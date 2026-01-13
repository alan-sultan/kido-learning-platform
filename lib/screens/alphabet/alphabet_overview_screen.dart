import 'package:flutter/material.dart';

import '../../alphabet/alphabet_library.dart';
import '../../data/seeded_learning_content.dart';
import '../../models/child_profile.dart';
import '../../models/learning_category.dart';
import '../../models/progress_record.dart';
import '../../services/app_services.dart';
import '../../services/navigation_service.dart';
import '../login_screen.dart';
import 'alphabet_lessons_screen.dart';
import 'alphabet_routes.dart';
import 'alphabet_theme.dart';

class AlphabetOverviewScreen extends StatefulWidget {
  const AlphabetOverviewScreen({super.key, this.categoryId = 'alphabet'});

  final String categoryId;

  @override
  State<AlphabetOverviewScreen> createState() => _AlphabetOverviewScreenState();
}

class _AlphabetOverviewScreenState extends State<AlphabetOverviewScreen> {
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

  Future<ChildProfile?> _ensureProfileAndSelection(String userId) async {
    final profile = await AppServices.ensureDefaultChildProfile();
    if (!AppServices.childSelection.hasActiveProfile && profile != null) {
      await AppServices.childSelection.initialize(userId);
    }
    return profile;
  }

  @override
  Widget build(BuildContext context) {
    final user = AppServices.auth.currentUser;
    if (user == null) {
      return _AuthRequired(onSignIn: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    }

    return Scaffold(
      backgroundColor: AlphabetTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            const _BackgroundBubbles(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    maxWidth: AlphabetTheme.maxContentWidth),
                child: FutureBuilder<ChildProfile?>(
                  future: _ensureProfileFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const _ErrorState(
                          message: 'Unable to load your explorer.');
                    }
                    return AnimatedBuilder(
                      animation: AppServices.childSelection,
                      builder: (context, _) {
                        final profile =
                            AppServices.childSelection.activeProfile;
                        if (profile == null) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return const _ProfileMissing();
                        }
                        return _AlphabetStreams(
                          userId: user.uid,
                          profile: profile,
                          categoryId: widget.categoryId,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlphabetStreams extends StatelessWidget {
  const _AlphabetStreams({
    required this.userId,
    required this.profile,
    required this.categoryId,
  });

  final String userId;
  final ChildProfile profile;
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LearningCategory>>(
      stream: AppServices.learningContent.watchCategories(),
      builder: (context, categorySnapshot) {
        if (categorySnapshot.hasError) {
          return const _ErrorState(message: 'Unable to load categories.');
        }
        final category = _resolveCategory(categorySnapshot.data, categoryId);
        if (category == null) {
          return const _ErrorState(
              message: 'Alphabet adventure is unavailable.');
        }
        return StreamBuilder<List<ProgressRecord>>(
          stream: AppServices.progress.watchProgress(userId, profile.id),
          builder: (context, progressSnapshot) {
            if (progressSnapshot.connectionState == ConnectionState.waiting &&
                !progressSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (progressSnapshot.hasError) {
              return const _ErrorState(message: 'Unable to load progress.');
            }

            final progressRecords =
                progressSnapshot.data ?? const <ProgressRecord>[];
            final progressMap = <String, ProgressRecord>{
              for (final record in progressRecords)
                if (AlphabetLibrary.byLessonId(record.lessonId) != null)
                  record.lessonId: record,
            };
            final entries = AlphabetLibrary.buildEntries(progressMap);
            final completed =
                entries.where((entry) => entry.isCompleted).length;
            final nextEntry = AlphabetLibrary.nextPlayable(entries);
            final completionRatio =
                entries.isEmpty ? 0.0 : completed / entries.length;

            return _OverviewContent(
              category: category,
              profile: profile,
              entries: entries,
              completedCount: completed,
              progressRatio: completionRatio,
              nextEntry: nextEntry,
            );
          },
        );
      },
    );
  }
}

class _OverviewContent extends StatelessWidget {
  const _OverviewContent({
    required this.category,
    required this.profile,
    required this.entries,
    required this.completedCount,
    required this.progressRatio,
    required this.nextEntry,
  });

  final LearningCategory category;
  final ChildProfile profile;
  final List<AlphabetLetterEntry> entries;
  final int completedCount;
  final double progressRatio;
  final AlphabetLetterEntry? nextEntry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OverviewHeader(profile: profile),
          const SizedBox(height: 16),
          _HeroImage(category: category),
          const SizedBox(height: 16),
          Text(
            category.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: AlphabetTheme.textMain,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ready to learn your ABCs?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AlphabetTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          _ProgressCard(
            completed: completedCount,
            total: entries.length,
            ratio: progressRatio,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings:
                      const RouteSettings(name: AlphabetRoutes.lessonList),
                  builder: (_) => AlphabetLessonListScreen(
                    initialLetterId: nextEntry?.metadata.lessonId,
                  ),
                ),
              );
            },
            style: AlphabetTheme.ctaButtonStyle(),
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label:
                Text(nextEntry == null ? 'Review Letters' : 'Start Learning'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Back to Home',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AlphabetTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.profile});

  final ChildProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleButton(
          icon: Icons.arrow_back,
          onTap: () => Navigator.pop(context),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'KIDO Learning',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AlphabetTheme.textMain,
                ),
              ),
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AlphabetTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            NavigationService.showSnackBar(
              const SnackBar(content: Text('Need help? Coming soon!')),
            );
          },
          icon: const Icon(Icons.help_outline, color: AlphabetTheme.textMain),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.category});

  final LearningCategory category;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: category.color.withValues(alpha: 0.25),
          image: category.heroImageUrl.isEmpty
              ? null
              : DecorationImage(
                  image: NetworkImage(category.heroImageUrl),
                  fit: BoxFit.cover,
                ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category.subtitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AlphabetTheme.textMain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.ratio,
  });

  final int completed;
  final int total;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final percent = (ratio * 100).clamp(0, 100).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8E4CE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Letters Found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AlphabetTheme.textMain,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AlphabetTheme.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$completed / $total',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AlphabetTheme.textMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 14,
              backgroundColor: const Color(0xFFE8E4CE),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AlphabetTheme.primary),
              value: ratio,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$percent% complete',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AlphabetTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: AlphabetTheme.textMain),
      ),
    );
  }
}

class _BackgroundBubbles extends StatelessWidget {
  const _BackgroundBubbles();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _bubble(const Color(0x33F2CC0D), 220),
          ),
          Positioned(
            bottom: 120,
            left: -40,
            child: _bubble(const Color(0x33FF8C42), 180),
          ),
        ],
      ),
    );
  }

  Widget _bubble(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _AuthRequired extends StatelessWidget {
  const _AuthRequired({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AlphabetTheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sign in to view the alphabet journey.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AlphabetTheme.textMain,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSignIn,
              style: AlphabetTheme.ctaButtonStyle(),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMissing extends StatelessWidget {
  const _ProfileMissing();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'Add an explorer profile to begin this adventure.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AlphabetTheme.textMain,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sentiment_dissatisfied,
                color: AlphabetTheme.textMuted, size: 42),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AlphabetTheme.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

LearningCategory? _resolveCategory(
  List<LearningCategory>? categories,
  String categoryId,
) {
  final list = categories ?? SeededLearningContent.categories;
  for (final category in list) {
    if (category.id == categoryId) return category;
  }
  return null;
}
