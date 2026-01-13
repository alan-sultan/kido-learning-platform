import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/progress_record.dart';

class NumbersOverviewContent {
  const NumbersOverviewContent({
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

class NumberIllustrationData {
  const NumberIllustrationData({
    required this.alt,
    required this.imageUrl,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String alt;
  final String imageUrl;
  final Color backgroundColor;
  final Color borderColor;
}

class NumberCollectionCard {
  const NumberCollectionCard({
    required this.count,
    required this.headline,
    required this.caption,
    required this.imageUrl,
    required this.highlightColor,
  });

  final int count;
  final String headline;
  final String caption;
  final String imageUrl;
  final Color highlightColor;
}

class NumberLessonMetadata {
  const NumberLessonMetadata({
    required this.lessonId,
    required this.numberValue,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.cardImageUrl,
    required this.cardBackground,
    required this.cardBorder,
    required this.accentColor,
    required this.badgeColor,
    required this.order,
    required this.defaultStatus,
    required this.learningPrompt,
    required this.gallery,
    required this.activityPrompt,
    required this.activityCards,
    required this.keypadChoices,
    required this.correctChoice,
    required this.completionTitle,
    required this.completionSubtitle,
    required this.completionMascotUrl,
  });

  final String lessonId;
  final int numberValue;
  final String title;
  final String subtitle;
  final String description;
  final String cardImageUrl;
  final Color cardBackground;
  final Color cardBorder;
  final Color accentColor;
  final Color badgeColor;
  final int order;
  final LessonStatus defaultStatus;
  final String learningPrompt;
  final List<NumberIllustrationData> gallery;
  final String activityPrompt;
  final List<NumberCollectionCard> activityCards;
  final List<int> keypadChoices;
  final int correctChoice;
  final String completionTitle;
  final String completionSubtitle;
  final String completionMascotUrl;

  String get heroHeadline => numberValue.toString();

  String get quizId => 'quiz-numbers-$numberValue';
}

class NumberLessonEntry {
  const NumberLessonEntry({
    required this.metadata,
    required this.status,
    required this.progress,
  });

  final NumberLessonMetadata metadata;
  final LessonPlayStatus status;
  final ProgressRecord? progress;

  bool get isLocked => status == LessonPlayStatus.locked;
  bool get isCompleted => status == LessonPlayStatus.completed;
  bool get isInProgress => status == LessonPlayStatus.inProgress;
}

class NumbersLibrary {
  NumbersLibrary._();

  static const NumbersOverviewContent overview = NumbersOverviewContent(
    tagline: "Let's count together!",
    subtitle: 'Numbers',
    encouragement: "Keep going! You're doing great.",
    heroImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBoB-_lRkURwQ0FgvnX17C30EYhECOTy8pRkWdMDOK3a2SBmktJwNUd5DPyoZBaZORLeoRfGvYPGxGAhZrdMruCJWiMBvM_ZclwciyHmXgwNknksJT9rAdsYh2FVFNb02BgfWZzgdbEox482Ex9TWufOQDh_T69NQFVWVRoagKXBP7bbcaG_Qjcg26Sl_CwhJgSI279x4a5GLmBZOi9qEueylT73Dk7xq1UvgQRdWUeO4hvG0UTV_mgdXk5rtLw-snzBdXlobg9ZCU',
    heroBadgeSymbol: '!',
    ctaLabel: 'Start Learning',
    progressLabel: 'Your Progress',
  );

  static final List<NumberLessonMetadata> lessons =
      List<NumberLessonMetadata>.unmodifiable(_seeds);

  static final Map<String, NumberLessonMetadata> _byLessonId = {
    for (final metadata in lessons) metadata.lessonId: metadata,
  };

  static NumberLessonMetadata? byLessonId(String lessonId) {
    return _byLessonId[lessonId];
  }

  static List<NumberLessonEntry> buildEntries(
    Map<String, ProgressRecord> progress,
  ) {
    final entries = <NumberLessonEntry>[];
    for (final metadata in lessons) {
      final record = progress[metadata.lessonId];
      final inferredStatus = _inferStatus(
        record,
        entries.isEmpty ? null : entries.last,
        metadata,
      );
      entries.add(
        NumberLessonEntry(
          metadata: metadata,
          status: inferredStatus,
          progress: record,
        ),
      );
    }
    return entries;
  }

  static NumberLessonEntry? nextPlayable(List<NumberLessonEntry> entries) {
    for (final entry in entries) {
      if (entry.status != LessonPlayStatus.completed) {
        return entry;
      }
    }
    return null;
  }

  static LessonPlayStatus _inferStatus(
    ProgressRecord? record,
    NumberLessonEntry? previous,
    NumberLessonMetadata metadata,
  ) {
    if (record != null) {
      return record.status;
    }
    switch (metadata.defaultStatus) {
      case LessonStatus.locked:
        return previous?.isCompleted ?? false
            ? LessonPlayStatus.ready
            : LessonPlayStatus.locked;
      case LessonStatus.start:
        return LessonPlayStatus.inProgress;
      case LessonStatus.ready:
        return LessonPlayStatus.ready;
    }
  }

  static final List<Lesson> lessonStubs = List<Lesson>.unmodifiable(
    lessons
        .map(
          (metadata) => Lesson(
            id: metadata.lessonId,
            categoryId: 'numbers',
            title: metadata.title,
            description: metadata.subtitle,
            illustration: LessonIllustration.numbers,
            defaultStatus: metadata.defaultStatus,
            order: metadata.order,
            content: metadata.description,
            durationMinutes: 5 + metadata.numberValue,
            quizId: metadata.quizId,
          ),
        )
        .toList(growable: false),
  );
}

const List<NumberLessonMetadata> _seeds = [
  NumberLessonMetadata(
    lessonId: 'numbers-one',
    numberValue: 1,
    title: 'Counting to One',
    subtitle: 'Spot a single superstar.',
    description:
        'Find one shiny object at a time and shout ONE with a big smile.',
    cardImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDFl4KIWwBnfEWJd3MEwD2izjQfKjfsndzfSYYAXMusp7XWoMwbvj0F5TnLNBQzVrouKLScLJUuxn-ukAYFKiNlBPBpR1oqQM3ziACb8cBn8b03C6qHF5Gj4G8CA_yCpMFyKoJ82xwWRdAgUcDcUA06i8xuoS3uKjLdHHbs1dxrPLG0I2Pyp9oQSSX42hZL1oBqpK1kFA8PMKQbJULNFEvfL61z8kkKUExw082UrfW3EKXkTqfelczZjVo-R5bcPcB-Dr7BypfDdHc',
    cardBackground: Color(0xFFE3FCF0),
    cardBorder: Color(0xFF34D399),
    accentColor: Color(0xFF059669),
    badgeColor: Color(0xFFFACC15),
    order: 0,
    defaultStatus: LessonStatus.ready,
    learningPrompt: 'One special friend is waiting for you!',
    gallery: _duckGallery,
    activityPrompt: 'Can you find the card that shows 1?',
    activityCards: [
      _collectionApples,
      _collectionBirds,
      _collectionSuns,
    ],
    keypadChoices: [1, 2, 3],
    correctChoice: 1,
    completionTitle: 'Number Navigator',
    completionSubtitle: '1 of 5 numbers mastered',
    completionMascotUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuA4vzbw2ovrdkRKIxK14a075UEur9NwF3Y7nkgSQRXe_N3dsFiZynSGT4ZiMj3dkOwLuNfO2N3ctP1fqNd43-Jb4gB6_VRbZtkA7wiSI0CuS0aSMDw9-81igA4l5CBpHqt8KgO7oWGHZUOHQ2yiqEBEwjsMovRKSyLiuBFTrIYEcucAeBnpjxJFEmnX8ZoYrD-Z4rqh0pnSkyfOcutLy0hlubPZkViR66c6sP3_Rl-UEJd-P1Pn0FNI53Kuc3XTZWVI8PKHU46bE-s',
  ),
  NumberLessonMetadata(
    lessonId: 'numbers-two',
    numberValue: 2,
    title: 'The Pair',
    subtitle: 'Everything feels better in twos.',
    description:
        'Match up friendly pairs and clap twice to celebrate every duo.',
    cardImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCYl_4LNNWWXQeJtWySKRAs0wnUhFvxulNjL4MiL1lXsUQbmIfcWSMrp_sepHmxt3hDDXqBDhL__ni17cZZ-dPgoHOQSLsHM4F-K7NdDBN_niRqo2rdPBdMRcP3IWjcR00B-im6RLWEQQjugeIzteqWvkEgNn4A_cQRmd_9L80ZqSUXZ9rzzG9H7GD4iqzu5OIYY2Rq0FxNHLRtKSmvQoVYqm5_z07BEKgdqEPJM4rZwVTas_H6JSnnWP1y7aSd2AB1Q8qoxLfqg44',
    cardBackground: Color(0xFFFFF7E6),
    cardBorder: Color(0xFFFBBF24),
    accentColor: Color(0xFFB45309),
    badgeColor: Color(0xFFFDE68A),
    order: 1,
    defaultStatus: LessonStatus.start,
    learningPrompt: 'Look for twins, buddies, and dancing pairs.',
    gallery: _duckGallery,
    activityPrompt: 'Which card shows exactly 2 friends?',
    activityCards: [
      _collectionBirds,
      _collectionBlocks,
      _collectionBalloons,
    ],
    keypadChoices: [2, 4, 5],
    correctChoice: 2,
    completionTitle: 'Pair Pro',
    completionSubtitle: '2 of 5 numbers celebrated',
    completionMascotUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuA4vzbw2ovrdkRKIxK14a075UEur9NwF3Y7nkgSQRXe_N3dsFiZynSGT4ZiMj3dkOwLuNfO2N3ctP1fqNd43-Jb4gB6_VRbZtkA7wiSI0CuS0aSMDw9-81igA4l5CBpHqt8KgO7oWGHZUOHQ2yiqEBEwjsMovRKSyLiuBFTrIYEcucAeBnpjxJFEmnX8ZoYrD-Z4rqh0pnSkyfOcutLy0hlubPZkViR66c6sP3_Rl-UEJd-P1Pn0FNI53Kuc3XTZWVI8PKHU46bE-s',
  ),
  NumberLessonMetadata(
    lessonId: 'numbers-three',
    numberValue: 3,
    title: 'Three Friends',
    subtitle: 'Trios make the best teams.',
    description:
        'Count three giggles, three stars, or three ducks marching in a row.',
    cardImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDtK4C9FMZ-2RhxJ__A6KudQmvZ-pYF7Q1Ko134HCX8TqzLsuy2-bEV4nGHxnH98eL1oD_gcoK3bVZswbh4nP5vQAWANXcwsDNDmKWF-p5YdPMnDjjFXd7a0fdIiTHlei3VKcJFk4uXnk7fn7w6IzKbjKVMSdEDtAbdzbhnMwQ4Ef2eEL6xQqlGsMNo8yEmAgxvZfhzeJnuZ2Q3M49DyAc4pP1bvVARhuKUFeub9TtOHE5_hE8es0R8XsTFYlYtYWCiMjnMKi_qK5k',
    cardBackground: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE5E7EB),
    accentColor: Color(0xFF94A3B8),
    badgeColor: Color(0xFFC7D2FE),
    order: 2,
    defaultStatus: LessonStatus.locked,
    learningPrompt: 'Ready to spot three of everything?',
    gallery: _duckGallery,
    activityPrompt: 'Tap the trio with exactly 3.',
    activityCards: [
      _collectionSuns,
      _collectionBirds,
      _collectionApples,
    ],
    keypadChoices: [1, 3, 5],
    correctChoice: 3,
    completionTitle: 'Trio Trailblazer',
    completionSubtitle: '3 of 5 numbers unlocked',
    completionMascotUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuA4vzbw2ovrdkRKIxK14a075UEur9NwF3Y7nkgSQRXe_N3dsFiZynSGT4ZiMj3dkOwLuNfO2N3ctP1fqNd43-Jb4gB6_VRbZtkA7wiSI0CuS0aSMDw9-81igA4l5CBpHqt8KgO7oWGHZUOHQ2yiqEBEwjsMovRKSyLiuBFTrIYEcucAeBnpjxJFEmnX8ZoYrD-Z4rqh0pnSkyfOcutLy0hlubPZkViR66c6sP3_Rl-UEJd-P1Pn0FNI53Kuc3XTZWVI8PKHU46bE-s',
  ),
  NumberLessonMetadata(
    lessonId: 'numbers-four',
    numberValue: 4,
    title: 'The Square',
    subtitle: 'Four corners, endless fun.',
    description: 'Build neat grids and clap four steady beats.',
    cardImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCn_sqI1MGA9uMF-Q8lC6aAt0KOgpNiNRpxgIhZVKRm_Oortu4jrsTEHlGozki4-UA8aSIzOcQa9gE-nJguBaP6eWFTDlzHQ8R4yBTIzw8O8UGa6eN74DznqqJxj6Pl9pAOPNwljq_438FOxvPgLSWO8rSyLXZiqdK7vqxkUNmAGC9QBa6g65ZZluI1c1pp4lz0KvSdQU5WAdFcl0TLPXT5gXdfQWw9aXefsX3m1E5ZFQGnPA_VzOQQJyOWd2FsJwT99G2_oLQuCMo',
    cardBackground: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE5E7EB),
    accentColor: Color(0xFF94A3B8),
    badgeColor: Color(0xFF67E8F9),
    order: 3,
    defaultStatus: LessonStatus.locked,
    learningPrompt: 'Four beats, four blocks, four amazing shapes.',
    gallery: _duckGallery,
    activityPrompt: 'Spot the group of four.',
    activityCards: [
      _collectionBlocks,
      _collectionBananas,
      _collectionBalloons,
    ],
    keypadChoices: [2, 4, 5],
    correctChoice: 4,
    completionTitle: 'Square Scout',
    completionSubtitle: '4 of 5 numbers glowing',
    completionMascotUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuA4vzbw2ovrdkRKIxK14a075UEur9NwF3Y7nkgSQRXe_N3dsFiZynSGT4ZiMj3dkOwLuNfO2N3ctP1fqNd43-Jb4gB6_VRbZtkA7wiSI0CuS0aSMDw9-81igA4l5CBpHqt8KgO7oWGHZUOHQ2yiqEBEwjsMovRKSyLiuBFTrIYEcucAeBnpjxJFEmnX8ZoYrD-Z4rqh0pnSkyfOcutLy0hlubPZkViR66c6sP3_Rl-UEJd-P1Pn0FNI53Kuc3XTZWVI8PKHU46bE-s',
  ),
  NumberLessonMetadata(
    lessonId: 'numbers-five',
    numberValue: 5,
    title: 'High Five',
    subtitle: 'A handful of celebration.',
    description: 'Collect five cheers, five jumps, or five balloons.',
    cardImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBIG5sQsJm1DVtvqxMbvIpdgnyIuMsYPzJpD3CVCABXeyz1syFKey9VnH8Cv-V_YHeYcjItexgRJwF9Ok7s4tcvjxQgzmpcYxYYuiaCBLjlRePA0tU07pg-bwgZMiF6d6n30vHU8unBOTuZPLJqsxRlz1iCwSLx66oGty2cIq4wdN68CgvFYvrW0rZ7kdl8_xD0DmU-8rQ-sunCWkFXOLNH1Dr8hihvXa8tpi2-QdfYreuSjdOboAsk2hcnntf8kWx0E6mv8hLoQTA',
    cardBackground: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE5E7EB),
    accentColor: Color(0xFF94A3B8),
    badgeColor: Color(0xFFF9A8D4),
    order: 4,
    defaultStatus: LessonStatus.locked,
    learningPrompt: 'Five sparks light up every room.',
    gallery: _duckGallery,
    activityPrompt: 'Show me the group of five.',
    activityCards: [
      _collectionBalloons,
      _collectionBananas,
      _collectionApples,
    ],
    keypadChoices: [3, 4, 5],
    correctChoice: 5,
    completionTitle: 'High-Five Hero',
    completionSubtitle: 'All 5 numbers mastered',
    completionMascotUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuA4vzbw2ovrdkRKIxK14a075UEur9NwF3Y7nkgSQRXe_N3dsFiZynSGT4ZiMj3dkOwLuNfO2N3ctP1fqNd43-Jb4gB6_VRbZtkA7wiSI0CuS0aSMDw9-81igA4l5CBpHqt8KgO7oWGHZUOHQ2yiqEBEwjsMovRKSyLiuBFTrIYEcucAeBnpjxJFEmnX8ZoYrD-Z4rqh0pnSkyfOcutLy0hlubPZkViR66c6sP3_Rl-UEJd-P1Pn0FNI53Kuc3XTZWVI8PKHU46bE-s',
  ),
];

const List<NumberIllustrationData> _duckGallery = [
  NumberIllustrationData(
    alt: 'Yellow duckling waving',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDhj5G6CODK_E6wmecFieIVNZT8c9Xqi3LZNX0iE9d0WPLllE8RaXE8N0s4E2S5iSJ1ZqP0DaE2M25MlZeQ7GBFnBEvEn1jLr4mtgVFRgEYZAhZ0v8nUJHjkDaIldnMmSx7pCI8ObSX6lWb_UbN5gEpNnZURNKWB0Y1zVOHX_kVl4ZhhszKCRoy5gYUQrqQ7TsEei_3OpmCsMEtKC5MvwhlAQlkB20DJCgGRkUjd8EmJDuNNg2_2ec-LzAuEG5WytPhTtSdhT2zwEs',
    backgroundColor: Color(0xFFFEF3C7),
    borderColor: Color(0xFFFCD34D),
  ),
  NumberIllustrationData(
    alt: 'Second duckling smiling',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCkLEdmogeVIEBNlhnV_L9FDP6YuZgKf5gBdHgcOTohF0Jtmz2LVwpfZKyV0Uelw1iXlOi31yeRTWdlfZ5Okdang3JJwRCjac2Y92AUMiW1BkGlt38fXtjvli5o5nqLosl-IdSJvhsaY79P8xUcZgjSuSMl3194feAPKXAUQPffe7fomyC0bEjp5KqSggB-OYHWsPtDfE85Tt1QIPzJLX2zLvZ5vW5B6JP2v4mvsvjATnt1qEF1YWSJ8EsAEBu6p3178iMBd-wfAU8',
    backgroundColor: Color(0xFFFEF3C7),
    borderColor: Color(0xFFFCD34D),
  ),
  NumberIllustrationData(
    alt: 'Third duckling cheering',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuA0B1Ki1SiyegVEXZ_O55iuWy1IgiTarJ_KtS2SNkkDKUNtyk2G_GBQJF3fDZ5YH0E8UGlYlA04w7fgkTPg9O8K8R2uZ14aeUrK-jrO0NAko-fw-dcT0VCpdMkTS1aBgUaFDTjZDlK5DimXT59ZNi0X4BimV7xhJ8yKpXTT1MuvqE6kEfjDMMjQJkpiKeH0EDARR0sXFRk5_0oCYvLkaQsJBVyOl6hflrdsZuzQKPrb3QAtwyTFp7VYNj-8LltbZZWKedQOtlCU2j0',
    backgroundColor: Color(0xFFFEF3C7),
    borderColor: Color(0xFFFCD34D),
  ),
];

const NumberCollectionCard _collectionApples = NumberCollectionCard(
  count: 1,
  headline: '1 Apple',
  caption: 'Crunchy and bright red.',
  imageUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCPGMgfUKnM2XSG3prXGqQInEooxrpsHn4Kjud3fsk3epg3WfbWTsIIP5l-s60f9mnsSlwkvfJy0WxUdymSBY5-pk1FDbr8kSwXnI26kEn65C5EoYEYxanb81IEIIKDL8d5ABJFSODGO2uGJriI16Up0PU__45XJpi6m1bGHigTtJ9V15kE6BIeg0CfhY4FThaSIQwij59709ayH3Cp9kXb5QlwerHvswlGhm9XsNOZOlyXih8DCEh8zE0AOqY8xgQaYO9BfRi_C7w',
  highlightColor: Color(0xFF34D399),
);

const NumberCollectionCard _collectionBirds = NumberCollectionCard(
  count: 2,
  headline: '2 Birds',
  caption: 'Blue buddies on a branch.',
  imageUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCYl_4LNNWWXQeJtWySKRAs0wnUhFvxulNjL4MiL1lXsUQbmIfcWSMrp_sepHmxt3hDDXqBDhL__ni17cZZ-dPgoHOQSLsHM4F-K7NdDBN_niRqo2rdPBdMRcP3IWjcR00B-im6RLWEQQjugeIzteqWvkEgNn4A_cQRmd_9L80ZqSUXZ9rzzG9H7GD4iqzu5OIYY2Rq0FxNHLRtKSmvQoVYqm5_z07BEKgdqEPJM4rZwVTas_H6JSnnWP1y7aSd2AB1Q8qoxLfqg44',
  highlightColor: Color(0xFFF59E0B),
);

const NumberCollectionCard _collectionSuns = NumberCollectionCard(
  count: 3,
  headline: '3 Suns',
  caption: 'Smiley sunshines.',
  imageUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDtK4C9FMZ-2RhxJ__A6KudQmvZ-pYF7Q1Ko134HCX8TqzLsuy2-bEV4nGHxnH98eL1oD_gcoK3bVZswbh4nP5vQAWANXcwsDNDmKWF-p5YdPMnDjjFXd7a0fdIiTHlei3VKcJFk4uXnk7fn7w6IzKbjKVMSdEDtAbdzbhnMwQ4Ef2eEL6xQqlGsMNo8yEmAgxvZfhzeJnuZ2Q3M49DyAc4pP1bvVARhuKUFeub9TtOHE5_hE8es0R8XsTFYlYtYWCiMjnMKi_qK5k',
  highlightColor: Color(0xFF60A5FA),
);

const NumberCollectionCard _collectionBlocks = NumberCollectionCard(
  count: 4,
  headline: '4 Blocks',
  caption: 'Stack into a square.',
  imageUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCn_sqI1MGA9uMF-Q8lC6aAt0KOgpNiNRpxgIhZVKRm_Oortu4jrsTEHlGozki4-UA8aSIzOcQa9gE-nJguBaP6eWFTDlzHQ8R4yBTIzw8O8UGa6eN74DznqqJxj6Pl9pAOPNwljq_438FOxvPgLSWO8rSyLXZiqdK7vqxkUNmAGC9QBa6g65ZZluI1c1pp4lz0KvSdQU5WAdFcl0TLPXT5gXdfQWw9aXefsX3m1E5ZFQGnPA_VzOQQJyOWd2FsJwT99G2_oLQuCMo',
  highlightColor: Color(0xFF7C3AED),
);

const NumberCollectionCard _collectionBananas = NumberCollectionCard(
  count: 4,
  headline: '4 Bananas',
  caption: 'Bundle of yellow energy.',
  imageUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuA9sNP67U6fQyUAKi66NWpcErLNAhXpHwREN3LteKthA7k8I-EMP6Kpp1UXKacdV7ch8qLy-Atlc8GNoOIMaJwhfMelEQ3Dee9-iLE-vt_lzbfNQ-A3mYJ9_kCsLUZuer7iMcyA7-Ko9eJ3qgshE2Iq2CocJJIkdqxHAkvWmuvPN0mEdbBmgSccpGgB5-dXBjtxDwgUJwCK4a1Dr3wrvfjVnLV6JHEL99fIczuJ5uVpWist3VAN34-piPybCoo_HK-RLYl-jNVreBI',
  highlightColor: Color(0xFF10B981),
);

const NumberCollectionCard _collectionBalloons = NumberCollectionCard(
  count: 5,
  headline: '5 Balloons',
  caption: 'A rainbow high five.',
  imageUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBIG5sQsJm1DVtvqxMbvIpdgnyIuMsYPzJpD3CVCABXeyz1syFKey9VnH8Cv-V_YHeYcjItexgRJwF9Ok7s4tcvjxQgzmpcYxYYuiaCBLjlRePA0tU07pg-bwgZMiF6d6n30vHU8unBOTuZPLJqsxRlz1iCwSLx66oGty2cIq4wdN68CgvFYvrW0rZ7kdl8_xD0DmU-8rQ-sunCWkFXOLNH1Dr8hihvXa8tpi2-QdfYreuSjdOboAsk2hcnntf8kWx0E6mv8hLoQTA',
  highlightColor: Color(0xFFF472B6),
);
