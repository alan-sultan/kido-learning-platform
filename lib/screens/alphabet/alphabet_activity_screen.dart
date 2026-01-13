import 'package:flutter/material.dart';

import '../../alphabet/alphabet_library.dart';
import '../../models/child_profile.dart';
import '../../models/progress_record.dart';
import '../../services/app_services.dart';
import '../login_screen.dart';
import 'alphabet_completion_screen.dart';
import 'alphabet_routes.dart';
import 'alphabet_theme.dart';

class AlphabetActivityScreen extends StatefulWidget {
  const AlphabetActivityScreen({super.key, required this.letterId});

  final String letterId;

  @override
  State<AlphabetActivityScreen> createState() => _AlphabetActivityScreenState();
}

class _AlphabetActivityScreenState extends State<AlphabetActivityScreen> {
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
                        'Add an explorer to keep learning.',
                      );
                    }
                    return _ActivityStream(
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

class _ActivityStream extends StatelessWidget {
  const _ActivityStream({
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
      return const _ErrorNotice('Letter activity is unavailable.');
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
          return const _ErrorNotice('Unable to load activity progress.');
        }

        return _ActivityContent(
          metadata: metadata,
          profile: profile,
          userId: userId,
          progress: snapshot.data,
        );
      },
    );
  }
}

class _ActivityContent extends StatefulWidget {
  const _ActivityContent({
    required this.metadata,
    required this.profile,
    required this.userId,
    required this.progress,
  });

  final AlphabetLetterMetadata metadata;
  final ChildProfile profile;
  final String userId;
  final ProgressRecord? progress;

  @override
  State<_ActivityContent> createState() => _ActivityContentState();
}

class _ActivityContentState extends State<_ActivityContent> {
  late final PageController _controller;
  late int _currentPage;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _currentPage = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeActivity() async {
    final record = ProgressRecord(
      id: widget.metadata.lessonId,
      lessonId: widget.metadata.lessonId,
      status: LessonPlayStatus.completed,
      starsEarned: (widget.progress?.starsEarned ?? 0) + 1,
      bestScore: widget.progress?.bestScore ?? 0,
      totalQuestions: widget.progress?.totalQuestions ?? 0,
      attempts: (widget.progress?.attempts ?? 0) + 1,
      lastPlayedAt: widget.progress?.lastPlayedAt,
      completedAt: widget.progress?.completedAt,
      lastDurationSeconds: widget.progress?.lastDurationSeconds ?? 0,
      lastHintsUsed: widget.progress?.lastHintsUsed ?? 0,
      fastestDurationSeconds: widget.progress?.fastestDurationSeconds ?? 0,
    );

    await AppServices.progress.upsertProgress(
      widget.userId,
      widget.profile.id,
      record,
    );

    if (!mounted) return;
    setState(() {
      _isCompleted = true;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: AlphabetRoutes.completion),
        builder: (_) =>
            AlphabetCompletionScreen(letterId: widget.metadata.lessonId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _ActivityStepData.build(widget.metadata);

    return Column(
      children: [
        _ActivityHeader(
          metadata: widget.metadata,
          page: _currentPage + 1,
          total: steps.length,
          onBack: () => Navigator.pop(context),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: steps.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final step = steps[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ActivityStepCard(data: step),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _isCompleted ? null : _completeActivity,
                style: AlphabetTheme.ctaButtonStyle(),
                child: Text(
                  _currentPage == steps.length - 1
                      ? 'Finish ${widget.metadata.letter}'
                      : 'Mark step done',
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to lesson'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader({
    required this.metadata,
    required this.page,
    required this.total,
    required this.onBack,
  });

  final AlphabetLetterMetadata metadata;
  final int page;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final progress = page / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: onBack,
              ),
              const Spacer(),
              Text(
                '${metadata.letter} Activity',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AlphabetTheme.textMain,
                ),
              ),
              const Spacer(),
              Text(
                '$page/$total',
                style: const TextStyle(
                  fontSize: 14,
                  color: AlphabetTheme.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              color: metadata.accentColor,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityStepCard extends StatelessWidget {
  const _ActivityStepCard({required this.data});

  final _ActivityStepData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8E4CE)),
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
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(data.icon, color: data.color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AlphabetTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.tagline,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AlphabetTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AlphabetTheme.textMain,
            ),
          )
        ],
      ),
    );
  }
}

class _ActivityStepData {
  const _ActivityStepData({
    required this.title,
    required this.tagline,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String tagline;
  final String description;
  final IconData icon;
  final Color color;

  static List<_ActivityStepData> build(AlphabetLetterMetadata metadata) {
    return [
      _ActivityStepData(
        title: 'Trace ${metadata.letter}',
        tagline: 'Use your finger in the air',
        description:
            'Draw ${metadata.letter} slowly and say the sound each time you finish a line.',
        icon: Icons.gesture_rounded,
        color: const Color(0xFF4ADE80),
      ),
      _ActivityStepData(
        title: 'Find the sound',
        tagline: 'Hunt for matching objects',
        description:
            'Look around the room for anything that starts with ${metadata.letter}. Say the word loudly.',
        icon: Icons.search_rounded,
        color: const Color(0xFFFBBF24),
      ),
      _ActivityStepData(
        title: 'Act it out',
        tagline: 'Move like ${metadata.word}',
        description:
            'Pretend to be ${metadata.word.toLowerCase()} for a full 10 seconds. Make the sound as you move.',
        icon: Icons.headset_mic_rounded,
        color: const Color(0xFF38BDF8),
      ),
    ];
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
              'Sign in to play this activity',
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
