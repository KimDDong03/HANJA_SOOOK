import 'dart:ui';

import 'stroke_evaluator.dart';

abstract class StrokeEngine {
  const StrokeEngine();

  bool areStrokesSimilar(Path expected, Path actual);

  double scoreError(Path expected, Path actual);
}

class HanjaDemoStrokeEngine extends StrokeEngine {
  const HanjaDemoStrokeEngine({this.evaluator = const HanjaStrokeEvaluator()});

  final HanjaStrokeEvaluator evaluator;

  @override
  bool areStrokesSimilar(Path expected, Path actual) {
    return evaluator.areStrokesSimilar(expected, actual);
  }

  @override
  double scoreError(Path expected, Path actual) {
    return evaluator.scoreError(expected, actual);
  }
}
