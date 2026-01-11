import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/progress_record.dart';
import 'firestore_paths.dart';

class ProgressRepository {
  ProgressRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _progressRef(
    String userId,
    String childId,
  ) {
    return _firestore.collection(
      FirestorePaths.progressCollection(userId, childId),
    );
  }

  Stream<List<ProgressRecord>> watchProgress(
    String userId,
    String childId,
  ) {
    return _progressRef(userId, childId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProgressRecord.fromDoc(doc))
              .toList(growable: false),
        );
  }

  Stream<ProgressRecord?> watchLessonProgress(
    String userId,
    String childId,
    String lessonId,
  ) {
    return _progressRef(userId, childId)
        .doc(lessonId)
        .snapshots()
        .map((doc) => doc.exists ? ProgressRecord.fromDoc(doc) : null);
  }

  Future<ProgressRecord?> fetchLessonProgress(
    String userId,
    String childId,
    String lessonId,
  ) async {
    final doc = await _progressRef(userId, childId).doc(lessonId).get();
    if (!doc.exists) return null;
    return ProgressRecord.fromDoc(doc);
  }

  Future<void> upsertProgress(
    String userId,
    String childId,
    ProgressRecord record,
  ) async {
    await _progressRef(userId, childId)
        .doc(record.lessonId)
        .set(record.toMap(), SetOptions(merge: true));
  }

  Future<void> recordPlayEvent({
    required String userId,
    required String childId,
    required String lessonId,
    required LessonPlayStatus status,
    int starsEarned = 0,
    int bestScore = 0,
    bool completed = false,
  }) async {
    await _progressRef(userId, childId).doc(lessonId).set({
      'lessonId': lessonId,
      'status': status.name,
      'starsEarned': FieldValue.increment(starsEarned),
      'bestScore': FieldValue.increment(bestScore),
      'attempts': FieldValue.increment(1),
      'lastPlayedAt': FieldValue.serverTimestamp(),
      if (completed) 'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
