class XpService {
  const XpService();

  static const writingCompletionSource = 'writing_completion';
  static const dailyCompletionSource = 'daily_completion_bonus';
  static const challengeResultSource = 'challenge_result';
  static const reviewSessionSource = 'review_session_completion';
  static const weaknessSessionSource = 'weakness_session_completion';

  static const _levelRequiredXp = <int, int>{
    1: 0,
    2: 100,
    3: 250,
    4: 450,
    5: 700,
    6: 1000,
    7: 1350,
    8: 1750,
    9: 2200,
    10: 2700,
    11: 3250,
    12: 3850,
    13: 4500,
    14: 5200,
    15: 5950,
    16: 6750,
    17: 7600,
    18: 8500,
    19: 9450,
    20: 10450,
  };

  int writingCompletionXp() => 15;

  int dailyCompletionBonusXp() => 30;

  int quizCorrectXp() => 5;

  int quizCompletionXp() => 20;

  int gameCorrectXp() => 5;

  int gameCompletionXp() => 20;

  int quizResultXp({required int correctCount, required int totalCount}) {
    if (totalCount <= 0) {
      return 0;
    }
    return correctCount * quizCorrectXp() + quizCompletionXp();
  }

  int gameResultXp({required int correctCount, required int totalCount}) {
    if (totalCount <= 0) {
      return 0;
    }
    return correctCount * gameCorrectXp() + gameCompletionXp();
  }

  int reviewSessionCompletionXp({
    required int reviewedCount,
    required int firstTryCorrectCount,
  }) {
    if (reviewedCount <= 0) {
      return 0;
    }
    final safeCorrectCount = firstTryCorrectCount
        .clamp(0, reviewedCount)
        .toInt();
    return quizCompletionXp() + safeCorrectCount * quizCorrectXp();
  }

  int weaknessSessionCompletionXp({required int completedHanjaCount}) {
    if (completedHanjaCount <= 0) {
      return 0;
    }
    return gameCompletionXp() + completedHanjaCount * gameCorrectXp();
  }

  String reviewSessionXpEventId({
    required String studentKey,
    required String learningDate,
    required String? focusHanjaId,
  }) {
    return '$studentKey-$learningDate-review-${_sessionScope(focusHanjaId)}';
  }

  String weaknessSessionXpEventId({
    required String studentKey,
    required String learningDate,
    required String? focusHanjaId,
  }) {
    return '$studentKey-$learningDate-weakness-${_sessionScope(focusHanjaId)}';
  }

  int levelForTotalXp(int totalXp) {
    var level = 1;
    for (final entry in _levelRequiredXp.entries) {
      if (totalXp >= entry.value) {
        level = entry.key;
      }
    }
    return level;
  }

  int currentLevelRequiredXp(int level) {
    return _levelRequiredXp[level] ?? _levelRequiredXp.values.last;
  }

  int nextLevelRequiredXp(int level) {
    return _levelRequiredXp[level + 1] ?? _levelRequiredXp.values.last;
  }

  String _sessionScope(String? focusHanjaId) {
    final focus = focusHanjaId?.trim();
    if (focus == null || focus.isEmpty) {
      return 'daily';
    }
    return 'focus-$focus';
  }
}
