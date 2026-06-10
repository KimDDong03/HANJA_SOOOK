import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/domain/models/learning_diagnostics.dart';
import 'package:hanja_soook/domain/services/weakness_scoring_service.dart';

void main() {
  const service = WeaknessScoringService();

  test('scores daily session mistakes toward focus practice', () {
    final result = service.score(
      const WeaknessScoringInput(
        source: HanjaPracticeSource.dailySession,
        activityType: HanjaPracticeActivityType.hanjaToHun,
        result: HanjaPracticeResult.incorrect,
        isLearned: true,
      ),
    );

    expect(result.scoreDelta, 2);
    expect(result.shouldUpdateWeakness, isTrue);
    expect(result.nextStatus, HanjaWeaknessStatus.watching);
  });

  test('does not create weakness rows for neutral correct answers', () {
    final result = service.score(
      const WeaknessScoringInput(
        source: HanjaPracticeSource.dailySession,
        activityType: HanjaPracticeActivityType.hanjaToHun,
        result: HanjaPracticeResult.correct,
        isLearned: true,
      ),
    );

    expect(result.scoreDelta, -2);
    expect(result.nextScore, 0);
    expect(result.shouldUpdateWeakness, isFalse);
    expect(result.nextStatus, HanjaWeaknessStatus.resolved);
  });

  test('activates a learned hanja weakness after repeated quiz mistakes', () {
    final first = service.score(
      const WeaknessScoringInput(
        source: HanjaPracticeSource.quiz,
        activityType: HanjaPracticeActivityType.hunToHanja,
        result: HanjaPracticeResult.incorrect,
        isLearned: true,
      ),
    );
    final second = service.score(
      const WeaknessScoringInput(
        source: HanjaPracticeSource.quiz,
        activityType: HanjaPracticeActivityType.hunToHanja,
        result: HanjaPracticeResult.incorrect,
        isLearned: true,
      ),
      current: _weakness(score: first.nextScore),
    );

    expect(first.nextScore, 2);
    expect(first.nextStatus, HanjaWeaknessStatus.watching);
    expect(second.nextScore, 4);
    expect(second.nextStatus, HanjaWeaknessStatus.active);
  });

  test('writing failure scores higher than a choice mistake', () {
    final writing = service.score(
      const WeaknessScoringInput(
        source: HanjaPracticeSource.reviewSession,
        activityType: HanjaPracticeActivityType.writing,
        result: HanjaPracticeResult.failed,
        isLearned: true,
      ),
    );
    final choice = service.score(
      const WeaknessScoringInput(
        source: HanjaPracticeSource.reviewSession,
        activityType: HanjaPracticeActivityType.hanjaToHun,
        result: HanjaPracticeResult.incorrect,
        isLearned: true,
      ),
    );

    expect(writing.scoreDelta, 3);
    expect(choice.scoreDelta, 2);
  });

  test('two weakness passes resolve the weakness', () {
    final result = service.score(
      const WeaknessScoringInput(
        source: HanjaPracticeSource.weaknessSession,
        activityType: HanjaPracticeActivityType.weaknessPass,
        result: HanjaPracticeResult.passed,
        isLearned: true,
        weaknessType: HanjaWeaknessType.retention,
      ),
      current: _weakness(
        score: 5,
        status: HanjaWeaknessStatus.active,
        successStreak: 1,
      ),
    );

    expect(result.scoreDelta, -3);
    expect(result.nextSuccessStreak, 2);
    expect(result.nextStatus, HanjaWeaknessStatus.resolved);
  });

  test('score is capped between zero and ten', () {
    final high = service.score(
      const WeaknessScoringInput(
        source: HanjaPracticeSource.quiz,
        activityType: HanjaPracticeActivityType.hanjaToHun,
        result: HanjaPracticeResult.incorrect,
        isLearned: true,
      ),
      current: _weakness(score: 10, status: HanjaWeaknessStatus.active),
    );
    final low = service.score(
      const WeaknessScoringInput(
        source: HanjaPracticeSource.weaknessSession,
        activityType: HanjaPracticeActivityType.weaknessPass,
        result: HanjaPracticeResult.passed,
        isLearned: true,
      ),
      current: _weakness(score: 1, status: HanjaWeaknessStatus.active),
    );

    expect(high.nextScore, 10);
    expect(low.nextScore, 0);
  });
}

HanjaWeaknessRecord _weakness({
  required int score,
  HanjaWeaknessStatus status = HanjaWeaknessStatus.watching,
  int successStreak = 0,
}) {
  final now = DateTime(2026, 6, 3);
  return HanjaWeaknessRecord(
    studentKey: 'student-1',
    hanjaId: 'HJ-1',
    weaknessType: HanjaWeaknessType.retention,
    score: score,
    status: status,
    mistakeCount: 1,
    successStreak: successStreak,
    lastEventAt: now,
    createdAt: now,
    updatedAt: now,
  );
}
