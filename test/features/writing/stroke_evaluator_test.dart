import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/features/writing/stroke_evaluator.dart';

void main() {
  group('HanjaStrokeEvaluator', () {
    const evaluator = HanjaStrokeEvaluator();

    test('accepts similar strokes', () {
      final expected = Path()
        ..moveTo(10, 10)
        ..cubicTo(20, 18, 28, 24, 40, 30);
      final actual = Path()
        ..moveTo(11, 11)
        ..cubicTo(21, 18, 29, 25, 39, 31);

      expect(evaluator.areStrokesSimilar(expected, actual), isTrue);
    });

    test('rejects distant strokes', () {
      final expected = Path()
        ..moveTo(10, 10)
        ..cubicTo(20, 18, 28, 24, 40, 30);
      final actual = Path()
        ..moveTo(80, 85)
        ..cubicTo(84, 90, 90, 96, 100, 100);

      expect(evaluator.areStrokesSimilar(expected, actual), isFalse);
    });
  });
}
