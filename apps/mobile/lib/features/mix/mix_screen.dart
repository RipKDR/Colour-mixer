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
        // Five icons plus the segmented button overflow a phone-width app
        // bar, so the tool shortcuts live in a single menu.
        actions: [
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.handyman_outlined),
            tooltip: 'Tools',
            onSelected: (route) => context.push(route),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: '/match',
                child: ListTile(
                  leading: Icon(Icons.gps_fixed),
                  title: Text('Color match'),
                ),
              ),
              PopupMenuItem(
                value: '/match/swatch',
                child: ListTile(
                  leading: Icon(Icons.photo_camera_outlined),
                  title: Text('Swatch check'),
                ),
              ),
              PopupMenuItem(
                value: '/light-booth',
                child: ListTile(
                  leading: Icon(Icons.wb_incandescent_outlined),
                  title: Text('Light booth'),
                ),
              ),
              PopupMenuItem(
                value: '/glaze',
                child: ListTile(
                  leading: Icon(Icons.layers_outlined),
                  title: Text('Glaze simulator'),
                ),
              ),
              PopupMenuItem(
                value: '/catalog',
                child: ListTile(
                  leading: Icon(Icons.store_outlined),
                  title: Text('Brand catalog'),
                ),
              ),
              PopupMenuItem(
                value: '/preview',
                child: ListTile(
                  leading: Icon(Icons.photo_outlined),
                  title: Text('Painting preview'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: mode == MixMode.palette
          ? const PaletteModeScreen()
          : const PrecisionModeScreen(),
    );
  }
}
