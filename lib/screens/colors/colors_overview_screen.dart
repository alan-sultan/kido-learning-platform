import 'package:flutter/material.dart';

import '../../colors/colors_library.dart';
import '../../models/child_profile.dart';
import '../../models/learning_category.dart';
import '../../models/progress_record.dart';
import '../../services/app_services.dart';
import '../login_screen.dart';
import 'colors_lessons_screen.dart';
import 'colors_routes.dart';
import 'colors_theme.dart';

class ColorsOverviewScreen extends StatefulWidget {
  const ColorsOverviewScreen({super.key, this.categoryId = 'colors'});

  final String categoryId;

  @override
  State<ColorsOverviewScreen> createState() => _ColorsOverviewScreenState();
}

class _ColorsOverviewScreenState extends State<ColorsOverviewScreen> {
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
      return const LoginScreen();
    }

    return Scaffold(
      backgroundColor: ColorsTheme.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: ColorsTheme.maxContentWidth),
            child: FutureBuilder<ChildProfile?>(
              future: _ensureProfileFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const _ErrorNotice('Unable to load explorer.');
                }
                return AnimatedBuilder(
                  animation: AppServices.childSelection,
                  builder: (context, _) {
                    final profile = AppServices.childSelection.activeProfile;
                    if (profile == null) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return const _ErrorNotice('Create an explorer first.');
                    }
                    return _CategoryStream(
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
      ),
    );
  }
}

class _CategoryStream extends StatelessWidget {
  const _CategoryStream({
    required this.userId,
    required this.profile,
    required this.categoryId,
  });

  final String userId;
  final ChildProfile profile;
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LearningCategory?>(
      future: AppServices.learningContent
          .fetchCategories()
          .then((list) => list.firstWhere(
                (category) => category.id == categoryId,
                orElse: () => LearningCategory(
                  id: categoryId,
                  title: ColorsLibrary.overview.subtitle,
                  subtitle: 'Creative',
                  topic: 'Art & expression',
                  iconName: 'palette',
                  colorHex: '#EDE9FE',
                  order: 3,
                  heroImageUrl: ColorsLibrary.overview.heroImageUrl,
                  gradientStartHex: '#C084FC',
                  gradientEndHex: '#A855F7',
                  accentHex: '#FFFFFF',
                ),
              )),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const _ErrorNotice('Colors category is unavailable.');
        }

        final category = snapshot.data;
        if (category == null) {
          return const _ErrorNotice('Colors category missing.');
        }

        return StreamBuilder<List<ProgressRecord>>(
          stream: AppServices.progress.watchProgress(userId, profile.id),
          builder: (context, progressSnapshot) {
            if (progressSnapshot.connectionState == ConnectionState.waiting &&
                !progressSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (progressSnapshot.hasError) {
              return const _ErrorNotice('Unable to load progress.');
            }

            final progressRecords =
                progressSnapshot.data ?? const <ProgressRecord>[];
            final progressMap = <String, ProgressRecord>{
              for (final record in progressRecords)
                if (ColorsLibrary.byLessonId(record.lessonId) != null)
                  record.lessonId: record,
            };
            final entries = ColorsLibrary.buildEntries(progressMap);
            final completed =
                entries.where((entry) => entry.isCompleted).length;
            final ratio = entries.isEmpty ? 0.0 : completed / entries.length;
            final nextEntry = ColorsLibrary.nextPlayable(entries);

            return _OverviewBody(
              category: category,
              entries: entries,
              completedCount: completed,
              progressRatio: ratio,
              nextEntry: nextEntry,
            );
          },
        );
      },
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({
    required this.category,
    required this.entries,
    required this.completedCount,
    required this.progressRatio,
    required this.nextEntry,
  });

  final LearningCategory category;
  final List<ColorLessonEntry> entries;
  final int completedCount;
  final double progressRatio;
  final ColorLessonEntry? nextEntry;

  @override
  Widget build(BuildContext context) {
    const overview = ColorsLibrary.overview;
    final percentLabel = '${(progressRatio * 100).clamp(0, 100).round()}%';

    return Column(
      children: [
        const SizedBox(height: 12),
        _TopBar(title: category.subtitle),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                _HeroIllustration(imageUrl: overview.heroImageUrl),
                const SizedBox(height: 12),
                Text(
                  category.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: ColorsTheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  overview.tagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorsTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                _ProgressCard(
                  label: overview.progressLabel,
                  encouragement: overview.encouragement,
                  completed: completedCount,
                  total: entries.length,
                  ratio: progressRatio,
                  percentageLabel: percentLabel,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings:
                            const RouteSettings(name: ColorsRoutes.lessonList),
                        builder: (_) => ColorsLessonListScreen(
                          initialLessonId: nextEntry?.metadata.lessonId,
                        ),
                      ),
                    );
                  },
                  style: ColorsTheme.primaryPill(),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(overview.ctaLabel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: ColorsTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const _BottomNav(),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: ColorsTheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: ColorsTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorsTheme.primary.withValues(alpha: 0.08),
            border: Border.all(color: Colors.white, width: 8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 30,
                offset: Offset(0, 20),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
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
    required this.label,
    required this.encouragement,
    required this.completed,
    required this.total,
    required this.ratio,
    required this.percentageLabel,
  });

  final String label;
  final String encouragement;
  final int completed;
  final int total;
  final double ratio;
  final String percentageLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ColorsTheme.progressCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ColorsTheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorsTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  percentageLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: ColorsTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio.clamp(0, 1),
              minHeight: 14,
              backgroundColor: ColorsTheme.primary.withValues(alpha: 0.15),
              color: ColorsTheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$completed of $total completed',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: ColorsTheme.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            encouragement,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ColorsTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIcon(icon: Icons.home, label: 'HOME', active: true),
          _NavIcon(icon: Icons.category, label: 'TOPICS'),
          _NavIcon(icon: Icons.military_tech, label: 'AWARDS'),
          _NavIcon(icon: Icons.person, label: 'PROFILE'),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? ColorsTheme.primary : ColorsTheme.textMuted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorsTheme.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
