import 'package:flutter/material.dart';

import '../../alphabet/alphabet_library.dart';
import '../../models/child_profile.dart';
import '../../models/progress_record.dart';
import '../../services/app_services.dart';
import '../login_screen.dart';
import 'alphabet_lesson_screen.dart';
import 'alphabet_routes.dart';
import 'alphabet_theme.dart';

class AlphabetLessonListScreen extends StatefulWidget {
  const AlphabetLessonListScreen({super.key, this.initialLetterId});

  final String? initialLetterId;

  @override
  State<AlphabetLessonListScreen> createState() =>
      _AlphabetLessonListScreenState();
}

class _AlphabetLessonListScreenState extends State<AlphabetLessonListScreen> {
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
      return _UnauthorizedView(
        onSignIn: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: AlphabetTheme.background,
      body: SafeArea(
        child: FutureBuilder<ChildProfile?>(
          future: _ensureProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _ErrorNotice('Could not prepare your explorer.');
            }
            return AnimatedBuilder(
              animation: AppServices.childSelection,
              builder: (context, _) {
                final profile = AppServices.childSelection.activeProfile;
                if (profile == null) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const _ErrorNotice('Add an explorer to view lessons.');
                }
                return _LessonListStreams(
                  userId: user.uid,
                  profile: profile,
                  initialLetterId: widget.initialLetterId,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _LessonListStreams extends StatelessWidget {
  const _LessonListStreams({
    required this.userId,
    required this.profile,
    required this.initialLetterId,
  });

  final String userId;
  final ChildProfile profile;
  final String? initialLetterId;

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
          return const _ErrorNotice('Unable to load progress data.');
        }

        final records = snapshot.data ?? const <ProgressRecord>[];
        final progressMap = <String, ProgressRecord>{
          for (final record in records)
            if (AlphabetLibrary.byLessonId(record.lessonId) != null)
              record.lessonId: record,
        };
        final entries = AlphabetLibrary.buildEntries(progressMap);
        final completed = entries.where((entry) => entry.isCompleted).length;

        return _LessonListBody(
          entries: entries,
          completed: completed,
          initialLetterId: initialLetterId,
        );
      },
    );
  }
}

class _LessonListBody extends StatelessWidget {
  const _LessonListBody({
    required this.entries,
    required this.completed,
    required this.initialLetterId,
  });

  final List<AlphabetLetterEntry> entries;
  final int completed;
  final String? initialLetterId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ListHeader(completed: completed, total: entries.length),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 160),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isSuggested = initialLetterId != null &&
                  entry.metadata.lessonId == initialLetterId;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _LetterCard(entry: entry, highlight: isSuggested),
              );
            },
          ),
        ),
        const _FloatingNav(),
      ],
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Alphabet Journey',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AlphabetTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$completed / $total letters',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AlphabetTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Let's learn letters!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AlphabetTheme.textMain,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap a card to start your adventure',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AlphabetTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterCard extends StatelessWidget {
  const _LetterCard({required this.entry, required this.highlight});

  final AlphabetLetterEntry entry;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final metadata = entry.metadata;
    final hero = _LetterHero(entry: entry);
    final statusChip = _StatusChip(status: entry.status);
    final calloutColor = highlight ? metadata.accentColor : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: highlight ? calloutColor : const Color(0xFFE5E1D2),
          width: highlight ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: entry.isLocked
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings:
                        const RouteSettings(name: AlphabetRoutes.lessonDetail),
                    builder: (_) => AlphabetLessonScreen(
                      letterId: metadata.lessonId,
                    ),
                  ),
                );
              },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            hero,
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  statusChip,
                  const SizedBox(height: 8),
                  Text(
                    metadata.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AlphabetTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metadata.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AlphabetTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CardActions(entry: entry),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _LetterHero extends StatelessWidget {
  const _LetterHero({required this.entry});

  final AlphabetLetterEntry entry;

  @override
  Widget build(BuildContext context) {
    final metadata = entry.metadata;
    return Stack(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            gradient: LinearGradient(
              colors: [
                metadata.backgroundColor,
                metadata.backgroundColor.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -20,
                child: Icon(
                  Icons.auto_stories,
                  size: 140,
                  color: metadata.accentColor.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    metadata.letter,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: metadata.accentColor,
                    ),
                  ),
                ),
              ),
              if (entry.isCompleted)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: metadata.badgeColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final LessonPlayStatus status;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color textColor;
    String label;
    switch (status) {
      case LessonPlayStatus.completed:
        background = const Color(0xFFE8FFF4);
        textColor = const Color(0xFF16A34A);
        label = 'COMPLETED';
        break;
      case LessonPlayStatus.inProgress:
        background = const Color(0xFFFFF7E6);
        textColor = const Color(0xFFB45309);
        label = 'IN PROGRESS';
        break;
      case LessonPlayStatus.ready:
        background = const Color(0xFFE0F2FF);
        textColor = const Color(0xFF0369A1);
        label = 'READY';
        break;
      case LessonPlayStatus.locked:
        background = const Color(0xFFF1F1F1);
        textColor = const Color(0xFF9CA3AF);
        label = 'LOCKED';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _CardActions extends StatelessWidget {
  const _CardActions({required this.entry});

  final AlphabetLetterEntry entry;

  @override
  Widget build(BuildContext context) {
    final label = _ctaLabel(entry.status);
    final disabled = entry.isLocked;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: disabled
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(
                            name: AlphabetRoutes.lessonDetail),
                        builder: (_) => AlphabetLessonScreen(
                          letterId: entry.metadata.lessonId,
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: entry.isCompleted
                  ? AlphabetTheme.primary.withValues(alpha: 0.25)
                  : AlphabetTheme.primary,
              foregroundColor: AlphabetTheme.textMain,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (entry.isCompleted)
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings:
                      const RouteSettings(name: AlphabetRoutes.lessonDetail),
                  builder: (_) => AlphabetLessonScreen(
                    letterId: entry.metadata.lessonId,
                  ),
                ),
              );
            },
            style: AlphabetTheme.outlineButtonStyle(),
            child: const Text('Review'),
          ),
      ],
    );
  }

  String _ctaLabel(LessonPlayStatus status) {
    switch (status) {
      case LessonPlayStatus.completed:
        return 'Replay';
      case LessonPlayStatus.inProgress:
        return 'Continue';
      case LessonPlayStatus.ready:
        return 'Start';
      case LessonPlayStatus.locked:
        return 'Locked';
    }
  }
}

class _FloatingNav extends StatelessWidget {
  const _FloatingNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
        border: Border.all(color: AlphabetTheme.primary.withValues(alpha: 0.2)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavIcon(label: 'Letters', icon: Icons.auto_stories, active: true),
          _NavIcon(label: 'Numbers', icon: Icons.calculate),
          _NavIcon(label: 'Shapes', icon: Icons.palette_outlined),
          _NavIcon(label: 'Profile', icon: Icons.face),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.label,
    required this.icon,
    this.active = false,
  });

  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AlphabetTheme.primary : const Color(0xFFB7B0A0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active
                ? AlphabetTheme.primary.withValues(alpha: 0.25)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _UnauthorizedView extends StatelessWidget {
  const _UnauthorizedView({required this.onSignIn});

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
              'Sign in to continue your alphabet adventure.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AlphabetTheme.textMain,
          ),
        ),
      ),
    );
  }
}
