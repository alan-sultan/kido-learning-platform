import 'package:flutter/material.dart';

import '../models/child_profile.dart';
import '../models/progress_record.dart';
import '../models/lesson.dart';
import '../services/achievement_service.dart';
import '../services/app_services.dart';
import 'category_listing_screen.dart';
import 'login_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final Future<ChildProfile?> _ensureProfileFuture;

  @override
  void initState() {
    super.initState();
    final user = AppServices.auth.currentUser;
    if (user == null) {
      _ensureProfileFuture = Future.value(null);
    } else {
      _ensureProfileFuture = _ensureAndBindProfile(user.uid);
    }
  }

  Future<ChildProfile?> _ensureAndBindProfile(String userId) async {
    final profile = await AppServices.ensureDefaultChildProfile();
    if (!AppServices.childSelection.hasActiveProfile && profile != null) {
      await AppServices.childSelection.initialize(userId);
    }
    return profile;
  }

  @override
  Widget build(BuildContext context) {
    final user = AppServices.auth.currentUser;
    if (user == null) {
      return _buildAuthRequired(context);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 200,
        leading: Row(
          children: [
            const SizedBox(width: 8),
            Icon(Icons.person, color: Colors.blue[700], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedBuilder(
                animation: AppServices.childSelection,
                builder: (context, _) {
                  final profile = AppServices.childSelection.activeProfile;
                  final name = profile?.name ?? 'Explorer';
                  return Text(
                    'PLAYER! $name',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<ChildProfile?>(
          future: _ensureProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildProgressErrorState(
                'We could not prepare your explorer right now. Please try again.',
              );
            }

            return AnimatedBuilder(
              animation: AppServices.childSelection,
              builder: (context, _) {
                final profile = AppServices.childSelection.activeProfile;
                if (profile == null) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildProfileMissingState();
                }

                return StreamBuilder<List<ProgressRecord>>(
                  stream: AppServices.progress.watchProgress(
                    user.uid,
                    profile.id,
                  ),
                  builder: (context, progressSnapshot) {
                    if (progressSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        !progressSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (progressSnapshot.hasError) {
                      return _buildProgressErrorState(
                        'We could not load progress for ${profile.name}.',
                      );
                    }
                    final records = progressSnapshot.data ?? const [];
                    return _buildProgressBody(context, profile, records);
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(2),
    );
  }

  Widget _buildProgressBody(
    BuildContext context,
    ChildProfile profile,
    List<ProgressRecord> progressRecords,
  ) {
    const lessonsToNextLevel = 5;
    final lessonsProgress = profile.totalLessons % lessonsToNextLevel;
    final goalProgress =
        lessonsToNextLevel == 0 ? 0.0 : lessonsProgress / lessonsToNextLevel;
    final lessonsRemaining =
        (lessonsToNextLevel - lessonsProgress).clamp(0, lessonsToNextLevel);
    final lessonsRemainingInt = lessonsRemaining.toInt();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "You're learning so fast, ${profile.name}!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.star,
                    iconColor: Colors.amber[700]!,
                    value: profile.stars.toString(),
                    label: 'STARS EARNED',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orange[700]!,
                    value: profile.streak.toString(),
                    label: 'DAY STREAK',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'CURRENT GOAL',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Level ${profile.level + 1} Master',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: goalProgress.clamp(0, 1).toDouble(),
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '✨ Just $lessonsRemainingInt more lesson${lessonsRemainingInt == 1 ? '' : 's'} to level up!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CategoryListingScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Continue Adventure',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Adventure Path',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoryListingScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'View Map',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAdventureSection(progressRecords),
            const SizedBox(height: 40),
            const Text(
              'My Stickers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildStickers(AchievementService.deriveBadges(profile)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAdventureSection(List<ProgressRecord> progressRecords) {
    if (progressRecords.isEmpty) {
      return _buildAdventureItem(
        title: 'Start your first lesson',
        icon: Icons.lock,
        iconColor: Colors.grey,
        isLocked: true,
      );
    }

    final latestRecords = progressRecords.take(3).toList();
    return FutureBuilder<Map<String, Lesson?>>(
      future: _fetchLessons(latestRecords),
      builder: (context, snapshot) {
        final lessonMap = snapshot.data ?? const {};
        return Column(
          children: latestRecords.map((record) {
            final lesson = lessonMap[record.lessonId];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAdventureItem(
                title: lesson?.title ?? 'Lesson ${record.lessonId}',
                icon: _iconForStatus(record.status),
                iconColor: _iconColorForStatus(record.status),
                isLocked: record.status == LessonPlayStatus.locked,
                isActive: record.status == LessonPlayStatus.inProgress,
                badge: record.status == LessonPlayStatus.inProgress
                    ? 'PLAYING NOW'
                    : null,
                level: record.status == LessonPlayStatus.completed
                    ? 'Completed'
                    : null,
                lesson: lesson?.description,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<Map<String, Lesson?>> _fetchLessons(
      List<ProgressRecord> records) async {
    final ids = records.map((r) => r.lessonId).toSet().toList();
    final results = await Future.wait(
      ids.map((id) async =>
          MapEntry(id, await AppServices.learningContent.fetchLesson(id))),
    );
    return {for (final entry in results) entry.key: entry.value};
  }

  IconData _iconForStatus(LessonPlayStatus status) {
    switch (status) {
      case LessonPlayStatus.completed:
        return Icons.check_circle;
      case LessonPlayStatus.inProgress:
        return Icons.rocket_launch;
      case LessonPlayStatus.ready:
        return Icons.play_arrow;
      case LessonPlayStatus.locked:
        return Icons.lock;
    }
  }

  Color _iconColorForStatus(LessonPlayStatus status) {
    switch (status) {
      case LessonPlayStatus.completed:
        return Colors.green;
      case LessonPlayStatus.inProgress:
        return Colors.amber[700]!;
      case LessonPlayStatus.ready:
        return Colors.blue;
      case LessonPlayStatus.locked:
        return Colors.grey;
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickers(List<String> achievements) {
    final items = achievements.isEmpty
        ? ['WISE OWL', 'FAST HOP', 'STEADY']
        : achievements.take(3).map((b) => b.toUpperCase()).toList();

    return Row(
      children: List.generate(items.length, (index) {
        final colorSwatchValue = 400 + index * 100;
        final color = achievements.isEmpty
            ? (index == 0
                ? Colors.amber[700]!
                : index == 1
                    ? Colors.green
                    : Colors.blue)
            : Colors.amber[colorSwatchValue] ?? Colors.amber[400]!;
        return Padding(
          padding: EdgeInsets.only(right: index == items.length - 1 ? 0 : 16),
          child: _buildSticker(items[index], color),
        );
      }),
    );
  }

  Widget _buildProfileMissingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.child_care, size: 56, color: Colors.black54),
            SizedBox(height: 16),
            Text(
              'No explorer selected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Add or choose a child profile to see their progress.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildAuthRequired(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please sign in to see progress.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdventureItem({
    required String title,
    required IconData icon,
    required Color iconColor,
    bool isLocked = false,
    bool isActive = false,
    String? badge,
    String? level,
    String? lesson,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? Colors.amber[50] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isActive ? Colors.amber[700]! : Colors.grey[200]!,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _withOpacity(iconColor, 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isLocked ? Colors.grey[400] : Colors.black,
                  ),
                ),
                if (level != null || lesson != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    level ?? lesson ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber[700],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSticker(String label, Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
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
            color: Colors.black.withAlpha(26),
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
          _buildNavItem(Icons.emoji_events, 2, selectedIndex),
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

Color _withOpacity(Color color, double opacity) {
  final alpha = (opacity * 255).round().clamp(0, 255).toInt();
  return color.withAlpha(alpha);
}
