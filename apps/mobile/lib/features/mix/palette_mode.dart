import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics.dart';
import '../../core/theme.dart';
import '../../engine/chroma_engine.dart';
import '../../engine/mix_shader.dart';
import '../../engine/mix_session.dart';

class PaintBlob {
  PaintBlob({
    required this.pigmentId,
    required this.position,
    required this.radius,
    this.weight = 1.0,
  });

  final String pigmentId;
  Offset position;
  double radius;
  double weight;
}

class PaletteModeScreen extends ConsumerStatefulWidget {
  const PaletteModeScreen({super.key});

  @override
  ConsumerState<PaletteModeScreen> createState() => _PaletteModeScreenState();
}

class _PaletteModeScreenState extends ConsumerState<PaletteModeScreen> {
  final List<PaintBlob> _blobs = [];
  final List<List<PaintBlob>> _undoStack = [];
  Offset? _knifePosition;
  bool _isMixing = false;
  bool _dragDidPush = false;
  ui.FragmentShader? _mixShader;

  @override
  void dispose() {
    _mixShader?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initBlobs();
      _loadShader();
    });
  }

  Future<void> _loadShader() async {
    final program = await ref.read(mixShaderProvider.future);
    if (!mounted || program == null) return;
    setState(() => _mixShader = program.fragmentShader());
  }

  void _initBlobs() {
    final engine = ref.read(engineProvider).requireValue;
    final blue = engine.getPigment('ultramarine_blue');
    final yellow = engine.getPigment('hansa_yellow');
    if (blue == null || yellow == null) return;
    setState(() {
      _blobs.clear();
      _blobs.addAll([
        PaintBlob(
          pigmentId: blue.id,
          position: const Offset(120, 180),
          radius: 45,
          weight: 2,
        ),
        PaintBlob(
          pigmentId: yellow.id,
          position: const Offset(220, 200),
          radius: 40,
          weight: 2,
        ),
      ]);
    });
    _syncToSession();
  }

  void _pushUndo() {
    _undoStack.add(_blobs.map((b) => PaintBlob(
          pigmentId: b.pigmentId,
          position: b.position,
          radius: b.radius,
          weight: b.weight,
        )).toList());
    if (_undoStack.length > 30) _undoStack.removeAt(0);
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    setState(() {
      _blobs.clear();
      _blobs.addAll(_undoStack.removeLast());
    });
    _syncToSession();
  }

  void _syncToSession() {
    final entries = _blobs
        .map((b) => MixEntry(pigmentId: b.pigmentId, weight: b.weight))
        .toList();
    ref.read(mixSessionProvider.notifier).setEntriesFromPalette(entries);
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    setState(() {
      _knifePosition = details.localPosition;
      for (final blob in _blobs) {
        final dist = (blob.position - details.localPosition).distance;
        if (dist < blob.radius + 20) {
          blob.position += details.delta * 0.3;
          _isMixing = true;
        }
      }
      _checkMerge();
    });
  }

  void _onPanStart(DragStartDetails details) {
    hapticLight();
    // Snapshot BEFORE the drag mutates blobs, so undo restores pre-drag state.
    _pushUndo();
    _dragDidPush = true;
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isMixing) {
      hapticMedium();
      _syncToSession();
    } else if (_dragDidPush) {
      // Nothing changed; drop the speculative snapshot.
      _undoStack.removeLast();
    }
    _dragDidPush = false;
    setState(() {
      _knifePosition = null;
      _isMixing = false;
    });
  }

  void _checkMerge() {
    for (var i = 0; i < _blobs.length; i++) {
      for (var j = i + 1; j < _blobs.length; j++) {
        final a = _blobs[i];
        final b = _blobs[j];
        final dist = (a.position - b.position).distance;
        if (dist < (a.radius + b.radius) * 0.7) {
          hapticLight();
          // B keeps its own blob below, so the merged blob must carry only
          // A's weight or B's contribution gets counted twice in the mix.
          final merged = PaintBlob(
            pigmentId: a.pigmentId,
            position: Offset(
              (a.position.dx + b.position.dx) / 2,
              (a.position.dy + b.position.dy) / 2,
            ),
            radius: math.min(a.radius + b.radius * 0.3, 70),
            weight: a.weight,
          );
          _blobs.removeAt(j);
          _blobs.removeAt(i);
          _blobs.add(merged);
          _blobs.add(PaintBlob(
            pigmentId: b.pigmentId,
            position: merged.position + const Offset(15, 10),
            radius: b.radius * 0.6,
            weight: b.weight,
          ));
          return;
        }
      }
    }
  }

  (Color, Color)? _knifeBlendColors(ChromaEngine engine) {
    if (_knifePosition == null || _blobs.length < 2) return null;
    final nearby = _blobs.where((b) {
      return (b.position - _knifePosition!).distance < b.radius + 30;
    }).toList();
    if (nearby.length < 2) return null;
    final a = engine.getPigment(nearby[0].pigmentId)?.color;
    final b = engine.getPigment(nearby[1].pigmentId)?.color;
    if (a == null || b == null) return null;
    return (a, b);
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(engineProvider).requireValue;
    final result = ref.watch(mixSessionProvider).result;
    final blendColors = _knifeBlendColors(engine);

    return Column(
      children: [
        if (result != null)
          Container(
            height: 48,
            color: result.color,
            child: Center(
              child: Text(
                'L:${result.lab.l.toStringAsFixed(0)} '
                'a:${result.lab.a.toStringAsFixed(0)} '
                'b:${result.lab.b.toStringAsFixed(0)}',
                style: TextStyle(
                  color: result.lab.l > 50 ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 3,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onPanUpdate: (d) =>
                          _onPanUpdate(d, constraints.biggest),
                      onPanEnd: _onPanEnd,
                      onPanStart: _onPanStart,
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: _PalettePainter(
                          // Copy so shouldRepaint sees a new identity when
                          // blobs are added/merged/undone in place.
                          blobs: List.of(_blobs),
                          engine: engine,
                          knifePosition: _knifePosition,
                          mixColor: result?.color,
                          isMixing: _isMixing,
                          mixShader: _mixShader,
                          blendColorA: blendColors?.$1,
                          blendColorB: blendColors?.$2,
                          canvasSize: constraints.biggest,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  onPressed: _undoStack.isEmpty ? null : _undo,
                  icon: const Icon(Icons.undo),
                  tooltip: 'Undo',
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _PigmentShelf(
                  pigments: engine.allPigments.take(8).toList(),
                  onAdd: (id) {
                    _pushUndo();
                    setState(() {
                      _blobs.add(PaintBlob(
                        pigmentId: id,
                        position: Offset(
                          100.0 + _blobs.length * 30,
                          280,
                        ),
                        radius: 35,
                      ));
                    });
                    _syncToSession();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PalettePainter extends CustomPainter {
  _PalettePainter({
    required this.blobs,
    required this.engine,
    this.knifePosition,
    this.mixColor,
    this.isMixing = false,
    this.mixShader,
    this.blendColorA,
    this.blendColorB,
    this.canvasSize = Size.zero,
  });

  final List<PaintBlob> blobs;
  final ChromaEngine engine;
  final Offset? knifePosition;
  final Color? mixColor;
  final bool isMixing;
  final ui.FragmentShader? mixShader;
  final Color? blendColorA;
  final Color? blendColorB;
  final Size canvasSize;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(40, 60, size.width - 80, size.height - 160);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    final woodPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF8B6914),
          const Color(0xFFA67C00),
          const Color(0xFF8B6914),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRRect(rrect, woodPaint);

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (final blob in blobs) {
      final pigment = engine.getPigment(blob.pigmentId);
      if (pigment == null) continue;

      final paint = Paint()
        ..color = pigment.color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(blob.position, blob.radius, paint);

      final highlight = Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(
        blob.position - Offset(blob.radius * 0.2, blob.radius * 0.2),
        blob.radius * 0.3,
        highlight,
      );
    }

    if (knifePosition != null) {
      final knifePaint = Paint()
        ..color = AppTheme.ochre
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        knifePosition! - const Offset(20, 0),
        knifePosition! + const Offset(20, 0),
        knifePaint,
      );
      if (isMixing && mixColor != null) {
        if (blendColorA != null && blendColorB != null) {
          MixShaderPainter(
            center: knifePosition!,
            radius: 32,
            colorA: blendColorA!,
            colorB: blendColorB!,
            progress: 0.5,
            shader: mixShader,
          ).paint(canvas, canvasSize);
        } else {
          final mixPaint = Paint()
            ..color = mixColor!.withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
          canvas.drawCircle(knifePosition!, 25, mixPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PalettePainter old) =>
      old.blobs != blobs ||
      old.knifePosition != knifePosition ||
      old.isMixing != isMixing ||
      old.mixColor != mixColor ||
      old.mixShader != mixShader ||
      old.blendColorA != blendColorA ||
      old.blendColorB != blendColorB;
}

class _PigmentShelf extends StatelessWidget {
  const _PigmentShelf({required this.pigments, required this.onAdd});

  final List<PigmentModel> pigments;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pigments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, i) {
          final p = pigments[i];
          return GestureDetector(
            onTap: () {
              hapticLight();
              onAdd(p.id);
            },
            child: Tooltip(
              message: p.name,
              child: CircleAvatar(radius: 20, backgroundColor: p.color),
            ),
          );
        },
      ),
    );
  }
}
