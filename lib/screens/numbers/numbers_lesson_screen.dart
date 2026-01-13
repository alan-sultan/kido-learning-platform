import 'package:flutter/material.dart';

import '../../models/child_profile.dart';
import '../../models/lesson.dart';
import '../../models/progress_record.dart';
import '../../numbers/numbers_library.dart';
import '../../services/app_services.dart';
import '../login_screen.dart';
import 'numbers_activity_screen.dart';
import 'numbers_routes.dart';
import 'numbers_theme.dart';

class NumbersLessonScreen extends StatefulWidget {
  const NumbersLessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<NumbersLessonScreen> createState() => _NumbersLessonScreenState();
}

class _NumbersLessonScreenState extends State<NumbersLessonScreen> {
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

    final metadata = NumbersLibrary.byLessonId(widget.lessonId);
    if (metadata == null) {
      return const _ErrorNotice('That lesson is taking a nap.');
    }

    return Scaffold(
      backgroundColor: NumbersTheme.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: NumbersTheme.maxContentWidth),
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
                    return _LessonContent(
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

class _LessonContent extends StatelessWidget {
  const _LessonContent({
    required this.userId,
    required this.profile,
    required this.metadata,
  });

  final String userId;
  final ChildProfile profile;
  final NumberLessonMetadata metadata;

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
          return const _ErrorNotice('Unable to load lesson progress.');
        }

        final record = snapshot.data;
        return _LessonView(metadata: metadata, record: record);
      },
    );
  }
}

class _LessonView extends StatelessWidget {
  const _LessonView({required this.metadata, this.record});

  final NumberLessonMetadata metadata;
  final ProgressRecord? record;

  @override
  Widget build(BuildContext context) {
    final index = NumbersLibrary.lessons.indexOf(metadata);
    final progressLabel =
        'Lesson ${index + 1} of ${NumbersLibrary.lessons.length}';
    final stars = record?.starsEarned ?? 0;
    final attempts = record?.attempts ?? 0;
    final status = record?.status ?? _resolveDefaultStatus(metadata);

    return Column(
      children: [
        _LessonHeader(
          metadata: metadata,
          progressLabel: progressLabel,
          status: status,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroNumber(
                    metadata: metadata, stars: stars, attempts: attempts),
                const SizedBox(height: 16),
                _GalleryGrid(illustrations: metadata.gallery),
                const SizedBox(height: 16),
                _LearningPrompt(text: metadata.learningPrompt),
                const SizedBox(height: 20),
                _LessonActions(metadata: metadata),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({
    required this.metadata,
    required this.progressLabel,
    required this.status,
  });

  final NumberLessonMetadata metadata;
  final String progressLabel;
  final LessonPlayStatus status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  metadata.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: NumbersTheme.textMain,
                  ),
                ),
                Text(
                  progressLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: NumbersTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _StatusChip(status: status),
        ],
      ),
    );
  }
}

LessonPlayStatus _resolveDefaultStatus(NumberLessonMetadata metadata) {
  switch (metadata.defaultStatus) {
    case LessonStatus.ready:
      return LessonPlayStatus.ready;
    case LessonStatus.start:
      return LessonPlayStatus.inProgress;
    case LessonStatus.locked:
      return LessonPlayStatus.locked;
  }
}

class _HeroNumber extends StatelessWidget {
  const _HeroNumber({
    required this.metadata,
    required this.stars,
    required this.attempts,
  });

  final NumberLessonMetadata metadata;
  final int stars;
  final int attempts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            metadata.heroHeadline,
            style: TextStyle(
              fontSize: 120,
              fontWeight: FontWeight.w900,
              color: metadata.accentColor,
              height: 0.9,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            metadata.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: NumbersTheme.textMain,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatBadge(icon: Icons.star_rounded, label: '$stars stars'),
              const SizedBox(width: 12),
              _StatBadge(icon: Icons.repeat_rounded, label: '$attempts tries'),
            ],
          ),
        ],
      ),
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  const _GalleryGrid({required this.illustrations});

  final List<NumberIllustrationData> illustrations;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: illustrations.length,
      itemBuilder: (context, index) {
        final item = illustrations[index];
        return Container(
          decoration: BoxDecoration(
            color: item.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: item.borderColor, width: 4),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(item.imageUrl, fit: BoxFit.cover),
        );
      },
    );
  }
}

class _LearningPrompt extends StatelessWidget {
  const _LearningPrompt({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: NumbersTheme.textMain,
        ),
      ),
    );
  }
}

class _LessonActions extends StatelessWidget {
  const _LessonActions({required this.metadata});

  final NumberLessonMetadata metadata;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: NumbersRoutes.activity),
                builder: (_) =>
                    NumbersActivityScreen(lessonId: metadata.lessonId),
              ),
            );
          },
          style: NumbersTheme.solidPill(),
          icon: const Icon(Icons.extension_rounded, size: 26),
          label: Text('Play with ${metadata.heroHeadline}'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          style: NumbersTheme.outlinePill(),
          icon: const Icon(Icons.grid_view_rounded),
          label: const Text('Back to lessons'),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: NumbersTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: NumbersTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: NumbersTheme.textMain,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final LessonPlayStatus status;

  @override
  Widget build(BuildContext context) {
    final chip = _StatusChipData.fromStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chip.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chip.icon, size: 16, color: chip.color),
          const SizedBox(width: 6),
          Text(
            chip.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: chip.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChipData {
  const _StatusChipData({
    required this.label,
    required this.background,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color background;
  final Color color;
  final IconData icon;

  static _StatusChipData fromStatus(LessonPlayStatus status) {
    switch (status) {
      case LessonPlayStatus.completed:
        return const _StatusChipData(
          label: 'COMPLETED',
          background: Color(0xFFE3FCF0),
          color: Color(0xFF047857),
          icon: Icons.verified_rounded,
        );
      case LessonPlayStatus.inProgress:
        return const _StatusChipData(
          label: 'IN PROGRESS',
          background: Color(0xFFFFF7E6),
          color: Color(0xFFB45309),
          icon: Icons.play_arrow_rounded,
        );
      case LessonPlayStatus.ready:
        return const _StatusChipData(
          label: 'READY',
          background: Color(0xFFEDE9FE),
          color: NumbersTheme.primary,
          icon: Icons.auto_stories,
        );
      case LessonPlayStatus.locked:
        return const _StatusChipData(
          label: 'LOCKED',
          background: Color(0xFFF1F5F9),
          color: Color(0xFF94A3B8),
          icon: Icons.lock_rounded,
        );
    }
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
