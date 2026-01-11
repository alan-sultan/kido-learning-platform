import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/child_profile.dart';
import '../repositories/child_profile_repository.dart';
import '../repositories/learning_content_repository.dart';
import '../repositories/progress_repository.dart';
import 'auth_service.dart';
import 'child_profile_selection_service.dart';

/// Central place to access shared service singletons.
class AppServices {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final AuthService auth = AuthService();
  static final ChildProfileRepository childProfiles =
      ChildProfileRepository(firestore: firestore);
  static final ChildProfileSelectionService childSelection =
      ChildProfileSelectionService(repository: childProfiles);
  static final LearningContentRepository learningContent =
      LearningContentRepository(firestore: firestore);
  static final ProgressRepository progress =
      ProgressRepository(firestore: firestore);

  static Future<ChildProfile?> ensureDefaultChildProfile() async {
    final user = auth.currentUser;
    if (user == null) return null;
    return childProfiles.ensureDefaultProfile(user.uid);
  }
}
