import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../engine/mix_session.dart';
import 'database.dart';
import 'recipes_provider.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
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

    if (saved != true || nameController.text.isEmpty) return;

    final pigmentData = jsonEncode(session.entries
        .map((e) => {'id': e.pigmentId, 'weight': e.weight})
        .toList());

    await ref.read(databaseProvider).insertRecipe(
          MixRecipesCompanion.insert(
            name: nameController.text,
            pigmentData: pigmentData,
            labL: result.lab.l,
            labA: result.lab.a,
            labB: result.lab.b,
            colorValue: _colorToInt(result.color),
          ),
        );

    refreshRecipes(ref);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe saved')),
      );
    }
  }

  void _loadRecipe(BuildContext context, WidgetRef ref, MixRecipe recipe) {
    final data =
        (jsonDecode(recipe.pigmentData) as List).cast<Map<String, dynamic>>();
    final entries = data
        .map((d) => MixEntry(
              pigmentId: d['id'] as String,
              weight: (d['weight'] as num).toDouble(),
            ))
        .toList();
    ref.read(mixSessionProvider.notifier).setEntriesFromPalette(entries);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loaded "${recipe.name}"')),
      );
    }
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
  });

  final MixRecipe recipe;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onLoad;

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
              case 'duplicate':
                onDuplicate();
              case 'delete':
                onDelete();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
