import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/child_profile.dart';
import '../repositories/child_profile_repository.dart';

class ChildProfileSelectionService extends ChangeNotifier {
  ChildProfileSelectionService({required ChildProfileRepository repository})
      : _repository = repository;

  final ChildProfileRepository _repository;
  StreamSubscription<ChildProfile?>? _activeProfileSub;
  ChildProfile? _activeProfile;
  String? _userId;
  String? _activeChildId;

  ChildProfile? get activeProfile => _activeProfile;
  String? get activeChildId => _activeChildId;
  bool get hasActiveProfile => _activeProfile != null;

  Future<void> initialize(String userId) async {
    if (_userId == userId && _activeProfileSub != null) {
      return;
    }
    await _bindToDefaultProfile(userId);
  }

  Future<void> selectProfile(String childId) async {
    final currentUserId = _userId;
    if (currentUserId == null) return;
    if (_activeChildId == childId && _activeProfileSub != null) return;
    await _bindToProfile(currentUserId, childId);
  }

  Future<void> refresh() async {
    final currentUserId = _userId;
    final childId = _activeChildId;
    if (currentUserId == null) return;
    if (childId == null) {
      await _bindToDefaultProfile(currentUserId);
    } else {
      await _bindToProfile(currentUserId, childId);
    }
  }

  Future<void> clear() async {
    await _activeProfileSub?.cancel();
    _activeProfileSub = null;
    _activeProfile = null;
    _userId = null;
    _activeChildId = null;
    notifyListeners();
  }

  Future<void> _bindToDefaultProfile(String userId) async {
    _userId = userId;
    final profile = await _repository.ensureDefaultProfile(userId);
    if (profile == null) return;
    await _bindToProfile(userId, profile.id, seed: profile);
  }

  Future<void> _bindToProfile(
    String userId,
    String childId, {
    ChildProfile? seed,
  }) async {
    await _activeProfileSub?.cancel();
    _activeChildId = childId;
    if (seed != null) {
      _activeProfile = seed;
      notifyListeners();
    }
    _activeProfileSub = _repository
        .watchProfile(userId, childId)
        .listen(_handleProfileUpdate);
  }

  void _handleProfileUpdate(ChildProfile? profile) {
    _activeProfile = profile;
    if (profile == null) {
      _activeChildId = null;
    }
    notifyListeners();
  }
}
