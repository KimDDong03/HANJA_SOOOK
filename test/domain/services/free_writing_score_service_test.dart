import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/domain/services/free_writing_score_service.dart';

void main() {
  group('FreeWritingScoreService', () {
    const controller = FreeWritingScoreService();

    test('scores similar free writing strokes with stars', () {
      final userStroke = Path()
        ..moveTo(10, 10)
        ..lineTo(90, 90);

      final result = controller.score(
        userStrokes: [userStroke],
        expectedSvgPaths: const ['M 10 10 L 90 90'],
        expectedStrokeCount: 1,
      );

      expect(result.score, greaterThanOrEqualTo(85));
      expect(result.passed, isTrue);
      expect(result.stars, 3);
      expect(result.message, '아주 잘했어요!');
    });

    test('passes the same shape drawn in a different position', () {
      final shiftedStroke = Path()
        ..moveTo(10, 82)
        ..lineTo(90, 82);

      final result = controller.score(
        userStrokes: [shiftedStroke],
        expectedSvgPaths: const ['M 10 20 L 90 20'],
        expectedStrokeCount: 1,
      );

      expect(result.score, greaterThanOrEqualTo(65));
      expect(result.passed, isTrue);
    });

    test('passes a shorter same-direction stroke in free writing', () {
      final shorterStroke = Path()
        ..moveTo(25, 20)
        ..lineTo(75, 20);

      final result = controller.score(
        userStrokes: [shorterStroke],
        expectedSvgPaths: const ['M 10 20 L 90 20'],
        expectedStrokeCount: 1,
      );

      expect(result.score, greaterThanOrEqualTo(65));
      expect(result.passed, isTrue);
    });

    test('uses forgiving free-mode score when stroke paths are missing', () {
      final userStroke = Path()
        ..moveTo(10, 10)
        ..lineTo(90, 90);

      final result = controller.score(
        userStrokes: [userStroke],
        expectedSvgPaths: const [],
        expectedStrokeCount: 1,
      );

      expect(result.score, 85);
      expect(result.passed, isTrue);
      expect(result.stars, 3);
    });

    test('falls back to free-mode score when stroke path data is invalid', () {
      final userStroke = Path()
        ..moveTo(10, 10)
        ..lineTo(90, 90);

      final result = controller.score(
        userStrokes: [userStroke],
        expectedSvgPaths: const ['M 10 10 L'],
        expectedStrokeCount: 1,
      );

      expect(result.score, 85);
      expect(result.passed, isTrue);
      expect(result.failedStrokeIndex, isNull);
    });

    test('does not pass when stroke order or count is different', () {
      final userStroke = Path()
        ..moveTo(10, 10)
        ..lineTo(90, 90);

      final result = controller.score(
        userStrokes: [userStroke],
        expectedSvgPaths: const ['M 10 10 L 90 10', 'M 10 90 L 90 90'],
        expectedStrokeCount: 2,
      );

      expect(result.score, lessThan(65));
      expect(result.passed, isFalse);
      expect(result.failedStrokeIndex, 1);
      expect(result.failureReason, FreeWritingFailureReason.missingStroke);
      expect(result.canContinueDemoFlow, isFalse);
    });

    test('does not pass a vertical stroke for horizontal one hanja', () {
      final verticalStroke = Path()
        ..moveTo(54.5, 7)
        ..lineTo(54.5, 102);

      final result = controller.score(
        userStrokes: [verticalStroke],
        expectedSvgPaths: const [
          'M11,54.25c3.19,0.62,6.25,0.75,9.73,0.5c20.64-1.5,50.39-5.12,68.58-5.24c3.6-0.02,5.77,0.24,7.57,0.49',
        ],
        expectedStrokeCount: 1,
      );

      expect(result.score, lessThan(65));
      expect(result.passed, isFalse);
      expect(result.failedStrokeIndex, 0);
      expect(result.failureReason, FreeWritingFailureReason.direction);
      expect(result.failureMessage, '1번째 획의 방향을 다시 확인해요.');
    });

    test('does not pass a short vertical mark for one hanja', () {
      final verticalStroke = Path()
        ..moveTo(54.5, 35)
        ..lineTo(54.5, 74);

      final result = controller.score(
        userStrokes: [verticalStroke],
        expectedSvgPaths: const [
          'M11,54.25c3.19,0.62,6.25,0.75,9.73,0.5c20.64-1.5,50.39-5.12,68.58-5.24c3.6-0.02,5.77,0.24,7.57,0.49',
        ],
        expectedStrokeCount: 1,
      );

      expect(result.score, lessThan(65));
      expect(result.passed, isFalse);
    });

    test('does not pass reversed stroke direction', () {
      final reversedStroke = Path()
        ..moveTo(96.88, 50)
        ..lineTo(11, 54.25);

      final result = controller.score(
        userStrokes: [reversedStroke],
        expectedSvgPaths: const [
          'M11,54.25c3.19,0.62,6.25,0.75,9.73,0.5c20.64-1.5,50.39-5.12,68.58-5.24c3.6-0.02,5.77,0.24,7.57,0.49',
        ],
        expectedStrokeCount: 1,
      );

      expect(result.score, lessThan(65));
      expect(result.passed, isFalse);
    });

    test(
      'does not pass when one stroke in a multi-stroke hanja is reversed',
      () {
        final result = controller.score(
          userStrokes: [
            Path()
              ..moveTo(10, 10)
              ..lineTo(90, 10),
            Path()
              ..moveTo(10, 25)
              ..lineTo(90, 25),
            Path()
              ..moveTo(10, 40)
              ..lineTo(90, 40),
            Path()
              ..moveTo(90, 55)
              ..lineTo(10, 55),
            Path()
              ..moveTo(10, 70)
              ..lineTo(90, 70),
            Path()
              ..moveTo(10, 85)
              ..lineTo(90, 85),
          ],
          expectedSvgPaths: const [
            'M 10 10 L 90 10',
            'M 10 25 L 90 25',
            'M 10 40 L 90 40',
            'M 10 55 L 90 55',
            'M 10 70 L 90 70',
            'M 10 85 L 90 85',
          ],
          expectedStrokeCount: 6,
        );

        expect(result.score, lessThan(65));
        expect(result.passed, isFalse);
        expect(result.failedStrokeIndex, 3);
        expect(result.failureReason, FreeWritingFailureReason.direction);
      },
    );

    test('reports the next missing stroke when stroke count is short', () {
      final result = controller.score(
        userStrokes: [
          Path()
            ..moveTo(10, 10)
            ..lineTo(90, 10),
        ],
        expectedSvgPaths: const ['M 10 10 L 90 10', 'M 10 25 L 90 25'],
        expectedStrokeCount: 2,
      );

      expect(result.passed, isFalse);
      expect(result.failedStrokeIndex, 1);
      expect(result.failureReason, FreeWritingFailureReason.missingStroke);
      expect(result.failureMessage, '2번째 획을 더 써야 해요.');
      expect(result.expectedHintPath, isNotNull);
    });

    test('returns zero when no strokes were drawn', () {
      final result = controller.score(
        userStrokes: const [],
        expectedSvgPaths: const ['M 10 10 L 90 90'],
        expectedStrokeCount: 1,
      );

      expect(result.score, 0);
      expect(result.passed, isFalse);
      expect(result.stars, 0);
    });
  });
}
