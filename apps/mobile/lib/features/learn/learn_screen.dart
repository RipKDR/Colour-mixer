import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../engine/chroma_engine.dart';
import '../../engine/mix_session.dart';
import '../recipes/database.dart';

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.targetLab,
    required this.hintPigments,
    required this.difficulty,
  });

  final String id;
  final String title;
  final String description;
  final LabColor targetLab;
  final List<String> hintPigments;
  final String difficulty;
}

const lessons = [
  Lesson(
    id: 'primary_green',
    title: 'Mix a Primary Green',
    description:
        'Combine a blue and a yellow to match the target green swatch. '
        'Aim for ΔE < 5 for a passing score.',
    targetLab: LabColor(52, -38, 42),
    hintPigments: ['ultramarine_blue', 'hansa_yellow'],
    difficulty: 'Beginner',
  ),
  Lesson(
    id: 'earth_shadow',
    title: 'Earth Shadow Neutral',
    description:
        'Mix an earthy shadow colour using a warm earth and a cool blue. '
        'Shadows are rarely pure grey — they lean warm or cool.',
    targetLab: LabColor(35, 8, 5),
    hintPigments: ['burnt_sienna', 'ultramarine_blue'],
    difficulty: 'Intermediate',
  ),
  Lesson(
    id: 'skin_base',
    title: 'Portrait Skin Base',
    description:
        'Build a basic skin tone from red, yellow earth, and white. '
        'Adjust ratios until your mix is close to the target.',
    targetLab: LabColor(68, 18, 22),
    hintPigments: ['cadmium_red_light', 'yellow_ochre', 'titanium_white'],
    difficulty: 'Advanced',
  ),
];

String scoreLabel(double deltaE) {
  if (deltaE < 2) return 'Excellent — gallery quality!';
  if (deltaE < 5) return 'Great match!';
  if (deltaE < 10) return 'Good — keep refining';
  return 'Keep mixing — adjust your ratios';
}

Color targetColor(LabColor lab) {
  final srgb = Colorimetry.labToSrgb(lab.l, lab.a, lab.b);
  return Colorimetry.srgbToColor(srgb);
}

final lessonProgressProvider = FutureProvider<Map<String, LessonProgressData>>((ref) async {
  final rows = await ref.watch(databaseProvider).getAllLessonProgress();
  return {for (final r in rows) r.lessonId: r};
});

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(lessonProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Colour Theory Challenges',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.deepBlue,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mix colours to match each target. Scoring uses CIEDE2000 ΔE — '
            'the same metric used in professional colour matching.',
          ),
          const SizedBox(height: 24),
          ...lessons.map((lesson) {
            final progress = progressAsync.valueOrNull?[lesson.id];
            return _LessonCard(
              lesson: lesson,
              completed: progress?.completed ?? false,
              bestDeltaE: progress?.bestDeltaE,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonDetailScreen(lesson: lesson),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.completed,
    required this.onTap,
    this.bestDeltaE,
  });

  final Lesson lesson;
  final bool completed;
  final double? bestDeltaE;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: targetColor(lesson.targetLab),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.ochre.withValues(alpha: 0.4)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        if (completed)
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ),
                    Text(lesson.difficulty,
                        style: Theme.of(context).textTheme.labelSmall),
                    if (bestDeltaE != null)
                      Text('Best ΔE: ${bestDeltaE!.toStringAsFixed(1)}'),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({super.key, required this.lesson});
  final Lesson lesson;

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  double? _lastDeltaE;

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final result = ref.watch(mixSessionProvider).result;
    final target = lesson.targetLab;

    if (result != null) {
      final deltaE = Colorimetry.ciede2000(result.lab, target);
      if (_lastDeltaE == null || (deltaE - _lastDeltaE!).abs() > 0.1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _lastDeltaE = deltaE);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(lesson.description),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SwatchColumn(label: 'Target', color: targetColor(target)),
              const Icon(Icons.compare_arrows),
              _SwatchColumn(
                label: 'Your mix',
                color: result?.color ?? Colors.grey,
              ),
            ],
          ),
          if (_lastDeltaE != null) ...[
            const SizedBox(height: 24),
            Text(
              'ΔE = ${_lastDeltaE!.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.deepBlue,
                  ),
              textAlign: TextAlign.center,
            ),
            Text(
              scoreLabel(_lastDeltaE!),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: lesson.hintPigments
                .map((id) => ActionChip(
                      label: Text('Load $id'),
                      onPressed: () {
                        ref.read(mixSessionProvider.notifier).setEntriesFromPalette(
                              id == lesson.hintPigments.first
                                  ? lesson.hintPigments
                                      .map((p) => MixEntry(pigmentId: p))
                                      .toList()
                                  : [
                                      MixEntry(pigmentId: id),
                                    ],
                            );
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: result == null || _lastDeltaE == null
                ? null
                : () => _submitScore(_lastDeltaE!),
            icon: const Icon(Icons.check),
            label: const Text('Submit score'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: AppTheme.deepBlue,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.go('/mix'),
            child: const Text('Open Mix screen to adjust'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitScore(double deltaE) async {
    final db = ref.read(databaseProvider);
    final existing = (await db.getAllLessonProgress())
        .where((r) => r.lessonId == widget.lesson.id)
        .firstOrNull;
    final attempts = (existing?.attempts ?? 0) + 1;
    final best = existing?.bestDeltaE == null
        ? deltaE
        : (deltaE < existing!.bestDeltaE! ? deltaE : existing.bestDeltaE!);

    await db.upsertLessonProgress(
      LessonProgressCompanion.insert(
        lessonId: widget.lesson.id,
        // A worse re-attempt must never take away an earned completion.
        completed: Value((existing?.completed ?? false) || deltaE < 5),
        bestDeltaE: Value(best),
        attempts: Value(attempts),
      ),
    );
    if (!mounted) return;
    ref.invalidate(lessonProgressProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(scoreLabel(deltaE))),
    );
  }
}

class _SwatchColumn extends StatelessWidget {
  const _SwatchColumn({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
