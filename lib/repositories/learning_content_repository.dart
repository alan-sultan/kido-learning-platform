import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/seeded_learning_content.dart';
import '../models/learning_category.dart';
import '../models/lesson.dart';
import '../models/quiz.dart';
import 'firestore_paths.dart';

class LearningContentRepository {
  LearningContentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _firestore.collection(FirestorePaths.categoriesCollection());

  CollectionReference<Map<String, dynamic>> get _lessonsRef =>
      _firestore.collection(FirestorePaths.lessonsCollection());

  CollectionReference<Map<String, dynamic>> get _quizzesRef =>
      _firestore.collection(FirestorePaths.quizzesCollection());

  Stream<List<LearningCategory>> watchCategories() async* {
    try {
      await for (final snapshot in _categoriesRef.orderBy('order').snapshots()) {
        final categories = snapshot.docs
            .map((doc) => LearningCategory.fromMap(doc.id, doc.data()))
            .toList(growable: false);
        if (categories.isEmpty) {
          yield _seededCategories();
        } else {
          yield categories;
        }
      }
    } catch (_) {
      yield _seededCategories();
    }
  }

  Future<List<LearningCategory>> fetchCategories() async {
    try {
      final snapshot = await _categoriesRef.orderBy('order').get();
      final categories = snapshot.docs
          .map((doc) => LearningCategory.fromMap(doc.id, doc.data()))
          .toList(growable: false);
      if (categories.isEmpty) {
        return _seededCategories();
      }
      return categories;
    } catch (_) {
      return _seededCategories();
    }
  }

  Stream<List<Lesson>> watchLessons({String? categoryId}) async* {
    Query<Map<String, dynamic>> query = _lessonsRef;
    var needsClientSort = false;
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
      needsClientSort = true;
    } else {
      query = query.orderBy('order');
    }

    try {
      await for (final snapshot in query.snapshots()) {
        var lessons = snapshot.docs
            .map((doc) => Lesson.fromDoc(doc))
            .toList(growable: false);
        if (lessons.isEmpty) {
          lessons = _seededLessons(categoryId: categoryId);
        } else if (needsClientSort) {
          lessons = lessons.toList()
            ..sort((a, b) => a.order.compareTo(b.order));
        }
        yield lessons;
      }
    } catch (_) {
      yield _seededLessons(categoryId: categoryId);
    }
  }

  Future<List<Lesson>> fetchLessons({String? categoryId}) async {
    Query<Map<String, dynamic>> query = _lessonsRef;
    var needsClientSort = false;
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
      needsClientSort = true;
    } else {
      query = query.orderBy('order');
    }
    try {
      final snapshot = await query.get();
      var lessons = snapshot.docs.map(Lesson.fromDoc).toList(growable: false);
      if (lessons.isEmpty) {
        lessons = _seededLessons(categoryId: categoryId);
      } else if (needsClientSort) {
        lessons = lessons.toList()
          ..sort((a, b) => a.order.compareTo(b.order));
      }
      return lessons;
    } catch (_) {
      return _seededLessons(categoryId: categoryId);
    }
  }

  Future<Lesson?> fetchLesson(String lessonId) async {
    try {
      final doc = await _lessonsRef.doc(lessonId).get();
      if (!doc.exists) {
        return _seededLessonById(lessonId);
      }
      return Lesson.fromDoc(doc);
    } catch (_) {
      return _seededLessonById(lessonId);
    }
  }

  Stream<Lesson?> watchLesson(String lessonId) async* {
    try {
      await for (final doc in _lessonsRef.doc(lessonId).snapshots()) {
        if (doc.exists) {
          yield Lesson.fromDoc(doc);
        } else {
          yield _seededLessonById(lessonId);
        }
      }
    } catch (_) {
      yield _seededLessonById(lessonId);
    }
  }

  Future<Quiz?> fetchQuizById(String quizId) async {
    final doc = await _quizzesRef.doc(quizId).get();
    if (!doc.exists) return null;
    return Quiz.fromDoc(doc);
  }

  Future<Quiz?> fetchQuizForLesson(String lessonId) async {
    final snapshot = await _quizzesRef
        .where('lessonId', isEqualTo: lessonId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return Quiz.fromDoc(snapshot.docs.first);
  }

  Stream<List<QuizQuestion>> watchQuizQuestions(String quizId) {
    return _quizzesRef
        .doc(quizId)
        .collection('questions')
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => QuizQuestion.fromDoc(doc))
              .toList(growable: false),
        );
  }

  Future<List<QuizQuestion>> fetchQuizQuestions(String quizId) async {
    final snapshot = await _quizzesRef
        .doc(quizId)
        .collection('questions')
        .orderBy('order')
        .get();
    return snapshot.docs.map(QuizQuestion.fromDoc).toList(growable: false);
  }

  List<LearningCategory> _seededCategories() {
    return SeededLearningContent.categories;
  }

  List<Lesson> _seededLessons({String? categoryId}) {
    final source = SeededLearningContent.lessons;
    if (categoryId == null || categoryId.isEmpty) {
      final sorted = List<Lesson>.of(source)
        ..sort((a, b) => a.order.compareTo(b.order));
      return List<Lesson>.unmodifiable(sorted);
    }
    final filtered = List<Lesson>.of(
      source.where((lesson) => lesson.categoryId == categoryId),
    )
      ..sort((a, b) => a.order.compareTo(b.order));
    return List<Lesson>.unmodifiable(filtered);
  }

  Lesson? _seededLessonById(String lessonId) {
    for (final lesson in SeededLearningContent.lessons) {
      if (lesson.id == lessonId) {
        return lesson;
      }
    }
    return null;
  }
}
