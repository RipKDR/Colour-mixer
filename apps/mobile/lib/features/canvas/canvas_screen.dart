import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/mix_session.dart';

class StrokePoint {
  StrokePoint(this.offset, this.width);
  final Offset offset;
  final double width;
}

class CanvasStroke {
  CanvasStroke({required this.points, required this.color});
  final List<StrokePoint> points;
  final Color color;
}

class CanvasState {
  const CanvasState({
    this.strokes = const [],
    this.undoStack = const [],
    this.brushSize = 12.0,
    this.brushOpacity = 1.0,
  });

  final List<CanvasStroke> strokes;
  final List<CanvasStroke> undoStack;
  final double brushSize;
  final double brushOpacity;

  CanvasState copyWith({
    List<CanvasStroke>? strokes,
    List<CanvasStroke>? undoStack,
    double? brushSize,
    double? brushOpacity,
  }) {
    return CanvasState(
      strokes: strokes ?? this.strokes,
      undoStack: undoStack ?? this.undoStack,
      brushSize: brushSize ?? this.brushSize,
      brushOpacity: brushOpacity ?? this.brushOpacity,
    );
  }
}

class CanvasNotifier extends StateNotifier<CanvasState> {
  CanvasNotifier() : super(const CanvasState());

  CanvasStroke? _currentStroke;

  void startStroke(Offset position, Color color) {
    _currentStroke = CanvasStroke(
      points: [StrokePoint(position, state.brushSize)],
      color: color.withValues(alpha: state.brushOpacity),
    );
  }

  void extendStroke(Offset position) {
    if (_currentStroke == null) return;
    final points = [..._currentStroke!.points, StrokePoint(position, state.brushSize)];
    _currentStroke = CanvasStroke(points: points, color: _currentStroke!.color);
    state = state.copyWith(strokes: [...state.strokes, _currentStroke!]);
  }

  void endStroke() {
    if (_currentStroke != null) {
      final strokes = [...state.strokes];
      if (strokes.isNotEmpty) strokes.removeLast();
      strokes.add(_currentStroke!);
      if (strokes.length > 50) strokes.removeAt(0);
      state = state.copyWith(
        strokes: strokes,
        undoStack: [],
      );
    }
    _currentStroke = null;
  }

  void undo() {
    if (state.strokes.isEmpty) return;
    final strokes = [...state.strokes];
    final removed = strokes.removeLast();
    state = state.copyWith(
      strokes: strokes,
      undoStack: [...state.undoStack, removed],
    );
  }

  void redo() {
    if (state.undoStack.isEmpty) return;
    final undoStack = [...state.undoStack];
    final stroke = undoStack.removeLast();
    state = state.copyWith(
      strokes: [...state.strokes, stroke],
      undoStack: undoStack,
    );
  }

  void clear() => state = const CanvasState();

  void setBrushSize(double size) =>
      state = state.copyWith(brushSize: size.clamp(2, 48));

  void setBrushOpacity(double opacity) =>
      state = state.copyWith(brushOpacity: opacity.clamp(0.1, 1.0));
}

final canvasProvider =
    StateNotifierProvider<CanvasNotifier, CanvasState>((ref) => CanvasNotifier());

class CanvasScreen extends ConsumerWidget {
  const CanvasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvas = ref.watch(canvasProvider);
    final canvasNotifier = ref.read(canvasProvider.notifier);
    final mixColor = ref.watch(mixSessionProvider).result?.color ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canvas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: canvas.strokes.isEmpty ? null : canvasNotifier.undo,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed:
                canvas.undoStack.isEmpty ? null : canvasNotifier.redo,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: canvas.strokes.isEmpty ? null : canvasNotifier.clear,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onPanStart: (d) => canvasNotifier.startStroke(
                      d.localPosition,
                      mixColor,
                    ),
                    onPanUpdate: (d) =>
                        canvasNotifier.extendStroke(d.localPosition),
                    onPanEnd: (_) => canvasNotifier.endStroke(),
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _CanvasPainter(
                        strokes: canvas.strokes,
                        backgroundColor: const Color(0xFFF5F0E8),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          _BrushToolbar(
            color: mixColor,
            brushSize: canvas.brushSize,
            brushOpacity: canvas.brushOpacity,
            onSizeChanged: canvasNotifier.setBrushSize,
            onOpacityChanged: canvasNotifier.setBrushOpacity,
          ),
        ],
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  _CanvasPainter({required this.strokes, required this.backgroundColor});

  final List<CanvasStroke> strokes;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    for (var y = 0.0; y < size.height; y += 8) {
      for (var x = 0.0; x < size.width; x += 8) {
        canvas.drawCircle(
          Offset(x, y),
          0.5,
          Paint()..color = Colors.brown.withValues(alpha: 0.05),
        );
      }
    }

    for (final stroke in strokes) {
      if (stroke.points.length < 2) {
        if (stroke.points.isNotEmpty) {
          final p = stroke.points.first;
          canvas.drawCircle(
            p.offset,
            p.width / 2,
            Paint()..color = stroke.color,
          );
        }
        continue;
      }
      final path = Path()..moveTo(stroke.points.first.offset.dx, stroke.points.first.offset.dy);
      for (var i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].offset.dx, stroke.points[i].offset.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = stroke.color
          ..strokeWidth = stroke.points.first.width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter old) => old.strokes != strokes;
}

class _BrushToolbar extends StatelessWidget {
  const _BrushToolbar({
    required this.color,
    required this.brushSize,
    required this.brushOpacity,
    required this.onSizeChanged,
    required this.onOpacityChanged,
  });

  final Color color;
  final double brushSize;
  final double brushOpacity;
  final ValueChanged<double> onSizeChanged;
  final ValueChanged<double> onOpacityChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color, radius: 16),
          const SizedBox(width: 16),
          const Icon(Icons.brush, size: 20),
          Expanded(
            child: Slider(
              value: brushSize,
              min: 2,
              max: 48,
              label: brushSize.round().toString(),
              onChanged: onSizeChanged,
            ),
          ),
          const Text('Opacity'),
          SizedBox(
            width: 100,
            child: Slider(
              value: brushOpacity,
              min: 0.1,
              max: 1,
              onChanged: onOpacityChanged,
            ),
          ),
        ],
      ),
    );
  }
}
