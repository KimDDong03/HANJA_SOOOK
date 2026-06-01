import 'dart:ui';

import 'stroke_evaluator.dart';

abstract class StrokeEngine {
  const StrokeEngine();

  bool areStrokesSimilar(Path expected, Path actual);

  bool areGuidedStrokesSimilar(Path expected, Path actual);

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
  bool areGuidedStrokesSimilar(Path expected, Path actual) {
    return evaluator.areGuidedStrokesSimilar(expected, actual);
  }

  @override
  double scoreError(Path expected, Path actual) {
    return evaluator.scoreError(expected, actual);
  }
}

class FallbackStrokeEngine extends StrokeEngine {
  const FallbackStrokeEngine();

  @override
  bool areStrokesSimilar(Path expected, Path actual) {
    return _hasDrawableInput(actual);
  }

  @override
  bool areGuidedStrokesSimilar(Path expected, Path actual) {
    return _hasDrawableInput(actual);
  }

  @override
  double scoreError(Path expected, Path actual) {
    return _hasDrawableInput(actual) ? 35 : 100;
  }

  bool _hasDrawableInput(Path path) {
    return path.computeMetrics().any((metric) => metric.length > 0);
  }
}
