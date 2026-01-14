import 'lesson.dart';
import 'progress_record.dart';

class LessonExperience {
  const LessonExperience({
    required this.lesson,
    required this.status,
    required this.progress,
  });

  final Lesson lesson;
  final LessonPlayStatus status;
  final ProgressRecord? progress;

  bool get isLocked => status == LessonPlayStatus.locked;

  bool get isCompleted => status == LessonPlayStatus.completed;

  bool get isInProgress => status == LessonPlayStatus.inProgress;
}

List<LessonExperience> buildLessonExperiences(
  List<Lesson> lessons,
  Map<String, ProgressRecord> progressMap,
) {
  final sorted = <Lesson>[...lessons]
    ..sort((a, b) => a.order.compareTo(b.order));

  final experiences = <LessonExperience>[];
  for (final lesson in sorted) {
    final record = progressMap[lesson.id];
    final previous = experiences.isEmpty ? null : experiences.last;
    final status = _resolveStatus(
      lesson,
      record,
      previous,
    );
    experiences.add(
      LessonExperience(
        lesson: lesson,
        status: status,
        progress: record,
      ),
    );
  }
  return List.unmodifiable(experiences);
}

LessonPlayStatus _resolveStatus(
  Lesson lesson,
  ProgressRecord? record,
  LessonExperience? previous,
) {
  if (record != null) {
    return record.status;
  }

  if (previous == null) {
    return _mapDefaultStatus(lesson.defaultStatus);
  }

  return previous.isCompleted
      ? LessonPlayStatus.ready
      : LessonPlayStatus.locked;
}

LessonPlayStatus _mapDefaultStatus(LessonStatus status) {
  switch (status) {
    case LessonStatus.start:
      return LessonPlayStatus.inProgress;
    case LessonStatus.locked:
      return LessonPlayStatus.locked;
    case LessonStatus.ready:
      return LessonPlayStatus.ready;
  }
}
