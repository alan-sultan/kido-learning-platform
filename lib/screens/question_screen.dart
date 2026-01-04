import 'package:flutter/material.dart';
import 'quiz_completion_screen.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int? selectedOption;
  int currentQuestion = 2;
  int totalQuestions = 5;
  String timeRemaining = "1:19";

  @override
  Widget build(BuildContext context) {
    final progress = currentQuestion / totalQuestions;
    final progressDots = List.generate(totalQuestions, (index) => index < currentQuestion);

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
          'Quiz Time!',
          style: TextStyle(
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
                Icon(Icons.timer, color: Colors.amber[700], size: 20),
                const SizedBox(width: 4),
                Text(
                  timeRemaining,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalQuestions, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: index < currentQuestion
                            ? Colors.amber[700]
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                // Question
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(text: 'Which animal is the '),
                      TextSpan(
                        text: 'fastest?',
                        style: TextStyle(
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Answer options grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    _buildOption(
                      label: 'Turtle',
                      icon: Icons.pets,
                      color: Colors.green,
                      index: 0,
                    ),
                    _buildOption(
                      label: 'Cheetah',
                      icon: Icons.pets,
                      color: Colors.orange,
                      index: 1,
                      isCorrect: true,
                    ),
                    _buildOption(
                      label: 'Snail',
                      icon: Icons.pets,
                      color: Colors.brown,
                      index: 2,
                    ),
                    _buildOption(
                      label: 'Sloth',
                      icon: Icons.pets,
                      color: Colors.grey,
                      index: 3,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Hint option
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber[700],
                  ),
                  label: Text(
                    'Need a hint?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.amber[700],
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

  Widget _buildOption({
    required String label,
    required IconData icon,
    required Color color,
    required int index,
    bool isCorrect = false,
  }) {
    final isSelected = selectedOption == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = index;
        });
        // Navigate to next question or completion after delay
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            if (currentQuestion >= totalQuestions) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizCompletionScreen(),
                ),
              );
            } else {
              // Would navigate to next question
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizCompletionScreen(),
                ),
              );
            }
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? (isCorrect ? Colors.green : Colors.red)
                : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 50, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? (isCorrect ? Colors.green : Colors.red)
                      : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected
                    ? (isCorrect ? Colors.green : Colors.red)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      isCorrect ? Icons.check : Icons.close,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

