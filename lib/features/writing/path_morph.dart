import 'dart:ui';

class HanjaPathMorph {
  const HanjaPathMorph._();

  static Path lerp(Path from, Path to, double t, {int pointCount = 196}) {
    final fromPoints = _sampleEvenly(from, pointCount);
    final toPoints = _sampleEvenly(to, pointCount);
    if (fromPoints == null || toPoints == null) {
      return to;
    }

    final points = <Offset>[];
    for (var i = 0; i < pointCount; i += 1) {
      points.add(Offset.lerp(fromPoints[i], toPoints[i], t) ?? toPoints[i]);
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final chunk in points.skip(1).toList().chunked(3)) {
      if (chunk.length == 3) {
        path.cubicTo(
          chunk[0].dx,
          chunk[0].dy,
          chunk[1].dx,
          chunk[1].dy,
          chunk[2].dx,
          chunk[2].dy,
        );
      } else {
        path.lineTo(chunk.last.dx, chunk.last.dy);
      }
    }
    return path;
  }

  static List<Offset>? _sampleEvenly(Path path, int pointCount) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty || pointCount < 2) {
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
    for (var i = 0; i < pointCount; i += 1) {
      points.add(_positionAt(metrics, i / (pointCount - 1) * totalLength));
    }
    return points;
  }

  static Offset _positionAt(List<PathMetric> metrics, double distance) {
    var remaining = distance;
    for (final metric in metrics) {
      if (remaining <= metric.length) {
        return metric.getTangentForOffset(remaining)?.position ?? Offset.zero;
      }
      remaining -= metric.length;
    }

    final last = metrics.last;
    return last.getTangentForOffset(last.length)?.position ?? Offset.zero;
  }
}

extension _ChunkedList<T> on List<T> {
  List<List<T>> chunked(int size) {
    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      final end = i + size > length ? length : i + size;
      result.add(sublist(i, end));
    }
    return result;
  }
}
