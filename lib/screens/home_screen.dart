import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/child_profile.dart';
import '../services/app_services.dart';
import 'category_listing_screen.dart';
import 'child_profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  static const List<Color> _rainbowGradientColors = <Color>[
    Colors.purple,
    Colors.blue,
    Colors.cyan,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red,
  ];

  static const Color _numbersIconColor = Color(0xFF1976D2);

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bear icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.brown[300],
                      shape: BoxShape.circle,
                    ),
                    child: const CustomPaint(
                      size: Size(40, 40),
                      painter: SmallBearIconPainter(),
                    ),
                  ),
                  // KIDO title
                  Text(
                    'KIDO',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  // Sun icon
                  Icon(
                    Icons.wb_sunny,
                    color: Colors.amber[700],
                    size: 28,
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Heading
                      const Text(
                        "Let's Play!",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Pick a game to start learning",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 30),
                      AnimatedBuilder(
                        animation: AppServices.childSelection,
                        builder: (context, _) {
                          final profile =
                              AppServices.childSelection.activeProfile;
                          if (profile == null) {
                            return _buildNoProfileCard(context);
                          }
                          return _buildActiveProfileCard(context, profile);
                        },
                      ),
                      const SizedBox(height: 24),
                      // Category cards grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                        children: [
                          _buildCategoryCard(
                            context,
                            title: 'ABC',
                            subtitle: 'Alphabet',
                            icon: Icons.abc,
                            backgroundColor: Colors.lightBlue[100]!,
                            iconColor: Colors.blue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CategoryListingScreen(),
                                ),
                              );
                            },
                          ),
                          _buildCategoryCard(
                            context,
                            title: '123',
                            subtitle: 'Numbers',
                            icon: Icons.numbers,
                            backgroundColor: Colors.lightBlue[100]!,
                            iconColor: Colors.blue,
                            onTap: () => _openLearningCatalog(context),
                          ),
                          _buildCategoryCard(
                            context,
                            title: 'Colors',
                            subtitle: 'Creative',
                            icon: Icons.palette,
                            backgroundColor: Colors.blue[900]!,
                            iconColor: Colors.white,
                            gradient: true,
                            onTap: () => _openLearningCatalog(context),
                          ),
                          _buildCategoryCard(
                            context,
                            title: 'Animals',
                            subtitle: 'Nature',
                            icon: Icons.pets,
                            backgroundColor: Colors.green[400]!,
                            iconColor: Colors.white,
                            showLion: true,
                            onTap: () => _openLearningCatalog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© 2024 Kido App',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.grey[600]),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLearningCatalog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CategoryListingScreen(),
      ),
    );
  }

  Widget _buildActiveProfileCard(
    BuildContext context,
    ChildProfile profile,
  ) {
    final accent = _avatarColor(profile.avatarKey);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _withOpacity(accent, 0.18),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 3),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: CustomPaint(
                painter: SmallBearIconPainter(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level ${profile.level}  •  ${profile.stars} stars',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to switch explorers or review progress.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChildProfileScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Manage',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProfileCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.child_care, size: 48, color: Colors.black54),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create an explorer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add your child profile to unlock progress tracking.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChildProfileScreen(),
                ),
              );
            },
            child: const Text('Add Explorer'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    bool gradient = false,
    bool showLion = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          gradient: gradient
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _rainbowGradientColors,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showLion)
                const CustomPaint(
                  size: Size(80, 80),
                  painter: LionIconPainter(),
                )
              else if (title == 'ABC')
                _buildABCIcon()
              else if (title == '123')
                _buildNumbersIcon()
              else
                Icon(icon, size: 60, color: iconColor),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: _withOpacity(iconColor, 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildABCIcon() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'A',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        Text(
          'B',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          'C',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildNumbersIcon() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '1',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: _numbersIconColor,
          ),
        ),
        Text(
          '2',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: _numbersIconColor,
          ),
        ),
        Text(
          '3',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: _numbersIconColor,
          ),
        ),
      ],
    );
  }

  Color _withOpacity(Color color, double opacity) {
    final alpha = (opacity * 255).round().clamp(0, 255).toInt();
    return color.withAlpha(alpha);
  }

  Color _avatarColor(String key) {
    switch (key) {
      case 'bunny':
        return Colors.pink[300]!;
      case 'fox':
        return Colors.deepOrange;
      case 'alien':
        return Colors.lightBlue;
      case 'monster':
        return Colors.purple;
      default:
        return Colors.amber;
    }
  }
}

class SmallBearIconPainter extends CustomPainter {
  const SmallBearIconPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Head
    final headPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawCircle(center, size.width * 0.4, headPaint);

    // Ears
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.25, center.dy - size.width * 0.25),
      size.width * 0.15,
      headPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.25, center.dy - size.width * 0.25),
      size.width * 0.15,
      headPaint,
    );

    // Eyes
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.12, center.dy - size.width * 0.05),
      size.width * 0.05,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.12, center.dy - size.width * 0.05),
      size.width * 0.05,
      eyePaint,
    );

    // Nose
    canvas.drawCircle(
      Offset(center.dx, center.dy + size.width * 0.05),
      size.width * 0.04,
      eyePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LionIconPainter extends CustomPainter {
  const LionIconPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Head (circle)
    final headPaint = Paint()..color = const Color(0xFFFFA500);
    canvas.drawCircle(center, size.width * 0.4, headPaint);

    // Mane (larger circle behind)
    final manePaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(center, size.width * 0.5, manePaint);

    // Face features
    final facePaint = Paint()..color = Colors.black;
    // Eyes
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.12, center.dy - size.width * 0.1),
      size.width * 0.06,
      facePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.12, center.dy - size.width * 0.1),
      size.width * 0.06,
      facePaint,
    );

    // Nose
    canvas.drawCircle(
      Offset(center.dx, center.dy + size.width * 0.05),
      size.width * 0.05,
      facePaint,
    );

    // Mouth
    final mouthPath = Path();
    mouthPath.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.width * 0.15),
        width: size.width * 0.3,
        height: size.width * 0.2,
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
