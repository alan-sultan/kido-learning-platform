import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/quiz.dart';
import 'home_screen.dart';
import 'lesson_screen.dart';

class QuizCompletionScreen extends StatelessWidget {
  const QuizCompletionScreen({
    super.key,
    required this.lesson,
    required this.quiz,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.starsEarned,
    required this.timeSpentSeconds,
    required this.hintsUsed,
    required this.hintPenaltyApplied,
    required this.bestScore,
    required this.isNewBestScore,
    required this.fastestDurationSeconds,
    required this.isNewFastestTime,
  });

  final Lesson lesson;
  final Quiz quiz;
  final int correctAnswers;
  final int totalQuestions;
  final int starsEarned;
  final int timeSpentSeconds;
  final int hintsUsed;
  final bool hintPenaltyApplied;
  final int bestScore;
  final bool isNewBestScore;
  final int fastestDurationSeconds;
  final bool isNewFastestTime;

  @override
  Widget build(BuildContext context) {
    final accuracy =
        totalQuestions == 0 ? 0.0 : correctAnswers / totalQuestions.toDouble();
    final durationLabel = _formatDuration(timeSpentSeconds);
    final hintsLabel = hintsUsed == 1 ? '1 hint' : '$hintsUsed hints';
    final infoBanners = _buildInfoBanners();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          quiz.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Celebration illustration
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.teal[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Confetti
                      CustomPaint(
                        size: const Size(double.infinity, 300),
                        painter: ConfettiPainter(),
                      ),
                      // Bear character
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: CelebratingBearPainter(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildStarRow(),
                if (infoBanners.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      for (final banner in infoBanners) ...[
                        banner,
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                // Awesome text
                const Text(
                  'Awesome!',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                // Result message
                Text(
                  'You answered $correctAnswers out of $totalQuestions questions correctly.',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Points
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '+$starsEarned Stars',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Accuracy ${(accuracy * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildStatChip(
                      icon: Icons.schedule,
                      label: 'Time',
                      value: durationLabel,
                    ),
                    _buildStatChip(
                      icon: Icons.lightbulb_outline,
                      label: 'Hints',
                      value: hintsLabel,
                    ),
                    if (bestScore > 0)
                      _buildStatChip(
                        icon: isNewBestScore
                            ? Icons.emoji_events
                            : Icons.insights,
                        label: isNewBestScore
                            ? 'New High Score'
                            : 'Best Score',
                        value: '$bestScore / $totalQuestions',
                      ),
                    if (fastestDurationSeconds > 0)
                      _buildStatChip(
                        icon: isNewFastestTime
                            ? Icons.bolt
                            : Icons.flag_circle,
                        label:
                            isNewFastestTime ? 'Fastest Run' : 'Best Time',
                        value: _formatDuration(fastestDurationSeconds),
                      ),
                  ],
                ),
                const SizedBox(height: 50),
                // Return to Lesson button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LessonScreen(lessonId: lesson.id),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh,
                          color: Colors.black,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Return to Lesson',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Return to Home button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home,
                          color: Colors.black87,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Return to Home',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
        ),
      ),
    );
  }

  Widget _buildStarRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final filled = index < starsEarned;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.star,
            color: filled ? Colors.amber[700] : Colors.grey[300],
            size: filled ? 48 : 40,
          ),
        );
      }),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            '$label · $value',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0s';
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    if (minutes == 0) {
      return '${remaining}s';
    }
    if (remaining == 0) {
      return '${minutes}m';
    }
    return '${minutes}m ${remaining}s';
  }

  List<Widget> _buildInfoBanners() {
    final banners = <Widget>[];
    final hintBanner = _buildHintBanner();
    if (hintBanner != null) {
      banners.add(hintBanner);
    }
    if (isNewBestScore && bestScore > 0) {
      banners.add(
        _buildInfoBanner(
          icon: Icons.emoji_events_outlined,
          text:
              'New high score! You reached $bestScore out of $totalQuestions.',
          backgroundColor: Colors.purple[50]!,
          iconColor: Colors.purple[700]!,
        ),
      );
    }
    if (isNewFastestTime && fastestDurationSeconds > 0) {
      banners.add(
        _buildInfoBanner(
          icon: Icons.bolt,
          text:
              'Fastest time yet at ${_formatDuration(fastestDurationSeconds)}!',
          backgroundColor: Colors.blue[50]!,
          iconColor: Colors.blue[700]!,
        ),
      );
    }
    return banners;
  }

  Widget? _buildHintBanner() {
    if (hintPenaltyApplied && starsEarned > 0) {
      return _buildInfoBanner(
        icon: Icons.lightbulb_outline,
        text:
            'Hints used this round cost a star. Try again without hints to earn them all!',
        backgroundColor: Colors.orange[50]!,
        iconColor: Colors.orange[700]!,
      );
    }
    if (!hintPenaltyApplied && hintsUsed == 0 && starsEarned > 0) {
      return _buildInfoBanner(
        icon: Icons.emoji_events_outlined,
        text: 'No hints needed! Way to keep every star.',
        backgroundColor: Colors.green[50]!,
        iconColor: Colors.green[700]!,
      );
    }
    return null;
  }

  Widget _buildInfoBanner({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    for (int i = 0; i < 20; i++) {
      final x = (i * 30.0) % size.width;
      final y = (i * 25.0) % size.height;
      final color = colors[i % colors.length];
      final paint = Paint()..color = color;
      canvas.drawCircle(Offset(x, y), 8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CelebratingBearPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Body (brown circle) - jumping position (higher)
    final bodyPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.height * 0.1),
      size.width * 0.35,
      bodyPaint,
    );

    // Head
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.height * 0.3),
      size.width * 0.3,
      bodyPaint,
    );

    // Ears
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.18, center.dy - size.height * 0.4),
      size.width * 0.1,
      bodyPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.18, center.dy - size.height * 0.4),
      size.width * 0.1,
      bodyPaint,
    );

    // Arms (raised in celebration)
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.35, center.dy - size.height * 0.2),
      size.width * 0.12,
      bodyPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.35, center.dy - size.height * 0.2),
      size.width * 0.12,
      bodyPaint,
    );

    // Legs
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.15, center.dy + size.height * 0.1),
      size.width * 0.1,
      bodyPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.15, center.dy + size.height * 0.1),
      size.width * 0.1,
      bodyPaint,
    );

    // Face features
    final facePaint = Paint()..color = Colors.black;
    // Eyes
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.08, center.dy - size.height * 0.3),
      size.width * 0.03,
      facePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.08, center.dy - size.height * 0.3),
      size.width * 0.03,
      facePaint,
    );

    // Nose
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.height * 0.25),
      size.width * 0.03,
      facePaint,
    );

    // Big smile
    final smilePath = Path();
    smilePath.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - size.height * 0.2),
        width: size.width * 0.25,
        height: size.width * 0.2,
      ),
      0,
      math.pi,
    );
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
