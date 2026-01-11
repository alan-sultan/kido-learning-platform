import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Quiz {
  final String id;
  final String lessonId;
  final String title;
  final String description;
  final int questionCount;
  final int durationSeconds;

  const Quiz({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    required this.questionCount,
    required this.durationSeconds,
  });

  factory Quiz.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Quiz(
      id: doc.id,
      lessonId: data['lessonId'] as String? ?? '',
      title: data['title'] as String? ?? 'Quiz',
      description: data['description'] as String? ?? '',
      questionCount: (data['questionCount'] as num?)?.toInt() ?? 0,
      durationSeconds: (data['durationSeconds'] as num?)?.toInt() ?? 300,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'title': title,
      'description': description,
      'questionCount': questionCount,
      'durationSeconds': durationSeconds,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class QuizQuestion {
  final String id;
  final String text;
  final List<QuizOption> options;
  final int correctIndex;
  final String illustration;
  final String hint;

  const QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.illustration,
    this.hint = '',
  });

  factory QuizQuestion.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawOptions = data['options'] as List<dynamic>? ?? const [];
    return QuizQuestion(
      id: doc.id,
      text: data['text'] as String? ?? '',
      options: rawOptions
          .map((option) => QuizOption.fromMap(option as Map<String, dynamic>))
          .toList(),
      correctIndex: (data['correctIndex'] as num?)?.toInt() ?? 0,
      illustration: data['illustration'] as String? ?? 'default',
      hint: data['hint'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'options': options.map((o) => o.toMap()).toList(),
      'correctIndex': correctIndex,
      'illustration': illustration,
      'hint': hint,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class QuizOption {
  final String label;
  final String value;
  final Color color;

  const QuizOption({
    required this.label,
    required this.value,
    required this.color,
  });

  factory QuizOption.fromMap(Map<String, dynamic> data) {
    return QuizOption(
      label: data['label'] as String? ?? '',
      value: data['value'] as String? ?? '',
      color: _colorFromHex(data['colorHex'] as String? ?? '#FFB74D'),
    );
  }

  Map<String, dynamic> toMap() {
    final rgb = color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
    final hex = '#$rgb';
    return {
      'label': label,
      'value': value,
      'colorHex': hex,
    };
  }

  static Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
