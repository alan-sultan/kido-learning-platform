class FirestorePaths {
  static String userDoc(String userId) => 'users/$userId';

  static String childrenCollection(String userId) => 'users/$userId/children';

  static String childDoc(String userId, String childId) =>
      'users/$userId/children/$childId';

  static String progressCollection(String userId, String childId) =>
      'users/$userId/children/$childId/progress';

  static String progressDoc(
    String userId,
    String childId,
    String lessonId,
  ) => 'users/$userId/children/$childId/progress/$lessonId';

  static String categoriesCollection() => 'categories';

  static String categoryDoc(String categoryId) => 'categories/$categoryId';

  static String lessonsCollection() => 'lessons';

  static String lessonDoc(String lessonId) => 'lessons/$lessonId';

  static String quizzesCollection() => 'quizzes';

  static String quizDoc(String quizId) => 'quizzes/$quizId';

  static String quizQuestionsCollection(String quizId) =>
      'quizzes/$quizId/questions';
}
