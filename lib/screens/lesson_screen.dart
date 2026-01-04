import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'quiz_activity_screen.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Lion illustration
              Container(
                height: 300,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomPaint(
                    size: const Size(double.infinity, 300),
                    painter: LionIllustrationPainter(),
                  ),
                ),
              ),
              // Lesson details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ANIMAL KINGDOM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The Lion',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "The lion is the king of the jungle. He has a big, loud roar! 🦁",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Play Sound button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuizActivityScreen(),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_filled,
                              color: Colors.black,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Play Sound',
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
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LionIllustrationPainter extends CustomPainter {
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
    mouthPath.lineTo(center.dx - size.width * 0.05, center.dy + size.height * 0.1);
    mouthPath.moveTo(center.dx, center.dy + size.height * 0.05);
    mouthPath.lineTo(center.dx + size.width * 0.05, center.dy + size.height * 0.1);
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

