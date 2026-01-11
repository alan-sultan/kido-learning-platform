import 'package:cloud_firestore/cloud_firestore.dart';

enum LessonPlayStatus { locked, ready, inProgress, completed }

class ProgressRecord {
  final String id;
  final String lessonId;
  final LessonPlayStatus status;
  final int starsEarned;
  final int bestScore;
  final int totalQuestions;
  final int attempts;
  final Timestamp? lastPlayedAt;
  final Timestamp? completedAt;
  final int lastDurationSeconds;
  final int lastHintsUsed;
  final int fastestDurationSeconds;

  const ProgressRecord({
    required this.id,
    required this.lessonId,
    required this.status,
    required this.starsEarned,
    required this.bestScore,
    required this.totalQuestions,
    required this.attempts,
    required this.lastPlayedAt,
    required this.completedAt,
    required this.lastDurationSeconds,
    required this.lastHintsUsed,
    required this.fastestDurationSeconds,
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
      totalQuestions: (data['totalQuestions'] as num?)?.toInt() ?? 0,
      attempts: (data['attempts'] as num?)?.toInt() ?? 0,
      lastPlayedAt: data['lastPlayedAt'] as Timestamp?,
      completedAt: data['completedAt'] as Timestamp?,
      lastDurationSeconds: (data['lastDurationSeconds'] as num?)?.toInt() ?? 0,
      lastHintsUsed: (data['lastHintsUsed'] as num?)?.toInt() ?? 0,
      fastestDurationSeconds:
          (data['fastestDurationSeconds'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'status': status.name,
      'starsEarned': starsEarned,
      'bestScore': bestScore,
      'totalQuestions': totalQuestions,
      'attempts': attempts,
      'lastPlayedAt': lastPlayedAt,
      'completedAt': completedAt,
      'lastDurationSeconds': lastDurationSeconds,
      'lastHintsUsed': lastHintsUsed,
      'fastestDurationSeconds': fastestDurationSeconds,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ProgressRecord copyWith({
    LessonPlayStatus? status,
    int? starsEarned,
    int? bestScore,
    int? totalQuestions,
    int? attempts,
    Timestamp? lastPlayedAt,
    Timestamp? completedAt,
    int? lastDurationSeconds,
    int? lastHintsUsed,
    int? fastestDurationSeconds,
  }) {
    return ProgressRecord(
      id: id,
      lessonId: lessonId,
      status: status ?? this.status,
      starsEarned: starsEarned ?? this.starsEarned,
      bestScore: bestScore ?? this.bestScore,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      attempts: attempts ?? this.attempts,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      completedAt: completedAt ?? this.completedAt,
      lastDurationSeconds: lastDurationSeconds ?? this.lastDurationSeconds,
      lastHintsUsed: lastHintsUsed ?? this.lastHintsUsed,
      fastestDurationSeconds:
          fastestDurationSeconds ?? this.fastestDurationSeconds,
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
