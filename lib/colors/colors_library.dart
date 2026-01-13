import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/progress_record.dart';

class ColorsOverviewContent {
  const ColorsOverviewContent({
    required this.tagline,
    required this.subtitle,
    required this.encouragement,
    required this.heroImageUrl,
    required this.heroBadgeSymbol,
    required this.ctaLabel,
    required this.progressLabel,
  });

  final String tagline;
  final String subtitle;
  final String encouragement;
  final String heroImageUrl;
  final String heroBadgeSymbol;
  final String ctaLabel;
  final String progressLabel;
}

class ColorGalleryItem {
  const ColorGalleryItem({
    required this.label,
    required this.imageUrl,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String label;
  final String imageUrl;
  final Color backgroundColor;
  final Color borderColor;
}

class ColorActivityOption {
  const ColorActivityOption({
    required this.id,
    required this.label,
    required this.imageUrl,
    required this.accentColor,
    required this.isCorrect,
  });

  final String id;
  final String label;
  final String imageUrl;
  final Color accentColor;
  final bool isCorrect;
}

class ColorLessonMetadata {
  const ColorLessonMetadata({
    required this.lessonId,
    required this.displayName,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.heroImageUrl,
    required this.gradientStart,
    required this.gradientEnd,
    required this.accentColor,
    required this.badgeColor,
    required this.order,
    required this.defaultStatus,
    required this.xpReward,
    required this.voiceLine,
    required this.gallery,
    required this.activityPrompt,
    required this.activityOptions,
    required this.completionTitle,
    required this.completionSubtitle,
    required this.completionMascotUrl,
  });

  final String lessonId;
  final String displayName;
  final String title;
  final String subtitle;
  final String description;
  final String heroImageUrl;
  final Color gradientStart;
  final Color gradientEnd;
  final Color accentColor;
  final Color badgeColor;
  final int order;
  final LessonStatus defaultStatus;
  final int xpReward;
  final String voiceLine;
  final List<ColorGalleryItem> gallery;
  final String activityPrompt;
  final List<ColorActivityOption> activityOptions;
  final String completionTitle;
  final String completionSubtitle;
  final String completionMascotUrl;

  String get heroLabel => displayName;
  String get quizId => 'quiz-${lessonId.replaceAll('-', '_')}';
}

class ColorLessonEntry {
  const ColorLessonEntry({
    required this.metadata,
    required this.status,
    required this.progress,
  });

  final ColorLessonMetadata metadata;
  final LessonPlayStatus status;
  final ProgressRecord? progress;

  bool get isLocked => status == LessonPlayStatus.locked;
  bool get isCompleted => status == LessonPlayStatus.completed;
  bool get isInProgress => status == LessonPlayStatus.inProgress;
}

class ColorsLibrary {
  ColorsLibrary._();

  static const ColorsOverviewContent overview = ColorsOverviewContent(
    tagline: 'Discover a world of color!',
    subtitle: 'Colors',
    encouragement: 'Keep going to unlock a new sticker!',
    heroImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB2Pvr0NKhMW4M_vvFvyIPRBdwB8usxAPtptTkjYgSZA4d1m-D8ZH9FOurl79dBC2jIVhOnjHR6l5Tkp5nMc_Pn7QrdfBexnVLEqnSy3u3p-XNeGePlfZMz7bc-8HX1Dt7GioqJzpFxHZE4uoWooQ7PD_xqCKzapsjPybMR3UFTyQutz9adZlflITWQTWBQ7_iHu92t8usSg2Bnec0KL86HIOhMNouIyKA1H-IT9gLnpaLZ0uWsaTaFF9W_6NmHhboBWEhVmK2xvwM',
    heroBadgeSymbol: '🎨',
    ctaLabel: 'Start Learning',
    progressLabel: "You're doing great!",
  );

  static final List<ColorLessonMetadata> lessons =
      List<ColorLessonMetadata>.unmodifiable(_colorSeeds);

  static final Map<String, ColorLessonMetadata> _byLessonId = {
    for (final metadata in lessons) metadata.lessonId: metadata,
  };

  static ColorLessonMetadata? byLessonId(String lessonId) {
    return _byLessonId[lessonId];
  }

  static List<ColorLessonEntry> buildEntries(
    Map<String, ProgressRecord> progress,
  ) {
    final entries = <ColorLessonEntry>[];
    for (final metadata in lessons) {
      final record = progress[metadata.lessonId];
      final status = _inferStatus(
        record,
        entries.isEmpty ? null : entries.last,
        metadata,
      );
      entries.add(ColorLessonEntry(
        metadata: metadata,
        status: status,
        progress: record,
      ));
    }
    return entries;
  }

  static ColorLessonEntry? nextPlayable(List<ColorLessonEntry> entries) {
    for (final entry in entries) {
      if (entry.status != LessonPlayStatus.completed) {
        return entry;
      }
    }
    return null;
  }

  static LessonPlayStatus _inferStatus(
    ProgressRecord? record,
    ColorLessonEntry? previous,
    ColorLessonMetadata metadata,
  ) {
    if (record != null) {
      return record.status;
    }
    switch (metadata.defaultStatus) {
      case LessonStatus.ready:
        return LessonPlayStatus.ready;
      case LessonStatus.start:
        return LessonPlayStatus.inProgress;
      case LessonStatus.locked:
        return previous?.isCompleted ?? false
            ? LessonPlayStatus.ready
            : LessonPlayStatus.locked;
    }
  }

  static final List<Lesson> lessonStubs = List<Lesson>.unmodifiable(
    lessons
        .map(
          (metadata) => Lesson(
            id: metadata.lessonId,
            categoryId: 'colors',
            title: metadata.title,
            description: metadata.subtitle,
            illustration: LessonIllustration.shapes,
            defaultStatus: metadata.defaultStatus,
            order: metadata.order,
            content: metadata.description,
            durationMinutes: 6,
            quizId: metadata.quizId,
          ),
        )
        .toList(growable: false),
  );
}

const String _redAppleImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuC3LLG3dkkNcYfDlJeXbt1qCy7DDqSE7IfSLaDdtc83bz5Sg1neBisNtMXrYheoyvdOpepKvjmOwLWuME6Ao7ZJNCBmyqNd1Si3hHIO5qA29Jig99OeouPoxCLKTR1dZyImsFPwA3EbS6kzSoJZdiacwwk7Wh5G34Zp_GE-vg5uMzXGUf5KEXC-zchqEu-435POXKL36jqs2RW0d879tgeJZNPRfX5rdQFyGHjOnMAquvgyJST5GtKLj8RPvaP2cq7vROz1oBSAHeg';
const String _blueFishImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBuEE7iPZxNPfpfibqW15CocAmYLz9BR6NDh4tF99TskNk6T43XWcqW7NLnysc9ipPM3lGoX6pweylmlu-tYPBQ7Zl0p0xQXVDMrcjZMiGBkQ_y61pGRXpkMEsH9AmbjnIgiEGQnCwzpL7HqihfGvIM9rc7vq6d4f0OMOAMay55Pp82ZI1qmNGOO8J3Xiu5rV66op8YuB-FMR_4A-EoCIVSeOFUzspTxz8oFMWH6p1Bc_h1OExYAaq5NbBAeA78YkfNq8VtSv5Ldrk';
const String _yellowSunImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuD8T6CxR4aEkRDzhwd-VnKDcgdMAW5oJeCK_Z_i2wfxll3e9P_8Tc4svlWg6NIkhLy55fxk0ywGLok3jfImTh5JldBOtSJPHUJMLd-UASKaD8KjoqtptNKzaBddQBlqf6eEd33HMwHwI6WAcj3OWhn5XZHZcJ2M5yyPc-tJa4fiRD2aXepbYhCjFBZy_twv6Db0OL4xdHPVmyJz_5P6m119ytyt6Ab16rMVRTo7NV31lwyQ2VNA8sLciupFC9Kmm1pvheAyOrYuafY';
const String _bananaImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBHXAiZWOS1g_v-Xj6AJx41xRflJeu4dyDDAImwWzfAqmqgBQOAX_vfbgboOINxL8ehgQsKeiF7Z1z-g7JctHQUVoWeO3a4aALXLSCtoY6zOSfhHa_kjyEmQWoSeHjanBd0Kg5ahrh-pqMHBwekLMIXCelZc5TKMpZlDE17ko2fP3TPWKpPJO6kh-5j0RbVBYKLGhLJexn5-j7JL85iI_KLviw6QhbfDg7wvwO9cYbLyySJTsHe8_QGTVnt_ItcFW-4bZl8RvOCa4g';
const String _greenLeafImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDQD2Qdu8A2P7wwLotXl9MoOrqGyZa9aqQolb0yNk3XFoxDsJ1U3nM4ybnBnr9XCOZljJYGNvpiO3H6kAss5ObeVcp0agQFVJLD-w-8Bz6o8lC3gSO3b17C0ubd2rDgoJO-tMjjzleVqFLd8mYhicGPoDGkUGZai0Y5NPX0ANndK-XzgLRyfADrHm-4PFqruFDH4nYbIvk2vh87-W2WwHxW4Iye8meAPXS4Cof5whbTZiIw8HG0SRv_JeZP7oLY4f140Kx9t890VLs';
const String _orangeFruitImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBEf12QNW83ZfKsgFsL_URZnZvZ7GLZWW7qUrDRW9Td41ddSaM8Aso-nyD02TMffRRaIKMtnxX_VwJnqqU_GTmMotqW5adXchNST-aFfBpQWI7tQw2lgYbOzgVBF2HgGfmi7rYBM8DVRygwXmSUkO0zZdzI_d8Lpk-g0LI-JxKuILNk2kBEMMF0AC85mKQwKLxFNe4DgET_pyEyN6-r-MP6LrTYRpg41Gh90gUxcT66lXxobs5dzlgO7Yo6URNM1miavGRsgnRkChM';
const String _paletteCelebrationImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBKQ0beyA-xMHqFJVvhn9V9PUx73v0xbgXVAUA0WxLj6DyZ--DrZWSaO5flgcJdZba_1vBwU-kEPOFJV-l-X8tKiVh7S5OAQLreYGcF_WLPui62pRgqZBipU8aypl7PhluDcxDAWSAh9dMUrZDOkAMedTZxljGiVjYtWMVCzmeUR5xJWvRMCZ4BD-iwD6yZ0UkiB6khUTfxWtRbUBOArYm5XBcQ2_VL257BlyzgBpFQutLA5BpLXAJUQFe9cdHUp-2A4NRZNMiH7xk';

const List<ColorLessonMetadata> _colorSeeds = [
  ColorLessonMetadata(
    lessonId: 'colors-red',
    displayName: 'Ruby Red',
    title: 'Ruby Red',
    subtitle: 'Sparkle like cherries.',
    description: 'Spot crimson treasures and shout RED with pride.',
    heroImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBg41oHr7KbxU6rXatEh6swU-RMW5WSWDG1bScUyNkyOci1MQNTnV3zECR0PNkEyWGy618DlQ8AvUpSOqVgXdO50V3YBGYjc91Uf5Lhba5ROW0cK9OYTW6bCCQGLoettUm06dcgaGJbj-fVDYcK7mE6ZR1d-Hc6EyLyY207Fs8XCP-9gsSSjvyTY49GBLQW7TwsOl1cUVVmKirx2FwauTl0AKHTKQr9iVtMNoA3tOPfOg8MDlUT73IZQ40fuOfmYs9IaWcI0c4lPIE',
    gradientStart: Color(0xFFFF5252),
    gradientEnd: Color(0xFFD32F2F),
    accentColor: Color(0xFFB71C1C),
    badgeColor: Color(0xFFFACC15),
    order: 0,
    defaultStatus: LessonStatus.ready,
    xpReward: 120,
    voiceLine: 'Red like apples and ladybugs!',
    gallery: [
      ColorGalleryItem(
        label: 'Apple',
        imageUrl: _redAppleImage,
        backgroundColor: Color(0xFFFFE5E5),
        borderColor: Color(0xFFFCA5A5),
      ),
      ColorGalleryItem(
        label: 'Paint Swirl',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuD51QRN9PKPGGUSWiY7C5fz1Tk2lonO9h5e10D63yDmJ7eUpsIn3Wg7rW_N3NauYedwGSDjtiOySREbAWx-7Hl1pULHjmxa9pbo6Aa3xrYPEBNWnpXOY6n_6o4nZR8YULPRefn9Yj3Nrv-RX6MRcJt6Ft0497PZopClwgKu3Ug3I9mVnO6v2BPg25LzETSE8R1_y7j0RsKeNR6t9l9nMqAghErSkVrU1dhdDZ1FkezprlQK6wMoM_JiLKnNkVdUnYUFvU0Kg7010Ew',
        backgroundColor: Color(0xFFFFCDD2),
        borderColor: Color(0xFFEF4444),
      ),
    ],
    activityPrompt: 'Can you find the red apple?',
    activityOptions: [
      ColorActivityOption(
        id: 'red-apple',
        label: 'Red apple',
        imageUrl: _redAppleImage,
        accentColor: Color(0xFFEF4444),
        isCorrect: true,
      ),
      ColorActivityOption(
        id: 'blue-fish',
        label: 'Blue fish',
        imageUrl: _blueFishImage,
        accentColor: Color(0xFF3B82F6),
        isCorrect: false,
      ),
      ColorActivityOption(
        id: 'green-leaf',
        label: 'Green leaf',
        imageUrl: _greenLeafImage,
        accentColor: Color(0xFF22C55E),
        isCorrect: false,
      ),
    ],
    completionTitle: 'Color Wizard!',
    completionSubtitle: 'Red magic unlocked',
    completionMascotUrl: _paletteCelebrationImage,
  ),
  ColorLessonMetadata(
    lessonId: 'colors-blue',
    displayName: 'Ocean Blue',
    title: 'Ocean Blue',
    subtitle: 'Calm like cool waves.',
    description: 'Swim through blue stories and hum watery tunes.',
    heroImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBuEE7iPZxNPfpfibqW15CocAmYLz9BR6NDh4tF99TskNk6T43XWcqW7NLnysc9ipPM3lGoX6pweylmlu-tYPBQ7Zl0p0xQXVDMrcjZMiGBkQ_y61pGRXpkMEsH9AmbjnIgiEGQnCwzpL7HqihfGvIM9rc7vq6d4f0OMOAMay55Pp82ZI1qmNGOO8J3Xiu5rV66op8YuB-FMR_4A-EoCIVSeOFUzspTxz8oFMWH6p1Bc_h1OExYAaq5NbBAeA78YkfNq8VtSv5Ldrk',
    gradientStart: Color(0xFF42A5F5),
    gradientEnd: Color(0xFF1976D2),
    accentColor: Color(0xFF0C4A95),
    badgeColor: Color(0xFFBAE6FD),
    order: 1,
    defaultStatus: LessonStatus.start,
    xpReward: 110,
    voiceLine: 'Blue like oceans and brave skies.',
    gallery: [
      ColorGalleryItem(
        label: 'Splash',
        imageUrl: _blueFishImage,
        backgroundColor: Color(0xFFE0F2FE),
        borderColor: Color(0xFF38BDF8),
      ),
      ColorGalleryItem(
        label: 'Kite',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuApX6QCJhMk9ykfQ8YlXFkBOOtBTJtQi6_udKEziE1vki63XybobwMXdW2MW2EX9c2sD9hebDa2_AWs9vyhuLAUtGhw3eh0Sfq71wFKF2cYFTdMVfDKd9GZ8Yrzs0mEjWUEZekUyYtvj-FoCadPu3KRfHkIVtyFhE3qOvm3V_Kg9W_HXl6OCsYaoROJq_3Thf2-2uS5fe3syz_n9yVINDLRiMaJtynS6N_K8qX3BsxXkAa9gY7LcJtKTu5Yw6skzZj6IN5D6YRR1Jg',
        backgroundColor: Color(0xFFD1FAFF),
        borderColor: Color(0xFF0EA5E9),
      ),
    ],
    activityPrompt: 'Can you spot something blue?',
    activityOptions: [
      ColorActivityOption(
        id: 'red-apple',
        label: 'Red apple',
        imageUrl: _redAppleImage,
        accentColor: Color(0xFFEF4444),
        isCorrect: false,
      ),
      ColorActivityOption(
        id: 'blue-fish',
        label: 'Blue fish',
        imageUrl: _blueFishImage,
        accentColor: Color(0xFF3B82F6),
        isCorrect: true,
      ),
      ColorActivityOption(
        id: 'yellow-sun',
        label: 'Yellow sun',
        imageUrl: _yellowSunImage,
        accentColor: Color(0xFFFACC15),
        isCorrect: false,
      ),
    ],
    completionTitle: 'Wave Rider',
    completionSubtitle: 'Blue stories memorized',
    completionMascotUrl: _paletteCelebrationImage,
  ),
  ColorLessonMetadata(
    lessonId: 'colors-yellow',
    displayName: 'Sunny Yellow',
    title: 'Sunny Yellow',
    subtitle: 'Bright like giggles.',
    description: 'Dance with sunshine objects and clap for cheer.',
    heroImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuD8T6CxR4aEkRDzhwd-VnKDcgdMAW5oJeCK_Z_i2wfxll3e9P_8Tc4svlWg6NIkhLy55fxk0ywGLok3jfImTh5JldBOtSJPHUJMLd-UASKaD8KjoqtptNKzaBddQBlqf6eEd33HMwHwI6WAcj3OWhn5XZHZcJ2M5yyPc-tJa4fiRD2aXepbYhCjFBZy_twv6Db0OL4xdHPVmyJz_5P6m119ytyt6Ab16rMVRTo7NV31lwyQ2VNA8sLciupFC9Kmm1pvheAyOrYuafY',
    gradientStart: Color(0xFFFFD54F),
    gradientEnd: Color(0xFFFBC02D),
    accentColor: Color(0xFFA16207),
    badgeColor: Color(0xFFFDE68A),
    order: 2,
    defaultStatus: LessonStatus.locked,
    xpReward: 100,
    voiceLine: 'Yellow like sunshine and giggles.',
    gallery: [
      ColorGalleryItem(
        label: 'Sun',
        imageUrl: _yellowSunImage,
        backgroundColor: Color(0xFFFFF7D6),
        borderColor: Color(0xFFFCD34D),
      ),
      ColorGalleryItem(
        label: 'Banana',
        imageUrl: _bananaImage,
        backgroundColor: Color(0xFFFFF3C7),
        borderColor: Color(0xFFEAB308),
      ),
    ],
    activityPrompt: 'Choose the sunny yellow friend.',
    activityOptions: [
      ColorActivityOption(
        id: 'yellow-sun',
        label: 'Yellow sun',
        imageUrl: _yellowSunImage,
        accentColor: Color(0xFFFACC15),
        isCorrect: true,
      ),
      ColorActivityOption(
        id: 'blue-fish',
        label: 'Blue fish',
        imageUrl: _blueFishImage,
        accentColor: Color(0xFF3B82F6),
        isCorrect: false,
      ),
      ColorActivityOption(
        id: 'green-leaf',
        label: 'Green leaf',
        imageUrl: _greenLeafImage,
        accentColor: Color(0xFF22C55E),
        isCorrect: false,
      ),
    ],
    completionTitle: 'Sunny Champ',
    completionSubtitle: 'Bright moments collected',
    completionMascotUrl: _paletteCelebrationImage,
  ),
  ColorLessonMetadata(
    lessonId: 'colors-green',
    displayName: 'Leafy Green',
    title: 'Leafy Green',
    subtitle: 'Grow with nature.',
    description: 'Build leafy patterns and whisper calm words.',
    heroImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDQD2Qdu8A2P7wwLotXl9MoOrqGyZa9aqQolb0yNk3XFoxDsJ1U3nM4ybnBnr9XCOZljJYGNvpiO3H6kAss5ObeVcp0agQFVJLD-w-8Bz6o8lC3gSO3b17C0ubd2rDgoJO-tMjjzleVqFLd8mYhicGPoDGkUGZai0Y5NPX0ANndK-XzgLRyfADrHm-4PFqruFDH4nYbIvk2vh87-W2WwHxW4Iye8meAPXS4Cof5whbTZiIw8HG0SRv_JeZP7oLY4f140Kx9t890VLs',
    gradientStart: Color(0xFF81C784),
    gradientEnd: Color(0xFF388E3C),
    accentColor: Color(0xFF166534),
    badgeColor: Color(0xFFBBF7D0),
    order: 3,
    defaultStatus: LessonStatus.locked,
    xpReward: 110,
    voiceLine: 'Green like leaves and froggy jumps.',
    gallery: [
      ColorGalleryItem(
        label: 'Leaf',
        imageUrl: _greenLeafImage,
        backgroundColor: Color(0xFFE3FCEC),
        borderColor: Color(0xFF4ADE80),
      ),
      ColorGalleryItem(
        label: 'Turtle',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC9U5DnI3AKai2UrHsXbZoW1wZ7f5ymq-AMxxZlmEf9YKfemmSLAV1-hHHzv13AlqQv0N8m5N9sYYlG2_3gsHL7G6cxHQTWd6c9oxuKVVSwYRQJ4QW2_9JAA99U5Fjp5zpw1DNtlcC2yXRPUrQ9Yacm8rjtG1Av4dvgB09x_gXXPx0mbrl6pHu-KYd_gdKpq1KOgDO5vFbzvOeQA0ynj-YT_NF2XGHyr7S1vrm7wK8iW3kG7KBYDqnxcUK1jc4mAX8CoOLnQ4hdyDk',
        backgroundColor: Color(0xFFD1FAE5),
        borderColor: Color(0xFF34D399),
      ),
    ],
    activityPrompt: 'Which friend is leafy green?',
    activityOptions: [
      ColorActivityOption(
        id: 'green-leaf',
        label: 'Green leaf',
        imageUrl: _greenLeafImage,
        accentColor: Color(0xFF22C55E),
        isCorrect: true,
      ),
      ColorActivityOption(
        id: 'red-apple',
        label: 'Red apple',
        imageUrl: _redAppleImage,
        accentColor: Color(0xFFEF4444),
        isCorrect: false,
      ),
      ColorActivityOption(
        id: 'orange-fruit',
        label: 'Orange fruit',
        imageUrl: _orangeFruitImage,
        accentColor: Color(0xFFF97316),
        isCorrect: false,
      ),
    ],
    completionTitle: 'Garden Guardian',
    completionSubtitle: 'Green wonders unlocked',
    completionMascotUrl: _paletteCelebrationImage,
  ),
  ColorLessonMetadata(
    lessonId: 'colors-orange',
    displayName: 'Juicy Orange',
    title: 'Juicy Orange',
    subtitle: 'Bursting with zest.',
    description: 'Bounce between oranges, tigers, and sunsets.',
    heroImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBEf12QNW83ZfKsgFsL_URZnZvZ7GLZWW7qUrDRW9Td41ddSaM8Aso-nyD02TMffRRaIKMtnxX_VwJnqqU_GTmMotqW5adXchNST-aFfBpQWI7tQw2lgYbOzgVBF2HgGfmi7rYBM8DVRygwXmSUkO0zZdzI_d8Lpk-g0LI-JxKuILNk2kBEMMF0AC85mKQwKLxFNe4DgET_pyEyN6-r-MP6LrTYRpg41Gh90gUxcT66lXxobs5dzlgO7Yo6URNM1miavGRsgnRkChM',
    gradientStart: Color(0xFFFFB74D),
    gradientEnd: Color(0xFFF57C00),
    accentColor: Color(0xFF9A3412),
    badgeColor: Color(0xFFFCD34D),
    order: 4,
    defaultStatus: LessonStatus.locked,
    xpReward: 115,
    voiceLine: 'Orange like sunsets and sweet treats.',
    gallery: [
      ColorGalleryItem(
        label: 'Orange',
        imageUrl: _orangeFruitImage,
        backgroundColor: Color(0xFFFFF4E5),
        borderColor: Color(0xFFF97316),
      ),
      ColorGalleryItem(
        label: 'Tiger',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCI_0R0hOC3FT_PIj5fasYyAxYsdVY62DYwE6CY9NGJB9TSV0wCJ1l5zVRjENG6h1DKf6ipZcJSteM7oPJRiFG-PZ7XkV0cQSrX6-Jn1lHPg8-FIGdZIr05nTk1GqQGfuwGwMiT_XRD_sal1RIPa80Mf3Bb5Q12JuxN2d17ewVSHPCi4bTBrM1grOD45pRFM_dCGVNEdgU3U4uiDKhPXhgtP5mL_No0Qbar3XbqPUOvPcXRVYgg69CXE0vi3S1DJ8kPxOGv_Bc2XtA',
        backgroundColor: Color(0xFFFFEDD5),
        borderColor: Color(0xFFFB923C),
      ),
    ],
    activityPrompt: 'Tap the juicy orange buddy.',
    activityOptions: [
      ColorActivityOption(
        id: 'orange-fruit',
        label: 'Orange fruit',
        imageUrl: _orangeFruitImage,
        accentColor: Color(0xFFF97316),
        isCorrect: true,
      ),
      ColorActivityOption(
        id: 'yellow-sun',
        label: 'Yellow sun',
        imageUrl: _yellowSunImage,
        accentColor: Color(0xFFFACC15),
        isCorrect: false,
      ),
      ColorActivityOption(
        id: 'blue-fish',
        label: 'Blue fish',
        imageUrl: _blueFishImage,
        accentColor: Color(0xFF3B82F6),
        isCorrect: false,
      ),
    ],
    completionTitle: 'Sunset Star',
    completionSubtitle: 'Orange adventures finished',
    completionMascotUrl: _paletteCelebrationImage,
  ),
];
