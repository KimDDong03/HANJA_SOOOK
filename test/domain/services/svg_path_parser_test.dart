import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/domain/services/svg_path_parser.dart';

void main() {
  group('SvgPathParser', () {
    test('parses compact relative cubic stroke data', () {
      final path = SvgPathParser.parse(
        'M52.44,11c0.97,0.97,1.69,2.25,1.69,3.68c0,3.42-0.08,4.99-0.08,8.1',
      );

      final metrics = path.computeMetrics().toList();
      final bounds = path.getBounds();

      expect(metrics, hasLength(1));
      expect(metrics.first.length, greaterThan(0));
      expect(bounds.left, closeTo(52.44, 0.01));
      expect(bounds.bottom, greaterThan(20));
    });

    test('parses repeated absolute cubic commands', () {
      final path = SvgPathParser.parse(
        'M0 0 C10 0 10 10 20 10 30 10 30 20 40 20',
      );

      final metrics = path.computeMetrics().toList();
      final bounds = path.getBounds();

      expect(metrics, hasLength(1));
      expect(bounds.right, closeTo(40, 0.01));
      expect(bounds.bottom, closeTo(20, 0.01));
    });
  });
}
