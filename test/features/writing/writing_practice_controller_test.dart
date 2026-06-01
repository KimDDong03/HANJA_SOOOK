import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/features/writing/stroke_engine.dart';
import 'package:hanja_soook/features/writing/writing_practice_controller.dart';

void main() {
  test('WritingPracticeController delegates stroke acceptance to engine', () {
    final controller = WritingPracticeController(
      strokeEngine: _AlwaysAcceptStrokeEngine(),
    );

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(1, 1);

    expect(controller.acceptStroke(expectedPath: path, userPath: path), isTrue);
  });

  test('FallbackStrokeEngine accepts any drawable input', () {
    const engine = FallbackStrokeEngine();
    final expected = Path()
      ..moveTo(0, 0)
      ..lineTo(1, 1);
    final actual = Path()
      ..moveTo(3, 3)
      ..lineTo(8, 8);

    expect(engine.areGuidedStrokesSimilar(expected, actual), isTrue);
    expect(engine.scoreError(expected, actual), 35);
  });
}

class _AlwaysAcceptStrokeEngine extends StrokeEngine {
  const _AlwaysAcceptStrokeEngine();

  @override
  bool areStrokesSimilar(Path expected, Path actual) => true;

  @override
  bool areGuidedStrokesSimilar(Path expected, Path actual) => true;

  @override
  double scoreError(Path expected, Path actual) => 0;
}
