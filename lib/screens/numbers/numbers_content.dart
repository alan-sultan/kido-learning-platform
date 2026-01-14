import 'package:flutter/material.dart';

import '../../models/lesson.dart';
import '../../models/lesson_experience.dart';
import '../../numbers/numbers_library.dart';
import 'numbers_theme.dart';

class NumberLessonEntryData {
  const NumberLessonEntryData({
    required this.experience,
    required this.theme,
  });

  final LessonExperience experience;
  final NumberLessonTheme theme;

  Lesson get lesson => experience.lesson;
}

class NumberLessonTheme {
  const NumberLessonTheme({
    required this.cardBackground,
    required this.cardBorder,
    required this.accentColor,
    required this.numberLabel,
    required this.cardImageUrl,
  });

  final Color cardBackground;
  final Color cardBorder;
  final Color accentColor;
  final String numberLabel;
  final String cardImageUrl;

  factory NumberLessonTheme.fromLesson(Lesson lesson) {
    final metadata = NumbersLibrary.byLessonId(lesson.id);
    if (metadata != null) {
      return NumberLessonTheme(
        cardBackground: metadata.cardBackground,
        cardBorder: metadata.cardBorder,
        accentColor: metadata.accentColor,
        numberLabel: metadata.numberValue.toString(),
        cardImageUrl: metadata.cardImageUrl,
      );
    }

    return NumberLessonTheme(
      cardBackground: Colors.white,
      cardBorder: const Color(0xFFE2E8F0),
      accentColor: NumbersTheme.primary,
      numberLabel: _deriveLabel(lesson.title),
      cardImageUrl: _deriveImage(lesson),
    );
  }

  static String _deriveLabel(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }

  static String _deriveImage(Lesson lesson) {
    final fromExtra = lesson.extra['cardImageUrl'];
    if (fromExtra is String && fromExtra.isNotEmpty) {
      return fromExtra;
    }
    return '';
  }
}
