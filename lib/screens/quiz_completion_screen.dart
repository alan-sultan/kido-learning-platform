import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'lesson_screen.dart';

class QuizCompletionScreen extends StatelessWidget {
  const QuizCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Result',
          style: TextStyle(
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
                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber[700], size: 40),
                    Icon(Icons.star, color: Colors.amber[700], size: 50),
                    Icon(Icons.star, color: Colors.amber[700], size: 40),
                  ],
                ),
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
                const Text(
                  'You answered 5 out of 5 questions correctly!',
                  style: TextStyle(
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
                    const Text(
                      '+50 Points',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
                          builder: (context) => const LessonScreen(),
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
                          Icons.refresh,
                          color: Colors.black,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home,
                          color: Colors.black87,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
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

    final random = colors.length;
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

