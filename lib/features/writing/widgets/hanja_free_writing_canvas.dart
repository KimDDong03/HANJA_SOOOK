import 'package:flutter/material.dart';

import '../hanja_canvas_geometry.dart';
import '../hanja_guide_grid.dart';
import '../stroke_color_palette.dart';

class HanjaFreeWritingCanvas extends StatefulWidget {
  const HanjaFreeWritingCanvas({
    super.key,
    this.expectedStrokeCount,
    this.initialStrokes = const [],
    this.onStrokesChanged,
    this.canvasExtent,
    this.canvasLeading,
    this.canvasTrailing,
    this.toolbarLeading,
    this.showTitle = true,
    this.onStrokeTexture,
    this.onStrokeTextureStop,
    this.viewBox = defaultHanjaViewBox,
    this.failedStrokeIndex,
    this.expectedHintPath,
    this.expectedHintPaths = const [],
    this.showStrokeOrderButton = false,
    this.strokeOrderPreviewPaths = const [],
    this.strokeOrderPreviewRequest = 0,
    this.onStrokeOrderPreviewed,
  });

  final int? expectedStrokeCount;
  final List<Path> initialStrokes;
  final ValueChanged<List<Path>>? onStrokesChanged;
  final double? canvasExtent;
  final Widget? canvasLeading;
  final Widget? canvasTrailing;
  final Widget? toolbarLeading;
  final bool showTitle;
  final VoidCallback? onStrokeTexture;
  final VoidCallback? onStrokeTextureStop;
  final Rect viewBox;
  final int? failedStrokeIndex;
  final Path? expectedHintPath;
  final List<Path> expectedHintPaths;
  final bool showStrokeOrderButton;
  final List<Path> strokeOrderPreviewPaths;
  final int strokeOrderPreviewRequest;
  final VoidCallback? onStrokeOrderPreviewed;

  @override
  State<HanjaFreeWritingCanvas> createState() => _HanjaFreeWritingCanvasState();
}

class _HanjaFreeWritingCanvasState extends State<HanjaFreeWritingCanvas>
    with SingleTickerProviderStateMixin {
  final List<Path> _strokes = [];
  Path? _currentPath;
  int? _activePointer;
  int _paintRevision = 0;
  late final AnimationController _strokeOrderController;

  @override
  void initState() {
    super.initState();
    _strokes.addAll(widget.initialStrokes);
    _strokeOrderController =
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: _strokeOrderDurationMillis),
        )..addStatusListener((status) {
          if (mounted &&
              (status == AnimationStatus.completed ||
                  status == AnimationStatus.dismissed)) {
            setState(() {});
          }
        });
    if (widget.strokeOrderPreviewRequest > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _playStrokeOrder();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant HanjaFreeWritingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStrokes != widget.initialStrokes) {
      setState(() {
        _strokes
          ..clear()
          ..addAll(widget.initialStrokes);
        _currentPath = null;
        _paintRevision += 1;
      });
    }
    if (oldWidget.strokeOrderPreviewPaths != widget.strokeOrderPreviewPaths) {
      _strokeOrderController.duration = Duration(
        milliseconds: _strokeOrderDurationMillis,
      );
    }
    if (oldWidget.strokeOrderPreviewRequest !=
            widget.strokeOrderPreviewRequest &&
        widget.strokeOrderPreviewRequest > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _playStrokeOrder();
        }
      });
    }
  }

  @override
  void dispose() {
    _strokeOrderController.dispose();
    super.dispose();
  }

  int get _strokeOrderDurationMillis {
    return (widget.strokeOrderPreviewPaths.length * 650)
        .clamp(1200, 12000)
        .toInt();
  }

  void _playStrokeOrder() {
    if (widget.strokeOrderPreviewPaths.isEmpty) {
      return;
    }
    setState(() {
      _activePointer = null;
      _currentPath = null;
      _paintRevision += 1;
    });
    _strokeOrderController.duration = Duration(
      milliseconds: _strokeOrderDurationMillis,
    );
    _strokeOrderController.forward(from: 0);
    setState(() {});
    widget.onStrokeOrderPreviewed?.call();
  }

  void _toggleStrokeOrder() {
    if (_strokeOrderController.isAnimating) {
      _strokeOrderController.stop();
      setState(() {});
      return;
    }
    _playStrokeOrder();
  }

  void _startStroke(Offset localPosition, Size canvasSize) {
    if (_strokeOrderController.isAnimating) {
      return;
    }
    final source = _sourcePoint(localPosition, canvasSize);
    setState(() {
      _currentPath = Path()..moveTo(source.dx, source.dy);
      _paintRevision += 1;
    });
  }

  void _updateStroke(Offset localPosition, Size canvasSize) {
    final path = _currentPath;
    if (path == null || _strokeOrderController.isAnimating) {
      return;
    }
    final source = _sourcePoint(localPosition, canvasSize);
    setState(() {
      path.lineTo(source.dx, source.dy);
      _paintRevision += 1;
    });
  }

  void _endStroke() {
    final path = _currentPath;
    if (path == null) {
      return;
    }
    setState(() {
      _strokes.add(path);
      _currentPath = null;
      _paintRevision += 1;
    });
    _notifyStrokesChanged();
    _playStrokeTexture();
  }

  void _undoStroke() {
    if (_strokes.isEmpty) {
      return;
    }
    setState(() {
      _strokes.removeLast();
      _paintRevision += 1;
    });
    _notifyStrokesChanged();
  }

  void _clearStrokes() {
    if (_strokes.isEmpty && _currentPath == null) {
      return;
    }
    setState(() {
      _strokes.clear();
      _currentPath = null;
      _paintRevision += 1;
    });
    _notifyStrokesChanged();
  }

  void _notifyStrokesChanged() {
    widget.onStrokesChanged?.call(List<Path>.unmodifiable(_strokes));
  }

  Offset _sourcePoint(Offset localPosition, Size canvasSize) {
    final transform = HanjaCanvasTransform(
      size: canvasSize,
      viewBox: widget.viewBox,
    );
    return transform.canvasToSource(localPosition);
  }

  void _playStrokeTexture() {
    widget.onStrokeTexture?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final expectedStrokeCount = widget.expectedStrokeCount;
    final countLabel = expectedStrokeCount == null
        ? '${_strokes.length}획'
        : '${_strokes.length} / $expectedStrokeCount';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (widget.showTitle)
              Expanded(
                child: Text(
                  '자유쓰기',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              )
            else if (widget.toolbarLeading case final toolbarLeading?)
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: toolbarLeading,
                  ),
                ),
              )
            else
              const Spacer(),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        countLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _CanvasToolButton(
                        onPressed: _strokes.isEmpty ? null : _undoStroke,
                        icon: const Icon(Icons.undo),
                        tooltip: '한 획 지우기',
                      ),
                      const SizedBox(width: 6),
                      if (widget.showStrokeOrderButton) ...[
                        _CanvasToolButton(
                          onPressed: widget.strokeOrderPreviewPaths.isEmpty
                              ? null
                              : _toggleStrokeOrder,
                          icon: Icon(
                            _strokeOrderController.isAnimating
                                ? Icons.stop
                                : Icons.play_arrow,
                          ),
                          tooltip: _strokeOrderController.isAnimating
                              ? '획순 보기 정지'
                              : '획순 보기',
                        ),
                        const SizedBox(width: 6),
                      ],
                      _CanvasToolButton(
                        onPressed: _strokes.isEmpty && _currentPath == null
                            ? null
                            : _clearStrokes,
                        icon: const Icon(Icons.delete_outline),
                        tooltip: '모두 지우기',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final hasLeading = widget.canvasLeading != null;
            final hasTrailing = widget.canvasTrailing != null;
            final sideSlotWidth = hasLeading || hasTrailing ? 44.0 : 0.0;
            final sideGap = hasLeading || hasTrailing ? 8.0 : 0.0;
            final sideSpace =
                (hasLeading ? sideSlotWidth + sideGap : 0.0) +
                (hasTrailing ? sideSlotWidth + sideGap : 0.0);
            final canvasExtent =
                widget.canvasExtent?.clamp(
                  0,
                  (constraints.maxWidth - sideSpace).clamp(
                    0.0,
                    constraints.maxWidth,
                  ),
                ) ??
                (constraints.maxWidth - sideSpace).clamp(
                  0.0,
                  constraints.maxWidth,
                );
            return Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.canvasLeading case final leading?) ...[
                    SizedBox(
                      width: sideSlotWidth,
                      child: Center(child: leading),
                    ),
                    SizedBox(width: sideGap),
                  ],
                  SizedBox.square(
                    dimension: canvasExtent.toDouble(),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final canvasSize = Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        );
                        return Listener(
                          onPointerDown: (event) {
                            if (_activePointer != null) {
                              return;
                            }
                            _activePointer = event.pointer;
                            _startStroke(event.localPosition, canvasSize);
                          },
                          onPointerMove: (event) {
                            if (_activePointer != event.pointer) {
                              return;
                            }
                            _updateStroke(event.localPosition, canvasSize);
                          },
                          onPointerUp: (event) {
                            if (_activePointer != event.pointer) {
                              return;
                            }
                            _activePointer = null;
                            _endStroke();
                          },
                          onPointerCancel: (event) {
                            if (_activePointer != event.pointer) {
                              return;
                            }
                            setState(() {
                              _activePointer = null;
                              _currentPath = null;
                              _paintRevision += 1;
                            });
                          },
                          child: GestureDetector(
                            key: const ValueKey(
                              'hanja-free-writing-canvas-input',
                            ),
                            behavior: HitTestBehavior.opaque,
                            onVerticalDragStart: (_) {},
                            onVerticalDragUpdate: (_) {},
                            onVerticalDragEnd: (_) {},
                            onHorizontalDragStart: (_) {},
                            onHorizontalDragUpdate: (_) {},
                            onHorizontalDragEnd: (_) {},
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              child: AnimatedBuilder(
                                animation: _strokeOrderController,
                                builder: (context, _) {
                                  return CustomPaint(
                                    painter: _FreeWritingPainter(
                                      strokes: List<Path>.of(_strokes),
                                      currentPath: _currentPath,
                                      paintRevision: _paintRevision,
                                      viewBox: widget.viewBox,
                                      failedStrokeColor: colorScheme.error,
                                      hintStrokeColor: colorScheme.error
                                          .withValues(alpha: 0.28),
                                      guideStrokeColor: colorScheme.onSurface
                                          .withValues(alpha: 0.13),
                                      gridColor: colorScheme.outlineVariant,
                                      failedStrokeIndex:
                                          widget.failedStrokeIndex,
                                      expectedHintPath: widget.expectedHintPath,
                                      expectedHintPaths:
                                          widget.expectedHintPaths,
                                      strokeOrderPreviewPaths:
                                          widget.strokeOrderPreviewPaths,
                                      strokeOrderProgress:
                                          _strokeOrderController.isAnimating
                                          ? _strokeOrderController.value
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (widget.canvasTrailing case final trailing?) ...[
                    SizedBox(width: sideGap),
                    SizedBox(
                      width: sideSlotWidth,
                      child: Center(child: trailing),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CanvasToolButton extends StatelessWidget {
  const _CanvasToolButton({
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: IconButton.filledTonal(
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size.square(40),
        ),
        onPressed: onPressed,
        icon: icon,
        tooltip: tooltip,
      ),
    );
  }
}

class _FreeWritingPainter extends CustomPainter {
  const _FreeWritingPainter({
    required this.strokes,
    required this.currentPath,
    required this.paintRevision,
    required this.viewBox,
    required this.failedStrokeColor,
    required this.hintStrokeColor,
    required this.guideStrokeColor,
    required this.gridColor,
    required this.failedStrokeIndex,
    required this.expectedHintPath,
    required this.expectedHintPaths,
    required this.strokeOrderPreviewPaths,
    required this.strokeOrderProgress,
  });

  final List<Path> strokes;
  final Path? currentPath;
  final int paintRevision;
  final Rect viewBox;
  final Color failedStrokeColor;
  final Color hintStrokeColor;
  final Color guideStrokeColor;
  final Color gridColor;
  final int? failedStrokeIndex;
  final Path? expectedHintPath;
  final List<Path> expectedHintPaths;
  final List<Path> strokeOrderPreviewPaths;
  final double? strokeOrderProgress;

  static const _hintStrokeWidth = 8.0;
  static const _failedStrokeWidth = 7.0;
  static const _userStrokeWidth = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    final transform = HanjaCanvasTransform(size: size, viewBox: viewBox);
    canvas.save();
    transform.apply(canvas);

    final strokeOrderProgress = this.strokeOrderProgress;
    if (strokeOrderProgress != null && strokeOrderPreviewPaths.isNotEmpty) {
      _drawAnimatedStrokeOrder(canvas, strokeOrderProgress);
      canvas.restore();
      return;
    }

    if (expectedHintPaths.isNotEmpty) {
      final guidePaint = Paint()
        ..color = guideStrokeColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = _hintStrokeWidth;
      for (final path in expectedHintPaths) {
        canvas.drawPath(path, guidePaint);
      }
    }

    final hintPath = expectedHintPath;
    if (hintPath != null) {
      final hintPaint = Paint()
        ..color = hintStrokeColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = _hintStrokeWidth;
      canvas.drawPath(hintPath, hintPaint);
    }

    for (var index = 0; index < strokes.length; index += 1) {
      if (index == failedStrokeIndex) {
        final failedPaint = Paint()
          ..color = failedStrokeColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = _failedStrokeWidth;
        canvas.drawPath(strokes[index], failedPaint);
      } else {
        canvas.drawPath(
          strokes[index],
          _strokePaint(
            HanjaStrokeColorPalette.colorFor(index),
            width: _userStrokeWidth,
          ),
        );
      }
    }

    final activePath = currentPath;
    if (activePath != null) {
      canvas.drawPath(
        activePath,
        _strokePaint(
          HanjaStrokeColorPalette.colorFor(strokes.length),
          width: _userStrokeWidth,
        ),
      );
    }

    canvas.restore();
  }

  void _drawAnimatedStrokeOrder(Canvas canvas, double progress) {
    final activeProgress =
        progress.clamp(0.0, 1.0) * strokeOrderPreviewPaths.length;
    final completedCount = activeProgress
        .floor()
        .clamp(0, strokeOrderPreviewPaths.length)
        .toInt();
    final currentProgress = activeProgress - completedCount;

    for (var index = 0; index < completedCount; index += 1) {
      canvas.drawPath(
        strokeOrderPreviewPaths[index],
        _strokePaint(
          HanjaStrokeColorPalette.colorFor(index).withValues(alpha: 0.88),
          width: _userStrokeWidth,
        ),
      );
    }
    if (completedCount < strokeOrderPreviewPaths.length &&
        currentProgress > 0) {
      canvas.drawPath(
        _extractPath(strokeOrderPreviewPaths[completedCount], currentProgress),
        _strokePaint(
          HanjaStrokeColorPalette.colorFor(completedCount),
          width: _userStrokeWidth,
        ),
      );
    }
  }

  Paint _strokePaint(Color color, {required double width}) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = width;
  }

  void _drawGrid(Canvas canvas, Size size) {
    drawHanjaGuideGrid(
      canvas: canvas,
      size: size,
      viewBox: viewBox,
      color: gridColor,
    );
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

  @override
  bool shouldRepaint(covariant _FreeWritingPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentPath != currentPath ||
        oldDelegate.paintRevision != paintRevision ||
        oldDelegate.viewBox != viewBox ||
        oldDelegate.failedStrokeColor != failedStrokeColor ||
        oldDelegate.hintStrokeColor != hintStrokeColor ||
        oldDelegate.guideStrokeColor != guideStrokeColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.failedStrokeIndex != failedStrokeIndex ||
        oldDelegate.expectedHintPath != expectedHintPath ||
        oldDelegate.expectedHintPaths != expectedHintPaths ||
        oldDelegate.strokeOrderPreviewPaths != strokeOrderPreviewPaths ||
        oldDelegate.strokeOrderProgress != strokeOrderProgress;
  }
}
