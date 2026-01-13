import 'package:flutter/material.dart';

import '../data/avatar_catalog.dart';
import '../models/child_profile.dart';
import '../models/learning_category.dart';
import '../models/lesson.dart';
import '../models/progress_record.dart';
import '../services/app_services.dart';
import 'child_profile_screen.dart';
import 'lesson_list_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'animals/animals_overview_screen.dart';
import 'alphabet/alphabet_overview_screen.dart';
import 'colors/colors_overview_screen.dart';
import 'numbers/numbers_overview_screen.dart';
import 'shapes/shapes_overview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<ChildProfile?> _ensureProfileFuture;

  @override
  void initState() {
    super.initState();
    final user = AppServices.auth.currentUser;
    if (user == null) {
      _ensureProfileFuture = Future.value(null);
    } else {
      _ensureProfileFuture = _ensureProfileAndSelection(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppServices.auth.currentUser;
    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F5),
      body: SafeArea(
        child: FutureBuilder<ChildProfile?>(
          future: _ensureProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _HomeError(
                  message: 'We could not prepare your explorer.');
            }

            return AnimatedBuilder(
              animation: AppServices.childSelection,
              builder: (context, _) {
                final profile = AppServices.childSelection.activeProfile;
                if (profile == null) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const _ProfileRequired();
                }
                return _buildDashboard(context, user.uid, profile);
              },
            );
          },
        ),
      ),
    );
  }

  Future<ChildProfile?> _ensureProfileAndSelection(String userId) async {
    final profile = await AppServices.ensureDefaultChildProfile();
    if (!AppServices.childSelection.hasActiveProfile && profile != null) {
      await AppServices.childSelection.initialize(userId);
    }
    return profile;
  }

  Widget _buildDashboard(
    BuildContext context,
    String userId,
    ChildProfile profile,
  ) {
    return StreamBuilder<List<LearningCategory>>(
      stream: AppServices.learningContent.watchCategories(),
      builder: (context, categorySnapshot) {
        if (categorySnapshot.connectionState == ConnectionState.waiting &&
            !categorySnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categorySnapshot.hasError) {
          return const _HomeError(message: 'Unable to load categories.');
        }

        final categories = categorySnapshot.data ?? const <LearningCategory>[];
        if (categories.isEmpty) {
          return const _HomeEmptyState();
        }

        return StreamBuilder<List<Lesson>>(
          stream: AppServices.learningContent.watchLessons(),
          builder: (context, lessonSnapshot) {
            if (lessonSnapshot.connectionState == ConnectionState.waiting &&
                !lessonSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (lessonSnapshot.hasError) {
              return const _HomeError(message: 'Unable to load lessons.');
            }

            final lessons = lessonSnapshot.data ?? const <Lesson>[];
            final lessonsByCategory = <String, List<Lesson>>{};
            for (final lesson in lessons) {
              lessonsByCategory
                  .putIfAbsent(lesson.categoryId, () => <Lesson>[])
                  .add(lesson);
            }

            return StreamBuilder<List<ProgressRecord>>(
              stream: AppServices.progress.watchProgress(userId, profile.id),
              builder: (context, progressSnapshot) {
                if (progressSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    !progressSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (progressSnapshot.hasError) {
                  return const _HomeError(message: 'Unable to load progress.');
                }

                final progressRecords =
                    progressSnapshot.data ?? const <ProgressRecord>[];
                final progressMap = <String, ProgressRecord>{
                  for (final record in progressRecords) record.lessonId: record,
                };

                final cards = categories
                    .map(
                      (category) => _HomeCategoryCardData.from(
                        category: category,
                        lessons:
                            lessonsByCategory[category.id] ?? const <Lesson>[],
                        progress: progressMap,
                      ),
                    )
                    .toList(growable: false);

                return _HomeSurface(
                  profile: profile,
                  cards: cards,
                  onOpenCategory: (categoryId, title) {
                    _openCategory(context, categoryId, title);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _openCategory(BuildContext context, String categoryId, String title) {
    if (categoryId == 'alphabet') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AlphabetOverviewScreen(),
        ),
      );
      return;
    }
    if (categoryId == 'numbers') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NumbersOverviewScreen(categoryId: categoryId),
        ),
      );
      return;
    }
    if (categoryId == 'animals') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AnimalsOverviewScreen(),
        ),
      );
      return;
    }
    if (categoryId == 'colors') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ColorsOverviewScreen(),
        ),
      );
      return;
    }
    if (categoryId == 'shapes') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ShapesOverviewScreen(),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonListScreen(
          categoryId: categoryId,
          categoryTitle: title,
        ),
      ),
    );
  }
}

class _HomeSurface extends StatelessWidget {
  const _HomeSurface({
    required this.profile,
    required this.cards,
    required this.onOpenCategory,
  });

  final ChildProfile profile;
  final List<_HomeCategoryCardData> cards;
  final void Function(String categoryId, String title) onOpenCategory;

  @override
  Widget build(BuildContext context) {
    final avatar = AvatarCatalog.byKey(profile.avatarKey);
    return Container(
      color: const Color(0xFFF8F8F5),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HomeHeader(
                  avatar: avatar,
                  onSettings: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                const _HeroSection(),
                const SizedBox(height: 16),
                _ActiveProfileCard(profile: profile, avatar: avatar),
                const SizedBox(height: 24),
                _HomeCategoryGrid(
                  cards: cards,
                  onOpenCategory: onOpenCategory,
                ),
                const SizedBox(height: 24),
                const _HomeFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.avatar,
    required this.onSettings,
  });

  final AvatarData avatar;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AvatarBadge(avatar: avatar),
        const Expanded(
          child: Center(
            child: Text(
              'KIDO',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFFF2CC0D),
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        _CircleActionButton(
          icon: Icons.wb_sunny,
          foreground: const Color(0xFFF59E0B),
          background: const Color(0xFFFFEDD5),
          onTap: onSettings,
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Let's Play!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1C190D),
            height: 1.1,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Pick a game to start learning',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B8776),
          ),
        )
      ],
    );
  }
}

class _ActiveProfileCard extends StatelessWidget {
  const _ActiveProfileCard({required this.profile, required this.avatar});

  final ChildProfile profile;
  final AvatarData avatar;

  @override
  Widget build(BuildContext context) {
    final accent = avatar.accent;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 3),
            ),
            child: ClipOval(
              child: Image.network(
                avatar.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1C190D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level ${profile.level} • ${profile.stars} stars',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B6455),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.totalLessons} lessons • ${profile.totalQuizzes} quizzes',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF938C7A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap manage to switch explorers or review progress.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF938C7A),
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChildProfileScreen(),
                ),
              );
            },
            child: const Text(
              'Manage',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCategoryGrid extends StatelessWidget {
  const _HomeCategoryGrid({
    required this.cards,
    required this.onOpenCategory,
  });

  final List<_HomeCategoryCardData> cards;
  final void Function(String categoryId, String title) onOpenCategory;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return _CategoryCard(
          data: card,
          onTap: card.isLocked
              ? null
              : () => onOpenCategory(card.category.id, card.category.title),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.data, this.onTap});

  final _HomeCategoryCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final category = data.category;
    final heroImageUrl = category.heroImageUrl.isNotEmpty
        ? category.heroImageUrl
        : _CategoryIllustrations.heroFor(category.id);
    final overlayGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        category.gradientEndColor.withValues(alpha: 0.9),
        category.gradientStartColor.withValues(alpha: 0.55),
        Colors.transparent,
      ],
    );

    return Material(
      borderRadius: BorderRadius.circular(32),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: category.color,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: heroImageUrl.isEmpty
                        ? null
                        : DecorationImage(
                            image: NetworkImage(heroImageUrl),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CategoryBlobPainter(
                      primary: category.gradientStartColor,
                      secondary: category.gradientEndColor,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: overlayGradient,
                  ),
                ),
              ),
              if (data.isLocked)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        category.icon,
                        color: Colors.white,
                        size: 42,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _StatusChip(
                        status: data.status,
                        completionRatio: data.completionRatio,
                      ),
                    ],
                  ),
                ),
              ),
              if (data.isLocked)
                const Positioned(
                  top: 16,
                  right: 16,
                  child: Icon(Icons.lock_outline, color: Colors.white70),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.completionRatio});

  final _HomeCategoryStatus status;
  final double completionRatio;

  @override
  Widget build(BuildContext context) {
    late final Color background;
    late final IconData icon;
    late final String label;

    switch (status) {
      case _HomeCategoryStatus.completed:
        background = const Color(0xFFDCFCE7);
        icon = Icons.emoji_events_outlined;
        label = 'Completed';
        break;
      case _HomeCategoryStatus.inProgress:
        background = const Color(0xFFFFF7CD);
        icon = Icons.play_arrow_rounded;
        final percent = (completionRatio * 100).clamp(0, 100).round();
        label = '$percent% ready';
        break;
      case _HomeCategoryStatus.locked:
        background = Colors.white.withValues(alpha: 0.25);
        icon = Icons.lock_outline;
        label = 'Locked';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background.withValues(
          alpha: status == _HomeCategoryStatus.locked ? 0.7 : 1,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C190D),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryIllustrations {
  static const Map<String, String> _fallbacks = {
    'alphabet':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBTnfNXeLd9_oouiexVgu8W5NBjqii8O4RsbiPPltskFMa1udGMhHyHKdmRs_MQLPdl3s8qaFLteDjKJ0GBec9AhYG9HH_lUvIbSw12U72YLY0QTNYOvOtKvqBE6g7SZrc3WWTy8Byjdk8rrDqoSYRQhzmEUlGmDpgS9dEIi8Sn9_0h1ujvwpqxu7-2fennavs2xMiTIMnCPfVmt7X3JMZL492bJWzuTFBdSsIZ800sDut4v4FBxAhOYwgnOWurI7tNMIDh9hmCyJA',
    'numbers':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDwmLhwbwwLvItBzcE2UJdKgPexqod84SEz9r_Fc1EMt9VLlPVq-f5JCE-WDWCm_z6ZoeZeCKHLipVKuL2KTDQa8kfleOZCjWY2rkpw430Lwo4BM7YNEp-Ikwh6DfIBEg2SSPPCk5YslNNkEgwQ7EZZ7epB2wJmwARSOlOcCwlZzhpa4ZOyGGgWOaa-1Fl2trObX39bulPzhn_uOerK67EGyGDZ-Efljd2S6rUEbpyAFONNwAvUbvdfmU1qZU6b5pGyT08G_zNFsjM',
    'colors':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDOAgC3S2080xNeUF-Cl6dwCefwG0TEPMRcWd3X1iPzou3QNaeKDrZyFJSLOArLQJaO6rP5uZFIxwPq1DkawTlmGim-QlhjcUUrqmfGGySPN9bm_Qwnob80KCR1uoX_mqWQWxLKTzhSvYY4-VlU-jHse7wfiuiPgsOttsRcN1osVwIWKK9t_lzuxWGU18QmVtlj9tcYF0PmgaT9Jb0fsbtxiBu2NxDzkfxfTxTRfS6WS0ufTBmu-DxTJO05UvDAEcX5ljKrCRHrN2U',
    'animals':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCS8SqgG_01tVmv7UUSRf4H46nhHKXOkGq4moe9vlo-jITNofIijQkrDcTf2gZnEyR9dYtmy6gdtRZVg__i5BvV22ggwxVrf19Qt6cay6w6i5GZ4VsS3DPaoTRCgVKHkYrSMd2UtWeh8yvClZ-kMtOvxXitf7BffPTdOMpZHb6-ZTTGaWWyXwHpbnaHkgQL-eGXLO0rNFJwOvBopKpv6qx41aASzZd_uc5lyu7SVv2x-mlbJDxS8uImMqS7uUbsPWiq6FiCS28r0oo',
  };

  static String heroFor(String categoryId) {
    return _fallbacks[categoryId] ?? '';
  }
}

class _CategoryBlobPainter extends CustomPainter {
  _CategoryBlobPainter({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    paint.color = primary.withValues(alpha: 0.22);
    final lowerBlob = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.95,
        size.width * 0.55,
        size.height * 0.85,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.72,
        size.width * 0.85,
        size.height * 0.45,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.2,
        size.width * 0.45,
        size.height * 0.25,
      )
      ..quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.3,
        0,
        size.height * 0.45,
      )
      ..close();
    canvas.drawPath(lowerBlob, paint);

    paint.color = secondary.withValues(alpha: 0.3);
    final upperBlob = Path()
      ..moveTo(size.width, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.05,
        size.width * 0.5,
        size.height * 0.1,
      )
      ..quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.2,
        size.width * 0.2,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.75,
        size.width * 0.6,
        size.height * 0.65,
      )
      ..quadraticBezierTo(
        size.width * 0.95,
        size.height * 0.55,
        size.width,
        size.height * 0.35,
      )
      ..close();
    canvas.drawPath(upperBlob, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            '© 2024 Kido App',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9B9686),
            ),
          ),
        ),
        _CircleActionButton(
          icon: Icons.settings,
          foreground: const Color(0xFF4B5563),
          background: const Color(0xFFE5E7EB),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: foreground, size: 26),
        ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.avatar});

  final AvatarData avatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFDBEAFE),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(4),
      child: ClipOval(
        child: Image.network(
          avatar.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.person),
        ),
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF5F5B50),
        ),
      ),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty, size: 48, color: Color(0xFFB0AA99)),
            SizedBox(height: 12),
            Text(
              'Check back soon for more adventures!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B6455),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRequired extends StatelessWidget {
  const _ProfileRequired();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'Add an explorer to start learning!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _HomeCategoryCardData {
  const _HomeCategoryCardData({
    required this.category,
    required this.status,
    required this.completedLessons,
    required this.totalLessons,
    required this.completionRatio,
  });

  factory _HomeCategoryCardData.from({
    required LearningCategory category,
    required List<Lesson> lessons,
    required Map<String, ProgressRecord> progress,
  }) {
    if (lessons.isEmpty) {
      return _HomeCategoryCardData(
        category: category,
        status: _HomeCategoryStatus.locked,
        completedLessons: 0,
        totalLessons: 0,
        completionRatio: 0,
      );
    }

    var completed = 0;
    var unlocked = 0;
    for (final lesson in lessons) {
      final record = progress[lesson.id];
      final lessonStatus = _resolveLessonStatus(lesson, record);
      if (lessonStatus != LessonPlayStatus.locked) {
        unlocked += 1;
      }
      if (lessonStatus == LessonPlayStatus.completed) {
        completed += 1;
      }
    }

    final total = lessons.length;
    final completionRatio = total == 0 ? 0.0 : completed / total;

    final status = unlocked == 0
        ? _HomeCategoryStatus.locked
        : completed == total
            ? _HomeCategoryStatus.completed
            : _HomeCategoryStatus.inProgress;

    return _HomeCategoryCardData(
      category: category,
      status: status,
      completedLessons: completed,
      totalLessons: total,
      completionRatio: completionRatio,
    );
  }

  final LearningCategory category;
  final _HomeCategoryStatus status;
  final int completedLessons;
  final int totalLessons;
  final double completionRatio;

  bool get isLocked => status == _HomeCategoryStatus.locked;
}

enum _HomeCategoryStatus { locked, inProgress, completed }

LessonPlayStatus _resolveLessonStatus(
  Lesson lesson,
  ProgressRecord? record,
) {
  if (record != null) {
    return record.status;
  }
  switch (lesson.defaultStatus) {
    case LessonStatus.locked:
      return LessonPlayStatus.locked;
    case LessonStatus.start:
      return LessonPlayStatus.inProgress;
    case LessonStatus.ready:
      return LessonPlayStatus.ready;
  }
}
