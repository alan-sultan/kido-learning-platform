import 'package:flutter/material.dart';

class ColorsTheme {
  static const Color background = Color(0xFFF7F5F8);
  static const Color canvas = Color(0xFFFDFBFF);
  static const Color darkBackground = Color(0xFF191022);
  static const Color primary = Color(0xFF7F0DF2);
  static const Color accentSun = Color(0xFFF2F20D);
  static const Color accentOrange = Color(0xFFF27F0D);
  static const Color textMain = Color(0xFF140D1C);
  static const Color textMuted = Color(0xFF7A6F8F);
  static const double maxContentWidth = 520;

  static ButtonStyle primaryPill({Color? backgroundColor}) {
    final bg = backgroundColor ?? primary;
    return ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      elevation: 8,
      shadowColor: bg.withValues(alpha: 0.35),
    );
  }

  static ButtonStyle outlinePill({Color? borderColor, Color? textColor}) {
    return OutlinedButton.styleFrom(
      foregroundColor: textColor ?? primary,
      side: BorderSide(
          color: borderColor ?? primary.withValues(alpha: 0.3), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static ButtonStyle ghostCircle({double size = 48}) {
    return IconButton.styleFrom(
      minimumSize: Size.square(size),
      maximumSize: Size.square(size),
      backgroundColor: Colors.white.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }

  static BoxDecoration progressCard() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: primary.withValues(alpha: 0.08)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 24,
          offset: Offset(0, 12),
        ),
      ],
    );
  }

  static LinearGradient heroGradient(
      {required Color start, required Color end}) {
    return LinearGradient(
      colors: [start, end],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
