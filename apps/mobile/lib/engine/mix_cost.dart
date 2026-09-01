import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/inventory/inventory_provider.dart';
import 'mix_session.dart';

class MixCostEstimate {
  const MixCostEstimate({
    required this.totalCost,
    required this.warnings,
    required this.coveredPigments,
  });

  final double totalCost;
  final List<String> warnings;
  final int coveredPigments;
}

final mixCostProvider = Provider<MixCostEstimate>((ref) {
  final session = ref.watch(mixSessionProvider);
  final inventoryAsync = ref.watch(inventoryProvider);

  return inventoryAsync.when(
    data: (items) {
      if (items.isEmpty || session.entries.isEmpty) {
        return const MixCostEstimate(
          totalCost: 0,
          warnings: [],
          coveredPigments: 0,
        );
      }

      var total = 0.0;
      var covered = 0;
      final warnings = <String>[];

      for (final entry in session.entries) {
        final matches =
            items.where((i) => i.pigmentId == entry.pigmentId).toList();
        if (matches.isEmpty) continue;
        covered++;
        final item = matches.first;
        if (item.pricePerTube <= 0) continue;

        final tubeMl = item.tubeSizeMl > 0 ? item.tubeSizeMl : 37.0;
        final costPerUnit = item.pricePerTube / tubeMl;
        final usedMl = entry.weight * 2;
        total += costPerUnit * usedMl;

        if (item.amountLeft < 0.15) {
          warnings.add('${item.pigmentId}: tube almost empty');
        } else if (usedMl > item.amountLeft * tubeMl * 0.5) {
          warnings.add('${item.pigmentId}: may need more than available');
        }
      }

      return MixCostEstimate(
        totalCost: total,
        warnings: warnings,
        coveredPigments: covered,
      );
    },
    loading: () => const MixCostEstimate(
      totalCost: 0,
      warnings: [],
      coveredPigments: 0,
    ),
    error: (_, __) => const MixCostEstimate(
      totalCost: 0,
      warnings: [],
      coveredPigments: 0,
    ),
  );
});
