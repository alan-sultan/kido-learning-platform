import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/progress_record.dart';
import '../models/quiz.dart';
import '../services/app_services.dart';
import 'question_screen.dart';

class QuizStartScreen extends StatefulWidget {
  const QuizStartScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<QuizStartScreen> createState() => _QuizStartScreenState();
}

class _QuizStartScreenState extends State<QuizStartScreen> {
  late final Future<_QuizBundle?> _quizFuture = _loadQuizBundle();

  Future<_QuizBundle?> _loadQuizBundle() async {
    if (widget.lesson.quizId.isEmpty) return null;
    try {
      final quiz =
          await AppServices.learningContent.fetchQuizById(widget.lesson.quizId);
      if (quiz == null) return null;
      final questions =
          await AppServices.learningContent.fetchQuizQuestions(quiz.id);
      if (questions.isEmpty) return null;
      return _QuizBundle(quiz: quiz, questions: questions);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppServices.auth.currentUser;
    if (user == null) {
      return _buildAuthRequired(context);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: AppServices.childSelection,
          builder: (context, _) {
            final profile = AppServices.childSelection.activeProfile;
            if (profile == null) {
              return _buildProfileMissing();
            }
            final user = AppServices.auth.currentUser!;

            return StreamBuilder<ProgressRecord?>(
              stream: AppServices.progress.watchLessonProgress(
                user.uid,
                profile.id,
                widget.lesson.id,
              ),
              builder: (context, progressSnapshot) {
                final progress = progressSnapshot.data;
                return FutureBuilder<_QuizBundle?>(
                  future: _quizFuture,
                  builder: (context, snapshot) {
                    final waiting =
                        snapshot.connectionState == ConnectionState.waiting &&
                            !snapshot.hasData;
                    final quizBundle = snapshot.data;
                    final hasQuiz = quizBundle != null;
                    final questionLabel = quizBundle == null
                        ? 'Quiz coming soon'
                        : '${quizBundle.questions.length} Questions';
                    final durationLabel = quizBundle == null
                        ? '—'
                        : _formatDuration(quizBundle.quiz.durationSeconds);
                    VoidCallback? startQuizCallback;
                    if (!waiting && quizBundle != null) {
                      final _QuizBundle readyBundle = quizBundle;
                      startQuizCallback = () => _startQuiz(readyBundle);
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildIllustrationHeader(profile.name),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 30),
                                Text(
                                  widget.lesson.categoryId.isEmpty
                                      ? 'ADVENTURE'
                                      : widget.lesson.categoryId.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF757575),
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.lesson.title,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.lesson.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildInfoItem(
                                  icon: Icons.star,
                                  label: 'Level ${widget.lesson.order + 1}',
                                ),
                                const SizedBox(height: 16),
                                _buildInfoItem(
                                  icon: Icons.help_outline,
                                  label: questionLabel,
                                ),
                                const SizedBox(height: 16),
                                _buildInfoItem(
                                  icon: Icons.access_time,
                                  label: durationLabel,
                                ),
                                const SizedBox(height: 30),
                                _buildQuizStatusMessage(waiting, hasQuiz),
                                if (hasQuiz) ...[
                                  const SizedBox(height: 20),
                                  _buildPerformanceCard(progress, quizBundle),
                                  const SizedBox(height: 20),
                                  _buildScoringExplainer(),
                                ],
                                const SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: startQuizCallback,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber[700],
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      disabledBackgroundColor: Colors.grey[300],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.play_arrow,
                                          color: hasQuiz
                                              ? Colors.black
                                              : Colors.grey,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          hasQuiz
                                              ? 'START QUIZ'
                                              : 'QUIZ UNAVAILABLE',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: hasQuiz
                                                ? Colors.black
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuizStatusMessage(bool waiting, bool hasQuiz) {
    if (waiting) {
      return const Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Loading your interactive quiz...'
              ' this only takes a moment.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
    }

    if (!hasQuiz) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'We are still adding questions for this lesson.'
          ' You can explore the content now and return later!',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.deepOrange,
          ),
        ),
      );
    }

    return Text(
      'Answer questions to earn stars and boost your streak!',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildIllustrationHeader(String childName) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.amber[100]!,
            Colors.lightBlue[100]!,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 40,
            child: Text(
              'Ready, $childName?'.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.black54,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              color: Colors.amber[200],
            ),
          ),
          CustomPaint(
            size: const Size(200, 200),
            painter: BlockCharacterPainter(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber[700], size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(
    ProgressRecord? progress,
    _QuizBundle? bundle,
  ) {
    if (bundle == null) {
      return const SizedBox.shrink();
    }

    if (progress == null || progress.attempts == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Text(
          'Complete the quiz to start tracking your personal best score '
          'and fastest time.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
      );
    }

    final totalQuestions = bundle.questions.length;
    final bestScore = totalQuestions == 0
        ? progress.bestScore
        : progress.bestScore.clamp(0, totalQuestions);
    final bestScoreLabel =
        totalQuestions == 0 ? '$bestScore' : '$bestScore / $totalQuestions';
    final fastestDuration =
        _formatDurationShort(progress.fastestDurationSeconds);
    final lastDuration = _formatDurationShort(progress.lastDurationSeconds);
    final lastHintsLabel = _formatHintLabel(progress.lastHintsUsed);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.teal, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Your progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${progress.attempts} attempt${progress.attempts == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildStatPill(
                icon: Icons.emoji_events_outlined,
                label: 'Best score',
                value: bestScoreLabel,
              ),
              if (progress.fastestDurationSeconds > 0)
                _buildStatPill(
                  icon: Icons.flash_on,
                  label: 'Fastest time',
                  value: fastestDuration,
                ),
              if (progress.lastDurationSeconds > 0)
                _buildStatPill(
                  icon: Icons.schedule,
                  label: 'Last run',
                  value: lastDuration,
                ),
              _buildStatPill(
                icon: Icons.lightbulb_outline,
                label: 'Last hints',
                value: lastHintsLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            '$label · $value',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDurationShort(int seconds) {
    if (seconds <= 0) return '—';
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    if (remaining == 0) return '${minutes}m';
    return '${minutes}m ${remaining}s';
  }

  String _formatHintLabel(int hints) {
    if (hints <= 0) return 'No hints';
    if (hints == 1) return '1 hint';
    return '$hints hints';
  }

  Widget _buildScoringExplainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlue[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.lightBlue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How to keep every star',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildExplainerRow(
            icon: Icons.star_rate,
            text:
                '3 stars for 90%+, 2 stars for 60%+, 1 star for any correct answer.',
          ),
          const SizedBox(height: 8),
          _buildExplainerRow(
            icon: Icons.lightbulb_outline,
            text:
                'Need a hint? Go for it! Just remember that using one costs a star this round.',
          ),
          const SizedBox(height: 8),
          _buildExplainerRow(
            icon: Icons.bolt,
            text:
                'Replay without hints to reclaim every star—and try to beat your time!',
          ),
        ],
      ),
    );
  }

  Widget _buildExplainerRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.amber[700], size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthRequired(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please sign in to explore this quiz.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMissing() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose a child profile first',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'We use the profile to save quiz progress and stars.',
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startQuiz(_QuizBundle bundle) async {
    final user = AppServices.auth.currentUser;
    final profile = AppServices.childSelection.activeProfile;
    if (user != null && profile != null) {
      try {
        await AppServices.progress.markQuizInProgress(
          userId: user.uid,
          childId: profile.id,
          lessonId: widget.lesson.id,
        );
      } catch (_) {
        // Ignore failures so the learner can still proceed.
      }
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionScreen(
          lesson: widget.lesson,
          quiz: bundle.quiz,
          questions: bundle.questions,
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return 'Self-paced';
    final minutes = (seconds / 60).ceil();
    return '$minutes min activity';
  }
}

class BlockCharacterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final blockColor = Colors.lightBlue[300]!;

    // Top block
    final topBlockPaint = Paint()..color = blockColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - size.height * 0.15),
          width: size.width * 0.4,
          height: size.height * 0.3,
        ),
        const Radius.circular(10),
      ),
      topBlockPaint,
    );

    // Bottom block
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + size.height * 0.15),
          width: size.width * 0.5,
          height: size.height * 0.3,
        ),
        const Radius.circular(10),
      ),
      topBlockPaint,
    );

    // Legs
    final legPaint = Paint()..color = blockColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          center.dx - size.width * 0.15,
          center.dy + size.height * 0.3,
          size.width * 0.1,
          size.height * 0.15,
        ),
        const Radius.circular(5),
      ),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          center.dx + size.width * 0.05,
          center.dy + size.height * 0.3,
          size.width * 0.1,
          size.height * 0.15,
        ),
        const Radius.circular(5),
      ),
      legPaint,
    );

    // Face on top block
    final facePaint = Paint()..color = Colors.black;
    // Eyes
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.08, center.dy - size.height * 0.2),
      size.width * 0.03,
      facePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.08, center.dy - size.height * 0.2),
      size.width * 0.03,
      facePaint,
    );

    // Smile
    final smilePath = Path();
    smilePath.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - size.height * 0.1),
        width: size.width * 0.2,
        height: size.width * 0.15,
      ),
      0,
      math.pi,
    );
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuizBundle {
  const _QuizBundle({required this.quiz, required this.questions});

  final Quiz quiz;
  final List<QuizQuestion> questions;
}
