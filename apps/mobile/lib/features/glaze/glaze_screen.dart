import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../engine/chroma_engine.dart';
import '../../engine/mediums.dart';
import '../../engine/mix_session.dart';

class GlazeScreen extends ConsumerStatefulWidget {
  const GlazeScreen({super.key});

  @override
  ConsumerState<GlazeScreen> createState() => _GlazeScreenState();
}

class _GlazeScreenState extends ConsumerState<GlazeScreen> {
  int _layers = 3;
  double _opacity = 0.25;
  Color _baseColor = const Color(0xFFF5E6D3);

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(mixSessionProvider).result;
    final glazeReflectance = result?.reflectance ??
        List<double>.filled(Colorimetry.spectrumSamples, 0.5);
    // Crude 3-band spectrum from the base colour so hue survives (a flat
    // spectrum from one channel would turn a blue base into gray).
    final baseReflectance = List<double>.generate(
      Colorimetry.spectrumSamples,
      (i) {
        final wl = 380 + i * 10;
        final channel = wl < 490
            ? _baseColor.b
            : wl < 590
                ? _baseColor.g
                : _baseColor.r;
        return channel * 0.9 + 0.05;
      },
    );

    final glazed = GlazeSimulator.glazeColor(
      baseReflectance,
      glazeReflectance,
      layers: _layers,
      layerOpacity: _opacity,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Glaze Simulator')),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _GlazePanel(
                    label: 'Base',
                    color: _baseColor,
                    onTap: () => _pickBaseColor(context),
                  ),
                ),
                const Icon(Icons.arrow_forward),
                Expanded(
                  child: _GlazePanel(
                    label: 'After $_layers layers',
                    color: glazed,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (result != null)
                      CircleAvatar(backgroundColor: result.color, radius: 14),
                    const SizedBox(width: 8),
                    const Text('Glaze colour from current mix'),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Layers: $_layers'),
                Slider(
                  value: _layers.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$_layers',
                  onChanged: (v) => setState(() => _layers = v.round()),
                ),
                Text('Layer opacity: ${(_opacity * 100).round()}%'),
                Slider(
                  value: _opacity,
                  min: 0.05,
                  max: 0.6,
                  onChanged: (v) => setState(() => _opacity = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickBaseColor(BuildContext context) async {
    final colors = [
      const Color(0xFFF5E6D3),
      Colors.white,
      const Color(0xFF8B7355),
      const Color(0xFF2C3E6B),
    ];
    final picked = await showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Base surface colour'),
        content: Wrap(
          spacing: 12,
          children: colors
              .map((c) => GestureDetector(
                    onTap: () => Navigator.pop(ctx, c),
                    child: CircleAvatar(backgroundColor: c, radius: 24),
                  ))
              .toList(),
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _baseColor = picked);
  }
}

class _GlazePanel extends StatelessWidget {
  const _GlazePanel({
    required this.label,
    required this.color,
    this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.ochre.withValues(alpha: 0.5)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
