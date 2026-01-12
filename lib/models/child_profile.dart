import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/avatar_catalog.dart';

class ChildProfile {
  final String id;
  final String name;
  final String avatarKey;
  final int level;
  final int stars;
  final int streak;
  final int totalLessons;
  final int totalQuizzes;
  final List<String> badges;
  final Timestamp? birthday;

  const ChildProfile({
    required this.id,
    required this.name,
    required this.avatarKey,
    required this.level,
    required this.stars,
    required this.streak,
    required this.totalLessons,
    required this.totalQuizzes,
    required this.badges,
    required this.birthday,
  });

  factory ChildProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ChildProfile(
      id: doc.id,
      name: data['name'] as String? ?? 'Explorer',
      avatarKey: data['avatarKey'] as String? ?? 'bear',
      level: (data['level'] as num?)?.toInt() ?? 1,
      stars: (data['stars'] as num?)?.toInt() ?? 0,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      totalLessons: (data['totalLessons'] as num?)?.toInt() ?? 0,
      totalQuizzes: (data['totalQuizzes'] as num?)?.toInt() ?? 0,
      badges: (data['badges'] as List<dynamic>? ?? const [])
          .map((badge) => badge.toString())
          .toList(),
      birthday: data['birthday'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarKey': avatarKey,
      'level': level,
      'stars': stars,
      'streak': streak,
      'totalLessons': totalLessons,
      'totalQuizzes': totalQuizzes,
      'badges': badges,
      'birthday': birthday,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ChildProfile copyWith({
    String? name,
    String? avatarKey,
    int? level,
    int? stars,
    int? streak,
    int? totalLessons,
    int? totalQuizzes,
    List<String>? badges,
    Timestamp? birthday,
  }) {
    return ChildProfile(
      id: id,
      name: name ?? this.name,
      avatarKey: avatarKey ?? this.avatarKey,
      level: level ?? this.level,
      stars: stars ?? this.stars,
      streak: streak ?? this.streak,
      totalLessons: totalLessons ?? this.totalLessons,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      badges: badges ?? this.badges,
      birthday: birthday ?? this.birthday,
    );
  }

  static List<String> get defaultAvatars => AvatarCatalog.keys;
}
