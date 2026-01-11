import 'package:cloud_firestore/cloud_firestore.dart';

enum LessonStatus { ready, start, locked }

enum LessonIllustration { balloons, lion, blocks, shapes, numbers }

class Lesson {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final LessonIllustration illustration;
  final LessonStatus defaultStatus;
  final int order;
  final String content;
  final int durationMinutes;
  final String quizId;

  const Lesson({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.illustration,
    required this.defaultStatus,
    required this.order,
    required this.content,
    required this.durationMinutes,
    required this.quizId,
  });

  factory Lesson.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Lesson(
      id: doc.id,
      categoryId: data['categoryId'] as String? ?? '',
      title: data['title'] as String? ?? 'Lesson',
      description: data['description'] as String? ?? '',
      illustration:
          _illustrationFromString(data['illustration'] as String? ?? 'lion'),
      defaultStatus:
          _statusFromString(data['defaultStatus'] as String? ?? 'ready'),
      order: (data['order'] as num?)?.toInt() ?? 0,
      content: data['content'] as String? ?? '',
      durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 5,
      quizId: data['quizId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'illustration': illustration.name,
      'defaultStatus': defaultStatus.name,
      'order': order,
      'content': content,
      'durationMinutes': durationMinutes,
      'quizId': quizId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static LessonIllustration _illustrationFromString(String value) {
    switch (value) {
      case 'balloons':
        return LessonIllustration.balloons;
      case 'blocks':
        return LessonIllustration.blocks;
      case 'shapes':
        return LessonIllustration.shapes;
      case 'numbers':
        return LessonIllustration.numbers;
      case 'lion':
      default:
        return LessonIllustration.lion;
    }
  }

  static LessonStatus _statusFromString(String value) {
    switch (value) {
      case 'start':
        return LessonStatus.start;
      case 'locked':
        return LessonStatus.locked;
      case 'ready':
      default:
        return LessonStatus.ready;
    }
  }
}
