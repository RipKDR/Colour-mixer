import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/haptics.dart';
import '../../core/theme.dart';
import '../../engine/chroma_engine.dart';
import '../../engine/mix_session.dart';
import '../../engine/mix_solver.dart';
import '../inventory/inventory_provider.dart';
import '../learn/learn_screen.dart' show scoreLabel;
import 'color_match.dart';

class ColorMatchScreen extends ConsumerStatefulWidget {
  const ColorMatchScreen({super.key});

  @override
  ConsumerState<ColorMatchScreen> createState() => _ColorMatchScreenState();
}

class _ColorMatchScreenState extends ConsumerState<ColorMatchScreen> {
  double _l = 55;
  double _a = 0;
  double _b = 0;
  bool _onlyMyPaints = false;
  bool _solving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final existing = ref.read(colorTargetProvider);
      if (existing != null) {
        setState(() {
          _l = existing.lab.l;
          _a = existing.lab.a;
          _b = existing.lab.b;
        });
      }
    });
  }

  void _applyTarget() {
    ref.read(colorTargetProvider.notifier).state = ColorTarget(
      lab: LabColor(_l, _a, _b),
      name: 'Custom target',
    );
    hapticLight();
  }

  Future<void> _openEyedropper() async {
    await context.push('/match/eyedropper');
    if (!mounted) return;
    final picked = ref.read(colorTargetProvider);
    if (picked != null) {
      setState(() {
        _l = picked.lab.l;
        _a = picked.lab.a;
        _b = picked.lab.b;
      });
    }
  }

  Future<void> _suggestRecipe() async {
    final engine = ref.read(engineProvider).valueOrNull;
    if (engine == null) return;
    final target = LabColor(_l, _a, _b);

    Set<String>? restrictTo;
    if (_onlyMyPaints) {
      final items = await ref.read(inventoryProvider.future);
      if (!mounted) return;
      restrictTo = items.map((i) => i.pigmentId).toSet();
      if (restrictTo.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your inventory is empty — add tubes in Stock'),
          ),
        );
        return;
      }
    }

    setState(() => _solving = true);
    MixSuggestion? suggestion;
    try {
      suggestion = await compute(
        solveMixRequest,
        SolveRequest(
          pigments: {for (final p in engine.allPigments) p.id: p},
          target: target,
          restrictTo: restrictTo,
        ),
      );
    } finally {
      // Always re-enable the button, even if the isolate fails.
      if (mounted) setState(() => _solving = false);
    }
    if (!mounted) return;
    final result = suggestion;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pigments available to suggest from')),
      );
      return;
    }
    hapticMedium();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _SuggestionSheet(
        suggestion: result,
        engine: engine,
        onLoad: () {
          ref.read(mixSessionProvider.notifier).setEntriesFromPalette([
            for (final c in result.components)
              MixEntry(pigmentId: c.pigmentId, weight: c.weight * 10),
          ]);
          ref.read(colorTargetProvider.notifier).state = ColorTarget(
            lab: target,
            name: 'Suggested match',
          );
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analysis = ref.watch(matchAnalysisProvider);
    final result = ref.watch(mixSessionProvider).result;
    final targetColor = Colorimetry.srgbToColor(
      Colorimetry.labToSrgb(_l, _a, _b),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Match'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(colorTargetProvider.notifier).state = null;
              context.pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Set a target colour and compare your current mix using CIEDE2000 ΔE.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SwatchTile(
                  label: 'Target',
                  color: targetColor,
                  lab: LabColor(_l, _a, _b),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SwatchTile(
                  label: 'Your mix',
                  color: result?.color ?? Colors.grey,
                  lab: result?.lab,
                ),
              ),
            ],
          ),
          if (analysis != null) ...[
            const SizedBox(height: 20),
            Card(
              color: analysis.deltaE < 5
                  ? Colors.green.shade50
                  : analysis.deltaE < 10
                      ? Colors.orange.shade50
                      : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ΔE ${analysis.deltaE.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppTheme.deepBlue,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(matchScoreLabel(analysis.deltaE)),
                    if (analysis.isMetamericRisk)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.wb_incandescent_outlined,
                              size: 18,
                              color: Colors.orange.shade800,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Metamerism risk: shifts up to '
                                '${analysis.maxIlluminantDeltaE.toStringAsFixed(1)} ΔE '
                                'under other lights. Check the light booth.',
                                style: TextStyle(color: Colors.orange.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text('Target Lab', style: Theme.of(context).textTheme.titleSmall),
          _LabSlider(
            label: 'L (lightness)',
            value: _l,
            min: 0,
            max: 100,
            onChanged: (v) => setState(() => _l = v),
          ),
          _LabSlider(
            label: 'a (green ↔ red)',
            value: _a,
            min: -80,
            max: 80,
            onChanged: (v) => setState(() => _a = v),
          ),
          _LabSlider(
            label: 'b (blue ↔ yellow)',
            value: _b,
            min: -80,
            max: 80,
            onChanged: (v) => setState(() => _b = v),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label: const Text('Skin base'),
                onPressed: () => setState(() {
                  _l = 68;
                  _a = 18;
                  _b = 22;
                }),
              ),
              ActionChip(
                label: const Text('Sky blue'),
                onPressed: () => setState(() {
                  _l = 52;
                  _a = -8;
                  _b = -35;
                }),
              ),
              ActionChip(
                label: const Text('Leaf green'),
                onPressed: () => setState(() {
                  _l = 52;
                  _a = -38;
                  _b = 42;
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _applyTarget,
            icon: const Icon(Icons.gps_fixed),
            label: const Text('Set as match target'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.deepBlue,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openEyedropper,
                  icon: const Icon(Icons.colorize),
                  label: const Text('From photo'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _solving ? null : _suggestRecipe,
                  icon: _solving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_fix_high),
                  label: Text(_solving ? 'Solving…' : 'Suggest recipe'),
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('Only suggest from my paints'),
            subtitle: const Text('Uses your Stock inventory'),
            value: _onlyMyPaints,
            onChanged: (v) => setState(() => _onlyMyPaints = v),
          ),
          if (analysis != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                scoreLabel(analysis.deltaE),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
        ],
      ),
    );
  }
}

class _SuggestionSheet extends StatelessWidget {
  const _SuggestionSheet({
    required this.suggestion,
    required this.engine,
    required this.onLoad,
  });

  final MixSuggestion suggestion;
  final ChromaEngine engine;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: suggestion.result.color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggested recipe',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Predicted ΔE ${suggestion.deltaE.toStringAsFixed(1)} — '
                      '${matchScoreLabel(suggestion.deltaE)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...suggestion.components.map((c) {
            final pigment = engine.getPigment(c.pigmentId);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: pigment?.color ?? Colors.grey,
                radius: 14,
              ),
              title: Text(pigment?.name ?? c.pigmentId),
              trailing: Text(
                '${(c.weight * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            );
          }),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onLoad,
            icon: const Icon(Icons.download),
            label: const Text('Load into current mix'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.deepBlue,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwatchTile extends StatelessWidget {
  const _SwatchTile({
    required this.label,
    required this.color,
    this.lab,
  });

  final String label;
  final Color color;
  final LabColor? lab;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 88,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.ochre.withValues(alpha: 0.4)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        if (lab != null)
          Text(
            'L${lab!.l.toStringAsFixed(0)} '
            'a${lab!.a.toStringAsFixed(0)} '
            'b${lab!.b.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
      ],
    );
  }
}

class _LabSlider extends StatelessWidget {
  const _LabSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(0)}'),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: (v) {
            hapticSelect();
            onChanged(v);
          },
        ),
      ],
    );
  }
}
