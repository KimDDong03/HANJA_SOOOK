enum ClassRankingMetric {
  xp('XP'),
  today('오늘'),
  flipBoard('판뒤집기');

  const ClassRankingMetric(this.label);

  final String label;
}

class ClassRankingRecord {
  const ClassRankingRecord({
    required this.studentKey,
    required this.displayName,
    required this.totalXp,
    required this.todayChallengeScore,
    required this.flipBoardTiles,
  });

  final String studentKey;
  final String displayName;
  final int totalXp;
  final int todayChallengeScore;
  final int flipBoardTiles;
}

class ClassRankingRow {
  const ClassRankingRow({
    required this.rank,
    required this.studentKey,
    required this.displayName,
    required this.scoreText,
    required this.isMe,
  });

  final int rank;
  final String studentKey;
  final String displayName;
  final String scoreText;
  final bool isMe;
}
