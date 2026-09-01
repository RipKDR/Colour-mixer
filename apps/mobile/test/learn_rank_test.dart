import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/engine/chroma_engine.dart';
import 'package:chromastudio/features/learn/learn_rank.dart';
import 'package:chromastudio/features/learn/learn_screen.dart';

void main() {
  const beginner = Lesson(
    id: 'a',
    title: 'A',
    description: '',
    targetLab: LabColor(50, 0, 0),
    hintPigments: [],
    difficulty: 'Beginner',
  );
  const intermediate = Lesson(
    id: 'b',
    title: 'B',
    description: '',
    targetLab: LabColor(50, 0, 0),
    hintPigments: [],
    difficulty: 'Intermediate',
  );
  const advanced = Lesson(
    id: 'c',
    title: 'C',
    description: '',
    targetLab: LabColor(50, 0, 0),
    hintPigments: [],
    difficulty: 'Advanced',
  );

  test('incomplete lessons rank ahead of completed ones', () {
    final ranked = rankLessons(
      [advanced, beginner, intermediate],
      {
        'a': const LessonProgressSnapshot(completed: true, bestDeltaE: 1.2),
      },
    );

    expect(ranked.first.lesson.id, isNot('a'));
    expect(ranked.last.lesson.id, 'a');
  });

  test('next recommendation is the first incomplete lesson', () {
    final ranked = rankLessons(
      [beginner, intermediate, advanced],
      {
        'a': const LessonProgressSnapshot(completed: true, bestDeltaE: 0.8),
      },
    );

    expect(recommendedLessonId(ranked), 'b');
  });

  test('worse best-ΔE incomplete lessons come first', () {
    final ranked = rankLessons(
      [beginner, intermediate],
      {
        'a': const LessonProgressSnapshot(completed: false, bestDeltaE: 12),
        'b': const LessonProgressSnapshot(completed: false, bestDeltaE: 6),
      },
    );

    expect(ranked.first.lesson.id, 'a');
  });
}
