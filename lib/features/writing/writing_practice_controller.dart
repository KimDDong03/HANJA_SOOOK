import 'dart:ui';

import 'stroke_engine.dart';

class WritingPracticeController {
  const WritingPracticeController({
    this.strokeEngine = const HanjaDemoStrokeEngine(),
  });

  final StrokeEngine strokeEngine;

  bool acceptStroke({required Path expectedPath, required Path userPath}) {
    return strokeEngine.areGuidedStrokesSimilar(expectedPath, userPath);
  }
}
