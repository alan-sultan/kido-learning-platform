import 'package:flutter/material.dart';

class AlphabetTheme {
  static const Color background = Color(0xFFFCFBF8);
  static const Color backgroundDark = Color(0xFF221F10);
  static const Color primary = Color(0xFFF2CC0D);
  static const Color accentOrange = Color(0xFFFF8C42);
  static const Color textMain = Color(0xFF1C190D);
  static const Color textMuted = Color(0xFF9C8E49);
  static const Color surface = Colors.white;
  static const double maxContentWidth = 520;

  static ButtonStyle ctaButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: accentOrange,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      padding: const EdgeInsets.symmetric(vertical: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      elevation: 6,
      shadowColor: accentOrange.withValues(alpha: 0.4),
    );
  }

  static ButtonStyle outlineButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: textMain,
      side: const BorderSide(color: Color(0xFFE8E4CE), width: 2),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }
}
