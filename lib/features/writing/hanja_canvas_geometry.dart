import 'dart:math' as math;
import 'dart:ui';

export '../../domain/services/hanja_stroke_geometry.dart';

class HanjaCanvasTransform {
  HanjaCanvasTransform({
    required this.size,
    required this.viewBox,
    this.padding = 16,
  }) {
    final side = math.min(size.width, size.height);
    final drawableSide = math.max(0.0, side - padding * 2);
    scale = drawableSide / math.max(viewBox.width, viewBox.height);
    dx = (size.width - viewBox.width * scale) / 2;
    dy = (size.height - viewBox.height * scale) / 2;
  }

  final Size size;
  final Rect viewBox;
  final double padding;

  late final double scale;
  late final double dx;
  late final double dy;

  Rect get gridRect {
    final side = math.min(size.width, size.height);
    final left = (size.width - side) / 2;
    final top = (size.height - side) / 2;
    return Rect.fromLTWH(left, top, side, side).deflate(padding);
  }

  Offset canvasToSource(Offset canvasPoint) {
    return Offset(
      (canvasPoint.dx - dx) / scale + viewBox.left,
      (canvasPoint.dy - dy) / scale + viewBox.top,
    );
  }

  void apply(Canvas canvas) {
    canvas.translate(dx, dy);
    canvas.scale(scale);
    canvas.translate(-viewBox.left, -viewBox.top);
  }
}
