import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/haptics.dart';
import '../../core/theme.dart';
import '../../engine/chroma_engine.dart';
import '../../engine/photo_adapt.dart';
import 'color_match.dart';

/// Pick a reference photo and tap it to sample a target colour.
class PhotoEyedropperScreen extends ConsumerStatefulWidget {
  const PhotoEyedropperScreen({super.key});

  @override
  ConsumerState<PhotoEyedropperScreen> createState() =>
      _PhotoEyedropperScreenState();
}

class _PhotoEyedropperScreenState extends ConsumerState<PhotoEyedropperScreen> {
  ui.Image? _image;
  ByteData? _pixels;
  Color? _sampled;
  LabColor? _sampledLab;
  Offset? _tapLocal;
  (double, double, double)? _whiteReference;

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
      _sampled = null;
      _sampledLab = null;
      _tapLocal = null;
      _whiteReference = null;
    });
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  /// Maps a tap inside the BoxFit.contain viewport to image pixel space.
  void _sampleAt(Offset local, Size viewport) {
    final image = _image;
    final pixels = _pixels;
    if (image == null || pixels == null) return;

    final scale = _containScale(image, viewport);
    final drawnW = image.width * scale;
    final drawnH = image.height * scale;
    final dx = (viewport.width - drawnW) / 2;
    final dy = (viewport.height - drawnH) / 2;

    final px = ((local.dx - dx) / scale).floor();
    final py = ((local.dy - dy) / scale).floor();
    if (px < 0 || py < 0 || px >= image.width || py >= image.height) return;

    // Average a 3x3 neighbourhood for a stable sample.
    var r = 0, g = 0, b = 0, n = 0;
    for (var y = py - 1; y <= py + 1; y++) {
      for (var x = px - 1; x <= px + 1; x++) {
        if (x < 0 || y < 0 || x >= image.width || y >= image.height) continue;
        final offset = (y * image.width + x) * 4;
        r += pixels.getUint8(offset);
        g += pixels.getUint8(offset + 1);
        b += pixels.getUint8(offset + 2);
        n++;
      }
    }
    final color = Color.fromARGB(255, r ~/ n, g ~/ n, b ~/ n);
    final srgb = (color.r, color.g, color.b);
    setState(() {
      _sampled = color;
      _sampledLab = srgbToLabAdapted(srgb, whiteReference: _whiteReference);
      _tapLocal = local;
    });
    hapticSelect();
  }

  double _containScale(ui.Image image, Size viewport) {
    final sx = viewport.width / image.width;
    final sy = viewport.height / image.height;
    return sx < sy ? sx : sy;
  }

  void _applyTarget() {
    final lab = _sampledLab;
    if (lab == null) return;
    ref.read(colorTargetProvider.notifier).state = ColorTarget(
      lab: lab,
      name: 'Photo sample',
    );
    hapticMedium();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final lab = _sampledLab;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Eyedropper'),
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
          Expanded(
            child: _image == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.colorize,
                            size: 64,
                            color: AppTheme.ochre.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        const Text('Pick a reference photo, then tap a colour'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Choose from gallery'),
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
                                left: _tapLocal!.dx - 14,
                                top: _tapLocal!.dy - 14,
                                child: IgnorePointer(
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _sampled,
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
          if (_sampled != null && lab != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _sampled,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.ochre.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'L ${lab.l.toStringAsFixed(1)}  '
                          'a ${lab.a.toStringAsFixed(1)}  '
                          'b ${lab.b.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _applyTarget,
                        icon: const Icon(Icons.gps_fixed),
                        label: const Text('Use as target'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.deepBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          final sampled = _sampled;
                          if (sampled == null) return;
                          setState(() {
                            _whiteReference = (sampled.r, sampled.g, sampled.b);
                            _sampledLab = srgbToLabAdapted(
                              (sampled.r, sampled.g, sampled.b),
                              whiteReference: _whiteReference,
                            );
                          });
                        },
                        icon: const Icon(Icons.wb_sunny_outlined, size: 18),
                        label: Text(
                          _whiteReference == null
                              ? 'Set as white card'
                              : 'White card set',
                        ),
                      ),
                      if (_whiteReference != null)
                        TextButton(
                          onPressed: () {
                            final sampled = _sampled;
                            setState(() {
                              _whiteReference = null;
                              if (sampled != null) {
                                _sampledLab = srgbToLabAdapted(
                                  (sampled.r, sampled.g, sampled.b),
                                );
                              }
                            });
                          },
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
