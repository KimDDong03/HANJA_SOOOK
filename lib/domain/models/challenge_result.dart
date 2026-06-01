enum ChallengeMode {
  quizHanjaToHun('quiz_hanja_to_hun'),
  quizHunToHanja('quiz_hun_to_hanja'),
  quizMixed('quiz_mixed'),
  speedChoice('speed_choice'),
  flipBoard('flip_board');

  const ChallengeMode(this.storageValue);

  final String storageValue;

  static ChallengeMode fromStorageValue(String value) {
    return switch (value) {
      'quiz_hanja_to_hun' => ChallengeMode.quizHanjaToHun,
      'quiz_hun_to_hanja' => ChallengeMode.quizHunToHanja,
      'quiz_mixed' => ChallengeMode.quizMixed,
      'speed_choice' => ChallengeMode.speedChoice,
      'flip_board' => ChallengeMode.flipBoard,
      _ => ChallengeMode.speedChoice,
    };
  }

  bool get isQuiz {
    return switch (this) {
      ChallengeMode.quizHanjaToHun ||
      ChallengeMode.quizHunToHanja ||
      ChallengeMode.quizMixed => true,
      ChallengeMode.speedChoice || ChallengeMode.flipBoard => false,
    };
  }
}

class ChallengeResultInput {
  const ChallengeResultInput({
    required this.mode,
    required this.score,
    required this.correctCount,
    required this.totalCount,
    required this.timeSec,
    this.flippedTileCount = 0,
  });

  final ChallengeMode mode;
  final int score;
  final int correctCount;
  final int totalCount;
  final int timeSec;
  final int flippedTileCount;
}

class ChallengeResult {
  const ChallengeResult({
    required this.id,
    required this.studentKey,
    required this.learningDate,
    required this.mode,
    required this.score,
    required this.correctCount,
    required this.totalCount,
    required this.timeSec,
    required this.flippedTileCount,
    required this.earnedXp,
    required this.completedAt,
  });

  final String id;
  final String studentKey;
  final String learningDate;
  final ChallengeMode mode;
  final int score;
  final int correctCount;
  final int totalCount;
  final int timeSec;
  final int flippedTileCount;
  final int earnedXp;
  final DateTime completedAt;
}
