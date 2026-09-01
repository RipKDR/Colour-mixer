import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'palette_mode.dart';
import 'precision_mode.dart';
import '../../engine/mix_session.dart';

class MixScreen extends ConsumerWidget {
  const MixScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(mixSessionProvider).mode;
    final notifier = ref.read(mixSessionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mix'),
        actions: [
          IconButton(
            icon: const Icon(Icons.wb_incandescent_outlined),
            tooltip: 'Light booth',
            onPressed: () => context.push('/light-booth'),
          ),
          IconButton(
            icon: const Icon(Icons.layers_outlined),
            tooltip: 'Glaze simulator',
            onPressed: () => context.push('/glaze'),
          ),
          IconButton(
            icon: const Icon(Icons.store_outlined),
            tooltip: 'Brand catalog',
            onPressed: () => context.push('/catalog'),
          ),
          IconButton(
            icon: const Icon(Icons.photo_outlined),
            tooltip: 'Painting preview',
            onPressed: () => context.push('/preview'),
          ),
          SegmentedButton<MixMode>(
            segments: const [
              ButtonSegment(
                value: MixMode.palette,
                icon: Icon(Icons.palette),
                label: Text('Palette'),
              ),
              ButtonSegment(
                value: MixMode.precision,
                icon: Icon(Icons.tune),
                label: Text('Precision'),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (s) => notifier.setMode(s.first),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: mode == MixMode.palette
          ? const PaletteModeScreen()
          : const PrecisionModeScreen(),
    );
  }
}
