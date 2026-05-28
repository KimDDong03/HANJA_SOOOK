import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../hanja_canvas_geometry.dart';
import '../hanja_guide_grid.dart';
import '../svg_path_parser.dart';

class AnimatedHanjaStrokePreview extends StatefulWidget {
  const AnimatedHanjaStrokePreview({
    super.key,
    required this.svgPaths,
    this.viewBox = defaultHanjaViewBox,
  });

  final List<String> svgPaths;
  final Rect viewBox;

  @override
  State<AnimatedHanjaStrokePreview> createState() =>
      _AnimatedHanjaStrokePreviewState();
}

class _AnimatedHanjaStrokePreviewState extends State<AnimatedHanjaStrokePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<Path> _paths;

  @override
  void initState() {
    super.initState();
    _paths = _parsePaths(widget.svgPaths);
    _controller = AnimationController(vsync: this, duration: _durationForPaths)
      ..forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedHanjaStrokePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.svgPaths != widget.svgPaths) {
      _paths = _parsePaths(widget.svgPaths);
      _controller.duration = _durationForPaths;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Duration get _durationForPaths {
    return Duration(milliseconds: math.max(1200, _paths.length * 650));
  }

  List<Path> _parsePaths(List<String> svgPaths) {
    return svgPaths
        .where((path) => path.trim().isNotEmpty)
        .map(SvgPathParser.parse)
        .toList();
  }

  void _replay() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _AnimatedHanjaStrokePainter(
                      paths: _paths,
                      progress: _controller.value,
                      viewBox: widget.viewBox,
                      strokeColor: colorScheme.onSurface,
                      activeStrokeColor: colorScheme.primary,
                      gridColor: colorScheme.outlineVariant,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Tooltip(
                message: '획순 다시 보기',
                child: IconButton.filledTonal(
                  onPressed: _replay,
                  icon: const Icon(Icons.replay),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedHanjaStrokePainter extends CustomPainter {
  const _AnimatedHanjaStrokePainter({
    required this.paths,
    required this.progress,
    required this.viewBox,
    required this.strokeColor,
    required this.activeStrokeColor,
    required this.gridColor,
  });

  final List<Path> paths;
  final double progress;
  final Rect viewBox;
  final Color strokeColor;
  final Color activeStrokeColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    if (paths.isEmpty) {
      return;
    }

    final transform = HanjaCanvasTransform(size: size, viewBox: viewBox);
    canvas.save();
    transform.apply(canvas);

    final activeProgress = progress.clamp(0.0, 1.0) * paths.length;
    final completedStrokeCount = activeProgress.floor();
    final currentStrokeProgress = activeProgress - completedStrokeCount;

    final completedPaint = Paint()
      ..color = strokeColor.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 4.8;

    final activePaint = Paint()
      ..color = activeStrokeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 5.2;

    for (var index = 0; index < paths.length; index += 1) {
      if (index < completedStrokeCount) {
        canvas.drawPath(paths[index], completedPaint);
        continue;
      }

      if (index == completedStrokeCount && currentStrokeProgress > 0) {
        final partialPath = _extractPath(paths[index], currentStrokeProgress);
        canvas.drawPath(partialPath, activePaint);
      }
    }

    canvas.restore();
  }

  Path _extractPath(Path path, double progress) {
    final output = Path();
    for (final metric in path.computeMetrics()) {
      output.addPath(
        metric.extractPath(0, metric.length * progress.clamp(0.0, 1.0)),
        Offset.zero,
      );
    }
    return output;
  }

  void _drawGrid(Canvas canvas, Size size) {
    drawHanjaGuideGrid(
      canvas: canvas,
      size: size,
      viewBox: viewBox,
      color: gridColor,
    );
  }

  @override
  bool shouldRepaint(covariant _AnimatedHanjaStrokePainter oldDelegate) {
    return oldDelegate.paths != paths ||
        oldDelegate.progress != progress ||
        oldDelegate.viewBox != viewBox ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.activeStrokeColor != activeStrokeColor ||
        oldDelegate.gridColor != gridColor;
  }
}
