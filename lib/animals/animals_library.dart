import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/progress_record.dart';

class AnimalsOverviewContent {
  const AnimalsOverviewContent({
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
}

class AnimalTraitCard {
  const AnimalTraitCard({
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

class AnimalActivityOption {
  const AnimalActivityOption({
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

class AnimalBadgeReward {
  const AnimalBadgeReward({
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

class AnimalLessonMetadata {
  const AnimalLessonMetadata({
    required this.lessonId,
    required this.title,
    required this.listDescription,
    required this.heroHeadline,
    required this.heroDescription,
    required this.heroImageUrl,
    required this.cardImageUrl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.soundLabel,
    required this.defaultStatus,
    required this.order,
    required this.traits,
    required this.activityPrompt,
    required this.activityOptions,
    required this.completionTitle,
    required this.completionSubtitle,
    required this.completionMascotUrl,
    required this.badges,
    required this.totalDiscoverySteps,
  });

  final String lessonId;
  final String title;
  final String listDescription;
  final String heroHeadline;
  final String heroDescription;
  final String heroImageUrl;
  final String cardImageUrl;
  final Color primaryColor;
  final Color secondaryColor;
  final String soundLabel;
  final LessonStatus defaultStatus;
  final int order;
  final List<AnimalTraitCard> traits;
  final String activityPrompt;
  final List<AnimalActivityOption> activityOptions;
  final String completionTitle;
  final String completionSubtitle;
  final String completionMascotUrl;
  final List<AnimalBadgeReward> badges;
  final int totalDiscoverySteps;

  String get quizId => 'quiz-${lessonId.replaceAll('-', '_')}';
}

class AnimalLessonEntry {
  const AnimalLessonEntry({
    required this.metadata,
    required this.status,
    required this.progress,
  });

  final AnimalLessonMetadata metadata;
  final LessonPlayStatus status;
  final ProgressRecord? progress;

  bool get isLocked => status == LessonPlayStatus.locked;
  bool get isCompleted => status == LessonPlayStatus.completed;
  bool get isInProgress => status == LessonPlayStatus.inProgress;

  double progressRatio() {
    if (isCompleted) return 1;
    if (metadata.totalDiscoverySteps <= 0) {
      return progress == null ? 0 : 1;
    }
    final best = progress?.bestScore ?? 0;
    final ratio = best / metadata.totalDiscoverySteps;
    return ratio.clamp(0, 1);
  }
}

class AnimalsLibrary {
  AnimalsLibrary._();

  static const AnimalsOverviewContent overview = AnimalsOverviewContent(
    title: 'Lion Kingdom',
    tagline: 'Meet your animal friends!',
    encouragement: 'Keep exploring to unlock new buddies.',
    heroImageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBmhd9eLDiIWvVRt52w88smz0pGdVgE7TxYTMr1dI-Ln5Y8dVqWaEQU0NxQk4kuoraWcfqq1VhC-SE2S-OWYEO3seRUxMKjmi4UqMVrioRrs7TaleKvg7A0MLbunYNk44h4EQEG4tTeyhS2LmgNpzCPCHbCuA7JZ_ysLM5AItRBee8JrXFt4RDVMdrbKklRUdhBvh-Kxgd8Kvh8Yb8voq0gUrVILI95KylK906eKZ8323PxAlicSEklSpmovovBEj8zfz_iG9OBi6k',
    ctaLabel: 'Start Learning',
    progressLabel: 'Animals Discovered',
    topicLabel: 'Animals',
  );

  static final List<AnimalLessonMetadata> lessons =
      List<AnimalLessonMetadata>.unmodifiable(_animalSeeds);

  static final Map<String, AnimalLessonMetadata> _byLessonId = {
    for (final lesson in lessons) lesson.lessonId: lesson,
  };

  static AnimalLessonMetadata? byLessonId(String lessonId) {
    return _byLessonId[lessonId];
  }

  static List<AnimalLessonEntry> buildEntries(
    Map<String, ProgressRecord> progress,
  ) {
    final entries = <AnimalLessonEntry>[];
    for (final metadata in lessons) {
      final record = progress[metadata.lessonId];
      final status = _inferStatus(
        record,
        entries.isEmpty ? null : entries.last,
        metadata,
      );
      entries.add(
        AnimalLessonEntry(
          metadata: metadata,
          status: status,
          progress: record,
        ),
      );
    }
    return entries;
  }

  static AnimalLessonEntry? nextPlayable(List<AnimalLessonEntry> entries) {
    for (final entry in entries) {
      if (entry.status != LessonPlayStatus.completed) {
        return entry;
      }
    }
    return null;
  }

  static LessonPlayStatus _inferStatus(
    ProgressRecord? record,
    AnimalLessonEntry? previous,
    AnimalLessonMetadata metadata,
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
            categoryId: 'animals',
            title: metadata.title,
            description: metadata.listDescription,
            illustration: LessonIllustration.lion,
            defaultStatus: metadata.defaultStatus,
            order: metadata.order,
            content: metadata.heroDescription,
            durationMinutes: 6 + metadata.order,
            quizId: metadata.quizId,
          ),
        )
        .toList(growable: false),
  );
}

const String _catImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuC5D-z_d7qfK-tjwajO8zS_TSo3dhwGhFTCRUzpQmrFQLBGk58nFVyE03uIWj51I6OFtH1yMj8iJQfV1XAUNKqK_9wz9-tEg6Tw7tqUz5mTWHzJ9LlwfKdQ9jaCIh1c6t8NT4nbbRr8HxAjS3R2w-V9M7p_YphQIrerkOOZI8z79FU4NgBQW4-flIYmB-6lF6dXdHk9EeNFbzPyUm-X-CjsVZfElpNiC_GVDC-C6qhd1bbh4G2NUP8XfPyionJwEP7mGN5JtsY8984';
const String _dogImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAcj4w-PlZ8SswpaQKFVz0_nAFTEywJpEhObsg8blJIoLBq16hI0Vnujmr4zIncQVIqaEGk5htNvFKz67Tn6ttw7rxHPHSJQV6WFSWxKQzyLp3HwZyHYkyWFsZFe1d6y7X5BGrLQV1AnOweSRAY-_rLuhXkjhybsGY6NiTuqGat3ofw4xoa6j8A7DpuCydQpV36oJlfsQ-bvlRSOOADQ92PHYQ78UJtb9B6RH5VQvmvRfAcAFQhusosP4-AAdOSw2vYsc51iXBhX5U';
const String _elephantImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCc9A_dRDhQ2r5NNE_uZr7mJpUQmqgKHKYgYv7KxT8_gEN-KBUW-wWh7EKFQZQSTZIc4dhETnGbb3U5sp_eh2KW3h6eoUYZd7wemHKDpfLaZVDfPr0fh9ZbB3DLGSUPlBPP2bhZjAXFwaapjUV-J70DPQEn6M9Gu4aT6rcqfzmAdF-qn5BtmqONMrx_HvEUodFx7mGrSIT1svJZTK65DUXWpkowOAXIIpC3hov-rbB-jXKGULlKqXqjuTKSSRV64k1zyghdF-EpHTg';
const String _lionImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuB7gtuPXFj8vAMYzx2B-3SauBwCyDBAx7Cg6kD8LsDg5ifW4dA7QwEMxqwU3CJVoqOWsybyB3nnuDxzZMDNaAFiDinpFoZ-9kV4ZZ9zyz9jirJRGsgTnUSauhNDfEQTEDdEhBOoKNyFlJGaa-FOGFxvLZbeweZmjOcny6wx8y9sE8oUK7tjiETc0h1X4oZZSJ8e_KNMC8lOz3U_UCyxyZ9ThPi2vEBBHi40GMSAUApccfPCyj8VkoRKg-uYGk5aAercRhTjI1e3Gtc';
const String _monkeyImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCWxsSje_lE7Jjn8ZgC69tZOYvz_b8a9Fw923NHk9EIBsSnmYVf4c1YcNf4HMKs7z8sPNC4xOrF-x2wq8aWB_ufX34criInZ3-Y3rnMkpAamv1iSPB43O5t0q-vXbKzSZiwQge9rdmT3sKX0RiOA1Zs2NhHja-2_MOwEpa0XMeeO1lV_E-Y4pwJJjFuzBFp9jKG6T02uRHRlEbDjCFF2g5iObiLoKit2UuK7XdyZCmBdEJMReDjo4LF7CBe9afilG8GeQE74irFKlI';
const String _lionCompletion =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDq5MdX9FhmkuLE7zX612Yu08AJWSI9_CUi4_9m0LPO4dycWcCddHjq9Yl4i-qtUjkFL341C5S6kY9II_c__Tghpj9IxjpgZhVvF0TPIoA3l0OwzUmAHxUCJzBE1KoSYADSORSiamQhnTm8PAbHZiQ9dxNz2rlyg6BGqzNESeYKueI7q7H8zaSZJX2Os8MzetlpwmMlfAdLyH12SB5CPhSc54zhXkeBDI-bkpbOC8M6G1cJvnCAx3OsoLCn3w4bUjECxlQLwvvn_uw';
const String _elephantHero =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuD7lRSj54GEKCfnJaLUbMEzHS0wLPF53fv6mH85PYTZx94CJDCRfjxAC_JCR37vJbVElUjM-QUMYHpDkSrEIC9HKLgS9k5A9kHuJx-dtzTmzEUqZFvr28UqLvPeIuPTILpGshs4GVaOj-z3wap7eM1frKHzAg5KQcVIewcFgKLoFjYBqOzZcycYevfVUXkVU5TYksM8eG2Je29HR-WISMNLAWggsy2hu2IyqyBc_POY2YRDtD3qhhtozukdB3b2G5zTUkZBA2nSzNs';
const String _traitTrunk =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAU4XOhsDB-98LxJNSuZeU-ck7YjTjH7XhODvUWy_0-k4sqsknYd53ambBEL9fcY5TJrt-lvliSJ8E8s-YhDNoKmqsTnKTHj69h3L9oGpwIdE-RjeAz3SpKKelr7hq7undOVvWL59I4xJvw3yEZH-soGnjKYVnTkmdrhPHlKEhz77DWNEQMZSof39JUuClrSHJOORm13ofBNYTrwj20GofGnj478Tj-XCjccPm_HZLObDF-CyTNe63R42EUeg1MMM3YA_h3hz_DdIg';
const String _traitEars =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuA7nJOhVuux30c1-Pok1dH2lv5DuT7WKKLTAQKpjb-USD0AKlBSc49yYwM7M9yZMBbMU2KL07ZR0_sF3JVYMGKMmcJqv9_n2ccOgZQUtUebEwhUYA1mjcb5ulbtiQhC50VeKCL4je1gMuHcU2WsOBlW6s0EbmWotMb0AurOjfu97n3gY_uBCyTWWkYZ8nd3rmyOx5kGdfJFyK4kgGT98kplyhXd9MsRdEd18BeFyxrNBXepMUP0U1vNHirpr9tMpRLPjJM43mDrnzo';

const List<AnimalLessonMetadata> _animalSeeds = [
  AnimalLessonMetadata(
    lessonId: 'animals-cat',
    title: 'Cat',
    listDescription: 'Let\'s Meow!',
    heroHeadline: 'The Cat is curious!',
    heroDescription: 'Cats tiptoe softly and love sunny window naps.',
    heroImageUrl: _catImage,
    cardImageUrl: _catImage,
    primaryColor: Color(0xFFF4B8D3),
    secondaryColor: Color(0xFFFFF1F7),
    soundLabel: 'Purr!',
    defaultStatus: LessonStatus.ready,
    order: 0,
    traits: [
      AnimalTraitCard(
        title: 'Soft Paws',
        description: 'Perfect for sneaky adventures.',
        imageUrl: _catImage,
        borderColor: Color(0xFFF472B6),
        badgeColor: Color(0xFFFDF2F8),
      ),
      AnimalTraitCard(
        title: 'Balancing Tail',
        description: 'Helps every leap stay graceful.',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAn4H8bV3FQsg0tP_tRkojtevQZjQRQ3lBBiy7bGtfwqZ4d8hsgFZAAyL5brVPmXOMZCh6b8z-AoMbbj1XUS5SOsyJjCwG40bL1hdGns-P6kqHwPS4ja_FbbWsGb4x6HXuIB5cHg0YcZ9mCLvFqhSiXCOhVCMXMcLBchuUqvJm5Jxr2bxGC6b0w2u4TOhf5rIfdvyHlEoqhSxnWwZWA7Uwayb8ZLpXzVWnQAgFTRhVPw6LtfRPllcCEEKsYqFrD2-ZsXBvtbpKzhYk',
        borderColor: Color(0xFFFB7185),
        badgeColor: Color(0xFFFFF0F5),
      ),
    ],
    activityPrompt: 'Which friend says Meow?',
    activityOptions: [
      AnimalActivityOption(
        id: 'cat-meow',
        label: 'Cat',
        imageUrl: _catImage,
        caption: 'Meow!',
        isCorrect: true,
      ),
      AnimalActivityOption(
        id: 'dog-bark',
        label: 'Dog',
        imageUrl: _dogImage,
        caption: 'Woof!',
        isCorrect: false,
      ),
      AnimalActivityOption(
        id: 'lion-roar',
        label: 'Lion',
        imageUrl: _lionImage,
        caption: 'Roar!',
        isCorrect: false,
      ),
    ],
    completionTitle: 'Purr-fect Pal',
    completionSubtitle: 'You met the cozy cat.',
    completionMascotUrl: _lionCompletion,
    badges: [
      AnimalBadgeReward(
        label: 'Explorer',
        icon: Icons.pets,
        startColor: Color(0xFFFEE2E2),
        endColor: Color(0xFFFCA5A5),
      ),
    ],
    totalDiscoverySteps: 5,
  ),
  AnimalLessonMetadata(
    lessonId: 'animals-dog',
    title: 'Dog',
    listDescription: 'Puppy Play',
    heroHeadline: 'Dogs are loyal friends!',
    heroDescription: 'They wag, bark, and love to fetch all day.',
    heroImageUrl: _dogImage,
    cardImageUrl: _dogImage,
    primaryColor: Color(0xFFE0E7FF),
    secondaryColor: Color(0xFFF2F5FF),
    soundLabel: 'Woof!',
    defaultStatus: LessonStatus.start,
    order: 1,
    traits: [
      AnimalTraitCard(
        title: 'Happy Tail',
        description: 'Wags at every smile.',
        imageUrl: _dogImage,
        borderColor: Color(0xFFA5B4FC),
        badgeColor: Color(0xFFEFF6FF),
      ),
      AnimalTraitCard(
        title: 'Playful Paws',
        description: 'Ready for every adventure.',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCbtNV_B0L5T7yuiwDyCIFL9yHmRJVfKtpQXSqiopalXGtqY2zJ7SPOfHO7L4aBgb5zsy5HoTBmyxWmNYci_pTlGfBGxpmOVIp3h2bFb68drYvQ32eKqMHKzMFCoWTzYlD-MyU0zqnqt3efcQM9bZk6k9C1aGj6Ds33mSyiGWrNWTJV7j2fQo1SvbSmTwRf4vXElSR9WumpEm8LudEiwhfNBxrsAYJ37wwvhb3mCB8B9AMcrgEreb3ZbgFY0V6zt6bxjH6Q9E6npyV',
        borderColor: Color(0xFF60A5FA),
        badgeColor: Color(0xFFE0F2FE),
      ),
    ],
    activityPrompt: 'Tap the friend who says Woof.',
    activityOptions: [
      AnimalActivityOption(
        id: 'dog-bark',
        label: 'Dog',
        imageUrl: _dogImage,
        caption: 'Woof Woof!',
        isCorrect: true,
      ),
      AnimalActivityOption(
        id: 'cat-meow',
        label: 'Cat',
        imageUrl: _catImage,
        caption: 'Meow!',
        isCorrect: false,
      ),
      AnimalActivityOption(
        id: 'lion-roar',
        label: 'Lion',
        imageUrl: _lionImage,
        caption: 'Roar!',
        isCorrect: false,
      ),
    ],
    completionTitle: 'Puppy Partner',
    completionSubtitle: 'Best fetch buddy unlocked.',
    completionMascotUrl: _lionCompletion,
    badges: [
      AnimalBadgeReward(
        label: 'Buddy',
        icon: Icons.favorite,
        startColor: Color(0xFFE0F2FE),
        endColor: Color(0xFFBAE6FD),
      ),
    ],
    totalDiscoverySteps: 8,
  ),
  AnimalLessonMetadata(
    lessonId: 'animals-elephant',
    title: 'Elephant',
    listDescription: 'Big Trunks',
    heroHeadline: 'The Elephant is huge!',
    heroDescription: 'Elephants remember everything and trumpet proudly.',
    heroImageUrl: _elephantHero,
    cardImageUrl: _elephantImage,
    primaryColor: Color(0xFFBEE3F8),
    secondaryColor: Color(0xFFE0F2FE),
    soundLabel: 'Toot!',
    defaultStatus: LessonStatus.locked,
    order: 2,
    traits: [
      AnimalTraitCard(
        title: 'Long Trunk',
        description: 'Acts like a hand and a trumpet.',
        imageUrl: _traitTrunk,
        borderColor: Color(0xFF60A5FA),
        badgeColor: Color(0xFFE0F2FE),
      ),
      AnimalTraitCard(
        title: 'Large Ears',
        description: 'Wave hello and keep them cool.',
        imageUrl: _traitEars,
        borderColor: Color(0xFFF97316),
        badgeColor: Color(0xFFFFEDD5),
      ),
    ],
    activityPrompt: 'Who makes a big trumpet sound?',
    activityOptions: [
      AnimalActivityOption(
        id: 'elephant-toot',
        label: 'Elephant',
        imageUrl: _elephantImage,
        caption: 'Toot!',
        isCorrect: true,
      ),
      AnimalActivityOption(
        id: 'dog-bark',
        label: 'Dog',
        imageUrl: _dogImage,
        caption: 'Woof!',
        isCorrect: false,
      ),
      AnimalActivityOption(
        id: 'cat-meow',
        label: 'Cat',
        imageUrl: _catImage,
        caption: 'Meow!',
        isCorrect: false,
      ),
    ],
    completionTitle: 'Jungle Giant',
    completionSubtitle: 'You trumpeted with the herd.',
    completionMascotUrl: _lionCompletion,
    badges: [
      AnimalBadgeReward(
        label: 'Brave',
        icon: Icons.shield,
        startColor: Color(0xFFFDE68A),
        endColor: Color(0xFFF59E0B),
      ),
    ],
    totalDiscoverySteps: 10,
  ),
  AnimalLessonMetadata(
    lessonId: 'animals-lion',
    title: 'Lion',
    listDescription: 'King of the Jungle',
    heroHeadline: 'The Lion is bold!',
    heroDescription: 'Lions lead their pride with fierce roars.',
    heroImageUrl: _lionImage,
    cardImageUrl: _lionImage,
    primaryColor: Color(0xFFFECACA),
    secondaryColor: Color(0xFFFFE4E6),
    soundLabel: 'Roar!',
    defaultStatus: LessonStatus.locked,
    order: 3,
    traits: [
      AnimalTraitCard(
        title: 'Golden Mane',
        description: 'Shines like a crown.',
        imageUrl: _lionImage,
        borderColor: Color(0xFFF97316),
        badgeColor: Color(0xFFFFEDD5),
      ),
      AnimalTraitCard(
        title: 'Brave Heart',
        description: 'Guards every friend.',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDbqL2JCKTnqU4NCvY8QXBQXLSVG22dUrOW9T8JteqSLoq2rZdTCyAboLkFeF099qplwGhUZR88aKTkczrYlwS8rVFxiBa1yM0VPPdskkI8i2ahRe7lO0E0Jt0XzAIgtPPZD90JMQDWG4FXA1S-8naYTr61toH0VqxNXGL3Lqf7S9P8vRjDz25CNUjLo-JM9FbBtbPtXE4uoxPM2hEAEqLB9Q5fwnxxBmSfaTu7SOBEAZTPEsbCf3S9prGwDrCbAN8PAnVd6U8dUeU',
        borderColor: Color(0xFFFBBF24),
        badgeColor: Color(0xFFFFF7CD),
      ),
    ],
    activityPrompt: 'Tap the animal that says ROAR.',
    activityOptions: [
      AnimalActivityOption(
        id: 'lion-roar',
        label: 'Lion',
        imageUrl: _lionImage,
        caption: 'Roar! ',
        isCorrect: true,
      ),
      AnimalActivityOption(
        id: 'dog-bark',
        label: 'Dog',
        imageUrl: _dogImage,
        caption: 'Woof!',
        isCorrect: false,
      ),
      AnimalActivityOption(
        id: 'cat-meow',
        label: 'Cat',
        imageUrl: _catImage,
        caption: 'Meow!',
        isCorrect: false,
      ),
    ],
    completionTitle: 'Roar Royalty',
    completionSubtitle: 'Crowned in the savanna.',
    completionMascotUrl: _lionCompletion,
    badges: [
      AnimalBadgeReward(
        label: 'Royal',
        icon: Icons.workspace_premium,
        startColor: Color(0xFFFFE082),
        endColor: Color(0xFFF59E0B),
      ),
    ],
    totalDiscoverySteps: 12,
  ),
  AnimalLessonMetadata(
    lessonId: 'animals-monkey',
    title: 'Monkey',
    listDescription: 'Banana Time',
    heroHeadline: 'Monkeys swing high!',
    heroDescription: 'Playful climbers who giggle all day.',
    heroImageUrl: _monkeyImage,
    cardImageUrl: _monkeyImage,
    primaryColor: Color(0xFFFEF3C7),
    secondaryColor: Color(0xFFFFFBEB),
    soundLabel: 'Eee!',
    defaultStatus: LessonStatus.locked,
    order: 4,
    traits: [
      AnimalTraitCard(
        title: 'Quick Hands',
        description: 'Grab every banana.',
        imageUrl: _monkeyImage,
        borderColor: Color(0xFFF97316),
        badgeColor: Color(0xFFFFEDD5),
      ),
      AnimalTraitCard(
        title: 'Swinging Tail',
        description: 'Hangs from jungle vines.',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuB6foJiVYWBEDfCjhfWMoem6z7qWQIMhUPTvQ0P5PAVUGUyGPGCL9j404Jd4pNGembGObkFLDlETsKDpsLrDBw6NTiBx3Rrg9t5zKQXCdB2Pp1cfVz80XSfFgj21GhBzpFctaXUwkleEBNyhsMWHD7G6vFCd-0QhpaCnktoLvnQMWojHlM209sU2GXtdY-8VTXjEuqyQjfEd14nCMIQf5TUULm4MSuuKmXhimernyduYIhPkZItu171mxq-JjmV8VKFDSNYCv7a549',
        borderColor: Color(0xFFFB923C),
        badgeColor: Color(0xFFFFEDD5),
      ),
    ],
    activityPrompt: 'Who loves bananas the most?',
    activityOptions: [
      AnimalActivityOption(
        id: 'monkey-eee',
        label: 'Monkey',
        imageUrl: _monkeyImage,
        caption: 'Eee!',
        isCorrect: true,
      ),
      AnimalActivityOption(
        id: 'lion-roar',
        label: 'Lion',
        imageUrl: _lionImage,
        caption: 'Roar!',
        isCorrect: false,
      ),
      AnimalActivityOption(
        id: 'dog-bark',
        label: 'Dog',
        imageUrl: _dogImage,
        caption: 'Woof!',
        isCorrect: false,
      ),
    ],
    completionTitle: 'Jungle Jester',
    completionSubtitle: 'You swung through the canopy.',
    completionMascotUrl: _lionCompletion,
    badges: [
      AnimalBadgeReward(
        label: 'Giggles',
        icon: Icons.emoji_emotions,
        startColor: Color(0xFFFDE68A),
        endColor: Color(0xFFF97316),
      ),
    ],
    totalDiscoverySteps: 10,
  ),
];
