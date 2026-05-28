import 'package:flutter/material.dart';

import '../hanja_canvas_geometry.dart';
import '../hanja_guide_grid.dart';
import '../path_morph.dart';
import '../svg_path_parser.dart';
import '../writing_practice_controller.dart';

class HanjaWritingPracticeCanvas extends StatefulWidget {
  const HanjaWritingPracticeCanvas({
    super.key,
    required this.svgPaths,
    this.viewBox = defaultHanjaViewBox,
  });

  final List<String> svgPaths;
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
  late final AnimationController _hintController;
  late final AnimationController _studyController;
  late final AnimationController _errorController;
  late final AnimationController _acceptedController;
  late final AnimationController _reviewController;

  int _completedStrokeCount = 0;
  int _currentStrokeMistakes = 0;
  Path? _acceptedFromPath;
  Path? _acceptedToPath;
  Path? _currentUserPath;
  Path? _errorUserPath;
  int? _activePointer;
  int _paintRevision = 0;
  String _statusText = '1획';

  @override
  void initState() {
    super.initState();
    _paths = _parsePaths(widget.svgPaths);
    _statusText = _nextStatusText;
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _studyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
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
              _completedStrokeCount += 1;
              _acceptedFromPath = null;
              _acceptedToPath = null;
              _statusText = _isComplete ? '완료' : _nextStatusText;
            });
            if (!_isComplete) {
              _showStudyStroke();
            }
          }
        });
    _reviewController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _reviewDurationMillis),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showStudyStroke();
      }
    });
  }

  @override
  void didUpdateWidget(covariant HanjaWritingPracticeCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.svgPaths != widget.svgPaths) {
      setState(() {
        _paths = _parsePaths(widget.svgPaths);
        _resetPracticeState();
      });
    }
  }

  @override
  void dispose() {
    _hintController.dispose();
    _studyController.dispose();
    _errorController.dispose();
    _acceptedController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  bool get _isComplete => _completedStrokeCount >= _paths.length;

  bool get _isAnimatingAccepted => _acceptedToPath != null;

  String get _nextStatusText => '${_completedStrokeCount + 1}획';

  int get _reviewDurationMillis {
    return (_paths.length * 650).clamp(1200, 12000);
  }

  List<Path> _parsePaths(List<String> svgPaths) {
    return svgPaths
        .where((path) => path.trim().isNotEmpty)
        .map(SvgPathParser.parse)
        .toList();
  }

  void _resetPracticeState() {
    _completedStrokeCount = 0;
    _currentStrokeMistakes = 0;
    _acceptedFromPath = null;
    _acceptedToPath = null;
    _currentUserPath = null;
    _errorUserPath = null;
    _activePointer = null;
    _paintRevision += 1;
    _statusText = _paths.isEmpty ? '데이터 없음' : '1획';
    _hintController.reset();
    _studyController.reset();
    _errorController.reset();
    _acceptedController.reset();
    _reviewController.reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showStudyStroke();
      }
    });
  }

  void _showHint() {
    if (_isComplete || _paths.isEmpty) {
      return;
    }
    _hintController.forward(from: 0);
  }

  void _showStudyStroke() {
    if (_isComplete || _paths.isEmpty) {
      return;
    }
    _studyController.forward(from: 0);
  }

  void _skipRemainingStrokes() {
    if (_isComplete || _paths.isEmpty) {
      return;
    }
    setState(() {
      _completedStrokeCount = _paths.length;
      _currentStrokeMistakes = 0;
      _currentUserPath = null;
      _errorUserPath = null;
      _acceptedFromPath = null;
      _acceptedToPath = null;
      _statusText = '완료';
      _paintRevision += 1;
    });
  }

  void _toggleReviewAnimation() {
    if (!_isComplete || _paths.isEmpty) {
      return;
    }
    if (_reviewController.isAnimating) {
      _reviewController.stop();
      return;
    }
    _reviewController.duration = Duration(milliseconds: _reviewDurationMillis);
    _reviewController.forward(from: 0);
  }

  void _startStroke(Offset localPosition, Size canvasSize) {
    if (_isComplete || _isAnimatingAccepted || _paths.isEmpty) {
      return;
    }
    final source = _sourcePoint(localPosition, canvasSize);
    setState(() {
      _currentUserPath = Path()..moveTo(source.dx, source.dy);
      _paintRevision += 1;
      _statusText = _nextStatusText;
    });
  }

  void _updateStroke(Offset localPosition, Size canvasSize) {
    final path = _currentUserPath;
    if (path == null || _isComplete || _isAnimatingAccepted) {
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
    if (userPath == null || _isComplete || _isAnimatingAccepted) {
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
        _currentStrokeMistakes = 0;
        _statusText = '좋아요';
      });
      _acceptedController.forward(from: 0);
      return;
    }

    _currentStrokeMistakes += 1;
    setState(() {
      _currentUserPath = null;
      _errorUserPath = _currentStrokeMistakes > 2 ? expectedPath : userPath;
      _statusText = _currentStrokeMistakes > 2 ? '보고 써요' : '다시';
    });
    _errorController.forward(from: 0);
    _hintController.forward(from: 0);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '직접 써보기',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text('$_completedStrokeCount / ${_paths.length}'),
            const SizedBox(width: 8),
            Tooltip(
              message: '힌트',
              child: IconButton.filledTonal(
                onPressed: _showHint,
                icon: const Icon(Icons.lightbulb_outline),
              ),
            ),
            Tooltip(
              message: '다시 시작',
              child: IconButton.filledTonal(
                onPressed: () => setState(_resetPracticeState),
                icon: const Icon(Icons.refresh),
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
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _hintController,
                              _studyController,
                              _errorController,
                              _acceptedController,
                              _reviewController,
                            ]),
                            builder: (context, _) {
                              return CustomPaint(
                                painter: _PracticePainter(
                                  paths: _paths,
                                  completedStrokeCount: _completedStrokeCount,
                                  acceptedFromPath: _acceptedFromPath,
                                  acceptedToPath: _acceptedToPath,
                                  acceptedProgress: _acceptedController.value,
                                  hintProgress: _hintController.value,
                                  studyProgress: _studyController.value,
                                  errorProgress: _errorController.value,
                                  reviewProgress: _reviewController.isAnimating
                                      ? _reviewController.value
                                      : null,
                                  paintRevision: _paintRevision,
                                  currentUserPath: _currentUserPath,
                                  errorUserPath: _errorUserPath,
                                  viewBox: widget.viewBox,
                                  strokeColor: colorScheme.onSurface,
                                  activeColor: colorScheme.primary,
                                  errorColor: colorScheme.error,
                                  gridColor: colorScheme.outlineVariant,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton.filledTonal(
                            onPressed: _showHint,
                            icon: const Icon(Icons.help_outline),
                            tooltip: '다음 획 보기',
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: IconButton.filledTonal(
                            onPressed: _skipRemainingStrokes,
                            icon: const Icon(Icons.check),
                            tooltip: '남은 획 건너뛰기',
                          ),
                        ),
                        if (_isComplete)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: IconButton.filledTonal(
                              onPressed: _toggleReviewAnimation,
                              icon: Icon(
                                _reviewController.isAnimating
                                    ? Icons.stop
                                    : Icons.play_arrow,
                              ),
                              tooltip: '전체 획순 다시 보기',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        _PracticeStatusPill(text: _statusText, isComplete: _isComplete),
      ],
    );
  }
}

class _PracticeStatusPill extends StatelessWidget {
  const _PracticeStatusPill({required this.text, required this.isComplete});

  final String text;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.center,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isComplete
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(text, style: Theme.of(context).textTheme.labelLarge),
        ),
      ),
    );
  }
}

class _PracticePainter extends CustomPainter {
  const _PracticePainter({
    required this.paths,
    required this.completedStrokeCount,
    required this.acceptedFromPath,
    required this.acceptedToPath,
    required this.acceptedProgress,
    required this.hintProgress,
    required this.studyProgress,
    required this.errorProgress,
    required this.reviewProgress,
    required this.paintRevision,
    required this.currentUserPath,
    required this.errorUserPath,
    required this.viewBox,
    required this.strokeColor,
    required this.activeColor,
    required this.errorColor,
    required this.gridColor,
  });

  final List<Path> paths;
  final int completedStrokeCount;
  final Path? acceptedFromPath;
  final Path? acceptedToPath;
  final double acceptedProgress;
  final double hintProgress;
  final double studyProgress;
  final double errorProgress;
  final double? reviewProgress;
  final int paintRevision;
  final Path? currentUserPath;
  final Path? errorUserPath;
  final Rect viewBox;
  final Color strokeColor;
  final Color activeColor;
  final Color errorColor;
  final Color gridColor;

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

    final completedPaint = _strokePaint(
      strokeColor.withValues(alpha: 0.88),
      width: 4.8,
    );
    for (var index = 0; index < completedStrokeCount; index += 1) {
      canvas.drawPath(paths[index], completedPaint);
    }

    final fromPath = acceptedFromPath;
    final toPath = acceptedToPath;
    if (fromPath != null && toPath != null) {
      canvas.drawPath(
        HanjaPathMorph.lerp(fromPath, toPath, acceptedProgress),
        _strokePaint(activeColor, width: 5.2),
      );
    }

    if (studyProgress > 0 && completedStrokeCount < paths.length) {
      canvas.drawPath(
        _extractPath(paths[completedStrokeCount], studyProgress),
        _strokePaint(activeColor.withValues(alpha: 0.34), width: 8.0),
      );
    }

    if (hintProgress > 0 && completedStrokeCount < paths.length) {
      final alpha = (1 - (hintProgress - 0.72).clamp(0.0, 0.28) / 0.28).clamp(
        0.0,
        1.0,
      );
      canvas.drawPath(
        _extractPath(paths[completedStrokeCount], hintProgress),
        _strokePaint(errorColor.withValues(alpha: alpha * 0.75), width: 5.2),
      );
    }

    final errorPath = errorUserPath;
    if (errorPath != null) {
      canvas.drawPath(
        errorPath,
        _strokePaint(
          errorColor.withValues(alpha: (1 - errorProgress).clamp(0.0, 1.0)),
          width: 5.0,
        ),
      );
    }

    final userPath = currentUserPath;
    if (userPath != null) {
      canvas.drawPath(userPath, _strokePaint(activeColor, width: 5.0));
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

    final completedPaint = _strokePaint(strokeColor.withValues(alpha: 0.88), width: 4.8);
    final activePaint = _strokePaint(activeColor, width: 5.2);

    for (var index = 0; index < completedCount; index += 1) {
      canvas.drawPath(paths[index], completedPaint);
    }
    if (completedCount < paths.length && currentProgress > 0) {
      canvas.drawPath(
        _extractPath(paths[completedCount], currentProgress),
        activePaint,
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
        oldDelegate.completedStrokeCount != completedStrokeCount ||
        oldDelegate.acceptedFromPath != acceptedFromPath ||
        oldDelegate.acceptedToPath != acceptedToPath ||
        oldDelegate.acceptedProgress != acceptedProgress ||
        oldDelegate.hintProgress != hintProgress ||
        oldDelegate.studyProgress != studyProgress ||
        oldDelegate.errorProgress != errorProgress ||
        oldDelegate.reviewProgress != reviewProgress ||
        oldDelegate.paintRevision != paintRevision ||
        oldDelegate.currentUserPath != currentUserPath ||
        oldDelegate.errorUserPath != errorUserPath ||
        oldDelegate.viewBox != viewBox ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.errorColor != errorColor ||
        oldDelegate.gridColor != gridColor;
  }
}
