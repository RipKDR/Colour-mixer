import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../engine/catalog.dart';
import '../../engine/mix_session.dart';

class BrandCatalogScreen extends ConsumerWidget {
  const BrandCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(brandCatalogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Brand Catalog')),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (catalog) {
          final brands = catalog.brandNames;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              final paints = catalog.byBrand(brand);
              return ExpansionTile(
                leading: Icon(Icons.store, color: AppTheme.ochre),
                title: Text(brand),
                subtitle: Text('${paints.length} colours'),
                children: paints.map((paint) {
                  final pigment = ref
                      .watch(engineProvider)
                      .valueOrNull
                      ?.getPigment(paint.pigmentId);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: pigment?.color ?? Colors.grey,
                      radius: 16,
                    ),
                    title: Text(paint.name),
                    subtitle: Text(
                      '${paint.line} · ${paint.pigmentCodes.join(", ")} · '
                      '\$${paint.priceUsd.toStringAsFixed(2)} / ${paint.sizeMl.toInt()}ml',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'Add to mix',
                      onPressed: () {
                        ref
                            .read(mixSessionProvider.notifier)
                            .addPigment(paint.pigmentId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added ${paint.name} to mix')),
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
