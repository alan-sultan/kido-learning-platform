import 'package:flutter/material.dart';

import '../../models/lesson.dart';
import '../../models/lesson_experience.dart';
import '../../models/progress_record.dart';
import '../../shapes/shapes_library.dart';
import 'shapes_theme.dart';

class ShapeLessonEntryData {
  const ShapeLessonEntryData({
    required this.experience,
    required this.theme,
  });

  final LessonExperience experience;
  final ShapeLessonTheme theme;

  Lesson get lesson => experience.lesson;
  LessonPlayStatus get status => experience.status;

  bool get isLocked => experience.isLocked;
  bool get isCompleted => experience.isCompleted;
  bool get isInProgress => experience.isInProgress;

  double progressRatio() {
    if (isCompleted) return 1;
    final total = theme.totalDiscoverySteps;
    if (total <= 0) {
      return experience.progress == null ? 0 : 1;
    }
    final best = experience.progress?.bestScore ?? 0;
    final ratio = best / total;
    return ratio.clamp(0, 1);
  }
}

class ShapeLessonTheme {
  const ShapeLessonTheme({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.cardGradientStart,
    required this.cardGradientEnd,
    required this.accentColor,
    required this.totalDiscoverySteps,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color cardGradientStart;
  final Color cardGradientEnd;
  final Color accentColor;
  final int totalDiscoverySteps;

  factory ShapeLessonTheme.fromLesson(Lesson lesson) {
    final metadata = ShapesLibrary.byLessonId(lesson.id);
    if (metadata != null) {
      return ShapeLessonTheme(
        icon: metadata.icon,
        iconColor: metadata.iconColor,
        iconBackground: metadata.iconBackground,
        cardGradientStart: metadata.cardGradientStart,
        cardGradientEnd: metadata.cardGradientEnd,
        accentColor: metadata.accentColor,
        totalDiscoverySteps: metadata.totalDiscoverySteps,
      );
    }

    return ShapeLessonTheme(
      icon: Icons.category_rounded,
      iconColor: Colors.white,
      iconBackground: ShapesTheme.primary,
      cardGradientStart: ShapesTheme.primary.withValues(alpha: 0.6),
      cardGradientEnd: ShapesTheme.primary,
      accentColor: ShapesTheme.primary,
      totalDiscoverySteps: 5,
    );
  }
}
