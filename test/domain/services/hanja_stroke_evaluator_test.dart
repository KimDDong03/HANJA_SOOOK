import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/domain/services/hanja_stroke_evaluator.dart';

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

    test('accepts same shape drawn in a different position', () {
      final expected = Path()
        ..moveTo(10, 10)
        ..lineTo(90, 10);
      final actual = Path()
        ..moveTo(10, 80)
        ..lineTo(90, 80);

      expect(evaluator.areStrokesSimilar(expected, actual), isTrue);
    });

    test('rejects different stroke shape', () {
      final expected = Path()
        ..moveTo(10, 10)
        ..lineTo(90, 10);
      final actual = Path()
        ..moveTo(50, 10)
        ..lineTo(50, 90);

      expect(evaluator.areStrokesSimilar(expected, actual), isFalse);
    });

    test('rejects reversed stroke direction', () {
      final expected = Path()
        ..moveTo(10, 10)
        ..lineTo(90, 10);
      final actual = Path()
        ..moveTo(90, 10)
        ..lineTo(10, 10);

      expect(evaluator.areStrokesSimilar(expected, actual), isFalse);
    });

    test('rejects a partial stroke that misses the final turn', () {
      final expected = Path()
        ..moveTo(20, 20)
        ..lineTo(85, 20)
        ..lineTo(85, 85);
      final actual = Path()
        ..moveTo(20, 20)
        ..lineTo(85, 20);

      expect(evaluator.areStrokesSimilar(expected, actual), isFalse);
    });

    test('guided mode rejects a stroke that only matches endpoints', () {
      final expected = Path()
        ..moveTo(20, 20)
        ..lineTo(80, 20)
        ..lineTo(80, 80);
      final actual = Path()
        ..moveTo(20, 20)
        ..lineTo(80, 80);

      expect(evaluator.areGuidedStrokesSimilar(expected, actual), isFalse);
    });

    test(
      'free mode still accepts same shape drawn in a different position',
      () {
        final expected = Path()
          ..moveTo(10, 10)
          ..lineTo(90, 10);
        final actual = Path()
          ..moveTo(10, 80)
          ..lineTo(90, 80);

        expect(evaluator.areStrokesSimilar(expected, actual), isTrue);
      },
    );
  });
}
