import 'package:flutter/material.dart';

import '../../models/child_profile.dart';
import '../../models/learning_category.dart';
import '../../models/progress_record.dart';
import '../../numbers/numbers_library.dart';
import '../../services/app_services.dart';
import '../../services/navigation_service.dart';
import '../login_screen.dart';
import 'numbers_lessons_screen.dart';
import 'numbers_routes.dart';
import 'numbers_theme.dart';

class NumbersOverviewScreen extends StatefulWidget {
  const NumbersOverviewScreen({super.key, this.categoryId = 'numbers'});

  final String categoryId;

  @override
  State<NumbersOverviewScreen> createState() => _NumbersOverviewScreenState();
}

class _NumbersOverviewScreenState extends State<NumbersOverviewScreen> {
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
      backgroundColor: NumbersTheme.canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: NumbersTheme.maxContentWidth),
            child: FutureBuilder<ChildProfile?>(
              future: _ensureProfileFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const _ErrorNotice('Unable to load explorer profile.');
                }
                return AnimatedBuilder(
                  animation: AppServices.childSelection,
                  builder: (context, _) {
                    final profile = AppServices.childSelection.activeProfile;
                    if (profile == null) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return const _ErrorNotice('Create an explorer to begin.');
                    }
                    return _OverviewStreams(
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

class _OverviewStreams extends StatelessWidget {
  const _OverviewStreams({
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
        if (categorySnapshot.connectionState == ConnectionState.waiting &&
            !categorySnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (categorySnapshot.hasError) {
          return const _ErrorNotice('Unable to load categories.');
        }

        final categories = categorySnapshot.data ?? const <LearningCategory>[];
        final category = categories
            .where((cat) => cat.id == categoryId)
            .cast<LearningCategory?>()
            .firstOrNull;
        if (category == null) {
          return const _ErrorNotice('Numbers category is unavailable.');
        }

        return StreamBuilder<List<ProgressRecord>>(
          stream: AppServices.progress.watchProgress(userId, profile.id),
          builder: (context, progressSnapshot) {
            if (progressSnapshot.connectionState == ConnectionState.waiting &&
                !progressSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (progressSnapshot.hasError) {
              return const _ErrorNotice('Unable to load progress data.');
            }

            final progressRecords =
                progressSnapshot.data ?? const <ProgressRecord>[];
            final progressMap = <String, ProgressRecord>{
              for (final record in progressRecords)
                if (NumbersLibrary.byLessonId(record.lessonId) != null)
                  record.lessonId: record,
            };
            final entries = NumbersLibrary.buildEntries(progressMap);
            final completed =
                entries.where((entry) => entry.isCompleted).length;
            final completionRatio =
                entries.isEmpty ? 0.0 : completed / entries.length;
            final nextEntry = NumbersLibrary.nextPlayable(entries);

            return _OverviewBody(
              category: category,
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

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({
    required this.category,
    required this.entries,
    required this.completedCount,
    required this.progressRatio,
    required this.nextEntry,
  });

  final LearningCategory category;
  final List<NumberLessonEntry> entries;
  final int completedCount;
  final double progressRatio;
  final NumberLessonEntry? nextEntry;

  @override
  Widget build(BuildContext context) {
    const overview = NumbersLibrary.overview;
    final percentLabel = '${(progressRatio * 100).clamp(0, 100).round()}%';

    return Column(
      children: [
        _TopBar(categoryTitle: category.subtitle),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  category.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: NumbersTheme.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  overview.tagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: NumbersTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                _HeroCard(category: category, overview: overview),
                const SizedBox(height: 24),
                _ProgressCard(
                  label: overview.progressLabel,
                  completed: completedCount,
                  total: entries.length,
                  ratio: progressRatio,
                  percentage: percentLabel,
                  encouragement: overview.encouragement,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings:
                            const RouteSettings(name: NumbersRoutes.lessonList),
                        builder: (_) => NumbersLessonListScreen(
                          initialLessonId: nextEntry?.metadata.lessonId,
                        ),
                      ),
                    );
                  },
                  style: NumbersTheme.solidPill(
                    backgroundColor: NumbersTheme.accentGreen,
                    shadowColor: const Color(0xFF0DA341),
                  ),
                  icon: const Icon(Icons.play_circle_fill_rounded, size: 28),
                  label: Text(overview.ctaLabel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: NumbersTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.categoryTitle});

  final String categoryTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'KIDO',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: NumbersTheme.textMain,
                  ),
                ),
                Text(
                  categoryTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: NumbersTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _CircleButton(
            icon: Icons.settings_rounded,
            onTap: () {
              NavigationService.showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.category, required this.overview});

  final LearningCategory category;
  final NumbersOverviewContent overview;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: NumbersTheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: category.heroImageUrl.isEmpty
                  ? Container(color: category.color.withValues(alpha: 0.15))
                  : Image.network(
                      category.heroImageUrl,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFFACC15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x55FACC15),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  overview.heroBadgeSymbol,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                overview.subtitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: NumbersTheme.textMain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.label,
    required this.completed,
    required this.total,
    required this.ratio,
    required this.percentage,
    required this.encouragement,
  });

  final String label;
  final int completed;
  final int total;
  final double ratio;
  final String percentage;
  final String encouragement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NumbersTheme.softCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: NumbersTheme.textMain,
                ),
              ),
              const Spacer(),
              Text(
                percentage,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: NumbersTheme.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio.clamp(0, 1),
              minHeight: 14,
              backgroundColor: const Color(0xFFE4E2EC),
              color: NumbersTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$completed of $total lessons',
            style: const TextStyle(
              fontSize: 13,
              color: NumbersTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            encouragement,
            style: const TextStyle(
              fontSize: 13,
              color: NumbersTheme.textMuted,
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
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: NumbersTheme.textMain),
      ),
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
                color: NumbersTheme.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }
}
