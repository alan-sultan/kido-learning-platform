import 'package:flutter/material.dart';

import '../../alphabet/alphabet_library.dart';
import '../../models/child_profile.dart';
import '../../models/progress_record.dart';
import '../../services/app_services.dart';
import '../login_screen.dart';
import 'alphabet_activity_screen.dart';
import 'alphabet_routes.dart';
import 'alphabet_theme.dart';

class AlphabetLessonScreen extends StatefulWidget {
  const AlphabetLessonScreen({super.key, required this.letterId});

  final String letterId;

  @override
  State<AlphabetLessonScreen> createState() => _AlphabetLessonScreenState();
}

class _AlphabetLessonScreenState extends State<AlphabetLessonScreen> {
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
      return _UnauthorizedView(onSignIn: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    }

    return Scaffold(
      backgroundColor: AlphabetTheme.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AlphabetTheme.maxContentWidth),
            child: FutureBuilder<ChildProfile?>(
              future: _ensureProfileFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const _ErrorNotice('Could not load your explorer.');
                }
                return AnimatedBuilder(
                  animation: AppServices.childSelection,
                  builder: (context, _) {
                    final profile = AppServices.childSelection.activeProfile;
                    if (profile == null) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return const _ErrorNotice(
                        'Create an explorer to start the lesson.',
                      );
                    }
                    return _LessonDetailStream(
                      userId: user.uid,
                      profile: profile,
                      letterId: widget.letterId,
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

class _LessonDetailStream extends StatelessWidget {
  const _LessonDetailStream({
    required this.userId,
    required this.profile,
    required this.letterId,
  });

  final String userId;
  final ChildProfile profile;
  final String letterId;

  @override
  Widget build(BuildContext context) {
    final metadata = AlphabetLibrary.byLessonId(letterId);
    if (metadata == null) {
      return const _ErrorNotice('That letter is taking a break.');
    }

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

        return _LessonDetailContent(
          metadata: metadata,
          record: snapshot.data,
        );
      },
    );
  }
}

class _LessonDetailContent extends StatelessWidget {
  const _LessonDetailContent({required this.metadata, this.record});

  final AlphabetLetterMetadata metadata;
  final ProgressRecord? record;

  @override
  Widget build(BuildContext context) {
    final status = record?.status ?? LessonPlayStatus.ready;
    final steps = _LessonStepData.build(metadata);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LessonHeader(metadata: metadata, status: status),
          const SizedBox(height: 20),
          _LessonHeroCard(metadata: metadata, record: record),
          const SizedBox(height: 20),
          _LessonStoryCard(metadata: metadata),
          const SizedBox(height: 20),
          ...steps
              .map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LessonStepTile(data: step),
                  ))
              .toList(),
          const SizedBox(height: 20),
          _LessonActions(metadata: metadata),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Back to lesson list',
              style: TextStyle(
                color: AlphabetTheme.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({required this.metadata, required this.status});

  final AlphabetLetterMetadata metadata;
  final LessonPlayStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Letter ${metadata.letter}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AlphabetTheme.textMain,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                metadata.heroCaption,
                style: const TextStyle(
                  fontSize: 12,
                  color: AlphabetTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _StatusChip(status: status),
      ],
    );
  }
}

class _LessonHeroCard extends StatelessWidget {
  const _LessonHeroCard({required this.metadata, this.record});

  final AlphabetLetterMetadata metadata;
  final ProgressRecord? record;

  @override
  Widget build(BuildContext context) {
    final attempts = record?.attempts ?? 0;
    final stars = record?.starsEarned ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            metadata.backgroundColor,
            metadata.backgroundColor.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                metadata.letter,
                style: TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                  color: metadata.accentColor,
                  height: 0.9,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  metadata.word,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AlphabetTheme.textMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            metadata.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: AlphabetTheme.textMain,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroStatChip(
                label: 'Stars',
                value: stars.toString(),
                color: metadata.badgeColor,
              ),
              const SizedBox(width: 12),
              _HeroStatChip(
                label: 'Tries',
                value: attempts.toString(),
                color: metadata.accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonStoryCard extends StatelessWidget {
  const _LessonStoryCard({required this.metadata});

  final AlphabetLetterMetadata metadata;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E4CE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Story spark',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AlphabetTheme.textMain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            metadata.storyPrompt,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: AlphabetTheme.textMain,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonActions extends StatelessWidget {
  const _LessonActions({required this.metadata});

  final AlphabetLetterMetadata metadata;

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
                settings: const RouteSettings(name: AlphabetRoutes.activity),
                builder: (_) => AlphabetActivityScreen(
                  letterId: metadata.lessonId,
                ),
              ),
            );
          },
          icon: const Icon(Icons.flash_on_rounded, size: 28),
          label: Text('Start ${metadata.letter} activity'),
          style: AlphabetTheme.ctaButtonStyle(),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.grid_view_rounded),
          label: const Text('Choose another letter'),
          style: AlphabetTheme.outlineButtonStyle(),
        ),
      ],
    );
  }
}

class _LessonStepTile extends StatelessWidget {
  const _LessonStepTile({required this.data});

  final _LessonStepData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAE5D2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AlphabetTheme.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AlphabetTheme.textMuted,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _LessonStepData {
  const _LessonStepData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;

  static List<_LessonStepData> build(AlphabetLetterMetadata metadata) {
    return [
      _LessonStepData(
        title: 'Meet ${metadata.word}',
        description: metadata.subtitle,
        icon: Icons.auto_awesome,
        color: metadata.accentColor,
      ),
      _LessonStepData(
        title: 'Story time',
        description: metadata.storyPrompt,
        icon: Icons.auto_stories,
        color: const Color(0xFF60A5FA),
      ),
      _LessonStepData(
        title: 'Sound practice',
        description:
            'Say ${metadata.letter} softly each time you spot something that starts with ${metadata.letter}.',
        icon: Icons.graphic_eq,
        color: const Color(0xFF34D399),
      ),
      _LessonStepData(
        title: 'Activity preview',
        description: metadata.activityPrompt,
        icon: Icons.extension,
        color: const Color(0xFFF97316),
      ),
    ];
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.darken(),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color.darken(),
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
    final colors = _statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        colors.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colors.foreground,
        ),
      ),
    );
  }
}

_StatusColors _statusColors(LessonPlayStatus status) {
  switch (status) {
    case LessonPlayStatus.completed:
      return const _StatusColors(
        label: 'Completed',
        background: Color(0xFFD1FAE5),
        foreground: Color(0xFF047857),
      );
    case LessonPlayStatus.inProgress:
      return const _StatusColors(
        label: 'In progress',
        background: Color(0xFFFDE68A),
        foreground: Color(0xFF92400E),
      );
    case LessonPlayStatus.ready:
      return const _StatusColors(
        label: 'Ready',
        background: Color(0xFFE0E7FF),
        foreground: Color(0xFF4338CA),
      );
    case LessonPlayStatus.locked:
      return const _StatusColors(
        label: 'Locked',
        background: Color(0xFFFEE2E2),
        foreground: Color(0xFFB91C1C),
      );
  }
}

class _StatusColors {
  const _StatusColors({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sign in to view this lesson',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AlphabetTheme.textMain,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSignIn,
              style: AlphabetTheme.ctaButtonStyle(),
              child: const Text('Sign in'),
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
                color: AlphabetTheme.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on Color {
  Color darken([double amount = 0.2]) {
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
