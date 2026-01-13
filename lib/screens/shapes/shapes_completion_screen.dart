import 'package:flutter/material.dart';

import '../../models/child_profile.dart';
import '../../models/progress_record.dart';
import '../../services/app_services.dart';
import '../../shapes/shapes_library.dart';
import '../login_screen.dart';
import 'shapes_lesson_screen.dart';
import 'shapes_lessons_screen.dart';
import 'shapes_routes.dart';
import 'shapes_theme.dart';

class ShapesCompletionScreen extends StatefulWidget {
  const ShapesCompletionScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<ShapesCompletionScreen> createState() => _ShapesCompletionScreenState();
}

class _ShapesCompletionScreenState extends State<ShapesCompletionScreen> {
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

    final metadata = ShapesLibrary.byLessonId(widget.lessonId);
    if (metadata == null) {
      return const _ErrorNotice('Celebration not found.');
    }

    return Scaffold(
      backgroundColor: ShapesTheme.canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: ShapesTheme.maxContentWidth),
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
                    return _CompletionStream(
                      userId: user.uid,
                      profile: profile,
                      metadata: metadata,
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

class _CompletionStream extends StatelessWidget {
  const _CompletionStream({
    required this.userId,
    required this.profile,
    required this.metadata,
  });

  final String userId;
  final ChildProfile profile;
  final ShapeLessonMetadata metadata;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProgressRecord?>(
      stream: AppServices.progress
          .watchLessonProgress(userId, profile.id, metadata.lessonId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const _ErrorNotice('Unable to load celebration.');
        }

        return _CompletionView(metadata: metadata, record: snapshot.data);
      },
    );
  }
}

class _CompletionView extends StatelessWidget {
  const _CompletionView({required this.metadata, this.record});

  final ShapeLessonMetadata metadata;
  final ProgressRecord? record;

  @override
  Widget build(BuildContext context) {
    final attempts = record?.attempts ?? 1;
    final best = record?.bestScore ?? metadata.totalDiscoverySteps;

    return Column(
      children: [
        _CompletionHeader(title: metadata.title),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CelebrationCard(metadata: metadata),
                const SizedBox(height: 18),
                _StatRow(
                    attempts: attempts,
                    bestScore: best,
                    total: metadata.totalDiscoverySteps),
                const SizedBox(height: 18),
                _RewardWrap(options: metadata.activityOptions),
                const SizedBox(height: 24),
                _CompletionActions(metadata: metadata),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompletionHeader extends StatelessWidget {
  const _CompletionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: ShapesTheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Shape Master!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ShapesTheme.primary,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ShapesTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _CelebrationCard extends StatelessWidget {
  const _CelebrationCard({required this.metadata});

  final ShapeLessonMetadata metadata;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: ShapesTheme.heroGradient(
                start: metadata.cardGradientStart,
                end: metadata.cardGradientEnd,
              ),
            ),
            child: Icon(metadata.completionIcon,
                color: metadata.iconColor, size: 70),
          ),
          const SizedBox(height: 12),
          Text(
            metadata.completionTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: ShapesTheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metadata.completionSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ShapesTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.attempts,
    required this.bestScore,
    required this.total,
  });

  final int attempts;
  final int bestScore;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.repeat_rounded,
            label: 'Attempts',
            value: '$attempts',
            color: ShapesTheme.accentRose,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.star_rounded,
            label: 'Best Score',
            value: '$bestScore / $total',
            color: ShapesTheme.accentSun,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: ShapesTheme.textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: ShapesTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardWrap extends StatelessWidget {
  const _RewardWrap({required this.options});

  final List<ShapeActivityOption> options;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: ShapesTheme.progressCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trophies Earned',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: ShapesTheme.textMain,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: options
                .map(
                  (option) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: option.backgroundColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(option.icon, color: option.backgroundColor),
                        const SizedBox(width: 6),
                        Text(
                          option.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: ShapesTheme.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CompletionActions extends StatelessWidget {
  const _CompletionActions({required this.metadata});

  final ShapeLessonMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final nextLesson = _nextLesson(metadata);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            if (nextLesson == null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: ShapesRoutes.lessonList),
                  builder: (_) => const ShapesLessonListScreen(),
                ),
              );
              return;
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: ShapesRoutes.lessonDetail),
                builder: (_) => ShapesLessonScreen(
                  lessonId: nextLesson.lessonId,
                ),
              ),
            );
          },
          style: ShapesTheme.primaryPill(),
          icon: Icon(nextLesson == null ? Icons.list_alt : Icons.bolt_rounded),
          label: Text(
            nextLesson == null ? 'Browse Lessons' : 'Next Shape',
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: ShapesRoutes.lessonList),
                builder: (_) => const ShapesLessonListScreen(),
              ),
            );
          },
          style: ShapesTheme.outlinePill(),
          child: const Text('Return to Library'),
        ),
      ],
    );
  }
}

ShapeLessonMetadata? _nextLesson(ShapeLessonMetadata current) {
  final index = ShapesLibrary.lessons.indexOf(current);
  if (index == -1) return null;
  final nextIndex = index + 1;
  if (nextIndex >= ShapesLibrary.lessons.length) {
    return null;
  }
  return ShapesLibrary.lessons[nextIndex];
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
                color: ShapesTheme.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
