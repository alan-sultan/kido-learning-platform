import 'package:flutter/material.dart';

import '../models/child_profile.dart';
import '../models/learning_category.dart';
import '../models/lesson.dart';
import '../models/progress_record.dart';
import '../services/app_services.dart';
import 'lesson_list_screen.dart';
import 'login_screen.dart';

class CategoryListingScreen extends StatefulWidget {
  const CategoryListingScreen({super.key});

  @override
  State<CategoryListingScreen> createState() => _CategoryListingScreenState();
}

class _CategoryListingScreenState extends State<CategoryListingScreen> {
  late final Future<ChildProfile?> _ensureProfileFuture;

  @override
  void initState() {
    super.initState();
    final user = AppServices.auth.currentUser;
    if (user == null) {
      _ensureProfileFuture = Future.value(null);
    } else {
      _ensureProfileFuture = _ensureProfileAndSelection(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppServices.auth.currentUser;
    if (user == null) {
      return _buildAuthRequired(context);
    }

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
        child: FutureBuilder<ChildProfile?>(
          future: _ensureProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState(
                'We could not prepare your explorer. Please try again.',
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
                  return _buildProfileMissing();
                }
                return _buildCategoryStreams(user.uid, profile);
              },
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(1),
    );
  }

  Future<ChildProfile?> _ensureProfileAndSelection(String userId) async {
    final profile = await AppServices.ensureDefaultChildProfile();
    if (!AppServices.childSelection.hasActiveProfile && profile != null) {
      await AppServices.childSelection.initialize(userId);
    }
    return profile;
  }

  Widget _buildCategoryStreams(String userId, ChildProfile profile) {
    return StreamBuilder<List<LearningCategory>>(
      stream: AppServices.learningContent.watchCategories(),
      builder: (context, categorySnapshot) {
        if (categorySnapshot.connectionState == ConnectionState.waiting &&
            !categorySnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categorySnapshot.hasError) {
          return _buildErrorState('Unable to load categories right now.');
        }

        final categories = categorySnapshot.data ?? const [];
        if (categories.isEmpty) {
          return _buildEmptyState();
        }

        return StreamBuilder<List<Lesson>>(
          stream: AppServices.learningContent.watchLessons(),
          builder: (context, lessonSnapshot) {
            if (lessonSnapshot.connectionState == ConnectionState.waiting &&
                !lessonSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (lessonSnapshot.hasError) {
              return _buildErrorState('Unable to load lessons.');
            }

            final lessons = lessonSnapshot.data ?? const [];
            final lessonsByCategory = <String, List<Lesson>>{};
            for (final lesson in lessons) {
              lessonsByCategory
                  .putIfAbsent(lesson.categoryId, () => <Lesson>[])
                  .add(lesson);
            }

            return StreamBuilder<List<ProgressRecord>>(
              stream: AppServices.progress.watchProgress(userId, profile.id),
              builder: (context, progressSnapshot) {
                if (progressSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    !progressSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (progressSnapshot.hasError) {
                  return _buildErrorState('Unable to load progress.');
                }

                final progressRecords = progressSnapshot.data ?? const [];
                final progressMap = <String, ProgressRecord>{
                  for (final record in progressRecords) record.lessonId: record,
                };

                final cardData = categories
                    .map(
                      (category) => _CategoryCardData(
                        category: category,
                        status: _statusForCategory(
                          lessonsByCategory[category.id] ?? const [],
                          progressMap,
                        ),
                        progress: _progressForCategory(
                          lessonsByCategory[category.id] ?? const [],
                          progressMap,
                        ),
                      ),
                    )
                    .toList(growable: false);

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        _buildCurrentTopicCard(cardData.first.category),
                        const SizedBox(height: 30),
                        for (final data in cardData) ...[
                          _buildCategoryCard(
                            category: data.category,
                            status: data.status,
                            progress: data.progress,
                            onTap: () {
                              if (data.status == CategoryStatus.locked) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LessonListScreen(
                                    categoryId: data.category.id,
                                    categoryTitle: data.category.title,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCurrentTopicCard(LearningCategory category) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _fadeColor(category.color, 0.3),
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
          Text(
            category.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category.subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required LearningCategory category,
    required CategoryStatus status,
    required VoidCallback onTap,
    double? progress,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _fadeColor(category.color, 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.icon, color: category.color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (status == CategoryStatus.inProgress &&
                      progress != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _buildStatusIndicator(status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(CategoryStatus status) {
    switch (status) {
      case CategoryStatus.completed:
        return Row(
          children: [
            ...List.generate(
              3,
              (_) => Icon(Icons.star, size: 20, color: Colors.amber[700]),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
          ],
        );
      case CategoryStatus.inProgress:
        return Container(
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
        );
      case CategoryStatus.locked:
        return Icon(Icons.lock, color: Colors.grey[400], size: 24);
    }
  }

  CategoryStatus _statusForCategory(
    List<Lesson> lessons,
    Map<String, ProgressRecord> progress,
  ) {
    if (lessons.isEmpty) {
      return CategoryStatus.locked;
    }

    final completedCount = lessons.where((lesson) {
      final record = progress[lesson.id];
      return record?.status == LessonPlayStatus.completed;
    }).length;

    if (completedCount == lessons.length) {
      return CategoryStatus.completed;
    }

    return CategoryStatus.inProgress;
  }

  double? _progressForCategory(
    List<Lesson> lessons,
    Map<String, ProgressRecord> progress,
  ) {
    if (lessons.isEmpty) return null;
    final completedCount = lessons.where((lesson) {
      final record = progress[lesson.id];
      return record?.status == LessonPlayStatus.completed;
    }).length;
    return completedCount / lessons.length;
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 40),
            Text(
              'No categories yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Come back soon for more adventures!',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMissing() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.child_care, size: 56, color: Colors.black54),
            SizedBox(height: 16),
            Text(
              'Add an explorer to begin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Create or pick a child profile so we can load lessons.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
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
              'Please sign in to view categories.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
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

  Widget _buildErrorState(String message) {
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
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Color _fadeColor(Color color, double opacity) {
    final scaled = (255 * opacity).round();
    final clamped = scaled.clamp(0, 255).toInt();
    return color.withAlpha(clamped);
  }
}

class _CategoryCardData {
  final LearningCategory category;
  final CategoryStatus status;
  final double? progress;

  const _CategoryCardData({
    required this.category,
    required this.status,
    required this.progress,
  });
}

enum CategoryStatus {
  completed,
  inProgress,
  locked,
}
