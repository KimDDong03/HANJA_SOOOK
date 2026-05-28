import 'dart:math' as math;
import 'dart:ui';

import 'hanja_canvas_geometry.dart';

class HanjaStrokeEvaluator {
  const HanjaStrokeEvaluator({
    this.errorThreshold = 100,
    this.interpolationPoints = 22,
  });

  final double errorThreshold;
  final int interpolationPoints;

  bool areStrokesSimilar(Path expected, Path actual) {
    final error = scoreError(expected, actual);
    return error <= errorThreshold;
  }

  double scoreError(Path expected, Path actual) {
    final expectedApproximation = _approximateEvenly(
      expected,
      interpolationPoints,
    );
    final actualApproximation = _approximateEvenly(actual, interpolationPoints);
    if (expectedApproximation == null || actualApproximation == null) {
      return errorThreshold + 1;
    }

    final lengthDiff =
        (expectedApproximation.length - actualApproximation.length).abs();
    final lengthError = 20 * lengthDiff / hanjaSourceSize;

    final expectedCenter = _center(expectedApproximation.points);
    final actualCenter = _center(actualApproximation.points);
    final centerError = 2 * _distance(expectedCenter, actualCenter);

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

    return lengthError + centerError + scaleError + pointDistanceError;
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
}

class _PathApproximation {
  const _PathApproximation({required this.length, required this.points});

  final double length;
  final List<Offset> points;
}
