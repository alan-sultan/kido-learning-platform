import 'package:flutter/material.dart';

import '../models/child_profile.dart';
import '../models/lesson.dart';
import '../models/progress_record.dart';
import '../services/app_services.dart';
import 'lesson_screen.dart';
import 'login_screen.dart';

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  final String categoryId;
  final String categoryTitle;

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  LessonFilter _selectedFilter = LessonFilter.all;
  late final Future<ChildProfile?> _ensureProfileFuture;

  static const List<LessonFilter> _filters = <LessonFilter>[
    LessonFilter.all,
    LessonFilter.inProgress,
    LessonFilter.completed,
  ];

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryTitle.isEmpty ? "Let's Learn!" : widget.categoryTitle,
          style: const TextStyle(
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
        child: FutureBuilder<ChildProfile?>(
          future: _ensureProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState(
                'We could not prepare your explorer. Please try again shortly.',
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
                  return _buildProfileMissing(context);
                }
                return _buildLessonStreams(context, user.uid, profile.id);
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

  Widget _buildLessonStreams(
    BuildContext context,
    String userId,
    String childId,
  ) {
    return StreamBuilder<List<Lesson>>(
      stream: AppServices.learningContent.watchLessons(
        categoryId: widget.categoryId.isEmpty ? null : widget.categoryId,
      ),
      builder: (context, lessonSnapshot) {
        if (lessonSnapshot.connectionState == ConnectionState.waiting &&
            !lessonSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (lessonSnapshot.hasError) {
          return _buildErrorState('Unable to load lessons right now.');
        }

        final lessons = lessonSnapshot.data ?? const <Lesson>[];
        if (lessons.isEmpty) {
          return _buildEmptyState();
        }

        return StreamBuilder<List<ProgressRecord>>(
          stream: AppServices.progress.watchProgress(userId, childId),
          builder: (context, progressSnapshot) {
            if (progressSnapshot.connectionState == ConnectionState.waiting &&
                !progressSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (progressSnapshot.hasError) {
              return _buildErrorState('Unable to load progress data.');
            }

            final progressMap = <String, ProgressRecord>{
              for (final record in progressSnapshot.data ?? const [])
                record.lessonId: record,
            };

            final cardData = lessons
                .map(
                  (lesson) => _LessonCardData(
                    lesson: lesson,
                    progress: progressMap[lesson.id],
                    status: _statusForLesson(
                      lesson,
                      progressMap[lesson.id],
                    ),
                  ),
                )
                .toList(growable: false);

            final filtered = cardData
                .where((data) => _matchesFilter(data.status))
                .toList(growable: false);

            if (filtered.isEmpty) {
              return Column(
                children: [
                  _buildFilterTabs(),
                  Expanded(child: _buildFilteredEmptyState()),
                ],
              );
            }

            return Column(
              children: [
                _buildFilterTabs(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildLessonCard(context, filtered[index]);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedFilter == filter) return;
                setState(() {
                  _selectedFilter = filter;
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
                  _filterLabel(filter),
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
    );
  }

  String _filterLabel(LessonFilter filter) {
    switch (filter) {
      case LessonFilter.all:
        return 'All';
      case LessonFilter.inProgress:
        return 'In Progress';
      case LessonFilter.completed:
        return 'Completed';
    }
  }

  bool _matchesFilter(LessonPlayStatus status) {
    switch (_selectedFilter) {
      case LessonFilter.all:
        return true;
      case LessonFilter.inProgress:
        return status == LessonPlayStatus.inProgress ||
            status == LessonPlayStatus.ready;
      case LessonFilter.completed:
        return status == LessonPlayStatus.completed;
    }
  }

  LessonPlayStatus _statusForLesson(
    Lesson lesson,
    ProgressRecord? record,
  ) {
    if (record != null) {
      return record.status;
    }

    switch (lesson.defaultStatus) {
      case LessonStatus.start:
        return LessonPlayStatus.inProgress;
      case LessonStatus.locked:
        return LessonPlayStatus.locked;
      case LessonStatus.ready:
        return LessonPlayStatus.ready;
    }
  }

  String _ctaLabel(LessonPlayStatus status) {
    switch (status) {
      case LessonPlayStatus.inProgress:
        return 'Continue';
      case LessonPlayStatus.completed:
        return 'Replay';
      case LessonPlayStatus.ready:
        return 'Start';
      case LessonPlayStatus.locked:
        return 'Locked';
    }
  }

  Widget _buildStatusBadge(LessonPlayStatus status) {
    Color background;
    Color textColor;
    String label;
    switch (status) {
      case LessonPlayStatus.completed:
        background = Colors.green[100]!;
        textColor = Colors.green[800]!;
        label = 'Completed';
        break;
      case LessonPlayStatus.inProgress:
        background = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        label = 'In Progress';
        break;
      case LessonPlayStatus.ready:
        background = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        label = 'Ready';
        break;
      case LessonPlayStatus.locked:
        background = Colors.grey[200]!;
        textColor = Colors.grey[600]!;
        label = 'Locked';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildFilteredEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_alt_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No lessons in this filter yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try switching to another filter to keep learning.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text(
              'No lessons yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back soon for new adventures!',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMissing(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add an explorer to view lessons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Create a child profile so we can track their progress.',
              style: TextStyle(color: Colors.grey[600]),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please sign in to view lessons.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
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
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.black54),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, _LessonCardData data) {
    final lesson = data.lesson;
    final status = data.status;
    final progress = data.progress;
    final telemetryChips = _buildTelemetryChips(progress);

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
            child: _buildLessonImage(lesson.illustration),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryTitle.isEmpty
                      ? lesson.categoryId.toUpperCase()
                      : widget.categoryTitle.toUpperCase(),
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusBadge(status),
                    const SizedBox(width: 8),
                    if (progress != null)
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber[700]),
                          const SizedBox(width: 4),
                          Text(
                            '${progress.starsEarned} stars',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (telemetryChips.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: telemetryChips,
                  ),
                ],
                if (lesson.durationMinutes > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${lesson.durationMinutes} min lesson',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (status == LessonPlayStatus.locked)
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
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () => _openLesson(lesson),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _ctaLabel(status),
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

  void _openLesson(Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonScreen(lessonId: lesson.id),
      ),
    );
  }

  List<Widget> _buildTelemetryChips(ProgressRecord? progress) {
    if (progress == null || progress.attempts == 0) {
      return const [];
    }

    final chips = <Widget>[];
    final duration = progress.lastDurationSeconds;
    if (duration > 0) {
      chips.add(
        _buildTelemetryChip(
          Icons.timer_outlined,
          _formatDurationShort(duration),
        ),
      );
    }

    final hints = progress.lastHintsUsed;
    final label =
        hints == 0 ? 'No hints' : '$hints hint${hints == 1 ? '' : 's'}';
    chips.add(
      _buildTelemetryChip(
        Icons.lightbulb_outline,
        label,
      ),
    );

    return chips;
  }

  Widget _buildTelemetryChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDurationShort(int totalSeconds) {
    if (totalSeconds < 60) {
      return '${totalSeconds}s';
    }
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (seconds == 0) {
      return '${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }

  Widget _buildLessonImage(LessonIllustration illustration) {
    switch (illustration) {
      case LessonIllustration.balloons:
        return CustomPaint(
          size: const Size(100, 100),
          painter: BalloonsPainter(),
        );
      case LessonIllustration.lion:
        return CustomPaint(
          size: const Size(100, 100),
          painter: LionFacePainter(),
        );
      case LessonIllustration.blocks:
        return CustomPaint(
          size: const Size(100, 100),
          painter: BlocksPainter(),
        );
      case LessonIllustration.shapes:
        return CustomPaint(
          size: const Size(100, 100),
          painter: ShapesPainter(),
        );
      case LessonIllustration.numbers:
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

enum LessonFilter { all, inProgress, completed }

class _LessonCardData {
  const _LessonCardData({
    required this.lesson,
    required this.status,
    this.progress,
  });

  final Lesson lesson;
  final LessonPlayStatus status;
  final ProgressRecord? progress;
}

class BalloonsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple
    ];
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
    trianglePath.lineTo(
        center.dx - size.width * 0.15, center.dy + size.height * 0.1);
    trianglePath.lineTo(
        center.dx + size.width * 0.15, center.dy + size.height * 0.1);
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
