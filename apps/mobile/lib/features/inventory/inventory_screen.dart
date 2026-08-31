import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../engine/mix_session.dart';
import '../recipes/database.dart';
import 'inventory_provider.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add paint tube',
            onPressed: () => _showAddTube(context, ref),
          ),
        ],
      ),
      body: inventoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: AppTheme.ochre.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('No paints in inventory'),
                  const SizedBox(height: 8),
                  const Text('Track your tubes to estimate mix costs'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showAddTube(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add paint tube'),
                  ),
                ],
              ),
            );
          }

          final totalValue = items.fold<double>(
            0,
            (sum, i) => sum + i.pricePerTube * i.amountLeft,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Tubes',
                        value: '${items.length}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Est. value',
                        value: '\$${totalValue.toStringAsFixed(0)}',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final pigment = ref
                        .watch(engineProvider)
                        .valueOrNull
                        ?.getPigment(item.pigmentId);
                    return _InventoryCard(
                      item: item,
                      pigmentName: pigment?.name ?? item.pigmentId,
                      color: pigment?.color ?? Colors.grey,
                      onAmountChanged: (v) async {
                        await ref.read(databaseProvider).updateInventory(
                              item.copyWith(amountLeft: v),
                            );
                        refreshInventory(ref);
                      },
                      onDelete: () async {
                        await ref
                            .read(databaseProvider)
                            .deleteInventory(item.id);
                        refreshInventory(ref);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAddTube(BuildContext context, WidgetRef ref) async {
    final engine = ref.read(engineProvider).valueOrNull;
    if (engine == null) return;

    String? selectedId;
    final brandCtrl = TextEditingController();
    final lineCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '12');
    var amount = 1.0;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add paint tube'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedId,
                  decoration: const InputDecoration(labelText: 'Pigment'),
                  items: engine.allPigments
                      .map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: p.color,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(p.name)),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => selectedId = v),
                ),
                TextField(
                  controller: brandCtrl,
                  decoration: const InputDecoration(labelText: 'Brand'),
                ),
                TextField(
                  controller: lineCtrl,
                  decoration: const InputDecoration(labelText: 'Line'),
                ),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Price per tube (\$)'),
                ),
                const SizedBox(height: 8),
                Text('Amount left: ${amountLabel(amount)}'),
                Slider(
                  value: amount,
                  onChanged: (v) => setState(() => amount = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed:
                  selectedId == null ? null : () => Navigator.pop(ctx, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (saved != true || selectedId == null) return;

    await ref.read(databaseProvider).insertInventory(
          InventoryItemsCompanion.insert(
            pigmentId: selectedId!,
            brand: Value(brandCtrl.text),
            line: Value(lineCtrl.text),
            pricePerTube: Value(double.tryParse(priceCtrl.text) ?? 0),
            amountLeft: Value(amount),
          ),
        );
    refreshInventory(ref);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.deepBlue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.item,
    required this.pigmentName,
    required this.color,
    required this.onAmountChanged,
    required this.onDelete,
  });

  final InventoryItem item;
  final String pigmentName;
  final Color color;
  final ValueChanged<double> onAmountChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (item.brand.isNotEmpty) item.brand,
      if (item.line.isNotEmpty) item.line,
      amountLabel(item.amountLeft),
      if (item.pricePerTube > 0)
        '\$${(item.pricePerTube * item.amountLeft).toStringAsFixed(2)} left',
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 22),
        title: Text(pigmentName),
        subtitle: Text(subtitle),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'delete', child: Text('Remove')),
          ],
        ),
        onTap: () => _showAmountDialog(context),
      ),
    );
  }

  void _showAmountDialog(BuildContext context) {
    var amount = item.amountLeft;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Update $pigmentName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(amountLabel(amount)),
              Slider(
                value: amount,
                onChanged: (v) => setState(() => amount = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                onAmountChanged(amount);
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
