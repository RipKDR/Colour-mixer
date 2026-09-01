import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/engine/chroma_engine.dart';
import 'package:chromastudio/engine/spectrum_from_lab.dart';

void main() {
  group('spectrumFromLab', () {
    test('synthesized spectrum reproduces a red target within ΔE 5', () {
      const target = LabColor(48, 62, 38);
      final spectrum = spectrumFromLab(target);
      expect(spectrum, hasLength(Colorimetry.spectrumSamples));
      final lab = Colorimetry.spectrumToLab(spectrum);
      expect(Colorimetry.ciede2000(lab, target), lessThan(5));
    });

    test('high-L neutral is a bright reflector', () {
      const target = LabColor(95, 0, 0);
      final spectrum = spectrumFromLab(target);
      final mean =
          spectrum.reduce((a, b) => a + b) / spectrum.length;
      expect(mean, greaterThan(0.7));
    });

    test('low-L neutral is a dark reflector', () {
      const target = LabColor(12, 0, 0);
      final spectrum = spectrumFromLab(target);
      final mean =
          spectrum.reduce((a, b) => a + b) / spectrum.length;
      expect(mean, lessThan(0.2));
    });

    test('samples stay in (0, 1)', () {
      final spectrum = spectrumFromLab(const LabColor(55, -40, 20));
      for (final r in spectrum) {
        expect(r, greaterThan(0));
        expect(r, lessThan(1));
      }
    });
  });
}
