import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/child_profile.dart';
import 'firestore_paths.dart';

class ChildProfileRepository {
  ChildProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _childrenRef(String userId) {
    return _firestore.collection(FirestorePaths.childrenCollection(userId));
  }

  Stream<List<ChildProfile>> watchProfiles(String userId) {
    return _childrenRef(userId).orderBy('createdAt', descending: false).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ChildProfile.fromDoc(doc))
              .toList(growable: false),
        );
  }

  Stream<ChildProfile?> watchPrimaryProfile(String userId) {
    return _childrenRef(userId)
        .orderBy('createdAt', descending: false)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return ChildProfile.fromDoc(snapshot.docs.first);
    });
  }

  Stream<ChildProfile?> watchProfile(String userId, String childId) {
    return _childrenRef(userId).doc(childId).snapshots().map(
          (doc) => doc.exists ? ChildProfile.fromDoc(doc) : null,
        );
  }

  Future<ChildProfile?> fetchProfile(String userId, String childId) async {
    final doc = await _childrenRef(userId).doc(childId).get();
    if (!doc.exists) return null;
    return ChildProfile.fromDoc(doc);
  }

  Future<void> createProfile(String userId, ChildProfile profile) async {
    final doc = _childrenRef(userId).doc(profile.id);
    await doc.set({
      ...profile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<ChildProfile>> fetchProfiles(String userId) async {
    final snapshot = await _childrenRef(userId)
        .orderBy('createdAt', descending: false)
        .get();
    return snapshot.docs
        .map((doc) => ChildProfile.fromDoc(doc))
        .toList(growable: false);
  }

  String newProfileId(String userId) {
    return _childrenRef(userId).doc().id;
  }

  Future<ChildProfile?> ensureDefaultProfile(String userId) async {
    final profiles = await fetchProfiles(userId);
    if (profiles.isNotEmpty) {
      return profiles.first;
    }

    final docRef = _childrenRef(userId).doc();
    final defaultProfile = ChildProfile(
      id: docRef.id,
      name: 'Explorer',
      avatarKey: ChildProfile.defaultAvatars.first,
      level: 1,
      stars: 0,
      streak: 0,
      totalLessons: 0,
      totalQuizzes: 0,
      badges: const <String>[],
      birthday: null,
    );

    await docRef.set({
      ...defaultProfile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return defaultProfile;
  }

  Future<void> updateProfile(String userId, ChildProfile profile) async {
    await _childrenRef(userId)
        .doc(profile.id)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<void> incrementStats(
    String userId,
    String childId, {
    int starsDelta = 0,
    int lessonsDelta = 0,
    int quizzesDelta = 0,
    int streakDelta = 0,
  }) async {
    await _childrenRef(userId).doc(childId).set({
      'stars': FieldValue.increment(starsDelta),
      'totalLessons': FieldValue.increment(lessonsDelta),
      'totalQuizzes': FieldValue.increment(quizzesDelta),
      'streak': FieldValue.increment(streakDelta),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteProfile(String userId, String childId) async {
    await _childrenRef(userId).doc(childId).delete();
  }
}
