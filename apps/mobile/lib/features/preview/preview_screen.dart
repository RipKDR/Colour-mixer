import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme.dart';
import '../../engine/mix_session.dart';

enum OverlayBlendMode { normal, multiply, overlay, screen, softLight }

class PreviewScreen extends ConsumerStatefulWidget {
  const PreviewScreen({super.key});

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  Uint8List? _imageBytes;
  double _opacity = 0.45;
  OverlayBlendMode _blendMode = OverlayBlendMode.multiply;
  bool _showOverlay = true;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, maxWidth: 2048);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _imageBytes = bytes);
  }

  BlendMode get _flutterBlendMode {
    switch (_blendMode) {
      case OverlayBlendMode.normal:
        return BlendMode.srcOver;
      case OverlayBlendMode.multiply:
        return BlendMode.multiply;
      case OverlayBlendMode.overlay:
        return BlendMode.overlay;
      case OverlayBlendMode.screen:
        return BlendMode.screen;
      case OverlayBlendMode.softLight:
        return BlendMode.softLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mixColor = ref.watch(mixSessionProvider).result?.color ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painting Preview'),
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
            child: _imageBytes == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_outlined,
                            size: 64,
                            color: AppTheme.ochre.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        const Text('Import a photo of your painting'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Choose from gallery'),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(_imageBytes!, fit: BoxFit.contain),
                      if (_showOverlay)
                        IgnorePointer(
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              mixColor.withValues(alpha: _opacity),
                              _flutterBlendMode,
                            ),
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          if (_imageBytes != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(backgroundColor: mixColor, radius: 16),
                      const SizedBox(width: 12),
                      const Text('Current mix overlay'),
                      const Spacer(),
                      Text(_showOverlay ? 'After' : 'Before'),
                      Switch(
                        value: _showOverlay,
                        onChanged: (v) => setState(() => _showOverlay = v),
                      ),
                    ],
                  ),
                  Slider(
                    value: _opacity,
                    label: '${(_opacity * 100).round()}%',
                    onChanged: (v) => setState(() => _opacity = v),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<OverlayBlendMode>(
                      segments: const [
                        ButtonSegment(
                          value: OverlayBlendMode.normal,
                          label: Text('Normal'),
                        ),
                        ButtonSegment(
                          value: OverlayBlendMode.multiply,
                          label: Text('Multiply'),
                        ),
                        ButtonSegment(
                          value: OverlayBlendMode.overlay,
                          label: Text('Overlay'),
                        ),
                        ButtonSegment(
                          value: OverlayBlendMode.screen,
                          label: Text('Screen'),
                        ),
                        ButtonSegment(
                          value: OverlayBlendMode.softLight,
                          label: Text('Soft'),
                        ),
                      ],
                      selected: {_blendMode},
                      onSelectionChanged: (s) =>
                          setState(() => _blendMode = s.first),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
