import 'package:flutter/material.dart';

import '../../models/child_profile.dart';
import '../../models/progress_record.dart';
import '../../numbers/numbers_library.dart';
import '../../services/app_services.dart';
import '../../services/navigation_service.dart';
import '../login_screen.dart';
import 'numbers_completion_screen.dart';
import 'numbers_routes.dart';
import 'numbers_theme.dart';

class NumbersActivityScreen extends StatefulWidget {
  const NumbersActivityScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<NumbersActivityScreen> createState() => _NumbersActivityScreenState();
}

class _NumbersActivityScreenState extends State<NumbersActivityScreen> {
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

    final metadata = NumbersLibrary.byLessonId(widget.lessonId);
    if (metadata == null) {
      return const _ErrorNotice('Activity not found.');
    }

    return Scaffold(
      backgroundColor: NumbersTheme.darkBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: NumbersTheme.maxContentWidth),
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
  final NumberLessonMetadata metadata;

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

  final NumberLessonMetadata metadata;
  final ChildProfile profile;
  final String userId;
  final ProgressRecord? progress;

  @override
  State<_ActivityExperience> createState() => _ActivityExperienceState();
}

class _ActivityExperienceState extends State<_ActivityExperience> {
  int? _selectedCount;
  int? _selectedAnswer;
  bool _isSubmitting = false;
  bool _showSuccess = false;

  @override
  Widget build(BuildContext context) {
    final step = widget.metadata.order + 1;
    final total = NumbersLibrary.lessons.length;
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Can you find ${widget.metadata.numberValue}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.metadata.activityPrompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                ...widget.metadata.activityCards.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ActivityCard(
                      card: card,
                      selected: _selectedCount == card.count,
                      onTap: () {
                        setState(() => _selectedCount = card.count);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _AnswerPad(
                  choices: widget.metadata.keypadChoices,
                  selectedValue: _selectedAnswer,
                  onTap: _handleAnswerTap,
                  disabled: _isSubmitting,
                ),
                if (_showSuccess)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: _SuccessBadge(
                        numberLabel: widget.metadata.heroHeadline),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAnswerTap(int value) async {
    if (_isSubmitting) return;
    setState(() => _selectedAnswer = value);
    if (value != widget.metadata.correctChoice) {
      NavigationService.showSnackBar(
        const SnackBar(content: Text('Try again! Choose a different number.')),
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
      bestScore: 1,
      completed: true,
    );
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: NumbersRoutes.completion),
        builder: (_) =>
            NumbersCompletionScreen(lessonId: widget.metadata.lessonId),
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
              color: NumbersTheme.accentGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.card,
    required this.selected,
    required this.onTap,
  });

  final NumberCollectionCard card;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? card.highlightColor : Colors.white12,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: card.highlightColor.withValues(alpha: 0.3),
                    width: 3),
                image: DecorationImage(
                  image: NetworkImage(card.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.headline,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.caption,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: card.highlightColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                card.count.toString(),
                style: TextStyle(
                  color: card.highlightColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerPad extends StatelessWidget {
  const _AnswerPad({
    required this.choices,
    required this.selectedValue,
    required this.onTap,
    this.disabled = false,
  });

  final List<int> choices;
  final int? selectedValue;
  final ValueChanged<int> onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: choices
            .map(
              (choice) => _AnswerChip(
                value: choice,
                selected: selectedValue == choice,
                onTap: disabled ? null : () => onTap(choice),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AnswerChip extends StatelessWidget {
  const _AnswerChip({
    required this.value,
    required this.selected,
    this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 90,
        height: 80,
        decoration: BoxDecoration(
          color: selected
              ? NumbersTheme.accentGreen
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.white : Colors.white24,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: selected ? NumbersTheme.darkBackground : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge({required this.numberLabel});

  final String numberLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: NumbersTheme.accentGreen.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_rounded,
              color: NumbersTheme.accentGreen, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Great!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: NumbersTheme.accentGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You found $numberLabel friends.',
            style: const TextStyle(color: Colors.white70),
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
