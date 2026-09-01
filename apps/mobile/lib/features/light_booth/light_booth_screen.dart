import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../engine/chroma_engine.dart';
import '../../engine/mix_session.dart';

class LightBoothScreen extends ConsumerWidget {
  const LightBoothScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(mixSessionProvider);
    final result = session.result;
    final reflectance = result?.reflectance ??
        List<double>.filled(Colorimetry.spectrumSamples, 0.5);

    return Scaffold(
      appBar: AppBar(title: const Text('Virtual Light Booth')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'See how your current mix shifts under different lighting. '
            'Spectral reflectance is re-computed per illuminant.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (result != null)
            _ReferenceSwatch(
              color: result.color,
              lab: result.lab,
              label: 'Reference (D65)',
            ),
          const SizedBox(height: 16),
          ...Illuminant.values.map((illuminant) {
            final color = Colorimetry.spectrumToColorUnder(reflectance, illuminant);
            final lab = Colorimetry.spectrumToLabUnder(reflectance, illuminant);
            final deltaE = result != null
                ? Colorimetry.ciede2000(result.lab, lab)
                : 0.0;
            return _IlluminantCard(
              illuminant: illuminant,
              color: color,
              lab: lab,
              deltaE: deltaE,
            );
          }),
        ],
      ),
    );
  }
}

class _ReferenceSwatch extends StatelessWidget {
  const _ReferenceSwatch({
    required this.color,
    required this.lab,
    required this.label,
  });

  final Color color;
  final LabColor lab;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 24),
        title: Text(label),
        subtitle: Text(
          'L ${lab.l.toStringAsFixed(0)} · '
          'a ${lab.a.toStringAsFixed(0)} · '
          'b ${lab.b.toStringAsFixed(0)}',
        ),
      ),
    );
  }
}

class _IlluminantCard extends StatelessWidget {
  const _IlluminantCard({
    required this.illuminant,
    required this.color,
    required this.lab,
    required this.deltaE,
  });

  final Illuminant illuminant;
  final Color color;
  final LabColor lab;
  final double deltaE;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.ochre.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${illuminant.label} (${illuminant.code})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    illuminant.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'L ${lab.l.toStringAsFixed(0)} · '
                    'a ${lab.a.toStringAsFixed(0)} · '
                    'b ${lab.b.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  if (deltaE > 0.5)
                    Text(
                      'ΔE ${deltaE.toStringAsFixed(1)} vs D65',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: deltaE > 3
                                ? Colors.orange.shade800
                                : null,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
