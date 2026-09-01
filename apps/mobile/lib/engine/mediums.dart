import 'dart:convert';

import 'package:flutter/services.dart';

import 'chroma_engine.dart';

class Medium {
  const Medium({
    required this.id,
    required this.name,
    required this.binder,
    required this.translucencyBoost,
    required this.glossLevel,
    required this.viscosity,
    required this.dryingModifier,
    required this.description,
  });

  final String id;
  final String name;
  final String binder;
  final double translucencyBoost;
  final double glossLevel;
  final double viscosity;
  final double dryingModifier;
  final String description;

  factory Medium.fromJson(Map<String, dynamic> json) => Medium(
        id: json['id'] as String,
        name: json['name'] as String,
        binder: json['binder'] as String,
        translucencyBoost: (json['translucency_boost'] as num).toDouble(),
        glossLevel: (json['gloss_level'] as num).toDouble(),
        viscosity: (json['viscosity'] as num).toDouble(),
        dryingModifier: (json['drying_modifier'] as num).toDouble(),
        description: json['description'] as String,
      );
}

class MediumLibrary {
  MediumLibrary(this._mediums);
  final Map<String, Medium> _mediums;

  static Future<MediumLibrary> load() async {
    final jsonStr = await rootBundle.loadString('assets/data/mediums.json');
    final list = (jsonDecode(jsonStr) as List).cast<Map<String, dynamic>>();
    return MediumLibrary({
      for (final m in list) m['id'] as String: Medium.fromJson(m),
    });
  }

  List<Medium> get all =>
      _mediums.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  Medium? get(String id) => _mediums[id];
}

enum DryingTime { oneDay, oneWeek, oneMonth }

class DryingSimulator {
  static Color driedColor(
    List<double> reflectance,
    String binder,
    DryingTime time, {
    double mediumModifier = 0.0,
  }) {
    final adjustedFactor = switch (time) {
      DryingTime.oneDay => 0.02 + mediumModifier * 0.01,
      DryingTime.oneWeek => 0.05 + mediumModifier * 0.02,
      DryingTime.oneMonth => 0.08 + mediumModifier * 0.03,
    };
    final dried = List.generate(reflectance.length, (i) {
      final wl = 380.0 + i * 10.0;
      final darken = 1.0 - adjustedFactor;
      final yellowBoost = binder == 'oil' && wl > 550 && wl < 650
          ? 1.0 + adjustedFactor * 0.5
          : 1.0;
      return (reflectance[i] * darken * yellowBoost).clamp(0.0, 1.0);
    });
    return Colorimetry.srgbToColor(Colorimetry.spectrumToSrgb(dried));
  }
}

class GlazeSimulator {
  static List<double> stackGlaze(
    List<double> baseReflectance,
    List<double> glazeReflectance, {
    int layers = 3,
    double layerOpacity = 0.25,
  }) {
    var current = List<double>.from(baseReflectance);
    for (var i = 0; i < layers; i++) {
      current = Colorimetry.mixSpectraKs(current, glazeReflectance, layerOpacity);
    }
    return current;
  }

  static Color glazeColor(
    List<double> baseReflectance,
    List<double> glazeReflectance, {
    int layers = 3,
    double layerOpacity = 0.25,
  }) {
    final result = stackGlaze(
      baseReflectance,
      glazeReflectance,
      layers: layers,
      layerOpacity: layerOpacity,
    );
    return Colorimetry.srgbToColor(Colorimetry.spectrumToSrgb(result));
  }
}

MixResult applyMedium(MixResult base, Medium medium, double amount) {
  if (amount <= 0) return base;
  final t = (amount / 10).clamp(0.0, 0.5);

  final whiteReflectance = List<double>.filled(
    Colorimetry.spectrumSamples,
    0.95,
  );
  final diluted = Colorimetry.mixSpectraKs(
    base.reflectance,
    whiteReflectance,
    t * medium.translucencyBoost,
  );

  final lab = Colorimetry.spectrumToLab(diluted);
  final color = Colorimetry.srgbToColor(Colorimetry.spectrumToSrgb(diluted));

  return MixResult(
    lab: lab,
    color: color,
    massTone: color,
    undertone: base.undertone,
    reflectance: diluted,
    glossLevel: medium.glossLevel,
    mediumName: medium.name,
  );
}
