import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/appwrite/appwrite_client.dart';
import '../../core/theme.dart';
import '../../engine/mix_session.dart';
import '../account/account_provider.dart';
import 'database.dart';
import 'recipe_export.dart';
import 'recipe_import.dart';
import 'recipe_sync.dart';
import 'recipes_provider.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);
    final showSync = ref.watch(appwriteConfigProvider).isConfigured &&
        ref.watch(cloudUserProvider).asData?.value != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          if (showSync)
            IconButton(
              icon: const Icon(Icons.cloud_sync_outlined),
              tooltip: 'Sync now',
              onPressed: () => _syncNow(context, ref),
            ),
          IconButton(
            icon: const Icon(Icons.upload_file_outlined),
            tooltip: 'Import recipe JSON',
            onPressed: () => _importRecipe(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save current mix',
            onPressed: () => _saveCurrentMix(context, ref),
          ),
        ],
      ),
      body: recipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (recipes) {
          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border,
                      size: 64, color: AppTheme.ochre.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('No saved recipes yet'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => _saveCurrentMix(context, ref),
                    child: const Text('Save current mix'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return _RecipeCard(
                recipe: recipe,
                onDelete: () async {
                  await ref.read(databaseProvider).deleteRecipe(recipe.id);
                  refreshRecipes(ref);
                },
                onDuplicate: () async {
                  await ref.read(databaseProvider).duplicateRecipe(recipe);
                  refreshRecipes(ref);
                },
                onLoad: () => _loadRecipe(context, ref, recipe),
                onShare: () => _shareRecipe(recipe),
                onExportPdf: () => _exportRecipePdf(recipe),
                onExportJson: () => _exportRecipeJson(recipe),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _saveCurrentMix(BuildContext context, WidgetRef ref) async {
    final session = ref.read(mixSessionProvider);
    final result = session.result;
    if (result == null) return;

    final nameController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Recipe'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Recipe name',
            hintText: 'e.g. Portrait skin tone',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    final name = nameController.text;
    nameController.dispose();
    if (saved != true || name.isEmpty || !context.mounted) return;

    final pigmentData = jsonEncode(session.entries
        .map((e) => {'id': e.pigmentId, 'weight': e.weight})
        .toList());

    await ref.read(databaseProvider).insertRecipe(
          MixRecipesCompanion.insert(
            name: name,
            pigmentData: pigmentData,
            labL: result.lab.l,
            labA: result.lab.a,
            labB: result.lab.b,
            colorValue: _colorToInt(result.color),
          ),
        );

    if (!context.mounted) return;
    refreshRecipes(ref);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe saved')),
    );
  }

  Future<void> _syncNow(BuildContext context, WidgetRef ref) async {
    final cloud = ref.read(cloudRecipesProvider);
    final user = await ref.read(cloudUserProvider.future);
    if (cloud == null || user == null) return;

    try {
      final result = await syncRecipes(
        store: DriftRecipeStore(ref.read(databaseProvider)),
        cloud: cloud,
        userId: user.id,
        newDocumentId: () => ID.unique(),
      );
      refreshRecipes(ref);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Synced: ${result.pushed} pushed, ${result.pulled} pulled',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    }
  }

  void _loadRecipe(BuildContext context, WidgetRef ref, MixRecipe recipe) {
    final List<MixEntry> entries;
    try {
      final data =
          (jsonDecode(recipe.pigmentData) as List).cast<Map<String, dynamic>>();
      entries = data
          .map((d) => MixEntry(
                pigmentId: d['id'] as String,
                weight: (d['weight'] as num).toDouble(),
              ))
          .toList();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe data is corrupted')),
      );
      return;
    }
    ref.read(mixSessionProvider.notifier).setEntriesFromPalette(entries);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Loaded "${recipe.name}"')),
    );
  }

  Future<void> _shareRecipe(MixRecipe recipe) async {
    final pigments =
        (jsonDecode(recipe.pigmentData) as List).cast<Map<String, dynamic>>();
    final lines = <String>[
      'ChromaStudio Recipe: ${recipe.name}',
      '',
      'Pigments:',
      for (final p in pigments)
        '  • ${p['id']}: ${(p['weight'] as num).toStringAsFixed(2)} parts',
      '',
      'Lab: L=${recipe.labL.toStringAsFixed(1)} '
      'a=${recipe.labA.toStringAsFixed(1)} '
      'b=${recipe.labB.toStringAsFixed(1)}',
      if (recipe.notes.isNotEmpty) '',
      if (recipe.notes.isNotEmpty) 'Notes: ${recipe.notes}',
    ];
    await Share.share(lines.join('\n'), subject: recipe.name);
  }

  Future<void> _exportRecipePdf(MixRecipe recipe) async {
    final names = await loadPigmentNameMap();
    await exportRecipePdf(recipe, pigmentNames: names);
  }

  Future<void> _exportRecipeJson(MixRecipe recipe) async {
    final names = await loadPigmentNameMap();
    await exportRecipeJson(recipe, pigmentNames: names);
  }

  Future<void> _importRecipe(BuildContext context, WidgetRef ref) async {
    final parsed = await pickAndParseRecipeFile();
    if (parsed == null || !context.mounted) return;

    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Import "${parsed.name}"?'),
        content: Text(
          '${parsed.entries.length} pigments · '
          'L:${parsed.labL.toStringAsFixed(0)} '
          'a:${parsed.labA.toStringAsFixed(0)} '
          'b:${parsed.labB.toStringAsFixed(0)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'load'),
            child: const Text('Load to mix'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: const Text('Save recipe'),
          ),
        ],
      ),
    );

    if (action == null || action == 'cancel' || !context.mounted) return;

    if (action == 'save') {
      await saveParsedRecipe(ref.read(databaseProvider), parsed);
      if (!context.mounted) return;
      refreshRecipes(ref);
    }

    if (action == 'load' || action == 'save') {
      ref.read(mixSessionProvider.notifier).setEntriesFromPalette(parsed.entries);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imported "${parsed.name}"')),
    );
  }
}

int _colorToInt(Color color) {
  final a = (color.a * 255.0).round() & 0xff;
  final r = (color.r * 255.0).round() & 0xff;
  final g = (color.g * 255.0).round() & 0xff;
  final b = (color.b * 255.0).round() & 0xff;
  return (a << 24) | (r << 16) | (g << 8) | b;
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.onDelete,
    required this.onDuplicate,
    required this.onLoad,
    required this.onShare,
    required this.onExportPdf,
    required this.onExportJson,
  });

  final MixRecipe recipe;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onLoad;
  final VoidCallback onShare;
  final VoidCallback onExportPdf;
  final VoidCallback onExportJson;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(recipe.colorValue),
          radius: 24,
        ),
        title: Text(recipe.name),
        subtitle: Text(
          'L:${recipe.labL.toStringAsFixed(0)} '
          'a:${recipe.labA.toStringAsFixed(0)} '
          'b:${recipe.labB.toStringAsFixed(0)}',
        ),
        onTap: onLoad,
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            switch (v) {
              case 'share':
                onShare();
              case 'pdf':
                onExportPdf();
              case 'json':
                onExportJson();
              case 'duplicate':
                onDuplicate();
              case 'delete':
                onDelete();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'share', child: Text('Share text')),
            PopupMenuItem(value: 'pdf', child: Text('Export PDF')),
            PopupMenuItem(value: 'json', child: Text('Export JSON')),
            PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
