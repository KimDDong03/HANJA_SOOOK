import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/features/writing/path_morph.dart';

void main() {
  group('HanjaPathMorph', () {
    test('interpolates between two drawable paths', () {
      final from = Path()
        ..moveTo(0, 0)
        ..lineTo(30, 0);
      final to = Path()
        ..moveTo(0, 0)
        ..lineTo(0, 30);

      final middle = HanjaPathMorph.lerp(from, to, 0.5, pointCount: 16);
      final metrics = middle.computeMetrics().toList();
      final bounds = middle.getBounds();

      expect(metrics, hasLength(1));
      expect(metrics.first.length, greaterThan(0));
      expect(bounds.right, greaterThan(0));
      expect(bounds.bottom, greaterThan(0));
    });

    test('returns target path when source cannot be sampled', () {
      final empty = Path();
      final target = Path()
        ..moveTo(5, 5)
        ..lineTo(10, 10);

      final result = HanjaPathMorph.lerp(empty, target, 0.5);

      expect(result.getBounds(), target.getBounds());
    });
  });
}
