import 'package:flutter/material.dart';

import '../../models/child_profile.dart';
import '../../models/progress_record.dart';
import '../../services/app_services.dart';
import '../../shapes/shapes_library.dart';
import '../login_screen.dart';
import 'shapes_lesson_screen.dart';
import 'shapes_routes.dart';
import 'shapes_theme.dart';

class ShapesLessonListScreen extends StatefulWidget {
  const ShapesLessonListScreen({super.key, this.initialLessonId});

  final String? initialLessonId;

  @override
  State<ShapesLessonListScreen> createState() => _ShapesLessonListScreenState();
}

class _ShapesLessonListScreenState extends State<ShapesLessonListScreen> {
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
      backgroundColor: ShapesTheme.background,
      body: SafeArea(
        child: FutureBuilder<ChildProfile?>(
          future: _ensureProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _ErrorNotice('Could not load explorer data.');
            }
            return AnimatedBuilder(
              animation: AppServices.childSelection,
              builder: (context, _) {
                final profile = AppServices.childSelection.activeProfile;
                if (profile == null) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const _ErrorNotice('Create an explorer to continue.');
                }
                return _LessonStream(
                  userId: user.uid,
                  profile: profile,
                  initialLessonId: widget.initialLessonId,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _LessonStream extends StatelessWidget {
  const _LessonStream({
    required this.userId,
    required this.profile,
    required this.initialLessonId,
  });

  final String userId;
  final ChildProfile profile;
  final String? initialLessonId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProgressRecord>>(
      stream: AppServices.progress.watchProgress(userId, profile.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const _ErrorNotice('Unable to load lesson progress.');
        }

        final records = snapshot.data ?? const <ProgressRecord>[];
        final progressMap = <String, ProgressRecord>{
          for (final record in records)
            if (ShapesLibrary.byLessonId(record.lessonId) != null)
              record.lessonId: record,
        };
        final entries = ShapesLibrary.buildEntries(progressMap);
        final completed = entries.where((entry) => entry.isCompleted).length;

        return _LessonListBody(
          entries: entries,
          completedCount: completed,
          initialLessonId: initialLessonId,
        );
      },
    );
  }
}

class _LessonListBody extends StatelessWidget {
  const _LessonListBody({
    required this.entries,
    required this.completedCount,
    required this.initialLessonId,
  });

  final List<ShapeLessonEntry> entries;
  final int completedCount;
  final String? initialLessonId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(completedCount: completedCount, total: entries.length),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final highlight = entry.metadata.lessonId == initialLessonId;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _LessonCard(entry: entry, highlight: highlight),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.completedCount, required this.total});

  final int completedCount;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: ShapesTheme.primary),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Column(
                children: [
                  const Text(
                    'Shapes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: ShapesTheme.primary,
                    ),
                  ),
                  Text(
                    '$completedCount / $total mastered',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ShapesTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.auto_awesome_mosaic,
                    color: ShapesTheme.accentSun),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Shape Library',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: ShapesTheme.textMain,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose a shape to explore.',
            style: TextStyle(
              fontSize: 14,
              color: ShapesTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.entry, required this.highlight});

  final ShapeLessonEntry entry;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final metadata = entry.metadata;
    final chip = _StatusChip.fromStatus(entry.status);
    final gradient = ShapesTheme.heroGradient(
      start: metadata.cardGradientStart,
      end: metadata.cardGradientEnd,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: highlight
              ? metadata.accentColor
              : metadata.accentColor.withValues(alpha: 0.4),
          width: highlight ? 3 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: metadata.accentColor.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: entry.isLocked
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings:
                        const RouteSettings(name: ShapesRoutes.lessonDetail),
                    builder: (_) => ShapesLessonScreen(
                      lessonId: metadata.lessonId,
                    ),
                  ),
                );
              },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: gradient,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _LessonHero(metadata: metadata),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      chip.build(),
                      const SizedBox(height: 8),
                      Text(
                        metadata.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metadata.listDescription,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: entry.progressRatio(),
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chip.description(entry),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: entry.isLocked
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          settings: const RouteSettings(
                                            name: ShapesRoutes.lessonDetail,
                                          ),
                                          builder: (_) => ShapesLessonScreen(
                                            lessonId: metadata.lessonId,
                                          ),
                                        ),
                                      );
                                    },
                              style: ShapesTheme.primaryPill(
                                backgroundColor: Colors.white,
                              ).copyWith(
                                foregroundColor: WidgetStateProperty.all<Color>(
                                  metadata.accentColor,
                                ),
                                elevation: WidgetStateProperty.all<double>(0),
                              ),
                              child: Text(_ctaLabel(entry.status)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  metadata.icon,
                  color: metadata.iconColor,
                  size: 48,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonHero extends StatelessWidget {
  const _LessonHero({required this.metadata});

  final ShapeLessonMetadata metadata;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: metadata.iconBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Icon(metadata.icon, color: metadata.iconColor, size: 40),
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

  Widget build() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }

  String description(ShapeLessonEntry entry) {
    if (entry.isCompleted) {
      return 'Completed lesson';
    }
    if (entry.isInProgress) {
      return 'Keep going!';
    }
    if (entry.isLocked) {
      return 'Unlock by finishing previous shape';
    }
    return 'Tap to start learning';
  }
}

String _ctaLabel(LessonPlayStatus status) {
  switch (status) {
    case LessonPlayStatus.completed:
      return 'Review';
    case LessonPlayStatus.inProgress:
      return 'Continue';
    case LessonPlayStatus.ready:
      return 'Start';
    case LessonPlayStatus.locked:
      return 'Locked';
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
