import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mediums.dart';

class BrandPaint {
  const BrandPaint({
    required this.id,
    required this.brand,
    required this.line,
    required this.name,
    required this.pigmentId,
    required this.pigmentCodes,
    required this.opacity,
    required this.priceUsd,
    required this.sizeMl,
  });

  final String id;
  final String brand;
  final String line;
  final String name;
  final String pigmentId;
  final List<String> pigmentCodes;
  final String opacity;
  final double priceUsd;
  final double sizeMl;

  factory BrandPaint.fromJson(Map<String, dynamic> json) => BrandPaint(
        id: json['id'] as String,
        brand: json['brand'] as String,
        line: json['line'] as String,
        name: json['name'] as String,
        pigmentId: json['pigment_id'] as String,
        pigmentCodes: (json['pigment_codes'] as List).cast<String>(),
        opacity: json['opacity'] as String,
        priceUsd: (json['price_usd'] as num).toDouble(),
        sizeMl: (json['size_ml'] as num).toDouble(),
      );
}

class BrandCatalog {
  BrandCatalog(this.paints);
  final List<BrandPaint> paints;

  static Future<BrandCatalog> load() async {
    final brands = ['golden', 'winsor_newton', 'liquitex', 'daniel_smith', 'schmincke'];
    final all = <BrandPaint>[];
    for (final b in brands) {
      final jsonStr =
          await rootBundle.loadString('assets/data/brands/$b.json');
      final list = (jsonDecode(jsonStr) as List).cast<Map<String, dynamic>>();
      all.addAll(list.map(BrandPaint.fromJson));
    }
    all.sort((a, b) => a.name.compareTo(b.name));
    return BrandCatalog(all);
  }

  List<String> get brandNames =>
      paints.map((p) => p.brand).toSet().toList()..sort();

  List<BrandPaint> byBrand(String brand) =>
      paints.where((p) => p.brand == brand).toList();
}

final brandCatalogProvider = FutureProvider<BrandCatalog>((ref) async {
  return BrandCatalog.load();
});

final mediumLibraryProvider = FutureProvider<MediumLibrary>((ref) async {
  return MediumLibrary.load();
});
