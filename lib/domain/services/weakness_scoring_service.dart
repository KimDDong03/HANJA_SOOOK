import '../models/learning_diagnostics.dart';

class WeaknessScoringService {
  const WeaknessScoringService();

  static const activationScore = 4;
  static const maxScore = 10;
  static const slowAnswerThresholdMs = 12000;
  static const resolvedSuccessStreak = 2;

  WeaknessScoringResult score(
    WeaknessScoringInput input, {
    HanjaWeaknessRecord? current,
  }) {
    if (!input.isLearned) {
      return WeaknessScoringResult(
        weaknessType: input.weaknessType,
        scoreDelta: 0,
        nextScore: current?.score ?? 0,
        nextStatus: current?.status ?? HanjaWeaknessStatus.watching,
        nextSuccessStreak: current?.successStreak ?? 0,
        shouldUpdateWeakness: false,
      );
    }

    final weaknessType = input.weaknessType ?? typeFor(input);
    final scoreDelta = _scoreDeltaFor(input);
    final previousScore = current?.score ?? 0;
    final nextScore = (previousScore + scoreDelta).clamp(0, maxScore).toInt();
    final previousSuccessStreak = current?.successStreak ?? 0;
    final nextSuccessStreak =
        input.source == HanjaPracticeSource.weaknessSession &&
            input.result == HanjaPracticeResult.passed
        ? previousSuccessStreak + 1
        : scoreDelta > 0
        ? 0
        : previousSuccessStreak;
    final nextStatus = _statusFor(
      nextScore: nextScore,
      successStreak: nextSuccessStreak,
      currentStatus: current?.status,
    );

    return WeaknessScoringResult(
      weaknessType: weaknessType,
      scoreDelta: scoreDelta,
      nextScore: nextScore,
      nextStatus: nextStatus,
      nextSuccessStreak: nextSuccessStreak,
      shouldUpdateWeakness:
          current != null || scoreDelta > 0 || nextScore >= activationScore,
    );
  }

  HanjaWeaknessType typeFor(WeaknessScoringInput input) {
    if (input.activityType == HanjaPracticeActivityType.writing ||
        input.result == HanjaPracticeResult.hinted) {
      return HanjaWeaknessType.writing;
    }
    if (input.confusedWithHanjaId != null) {
      return HanjaWeaknessType.shapeConfusion;
    }
    if (input.source == HanjaPracticeSource.reviewSession &&
        (input.result == HanjaPracticeResult.incorrect ||
            input.result == HanjaPracticeResult.failed)) {
      return HanjaWeaknessType.retention;
    }
    return switch (input.activityType) {
      HanjaPracticeActivityType.hanjaToHun => HanjaWeaknessType.hunMeaning,
      HanjaPracticeActivityType.hunToHanja =>
        HanjaWeaknessType.hanjaRecognition,
      HanjaPracticeActivityType.writing => HanjaWeaknessType.writing,
      HanjaPracticeActivityType.hint => HanjaWeaknessType.writing,
      HanjaPracticeActivityType.weaknessPass => HanjaWeaknessType.retention,
      HanjaPracticeActivityType.mixed => HanjaWeaknessType.retention,
    };
  }

  int _scoreDeltaFor(WeaknessScoringInput input) {
    if (input.source == HanjaPracticeSource.weaknessSession &&
        input.result == HanjaPracticeResult.passed) {
      return -3;
    }
    if (input.result == HanjaPracticeResult.hinted) {
      return 1;
    }
    if (input.activityType == HanjaPracticeActivityType.writing &&
        input.result == HanjaPracticeResult.failed) {
      return 3;
    }
    if (input.result == HanjaPracticeResult.incorrect ||
        input.result == HanjaPracticeResult.failed) {
      return 2;
    }
    if (input.result == HanjaPracticeResult.correct &&
        (input.elapsedMs ?? 0) >= slowAnswerThresholdMs) {
      return 1;
    }
    if (input.result == HanjaPracticeResult.correct) {
      return -2;
    }
    return 0;
  }

  HanjaWeaknessStatus _statusFor({
    required int nextScore,
    required int successStreak,
    required HanjaWeaknessStatus? currentStatus,
  }) {
    if (nextScore <= 0 || successStreak >= resolvedSuccessStreak) {
      return HanjaWeaknessStatus.resolved;
    }
    if (nextScore >= activationScore) {
      return HanjaWeaknessStatus.active;
    }
    if (currentStatus == HanjaWeaknessStatus.active) {
      return HanjaWeaknessStatus.active;
    }
    return HanjaWeaknessStatus.watching;
  }
}

class WeaknessScoringInput {
  const WeaknessScoringInput({
    required this.source,
    required this.activityType,
    required this.result,
    required this.isLearned,
    this.weaknessType,
    this.hintLevel,
    this.elapsedMs,
    this.confusedWithHanjaId,
  });

  final HanjaPracticeSource source;
  final HanjaPracticeActivityType activityType;
  final HanjaPracticeResult result;
  final bool isLearned;
  final HanjaWeaknessType? weaknessType;
  final int? hintLevel;
  final int? elapsedMs;
  final String? confusedWithHanjaId;
}

class WeaknessScoringResult {
  const WeaknessScoringResult({
    required this.weaknessType,
    required this.scoreDelta,
    required this.nextScore,
    required this.nextStatus,
    required this.nextSuccessStreak,
    required this.shouldUpdateWeakness,
  });

  final HanjaWeaknessType? weaknessType;
  final int scoreDelta;
  final int nextScore;
  final HanjaWeaknessStatus nextStatus;
  final int nextSuccessStreak;
  final bool shouldUpdateWeakness;
}
