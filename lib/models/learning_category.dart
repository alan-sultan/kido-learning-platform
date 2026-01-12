import 'package:flutter/material.dart';

class LearningCategory {
  final String id;
  final String title;
  final String subtitle;
  final String topic;
  final String iconName;
  final String colorHex;
  final int order;
  final String heroImageUrl;
  final String gradientStartHex;
  final String gradientEndHex;
  final String accentHex;

  const LearningCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.topic,
    required this.iconName,
    required this.colorHex,
    required this.order,
    this.heroImageUrl = '',
    this.gradientStartHex = '',
    this.gradientEndHex = '',
    this.accentHex = '',
  });

  factory LearningCategory.fromMap(String id, Map<String, dynamic> data) {
    return LearningCategory(
      id: id,
      title: data['title'] as String? ?? 'Category',
      subtitle: data['subtitle'] as String? ?? '',
      topic: data['topic'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'book',
      colorHex: data['colorHex'] as String? ?? '#FFE082',
      order: (data['order'] as num?)?.toInt() ?? 0,
      heroImageUrl: data['heroImageUrl'] as String? ?? '',
      gradientStartHex: data['gradientStartHex'] as String? ?? '',
      gradientEndHex: data['gradientEndHex'] as String? ?? '',
      accentHex: data['accentHex'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'topic': topic,
      'iconName': iconName,
      'colorHex': colorHex,
      'order': order,
      'heroImageUrl': heroImageUrl,
      'gradientStartHex': gradientStartHex,
      'gradientEndHex': gradientEndHex,
      'accentHex': accentHex,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  Color get color => _colorFromHex(colorHex);

  Color get accentColor =>
      _colorFromHex(accentHex.isEmpty ? colorHex : accentHex);

  Color get gradientStartColor =>
      _colorFromHex(gradientStartHex.isEmpty ? colorHex : gradientStartHex);

  Color get gradientEndColor =>
      _colorFromHex(gradientEndHex.isEmpty ? colorHex : gradientEndHex);

  IconData get icon => _iconFromName(iconName);

  static Color _colorFromHex(String hex) {
    if (hex.isEmpty) {
      return const Color(0xFFF2CC0D);
    }
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static IconData _iconFromName(String name) {
    switch (name) {
      case 'apple':
        return Icons.apple;
      case 'ball':
        return Icons.sports_basketball;
      case 'palette':
        return Icons.palette;
      case 'numbers':
        return Icons.numbers;
      case 'abc':
        return Icons.abc;
      case 'looks_3':
        return Icons.looks_3;
      case 'pets':
        return Icons.pets;
      case 'music':
        return Icons.music_note;
      case 'book':
      default:
        return Icons.menu_book;
    }
  }
}
