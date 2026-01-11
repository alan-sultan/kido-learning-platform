import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/progress_record.dart';
import '../services/app_services.dart';
import 'login_screen.dart';
import 'quiz_start_screen.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, this.lessonId});

  final String? lessonId;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  Widget build(BuildContext context) {
    final lessonId = widget.lessonId;
    if (lessonId == null || lessonId.isEmpty) {
      return _buildStaticLesson(context);
    }

    final user = AppServices.auth.currentUser;
    if (user == null) {
      return _buildAuthRequired(context);
    }

    return AnimatedBuilder(
      animation: AppServices.childSelection,
      builder: (context, _) {
        final profile = AppServices.childSelection.activeProfile;
        if (profile == null) {
          return _buildProfileMissing(context);
        }

        return StreamBuilder<Lesson?>(
          stream: AppServices.learningContent.watchLesson(lessonId),
          builder: (context, snapshot) {
            final waiting =
                snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData;
            final lesson = snapshot.data;

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.home, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  lesson?.title ?? 'Lesson',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        Icon(Icons.star, color: Colors.grey[300], size: 20),
                        Icon(Icons.star, color: Colors.grey[300], size: 20),
                      ],
                    ),
                  ),
                ],
              ),
              body: SafeArea(
                child: Builder(
                  builder: (_) {
                    if (snapshot.hasError) {
                      return _buildErrorState(
                        'Unable to load this lesson right now.',
                      );
                    }
                    if (waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (lesson == null) {
                      return _buildErrorState(
                        'This lesson is no longer available.',
                      );
                    }

                    return StreamBuilder<ProgressRecord?>(
                      stream: AppServices.progress.watchLessonProgress(
                        user.uid,
                        profile.id,
                        lesson.id,
                      ),
                      builder: (context, progressSnapshot) {
                        return _buildLessonBody(
                          context,
                          lesson,
                          progressSnapshot.data,
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLessonBody(
    BuildContext context,
    Lesson lesson,
    ProgressRecord? progress,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 300,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _illustrationBackground(lesson.illustration),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: const CustomPaint(
                size: Size(double.infinity, 300),
                painter: LionIllustrationPainter(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.categoryId.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lesson.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  lesson.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                if (lesson.content.isNotEmpty)
                  Text(
                    lesson.content,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                const SizedBox(height: 24),
                if (lesson.durationMinutes > 0)
                  Row(
                    children: [
                      const Icon(Icons.schedule,
                          size: 18, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                        '${lesson.durationMinutes} minute activity',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                const SizedBox(height: 32),
                _buildProgressOverview(progress),
                const SizedBox(height: 32),
                Builder(
                  builder: (_) {
                    final hasQuiz = lesson.quizId.isNotEmpty;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: hasQuiz
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          QuizStartScreen(lesson: lesson),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                hasQuiz ? Colors.amber[700] : Colors.grey[300],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hasQuiz ? Icons.quiz : Icons.hourglass_empty,
                                color:
                                    hasQuiz ? Colors.black : Colors.grey[600],
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                hasQuiz ? 'Start Quiz' : 'Quiz Coming Soon',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      hasQuiz ? Colors.black : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!hasQuiz) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'We are preparing interactive questions for this lesson. '
                              'Enjoy the lesson content above and check back soon!',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 30),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(ProgressRecord? progress) {
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
          'Take the quiz to unlock your personal stats and earn shiny stars!',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      );
    }

    final bestScoreLabel = progress.totalQuestions > 0
        ? '${progress.bestScore}/${progress.totalQuestions}'
        : '${progress.bestScore} pts';
    final accuracy = progress.totalQuestions > 0 && progress.bestScore > 0
        ? '${((progress.bestScore / progress.totalQuestions) * 100).round()}%'
        : null;
    final fastestTime = _formatDurationShort(progress.fastestDurationSeconds);
    final lastRunTime = _formatDurationShort(progress.lastDurationSeconds);
    final hintsLabel = _formatHintLabel(progress.lastHintsUsed);

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
            blurRadius: 12,
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
                'Lesson progress',
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildStatChip(
                icon: Icons.emoji_events_outlined,
                label: 'Best score',
                value: accuracy == null
                    ? bestScoreLabel
                    : '$bestScoreLabel · $accuracy',
              ),
              if (progress.fastestDurationSeconds > 0)
                _buildStatChip(
                  icon: Icons.flash_on,
                  label: 'Fastest time',
                  value: fastestTime,
                ),
              if (progress.lastDurationSeconds > 0)
                _buildStatChip(
                  icon: Icons.schedule,
                  label: 'Last run',
                  value: lastRunTime,
                ),
              _buildStatChip(
                icon: Icons.lightbulb_outline,
                label: 'Last hints',
                value: hintsLabel,
              ),
              _buildStatChip(
                icon: Icons.star_rate,
                label: 'Total stars',
                value: '${progress.starsEarned}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
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

  Widget _buildStaticLesson(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lesson',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: _buildLessonBody(context, _placeholderLesson, null),
      ),
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
                'Please sign in to continue.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  'Sign In',
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

  Widget _buildProfileMissing(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select a child profile to view progress.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'We use the active profile to save quiz attempts, stars, and best times.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.black54),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _illustrationBackground(LessonIllustration illustration) {
    switch (illustration) {
      case LessonIllustration.balloons:
        return Colors.pink[50]!;
      case LessonIllustration.blocks:
        return Colors.orange[50]!;
      case LessonIllustration.shapes:
        return Colors.indigo[50]!;
      case LessonIllustration.numbers:
        return Colors.blue[50]!;
      case LessonIllustration.lion:
        return Colors.green[50]!;
    }
  }
}

class LionIllustrationPainter extends CustomPainter {
  const LionIllustrationPainter();
  @override
  void paint(Canvas canvas, Size size) {
    // Background - jungle foliage
    final foliagePaint = Paint()..color = Colors.green[300]!;
    for (int i = 0; i < 10; i++) {
      final x = (i * size.width / 10) + size.width / 20;
      canvas.drawCircle(
        Offset(x, size.height * 0.8),
        30 + (i % 3) * 10,
        foliagePaint,
      );
    }

    // Lion body
    final center = Offset(size.width / 2, size.height * 0.6);

    // Mane (golden circle)
    final manePaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(center, size.width * 0.25, manePaint);

    // Head (orange circle)
    final headPaint = Paint()..color = const Color(0xFFFFA500);
    canvas.drawCircle(center, size.width * 0.2, headPaint);

    // Body (sitting position - oval)
    final bodyPaint = Paint()..color = const Color(0xFFFFA500);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.15),
        width: size.width * 0.35,
        height: size.height * 0.3,
      ),
      bodyPaint,
    );

    // Face features
    final facePaint = Paint()..color = Colors.black;
    // Eyes
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.08, center.dy - size.height * 0.05),
      size.width * 0.04,
      facePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.08, center.dy - size.height * 0.05),
      size.width * 0.04,
      facePaint,
    );

    // Nose
    canvas.drawCircle(
      Offset(center.dx, center.dy + size.height * 0.02),
      size.width * 0.03,
      facePaint,
    );

    // Mouth
    final mouthPath = Path();
    mouthPath.moveTo(center.dx, center.dy + size.height * 0.05);
    mouthPath.lineTo(
        center.dx - size.width * 0.05, center.dy + size.height * 0.1);
    mouthPath.moveTo(center.dx, center.dy + size.height * 0.05);
    mouthPath.lineTo(
        center.dx + size.width * 0.05, center.dy + size.height * 0.1);
    canvas.drawPath(mouthPath, facePaint);

    // Front paws
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.1, center.dy + size.height * 0.25),
      size.width * 0.06,
      bodyPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.1, center.dy + size.height * 0.25),
      size.width * 0.06,
      bodyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const Lesson _placeholderLesson = Lesson(
  id: 'demo-lesson',
  categoryId: 'Animal Kingdom',
  title: 'The Lion',
  description: 'Learn about animal sounds and habitats.',
  illustration: LessonIllustration.lion,
  defaultStatus: LessonStatus.ready,
  order: 0,
  content: 'The lion is the king of the jungle. He has a big, loud roar! 🦁',
  durationMinutes: 5,
  quizId: '',
);
