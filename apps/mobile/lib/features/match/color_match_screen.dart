import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/haptics.dart';
import '../../core/theme.dart';
import '../../engine/chroma_engine.dart';
import '../../engine/mix_session.dart';
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
