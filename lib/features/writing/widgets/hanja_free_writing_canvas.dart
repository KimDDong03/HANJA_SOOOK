import 'package:flutter/material.dart';

import '../hanja_canvas_geometry.dart';
import '../hanja_guide_grid.dart';

class HanjaFreeWritingCanvas extends StatefulWidget {
  const HanjaFreeWritingCanvas({
    super.key,
    this.expectedStrokeCount,
    this.viewBox = defaultHanjaViewBox,
  });

  final int? expectedStrokeCount;
  final Rect viewBox;

  @override
  State<HanjaFreeWritingCanvas> createState() => _HanjaFreeWritingCanvasState();
}

class _HanjaFreeWritingCanvasState extends State<HanjaFreeWritingCanvas> {
  final List<Path> _strokes = [];
  Path? _currentPath;
  int? _activePointer;
  int _paintRevision = 0;

  void _startStroke(Offset localPosition, Size canvasSize) {
    final source = _sourcePoint(localPosition, canvasSize);
    setState(() {
      _currentPath = Path()..moveTo(source.dx, source.dy);
      _paintRevision += 1;
    });
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
  }

  void _undoStroke() {
    if (_strokes.isEmpty) {
      return;
    }
    setState(() {
      _strokes.removeLast();
      _paintRevision += 1;
    });
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
  }

  Offset _sourcePoint(Offset localPosition, Size canvasSize) {
    final transform = HanjaCanvasTransform(
      size: canvasSize,
      viewBox: widget.viewBox,
    );
    return transform.canvasToSource(localPosition);
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
            Expanded(
              child: Text(
                '자유쓰기',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(countLabel),
            const SizedBox(width: 8),
            Tooltip(
              message: '한 획 지우기',
              child: IconButton.filledTonal(
                onPressed: _undoStroke,
                icon: const Icon(Icons.undo),
              ),
            ),
            Tooltip(
              message: '모두 지우기',
              child: IconButton.filledTonal(
                onPressed: _clearStrokes,
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 1,
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
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: CustomPaint(
                      painter: _FreeWritingPainter(
                        strokes: List<Path>.of(_strokes),
                        currentPath: _currentPath,
                        paintRevision: _paintRevision,
                        viewBox: widget.viewBox,
                        strokeColor: colorScheme.primary,
                        gridColor: colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
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
    required this.strokeColor,
    required this.gridColor,
  });

  final List<Path> strokes;
  final Path? currentPath;
  final int paintRevision;
  final Rect viewBox;
  final Color strokeColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    final transform = HanjaCanvasTransform(size: size, viewBox: viewBox);
    canvas.save();
    transform.apply(canvas);

    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 5;

    for (final stroke in strokes) {
      canvas.drawPath(stroke, paint);
    }

    final activePath = currentPath;
    if (activePath != null) {
      canvas.drawPath(activePath, paint);
    }

    canvas.restore();
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
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.gridColor != gridColor;
  }
}
