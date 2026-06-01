import 'package:flutter/material.dart';

import '../hanja_canvas_geometry.dart';
import '../hanja_guide_grid.dart';
import '../stroke_color_palette.dart';

class HanjaFreeWritingCanvas extends StatefulWidget {
  const HanjaFreeWritingCanvas({
    super.key,
    this.expectedStrokeCount,
    this.onStrokesChanged,
    this.canvasExtent,
    this.showTitle = true,
    this.onStrokeTexture,
    this.viewBox = defaultHanjaViewBox,
    this.failedStrokeIndex,
    this.expectedHintPath,
  });

  final int? expectedStrokeCount;
  final ValueChanged<List<Path>>? onStrokesChanged;
  final double? canvasExtent;
  final bool showTitle;
  final VoidCallback? onStrokeTexture;
  final Rect viewBox;
  final int? failedStrokeIndex;
  final Path? expectedHintPath;

  @override
  State<HanjaFreeWritingCanvas> createState() => _HanjaFreeWritingCanvasState();
}

class _HanjaFreeWritingCanvasState extends State<HanjaFreeWritingCanvas> {
  final List<Path> _strokes = [];
  Path? _currentPath;
  int? _activePointer;
  int _paintRevision = 0;
  DateTime? _lastStrokeTextureAt;

  static const _strokeTextureInterval = Duration(milliseconds: 120);

  void _startStroke(Offset localPosition, Size canvasSize) {
    final source = _sourcePoint(localPosition, canvasSize);
    setState(() {
      _currentPath = Path()..moveTo(source.dx, source.dy);
      _paintRevision += 1;
    });
    _playStrokeTexture();
  }

  void _updateStroke(Offset localPosition, Size canvasSize) {
    final path = _currentPath;
    if (path == null) {
      return;
    }
    final source = _sourcePoint(localPosition, canvasSize);
    setState(() {
      path.lineTo(source.dx, source.dy);
      _paintRevision += 1;
    });
    _playStrokeTexture();
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
    final now = DateTime.now();
    final lastPlayedAt = _lastStrokeTextureAt;
    if (lastPlayedAt != null &&
        now.difference(lastPlayedAt) < _strokeTextureInterval) {
      return;
    }
    _lastStrokeTextureAt = now;
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
            else
              const Spacer(),
            Text(countLabel),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: _undoStroke,
              icon: const Icon(Icons.undo),
              tooltip: '한 획 지우기',
            ),
            IconButton.filledTonal(
              onPressed: _clearStrokes,
              icon: const Icon(Icons.delete_outline),
              tooltip: '모두 지우기',
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final canvasExtent =
                widget.canvasExtent?.clamp(0, constraints.maxWidth) ??
                constraints.maxWidth;
            return Align(
              alignment: Alignment.center,
              child: SizedBox.square(
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
                        key: const ValueKey('hanja-free-writing-canvas-input'),
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
                          child: CustomPaint(
                            painter: _FreeWritingPainter(
                              strokes: List<Path>.of(_strokes),
                              currentPath: _currentPath,
                              paintRevision: _paintRevision,
                              viewBox: widget.viewBox,
                              failedStrokeColor: colorScheme.error,
                              hintStrokeColor: colorScheme.error.withValues(
                                alpha: 0.28,
                              ),
                              gridColor: colorScheme.outlineVariant,
                              failedStrokeIndex: widget.failedStrokeIndex,
                              expectedHintPath: widget.expectedHintPath,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
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
    required this.gridColor,
    required this.failedStrokeIndex,
    required this.expectedHintPath,
  });

  final List<Path> strokes;
  final Path? currentPath;
  final int paintRevision;
  final Rect viewBox;
  final Color failedStrokeColor;
  final Color hintStrokeColor;
  final Color gridColor;
  final int? failedStrokeIndex;
  final Path? expectedHintPath;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    final transform = HanjaCanvasTransform(size: size, viewBox: viewBox);
    canvas.save();
    transform.apply(canvas);

    final hintPath = expectedHintPath;
    if (hintPath != null) {
      final hintPaint = Paint()
        ..color = hintStrokeColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 7;
      canvas.drawPath(hintPath, hintPaint);
    }

    for (var index = 0; index < strokes.length; index += 1) {
      if (index == failedStrokeIndex) {
        final failedPaint = Paint()
          ..color = failedStrokeColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 6;
        canvas.drawPath(strokes[index], failedPaint);
      } else {
        canvas.drawPath(
          strokes[index],
          _strokePaint(HanjaStrokeColorPalette.colorFor(index), width: 5),
        );
      }
    }

    final activePath = currentPath;
    if (activePath != null) {
      canvas.drawPath(
        activePath,
        _strokePaint(
          HanjaStrokeColorPalette.colorFor(strokes.length),
          width: 5,
        ),
      );
    }

    canvas.restore();
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

  @override
  bool shouldRepaint(covariant _FreeWritingPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentPath != currentPath ||
        oldDelegate.paintRevision != paintRevision ||
        oldDelegate.viewBox != viewBox ||
        oldDelegate.failedStrokeColor != failedStrokeColor ||
        oldDelegate.hintStrokeColor != hintStrokeColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.failedStrokeIndex != failedStrokeIndex ||
        oldDelegate.expectedHintPath != expectedHintPath;
  }
}
