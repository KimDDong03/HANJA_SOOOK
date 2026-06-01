import 'dart:math' as math;
import 'dart:ui';

import 'hanja_canvas_geometry.dart';

class HanjaStrokeEvaluator {
  const HanjaStrokeEvaluator({
    this.errorThreshold = 100,
    this.interpolationPoints = 22,
    this.minLengthRatio = 0.72,
  });

  final double errorThreshold;
  final int interpolationPoints;
  final double minLengthRatio;

  bool areStrokesSimilar(Path expected, Path actual) {
    final error = scoreError(expected, actual);
    return error <= errorThreshold;
  }

  bool areGuidedStrokesSimilar(Path expected, Path actual) {
    final result = evaluate(expected, actual, requirePositionMatch: true);
    return result.error <= errorThreshold;
  }

  double scoreError(Path expected, Path actual) {
    return evaluate(expected, actual).error;
  }

  StrokeEvaluationResult evaluate(
    Path expected,
    Path actual, {
    bool requirePositionMatch = false,
  }) {
    final expectedApproximation = _approximateEvenly(
      expected,
      interpolationPoints,
    );
    final actualApproximation = _approximateEvenly(actual, interpolationPoints);
    if (expectedApproximation == null || actualApproximation == null) {
      return StrokeEvaluationResult(
        error: errorThreshold + 1,
        failureReason: StrokeFailureReason.shape,
      );
    }
    if (!_hasSimilarDirection(expectedApproximation, actualApproximation)) {
      return StrokeEvaluationResult(
        error: errorThreshold + 1,
        failureReason: StrokeFailureReason.direction,
      );
    }
    if (!_hasEnoughLength(expectedApproximation, actualApproximation)) {
      return StrokeEvaluationResult(
        error: errorThreshold + 1,
        failureReason: StrokeFailureReason.shape,
      );
    }
    if (requirePositionMatch &&
        !_followsExpectedPath(expectedApproximation, actualApproximation)) {
      return StrokeEvaluationResult(
        error: errorThreshold + 1,
        failureReason: StrokeFailureReason.shape,
      );
    }

    final lengthDiff =
        (expectedApproximation.length - actualApproximation.length).abs();
    final lengthError = 20 * lengthDiff / hanjaSourceSize;

    final expectedCenter = _center(expectedApproximation.points);
    final actualCenter = _center(actualApproximation.points);

    final expectedCentered = _decreaseAll(
      expectedApproximation.points,
      expectedCenter,
    );
    final actualCentered = _decreaseAll(
      actualApproximation.points,
      actualCenter,
    );
    final expectedScale = _scale(expectedCentered);
    final actualScale = _scale(actualCentered);
    final scaleError = _scaleError(expectedScale, actualScale);

    final expectedScaledToActual = expectedCentered
        .map(
          (point) => Offset(
            point.dx * actualScale.width / expectedScale.width,
            point.dy * actualScale.height / expectedScale.height,
          ),
        )
        .toList();

    var pointDistanceSum = 0.0;
    for (var i = 0; i < expectedScaledToActual.length; i += 1) {
      pointDistanceSum += _distance(
        expectedScaledToActual[i],
        actualCentered[i],
      );
    }
    final pointDistanceError = 0.2 * pointDistanceSum;

    return StrokeEvaluationResult(
      error: lengthError + scaleError + pointDistanceError,
      failureReason: StrokeFailureReason.shape,
    );
  }

  _PathApproximation? _approximateEvenly(Path path, int pointsCount) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty || pointsCount < 2) {
      return null;
    }

    final totalLength = metrics.fold<double>(
      0,
      (sum, metric) => sum + metric.length,
    );
    if (totalLength <= 0) {
      return null;
    }

    final points = <Offset>[];
    for (var i = 0; i < pointsCount; i += 1) {
      final targetDistance = i / (pointsCount - 1) * totalLength;
      points.add(_positionAt(metrics, targetDistance));
    }

    return _PathApproximation(length: totalLength, points: points);
  }

  Offset _positionAt(List<PathMetric> metrics, double distance) {
    var remaining = distance;
    for (final metric in metrics) {
      if (remaining <= metric.length) {
        final tangent = metric.getTangentForOffset(remaining);
        return tangent?.position ?? Offset.zero;
      }
      remaining -= metric.length;
    }

    final last = metrics.last;
    return last.getTangentForOffset(last.length)?.position ?? Offset.zero;
  }

  Offset _center(List<Offset> points) {
    final sum = points.fold<Offset>(
      Offset.zero,
      (previous, point) => previous + point,
    );
    return sum / points.length.toDouble();
  }

  List<Offset> _decreaseAll(List<Offset> points, Offset value) {
    return points.map((point) => point - value).toList();
  }

  Size _scale(List<Offset> points) {
    final xs = points.map((point) => point.dx);
    final ys = points.map((point) => point.dy);
    return Size(math.max(_range(xs), 1), math.max(_range(ys), 1));
  }

  double _range(Iterable<double> values) {
    return values.reduce(math.max) - values.reduce(math.min);
  }

  double _scaleError(Size first, Size second) {
    final widthScaleDiff = _bigSideToShortSideRatio(first.width, second.width);
    final heightScaleDiff = _bigSideToShortSideRatio(
      first.height,
      second.height,
    );
    return 5 * (widthScaleDiff + heightScaleDiff);
  }

  double _bigSideToShortSideRatio(double first, double second) {
    return math.max(first, second) / math.min(first, second);
  }

  double _distance(Offset first, Offset second) {
    return (first - second).distance;
  }

  bool _hasSimilarDirection(
    _PathApproximation expected,
    _PathApproximation actual,
  ) {
    final expectedVector = expected.points.last - expected.points.first;
    final actualVector = actual.points.last - actual.points.first;
    final expectedDistance = expectedVector.distance;
    final actualDistance = actualVector.distance;
    if (expectedDistance <= 1 || actualDistance <= 1) {
      return false;
    }
    final dot =
        expectedVector.dx * actualVector.dx +
        expectedVector.dy * actualVector.dy;
    final cosine = dot / (expectedDistance * actualDistance);
    return cosine >= 0.35;
  }

  bool _hasEnoughLength(
    _PathApproximation expected,
    _PathApproximation actual,
  ) {
    return actual.length >= expected.length * minLengthRatio;
  }

  bool _followsExpectedPath(
    _PathApproximation expected,
    _PathApproximation actual,
  ) {
    var missCount = 0;
    for (var i = 0; i < expected.points.length; i += 1) {
      final allowedDistance = math.max(18.0, expected.length * 0.18);
      if (_distance(expected.points[i], actual.points[i]) > allowedDistance) {
        missCount += 1;
      }
    }
    return missCount <= math.max(2, interpolationPoints ~/ 5);
  }
}

enum StrokeFailureReason { direction, shape }

class StrokeEvaluationResult {
  const StrokeEvaluationResult({
    required this.error,
    required this.failureReason,
  });

  final double error;
  final StrokeFailureReason failureReason;
}

class _PathApproximation {
  const _PathApproximation({required this.length, required this.points});

  final double length;
  final List<Offset> points;
}
