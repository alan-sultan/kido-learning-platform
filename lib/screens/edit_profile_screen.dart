import 'dart:math' as math;
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'Timmy');
  int _selectedCharacterIndex = 0;

  final List<CharacterData> _characters = [
    CharacterData('Bear', Colors.brown),
    CharacterData('Bunny', Colors.white),
    CharacterData('Fox', Colors.red),
    CharacterData('Alien', Colors.lightBlue),
    CharacterData('Monster', Colors.green),
    CharacterData('Add', Colors.grey),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Profile picture editor
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: _characters[_selectedCharacterIndex].color,
                            shape: BoxShape.circle,
                          ),
                          child: _selectedCharacterIndex == 0
                              ? CustomPaint(
                                  size: const Size(120, 120),
                                  painter: BearAvatarPainter(),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to change photo',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Name input
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "What is your name?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      suffixIcon: Icon(
                        Icons.check_circle,
                        color: Colors.amber[700],
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Character selection
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Pick your character!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Character grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: _characters.length,
                  itemBuilder: (context, index) {
                    final character = _characters[index];
                    final isSelected = index == _selectedCharacterIndex;
                    final isAddButton = index == _characters.length - 1;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCharacterIndex = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isAddButton ? Colors.grey[200] : character.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.amber[700]! : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isAddButton
                            ? Icon(
                                Icons.add,
                                size: 40,
                                color: Colors.grey[600],
                              )
                            : index == 0
                                ? CustomPaint(
                                    size: const Size(80, 80),
                                    painter: BearAvatarPainter(),
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
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
        ),
      ),
    );
  }
}

class CharacterData {
  final String name;
  final Color color;

  CharacterData(this.name, this.color);
}

class BearAvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Body (brown circle)
    final bodyPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawCircle(center, size.width * 0.4, bodyPaint);

    // Head (slightly smaller brown circle)
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.width * 0.15),
      size.width * 0.35,
      bodyPaint,
    );

    // Ears
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.2, center.dy - size.width * 0.3),
      size.width * 0.12,
      bodyPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.2, center.dy - size.width * 0.3),
      size.width * 0.12,
      bodyPaint,
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
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.width * 0.05),
      size.width * 0.03,
      eyePaint,
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

