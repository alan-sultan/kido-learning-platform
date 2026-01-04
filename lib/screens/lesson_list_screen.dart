import 'package:flutter/material.dart';
import 'quiz_start_screen.dart';
import 'lesson_screen.dart';

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({super.key});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  String selectedTab = 'All';

  final List<String> tabs = ['All', 'Math', 'Reading', 'Writing'];

  final List<LessonData> lessons = [
    LessonData(
      title: 'Counting to 30',
      category: 'MATH',
      description: 'Learn numbers with balloons!',
      imageType: LessonImageType.balloons,
      status: LessonStatus.ready,
    ),
    LessonData(
      title: 'Animal Sounds',
      category: 'READING',
      description: 'Listen & learn!',
      imageType: LessonImageType.lion,
      status: LessonStatus.ready,
    ),
    LessonData(
      title: 'ABC Adventures',
      category: 'LANGUAGE ARTS',
      description: 'Explore the alphabet forest!',
      imageType: LessonImageType.blocks,
      status: LessonStatus.start,
    ),
    LessonData(
      title: 'Colors & Shapes',
      category: 'ART',
      description: 'Discover colors & form!',
      imageType: LessonImageType.shapes,
      status: LessonStatus.locked,
    ),
    LessonData(
      title: 'Simple Addition',
      category: 'MATH',
      description: 'Learn to add!',
      imageType: LessonImageType.numbers,
      status: LessonStatus.locked,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredLessons = selectedTab == 'All'
        ? lessons
        : lessons.where((lesson) => lesson.category == selectedTab.toUpperCase() || 
            (selectedTab == 'Reading' && lesson.category == 'READING') ||
            (selectedTab == 'Math' && lesson.category == 'MATH') ||
            (selectedTab == 'Writing' && lesson.category == 'LANGUAGE ARTS')).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Let's Learn!",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: tabs.map((tab) {
                  final isSelected = selectedTab == tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = tab;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.amber[700] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tab,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Lesson list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: filteredLessons.length,
                itemBuilder: (context, index) {
                  final lesson = filteredLessons[index];
                  return _buildLessonCard(lesson);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(1),
    );
  }

  Widget _buildLessonCard(LessonData lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: _buildLessonImage(lesson.imageType),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                if (lesson.status == LessonStatus.locked)
                  Row(
                    children: [
                      Icon(Icons.lock, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        'Locked',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        if (lesson.title == 'ABC Adventures') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuizStartScreen(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LessonScreen(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        lesson.status == LessonStatus.start ? 'Start' : 'Ready',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonImage(LessonImageType type) {
    switch (type) {
      case LessonImageType.balloons:
        return CustomPaint(
          size: const Size(100, 100),
          painter: BalloonsPainter(),
        );
      case LessonImageType.lion:
        return CustomPaint(
          size: const Size(100, 100),
          painter: LionFacePainter(),
        );
      case LessonImageType.blocks:
        return CustomPaint(
          size: const Size(100, 100),
          painter: BlocksPainter(),
        );
      case LessonImageType.shapes:
        return CustomPaint(
          size: const Size(100, 100),
          painter: ShapesPainter(),
        );
      case LessonImageType.numbers:
        return CustomPaint(
          size: const Size(100, 100),
          painter: NumbersPainter(),
        );
    }
  }

  Widget _buildBottomNavigationBar(int selectedIndex) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0, selectedIndex),
          _buildNavItem(Icons.person, 1, selectedIndex),
          _buildNavItem(Icons.star, 2, selectedIndex),
          _buildNavItem(Icons.settings, 3, selectedIndex),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, int selectedIndex) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber[700] : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

enum LessonStatus { ready, start, locked }
enum LessonImageType { balloons, lion, blocks, shapes, numbers }

class LessonData {
  final String title;
  final String category;
  final String description;
  final LessonImageType imageType;
  final LessonStatus status;

  LessonData({
    required this.title,
    required this.category,
    required this.description,
    required this.imageType,
    required this.status,
  });
}

class BalloonsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple];
    for (int i = 0; i < 5; i++) {
      final x = (i * 20.0) % size.width;
      final y = size.height * 0.3 + (i * 15.0) % (size.height * 0.4);
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 20,
          height: 30,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LionFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final headPaint = Paint()..color = const Color(0xFFFFA500);
    canvas.drawCircle(center, size.width * 0.4, headPaint);
    final manePaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(center, size.width * 0.45, manePaint);
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.15, center.dy - size.height * 0.1),
      size.width * 0.05,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.15, center.dy - size.height * 0.1),
      size.width * 0.05,
      eyePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BlocksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final blockPaint = Paint()..color = Colors.brown[300]!;
    final textPaint = Paint()..color = Colors.white;
    final textStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    
    // Block A
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - size.width * 0.3, center.dy),
          width: size.width * 0.25,
          height: size.height * 0.3,
        ),
        const Radius.circular(5),
      ),
      blockPaint,
    );
    
    // Block B
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: size.width * 0.25,
          height: size.height * 0.3,
        ),
        const Radius.circular(5),
      ),
      blockPaint,
    );
    
    // Block C
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + size.width * 0.3, center.dy),
          width: size.width * 0.25,
          height: size.height * 0.3,
        ),
        const Radius.circular(5),
      ),
      blockPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..color = Colors.grey[400]!;
    
    // Circle
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.2, center.dy),
      size.width * 0.15,
      paint,
    );
    
    // Square
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx + size.width * 0.2, center.dy),
        width: size.width * 0.3,
        height: size.width * 0.3,
      ),
      paint,
    );
    
    // Triangle
    final trianglePath = Path();
    trianglePath.moveTo(center.dx, center.dy - size.height * 0.2);
    trianglePath.lineTo(center.dx - size.width * 0.15, center.dy + size.height * 0.1);
    trianglePath.lineTo(center.dx + size.width * 0.15, center.dy + size.height * 0.1);
    trianglePath.close();
    canvas.drawPath(trianglePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NumbersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final numbers = ['1', '2', '5', '8', '6'];
    final textPaint = Paint()..color = Colors.grey[600]!;
    
    for (int i = 0; i < numbers.length; i++) {
      final x = (i * 18.0) % size.width;
      final y = (i * 20.0) % size.height;
      // Numbers would be drawn here with text rendering
      // For simplicity, using circles as placeholders
      canvas.drawCircle(Offset(x, y), 8, textPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

