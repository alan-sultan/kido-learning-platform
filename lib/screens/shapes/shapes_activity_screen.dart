import 'package:flutter/material.dart';

import '../../models/child_profile.dart';
import '../../models/progress_record.dart';
import '../../services/app_services.dart';
import '../../services/navigation_service.dart';
import '../../shapes/shapes_library.dart';
import '../login_screen.dart';
import 'shapes_completion_screen.dart';
import 'shapes_routes.dart';
import 'shapes_theme.dart';

class ShapesActivityScreen extends StatefulWidget {
  const ShapesActivityScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<ShapesActivityScreen> createState() => _ShapesActivityScreenState();
}

class _ShapesActivityScreenState extends State<ShapesActivityScreen> {
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

  Future<ChildProfile?> _ensureProfileAndSelection(String userId) async {
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
      return const LoginScreen();
    }

    final metadata = ShapesLibrary.byLessonId(widget.lessonId);
    if (metadata == null) {
      return const _ErrorNotice('Activity not found.');
    }

    return Scaffold(
      backgroundColor: ShapesTheme.darkBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: ShapesTheme.maxContentWidth),
            child: FutureBuilder<ChildProfile?>(
              future: _ensureProfileFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const _ErrorNotice('Unable to load explorer.');
                }
                return AnimatedBuilder(
                  animation: AppServices.childSelection,
                  builder: (context, _) {
                    final profile = AppServices.childSelection.activeProfile;
                    if (profile == null) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return const _ErrorNotice('Create an explorer first.');
                    }
                    return _ActivityStream(
                      userId: user.uid,
                      profile: profile,
                      metadata: metadata,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityStream extends StatelessWidget {
  const _ActivityStream({
    required this.userId,
    required this.profile,
    required this.metadata,
  });

  final String userId;
  final ChildProfile profile;
  final ShapeLessonMetadata metadata;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProgressRecord?>(
      stream: AppServices.progress
          .watchLessonProgress(userId, profile.id, metadata.lessonId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const _ErrorNotice('Unable to load progress.');
        }

        return _ActivityExperience(
          metadata: metadata,
          profile: profile,
          userId: userId,
          progress: snapshot.data,
        );
      },
    );
  }
}

class _ActivityExperience extends StatefulWidget {
  const _ActivityExperience({
    required this.metadata,
    required this.profile,
    required this.userId,
    required this.progress,
  });

  final ShapeLessonMetadata metadata;
  final ChildProfile profile;
  final String userId;
  final ProgressRecord? progress;

  @override
  State<_ActivityExperience> createState() => _ActivityExperienceState();
}

class _ActivityExperienceState extends State<_ActivityExperience> {
  String? _selectedOption;
  bool _isSubmitting = false;
  bool _showSuccess = false;

  @override
  Widget build(BuildContext context) {
    final step = widget.metadata.order + 1;
    final total = ShapesLibrary.lessons.length;
    final progressValue = step / total;

    return Column(
      children: [
        _ActivityHeader(
          step: step,
          total: total,
          progress: progressValue,
          onClose: () => Navigator.pop(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Can you find the ${widget.metadata.title}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.metadata.activityPrompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                ...widget.metadata.activityOptions.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ActivityCard(
                      option: option,
                      selected: _selectedOption == option.id,
                      onTap: () => _handleSelection(option),
                    ),
                  ),
                ),
                if (_showSuccess)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _SuccessBadge(
                      label: 'You found the ${widget.metadata.title}! 🎉',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSelection(ShapeActivityOption option) async {
    if (_isSubmitting) return;
    setState(() => _selectedOption = option.id);
    if (!option.isCorrect) {
      NavigationService.showSnackBar(
        SnackBar(content: Text('${option.label} is not the right shape.')),
      );
      return;
    }

    setState(() => _showSuccess = true);
    await _completeLesson();
  }

  Future<void> _completeLesson() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    await AppServices.progress.recordPlayEvent(
      userId: widget.userId,
      childId: widget.profile.id,
      lessonId: widget.metadata.lessonId,
      status: LessonPlayStatus.completed,
      starsEarned: 1,
      bestScore: widget.metadata.totalDiscoverySteps,
      completed: true,
    );
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: ShapesRoutes.completion),
        builder: (_) => ShapesCompletionScreen(
          lessonId: widget.metadata.lessonId,
        ),
      ),
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader({
    required this.step,
    required this.total,
    required this.progress,
    required this.onClose,
  });

  final int step;
  final int total;
  final double progress;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: onClose,
              ),
              const Spacer(),
              Text(
                'Step $step of $total',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: Colors.white12,
              color: ShapesTheme.accentSun,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ShapeActivityOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? option.backgroundColor : Colors.white24,
            width: selected ? 3 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: option.backgroundColor.withValues(alpha: 0.3),
              ),
              child: Icon(option.icon, color: Colors.white, size: 42),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? option.backgroundColor : Colors.white38,
            )
          ],
        ),
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
