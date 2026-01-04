import 'package:flutter/material.dart';

class QuizActivityScreen extends StatefulWidget {
  const QuizActivityScreen({super.key});

  @override
  State<QuizActivityScreen> createState() => _QuizActivityScreenState();
}

class _QuizActivityScreenState extends State<QuizActivityScreen> {
  int currentQuestion = 3;
  int totalQuestions = 5;
  int? selectedOption;

  @override
  Widget build(BuildContext context) {
    final progress = currentQuestion / totalQuestions;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '120 pts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.amber[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Quit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Progress indicator
                    Text(
                      'QUESTIONS $currentQuestion OF $totalQuestions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Question card with illustration
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Barn illustration
                          CustomPaint(
                            size: const Size(double.infinity, 250),
                            painter: BarnIllustrationPainter(),
                          ),
                          // Speaker icon
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.amber[700],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.volume_up,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Question text
                    const Text(
                      "Which animal says 'Moo'?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap the correct picture!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    // Options
                    _buildOption(
                      icon: Icons.pets,
                      label: 'Cow',
                      index: 0,
                      isCorrect: true,
                    ),
                    const SizedBox(height: 16),
                    _buildOption(
                      icon: Icons.pets,
                      label: 'Pig',
                      index: 1,
                      isCorrect: false,
                    ),
                    const SizedBox(height: 16),
                    _buildOption(
                      icon: Icons.pets,
                      label: 'Duck',
                      index: 2,
                      isCorrect: false,
                    ),
                    const SizedBox(height: 100), // Space for owl character
                  ],
                ),
              ),
            ),
            // Owl character at bottom right
            Positioned(
              bottom: 20,
              right: 20,
              child: CustomPaint(
                size: const Size(100, 100),
                painter: QuizOwlCharacterPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required int index,
    required bool isCorrect,
  }) {
    final isSelected = selectedOption == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = index;
        });
        // Auto-advance after selection (simulated)
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            // Would navigate to next question or completion screen
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isCorrect ? Colors.green[100] : Colors.red[100])
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? (isCorrect ? Colors.green : Colors.red)
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.brown, size: 28),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

class BarnIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Sky
    final skyPaint = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.6),
      skyPaint,
    );

    // Ground/grass
    final grassPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4),
      grassPaint,
    );

    final center = Offset(size.width / 2, size.height * 0.5);

    // Barn (red)
    final barnPaint = Paint()..color = Colors.red[700]!;
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.4,
        height: size.height * 0.4,
      ),
      barnPaint,
    );

    // Barn roof (triangle)
    final roofPath = Path();
    roofPath.moveTo(center.dx - size.width * 0.2, center.dy - size.height * 0.2);
    roofPath.lineTo(center.dx, center.dy - size.height * 0.35);
    roofPath.lineTo(center.dx + size.width * 0.2, center.dy - size.height * 0.2);
    roofPath.close();
    final roofPaint = Paint()..color = Colors.brown[700]!;
    canvas.drawPath(roofPath, roofPaint);

    // Barn door
    final doorPaint = Paint()..color = Colors.brown[800]!;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.1),
        width: size.width * 0.15,
        height: size.height * 0.25,
      ),
      doorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QuizOwlCharacterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Body (brown oval)
    final bodyPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.6,
        height: size.height * 0.7,
      ),
      bodyPaint,
    );

    // Head
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.height * 0.15),
      size.width * 0.35,
      bodyPaint,
    );

    // Glasses
    final glassesPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - size.width * 0.15, center.dy - size.height * 0.2),
        width: size.width * 0.25,
        height: size.width * 0.2,
      ),
      glassesPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + size.width * 0.15, center.dy - size.height * 0.2),
        width: size.width * 0.25,
        height: size.width * 0.2,
      ),
      glassesPaint,
    );

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.15, center.dy - size.height * 0.2),
      size.width * 0.08,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.15, center.dy - size.height * 0.2),
      size.width * 0.08,
      eyePaint,
    );

    // Book (green, held in front)
    final bookPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + size.height * 0.1),
          width: size.width * 0.4,
          height: size.height * 0.3,
        ),
        const Radius.circular(5),
      ),
      bookPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

