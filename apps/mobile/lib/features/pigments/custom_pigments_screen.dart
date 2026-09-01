import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/haptics.dart';
import '../../core/theme.dart';
import '../../engine/chroma_engine.dart';
import '../../engine/mix_session.dart';
import '../../engine/spectrum_from_lab.dart';
import '../match/color_match.dart';
import '../recipes/database.dart';
import 'custom_pigments_provider.dart';

class CustomPigmentsScreen extends ConsumerWidget {
  const CustomPigmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customAsync = ref.watch(customPigmentModelsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Custom pigments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add pigment'),
        backgroundColor: AppTheme.deepBlue,
      ),
      body: customAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (pigments) {
          if (pigments.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Save a paint that is not in the bundled catalog. '
                  'ChromaStudio synthesizes a reflectance curve from Lab '
                  'so it can mix with the spectral engine.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: pigments.length,
            itemBuilder: (context, index) {
              final p = pigments[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: p.color),
                  title: Text(p.name),
                  subtitle: Text(
                    'L${p.lab.l.toStringAsFixed(0)} '
                    'a${p.lab.a.toStringAsFixed(0)} '
                    'b${p.lab.b.toStringAsFixed(0)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Add to mix',
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          ref.read(mixSessionProvider.notifier).addPigment(p.id);
                          hapticLight();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added ${p.name} to mix')),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await ref
                              .read(databaseProvider)
                              .deleteCustomPigment(p.id);
                          refreshCustomPigments(ref);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, WidgetRef ref) async {
    final mixLab = ref.read(mixSessionProvider).result?.lab;
    final targetLab = ref.read(colorTargetProvider)?.lab;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _CustomPigmentEditor(
        initialLab: targetLab ?? mixLab ?? const LabColor(55, 10, 15),
      ),
    );
  }
}

class _CustomPigmentEditor extends ConsumerStatefulWidget {
  const _CustomPigmentEditor({required this.initialLab});

  final LabColor initialLab;

  @override
  ConsumerState<_CustomPigmentEditor> createState() =>
      _CustomPigmentEditorState();
}

class _CustomPigmentEditorState extends ConsumerState<_CustomPigmentEditor> {
  late final TextEditingController _name;
  late double _l;
  late double _a;
  late double _b;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _l = widget.initialLab.l;
    _a = widget.initialLab.a;
    _b = widget.initialLab.b;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give the pigment a name')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final pigment = pigmentFromLab(
        id: 'custom_${const Uuid().v4()}',
        name: name,
        target: LabColor(_l, _a, _b),
      );
      await ref.read(databaseProvider).insertCustomPigment(
            CustomPigmentsCompanion.insert(
              id: pigment.id,
              name: pigment.name,
              reflectanceJson: jsonEncode(pigment.reflectance),
              opacity: Value(pigment.opacity),
              tintingStrength: Value(pigment.tintingStrength),
              binder: Value(pigment.binder),
            ),
          );
      refreshCustomPigments(ref);
      if (!mounted) return;
      Navigator.of(context).pop();
      hapticMedium();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = Colorimetry.srgbToColor(
      Colorimetry.labToSrgb(_l, _a, _b),
    );
    final inset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + inset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New custom pigment',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Studio warm grey',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: preview,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.ochre.withValues(alpha: 0.4)),
              ),
            ),
            Text('L: ${_l.toStringAsFixed(0)}'),
            Slider(
              value: _l.clamp(0, 100),
              min: 0,
              max: 100,
              onChanged: (v) => setState(() => _l = v),
            ),
            Text('a: ${_a.toStringAsFixed(0)}'),
            Slider(
              value: _a.clamp(-80, 80),
              min: -80,
              max: 80,
              onChanged: (v) => setState(() => _a = v),
            ),
            Text('b: ${_b.toStringAsFixed(0)}'),
            Slider(
              value: _b.clamp(-80, 80),
              min: -80,
              max: 80,
              onChanged: (v) => setState(() => _b = v),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_saving ? 'Saving…' : 'Save pigment'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.deepBlue,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
