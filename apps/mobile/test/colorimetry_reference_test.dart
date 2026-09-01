import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/engine/chroma_engine.dart';

void main() {
  final white = List<double>.filled(Colorimetry.spectrumSamples, 1.0);

  group('CIE reference values', () {
    test('perfect white reflector reproduces the D65 white point', () {
      final (x, y, z) = Colorimetry.spectrumToXyz(white);
      // 10 nm sampling gives small residuals vs the 1 nm standard values.
      expect(x, closeTo(95.047, 0.3));
      expect(y, closeTo(100.0, 0.001));
      expect(z, closeTo(108.883, 0.3));
    });

    test('perfect white reflector is neutral in Lab', () {
      final lab = Colorimetry.spectrumToLab(white);
      expect(lab.l, closeTo(100.0, 0.01));
      expect(lab.a.abs(), lessThan(0.05));
      expect(lab.b.abs(), lessThan(0.05));
    });

    test('perfect white reflector renders as sRGB white', () {
      final (r, g, b) = Colorimetry.spectrumToSrgb(white);
      expect(r, closeTo(1.0, 0.01));
      expect(g, closeTo(1.0, 0.01));
      expect(b, closeTo(1.0, 0.01));
    });

    test('flat gray reflector is neutral in Lab', () {
      final gray = List<double>.filled(Colorimetry.spectrumSamples, 0.2);
      final lab = Colorimetry.spectrumToLab(gray);
      expect(lab.a.abs(), lessThan(0.1));
      expect(lab.b.abs(), lessThan(0.1));
    });
  });

  group('illuminant handling', () {
    test('white reflector stays neutral under every illuminant', () {
      for (final illuminant in Illuminant.values) {
        final lab = Colorimetry.spectrumToLabUnder(white, illuminant);
        expect(lab.l, closeTo(100.0, 0.01), reason: '$illuminant');
        expect(lab.a.abs(), lessThan(0.05), reason: '$illuminant');
        expect(lab.b.abs(), lessThan(0.05), reason: '$illuminant');
      }
    });

    test('incandescent SPD is red-heavy, not blue-heavy', () {
      final atRed = Colorimetry.illuminantSpd(Illuminant.incandescent, 700);
      final atBlue = Colorimetry.illuminantSpd(Illuminant.incandescent, 400);
      expect(atRed, greaterThan(atBlue * 2));
    });

    test('cool LED SPD peaks near the 450nm blue pump, not in near-UV', () {
      final at450 = Colorimetry.illuminantSpd(Illuminant.coolLed, 450);
      final at380 = Colorimetry.illuminantSpd(Illuminant.coolLed, 380);
      expect(at450, greaterThan(at380));
    });
  });

  group('tinting strength normalization', () {
    PigmentModel makePigment(String id, double reflectance, double strength) {
      final spectrum =
          List<double>.filled(Colorimetry.spectrumSamples, reflectance);
      return PigmentModel(
        id: id,
        name: id,
        pigmentCodes: const ['PX'],
        reflectance: spectrum,
        opacity: 1.0,
        tintingStrength: strength,
        toxicity: 'low',
        binder: 'oil',
        lab: Colorimetry.spectrumToLab(spectrum),
        color: Colorimetry.srgbToColor(Colorimetry.spectrumToSrgb(spectrum)),
      );
    }

    test('a pure pigment mix reproduces its own masstone', () {
      // Strength != 1 must not change a single-pigment mix: strength is
      // only meaningful relative to other pigments in the mix.
      final weak = makePigment('weak_white', 0.9, 0.3);
      final strong = makePigment('strong_black', 0.05, 1.2);
      final engine = ChromaEngine({'weak_white': weak, 'strong_black': strong});

      for (final pigment in [weak, strong]) {
        final mixed = engine
            .mix([MixComponent(pigmentId: pigment.id, weight: 1.0)]).lab;
        final direct = Colorimetry.spectrumToLab(pigment.reflectance);
        expect(mixed.l, closeTo(direct.l, 0.01), reason: pigment.id);
        expect(mixed.a, closeTo(direct.a, 0.01), reason: pigment.id);
        expect(mixed.b, closeTo(direct.b, 0.01), reason: pigment.id);
      }
    });

    test('higher tinting strength dominates a 50/50 mix', () {
      final weak = makePigment('weak_white', 0.9, 0.3);
      final strong = makePigment('strong_black', 0.05, 1.2);
      final engine = ChromaEngine({'weak_white': weak, 'strong_black': strong});
      final mixed = engine.mix([
        const MixComponent(pigmentId: 'weak_white', weight: 1.0),
        const MixComponent(pigmentId: 'strong_black', weight: 1.0),
      ]).lab;
      final blackLab = Colorimetry.spectrumToLab(weak.reflectance);
      final midpoint = (Colorimetry.spectrumToLab(strong.reflectance).l +
              blackLab.l) /
          2;
      expect(mixed.l, lessThan(midpoint));
    });
  });
}
