import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics.dart';
import '../../core/theme.dart';
import '../../engine/catalog.dart';
import '../../engine/chroma_engine.dart';
import '../../engine/mediums.dart';
import '../../engine/mix_cost.dart';
import '../../engine/mix_session.dart';
import '../match/color_match.dart';

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
        final cost = ref.watch(mixCostProvider);
        final match = ref.watch(matchAnalysisProvider);

        Color displayColor;
        if (session.showUndertone) {
          displayColor = result?.undertone ?? Colors.grey;
        } else if (session.showDryingPreview && result != null) {
          final mod = session.mediumId != null
              ? (ref.watch(mediumLibraryProvider).valueOrNull
                      ?.get(session.mediumId!)
                      ?.dryingModifier ??
                  0.0)
              : 0.0;
          displayColor = DryingSimulator.driedColor(
            result.reflectance,
            session.binder,
            session.dryingTime,
            mediumModifier: mod,
          );
        } else {
          displayColor = result?.color ?? Colors.grey;
        }

        return Column(
          children: [
            if (match != null)
              MaterialBanner(
                content: Text(
                  'Target match: ΔE ${match.deltaE.toStringAsFixed(1)}',
                ),
                leading: Icon(
                  match.deltaE < 5 ? Icons.check_circle_outline : Icons.tune,
                  color: match.deltaE < 5 ? Colors.green : AppTheme.ochre,
                ),
                backgroundColor: match.deltaE < 5
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                actions: [
                  TextButton(
                    onPressed: () {},
                    child: Text(matchScoreLabel(match.deltaE)),
                  ),
                ],
              ),
            if (cost.warnings.isNotEmpty)
              MaterialBanner(
                content: Text(cost.warnings.join(' · ')),
                leading: const Icon(Icons.warning_amber),
                backgroundColor: Colors.orange.shade50,
                actions: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      cost.totalCost > 0
                          ? 'Est. \$${cost.totalCost.toStringAsFixed(2)}'
                          : 'View stock',
                    ),
                  ),
                ],
              ),
            Expanded(
              flex: 2,
              child: _SwatchPanel(
                color: displayColor,
                wetColor: result?.color,
                lab: result?.lab,
                background: session.swatchBackground,
                showUndertone: session.showUndertone,
                showDrying: session.showDryingPreview,
                onBackgroundChanged: notifier.setSwatchBackground,
                onToggleUndertone: notifier.toggleUndertone,
                onToggleDrying: notifier.toggleDryingPreview,
              ),
            ),
            _MediumSection(
              mediumId: session.mediumId,
              mediumAmount: session.mediumAmount,
              dryingTime: session.dryingTime,
              binder: session.binder,
              onMediumChanged: notifier.setMedium,
              onDryingTimeChanged: notifier.setDryingTime,
              onBinderChanged: notifier.setBinder,
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
                      hapticSelect();
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
    required this.background,
    required this.showUndertone,
    required this.onBackgroundChanged,
    required this.onToggleUndertone,
    this.wetColor,
    this.lab,
    this.showDrying = false,
    this.onToggleDrying,
  });

  final Color color;
  final Color? wetColor;
  final LabColor? lab;
  final SwatchBackground background;
  final bool showUndertone;
  final bool showDrying;
  final ValueChanged<SwatchBackground> onBackgroundChanged;
  final VoidCallback onToggleUndertone;
  final VoidCallback? onToggleDrying;

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final preview = Semantics(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showDrying && wetColor != null) ...[
                      _MiniSwatch(color: wetColor!, label: 'Wet'),
                      const SizedBox(width: 16),
                      const Icon(Icons.arrow_forward, size: 16),
                      const SizedBox(width: 16),
                    ],
                    _MiniSwatch(
                      color: color,
                      label: showDrying
                          ? 'Dry'
                          : (showUndertone ? 'Undertone' : 'Mix'),
                      large: !showDrying,
                    ),
                  ],
                ),
              ),
            ),
          );
          final controls = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: SwatchBackground.values.map((bg) {
                  return ChoiceChip(
                    label: Text(
                      bg.name[0].toUpperCase() + bg.name.substring(1),
                    ),
                    selected: background == bg,
                    onSelected: (_) => onBackgroundChanged(bg),
                  );
                }).toList(),
              ),
              TextButton.icon(
                onPressed: onToggleUndertone,
                icon: Icon(showUndertone ? Icons.layers : Icons.circle),
                label: Text(showUndertone ? 'Undertone' : 'Mass tone'),
              ),
              if (onToggleDrying != null)
                TextButton.icon(
                  onPressed: onToggleDrying,
                  icon: Icon(showDrying ? Icons.wb_sunny : Icons.water_drop),
                  label: Text(showDrying ? 'Drying preview' : 'Wet only'),
                ),
            ],
          );

          if (constraints.maxHeight < 300) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 120, child: preview),
                  const SizedBox(height: 8),
                  controls,
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(child: preview),
              const SizedBox(height: 8),
              controls,
            ],
          );
        },
      ),
    );
  }
}

class _MiniSwatch extends StatelessWidget {
  const _MiniSwatch({
    required this.color,
    required this.label,
    this.large = false,
  });

  final Color color;
  final String label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 120.0 : 64.0;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _MediumSection extends ConsumerWidget {
  const _MediumSection({
    required this.mediumId,
    required this.mediumAmount,
    required this.dryingTime,
    required this.binder,
    required this.onMediumChanged,
    required this.onDryingTimeChanged,
    required this.onBinderChanged,
  });

  final String? mediumId;
  final double mediumAmount;
  final DryingTime dryingTime;
  final String binder;
  final void Function(String?, double) onMediumChanged;
  final ValueChanged<DryingTime> onDryingTimeChanged;
  final ValueChanged<String> onBinderChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediumsAsync = ref.watch(mediumLibraryProvider);

    return mediumsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (lib) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Medium', style: Theme.of(context).textTheme.titleSmall),
            DropdownButtonFormField<String?>(
              initialValue: mediumId,
              decoration: const InputDecoration(
                hintText: 'No medium',
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                ...lib.all.map(
                  (m) => DropdownMenuItem(value: m.id, child: Text(m.name)),
                ),
              ],
              onChanged: (id) => onMediumChanged(id, mediumAmount),
            ),
            if (mediumId != null) ...[
              Slider(
                value: mediumAmount.clamp(0, 10),
                min: 0,
                max: 10,
                label: mediumAmount.toStringAsFixed(1),
                onChanged: (v) => onMediumChanged(mediumId, v),
              ),
            ],
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: binder,
                    decoration: const InputDecoration(
                      labelText: 'Binder',
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'acrylic', child: Text('Acrylic')),
                      DropdownMenuItem(value: 'oil', child: Text('Oil')),
                    ],
                    onChanged: (v) {
                      if (v != null) onBinderChanged(v);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<DryingTime>(
                    initialValue: dryingTime,
                    decoration: const InputDecoration(
                      labelText: 'Dry time',
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: DryingTime.oneDay,
                        child: Text('1 day'),
                      ),
                      DropdownMenuItem(
                        value: DryingTime.oneWeek,
                        child: Text('1 week'),
                      ),
                      DropdownMenuItem(
                        value: DryingTime.oneMonth,
                        child: Text('1 month'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) onDryingTimeChanged(v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
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
