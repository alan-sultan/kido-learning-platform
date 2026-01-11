import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF44F),
      body: SafeArea(
        child: Stack(
          children: [
            // Background geometric shapes
            Positioned.fill(
              child: CustomPaint(
                painter: GeometricShapesPainter(),
              ),
            ),
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLogoLetter('K', const Color(0xFFFF69B4)),
                      _buildLogoLetter('I', const Color(0xFF4CAF50)),
                      _buildLogoLetter('D', const Color(0xFFFF9800)),
                      _buildLogoLetter('O', const Color(0xFF2196F3)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Tagline
                const Text(
                  "Let's Play & Learn!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const Spacer(flex: 3),
                // Bear character
                Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _buildBearCharacter(),
                  ),
                ),
                const Spacer(flex: 3),
                // Loading indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      const Text(
                        "LOADING FUN...",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          minHeight: 8,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF69B4),
                          ),
                          value: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "v1.0.2",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoLetter(String letter, Color color) {
    return Text(
      letter,
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildBearCharacter() {
    return CustomPaint(
      size: const Size(150, 150),
      painter: BearPainter(),
    );
  }
}

class GeometricShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFF9C4)
      ..style = PaintingStyle.fill;

    // Draw stars
    for (int i = 0; i < 5; i++) {
      final x = (i * 80.0) % size.width;
      final y = (i * 100.0) % size.height;
      _drawStar(canvas, paint, Offset(x, y), 15);
    }

    // Draw hexagons
    for (int i = 0; i < 4; i++) {
      final x = (i * 120.0) % size.width;
      final y = (i * 150.0) % size.height;
      _drawHexagon(canvas, paint, Offset(x, y), 20);
    }

    // Draw triangles
    for (int i = 0; i < 6; i++) {
      final x = (i * 90.0) % size.width;
      final y = (i * 110.0) % size.height;
      _drawTriangle(canvas, paint, Offset(x, y), 18);
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHexagon(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 2 * math.pi / 6);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawTriangle(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BearPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Body (brown circle)
    final bodyPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawCircle(center, size.width * 0.4, bodyPaint);

    // Head (slightly smaller brown circle)
    final headPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.width * 0.15),
      size.width * 0.35,
      headPaint,
    );

    // Ears
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.2, center.dy - size.width * 0.3),
      size.width * 0.12,
      headPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.2, center.dy - size.width * 0.3),
      size.width * 0.12,
      headPaint,
    );

    // Rosy cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFFB6C1);
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.15, center.dy - size.width * 0.05),
      size.width * 0.08,
      cheekPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.15, center.dy - size.width * 0.05),
      size.width * 0.08,
      cheekPaint,
    );

    // Eyes
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.1, center.dy - size.width * 0.15),
      size.width * 0.04,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.1, center.dy - size.width * 0.15),
      size.width * 0.04,
      eyePaint,
    );

    // Nose
    final nosePaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.width * 0.05),
      size.width * 0.03,
      nosePaint,
    );

    // Mouth (smile)
    final mouthPath = Path();
    mouthPath.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy),
        width: size.width * 0.2,
        height: size.width * 0.15,
      ),
      0,
      math.pi,
    );
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(mouthPath, mouthPaint);

    // Arms (outstretched)
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.35, center.dy),
      size.width * 0.1,
      bodyPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.35, center.dy),
      size.width * 0.1,
      bodyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
