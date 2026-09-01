import 'learn_screen.dart';

/// Persistence-free view of lesson progress used for ranking.
class LessonProgressSnapshot {
  const LessonProgressSnapshot({
    required this.completed,
    this.bestDeltaE,
  });

  final bool completed;
  final double? bestDeltaE;
}

class RankedLesson {
  const RankedLesson({
    required this.lesson,
    required this.isNext,
  });

  final Lesson lesson;
  final bool isNext;
}

/// Incomplete lessons first; among those, worse (higher) ΔE first so the
/// learner is sent back to the weakest mix. Unattempted counts as worst.
List<RankedLesson> rankLessons(
  List<Lesson> lessons,
  Map<String, LessonProgressSnapshot> progress,
) {
  final sorted = [...lessons]..sort((a, b) {
      final pa = progress[a.id];
      final pb = progress[b.id];
      final ca = pa?.completed ?? false;
      final cb = pb?.completed ?? false;
      if (ca != cb) return ca ? 1 : -1;
      final da = pa?.bestDeltaE ?? double.infinity;
      final db = pb?.bestDeltaE ?? double.infinity;
      final byDelta = db.compareTo(da);
      if (byDelta != 0) return byDelta;
      return lessons.indexOf(a).compareTo(lessons.indexOf(b));
    });

  String? nextId;
  for (final lesson in sorted) {
    if (!(progress[lesson.id]?.completed ?? false)) {
      nextId = lesson.id;
      break;
    }
  }

  return [
    for (final lesson in sorted)
      RankedLesson(lesson: lesson, isNext: lesson.id == nextId),
  ];
}

String? recommendedLessonId(List<RankedLesson> ranked) {
  for (final item in ranked) {
    if (item.isNext) return item.lesson.id;
  }
  return null;
}
