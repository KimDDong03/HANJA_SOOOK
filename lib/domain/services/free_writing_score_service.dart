import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hanja_stroke_evaluator.dart';
import 'svg_path_parser.dart';

final freeWritingScoreServiceProvider = Provider<FreeWritingScoreService>(
  (ref) => const FreeWritingScoreService(),
);

class FreeWritingScoreService {
  const FreeWritingScoreService({
    this.evaluator = const HanjaStrokeEvaluator(minLengthRatio: 0.5),
  });

  static const _passingScore = 65;
  static const _strokeFailureScore = 45.0;
  static const _strokeScoreErrorWeight = 0.55;

  final HanjaStrokeEvaluator evaluator;

  FreeWritingScoreResult score({
    required List<Path> userStrokes,
    required List<String> expectedSvgPaths,
    required int? expectedStrokeCount,
  }) {
    final expectedPaths = _parseExpectedPaths(expectedSvgPaths);

    return expectedPaths != null && expectedPaths.isNotEmpty
        ? _scoreWithExpectedPaths(
            userStrokes: userStrokes,
            expectedPaths: expectedPaths,
          )
        : _scoreWithStrokeCount(
            userStrokes: userStrokes,
            expectedStrokeCount: expectedStrokeCount,
          );
  }

  List<Path>? _parseExpectedPaths(List<String> expectedSvgPaths) {
    final paths = <Path>[];
    for (final pathData in expectedSvgPaths.where(
      (path) => path.trim().isNotEmpty,
    )) {
      final path = SvgPathParser.tryParse(pathData);
      if (path == null) {
        return null;
      }
      paths.add(path);
    }
    return paths;
  }

  FreeWritingScoreResult _scoreWithExpectedPaths({
    required List<Path> userStrokes,
    required List<Path> expectedPaths,
  }) {
    if (userStrokes.isEmpty) {
      return _failedResult(
        score: 0,
        failedStrokeIndex: 0,
        failureReason: FreeWritingFailureReason.missingStroke,
        expectedHintPath: expectedPaths.first,
      );
    }

    if (userStrokes.length != expectedPaths.length) {
      final countDiff = (userStrokes.length - expectedPaths.length).abs();
      final failedStrokeIndex = userStrokes.length < expectedPaths.length
          ? userStrokes.length
          : expectedPaths.length;
      return _failedResult(
        score: (40 - countDiff * 10).clamp(0, 45).toDouble(),
        failedStrokeIndex: failedStrokeIndex,
        failureReason: userStrokes.length < expectedPaths.length
            ? FreeWritingFailureReason.missingStroke
            : FreeWritingFailureReason.extraStroke,
        expectedHintPath: failedStrokeIndex < expectedPaths.length
            ? expectedPaths[failedStrokeIndex]
            : null,
      );
    }

    var scoreSum = 0.0;
    for (var index = 0; index < expectedPaths.length; index += 1) {
      final evaluation = evaluator.evaluate(
        expectedPaths[index],
        userStrokes[index],
      );
      final error = evaluation.error;
      final strokeScore = (100 - error * _strokeScoreErrorWeight)
          .clamp(0, 100)
          .toDouble();
      if (strokeScore < _passingScore) {
        return _failedResult(
          score: _strokeFailureScore,
          failedStrokeIndex: index,
          failureReason: switch (evaluation.failureReason) {
            StrokeFailureReason.direction => FreeWritingFailureReason.direction,
            StrokeFailureReason.shape => FreeWritingFailureReason.shape,
          },
          expectedHintPath: expectedPaths[index],
        );
      }
      scoreSum += strokeScore;
    }

    return _passedResult(scoreSum / expectedPaths.length);
  }

  FreeWritingScoreResult _scoreWithStrokeCount({
    required List<Path> userStrokes,
    required int? expectedStrokeCount,
  }) {
    if (userStrokes.isEmpty) {
      return _failedResult(
        score: 0,
        failedStrokeIndex: 0,
        failureReason: FreeWritingFailureReason.missingStroke,
        expectedHintPath: null,
      );
    }

    if (expectedStrokeCount == null || expectedStrokeCount <= 0) {
      return _passedResult(
        _scoreFreeModeFallback(
          userStrokes: userStrokes,
          expectedStrokeCount: expectedStrokeCount,
        ),
      );
    }

    return _passedResult(
      _scoreFreeModeFallback(
        userStrokes: userStrokes,
        expectedStrokeCount: expectedStrokeCount,
      ),
    );
  }

  double _scoreFreeModeFallback({
    required List<Path> userStrokes,
    required int? expectedStrokeCount,
  }) {
    var score = 60.0;
    final totalLength = _totalLength(userStrokes);
    if (totalLength >= 35) {
      score += 10;
    }
    if (_coversCenterArea(userStrokes)) {
      score += 10;
    }
    final expectedCount = expectedStrokeCount;
    if (expectedCount != null && expectedCount > 0) {
      final countDiff = (userStrokes.length - expectedCount).abs();
      if (countDiff == 0) {
        score += 10;
      } else if (countDiff == 1) {
        score += 5;
      }
    }
    if (totalLength < 12) {
      score -= 30;
    }
    return score.clamp(0, 85).toDouble();
  }

  double _totalLength(List<Path> strokes) {
    var total = 0.0;
    for (final stroke in strokes) {
      for (final metric in stroke.computeMetrics()) {
        total += metric.length;
      }
    }
    return total;
  }

  bool _coversCenterArea(List<Path> strokes) {
    final bounds = _combinedBounds(strokes);
    if (bounds == null) {
      return false;
    }
    final center = bounds.center;
    return center.dx >= 25 &&
        center.dx <= 75 &&
        center.dy >= 25 &&
        center.dy <= 75 &&
        bounds.width >= 20 &&
        bounds.height >= 20;
  }

  Rect? _combinedBounds(List<Path> strokes) {
    Rect? bounds;
    for (final stroke in strokes) {
      final strokeBounds = stroke.getBounds();
      if (strokeBounds.isEmpty) {
        continue;
      }
      bounds = bounds == null
          ? strokeBounds
          : bounds.expandToInclude(strokeBounds);
    }
    return bounds;
  }

  FreeWritingScoreResult _passedResult(double score) {
    final roundedScore = score.round().clamp(0, 100);
    return FreeWritingScoreResult(
      score: roundedScore,
      passed: _isPassed(roundedScore),
      stars: _starsForScore(roundedScore),
      message: _messageForScore(roundedScore),
      failedStrokeIndex: null,
      failureReason: null,
      failureMessage: null,
      expectedHintPath: null,
    );
  }

  FreeWritingScoreResult _failedResult({
    required double score,
    required int? failedStrokeIndex,
    required FreeWritingFailureReason failureReason,
    required Path? expectedHintPath,
  }) {
    final roundedScore = score.round().clamp(0, 100);
    return FreeWritingScoreResult(
      score: roundedScore,
      passed: false,
      stars: _starsForScore(roundedScore),
      message: _messageForScore(roundedScore),
      failedStrokeIndex: failedStrokeIndex,
      failureReason: failureReason,
      failureMessage: _failureMessage(
        failedStrokeIndex: failedStrokeIndex,
        failureReason: failureReason,
      ),
      expectedHintPath: expectedHintPath,
    );
  }

  int _starsForScore(int score) {
    if (score >= 85) {
      return 3;
    }
    if (score >= 65) {
      return 2;
    }
    if (score >= 45) {
      return 1;
    }
    return 0;
  }

  bool _isPassed(int score) => score >= _passingScore;

  String _messageForScore(int score) {
    if (score >= 85) {
      return '아주 잘했어요!';
    }
    if (score >= 65) {
      return '잘했어요!';
    }
    if (score >= 45) {
      return '조금만 더 연습해요.';
    }
    return '다시 써볼까요?';
  }

  String _failureMessage({
    required int? failedStrokeIndex,
    required FreeWritingFailureReason failureReason,
  }) {
    final strokeLabel = failedStrokeIndex == null
        ? '획'
        : '${failedStrokeIndex + 1}번째 획';
    return switch (failureReason) {
      FreeWritingFailureReason.missingStroke => '$strokeLabel을 더 써야 해요.',
      FreeWritingFailureReason.extraStroke => '$strokeLabel이 많아요. 한 획 지워볼까요?',
      FreeWritingFailureReason.direction => '$strokeLabel의 방향을 다시 확인해요.',
      FreeWritingFailureReason.shape => '$strokeLabel의 모양을 조금 더 비슷하게 써봐요.',
      FreeWritingFailureReason.missingStrokeData =>
        '정확한 획순 데이터가 없어 통과 판정을 할 수 없어요.',
    };
  }
}

enum FreeWritingFailureReason {
  missingStroke,
  extraStroke,
  direction,
  shape,
  missingStrokeData,
}

class FreeWritingScoreResult {
  const FreeWritingScoreResult({
    required this.score,
    required this.passed,
    required this.stars,
    required this.message,
    required this.failedStrokeIndex,
    required this.failureReason,
    required this.failureMessage,
    required this.expectedHintPath,
  });

  final int score;
  final bool passed;
  final int stars;
  final String message;
  final int? failedStrokeIndex;
  final FreeWritingFailureReason? failureReason;
  final String? failureMessage;
  final Path? expectedHintPath;

  bool get canContinueDemoFlow => passed;
}
