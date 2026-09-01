import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings_provider.dart';
import '../../core/theme.dart';
import '../../engine/chroma_engine.dart';
import '../../engine/mix_session.dart';
import '../../engine/native_engine.dart';
import '../account/account_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final highContrast = ref.watch(highContrastProvider);

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
            subtitle: Text(ref.watch(quantityUnitProvider).name),
            trailing: DropdownButton<QuantityUnit>(
              value: ref.watch(quantityUnitProvider),
              items: const [
                DropdownMenuItem(
                  value: QuantityUnit.parts,
                  child: Text('Parts'),
                ),
                DropdownMenuItem(
                  value: QuantityUnit.grams,
                  child: Text('Grams'),
                ),
                DropdownMenuItem(
                  value: QuantityUnit.milliliters,
                  child: Text('Millilitres'),
                ),
                DropdownMenuItem(
                  value: QuantityUnit.drops,
                  child: Text('Drops'),
                ),
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
            value: highContrast,
            onChanged: (v) =>
                ref.read(highContrastProvider.notifier).state = v,
          ),
          const _SectionHeader('Tools'),
          ListTile(
            leading: const Icon(Icons.wb_incandescent_outlined),
            title: const Text('Virtual light booth'),
            subtitle: const Text('Preview mixes under different illuminants'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/light-booth'),
          ),
          ListTile(
            leading: const Icon(Icons.gps_fixed),
            title: const Text('Color match'),
            subtitle: const Text('Set a target colour and track ΔE'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/match'),
          ),
          ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text('Custom pigments'),
            subtitle: const Text('Add paints not in the bundled catalog'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/custom-pigments'),
          ),
          const _SectionHeader('Account'),
          const AccountSection(),
          const _SectionHeader('About'),
          Consumer(
            builder: (context, ref, _) {
              final backend = ref.watch(engineBackendProvider);
              final label = backend.when(
                data: (b) {
                  if (b is NativeEngineBackend) {
                    final spectra = b.hasFullSpectra ? 'full spectra' : 'Lab only';
                    return 'Rust (native FFI · $spectra)';
                  }
                  return 'Dart (full spectra)';
                },
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
