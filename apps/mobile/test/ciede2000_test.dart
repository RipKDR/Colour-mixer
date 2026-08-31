import 'package:flutter_test/flutter_test.dart';

import 'package:chromastudio/engine/chroma_engine.dart';

void main() {
  test('CIEDE2000 identical colours is near zero', () {
    const lab = LabColor(50, 10, 20);
    expect(Colorimetry.ciede2000(lab, lab), lessThan(0.01));
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
