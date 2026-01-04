import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // App title with crown
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'KI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      const Text(
                        'D',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Positioned(
                        top: -12,
                        child: Icon(
                          Icons.star,
                          size: 20,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'O',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Main content card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE082),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    // Feature badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'FUN!',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 3D character placeholder
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Building blocks background
                          Positioned(
                            bottom: 20,
                            left: 20,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 50,
                            left: 50,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 50,
                            right: 50,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          // Child character
                          CustomPaint(
                            size: const Size(120, 150),
                            painter: ChildCharacterPainter(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Call to action text
                    const Text(
                      'Ready to Play & Learn?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Join the fun world of KIDO and discover new things every day!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    // Primary button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Let's Play!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Parents Login link
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.lock,
                  size: 16,
                  color: Colors.black87,
                ),
                label: const Text(
                  'Parents Login',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ChildCharacterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Head (circle)
    final headPaint = Paint()..color = const Color(0xFFD4A574);
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.height * 0.25),
      size.width * 0.25,
      headPaint,
    );

    // Hair
    final hairPaint = Paint()..color = const Color(0xFF8B4513);
    final hairPath = Path();
    hairPath.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - size.height * 0.25),
        width: size.width * 0.5,
        height: size.width * 0.4,
      ),
      math.pi,
      math.pi,
    );
    canvas.drawPath(hairPath, hairPaint);

    // Body (light blue shirt)
    final shirtPaint = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + size.height * 0.1),
          width: size.width * 0.6,
          height: size.height * 0.3,
        ),
        const Radius.circular(10),
      ),
      shirtPaint,
    );

    // Overalls (dark blue)
    final overallsPaint = Paint()..color = const Color(0xFF1E3A8A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + size.height * 0.25),
          width: size.width * 0.65,
          height: size.height * 0.4,
        ),
        const Radius.circular(10),
      ),
      overallsPaint,
    );

    // Overalls straps
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - size.width * 0.3,
        center.dy - size.height * 0.1,
        size.width * 0.15,
        size.height * 0.35,
      ),
      overallsPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx + size.width * 0.15,
        center.dy - size.height * 0.1,
        size.width * 0.15,
        size.height * 0.35,
      ),
      overallsPaint,
    );

    // Face features
    final facePaint = Paint()..color = Colors.black;
    // Eyes
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.1, center.dy - size.height * 0.3),
      size.width * 0.03,
      facePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.1, center.dy - size.height * 0.3),
      size.width * 0.03,
      facePaint,
    );

    // Smile
    final smilePath = Path();
    smilePath.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - size.height * 0.2),
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

    // Arms
    final armPaint = Paint()..color = const Color(0xFFD4A574);
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.35, center.dy + size.height * 0.1),
      size.width * 0.08,
      armPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.35, center.dy + size.height * 0.1),
      size.width * 0.08,
      armPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

