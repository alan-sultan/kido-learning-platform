import 'package:flutter/material.dart';

import '../../alphabet/alphabet_library.dart';
import '../../models/child_profile.dart';
import '../../models/progress_record.dart';
import '../../services/app_services.dart';
import '../login_screen.dart';
import 'alphabet_lessons_screen.dart';
import 'alphabet_routes.dart';
import 'alphabet_theme.dart';

class AlphabetCompletionScreen extends StatefulWidget {
  const AlphabetCompletionScreen({super.key, required this.letterId});

  final String letterId;

  @override
  State<AlphabetCompletionScreen> createState() =>
      _AlphabetCompletionScreenState();
}

class _AlphabetCompletionScreenState extends State<AlphabetCompletionScreen> {
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
                        'Add an explorer to show their wins.',
                      );
                    }
                    return _CompletionContent(
                      letterId: widget.letterId,
                      profile: profile,
                      userId: user.uid,
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

class _CompletionContent extends StatelessWidget {
  const _CompletionContent({
    required this.letterId,
    required this.profile,
    required this.userId,
  });

  final String letterId;
  final ChildProfile profile;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final metadata = AlphabetLibrary.byLessonId(letterId);
    if (metadata == null) {
      return const _ErrorNotice('Letter party missing.');
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
          return const _ErrorNotice('Unable to load celebration details.');
        }

        final record = snapshot.data;
        final attempts = record?.attempts ?? 1;
        final stars = record?.starsEarned ?? 1;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CompletionHeader(letter: metadata.letter),
              const SizedBox(height: 24),
              _ConfettiHero(
                  metadata: metadata, attempts: attempts, stars: stars),
              const SizedBox(height: 24),
              _CompletionStats(attempts: attempts, stars: stars),
              const SizedBox(height: 24),
              _CompletionActions(metadata: metadata),
            ],
          ),
        );
      },
    );
  }
}

class _CompletionHeader extends StatelessWidget {
  const _CompletionHeader({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              const Text(
                'Great job!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AlphabetTheme.textMain,
                ),
              ),
              Text(
                'You finished letter $letter',
                style: const TextStyle(
                  fontSize: 12,
                  color: AlphabetTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _ConfettiHero extends StatelessWidget {
  const _ConfettiHero({
    required this.metadata,
    required this.attempts,
    required this.stars,
  });

  final AlphabetLetterMetadata metadata;
  final int attempts;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            metadata.backgroundColor,
            metadata.backgroundColor.withValues(alpha: 0.7),
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
          const SizedBox(height: 12),
          Text(
            metadata.word,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AlphabetTheme.textMain,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Alphabet superstar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AlphabetTheme.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _ConfettiChip(
                label: '$stars star${stars == 1 ? '' : 's'} earned',
                icon: Icons.star,
                color: metadata.badgeColor,
              ),
              _ConfettiChip(
                label: '$attempts attempt${attempts == 1 ? '' : 's'}',
                icon: Icons.repeat,
                color: metadata.accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletionStats extends StatelessWidget {
  const _CompletionStats({required this.attempts, required this.stars});

  final int attempts;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8E4CE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Journey recap',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AlphabetTheme.textMain,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department,
                  label: 'Attempts',
                  value: '$attempts',
                  color: const Color(0xFFFB7185),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.auto_awesome,
                  label: 'Stars',
                  value: '$stars',
                  color: const Color(0xFFFCD34D),
                ),
              ),
            ],
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AlphabetTheme.textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AlphabetTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiChip extends StatelessWidget {
  const _ConfettiChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color.darken(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionActions extends StatelessWidget {
  const _CompletionActions({required this.metadata});

  final AlphabetLetterMetadata metadata;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: AlphabetRoutes.lessonList),
                builder: (_) => const AlphabetLessonListScreen(),
              ),
              (route) => route.isFirst,
            );
          },
          style: AlphabetTheme.ctaButtonStyle(),
          icon: const Icon(Icons.grid_view_rounded),
          label: const Text('Pick another letter'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          style: AlphabetTheme.outlineButtonStyle(),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text('Repeat ${metadata.letter} activity'),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sign in to view this celebration',
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
