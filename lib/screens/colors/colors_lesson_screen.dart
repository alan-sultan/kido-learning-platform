import 'package:flutter/material.dart';

import '../../colors/colors_library.dart';
import '../../models/child_profile.dart';
import '../../models/lesson.dart';
import '../../models/progress_record.dart';
import '../../services/app_services.dart';
import '../login_screen.dart';
import 'colors_activity_screen.dart';
import 'colors_routes.dart';
import 'colors_theme.dart';

class ColorsLessonScreen extends StatefulWidget {
  const ColorsLessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<ColorsLessonScreen> createState() => _ColorsLessonScreenState();
}

class _ColorsLessonScreenState extends State<ColorsLessonScreen> {
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
      return const _ErrorNotice('This color took a break.');
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
                  return const _ErrorNotice('Unable to load explorer data.');
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

  final ColorLessonMetadata metadata;
  final ProgressRecord? record;

  @override
  Widget build(BuildContext context) {
    final index = ColorsLibrary.lessons.indexOf(metadata);
    final label = 'Lesson ${index + 1} of ${ColorsLibrary.lessons.length}';
    final status = record?.status ??
        _fallbackStatus(metadata.defaultStatus, record?.status);
    final stars = record?.starsEarned ?? 0;

    return Column(
      children: [
        _LessonHeader(
          metadata: metadata,
          progressLabel: label,
          status: status,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroPanel(metadata: metadata, stars: stars),
                const SizedBox(height: 16),
                _GalleryGrid(items: metadata.gallery),
                const SizedBox(height: 16),
                _LearningPrompt(text: metadata.description),
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

LessonPlayStatus _fallbackStatus(
  LessonStatus defaultStatus,
  LessonPlayStatus? recordStatus,
) {
  if (recordStatus != null) return recordStatus;
  switch (defaultStatus) {
    case LessonStatus.ready:
      return LessonPlayStatus.ready;
    case LessonStatus.start:
      return LessonPlayStatus.inProgress;
    case LessonStatus.locked:
      return LessonPlayStatus.locked;
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({
    required this.metadata,
    required this.progressLabel,
    required this.status,
  });

  final ColorLessonMetadata metadata;
  final String progressLabel;
  final LessonPlayStatus status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: ColorsTheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  metadata.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ColorsTheme.textMain,
                  ),
                ),
                Text(
                  progressLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorsTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _StatusTag(status: status),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.metadata, required this.stars});

  final ColorLessonMetadata metadata;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: ColorsTheme.heroGradient(
          start: metadata.gradientStart,
          end: metadata.gradientEnd,
        ),
        boxShadow: [
          BoxShadow(
            color: metadata.accentColor.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  metadata.heroLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  3,
                  (index) => Icon(
                    Icons.star_rounded,
                    color:
                        index < stars ? ColorsTheme.accentSun : Colors.white24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                metadata.heroImageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            metadata.voiceLine,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  const _GalleryGrid({required this.items});

  final List<ColorGalleryItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: item.backgroundColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: item.borderColor, width: 3),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(item.imageUrl, fit: BoxFit.cover),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: ColorsTheme.textMain,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: ColorsTheme.progressCard(),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ColorsTheme.textMain,
        ),
      ),
    );
  }
}

class _LessonActions extends StatelessWidget {
  const _LessonActions({required this.metadata});

  final ColorLessonMetadata metadata;

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
                settings: const RouteSettings(name: ColorsRoutes.activity),
                builder: (_) => ColorsActivityScreen(
                  lessonId: metadata.lessonId,
                ),
              ),
            );
          },
          style: ColorsTheme.primaryPill(),
          icon: const Icon(Icons.palette_rounded),
          label: Text('Paint with ${metadata.displayName}'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          style: ColorsTheme.outlinePill(),
          icon: const Icon(Icons.grid_view_rounded),
          label: const Text('Back to colors'),
        ),
      ],
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status});

  final LessonPlayStatus status;

  @override
  Widget build(BuildContext context) {
    late final Color background;
    late final String label;
    late final Color textColor;

    switch (status) {
      case LessonPlayStatus.completed:
        background = const Color(0xFFE1F9F0);
        textColor = const Color(0xFF047857);
        label = 'Mastered';
        break;
      case LessonPlayStatus.inProgress:
        background = const Color(0xFFFFF7E5);
        textColor = const Color(0xFFB45309);
        label = 'In Progress';
        break;
      case LessonPlayStatus.ready:
        background = const Color(0xFFEDE9FE);
        textColor = ColorsTheme.primary;
        label = 'Ready';
        break;
      case LessonPlayStatus.locked:
        background = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF94A3B8);
        label = 'Locked';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
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
                color: ColorsTheme.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
