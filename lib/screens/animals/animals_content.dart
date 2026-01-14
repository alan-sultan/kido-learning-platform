import 'package:flutter/material.dart';

import '../../animals/animals_library.dart';
import '../../models/learning_category.dart';
import '../../models/lesson.dart';
import '../../models/lesson_experience.dart';
import '../../models/progress_record.dart';
import 'animals_theme.dart';

class AnimalLessonEntryData {
  const AnimalLessonEntryData({
    required this.experience,
    required this.theme,
  });

  final LessonExperience experience;
  final AnimalLessonTheme theme;

  Lesson get lesson => experience.lesson;
  LessonPlayStatus get status => experience.status;
  bool get isLocked => experience.isLocked;
  bool get isCompleted => experience.isCompleted;
  bool get isInProgress => experience.isInProgress;
  ProgressRecord? get progress => experience.progress;

  double progressRatio() {
    if (isCompleted) return 1;
    final total = theme.totalDiscoverySteps;
    if (total <= 0) {
      return progress == null ? 0 : 1;
    }
    final best = progress?.bestScore ?? 0;
    final ratio = best / total;
    return ratio.clamp(0, 1);
  }
}

class AnimalLessonTheme {
  const AnimalLessonTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.cardImageUrl,
    required this.soundLabel,
    required this.totalDiscoverySteps,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final String cardImageUrl;
  final String soundLabel;
  final int totalDiscoverySteps;

  factory AnimalLessonTheme.fromLesson(Lesson lesson) {
    final metadata = AnimalsLibrary.byLessonId(lesson.id);
    final themeExtra = lesson.extra['theme'];

    final primary = _colorFromHex(
      themeExtra is Map<String, dynamic> ? themeExtra['primaryColor'] : null,
      metadata?.primaryColor ?? AnimalsTheme.primary,
    );
    final secondary = _colorFromHex(
      themeExtra is Map<String, dynamic> ? themeExtra['secondaryColor'] : null,
      metadata?.secondaryColor ?? AnimalsTheme.primary.withValues(alpha: 0.6),
    );
    final cardImageUrl = _string(
          themeExtra is Map<String, dynamic>
              ? themeExtra['cardImageUrl']
              : lesson.extra['cardImageUrl'],
        ) ??
        metadata?.cardImageUrl ??
        '';
    final soundLabel = _string(
          themeExtra is Map<String, dynamic>
              ? themeExtra['soundLabel']
              : lesson.extra['soundLabel'],
        ) ??
        metadata?.soundLabel ??
        'Roar';
    final totalSteps = _int(
          themeExtra is Map<String, dynamic>
              ? themeExtra['totalDiscoverySteps']
              : lesson.extra['totalDiscoverySteps'],
        ) ??
        metadata?.totalDiscoverySteps ??
        5;

    return AnimalLessonTheme(
      primaryColor: primary,
      secondaryColor: secondary,
      cardImageUrl: cardImageUrl,
      soundLabel: soundLabel,
      totalDiscoverySteps: totalSteps,
    );
  }
}

class AnimalOverviewContentData {
  const AnimalOverviewContentData({
    required this.title,
    required this.tagline,
    required this.encouragement,
    required this.heroImageUrl,
    required this.ctaLabel,
    required this.progressLabel,
    required this.topicLabel,
  });

  final String title;
  final String tagline;
  final String encouragement;
  final String heroImageUrl;
  final String ctaLabel;
  final String progressLabel;
  final String topicLabel;

  factory AnimalOverviewContentData.fallback() {
    const overview = AnimalsLibrary.overview;
    return AnimalOverviewContentData(
      title: overview.title,
      tagline: overview.tagline,
      encouragement: overview.encouragement,
      heroImageUrl: overview.heroImageUrl,
      ctaLabel: overview.ctaLabel,
      progressLabel: overview.progressLabel,
      topicLabel: overview.topicLabel,
    );
  }

  factory AnimalOverviewContentData.fromCategory(LearningCategory category) {
    const overview = AnimalsLibrary.overview;
    return AnimalOverviewContentData(
      title: category.title.isNotEmpty ? category.title : overview.title,
      tagline:
          category.subtitle.isNotEmpty ? category.subtitle : overview.tagline,
      encouragement: overview.encouragement,
      heroImageUrl: category.heroImageUrl.isNotEmpty
          ? category.heroImageUrl
          : overview.heroImageUrl,
      ctaLabel: overview.ctaLabel,
      progressLabel: overview.progressLabel,
      topicLabel:
          category.topic.isNotEmpty ? category.topic : overview.topicLabel,
    );
  }
}

class AnimalLessonContentData {
  const AnimalLessonContentData({
    required this.lesson,
    required this.theme,
    required this.heroHeadline,
    required this.heroDescription,
    required this.heroImageUrl,
    required this.traits,
    required this.activityPrompt,
    required this.activityOptions,
    required this.completion,
    required this.badges,
    required this.totalDiscoverySteps,
  });

  final Lesson lesson;
  final AnimalLessonTheme theme;
  final String heroHeadline;
  final String heroDescription;
  final String heroImageUrl;
  final List<AnimalTraitContent> traits;
  final String activityPrompt;
  final List<AnimalActivityOptionContent> activityOptions;
  final AnimalCompletionContentData completion;
  final List<AnimalBadgeRewardContent> badges;
  final int totalDiscoverySteps;

  factory AnimalLessonContentData.fromLesson(Lesson lesson) {
    final extra = lesson.extra;
    final fallback = AnimalsLibrary.byLessonId(lesson.id);
    final theme = AnimalLessonTheme.fromLesson(lesson);

    final heroHeadline = _string(extra['heroHeadline']) ??
        fallback?.heroHeadline ??
        lesson.title;
    final heroDescription = _string(extra['heroDescription']) ??
        fallback?.heroDescription ??
        lesson.description;
    final heroImageUrl =
        _string(extra['heroImageUrl']) ?? fallback?.heroImageUrl ?? '';

    final traits = _parseTraitList(extra['traits']) ??
        (fallback?.traits ?? const <AnimalTraitCard>[])
            .map(_traitFromMetadata)
            .toList();

    final activityPrompt = _string(extra['activityPrompt']) ??
        fallback?.activityPrompt ??
        'Ready for an adventure?';

    final activityOptions = _parseActivityOptions(extra['activityOptions']) ??
        (fallback?.activityOptions ?? const <AnimalActivityOption>[])
            .map(_activityFromMetadata)
            .toList();

    final completion = AnimalCompletionContentData(
      title: _string(extra['completionTitle']) ??
          fallback?.completionTitle ??
          'Great job!',
      subtitle: _string(extra['completionSubtitle']) ??
          fallback?.completionSubtitle ??
          'You made a new friend.',
      mascotUrl: _string(extra['completionMascotUrl']) ??
          fallback?.completionMascotUrl ??
          theme.cardImageUrl,
    );

    final badges = _parseBadges(extra['badges']) ??
        (fallback?.badges ?? const <AnimalBadgeReward>[])
            .map(_badgeFromMetadata)
            .toList();

    final totalSteps =
        _int(extra['totalDiscoverySteps']) ?? theme.totalDiscoverySteps;

    return AnimalLessonContentData(
      lesson: lesson,
      theme: theme,
      heroHeadline: heroHeadline,
      heroDescription: heroDescription,
      heroImageUrl: heroImageUrl.isNotEmpty ? heroImageUrl : theme.cardImageUrl,
      traits: traits,
      activityPrompt: activityPrompt,
      activityOptions: activityOptions,
      completion: completion,
      badges: badges,
      totalDiscoverySteps: totalSteps,
    );
  }
}

class AnimalTraitContent {
  const AnimalTraitContent({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.borderColor,
    required this.badgeColor,
  });

  final String title;
  final String description;
  final String imageUrl;
  final Color borderColor;
  final Color badgeColor;
}

class AnimalActivityOptionContent {
  const AnimalActivityOptionContent({
    required this.id,
    required this.label,
    required this.imageUrl,
    required this.caption,
    required this.isCorrect,
  });

  final String id;
  final String label;
  final String imageUrl;
  final String caption;
  final bool isCorrect;
}

class AnimalBadgeRewardContent {
  const AnimalBadgeRewardContent({
    required this.label,
    required this.icon,
    required this.startColor,
    required this.endColor,
  });

  final String label;
  final IconData icon;
  final Color startColor;
  final Color endColor;
}

class AnimalCompletionContentData {
  const AnimalCompletionContentData({
    required this.title,
    required this.subtitle,
    required this.mascotUrl,
  });

  final String title;
  final String subtitle;
  final String mascotUrl;
}

String? _string(dynamic value) {
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return null;
}

int? _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

Color _colorFromHex(dynamic value, Color fallback) {
  if (value is int) {
    return Color(value);
  }
  if (value is String) {
    final sanitized = value.replaceAll('#', '');
    final parsed = int.tryParse(sanitized, radix: 16);
    if (parsed != null) {
      if (sanitized.length <= 6) {
        return Color(0xFF000000 | parsed);
      }
      return Color(parsed);
    }
  }
  return fallback;
}

List<AnimalTraitContent>? _parseTraitList(dynamic raw) {
  if (raw is List) {
    return raw.whereType<Map>().map((map) {
      return AnimalTraitContent(
        title: _string(map['title']) ?? 'Amazing feature',
        description: _string(map['description']) ?? 'This buddy is awesome!',
        imageUrl: _string(map['imageUrl']) ?? '',
        borderColor: _colorFromHex(
          map['borderColor'],
          AnimalsTheme.accentLeaf,
        ),
        badgeColor: _colorFromHex(
          map['badgeColor'],
          AnimalsTheme.accentSun,
        ),
      );
    }).toList();
  }
  return null;
}

AnimalTraitContent _traitFromMetadata(AnimalTraitCard trait) {
  return AnimalTraitContent(
    title: trait.title,
    description: trait.description,
    imageUrl: trait.imageUrl,
    borderColor: trait.borderColor,
    badgeColor: trait.badgeColor,
  );
}

List<AnimalActivityOptionContent>? _parseActivityOptions(dynamic raw) {
  if (raw is List) {
    return raw.whereType<Map>().map((map) {
      return AnimalActivityOptionContent(
        id: _string(map['id']) ?? UniqueKey().toString(),
        label: _string(map['label']) ?? 'Friend',
        imageUrl: _string(map['imageUrl']) ?? '',
        caption: _string(map['caption']) ?? '',
        isCorrect: map['isCorrect'] == true,
      );
    }).toList();
  }
  return null;
}

AnimalActivityOptionContent _activityFromMetadata(
  AnimalActivityOption option,
) {
  return AnimalActivityOptionContent(
    id: option.id,
    label: option.label,
    imageUrl: option.imageUrl,
    caption: option.caption,
    isCorrect: option.isCorrect,
  );
}

List<AnimalBadgeRewardContent>? _parseBadges(dynamic raw) {
  if (raw is List) {
    return raw.whereType<Map>().map((map) {
      return AnimalBadgeRewardContent(
        label: _string(map['label']) ?? 'Badge',
        icon: _iconFromName(map['icon']) ?? Icons.emoji_events_rounded,
        startColor: _colorFromHex(
          map['startColor'],
          AnimalsTheme.primary,
        ),
        endColor: _colorFromHex(
          map['endColor'],
          AnimalsTheme.accentSun,
        ),
      );
    }).toList();
  }
  return null;
}

AnimalBadgeRewardContent _badgeFromMetadata(AnimalBadgeReward badge) {
  return AnimalBadgeRewardContent(
    label: badge.label,
    icon: badge.icon,
    startColor: badge.startColor,
    endColor: badge.endColor,
  );
}

IconData? _iconFromName(dynamic value) {
  final name = _string(value);
  switch (name) {
    case 'star':
      return Icons.star_rounded;
    case 'trophy':
      return Icons.emoji_events_rounded;
    case 'medal':
      return Icons.military_tech_rounded;
    default:
      return null;
  }
}
