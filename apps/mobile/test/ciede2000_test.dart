import 'package:flutter_test/flutter_test.dart';

import 'package:chromastudio/engine/chroma_engine.dart';

void main() {
  test('CIEDE2000 identical colours is near zero', () {
    const lab = LabColor(50, 10, 20);
    expect(Colorimetry.ciede2000(lab, lab), lessThan(0.01));
  });

    test('CIEDE2000 matches Sharma 2005 reference pairs', () {
      // (L1,a1,b1), (L2,a2,b2), expected dE00 — Sharma et al. (2005) dataset.
      const cases = [
        (LabColor(50, 2.6772, -79.7751), LabColor(50, 0, -82.7485), 2.0425),
        (LabColor(50, 3.1571, -77.2803), LabColor(50, 0, -82.7485), 2.8615),
        (LabColor(50, 2.8361, -74.0200), LabColor(50, 0, -82.7485), 3.4412),
        (LabColor(50, -1.3802, -84.2814), LabColor(50, 0, -82.7485), 1.0000),
        (LabColor(50, -1.1848, -84.8006), LabColor(50, 0, -82.7485), 1.0000),
        (LabColor(50, -0.9009, -85.5211), LabColor(50, 0, -82.7485), 1.0000),
        (LabColor(50, 0, 0), LabColor(50, -1, 2), 2.3669),
      ];
      for (final (lab1, lab2, expected) in cases) {
        expect(
          Colorimetry.ciede2000(lab1, lab2),
          closeTo(expected, 0.0001),
          reason: 'pair $lab1 vs $lab2',
        );
      }
    });

    test('CIEDE2000 different colours is positive', () {
    const a = LabColor(50, 10, 20);
    const b = LabColor(70, -10, 30);
    expect(Colorimetry.ciede2000(a, b), greaterThan(1));
  });

  test('labToSrgb produces valid components', () {
    final srgb = Colorimetry.labToSrgb(50, 10, 20);
    expect(srgb.$1, inInclusiveRange(0, 1));
    expect(srgb.$2, inInclusiveRange(0, 1));
    expect(srgb.$3, inInclusiveRange(0, 1));
  });
}
