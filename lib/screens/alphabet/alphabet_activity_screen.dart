import 'dart:async';
import 'dart:math';

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
                child: _ActivityStepCard(
                  data: step,
                  onAction: () => _handleStepAction(step),
                ),
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

  Future<void> _handleStepAction(_ActivityStepData step) async {
    late final Widget interaction;
    switch (step.kind) {
      case _ActivityKind.trace:
        interaction = _TracePracticeSheet(
          letter: widget.metadata.letter,
          accentColor: widget.metadata.accentColor,
        );
        break;
      case _ActivityKind.sound:
        interaction = _SoundMatchSheet(
          letter: widget.metadata.letter,
          focusWord: widget.metadata.word,
          accentColor: widget.metadata.accentColor,
        );
        break;
      case _ActivityKind.act:
        interaction = _ActItOutSheet(
          letter: widget.metadata.letter,
          word: widget.metadata.word,
          accentColor: widget.metadata.accentColor,
        );
        break;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AlphabetSheetWrapper(child: interaction),
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
  const _ActivityStepCard({required this.data, required this.onAction});

  final _ActivityStepData data;
  final VoidCallback onAction;

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
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            style: AlphabetTheme.ctaButtonStyle().copyWith(
                minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48))),
            child: Text(data.actionLabel),
          ),
        ],
      ),
    );
  }
}

enum _ActivityKind { trace, sound, act }

class _ActivityStepData {
  const _ActivityStepData({
    required this.title,
    required this.tagline,
    required this.description,
    required this.icon,
    required this.color,
    required this.actionLabel,
    required this.kind,
  });

  final String title;
  final String tagline;
  final String description;
  final IconData icon;
  final Color color;
  final String actionLabel;
  final _ActivityKind kind;

  static List<_ActivityStepData> build(AlphabetLetterMetadata metadata) {
    return [
      _ActivityStepData(
        title: 'Trace ${metadata.letter}',
        tagline: 'Use your finger in the air',
        description:
            'Draw ${metadata.letter} slowly and say the sound each time you finish a line.',
        icon: Icons.gesture_rounded,
        color: const Color(0xFF4ADE80),
        actionLabel: 'Open tracing pad',
        kind: _ActivityKind.trace,
      ),
      _ActivityStepData(
        title: 'Find the sound',
        tagline: 'Hunt for matching objects',
        description:
            'Look around the room for anything that starts with ${metadata.letter}. Say the word loudly.',
        icon: Icons.search_rounded,
        color: const Color(0xFFFBBF24),
        actionLabel: 'Play sound hunt',
        kind: _ActivityKind.sound,
      ),
      _ActivityStepData(
        title: 'Act it out',
        tagline: 'Move like ${metadata.word}',
        description:
            'Pretend to be ${metadata.word.toLowerCase()} for a full 10 seconds. Make the sound as you move.',
        icon: Icons.headset_mic_rounded,
        color: const Color(0xFF38BDF8),
        actionLabel: 'Start action timer',
        kind: _ActivityKind.act,
      ),
    ];
  }
}

class _AlphabetSheetWrapper extends StatelessWidget {
  const _AlphabetSheetWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 24,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}

class _TracePracticeSheet extends StatefulWidget {
  const _TracePracticeSheet({
    required this.letter,
    required this.accentColor,
  });

  final String letter;
  final Color accentColor;

  @override
  State<_TracePracticeSheet> createState() => _TracePracticeSheetState();
}

class _TracePracticeSheetState extends State<_TracePracticeSheet> {
  final List<List<Offset>> _strokes = <List<Offset>>[];
  double _strokeDistance = 0;

  bool get _isTraceComplete => _strokeDistance >= 800;

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _strokes.add(<Offset>[details.localPosition]);
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_strokes.isEmpty) {
      _strokes.add(<Offset>[details.localPosition]);
    }
    final stroke = _strokes.last;
    final newPoint = details.localPosition;
    final previous = stroke.isEmpty ? newPoint : stroke.last;
    setState(() {
      _strokeDistance += (newPoint - previous).distance;
      stroke.add(newPoint);
    });
  }

  void _clearPad() {
    setState(() {
      _strokes.clear();
      _strokeDistance = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Trace ${widget.letter}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AlphabetTheme.textMain,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Fill the canvas until the checkmark appears.',
          style: TextStyle(
            color: AlphabetTheme.textMuted,
          ),
        ),
        const SizedBox(height: 20),
        AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE4E2D0)),
              color: const Color(0xFFFDFBF6),
            ),
            child: GestureDetector(
              onPanStart: _handlePanStart,
              onPanUpdate: _handlePanUpdate,
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      widget.letter,
                      style: TextStyle(
                        fontSize: 220,
                        fontWeight: FontWeight.w800,
                        color: widget.accentColor.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  CustomPaint(
                    painter: _TracePainter(
                      strokes: _strokes,
                      accentColor: widget.accentColor,
                    ),
                    size: Size.infinite,
                  ),
                  if (_isTraceComplete)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: widget.accentColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Great tracing!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton(onPressed: _clearPad, child: const Text('Clear pad')),
            const Spacer(),
            Text(
              '${_strokeDistance.toStringAsFixed(0)} px traced',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AlphabetTheme.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TracePainter extends CustomPainter {
  const _TracePainter({required this.strokes, required this.accentColor});

  final List<List<Offset>> strokes;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TracePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.accentColor != accentColor;
  }
}

class _SoundMatchSheet extends StatefulWidget {
  const _SoundMatchSheet({
    required this.letter,
    required this.focusWord,
    required this.accentColor,
  });

  final String letter;
  final String focusWord;
  final Color accentColor;

  @override
  State<_SoundMatchSheet> createState() => _SoundMatchSheetState();
}

class _SoundMatchSheetState extends State<_SoundMatchSheet> {
  late final List<_SoundWord> _options;

  int get _matchCount => _options.where((o) => o.isMatch).length;

  bool get _allFound =>
      _options
          .where((o) => o.isMatch && o.status == _SoundCardStatus.correct)
          .length ==
      _matchCount;

  @override
  void initState() {
    super.initState();
    _options = _buildOptions();
  }

  List<_SoundWord> _buildOptions() {
    final otherWords = AlphabetLibrary.letters
        .where((entry) => entry.letter != widget.letter)
        .map((entry) => entry.word)
        .toList();
    otherWords.shuffle(Random(widget.letter.codeUnitAt(0)));
    final decoys = otherWords.take(3).toList();
    final combined = <_SoundWord>[
      _SoundWord(word: widget.focusWord, isMatch: true),
      ...decoys.map((w) => _SoundWord(word: w, isMatch: false)),
    ];
    combined.shuffle(Random(widget.focusWord.hashCode));
    return combined;
  }

  void _handleTap(_SoundWord option) {
    if (option.status == _SoundCardStatus.correct && option.isMatch) {
      return;
    }

    setState(() {
      option.status = option.isMatch
          ? _SoundCardStatus.correct
          : _SoundCardStatus.incorrect;
    });

    if (!option.isMatch) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          if (option.status == _SoundCardStatus.incorrect) {
            option.status = _SoundCardStatus.neutral;
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sound hunt for ${widget.letter}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AlphabetTheme.textMain,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tap the words that begin with the ${widget.letter} sound.',
          style: const TextStyle(color: AlphabetTheme.textMuted),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemCount: _options.length,
          itemBuilder: (context, index) {
            final option = _options[index];
            final status = option.status;
            Color background;
            Color borderColor;
            switch (status) {
              case _SoundCardStatus.neutral:
                background = const Color(0xFFF7F4ED);
                borderColor = const Color(0xFFE3DED1);
                break;
              case _SoundCardStatus.correct:
                background = widget.accentColor.withValues(alpha: 0.15);
                borderColor = widget.accentColor;
                break;
              case _SoundCardStatus.incorrect:
                background = const Color(0xFFFFF1F2);
                borderColor = const Color(0xFFFB7185);
                break;
            }
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _handleTap(option),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: background,
                  border: Border.all(color: borderColor, width: 2),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      option.word,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AlphabetTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      option.word
                              .toLowerCase()
                              .startsWith(widget.letter.toLowerCase())
                          ? 'Matches?'
                          : 'Try it',
                      style: const TextStyle(
                        color: AlphabetTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        AnimatedOpacity(
          opacity: _allFound ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: _allFound
              ? Row(
                  children: [
                    Icon(Icons.graphic_eq_rounded, color: widget.accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Awesome listening! You found every ${widget.letter} sound.',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AlphabetTheme.textMain,
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _SoundWord {
  _SoundWord({required this.word, required this.isMatch});

  final String word;
  final bool isMatch;
  _SoundCardStatus status = _SoundCardStatus.neutral;
}

enum _SoundCardStatus { neutral, correct, incorrect }

class _ActItOutSheet extends StatefulWidget {
  const _ActItOutSheet({
    required this.letter,
    required this.word,
    required this.accentColor,
  });

  final String letter;
  final String word;
  final Color accentColor;

  @override
  State<_ActItOutSheet> createState() => _ActItOutSheetState();
}

class _ActItOutSheetState extends State<_ActItOutSheet> {
  static const int _totalSeconds = 10;

  Timer? _timer;
  int _secondsLeft = _totalSeconds;
  bool _isRunning = false;
  bool _completed = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _totalSeconds;
      _isRunning = true;
      _completed = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
          _isRunning = false;
          _completed = true;
        });
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  double get _progress => 1 - (_secondsLeft / _totalSeconds);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Act like a ${widget.word}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AlphabetTheme.textMain,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Move, stretch, or dance while making the ${widget.letter} sound.',
          style: const TextStyle(color: AlphabetTheme.textMuted),
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: _isRunning ? _progress : (_completed ? 1 : 0),
            minHeight: 12,
            backgroundColor: const Color(0xFFE6E0C5),
            color: widget.accentColor,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            _completed
                ? 'Great acting!'
                : _isRunning
                    ? '${_secondsLeft}s left'
                    : 'Ready to move?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AlphabetTheme.textMain,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isRunning ? null : _startTimer,
          style: AlphabetTheme.ctaButtonStyle(),
          child: Text(_completed ? 'Do it again' : 'Start 10 second timer'),
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
