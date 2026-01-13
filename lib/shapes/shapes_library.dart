import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/progress_record.dart';

class ShapesOverviewContent {
  const ShapesOverviewContent({
    required this.title,
    required this.tagline,
    required this.encouragement,
    required this.heroImageUrl,
    required this.ctaLabel,
    required this.progressLabel,
    required this.progressCaption,
    required this.topicLabel,
  });

  final String title;
  final String tagline;
  final String encouragement;
  final String heroImageUrl;
  final String ctaLabel;
  final String progressLabel;
  final String progressCaption;
  final String topicLabel;
}

class ShapeGalleryItem {
  const ShapeGalleryItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final Color backgroundColor;
  final Color borderColor;
}

class ShapeActivityOption {
  const ShapeActivityOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.isCorrect,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final bool isCorrect;
}

class ShapeLessonMetadata {
  const ShapeLessonMetadata({
    required this.lessonId,
    required this.title,
    required this.listDescription,
    required this.heroStatement,
    required this.highlightLabel,
    required this.heroDescription,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.cardGradientStart,
    required this.cardGradientEnd,
    required this.accentColor,
    required this.defaultStatus,
    required this.order,
    required this.gallery,
    required this.activityPrompt,
    required this.activityOptions,
    required this.completionTitle,
    required this.completionSubtitle,
    required this.completionIcon,
    required this.totalDiscoverySteps,
  });

  final String lessonId;
  final String title;
  final String listDescription;
  final String heroStatement;
  final String highlightLabel;
  final String heroDescription;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color cardGradientStart;
  final Color cardGradientEnd;
  final Color accentColor;
  final LessonStatus defaultStatus;
  final int order;
  final List<ShapeGalleryItem> gallery;
  final String activityPrompt;
  final List<ShapeActivityOption> activityOptions;
  final String completionTitle;
  final String completionSubtitle;
  final IconData completionIcon;
  final int totalDiscoverySteps;

  String get quizId => 'quiz-${lessonId.replaceAll('-', '_')}';
}

class ShapeLessonEntry {
  const ShapeLessonEntry({
    required this.metadata,
    required this.status,
    required this.progress,
  });

  final ShapeLessonMetadata metadata;
  final LessonPlayStatus status;
  final ProgressRecord? progress;

  bool get isLocked => status == LessonPlayStatus.locked;
  bool get isCompleted => status == LessonPlayStatus.completed;
  bool get isInProgress => status == LessonPlayStatus.inProgress;

  double progressRatio() {
    if (isCompleted) return 1;
    final total = metadata.totalDiscoverySteps;
    if (total == 0) {
      return progress == null ? 0 : 1;
    }
    final best = progress?.bestScore ?? 0;
    return (best / total).clamp(0, 1);
  }
}

class ShapesLibrary {
  ShapesLibrary._();

  static const ShapesOverviewContent overview = ShapesOverviewContent(
    title: 'Shapes',
    tagline: "Let's find the shapes!",
    encouragement: 'Keep learning to unlock new friends.',
    heroImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB5vi90HjRBwmW2mEp66CSa3cjqeUUkraW_hOaFKtjk9l_kNriLGlDmzz45-TED1f1by8UVnRiLstLa3nK5lLXcSEBONABTFab-UKORpj0nDk0Dh-4D80u1sM9Mde118SHCn3r6xQ1jcbNkrHvJyFnvAU87E_TWX4El-PyBx0gdwMsn2r8vsskFB5Rmt4xiAq92gJcMv1M775duOjjseIH1Jos3PI3Wb6FqxQ1FH3UpA51a4VNlKTNySrC1NjOeIqeje8Ncz5M25Ms',
    ctaLabel: 'Start Learning',
    progressLabel: 'Shapes Mastered',
    progressCaption: 'Every new shape earns a badge.',
    topicLabel: 'Shapes',
  );

  static final List<ShapeLessonMetadata> lessons =
      List<ShapeLessonMetadata>.unmodifiable(_shapeSeeds);

  static final Map<String, ShapeLessonMetadata> _byLessonId = {
    for (final lesson in lessons) lesson.lessonId: lesson,
  };

  static ShapeLessonMetadata? byLessonId(String lessonId) {
    return _byLessonId[lessonId];
  }

  static List<ShapeLessonEntry> buildEntries(
    Map<String, ProgressRecord> progress,
  ) {
    final entries = <ShapeLessonEntry>[];
    for (final metadata in lessons) {
      final record = progress[metadata.lessonId];
      final status = _inferStatus(
        record,
        entries.isEmpty ? null : entries.last,
        metadata,
      );
      entries.add(
        ShapeLessonEntry(
          metadata: metadata,
          status: status,
          progress: record,
        ),
      );
    }
    return entries;
  }

  static ShapeLessonEntry? nextPlayable(List<ShapeLessonEntry> entries) {
    for (final entry in entries) {
      if (entry.status != LessonPlayStatus.completed) {
        return entry;
      }
    }
    return null;
  }

  static LessonPlayStatus _inferStatus(
    ProgressRecord? record,
    ShapeLessonEntry? previous,
    ShapeLessonMetadata metadata,
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
            categoryId: 'shapes',
            title: metadata.title,
            description: metadata.listDescription,
            illustration: LessonIllustration.shapes,
            defaultStatus: metadata.defaultStatus,
            order: metadata.order,
            content: metadata.heroDescription,
            durationMinutes: 5 + metadata.order,
            quizId: metadata.quizId,
          ),
        )
        .toList(growable: false),
  );
}

const List<ShapeLessonMetadata> _shapeSeeds = [
  ShapeLessonMetadata(
    lessonId: 'shapes-circle',
    title: 'Circle',
    listDescription: 'Round and ready',
    heroStatement: 'The Circle is [highlight] all around!',
    highlightLabel: 'round',
    heroDescription: 'Circles roll smoothly and never have corners.',
    icon: Icons.circle,
    iconColor: Colors.white,
    iconBackground: Color(0xFFF472B6),
    cardGradientStart: Color(0xFFFEC6D7),
    cardGradientEnd: Color(0xFFF9739B),
    accentColor: Color(0xFFDB2777),
    defaultStatus: LessonStatus.ready,
    order: 0,
    gallery: [
      ShapeGalleryItem(
        title: 'Donut',
        subtitle: 'Sweet and circular',
        imageUrl:
            'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=600&q=80',
        backgroundColor: Color(0xFFFFF1F5),
        borderColor: Color(0xFFFBCFE8),
      ),
      ShapeGalleryItem(
        title: 'Ferris Wheel',
        subtitle: 'Spinning circle ride',
        imageUrl:
            'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?auto=format&fit=crop&w=600&q=80',
        backgroundColor: Color(0xFFFEE2E2),
        borderColor: Color(0xFFFCA5A5),
      ),
    ],
    activityPrompt: 'Which friend is a perfect circle?',
    activityOptions: [
      ShapeActivityOption(
        id: 'circle',
        label: 'Circle',
        icon: Icons.circle,
        backgroundColor: Color(0xFFF472B6),
        isCorrect: true,
      ),
      ShapeActivityOption(
        id: 'square',
        label: 'Square',
        icon: Icons.crop_square,
        backgroundColor: Color(0xFF38BDF8),
        isCorrect: false,
      ),
      ShapeActivityOption(
        id: 'triangle',
        label: 'Triangle',
        icon: Icons.change_history,
        backgroundColor: Color(0xFF34D399),
        isCorrect: false,
      ),
    ],
    completionTitle: 'Circle Champ',
    completionSubtitle: 'You rolled through every corner!',
    completionIcon: Icons.circle,
    totalDiscoverySteps: 4,
  ),
  ShapeLessonMetadata(
    lessonId: 'shapes-square',
    title: 'Square',
    listDescription: 'Four equal sides',
    heroStatement: 'A Square stands [highlight] and strong.',
    highlightLabel: 'even',
    heroDescription: 'Squares love stacking and building tall towns.',
    icon: Icons.crop_square,
    iconColor: Colors.white,
    iconBackground: Color(0xFF38BDF8),
    cardGradientStart: Color(0xFFE0F2FE),
    cardGradientEnd: Color(0xFF60A5FA),
    accentColor: Color(0xFF1D4ED8),
    defaultStatus: LessonStatus.start,
    order: 1,
    gallery: [
      ShapeGalleryItem(
        title: 'City Windows',
        subtitle: 'Squares make strong towers',
        imageUrl:
            'https://images.unsplash.com/photo-1470093851219-69951fcbb533?auto=format&fit=crop&w=600&q=80',
        backgroundColor: Color(0xFFE0F2FE),
        borderColor: Color(0xFF38BDF8),
      ),
      ShapeGalleryItem(
        title: 'Checkerboard',
        subtitle: 'Games use squares',
        imageUrl:
            'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=600&q=80',
        backgroundColor: Color(0xFFDBEAFE),
        borderColor: Color(0xFF60A5FA),
      ),
    ],
    activityPrompt: 'Find the shape with four equal sides.',
    activityOptions: [
      ShapeActivityOption(
        id: 'triangle',
        label: 'Triangle',
        icon: Icons.change_history,
        backgroundColor: Color(0xFF34D399),
        isCorrect: false,
      ),
      ShapeActivityOption(
        id: 'square',
        label: 'Square',
        icon: Icons.crop_square,
        backgroundColor: Color(0xFF38BDF8),
        isCorrect: true,
      ),
      ShapeActivityOption(
        id: 'star',
        label: 'Star',
        icon: Icons.grade,
        backgroundColor: Color(0xFFFACC15),
        isCorrect: false,
      ),
    ],
    completionTitle: 'Square Builder',
    completionSubtitle: 'Everything lines up perfectly.',
    completionIcon: Icons.crop_square,
    totalDiscoverySteps: 6,
  ),
  ShapeLessonMetadata(
    lessonId: 'shapes-triangle',
    title: 'Triangle',
    listDescription: 'Pointy paths',
    heroStatement: 'The Triangle has [highlight] brave points.',
    highlightLabel: 'three',
    heroDescription: 'Triangles climb mountains and fly kites.',
    icon: Icons.change_history,
    iconColor: Colors.white,
    iconBackground: Color(0xFF34D399),
    cardGradientStart: Color(0xFFBBF7D0),
    cardGradientEnd: Color(0xFF4ADE80),
    accentColor: Color(0xFF15803D),
    defaultStatus: LessonStatus.locked,
    order: 2,
    gallery: [
      ShapeGalleryItem(
        title: 'Mountains',
        subtitle: 'Nature loves triangles',
        imageUrl:
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
        backgroundColor: Color(0xFFEFFDF6),
        borderColor: Color(0xFF4ADE80),
      ),
      ShapeGalleryItem(
        title: 'Kites',
        subtitle: 'Fly triangle tails',
        imageUrl:
            'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=600&q=80',
        backgroundColor: Color(0xFFD1FAE5),
        borderColor: Color(0xFF34D399),
      ),
    ],
    activityPrompt: 'Point to the triangle buddy.',
    activityOptions: [
      ShapeActivityOption(
        id: 'circle',
        label: 'Circle',
        icon: Icons.circle,
        backgroundColor: Color(0xFFF472B6),
        isCorrect: false,
      ),
      ShapeActivityOption(
        id: 'triangle',
        label: 'Triangle',
        icon: Icons.change_history,
        backgroundColor: Color(0xFF34D399),
        isCorrect: true,
      ),
      ShapeActivityOption(
        id: 'heart',
        label: 'Heart',
        icon: Icons.favorite,
        backgroundColor: Color(0xFFFB7185),
        isCorrect: false,
      ),
    ],
    completionTitle: 'Peak Finder',
    completionSubtitle: 'You climbed every point.',
    completionIcon: Icons.change_history,
    totalDiscoverySteps: 8,
  ),
  ShapeLessonMetadata(
    lessonId: 'shapes-star',
    title: 'Star',
    listDescription: 'Shiny hero',
    heroStatement: 'The Star sparkles with [highlight] bright tips.',
    highlightLabel: 'five',
    heroDescription: 'Stars twinkle in the sky and celebrate wins.',
    icon: Icons.grade,
    iconColor: Color(0xFF7F0DF2),
    iconBackground: Color(0xFFFACC15),
    cardGradientStart: Color(0xFFFFF1B8),
    cardGradientEnd: Color(0xFFFACC15),
    accentColor: Color(0xFFCA8A04),
    defaultStatus: LessonStatus.locked,
    order: 3,
    gallery: [
      ShapeGalleryItem(
        title: 'Night Sky',
        subtitle: 'Constellations everywhere',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCQyPv5PWc3mbHmwaolNd8xjUGeNcbde1NFrQtKPosUCB7oHo2G-JsHNPZPr7jZaIH6wFIWJKy9SQzG9c5yUU9LLAgshEi_OveExvEnY7IBkxovBhkXiZuCclI2buTQ69vaIxhv2qN797HC37COYbrApN54jog7elQYGPbH__N3MK9qNg5Daskw5Mqey6_OqB3B2Oq6Y-d5J_RYZkD__BC1NmAeDSzr3pU_LQlBWYtr9RiylCWQNGsRkYjN5_-Xj2zv9nMHXdd8h9s',
        backgroundColor: Color(0xFFFFF7CD),
        borderColor: Color(0xFFFACC15),
      ),
      ShapeGalleryItem(
        title: 'Decorations',
        subtitle: 'Celebrate with stars',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDWNXU_IjMcx9UUEjqZq283I11zKV5kgGA2VjudeODQARchwxip_Kkjdqs8VJZVxq2n--Dcc1vV_498PyVAChegz_K_YXFN99G1Un2sluej2DFJurBUUqhj0I3MI5XQRGl7cAai0c_8E23-cCfzr8BdPwLVdcRV_E0cyS0CU_y_dudEHZ3o3de6EkoZY0lT_8eOIooLCV0TYw0HCQSA_l72mYHb1WiPjuoBbFwppwZKLhyDMIlYM6z98NuFcTmRememhqfOsNo4Q1s',
        backgroundColor: Color(0xFFFFF9C4),
        borderColor: Color(0xFFFDE68A),
      ),
    ],
    activityPrompt: 'Can you spot the shining star?',
    activityOptions: [
      ShapeActivityOption(
        id: 'square',
        label: 'Square',
        icon: Icons.crop_square,
        backgroundColor: Color(0xFF38BDF8),
        isCorrect: false,
      ),
      ShapeActivityOption(
        id: 'star',
        label: 'Star',
        icon: Icons.grade,
        backgroundColor: Color(0xFFFACC15),
        isCorrect: true,
      ),
      ShapeActivityOption(
        id: 'circle',
        label: 'Circle',
        icon: Icons.circle,
        backgroundColor: Color(0xFFF472B6),
        isCorrect: false,
      ),
    ],
    completionTitle: 'Constellation Captain',
    completionSubtitle: 'You lit up the galaxy.',
    completionIcon: Icons.grade,
    totalDiscoverySteps: 10,
  ),
  ShapeLessonMetadata(
    lessonId: 'shapes-heart',
    title: 'Heart',
    listDescription: 'Share the love',
    heroStatement: 'The Heart beats with [highlight] kindness.',
    highlightLabel: 'warm',
    heroDescription: 'Hearts show care, hugs, and big feelings.',
    icon: Icons.favorite,
    iconColor: Colors.white,
    iconBackground: Color(0xFFFB7185),
    cardGradientStart: Color(0xFFFECACA),
    cardGradientEnd: Color(0xFFF87171),
    accentColor: Color(0xFFBE123C),
    defaultStatus: LessonStatus.locked,
    order: 4,
    gallery: [
      ShapeGalleryItem(
        title: 'Cards',
        subtitle: 'Hearts in notes',
        imageUrl:
            'https://images.unsplash.com/photo-1529257414770-1960a06b7b1a?auto=format&fit=crop&w=600&q=80',
        backgroundColor: Color(0xFFFFF1F2),
        borderColor: Color(0xFFFDA4AF),
      ),
      ShapeGalleryItem(
        title: 'Lights',
        subtitle: 'Glowing hearts at night',
        imageUrl:
            'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?auto=format&fit=crop&w=600&q=80',
        backgroundColor: Color(0xFFFDE2E4),
        borderColor: Color(0xFFFB7185),
      ),
    ],
    activityPrompt: 'Touch the heart shape.',
    activityOptions: [
      ShapeActivityOption(
        id: 'heart',
        label: 'Heart',
        icon: Icons.favorite,
        backgroundColor: Color(0xFFFB7185),
        isCorrect: true,
      ),
      ShapeActivityOption(
        id: 'triangle',
        label: 'Triangle',
        icon: Icons.change_history,
        backgroundColor: Color(0xFF34D399),
        isCorrect: false,
      ),
      ShapeActivityOption(
        id: 'star',
        label: 'Star',
        icon: Icons.grade,
        backgroundColor: Color(0xFFFACC15),
        isCorrect: false,
      ),
    ],
    completionTitle: 'Heart Hero',
    completionSubtitle: 'You shared every smile.',
    completionIcon: Icons.favorite,
    totalDiscoverySteps: 12,
  ),
];
