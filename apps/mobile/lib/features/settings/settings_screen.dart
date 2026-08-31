import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings_provider.dart';
import '../../core/theme.dart';
import '../../engine/mix_session.dart';
import '../../engine/native_engine.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_themeLabel(themeMode)),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('Auto')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {themeMode},
              onSelectionChanged: (s) =>
                  ref.read(themeModeProvider.notifier).state = s.first,
            ),
          ),
          const _SectionHeader('Units'),
          ListTile(
            title: const Text('Default quantity unit'),
            subtitle: Text(ref.watch(quantityUnitProvider)),
            trailing: DropdownButton<String>(
              value: ref.watch(quantityUnitProvider),
              items: const [
                DropdownMenuItem(value: 'parts', child: Text('Parts')),
                DropdownMenuItem(value: 'grams', child: Text('Grams')),
                DropdownMenuItem(value: 'drops', child: Text('Drops')),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref.read(quantityUnitProvider.notifier).state = v;
                }
              },
            ),
          ),
          const _SectionHeader('Accessibility'),
          SwitchListTile(
            title: const Text('High contrast'),
            subtitle: const Text('Increases UI contrast for readability'),
            value: false,
            onChanged: (_) {},
          ),
          const _SectionHeader('About'),
          Consumer(
            builder: (context, ref, _) {
              final backend = ref.watch(engineBackendProvider);
              final label = backend.when(
                data: (b) =>
                    b is NativeEngineBackend ? 'Rust (native FFI)' : 'Dart',
                loading: () => 'Loading…',
                error: (_, __) => 'Dart (fallback)',
              );
              return ListTile(
                leading: const Icon(Icons.memory_outlined),
                title: const Text('Mixing engine'),
                subtitle: Text(label),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('ChromaStudio v1.0.0'),
            subtitle: Text('Spectral Kubelka-Munk mixing engine'),
          ),
          const ListTile(
            leading: Icon(Icons.palette, color: AppTheme.ochre),
            title: Text('20 pigments loaded'),
            subtitle: Text('Offline • iOS & Android'),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.deepBlue,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
