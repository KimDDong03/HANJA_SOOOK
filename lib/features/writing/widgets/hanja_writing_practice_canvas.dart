import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../hanja_canvas_geometry.dart';
import '../hanja_guide_grid.dart';
import '../path_morph.dart';
import '../stroke_color_palette.dart';
import '../svg_path_parser.dart';
import '../writing_practice_controller.dart';

class HanjaWritingPracticeCanvas extends StatefulWidget {
  const HanjaWritingPracticeCanvas({
    super.key,
    required this.svgPaths,
    this.canvasExtent,
    this.autoPlayOnStart = false,
    this.completedStrokeCount = 0,
    this.headerLeading,
    this.canvasLeading,
    this.canvasTrailing,
    this.onCompleted,
    this.onStrokeTexture,
    this.onStrokeTextureStop,
    this.viewBox = defaultHanjaViewBox,
  });

  final List<String> svgPaths;
  final double? canvasExtent;
  final bool autoPlayOnStart;
  final int completedStrokeCount;
  final Widget? headerLeading;
  final Widget? canvasLeading;
  final Widget? canvasTrailing;
  final VoidCallback? onCompleted;
  final VoidCallback? onStrokeTexture;
  final VoidCallback? onStrokeTextureStop;
  final Rect viewBox;

  @override
  State<HanjaWritingPracticeCanvas> createState() =>
      _HanjaWritingPracticeCanvasState();
}

class _HanjaWritingPracticeCanvasState extends State<HanjaWritingPracticeCanvas>
    with TickerProviderStateMixin {
  static const WritingPracticeController _practiceController =
      WritingPracticeController();

  late List<Path> _paths;
  late final AnimationController _errorController;
  late final AnimationController _acceptedController;
  late final AnimationController _reviewController;

  int _completedStrokeCount = 0;
  final List<Path> _completedDisplayPaths = [];
  Path? _acceptedFromPath;
  Path? _acceptedToPath;
  Path? _currentUserPath;
  Path? _errorUserPath;
  int? _activePointer;
  int _paintRevision = 0;

  @override
  void initState() {
    super.initState();
    _paths = _parsePaths(widget.svgPaths);
    _applyInitialCompletedStrokeCount();
    _errorController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() => _errorUserPath = null);
          }
        });
    _acceptedController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 420),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() {
              final acceptedTargetPath = _acceptedToPath;
              if (acceptedTargetPath != null) {
                _completedDisplayPaths.add(acceptedTargetPath);
              }
              _completedStrokeCount += 1;
              _acceptedFromPath = null;
              _acceptedToPath = null;
            });
            if (_isComplete) {
              widget.onCompleted?.call();
            }
          }
        });
    _reviewController =
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: _reviewDurationMillis),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() {});
          }
        });
    if (widget.autoPlayOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _playStrokeOrder();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant HanjaWritingPracticeCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.svgPaths, widget.svgPaths) ||
        oldWidget.completedStrokeCount != widget.completedStrokeCount) {
      setState(() {
        _paths = _parsePaths(widget.svgPaths);
        _resetPracticeState();
        _applyInitialCompletedStrokeCount();
      });
    }
  }

  @override
  void dispose() {
    _errorController.dispose();
    _acceptedController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  bool get _isComplete => _completedStrokeCount >= _paths.length;

  bool get _isAnimatingAccepted => _acceptedToPath != null;

  int get _reviewDurationMillis {
    return (_paths.length * 650).clamp(1200, 12000);
  }

  List<Path> _parsePaths(List<String> svgPaths) {
    final paths = <Path>[];
    for (final pathData in svgPaths.where((path) => path.trim().isNotEmpty)) {
      final path = SvgPathParser.tryParse(pathData);
      if (path == null) {
        return const [];
      }
      paths.add(path);
    }
    return paths;
  }

  void _resetPracticeState() {
    _completedStrokeCount = 0;
    _completedDisplayPaths.clear();
    _acceptedFromPath = null;
    _acceptedToPath = null;
    _currentUserPath = null;
    _errorUserPath = null;
    _activePointer = null;
    _paintRevision += 1;
    _errorController.reset();
    _acceptedController.reset();
    _reviewController.reset();
  }

  void _applyInitialCompletedStrokeCount() {
    final completedCount = widget.completedStrokeCount
        .clamp(0, _paths.length)
        .toInt();
    _completedStrokeCount = completedCount;
    _completedDisplayPaths
      ..clear()
      ..addAll(_paths.take(completedCount));
  }

  void _playStrokeOrder() {
    if (_paths.isEmpty) {
      return;
    }
    setState(() {
      _activePointer = null;
      _currentUserPath = null;
      _paintRevision += 1;
    });
    _reviewController.duration = Duration(milliseconds: _reviewDurationMillis);
    _reviewController.forward(from: 0);
  }

  void _toggleStrokeOrder() {
    if (_reviewController.isAnimating) {
      _reviewController.stop();
      setState(() {});
      return;
    }
    _playStrokeOrder();
  }

  void _startStroke(Offset localPosition, Size canvasSize) {
    if (_isComplete ||
        _isAnimatingAccepted ||
        _reviewController.isAnimating ||
        _paths.isEmpty) {
      return;
    }
    final source = _sourcePoint(localPosition, canvasSize);
    setState(() {
      _currentUserPath = Path()..moveTo(source.dx, source.dy);
      _paintRevision += 1;
    });
  }

  void _updateStroke(Offset localPosition, Size canvasSize) {
    final path = _currentUserPath;
    if (path == null ||
        _isComplete ||
        _isAnimatingAccepted ||
        _reviewController.isAnimating) {
      return;
    }
    final source = _sourcePoint(localPosition, canvasSize);
    setState(() {
      path.lineTo(source.dx, source.dy);
      _paintRevision += 1;
    });
  }

  void _endStroke() {
    final userPath = _currentUserPath;
    if (userPath == null ||
        _isComplete ||
        _isAnimatingAccepted ||
        _reviewController.isAnimating) {
      return;
    }

    final expectedPath = _paths[_completedStrokeCount];
    final isCorrect = _practiceController.acceptStroke(
      expectedPath: expectedPath,
      userPath: userPath,
    );
    if (isCorrect) {
      setState(() {
        _currentUserPath = null;
        _acceptedFromPath = userPath;
        _acceptedToPath = expectedPath;
      });
      _acceptedController.forward(from: 0);
      _playStrokeTexture();
      return;
    }

    setState(() {
      _currentUserPath = null;
      _errorUserPath = expectedPath;
    });
    _errorController.forward(from: 0);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.headerLeading case final headerLeading?)
              Expanded(child: headerLeading)
            else
              const Spacer(),
            const SizedBox(width: 8),
            SizedBox(
              width: 108,
              height: 38,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                onPressed: _toggleStrokeOrder,
                icon: Icon(
                  _reviewController.isAnimating ? Icons.stop : Icons.play_arrow,
                  size: 18,
                ),
                label: Text(_reviewController.isAnimating ? '정지' : '획순 보기'),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox.square(
              dimension: 38,
              child: IconButton.filledTonal(
                onPressed: () => setState(_resetPracticeState),
                icon: const Icon(Icons.refresh, size: 21),
                tooltip: '다시 하기',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
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
                              _currentUserPath = null;
                            });
                          },
                          child: GestureDetector(
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
                                animation: Listenable.merge([
                                  _errorController,
                                  _acceptedController,
                                  _reviewController,
                                ]),
                                builder: (context, _) {
                                  return CustomPaint(
                                    painter: _PracticePainter(
                                      paths: _paths,
                                      completedDisplayPaths: List<Path>.of(
                                        _completedDisplayPaths,
                                      ),
                                      completedStrokeCount:
                                          _completedStrokeCount,
                                      acceptedFromPath: _acceptedFromPath,
                                      acceptedToPath: _acceptedToPath,
                                      acceptedProgress:
                                          _acceptedController.value,
                                      errorProgress: _errorController.value,
                                      reviewProgress:
                                          _reviewController.isAnimating
                                          ? _reviewController.value
                                          : null,
                                      paintRevision: _paintRevision,
                                      currentUserPath: _currentUserPath,
                                      errorUserPath: _errorUserPath,
                                      viewBox: widget.viewBox,
                                      strokeColor: colorScheme.onSurface,
                                      errorColor: colorScheme.error,
                                      gridColor: colorScheme.outlineVariant,
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

class _PracticePainter extends CustomPainter {
  const _PracticePainter({
    required this.paths,
    required this.completedDisplayPaths,
    required this.completedStrokeCount,
    required this.acceptedFromPath,
    required this.acceptedToPath,
    required this.acceptedProgress,
    required this.errorProgress,
    required this.reviewProgress,
    required this.paintRevision,
    required this.currentUserPath,
    required this.errorUserPath,
    required this.viewBox,
    required this.strokeColor,
    required this.errorColor,
    required this.gridColor,
  });

  final List<Path> paths;
  final List<Path> completedDisplayPaths;
  final int completedStrokeCount;
  final Path? acceptedFromPath;
  final Path? acceptedToPath;
  final double acceptedProgress;
  final double errorProgress;
  final double? reviewProgress;
  final int paintRevision;
  final Path? currentUserPath;
  final Path? errorUserPath;
  final Rect viewBox;
  final Color strokeColor;
  final Color errorColor;
  final Color gridColor;

  static const _guideStrokeWidth = 8.0;
  static const _completedStrokeWidth = 5.7;
  static const _activeStrokeWidth = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    final transform = HanjaCanvasTransform(size: size, viewBox: viewBox);
    canvas.save();
    transform.apply(canvas);

    final reviewProgress = this.reviewProgress;
    if (reviewProgress != null) {
      _drawAnimatedCharacter(canvas, reviewProgress);
      canvas.restore();
      return;
    }

    final guidePaint = _strokePaint(
      strokeColor.withValues(alpha: 0.13),
      width: _guideStrokeWidth,
    );
    for (final path in paths) {
      canvas.drawPath(path, guidePaint);
    }

    for (var index = 0; index < completedStrokeCount; index += 1) {
      final completedPath = index < completedDisplayPaths.length
          ? completedDisplayPaths[index]
          : paths[index];
      canvas.drawPath(
        completedPath,
        _strokePaint(
          HanjaStrokeColorPalette.colorFor(index).withValues(alpha: 0.88),
          width: _completedStrokeWidth,
        ),
      );
    }

    final fromPath = acceptedFromPath;
    final toPath = acceptedToPath;
    if (fromPath != null && toPath != null) {
      canvas.drawPath(
        HanjaPathMorph.lerp(fromPath, toPath, acceptedProgress),
        _strokePaint(
          HanjaStrokeColorPalette.colorFor(completedStrokeCount),
          width: _activeStrokeWidth,
        ),
      );
    }

    final errorPath = errorUserPath;
    if (errorPath != null) {
      canvas.drawPath(
        errorPath,
        _strokePaint(
          errorColor.withValues(alpha: (1 - errorProgress).clamp(0.0, 1.0)),
          width: _activeStrokeWidth,
        ),
      );
    }

    final userPath = currentUserPath;
    if (userPath != null) {
      canvas.drawPath(
        userPath,
        _strokePaint(
          HanjaStrokeColorPalette.colorFor(completedStrokeCount),
          width: _activeStrokeWidth,
        ),
      );
    }

    canvas.restore();
  }

  void _drawAnimatedCharacter(Canvas canvas, double progress) {
    if (paths.isEmpty) {
      return;
    }

    final activeProgress = progress.clamp(0.0, 1.0) * paths.length;
    final completedCount = activeProgress.floor().clamp(0, paths.length);
    final currentProgress = activeProgress - completedCount;

    for (var index = 0; index < completedCount; index += 1) {
      canvas.drawPath(
        paths[index],
        _strokePaint(
          HanjaStrokeColorPalette.colorFor(index).withValues(alpha: 0.88),
          width: _completedStrokeWidth,
        ),
      );
    }
    if (completedCount < paths.length && currentProgress > 0) {
      canvas.drawPath(
        _extractPath(paths[completedCount], currentProgress),
        _strokePaint(
          HanjaStrokeColorPalette.colorFor(completedCount),
          width: _activeStrokeWidth,
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
  bool shouldRepaint(covariant _PracticePainter oldDelegate) {
    return oldDelegate.paths != paths ||
        oldDelegate.completedDisplayPaths != completedDisplayPaths ||
        oldDelegate.completedStrokeCount != completedStrokeCount ||
        oldDelegate.acceptedFromPath != acceptedFromPath ||
        oldDelegate.acceptedToPath != acceptedToPath ||
        oldDelegate.acceptedProgress != acceptedProgress ||
        oldDelegate.errorProgress != errorProgress ||
        oldDelegate.reviewProgress != reviewProgress ||
        oldDelegate.paintRevision != paintRevision ||
        oldDelegate.currentUserPath != currentUserPath ||
        oldDelegate.errorUserPath != errorUserPath ||
        oldDelegate.viewBox != viewBox ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.errorColor != errorColor ||
        oldDelegate.gridColor != gridColor;
  }
}
