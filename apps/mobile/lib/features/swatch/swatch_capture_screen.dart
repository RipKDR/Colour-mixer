import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/haptics.dart';
import '../../core/theme.dart';
import '../../engine/chroma_engine.dart';
import '../../engine/mix_session.dart';
import 'swatch_compare.dart';

/// Photograph a painted swatch and compare it to the current mix prediction.
class SwatchCaptureScreen extends ConsumerStatefulWidget {
  const SwatchCaptureScreen({super.key});

  @override
  ConsumerState<SwatchCaptureScreen> createState() =>
      _SwatchCaptureScreenState();
}

class _SwatchCaptureScreenState extends ConsumerState<SwatchCaptureScreen> {
  ui.Image? _image;
  ByteData? _pixels;
  LabColor? _sampledLab;
  Color? _sampledColor;
  Offset? _tapLocal;
  SwatchComparison? _comparison;
  (double, double, double)? _whiteReference;
  (double, double, double)? _sampledSrgb;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, maxWidth: 2048);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final image = await decodeImageFromList(bytes);
    final pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (!mounted) {
      image.dispose();
      return;
    }
    _image?.dispose();
    setState(() {
      _image = image;
      _pixels = pixels;
      _sampledLab = null;
      _sampledColor = null;
      _tapLocal = null;
      _comparison = null;
      _sampledSrgb = null;
    });
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  void _sampleAt(Offset local, Size viewport) {
    final image = _image;
    final pixels = _pixels;
    if (image == null || pixels == null) return;

    final reference = ref.read(mixSessionProvider).result?.lab;
    if (reference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mix some paints first, then check your swatch')),
      );
      return;
    }

    final scale = _containScale(image, viewport);
    final drawnW = image.width * scale;
    final drawnH = image.height * scale;
    final dx = (viewport.width - drawnW) / 2;
    final dy = (viewport.height - drawnH) / 2;

    final px = ((local.dx - dx) / scale).floor();
    final py = ((local.dy - dy) / scale).floor();
    if (px < 0 || py < 0 || px >= image.width || py >= image.height) return;

    final srgb = sampleSrgbFromRgba(
      pixels,
      image.width,
      image.height,
      px,
      py,
    );
    if (srgb == null) return;
    final lab = sampleLabFromRgba(
      pixels,
      image.width,
      image.height,
      px,
      py,
      whiteReference: _whiteReference,
    );
    final display = Colorimetry.labToSrgb(lab.l, lab.a, lab.b);
    final color = Color.fromARGB(
      255,
      (display.$1 * 255).round(),
      (display.$2 * 255).round(),
      (display.$3 * 255).round(),
    );

    setState(() {
      _sampledLab = lab;
      _sampledColor = color;
      _sampledSrgb = srgb;
      _tapLocal = local;
      _comparison = SwatchComparison.compare(
        swatchLab: lab,
        referenceLab: reference,
      );
    });
    hapticSelect();
  }

  double _containScale(ui.Image image, Size viewport) {
    final sx = viewport.width / image.width;
    final sy = viewport.height / image.height;
    return sx < sy ? sx : sy;
  }

  @override
  Widget build(BuildContext context) {
    final mixResult = ref.watch(mixSessionProvider).result;
    final comparison = _comparison;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swatch Check'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: 'Gallery',
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Camera',
            onPressed: () => _pickImage(ImageSource.camera),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Paint a swatch of your current mix, photograph it under neutral '
              'light, then tap the painted area to compare against the prediction.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: _image == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          size: 64,
                          color: AppTheme.ochre.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text('Photograph your painted swatch'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Take photo'),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final viewport = constraints.biggest;
                      return GestureDetector(
                        onTapDown: (d) => _sampleAt(d.localPosition, viewport),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            RawImage(image: _image, fit: BoxFit.contain),
                            if (_tapLocal != null)
                              Positioned(
                                left: _tapLocal!.dx - 18,
                                top: _tapLocal!.dy - 18,
                                child: IgnorePointer(
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 4,
                                          color: Colors.black45,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (mixResult != null && _sampledColor != null && comparison != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SwatchTile(
                          label: 'Painted swatch',
                          color: _sampledColor!,
                          lab: _sampledLab,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SwatchTile(
                          label: 'Predicted mix',
                          color: mixResult.color,
                          lab: mixResult.lab,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: comparison.deltaE < 5
                        ? Colors.green.shade50
                        : comparison.deltaE < 10
                            ? Colors.orange.shade50
                            : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ΔE ${comparison.deltaE.toStringAsFixed(1)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppTheme.deepBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(swatchVerdictLabel(comparison.verdict)),
                          const SizedBox(height: 6),
                          Text(
                            _whiteReference == null
                                ? 'Photo treated as sRGB. Tap a gray/white card '
                                    'in the photo, then “Set as white card” to '
                                    'adapt to D65.'
                                : 'White card set — sample is Bradford-adapted to D65.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: _sampledSrgb == null
                                    ? null
                                    : () => setState(() {
                                          _whiteReference = _sampledSrgb;
                                        }),
                                child: Text(
                                  _whiteReference == null
                                      ? 'Set as white card'
                                      : 'White card set',
                                ),
                              ),
                              if (_whiteReference != null)
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _whiteReference = null),
                                  child: const Text('Clear'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (mixResult == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No mix loaded — add pigments on the Mix screen first.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _SwatchTile extends StatelessWidget {
  const _SwatchTile({
    required this.label,
    required this.color,
    this.lab,
  });

  final String label;
  final Color color;
  final LabColor? lab;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 72,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.ochre.withValues(alpha: 0.4)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        if (lab != null)
          Text(
            'L${lab!.l.toStringAsFixed(0)} '
            'a${lab!.a.toStringAsFixed(0)} '
            'b${lab!.b.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
      ],
    );
  }
}
