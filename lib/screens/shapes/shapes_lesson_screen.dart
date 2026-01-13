import 'package:flutter/material.dart';

import '../../models/child_profile.dart';
import '../../models/lesson.dart';
import '../../models/progress_record.dart';
import '../../services/app_services.dart';
import '../../shapes/shapes_library.dart';
import '../login_screen.dart';
import 'shapes_activity_screen.dart';
import 'shapes_routes.dart';
import 'shapes_theme.dart';

class ShapesLessonScreen extends StatefulWidget {
  const ShapesLessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<ShapesLessonScreen> createState() => _ShapesLessonScreenState();
}

class _ShapesLessonScreenState extends State<ShapesLessonScreen> {
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
      return const _ErrorNotice('This shape is unavailable.');
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
          return const _ErrorNotice('Unable to load lesson progress.');
        }

        return _LessonView(metadata: metadata, record: snapshot.data);
      },
    );
  }
}

class _LessonView extends StatelessWidget {
  const _LessonView({required this.metadata, this.record});

  final ShapeLessonMetadata metadata;
  final ProgressRecord? record;

  @override
  Widget build(BuildContext context) {
    final index = ShapesLibrary.lessons.indexOf(metadata);
    final label = 'Lesson ${index + 1} of ${ShapesLibrary.lessons.length}';
    final status = record?.status ??
        _fallbackStatus(metadata.defaultStatus, record?.status);
    final bestScore = record?.bestScore ?? 0;
    final attempts = record?.attempts ?? 0;

    return Column(
      children: [
        _LessonHeader(metadata: metadata, progressLabel: label, status: status),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroPanel(metadata: metadata, status: status),
                const SizedBox(height: 16),
                _StatRow(
                  attempts: attempts,
                  bestScore: bestScore,
                  total: metadata.totalDiscoverySteps,
                ),
                const SizedBox(height: 16),
                _GalleryGrid(items: metadata.gallery),
                const SizedBox(height: 16),
                _ActivityPreview(metadata: metadata, status: status),
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

  final ShapeLessonMetadata metadata;
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
                color: ShapesTheme.primary),
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
                    color: ShapesTheme.textMain,
                  ),
                ),
                Text(
                  progressLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ShapesTheme.textMuted,
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
  const _HeroPanel({required this.metadata, required this.status});

  final ShapeLessonMetadata metadata;
  final LessonPlayStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: ShapesTheme.heroGradient(
          start: metadata.cardGradientStart,
          end: metadata.cardGradientEnd,
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: metadata.iconBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Icon(metadata.icon, color: metadata.iconColor, size: 32),
              ),
              const Spacer(),
              _StatusTag(status: status, dense: true),
            ],
          ),
          const SizedBox(height: 18),
          Text.rich(
            _buildHighlightSpan(
              metadata.heroStatement,
              metadata.highlightLabel,
              metadata.accentColor,
            ),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            metadata.heroDescription,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

TextSpan _buildHighlightSpan(
  String statement,
  String highlightLabel,
  Color accent,
) {
  final segments = statement.split('[highlight]');
  if (segments.length == 1) {
    return TextSpan(text: statement);
  }
  final children = <TextSpan>[];
  for (var i = 0; i < segments.length; i++) {
    final segment = segments[i];
    if (segment.isNotEmpty) {
      children.add(TextSpan(text: segment));
    }
    if (i < segments.length - 1) {
      children.add(
        TextSpan(
          text: highlightLabel,
          style: TextStyle(color: accent, fontWeight: FontWeight.w900),
        ),
      );
    }
  }
  return TextSpan(children: children);
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
            value: attempts == 0 ? 'New' : '$attempts',
            color: ShapesTheme.accentRose,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.auto_graph_rounded,
            label: 'Best Score',
            value: '$bestScore / $total',
            color: ShapesTheme.accentLeaf,
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
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
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

class _GalleryGrid extends StatelessWidget {
  const _GalleryGrid({required this.items});

  final List<ShapeGalleryItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spot the shapes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ShapesTheme.textMain,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.9,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(item.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ShapesTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ShapesTheme.textMuted,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ActivityPreview extends StatelessWidget {
  const _ActivityPreview({required this.metadata, required this.status});

  final ShapeLessonMetadata metadata;
  final LessonPlayStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: ShapesTheme.progressCard(
        borderColor: metadata.accentColor.withValues(alpha: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mini Mission',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: metadata.accentColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metadata.activityPrompt,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ShapesTheme.textMain,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: metadata.activityOptions
                .take(3)
                .map(
                  (option) => Chip(
                    backgroundColor:
                        option.backgroundColor.withValues(alpha: 0.2),
                    label: Text(option.label),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: status == LessonPlayStatus.locked
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings:
                            const RouteSettings(name: ShapesRoutes.activity),
                        builder: (_) => ShapesActivityScreen(
                          lessonId: metadata.lessonId,
                        ),
                      ),
                    );
                  },
            style: ShapesTheme.primaryPill(),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Activity'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: ShapesTheme.outlinePill(),
            child: const Text('Back to Lessons'),
          ),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status, this.dense = false});

  final LessonPlayStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final chip = _StatusChip.fromStatus(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 10 : 14,
        vertical: dense ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: chip.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        chip.label,
        style: TextStyle(
          fontSize: dense ? 10 : 12,
          fontWeight: FontWeight.w800,
          color: chip.foreground,
        ),
      ),
    );
  }
}

class _StatusChip {
  const _StatusChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  static _StatusChip fromStatus(LessonPlayStatus status) {
    switch (status) {
      case LessonPlayStatus.completed:
        return const _StatusChip(
          label: 'Completed',
          background: Color(0xFFDCFCE7),
          foreground: Color(0xFF166534),
        );
      case LessonPlayStatus.inProgress:
        return const _StatusChip(
          label: 'In Progress',
          background: Color(0xFFFEF3C7),
          foreground: Color(0xFF92400E),
        );
      case LessonPlayStatus.ready:
        return const _StatusChip(
          label: 'Ready',
          background: Color(0xFFE0E7FF),
          foreground: Color(0xFF3730A3),
        );
      case LessonPlayStatus.locked:
        return const _StatusChip(
          label: 'Locked',
          background: Color(0xFFFEE2E2),
          foreground: Color(0xFF991B1B),
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
                color: ShapesTheme.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
