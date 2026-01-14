import 'package:flutter/material.dart';

import '../../colors/colors_library.dart';
import '../../models/lesson.dart';
import '../../models/lesson_experience.dart';
import '../../models/progress_record.dart';
import 'colors_theme.dart';

class ColorLessonEntryData {
  const ColorLessonEntryData({
    required this.experience,
    required this.theme,
  });

  final LessonExperience experience;
  final ColorLessonTheme theme;

  Lesson get lesson => experience.lesson;
  LessonPlayStatus get status => experience.status;
  bool get isLocked => experience.isLocked;
  bool get isCompleted => experience.isCompleted;
}

class ColorLessonTheme {
  const ColorLessonTheme({
    required this.gradientStart,
    required this.gradientEnd,
    required this.accentColor,
    required this.badgeColor,
    required this.heroLabel,
    required this.heroImageUrl,
  });

  final Color gradientStart;
  final Color gradientEnd;
  final Color accentColor;
  final Color badgeColor;
  final String heroLabel;
  final String heroImageUrl;

  factory ColorLessonTheme.fromLesson(Lesson lesson) {
    final metadata = ColorsLibrary.byLessonId(lesson.id);
    if (metadata != null) {
      return ColorLessonTheme(
        gradientStart: metadata.gradientStart,
        gradientEnd: metadata.gradientEnd,
        accentColor: metadata.accentColor,
        badgeColor: metadata.badgeColor,
        heroLabel: metadata.displayName.split(' ').first,
        heroImageUrl: metadata.heroImageUrl,
      );
    }

    return ColorLessonTheme(
      gradientStart: ColorsTheme.primary.withValues(alpha: 0.8),
      gradientEnd: ColorsTheme.primary,
      accentColor: ColorsTheme.accentOrange,
      badgeColor: Colors.white,
      heroLabel: _fallbackLabel(lesson.title),
      heroImageUrl: _fallbackImage(lesson),
    );
  }

  static String _fallbackLabel(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return 'Hue';
    }
    final spaceIndex = trimmed.indexOf(' ');
    if (spaceIndex == -1) {
      return trimmed;
    }
    return trimmed.substring(0, spaceIndex);
  }

  static String _fallbackImage(Lesson lesson) {
    final fromExtra = lesson.extra['heroImageUrl'];
    if (fromExtra is String && fromExtra.isNotEmpty) {
      return fromExtra;
    }
    return '';
  }
}
