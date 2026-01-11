import 'package:cloud_firestore/cloud_firestore.dart';

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

  Stream<List<LearningCategory>> watchCategories() {
    return _categoriesRef.orderBy('order').snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => LearningCategory.fromMap(doc.id, doc.data()),
              )
              .toList(growable: false),
        );
  }

  Future<List<LearningCategory>> fetchCategories() async {
    final snapshot = await _categoriesRef.orderBy('order').get();
    return snapshot.docs
        .map((doc) => LearningCategory.fromMap(doc.id, doc.data()))
        .toList(growable: false);
  }

  Stream<List<Lesson>> watchLessons({String? categoryId}) {
    Query<Map<String, dynamic>> query = _lessonsRef.orderBy('order');
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Lesson.fromDoc(doc))
              .toList(growable: false),
        );
  }

  Future<List<Lesson>> fetchLessons({String? categoryId}) async {
    Query<Map<String, dynamic>> query = _lessonsRef.orderBy('order');
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    final snapshot = await query.get();
    return snapshot.docs.map(Lesson.fromDoc).toList(growable: false);
  }

  Future<Lesson?> fetchLesson(String lessonId) async {
    final doc = await _lessonsRef.doc(lessonId).get();
    if (!doc.exists) return null;
    return Lesson.fromDoc(doc);
  }

  Stream<Lesson?> watchLesson(String lessonId) {
    return _lessonsRef.doc(lessonId).snapshots().map(
          (doc) => doc.exists ? Lesson.fromDoc(doc) : null,
        );
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
}
