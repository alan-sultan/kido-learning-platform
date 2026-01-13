import 'package:flutter/material.dart';

import '../../colors/colors_library.dart';
import '../../models/child_profile.dart';
import '../../models/progress_record.dart';
import '../../services/app_services.dart';
import '../login_screen.dart';
import 'colors_lesson_screen.dart';
import 'colors_lessons_screen.dart';
import 'colors_routes.dart';
import 'colors_theme.dart';

class ColorsCompletionScreen extends StatefulWidget {
  const ColorsCompletionScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<ColorsCompletionScreen> createState() => _ColorsCompletionScreenState();
}

class _ColorsCompletionScreenState extends State<ColorsCompletionScreen> {
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

    final metadata = ColorsLibrary.byLessonId(widget.lessonId);
    if (metadata == null) {
      return const _ErrorNotice('Celebration not found.');
    }

    return Scaffold(
      backgroundColor: ColorsTheme.canvas,
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
  final ColorLessonMetadata metadata;

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

  final ColorLessonMetadata metadata;
  final ProgressRecord? record;

  @override
  Widget build(BuildContext context) {
    final attempts = record?.attempts ?? 1;
    final stars = record?.starsEarned ?? 1;

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
                _StatRow(attempts: attempts, stars: stars),
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
            icon: const Icon(Icons.close_rounded, color: ColorsTheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Color Champion!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ColorsTheme.primary,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorsTheme.textMuted,
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

  final ColorLessonMetadata metadata;

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
            height: 220,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(metadata.completionMascotUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            metadata.completionTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: ColorsTheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metadata.completionSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ColorsTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.attempts, required this.stars});

  final int attempts;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.repeat_rounded,
            label: 'Attempts',
            value: '$attempts',
            color: const Color(0xFFFB7185),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.star_rounded,
            label: 'Stars',
            value: '$stars',
            color: const Color(0xFFFACC15),
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
              color: ColorsTheme.textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: ColorsTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionActions extends StatelessWidget {
  const _CompletionActions({required this.metadata});

  final ColorLessonMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final nextLesson = _nextLesson(metadata);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            if (nextLesson == null) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: ColorsRoutes.lessonList),
                  builder: (_) => const ColorsLessonListScreen(),
                ),
                (route) => route.isFirst,
              );
              return;
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: ColorsRoutes.lessonDetail),
                builder: (_) => ColorsLessonScreen(
                  lessonId: nextLesson.lessonId,
                ),
              ),
            );
          },
          style: ColorsTheme.primaryPill(),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(nextLesson == null ? 'Back to Colors' : 'Next Color'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: ColorsRoutes.lessonList),
                builder: (_) => const ColorsLessonListScreen(),
              ),
              (route) => route.isFirst,
            );
          },
          style: ColorsTheme.outlinePill(),
          icon: const Icon(Icons.grid_view_rounded),
          label: const Text('All colors'),
        ),
      ],
    );
  }

  ColorLessonMetadata? _nextLesson(ColorLessonMetadata metadata) {
    final list = ColorsLibrary.lessons;
    final index = list.indexOf(metadata);
    if (index == -1 || index + 1 >= list.length) return null;
    return list[index + 1];
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
