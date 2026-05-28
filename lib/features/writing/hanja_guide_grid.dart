import 'dart:math' as math;
import 'dart:ui';

import 'hanja_canvas_geometry.dart';

void drawHanjaGuideGrid({
  required Canvas canvas,
  required Size size,
  required Rect viewBox,
  required Color color,
}) {
  final transform = HanjaCanvasTransform(size: size, viewBox: viewBox);
  final rect = transform.gridRect;
  final borderPaint = Paint()
    ..color = color.withValues(alpha: 0.7)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final diagonalPaint = Paint()
    ..color = color.withValues(alpha: 0.42)
    ..strokeWidth = 1;
  final centerPaint = Paint()
    ..color = color.withValues(alpha: 0.78)
    ..strokeWidth = 1.4
    ..strokeCap = StrokeCap.square;
  final quarterPaint = Paint()
    ..color = color.withValues(alpha: 0.42)
    ..strokeWidth = 1
    ..strokeCap = StrokeCap.square;

  canvas.drawRect(rect, borderPaint);
  canvas.drawLine(rect.topLeft, rect.bottomRight, diagonalPaint);
  canvas.drawLine(rect.topRight, rect.bottomLeft, diagonalPaint);

  _drawDottedLine(canvas, rect.topCenter, rect.bottomCenter, centerPaint);
  _drawDottedLine(canvas, rect.centerLeft, rect.centerRight, centerPaint);

  final quarterX = rect.left + rect.width / 4;
  final threeQuarterX = rect.left + rect.width * 3 / 4;
  final quarterY = rect.top + rect.height / 4;
  final threeQuarterY = rect.top + rect.height * 3 / 4;

  _drawDottedLine(
    canvas,
    Offset(quarterX, rect.top),
    Offset(quarterX, rect.bottom),
    quarterPaint,
    dashLength: 5,
    gapLength: 7,
  );
  _drawDottedLine(
    canvas,
    Offset(threeQuarterX, rect.top),
    Offset(threeQuarterX, rect.bottom),
    quarterPaint,
    dashLength: 5,
    gapLength: 7,
  );
  _drawDottedLine(
    canvas,
    Offset(rect.left, quarterY),
    Offset(rect.right, quarterY),
    quarterPaint,
    dashLength: 5,
    gapLength: 7,
  );
  _drawDottedLine(
    canvas,
    Offset(rect.left, threeQuarterY),
    Offset(rect.right, threeQuarterY),
    quarterPaint,
    dashLength: 5,
    gapLength: 7,
  );
}

void _drawDottedLine(
  Canvas canvas,
  Offset start,
  Offset end,
  Paint paint, {
  double dashLength = 6,
  double gapLength = 6,
}) {
  final vector = end - start;
  final distance = vector.distance;
  if (distance <= 0) {
    return;
  }

  final direction = vector / distance;
  var drawn = 0.0;
  while (drawn < distance) {
    final next = math.min(drawn + dashLength, distance);
    canvas.drawLine(start + direction * drawn, start + direction * next, paint);
    drawn = next + gapLength;
  }
}
