import 'package:flutter/material.dart';

import '../../alphabet/alphabet_library.dart';
import '../../models/lesson.dart';
import '../../models/lesson_experience.dart';

class AlphabetLessonEntryData {
  const AlphabetLessonEntryData({
    required this.experience,
    required this.theme,
  });

  final LessonExperience experience;
  final AlphabetLessonTheme theme;

  Lesson get lesson => experience.lesson;
}

class AlphabetLessonTheme {
  const AlphabetLessonTheme({
    required this.letter,
    required this.subtitle,
    required this.backgroundColor,
    required this.accentColor,
    required this.badgeColor,
  });

  final String letter;
  final String subtitle;
  final Color backgroundColor;
  final Color accentColor;
  final Color badgeColor;

  static AlphabetLessonTheme fromLesson(Lesson lesson) {
    final metadata = AlphabetLibrary.byLessonId(lesson.id);
    if (metadata != null) {
      return AlphabetLessonTheme(
        letter: metadata.letter,
        subtitle: metadata.subtitle,
        backgroundColor: metadata.backgroundColor,
        accentColor: metadata.accentColor,
        badgeColor: metadata.badgeColor,
      );
    }

    final fallbackLetter = _firstLetter(lesson.title);
    return AlphabetLessonTheme(
      letter: fallbackLetter,
      subtitle: lesson.description,
      backgroundColor: Colors.orange.shade50,
      accentColor: Colors.orange.shade400,
      badgeColor: Colors.amber.shade400,
    );
  }

  static String _firstLetter(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    final rune = trimmed.runes.first;
    return String.fromCharCode(rune).toUpperCase();
  }
}
