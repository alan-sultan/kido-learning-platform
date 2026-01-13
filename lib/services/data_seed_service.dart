import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/firestore_paths.dart';

class DataSeedService {
  DataSeedService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> seedInitialContent() async {
    await _seedCategories();
    await _seedLessons();
    await _seedQuizzes();
  }

  Future<void> _seedCategories() async {
    final categoriesRef =
        _firestore.collection(FirestorePaths.categoriesCollection());
    for (final category in _categorySeeds) {
      final doc = categoriesRef.doc(category.id);
      final snapshot = await doc.get();
      if (!snapshot.exists) {
        await doc.set(category.toMap());
      }
    }
  }

  Future<void> _seedLessons() async {
    final lessonsRef =
        _firestore.collection(FirestorePaths.lessonsCollection());
    for (final lesson in _lessonSeeds) {
      final doc = lessonsRef.doc(lesson.id);
      final snapshot = await doc.get();
      if (!snapshot.exists) {
        await doc.set(lesson.toMap());
      }
    }
  }

  Future<void> _seedQuizzes() async {
    final quizzesRef =
        _firestore.collection(FirestorePaths.quizzesCollection());
    for (final quiz in _quizSeeds) {
      final quizDoc = quizzesRef.doc(quiz.id);
      final quizSnapshot = await quizDoc.get();
      if (!quizSnapshot.exists) {
        await quizDoc.set(quiz.toMap());
      }

      final questionsRef = _firestore
          .collection(FirestorePaths.quizQuestionsCollection(quiz.id));
      for (final question in quiz.questions) {
        final questionDoc = questionsRef.doc(question.id);
        final questionSnapshot = await questionDoc.get();
        if (!questionSnapshot.exists) {
          await questionDoc.set(question.toMap());
        }
      }
    }
  }
}

class _CategorySeed {
  const _CategorySeed({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.topic,
    required this.iconName,
    required this.colorHex,
    required this.order,
  });

  final String id;
  final String title;
  final String subtitle;
  final String topic;
  final String iconName;
  final String colorHex;
  final int order;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'topic': topic,
      'iconName': iconName,
      'colorHex': colorHex,
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class _LessonSeed {
  const _LessonSeed({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.illustration,
    required this.defaultStatus,
    required this.order,
    required this.content,
    required this.durationMinutes,
    required this.quizId,
  });

  final String id;
  final String categoryId;
  final String title;
  final String description;
  final String illustration;
  final String defaultStatus;
  final int order;
  final String content;
  final int durationMinutes;
  final String quizId;

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'illustration': illustration,
      'defaultStatus': defaultStatus,
      'order': order,
      'content': content,
      'durationMinutes': durationMinutes,
      'quizId': quizId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class _QuizSeed {
  const _QuizSeed({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    required this.durationSeconds,
    required this.questions,
  });

  final String id;
  final String lessonId;
  final String title;
  final String description;
  final int durationSeconds;
  final List<_QuestionSeed> questions;

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'title': title,
      'description': description,
      'questionCount': questions.length,
      'durationSeconds': durationSeconds,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class _QuestionSeed {
  const _QuestionSeed({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.hint,
    required this.order,
  });

  final String id;
  final String text;
  final List<Map<String, String>> options;
  final int correctIndex;
  final String hint;
  final int order;

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'options': options,
      'correctIndex': correctIndex,
      'illustration': 'default',
      'hint': hint,
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

const List<_CategorySeed> _categorySeeds = [
  _CategorySeed(
    id: 'alphabet',
    title: 'Alphabet Adventures',
    subtitle: 'Letters & sounds',
    topic: 'Language',
    iconName: 'book',
    colorHex: '#FFE082',
    order: 0,
  ),
  _CategorySeed(
    id: 'numbers',
    title: 'Number Quest',
    subtitle: 'Counting fun',
    topic: 'Math',
    iconName: 'numbers',
    colorHex: '#C5E1A5',
    order: 1,
  ),
  _CategorySeed(
    id: 'colors',
    title: 'Color Creators',
    subtitle: 'Mix & match hues',
    topic: 'Art',
    iconName: 'palette',
    colorHex: '#B39DDB',
    order: 2,
  ),
  _CategorySeed(
    id: 'animals',
    title: 'Animal Explorers',
    subtitle: 'Sounds & habitats',
    topic: 'Science',
    iconName: 'book',
    colorHex: '#A5D6A7',
    order: 3,
  ),
];

const List<_LessonSeed> _lessonSeeds = [
  _LessonSeed(
    id: 'alphabet-basics',
    categoryId: 'alphabet',
    title: 'Meet the Alphabet',
    description: 'Learn how letters look and sound.',
    illustration: 'lion',
    defaultStatus: 'ready',
    order: 0,
    content:
        'Practice tracing A, B, and C. Say the letter sounds aloud and match them to words.',
    durationMinutes: 5,
    quizId: 'quiz-alphabet-basics',
  ),
  _LessonSeed(
    id: 'alphabet-adventure',
    categoryId: 'alphabet',
    title: 'Letter Hunt',
    description: 'Spot letters in words and stories.',
    illustration: 'balloons',
    defaultStatus: 'ready',
    order: 1,
    content:
        'Read mini stories that hide letters. Circle the letters you hear and see.',
    durationMinutes: 6,
    quizId: 'quiz-alphabet-adventure',
  ),
  _LessonSeed(
    id: 'numbers-counting',
    categoryId: 'numbers',
    title: 'Counting Stars',
    description: 'Count objects up to 10.',
    illustration: 'numbers',
    defaultStatus: 'ready',
    order: 0,
    content:
        'Clap, count, and drag stars into the sky to practice numbers one through ten.',
    durationMinutes: 5,
    quizId: 'quiz-numbers-counting',
  ),
  _LessonSeed(
    id: 'numbers-compare',
    categoryId: 'numbers',
    title: 'More or Less',
    description: 'Compare groups of objects.',
    illustration: 'blocks',
    defaultStatus: 'ready',
    order: 1,
    content:
        'Look at two treasure piles and decide which is greater, smaller, or equal.',
    durationMinutes: 6,
    quizId: 'quiz-numbers-compare',
  ),
  _LessonSeed(
    id: 'colors-basics',
    categoryId: 'colors',
    title: 'Color Splash',
    description: 'Learn the primary colors.',
    illustration: 'balloons',
    defaultStatus: 'ready',
    order: 0,
    content:
        'Match bright paint splashes to their names and find objects that share the same color.',
    durationMinutes: 5,
    quizId: 'quiz-colors-basics',
  ),
  _LessonSeed(
    id: 'colors-mix',
    categoryId: 'colors',
    title: 'Mix & Paint',
    description: 'Blend colors to make new shades.',
    illustration: 'blocks',
    defaultStatus: 'ready',
    order: 1,
    content:
        'Drag droplets of paint together to discover what new color appears, then paint a simple picture.',
    durationMinutes: 6,
    quizId: 'quiz-colors-mix',
  ),
  _LessonSeed(
    id: 'animals-sounds',
    categoryId: 'animals',
    title: 'Jungle Jukebox',
    description: 'Match animals to their sounds.',
    illustration: 'lion',
    defaultStatus: 'ready',
    order: 0,
    content:
        'Play short roars, chirps, and growls, then tap the animal that makes each sound.',
    durationMinutes: 5,
    quizId: 'quiz-animals-sounds',
  ),
  _LessonSeed(
    id: 'animals-habitats',
    categoryId: 'animals',
    title: 'Habitat Helpers',
    description: 'Learn where animals live.',
    illustration: 'lion',
    defaultStatus: 'ready',
    order: 1,
    content:
        'Sort animals into the forest, ocean, or arctic and describe what makes each home special.',
    durationMinutes: 6,
    quizId: 'quiz-animals-habitats',
  ),
];

const List<_QuizSeed> _quizSeeds = [
  _QuizSeed(
    id: 'quiz-alphabet-basics',
    lessonId: 'alphabet-basics',
    title: 'Alphabet Warmup',
    description: 'Match letters to their sounds.',
    durationSeconds: 120,
    questions: [
      _QuestionSeed(
        id: 'alphabet-q1',
        text: 'Which letter makes the /a/ sound as in apple?',
        options: [
          {'label': 'A', 'value': 'A', 'colorHex': '#FFB74D'},
          {'label': 'B', 'value': 'B', 'colorHex': '#81C784'},
          {'label': 'C', 'value': 'C', 'colorHex': '#64B5F6'},
        ],
        correctIndex: 0,
        hint: 'Think of apples.',
        order: 0,
      ),
      _QuestionSeed(
        id: 'alphabet-q2',
        text: 'Which letter comes after C?',
        options: [
          {'label': 'D', 'value': 'D', 'colorHex': '#4DB6AC'},
          {'label': 'E', 'value': 'E', 'colorHex': '#BA68C8'},
          {'label': 'B', 'value': 'B', 'colorHex': '#F06292'},
        ],
        correctIndex: 0,
        hint: 'Say the alphabet aloud.',
        order: 1,
      ),
      _QuestionSeed(
        id: 'alphabet-q3',
        text: 'Match the lowercase letter to uppercase A.',
        options: [
          {'label': 'a', 'value': 'a', 'colorHex': '#FFD54F'},
          {'label': 'o', 'value': 'o', 'colorHex': '#90CAF9'},
          {'label': 'e', 'value': 'e', 'colorHex': '#A5D6A7'},
        ],
        correctIndex: 0,
        hint: 'They look the same shape.',
        order: 2,
      ),
    ],
  ),
  _QuizSeed(
    id: 'quiz-numbers-counting',
    lessonId: 'numbers-counting',
    title: 'Counting Stars',
    description: 'Count objects up to ten.',
    durationSeconds: 120,
    questions: [
      _QuestionSeed(
        id: 'numbers-q1',
        text: 'How many stars do you see? ⭐️⭐️⭐️',
        options: [
          {'label': '2', 'value': '2', 'colorHex': '#CE93D8'},
          {'label': '3', 'value': '3', 'colorHex': '#4DB6AC'},
          {'label': '4', 'value': '4', 'colorHex': '#FFB74D'},
        ],
        correctIndex: 1,
        hint: 'Count each star out loud.',
        order: 0,
      ),
      _QuestionSeed(
        id: 'numbers-q2',
        text: 'Which number is bigger?',
        options: [
          {'label': '5', 'value': '5', 'colorHex': '#9575CD'},
          {'label': '7', 'value': '7', 'colorHex': '#81C784'},
        ],
        correctIndex: 1,
        hint: 'Think about counting forward.',
        order: 1,
      ),
      _QuestionSeed(
        id: 'numbers-q3',
        text: 'What number comes before 10?',
        options: [
          {'label': '8', 'value': '8', 'colorHex': '#4FC3F7'},
          {'label': '9', 'value': '9', 'colorHex': '#FF8A65'},
          {'label': '11', 'value': '11', 'colorHex': '#AED581'},
        ],
        correctIndex: 1,
        hint: 'Count backward from 10.',
        order: 2,
      ),
    ],
  ),
  _QuizSeed(
    id: 'quiz-colors-basics',
    lessonId: 'colors-basics',
    title: 'Color Match',
    description: 'Name the primary colors.',
    durationSeconds: 120,
    questions: [
      _QuestionSeed(
        id: 'colors-q1',
        text: 'Which splash shows the color red?',
        options: [
          {'label': '🔴', 'value': 'red', 'colorHex': '#EF5350'},
          {'label': '🔵', 'value': 'blue', 'colorHex': '#42A5F5'},
          {'label': '🟢', 'value': 'green', 'colorHex': '#66BB6A'},
        ],
        correctIndex: 0,
        hint: 'Think of apples.',
        order: 0,
      ),
      _QuestionSeed(
        id: 'colors-q2',
        text: 'Which item is usually yellow?',
        options: [
          {'label': 'Sun', 'value': 'sun', 'colorHex': '#FFEE58'},
          {'label': 'Ocean', 'value': 'ocean', 'colorHex': '#4FC3F7'},
          {'label': 'Grass', 'value': 'grass', 'colorHex': '#81C784'},
        ],
        correctIndex: 0,
        hint: 'It shines in the sky.',
        order: 1,
      ),
      _QuestionSeed(
        id: 'colors-q3',
        text: 'Pick the color that mixes with blue to make green.',
        options: [
          {'label': 'Yellow', 'value': 'yellow', 'colorHex': '#FFD54F'},
          {'label': 'Red', 'value': 'red', 'colorHex': '#E57373'},
          {'label': 'Purple', 'value': 'purple', 'colorHex': '#BA68C8'},
        ],
        correctIndex: 0,
        hint: 'Think of paint mixing.',
        order: 2,
      ),
    ],
  ),
  _QuizSeed(
    id: 'quiz-alphabet-adventure',
    lessonId: 'alphabet-adventure',
    title: 'Letter Detective',
    description: 'Spot letters inside words.',
    durationSeconds: 150,
    questions: [
      _QuestionSeed(
        id: 'alphabet2-q1',
        text: 'Which word starts with the letter S?',
        options: [
          {'label': 'Sun', 'value': 'Sun', 'colorHex': '#FFD54F'},
          {'label': 'Tree', 'value': 'Tree', 'colorHex': '#4DB6AC'},
          {'label': 'Cloud', 'value': 'Cloud', 'colorHex': '#90CAF9'},
        ],
        correctIndex: 0,
        hint: 'Listen for the first sound.',
        order: 0,
      ),
      _QuestionSeed(
        id: 'alphabet2-q2',
        text: 'Select the word that ends with letter T.',
        options: [
          {'label': 'Hat', 'value': 'Hat', 'colorHex': '#F06292'},
          {'label': 'Map', 'value': 'Map', 'colorHex': '#A5D6A7'},
          {'label': 'Bee', 'value': 'Bee', 'colorHex': '#4FC3F7'},
        ],
        correctIndex: 0,
        hint: 'Say the ending sound.',
        order: 1,
      ),
      _QuestionSeed(
        id: 'alphabet2-q3',
        text: 'Which lowercase letter matches uppercase M?',
        options: [
          {'label': 'm', 'value': 'm', 'colorHex': '#BA68C8'},
          {'label': 'n', 'value': 'n', 'colorHex': '#FFB74D'},
          {'label': 'w', 'value': 'w', 'colorHex': '#64B5F6'},
        ],
        correctIndex: 0,
        hint: 'They have the same points.',
        order: 2,
      ),
    ],
  ),
  _QuizSeed(
    id: 'quiz-numbers-compare',
    lessonId: 'numbers-compare',
    title: 'More or Less',
    description: 'Compare quantities quickly.',
    durationSeconds: 150,
    questions: [
      _QuestionSeed(
        id: 'numbers2-q1',
        text: 'Which group is greater?',
        options: [
          {'label': '⚽⚽', 'value': '2', 'colorHex': '#4FC3F7'},
          {'label': '⚽⚽⚽', 'value': '3', 'colorHex': '#FFCC80'},
        ],
        correctIndex: 1,
        hint: 'Count each ball.',
        order: 0,
      ),
      _QuestionSeed(
        id: 'numbers2-q2',
        text: 'Fill in the blank: 4 __ 6',
        options: [
          {'label': '<', 'value': '<', 'colorHex': '#AED581'},
          {'label': '>', 'value': '>', 'colorHex': '#FF8A65'},
          {'label': '=', 'value': '=', 'colorHex': '#BA68C8'},
        ],
        correctIndex: 0,
        hint: 'Which side has more?',
        order: 1,
      ),
      _QuestionSeed(
        id: 'numbers2-q3',
        text: '7 is how many more than 5?',
        options: [
          {'label': '1', 'value': '1', 'colorHex': '#4DB6AC'},
          {'label': '2', 'value': '2', 'colorHex': '#FFB74D'},
          {'label': '3', 'value': '3', 'colorHex': '#90CAF9'},
        ],
        correctIndex: 1,
        hint: 'Count up from 5.',
        order: 2,
      ),
    ],
  ),
  _QuizSeed(
    id: 'quiz-colors-mix',
    lessonId: 'colors-mix',
    title: 'Color Chef',
    description: 'Blend colors to create new ones.',
    durationSeconds: 150,
    questions: [
      _QuestionSeed(
        id: 'colors2-q1',
        text: 'Red + Blue makes which color?',
        options: [
          {'label': 'Purple', 'value': 'purple', 'colorHex': '#AB47BC'},
          {'label': 'Orange', 'value': 'orange', 'colorHex': '#FFA726'},
          {'label': 'Green', 'value': 'green', 'colorHex': '#66BB6A'},
        ],
        correctIndex: 0,
        hint: 'Think of a grape smoothie.',
        order: 0,
      ),
      _QuestionSeed(
        id: 'colors2-q2',
        text: 'Which colors do you need to make orange?',
        options: [
          {'label': 'Red + Yellow', 'value': 'red-yellow', 'colorHex': '#FF7043'},
          {'label': 'Blue + Green', 'value': 'blue-green', 'colorHex': '#26C6DA'},
          {'label': 'Purple + Pink', 'value': 'purple-pink', 'colorHex': '#EC407A'},
        ],
        correctIndex: 0,
        hint: 'Think of a sunset.',
        order: 1,
      ),
      _QuestionSeed(
        id: 'colors2-q3',
        text: 'If you add white to red you get?',
        options: [
          {'label': 'Pink', 'value': 'pink', 'colorHex': '#F48FB1'},
          {'label': 'Brown', 'value': 'brown', 'colorHex': '#8D6E63'},
          {'label': 'Teal', 'value': 'teal', 'colorHex': '#4DB6AC'},
        ],
        correctIndex: 0,
        hint: 'Lightens the color.',
        order: 2,
      ),
    ],
  ),
  _QuizSeed(
    id: 'quiz-animals-sounds',
    lessonId: 'animals-sounds',
    title: 'Sound Safari',
    description: 'Match noises to animals.',
    durationSeconds: 120,
    questions: [
      _QuestionSeed(
        id: 'animals-q1',
        text: 'Which animal roars loudly?',
        options: [
          {'label': 'Lion', 'value': 'lion', 'colorHex': '#FFB74D'},
          {'label': 'Rabbit', 'value': 'rabbit', 'colorHex': '#CE93D8'},
          {'label': 'Butterfly', 'value': 'butterfly', 'colorHex': '#4FC3F7'},
        ],
        correctIndex: 0,
        hint: 'King of the jungle.',
        order: 0,
      ),
      _QuestionSeed(
        id: 'animals-q2',
        text: 'Who says “ribbit”?',
        options: [
          {'label': 'Frog', 'value': 'frog', 'colorHex': '#66BB6A'},
          {'label': 'Dog', 'value': 'dog', 'colorHex': '#90CAF9'},
          {'label': 'Cat', 'value': 'cat', 'colorHex': '#FFCC80'},
        ],
        correctIndex: 0,
        hint: 'Lives in ponds.',
        order: 1,
      ),
      _QuestionSeed(
        id: 'animals-q3',
        text: 'Which animal hoots at night?',
        options: [
          {'label': 'Owl', 'value': 'owl', 'colorHex': '#A1887F'},
          {'label': 'Horse', 'value': 'horse', 'colorHex': '#8D6E63'},
          {'label': 'Sheep', 'value': 'sheep', 'colorHex': '#B0BEC5'},
        ],
        correctIndex: 0,
        hint: 'Big eyes and silent wings.',
        order: 2,
      ),
    ],
  ),
  _QuizSeed(
    id: 'quiz-animals-habitats',
    lessonId: 'animals-habitats',
    title: 'Habitat Heroes',
    description: 'Place animals in their homes.',
    durationSeconds: 150,
    questions: [
      _QuestionSeed(
        id: 'animals2-q1',
        text: 'Where does a polar bear live?',
        options: [
          {'label': 'Arctic ice', 'value': 'arctic', 'colorHex': '#B3E5FC'},
          {'label': 'Desert', 'value': 'desert', 'colorHex': '#FFCC80'},
          {'label': 'Jungle', 'value': 'jungle', 'colorHex': '#81C784'},
        ],
        correctIndex: 0,
        hint: 'Very cold!',
        order: 0,
      ),
      _QuestionSeed(
        id: 'animals2-q2',
        text: 'Which animal belongs in the ocean?',
        options: [
          {'label': 'Dolphin', 'value': 'dolphin', 'colorHex': '#4FC3F7'},
          {'label': 'Giraffe', 'value': 'giraffe', 'colorHex': '#FFB74D'},
          {'label': 'Bear', 'value': 'bear', 'colorHex': '#A1887F'},
        ],
        correctIndex: 0,
        hint: 'Swims all day.',
        order: 1,
      ),
      _QuestionSeed(
        id: 'animals2-q3',
        text: 'Where would you find a camel?',
        options: [
          {'label': 'Desert', 'value': 'desert', 'colorHex': '#FFCC80'},
          {'label': 'Lake', 'value': 'lake', 'colorHex': '#4DD0E1'},
          {'label': 'Snow', 'value': 'snow', 'colorHex': '#B3E5FC'},
        ],
        correctIndex: 0,
        hint: 'Hot and sandy.',
        order: 2,
      ),
    ],
  ),
];
