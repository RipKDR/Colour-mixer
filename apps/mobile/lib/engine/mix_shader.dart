import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads the palette-knife spectral blend fragment shader (optional).
final mixShaderProvider = FutureProvider<ui.FragmentProgram?>((ref) async {
  try {
    return ui.FragmentProgram.fromAsset('assets/shaders/mix_blend.frag');
  } catch (_) {
    return null;
  }
});

/// Paints a soft blend between two colours using the mix shader when available.
class MixShaderPainter extends CustomPainter {
  MixShaderPainter({
    required this.center,
    required this.radius,
    required this.colorA,
    required this.colorB,
    required this.progress,
    this.shader,
  });

  final Offset center;
  final double radius;
  final Color colorA;
  final Color colorB;
  final double progress;
  final ui.FragmentShader? shader;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    if (shader != null) {
      shader!
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, colorA.r)
        ..setFloat(3, colorA.g)
        ..setFloat(4, colorA.b)
        ..setFloat(5, colorB.r)
        ..setFloat(6, colorB.g)
        ..setFloat(7, colorB.b)
        ..setFloat(8, progress.clamp(0.0, 1.0));
      canvas.drawRect(
        rect,
        Paint()
          ..shader = shader
          ..blendMode = BlendMode.srcOver,
      );
      return;
    }

    final fallback = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(colorA, colorB, progress)!.withValues(alpha: 0.55),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius, fallback);
  }

  @override
  bool shouldRepaint(covariant MixShaderPainter oldDelegate) =>
      oldDelegate.center != center ||
      oldDelegate.radius != radius ||
      oldDelegate.colorA != colorA ||
      oldDelegate.colorB != colorB ||
      oldDelegate.progress != progress ||
      oldDelegate.shader != shader;
}
