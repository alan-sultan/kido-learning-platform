import 'package:flutter/material.dart';

class CategoryListingScreen extends StatelessWidget {
  const CategoryListingScreen({super.key});

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
          'The Alphabet',
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Current topic card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT TOPIC',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Let's learn letters!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Category list
                _buildCategoryCard(
                  icon: Icons.apple,
                  iconColor: Colors.red,
                  title: 'Letter A',
                  subtitle: 'Apple',
                  status: CategoryStatus.completed,
                ),
                const SizedBox(height: 16),
                _buildCategoryCard(
                  icon: Icons.sports_basketball,
                  iconColor: Colors.orange,
                  title: 'Letter B',
                  subtitle: 'Ball',
                  status: CategoryStatus.inProgress,
                  progress: 0.45,
                ),
                const SizedBox(height: 16),
                _buildCategoryCard(
                  icon: Icons.pets,
                  iconColor: Colors.grey,
                  title: 'Letter C',
                  subtitle: 'Cat',
                  status: CategoryStatus.locked,
                ),
                const SizedBox(height: 16),
                _buildCategoryCard(
                  icon: Icons.pets,
                  iconColor: Colors.grey,
                  title: 'Letter D',
                  subtitle: 'Dog',
                  status: CategoryStatus.locked,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(1),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required CategoryStatus status,
    double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (status == CategoryStatus.inProgress && progress != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Status indicator
          if (status == CategoryStatus.completed)
            Row(
              children: [
                ...List.generate(3, (index) => Icon(
                      Icons.star,
                      size: 20,
                      color: Colors.amber[700],
                    )),
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                ),
              ],
            )
          else if (status == CategoryStatus.inProgress)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber[700],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                'PLAY NOW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            )
          else
            Icon(
              Icons.lock,
              color: Colors.grey[400],
              size: 24,
            ),
        ],
      ),
    );
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
          _buildNavItem(Icons.play_circle_outline, 1, selectedIndex),
          _buildNavItem(Icons.person, 2, selectedIndex),
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

enum CategoryStatus {
  completed,
  inProgress,
  locked,
}

