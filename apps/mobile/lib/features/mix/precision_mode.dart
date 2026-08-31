import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../engine/chroma_engine.dart';
import '../../engine/mix_session.dart';

class PrecisionModeScreen extends ConsumerWidget {
  const PrecisionModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineAsync = ref.watch(engineProvider);
    return engineAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (_) {
        final session = ref.watch(mixSessionProvider);
        final notifier = ref.read(mixSessionProvider.notifier);
        final result = session.result;
        final displayColor = session.showUndertone
            ? result?.undertone ?? Colors.grey
            : result?.color ?? Colors.grey;

        return Column(
          children: [
            Expanded(
              flex: 2,
              child: _SwatchPanel(
                color: displayColor,
                lab: result?.lab,
                background: session.swatchBackground,
                showUndertone: session.showUndertone,
                onBackgroundChanged: notifier.setSwatchBackground,
                onToggleUndertone: notifier.toggleUndertone,
              ),
            ),
            Expanded(
              flex: 3,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: session.entries.length,
                itemBuilder: (context, index) {
                  final entry = session.entries[index];
                  final pigment = ref
                      .watch(engineProvider)
                      .requireValue
                      .getPigment(entry.pigmentId);
                  if (pigment == null) return const SizedBox.shrink();
                  final ratios = formatRatios(
                    session.weights,
                    session.quantityUnit,
                  );
                  final ratio = ratios[index];
                  return _PigmentSlider(
                    pigment: pigment,
                    weight: entry.weight,
                    ratio: ratio,
                    onChanged: (w) {
                      HapticFeedback.selectionClick();
                      notifier.setWeight(index, w);
                    },
                    onRemove: session.entries.length > 1
                        ? () => notifier.removePigment(index)
                        : null,
                  );
                },
              ),
            ),
            _MixControls(
              lockRatios: session.lockRatios,
              onToggleLock: notifier.toggleLockRatios,
              onAddPigment: () => _showAddPigment(context, ref),
            ),
          ],
        );
      },
    );
  }

  void _showAddPigment(BuildContext context, WidgetRef ref) {
    final engine = ref.read(engineProvider).requireValue;
    final session = ref.read(mixSessionProvider);
    final used = session.entries.map((e) => e.pigmentId).toSet();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        children: engine.allPigments
            .where((p) => !used.contains(p.id))
            .map(
              (p) => ListTile(
                leading: CircleAvatar(backgroundColor: p.color),
                title: Text(p.name),
                subtitle: Text(p.pigmentCodes.join(', ')),
                onTap: () {
                  ref.read(mixSessionProvider.notifier).addPigment(p.id);
                  Navigator.pop(ctx);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SwatchPanel extends StatelessWidget {
  const _SwatchPanel({
    required this.color,
    required this.lab,
    required this.background,
    required this.showUndertone,
    required this.onBackgroundChanged,
    required this.onToggleUndertone,
  });

  final Color color;
  final LabColor? lab;
  final SwatchBackground background;
  final bool showUndertone;
  final ValueChanged<SwatchBackground> onBackgroundChanged;
  final VoidCallback onToggleUndertone;

  Color get _bgColor {
    switch (background) {
      case SwatchBackground.white:
        return Colors.white;
      case SwatchBackground.black:
        return Colors.black;
      case SwatchBackground.grey:
        return const Color(0xFF808080);
      case SwatchBackground.custom:
        return const Color(0xFFE8E0D5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Semantics(
              label: lab != null
                  ? 'Mixed colour L ${lab!.l.toStringAsFixed(1)}, '
                      'a ${lab!.a.toStringAsFixed(1)}, '
                      'b ${lab!.b.toStringAsFixed(1)}'
                  : 'Mixed colour swatch',
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.ochre.withValues(alpha: 0.5)),
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: SwatchBackground.values.map((bg) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(bg.name[0].toUpperCase() + bg.name.substring(1)),
                  selected: background == bg,
                  onSelected: (_) => onBackgroundChanged(bg),
                ),
              );
            }).toList(),
          ),
          TextButton.icon(
            onPressed: onToggleUndertone,
            icon: Icon(showUndertone ? Icons.layers : Icons.circle),
            label: Text(showUndertone ? 'Undertone' : 'Mass tone'),
          ),
        ],
      ),
    );
  }
}

class _PigmentSlider extends StatelessWidget {
  const _PigmentSlider({
    required this.pigment,
    required this.weight,
    required this.ratio,
    required this.onChanged,
    this.onRemove,
  });

  final PigmentModel pigment;
  final double weight;
  final RatioDisplay ratio;
  final ValueChanged<double> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 14, backgroundColor: pigment.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pigment.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onRemove,
                  ),
              ],
            ),
            Slider(
              value: weight.clamp(0, 10),
              min: 0,
              max: 10,
              divisions: 100,
              onChanged: onChanged,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${ratio.parts} parts'),
                Text(ratio.percent),
                Text(ratio.grams),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MixControls extends StatelessWidget {
  const _MixControls({
    required this.lockRatios,
    required this.onToggleLock,
    required this.onAddPigment,
  });

  final bool lockRatios;
  final VoidCallback onToggleLock;
  final VoidCallback onAddPigment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: onToggleLock,
            icon: Icon(lockRatios ? Icons.lock : Icons.lock_open),
            tooltip: 'Lock ratios',
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: onAddPigment,
            icon: const Icon(Icons.add),
            label: const Text('Add pigment'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.deepBlue,
            ),
          ),
        ],
      ),
    );
  }
}
