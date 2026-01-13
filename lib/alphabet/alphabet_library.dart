import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/progress_record.dart';

class AlphabetLetterMetadata {
  AlphabetLetterMetadata({
    required this.lessonId,
    required this.letter,
    required this.word,
    required this.description,
    required this.storyPrompt,
    required this.activityPrompt,
    required this.backgroundColor,
    required this.accentColor,
    required this.badgeColor,
    required this.order,
  });

  final String lessonId;
  final String letter;
  final String word;
  final String description;
  final String storyPrompt;
  final String activityPrompt;
  final Color backgroundColor;
  final Color accentColor;
  final Color badgeColor;
  final int order;

  String get title => 'Letter $letter is for $word';
  String get subtitle => description;
  String get heroCaption => '$word begins with $letter';
}

class AlphabetLetterEntry {
  const AlphabetLetterEntry({
    required this.metadata,
    required this.status,
    required this.progress,
  });

  final AlphabetLetterMetadata metadata;
  final LessonPlayStatus status;
  final ProgressRecord? progress;

  bool get isLocked => status == LessonPlayStatus.locked;
  bool get isCompleted => status == LessonPlayStatus.completed;
  bool get isInProgress => status == LessonPlayStatus.inProgress;
}

class AlphabetLibrary {
  AlphabetLibrary._();

  static final List<AlphabetLetterMetadata> letters = _buildLetters();

  static final Map<String, AlphabetLetterMetadata> _byLetter = {
    for (final metadata in letters) metadata.letter: metadata,
  };

  static final Map<String, AlphabetLetterMetadata> _byLessonId = {
    for (final metadata in letters) metadata.lessonId: metadata,
  };

  static AlphabetLetterMetadata? byLetter(String letter) {
    return _byLetter[letter.toUpperCase()];
  }

  static AlphabetLetterMetadata? byLessonId(String lessonId) {
    return _byLessonId[lessonId];
  }

  static List<AlphabetLetterEntry> buildEntries(
    Map<String, ProgressRecord> progress,
  ) {
    final entries = <AlphabetLetterEntry>[];
    for (var i = 0; i < letters.length; i++) {
      final metadata = letters[i];
      final record = progress[metadata.lessonId];
      final inferredStatus =
          _inferStatus(record, entries.isEmpty ? null : entries.last);
      entries.add(
        AlphabetLetterEntry(
          metadata: metadata,
          status: inferredStatus,
          progress: record,
        ),
      );
    }
    return entries;
  }

  static LessonPlayStatus _inferStatus(
    ProgressRecord? record,
    AlphabetLetterEntry? previous,
  ) {
    if (record != null) {
      return record.status;
    }
    if (previous == null) {
      return LessonPlayStatus.ready;
    }
    return previous.isCompleted
        ? LessonPlayStatus.ready
        : LessonPlayStatus.locked;
  }

  static AlphabetLetterEntry? nextPlayable(List<AlphabetLetterEntry> entries) {
    for (final entry in entries) {
      if (entry.status != LessonPlayStatus.completed) {
        return entry;
      }
    }
    return null;
  }

  static final List<Lesson> lessonStubs = List<Lesson>.unmodifiable(
    letters
        .map(
          (metadata) => Lesson(
            id: metadata.lessonId,
            categoryId: 'alphabet',
            title: metadata.title,
            description: metadata.subtitle,
            illustration: LessonIllustration.shapes,
            defaultStatus: LessonStatus.ready,
            order: metadata.order,
            content:
                'Explore the sound of ${metadata.letter} with ${metadata.word}. ${metadata.storyPrompt}',
            durationMinutes: 4,
            quizId: '',
          ),
        )
        .toList(growable: false),
  );
}

class _AlphabetLetterSeed {
  const _AlphabetLetterSeed({
    required this.letter,
    required this.word,
    required this.description,
    required this.storyPrompt,
  });

  final String letter;
  final String word;
  final String description;
  final String storyPrompt;
}

const List<_AlphabetLetterSeed> _alphabetSeeds = [
  _AlphabetLetterSeed(
    letter: 'A',
    word: 'Apple',
    description: 'Crunchy snack hero who shouts "ah".',
    storyPrompt: 'Pretend to take a big bite and say A three times.',
  ),
  _AlphabetLetterSeed(
    letter: 'B',
    word: 'Bee',
    description: 'A buzzing buddy who loves bright flowers.',
    storyPrompt: 'Buzz around the room and trace big and little B.',
  ),
  _AlphabetLetterSeed(
    letter: 'C',
    word: 'Cat',
    description: 'Curious whiskers that curl like the letter.',
    storyPrompt: 'Draw cat whiskers in the air while you say C sounds.',
  ),
  _AlphabetLetterSeed(
    letter: 'D',
    word: 'Dino',
    description: 'Gentle giant who stomps out drum beats.',
    storyPrompt: 'Stomp four times saying D with each stomp.',
  ),
  _AlphabetLetterSeed(
    letter: 'E',
    word: 'Elephant',
    description: 'Trumpeting pal with enormous ears.',
    storyPrompt: 'Stretch your arms like a trunk and whisper Eeee.',
  ),
  _AlphabetLetterSeed(
    letter: 'F',
    word: 'Firefly',
    description: 'Glowing friend who flickers in the night.',
    storyPrompt: 'Wiggle your fingers like tiny lights and say F.',
  ),
  _AlphabetLetterSeed(
    letter: 'G',
    word: 'Garden',
    description: 'Green sprouts that grow with gentle sounds.',
    storyPrompt: 'Pretend to water plants while humming G.',
  ),
  _AlphabetLetterSeed(
    letter: 'H',
    word: 'House',
    description: 'Happy home that hugs everyone inside.',
    storyPrompt: 'Build a house with your arms and breathe out H.',
  ),
  _AlphabetLetterSeed(
    letter: 'I',
    word: 'Igloo',
    description: 'Icy dome that glows under moonlight.',
    storyPrompt: 'Draw a circle igloo in the air and whisper I.',
  ),
  _AlphabetLetterSeed(
    letter: 'J',
    word: 'Jelly',
    description: 'Jiggly treat that wiggles with joy.',
    storyPrompt: 'Jiggle like jelly while saying jumpy J sounds.',
  ),
  _AlphabetLetterSeed(
    letter: 'K',
    word: 'Kite',
    description: 'Colorful flyer that kicks up breezes.',
    storyPrompt: 'Pretend to hold a kite string and call out K.',
  ),
  _AlphabetLetterSeed(
    letter: 'L',
    word: 'Lion',
    description: 'Kind leader who loves to lounge.',
    storyPrompt: 'Roar softly like a lion while tracing L.',
  ),
  _AlphabetLetterSeed(
    letter: 'M',
    word: 'Moon',
    description: 'Midnight glow that makes wishes cozy.',
    storyPrompt: 'Draw a crescent moon and hum mmmm gently.',
  ),
  _AlphabetLetterSeed(
    letter: 'N',
    word: 'Nest',
    description: 'Neat home filled with tiny notes of song.',
    storyPrompt: 'Cup your hands like a nest and nod with N.',
  ),
  _AlphabetLetterSeed(
    letter: 'O',
    word: 'Octopus',
    description: 'Ocean dancer with eight waving arms.',
    storyPrompt: 'Wave your arms like tentacles while saying O.',
  ),
  _AlphabetLetterSeed(
    letter: 'P',
    word: 'Panda',
    description: 'Playful pal who prefers bamboo picnics.',
    storyPrompt: 'Pat your knees and pop the P sound.',
  ),
  _AlphabetLetterSeed(
    letter: 'Q',
    word: 'Queen',
    description: 'Quick thinker wearing a quiet crown.',
    storyPrompt: 'Balance an imaginary crown and whisper Q.',
  ),
  _AlphabetLetterSeed(
    letter: 'R',
    word: 'Rainbow',
    description: 'Radiant arch painted after rain.',
    storyPrompt: 'Draw rainbow stripes while rolling R lightly.',
  ),
  _AlphabetLetterSeed(
    letter: 'S',
    word: 'Sun',
    description: 'Shiny star that sprinkles warm sparkles.',
    storyPrompt: 'Stretch wide like sunshine and hiss S.',
  ),
  _AlphabetLetterSeed(
    letter: 'T',
    word: 'Turtle',
    description: 'Tiny traveler with a trusty shell.',
    storyPrompt: 'Tap your shoulders for turtle steps and say T.',
  ),
  _AlphabetLetterSeed(
    letter: 'U',
    word: 'Umbrella',
    description: 'Upbeat helper on drippy days.',
    storyPrompt: 'Open an imaginary umbrella and utter U.',
  ),
  _AlphabetLetterSeed(
    letter: 'V',
    word: 'Volcano',
    description: 'Vibrant mountain full of fizz.',
    storyPrompt: 'Make a V with your arms and voice a gentle V.',
  ),
  _AlphabetLetterSeed(
    letter: 'W',
    word: 'Whale',
    description: 'Wavy singer of the deep blue.',
    storyPrompt: 'Swim in place like a whale and whisper W.',
  ),
  _AlphabetLetterSeed(
    letter: 'X',
    word: 'Xylophone',
    description: 'Excellent instrument with zigzag bars.',
    storyPrompt: 'Pretend to tap keys while saying eks.',
  ),
  _AlphabetLetterSeed(
    letter: 'Y',
    word: 'Yo-yo',
    description: 'Yippy toy that zooms up and down.',
    storyPrompt: 'Move your hand like a yo-yo and chant Y.',
  ),
  _AlphabetLetterSeed(
    letter: 'Z',
    word: 'Zebra',
    description: 'Zippy stripes zigzagging across the savanna.',
    storyPrompt: 'Gallop in place and buzz the Z sound.',
  ),
];

const List<Color> _backgroundPalette = <Color>[
  Color(0xFFFFF2EC),
  Color(0xFFEFF6FF),
  Color(0xFFF3E8FF),
  Color(0xFFE8FFF4),
  Color(0xFFFFF9DB),
  Color(0xFFEFFAFB),
];

const List<Color> _accentPalette = <Color>[
  Color(0xFFFF6B6B),
  Color(0xFF60A5FA),
  Color(0xFFBE7BFF),
  Color(0xFF34D399),
  Color(0xFFF97316),
  Color(0xFF0EA5E9),
];

const List<Color> _badgePalette = <Color>[
  Color(0xFFFFA8A8),
  Color(0xFFA5B4FC),
  Color(0xFFD8B4FE),
  Color(0xFF86EFAC),
  Color(0xFFFCD34D),
  Color(0xFF67E8F9),
];

List<AlphabetLetterMetadata> _buildLetters() {
  final result = <AlphabetLetterMetadata>[];
  for (var i = 0; i < _alphabetSeeds.length; i++) {
    final seed = _alphabetSeeds[i];
    final paletteIndex = i % _backgroundPalette.length;
    result.add(
      AlphabetLetterMetadata(
        lessonId: 'alphabet-letter-${seed.letter.toLowerCase()}',
        letter: seed.letter,
        word: seed.word,
        description: seed.description,
        storyPrompt: seed.storyPrompt,
        activityPrompt: 'Which one starts with ${seed.letter}?',
        backgroundColor: _backgroundPalette[paletteIndex],
        accentColor: _accentPalette[paletteIndex],
        badgeColor: _badgePalette[paletteIndex],
        order: i,
      ),
    );
  }
  return List<AlphabetLetterMetadata>.unmodifiable(result);
}
