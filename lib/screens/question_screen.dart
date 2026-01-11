import 'dart:async';

import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/quiz.dart';
import '../repositories/progress_repository.dart';
import '../services/app_services.dart';
import 'quiz_completion_screen.dart';

class QuestionScreen extends StatefulWidget {
  QuestionScreen({
    super.key,
    required this.lesson,
    required this.quiz,
    required this.questions,
  }) : assert(questions.isNotEmpty);

  final Lesson lesson;
  final Quiz quiz;
  final List<QuizQuestion> questions;

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int? _selectedOption;
  bool _showingFeedback = false;
  bool _submittingResult = false;
  bool _hasTimer = false;
  int _remainingSeconds = 0;
  Timer? _countdownTimer;
  late final Stopwatch _sessionStopwatch;
  final Set<int> _hintedQuestions = <int>{};

  @override
  void initState() {
    super.initState();
    _sessionStopwatch = Stopwatch()..start();
    _hasTimer = widget.quiz.durationSeconds > 0;
    if (_hasTimer) {
      _remainingSeconds = widget.quiz.durationSeconds;
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    if (_sessionStopwatch.isRunning) {
      _sessionStopwatch.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;
    final totalQuestions = widget.questions.length;
    final progress = (_currentIndex + 1) / totalQuestions;
    final hintText = question.hint.trim();
    final hasHint = hintText.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.quiz.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          if (_hasTimer)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(Icons.timer, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _remainingSeconds <= 10
                          ? Colors.redAccent
                          : Colors.amber[700],
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
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
                ),
                const SizedBox(height: 16),
                Text(
                  'Question ${_currentIndex + 1} of $totalQuestions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  question.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  children: List.generate(
                    question.options.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildOption(question, index),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed:
                      hasHint ? () => _showHint(hintText, _currentIndex) : null,
                  icon: Icon(
                    Icons.lightbulb_outline,
                    color: hasHint ? Colors.amber[700] : Colors.grey,
                  ),
                  label: Text(
                    hasHint ? 'Need a hint?' : 'Hints coming soon',
                    style: TextStyle(
                      fontSize: 16,
                      color: hasHint ? Colors.amber[700] : Colors.grey,
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

  Widget _buildOption(QuizQuestion question, int index) {
    final option = question.options[index];
    final isSelected = _selectedOption == index;
    final isCorrect = index == question.correctIndex;
    Color borderColor = Colors.grey[300]!;
    Color fillColor = Colors.white;
    IconData? icon;
    Color iconColor = Colors.black;

    if (_showingFeedback) {
      if (isSelected) {
        borderColor = isCorrect ? Colors.green : Colors.red;
        fillColor = isCorrect ? Colors.green[50]! : Colors.red[50]!;
        icon = isCorrect ? Icons.check_circle : Icons.cancel;
        iconColor = isCorrect ? Colors.green : Colors.red;
      } else if (isCorrect) {
        borderColor = Colors.green;
        fillColor = Colors.green[50]!;
        icon = Icons.check_circle;
        iconColor = Colors.green;
      }
    } else if (isSelected) {
      borderColor = Colors.amber;
      fillColor = Colors.amber[50]!;
    }

    return GestureDetector(
      onTap: _showingFeedback ? null : () => _handleOptionTap(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: option.color.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: option.color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to choose',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (icon != null)
              Icon(
                icon,
                color: iconColor,
              ),
          ],
        ),
      ),
    );
  }

  void _handleOptionTap(int index) {
    if (_showingFeedback) return;

    final question = _currentQuestion;
    final isCorrect = index == question.correctIndex;

    setState(() {
      _selectedOption = index;
      _showingFeedback = true;
      if (isCorrect) {
        _correctAnswers++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () async {
      if (!mounted) return;
      if (_currentIndex + 1 >= widget.questions.length) {
        await _completeQuiz();
        return;
      }

      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _showingFeedback = false;
      });
    });
  }

  Future<void> _completeQuiz() async {
    if (_submittingResult) return;
    _submittingResult = true;
    _countdownTimer?.cancel();
    if (_sessionStopwatch.isRunning) {
      _sessionStopwatch.stop();
    }
    final timeSpentSeconds = _sessionStopwatch.elapsed.inSeconds;
    final hintsUsed = _hintedQuestions.length;
    final baseStars = _calculateBaseStars();
    final hintPenaltyApplied = _hintedQuestions.isNotEmpty && baseStars > 0;
    final stars = hintPenaltyApplied ? baseStars - 1 : baseStars;
    final progressResult =
        await _recordProgress(stars, timeSpentSeconds, hintsUsed);
    final bestScore = progressResult?.bestScore ?? _correctAnswers;
    final isNewBestScore = progressResult?.improvedBestScore ?? false;
    final fastestDurationSeconds = progressResult?.fastestDurationSeconds ?? 0;
    final isNewFastestTime = progressResult?.improvedFastestTime ?? false;
    final starDelta = progressResult == null
        ? stars
        : (progressResult.totalStars - progressResult.previousStars);
    await _maybeIncrementChildStats(
      starsDelta: starDelta > 0 ? starDelta : 0,
      improvedBestScore: isNewBestScore,
      improvedFastestTime: isNewFastestTime,
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizCompletionScreen(
          lesson: widget.lesson,
          quiz: widget.quiz,
          correctAnswers: _correctAnswers,
          totalQuestions: widget.questions.length,
          starsEarned: stars,
          timeSpentSeconds: timeSpentSeconds,
          hintsUsed: hintsUsed,
          hintPenaltyApplied: hintPenaltyApplied,
          bestScore: bestScore,
          isNewBestScore: isNewBestScore,
          fastestDurationSeconds: fastestDurationSeconds,
          isNewFastestTime: isNewFastestTime,
        ),
      ),
    );
  }

  Future<QuizProgressResult?> _recordProgress(
    int starsEarned,
    int timeSpentSeconds,
    int hintsUsed,
  ) async {
    final user = AppServices.auth.currentUser;
    final profile = AppServices.childSelection.activeProfile;
    if (user == null || profile == null) return null;
    try {
      final result = await AppServices.progress.recordQuizResult(
        userId: user.uid,
        childId: profile.id,
        lessonId: widget.lesson.id,
        correctAnswers: _correctAnswers,
        totalQuestions: widget.questions.length,
        starsEarned: starsEarned,
        timeSpentSeconds: timeSpentSeconds,
        hintsUsed: hintsUsed,
      );
      return result;
    } catch (_) {
      // Ignore errors for now; the UI still transitions to completion.
      return null;
    }
  }

  Future<void> _maybeIncrementChildStats({
    required int starsDelta,
    required bool improvedBestScore,
    required bool improvedFastestTime,
  }) async {
    final user = AppServices.auth.currentUser;
    final profile = AppServices.childSelection.activeProfile;
    if (user == null || profile == null) return;
    final bool countCompletion = improvedBestScore || improvedFastestTime;
    final bool earnedStars = starsDelta > 0;
    if (!countCompletion && !earnedStars) {
      return;
    }

    await AppServices.childProfiles.incrementStats(
      user.uid,
      profile.id,
      starsDelta: earnedStars ? starsDelta : 0,
      lessonsDelta: countCompletion ? 1 : 0,
      quizzesDelta: countCompletion ? 1 : 0,
    );
  }

  int _calculateBaseStars() {
    final ratio = _correctAnswers / widget.questions.length;
    if (ratio >= 0.9) return 3;
    if (ratio >= 0.6) return 2;
    if (ratio > 0) return 1;
    return 0;
  }

  QuizQuestion get _currentQuestion => widget.questions[_currentIndex];

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
        _handleTimerExpired();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _handleTimerExpired() async {
    if (_submittingResult) return;
    await _completeQuiz();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = secs.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  void _showHint(String hint, int questionIndex) {
    if (hint.isEmpty) return;
    _hintedQuestions.add(questionIndex);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Helpful hint',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                hint,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
