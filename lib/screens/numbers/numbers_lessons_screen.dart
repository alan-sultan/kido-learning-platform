import 'package:flutter/material.dart';

import '../../models/child_profile.dart';
import '../../models/progress_record.dart';
import '../../numbers/numbers_library.dart';
import '../../services/app_services.dart';
import '../login_screen.dart';
import 'numbers_lesson_screen.dart';
import 'numbers_routes.dart';
import 'numbers_theme.dart';

class NumbersLessonListScreen extends StatefulWidget {
  const NumbersLessonListScreen({super.key, this.initialLessonId});

  final String? initialLessonId;

  @override
  State<NumbersLessonListScreen> createState() =>
      _NumbersLessonListScreenState();
}

class _NumbersLessonListScreenState extends State<NumbersLessonListScreen> {
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
      backgroundColor: NumbersTheme.background,
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
            if (NumbersLibrary.byLessonId(record.lessonId) != null)
              record.lessonId: record,
        };
        final entries = NumbersLibrary.buildEntries(progressMap);
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

  final List<NumberLessonEntry> entries;
  final int completedCount;
  final String? initialLessonId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(completedCount: completedCount, total: entries.length),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final highlight = entry.metadata.lessonId == initialLessonId;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _LessonCard(entry: entry, highlight: highlight),
              );
            },
          ),
        ),
        const _BottomTabs(),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Column(
                children: [
                  const Text(
                    'Numbers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: NumbersTheme.primary,
                    ),
                  ),
                  Text(
                    '$completedCount / $total mastered',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: NumbersTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.star_rounded, color: Colors.amber),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Let's learn numbers!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: NumbersTheme.textMain,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap a card to keep counting adventures going.',
            style: TextStyle(
              fontSize: 14,
              color: NumbersTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.entry, required this.highlight});

  final NumberLessonEntry entry;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final metadata = entry.metadata;
    final status = _StatusChip.fromStatus(entry.status);
    final borderColor = highlight ? metadata.accentColor : metadata.cardBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: metadata.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor, width: highlight ? 3 : 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: entry.isLocked
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings:
                        const RouteSettings(name: NumbersRoutes.lessonDetail),
                    builder: (_) => NumbersLessonScreen(
                      lessonId: metadata.lessonId,
                    ),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _LessonNumberBadge(metadata: metadata),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    status.build(),
                    const SizedBox(height: 6),
                    Text(
                      metadata.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: NumbersTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metadata.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: NumbersTheme.textMuted,
                        fontWeight: FontWeight.w600,
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
                                          name: NumbersRoutes.lessonDetail,
                                        ),
                                        builder: (_) => NumbersLessonScreen(
                                          lessonId: metadata.lessonId,
                                        ),
                                      ),
                                    );
                                  },
                            style: NumbersTheme.solidPill(
                              backgroundColor: entry.isCompleted
                                  ? metadata.accentColor.withValues(alpha: 0.2)
                                  : NumbersTheme.primary,
                              foregroundColor: entry.isCompleted
                                  ? metadata.accentColor
                                  : Colors.white,
                              shadowColor: entry.isCompleted
                                  ? Colors.transparent
                                  : NumbersTheme.primary,
                            ),
                            child: Text(_ctaLabel(entry.status)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _LessonImage(metadata: metadata),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonNumberBadge extends StatelessWidget {
  const _LessonNumberBadge({required this.metadata});

  final NumberLessonMetadata metadata;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: metadata.accentColor, width: 3),
      ),
      child: Center(
        child: Text(
          metadata.numberValue.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: metadata.accentColor,
          ),
        ),
      ),
    );
  }
}

class _LessonImage extends StatelessWidget {
  const _LessonImage({required this.metadata});

  final NumberLessonMetadata metadata;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        metadata.cardImageUrl,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _StatusChip {
  const _StatusChip({
    required this.label,
    required this.background,
    required this.textColor,
    required this.icon,
  });

  final String label;
  final Color background;
  final Color textColor;
  final IconData icon;

  Widget build() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  static _StatusChip fromStatus(LessonPlayStatus status) {
    switch (status) {
      case LessonPlayStatus.completed:
        return const _StatusChip(
          label: 'COMPLETED',
          background: Color(0xFFE3FCF0),
          textColor: Color(0xFF047857),
          icon: Icons.verified_rounded,
        );
      case LessonPlayStatus.inProgress:
        return const _StatusChip(
          label: 'IN PROGRESS',
          background: Color(0xFFFFF7E6),
          textColor: Color(0xFFB45309),
          icon: Icons.play_arrow_rounded,
        );
      case LessonPlayStatus.ready:
        return const _StatusChip(
          label: 'READY',
          background: Color(0xFFEDE9FE),
          textColor: NumbersTheme.primary,
          icon: Icons.auto_stories,
        );
      case LessonPlayStatus.locked:
        return const _StatusChip(
          label: 'LOCKED',
          background: Color(0xFFF1F5F9),
          textColor: Color(0xFF94A3B8),
          icon: Icons.lock_rounded,
        );
    }
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

class _BottomTabs extends StatelessWidget {
  const _BottomTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
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
          _TabIcon(icon: Icons.home_rounded, label: 'Home', active: true),
          _TabIcon(icon: Icons.auto_stories_rounded, label: 'Lessons'),
          _TabIcon(icon: Icons.emoji_events_rounded, label: 'Awards'),
          _TabIcon(icon: Icons.person_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? NumbersTheme.primary : NumbersTheme.textMuted;
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
        padding: const EdgeInsets.all(24),
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
