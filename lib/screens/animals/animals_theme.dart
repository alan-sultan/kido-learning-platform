import 'package:flutter/material.dart';

class AnimalsTheme {
  static const Color background = Color(0xFFFFFAF3);
  static const Color canvas = Color(0xFFFFFDF8);
  static const Color darkBackground = Color(0xFF1F140A);
  static const Color primary = Color(0xFFB45309);
  static const Color accentLeaf = Color(0xFF15803D);
  static const Color accentSky = Color(0xFF0EA5E9);
  static const Color accentSun = Color(0xFFFACC15);
  static const Color textMain = Color(0xFF1C160B);
  static const Color textMuted = Color(0xFF7C6A58);
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
        color: borderColor ?? primary.withValues(alpha: 0.35),
        width: 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
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
      backgroundColor: Colors.white.withValues(alpha: 0.65),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  static BoxDecoration progressCard({Color? borderColor}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: borderColor ?? primary.withValues(alpha: 0.1),
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 24,
          offset: Offset(0, 14),
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
