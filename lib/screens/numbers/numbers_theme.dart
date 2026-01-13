import 'package:flutter/material.dart';

class NumbersTheme {
  static const Color background = Color(0xFFF7F5F8);
  static const Color canvas = Color(0xFFF6F8F6);
  static const Color darkBackground = Color(0xFF191022);
  static const Color primary = Color(0xFF7F0DF2);
  static const Color accentGreen = Color(0xFF13EC5B);
  static const Color textMain = Color(0xFF140D1C);
  static const Color textMuted = Color(0xFF6F647C);
  static const Color surface = Colors.white;
  static const double maxContentWidth = 520;

  static ButtonStyle solidPill({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? shadowColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? primary,
      foregroundColor: foregroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      elevation: 6,
      shadowColor:
          (shadowColor ?? backgroundColor ?? primary).withValues(alpha: 0.3),
    );
  }

  static ButtonStyle outlinePill({Color? borderColor, Color? textColor}) {
    return OutlinedButton.styleFrom(
      foregroundColor: textColor ?? textMain,
      side: BorderSide(
          color: borderColor ?? textMain.withValues(alpha: 0.2), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static ButtonStyle ghostCircle({double size = 48}) {
    return IconButton.styleFrom(
      minimumSize: Size.square(size),
      maximumSize: Size.square(size),
      backgroundColor: Colors.white.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }

  static BoxDecoration softCard({Color? color, double radius = 24}) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x11000000),
          blurRadius: 18,
          offset: Offset(0, 10),
        ),
      ],
    );
  }
}
