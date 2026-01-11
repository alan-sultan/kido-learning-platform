import 'package:cloud_firestore/cloud_firestore.dart';

enum LessonPlayStatus { locked, ready, inProgress, completed }

class ProgressRecord {
  final String id;
  final String lessonId;
  final LessonPlayStatus status;
  final int starsEarned;
  final int bestScore;
  final int attempts;
  final Timestamp? lastPlayedAt;
  final Timestamp? completedAt;

  const ProgressRecord({
    required this.id,
    required this.lessonId,
    required this.status,
    required this.starsEarned,
    required this.bestScore,
    required this.attempts,
    required this.lastPlayedAt,
    required this.completedAt,
  });

  factory ProgressRecord.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return ProgressRecord(
      id: doc.id,
      lessonId: data['lessonId'] as String? ?? doc.id,
      status: _statusFromString(data['status'] as String? ?? 'locked'),
      starsEarned: (data['starsEarned'] as num?)?.toInt() ?? 0,
      bestScore: (data['bestScore'] as num?)?.toInt() ?? 0,
      attempts: (data['attempts'] as num?)?.toInt() ?? 0,
      lastPlayedAt: data['lastPlayedAt'] as Timestamp?,
      completedAt: data['completedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'status': status.name,
      'starsEarned': starsEarned,
      'bestScore': bestScore,
      'attempts': attempts,
      'lastPlayedAt': lastPlayedAt,
      'completedAt': completedAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ProgressRecord copyWith({
    LessonPlayStatus? status,
    int? starsEarned,
    int? bestScore,
    int? attempts,
    Timestamp? lastPlayedAt,
    Timestamp? completedAt,
  }) {
    return ProgressRecord(
      id: id,
      lessonId: lessonId,
      status: status ?? this.status,
      starsEarned: starsEarned ?? this.starsEarned,
      bestScore: bestScore ?? this.bestScore,
      attempts: attempts ?? this.attempts,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  static LessonPlayStatus _statusFromString(String raw) {
    switch (raw) {
      case 'ready':
        return LessonPlayStatus.ready;
      case 'inProgress':
        return LessonPlayStatus.inProgress;
      case 'completed':
        return LessonPlayStatus.completed;
      case 'locked':
      default:
        return LessonPlayStatus.locked;
    }
  }
}
