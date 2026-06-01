import '../models/challenge_result.dart';
import '../models/class_ranking.dart';
import 'xp_service.dart';

class ChallengeResultService {
  const ChallengeResultService({this.xpService = const XpService()});

  final XpService xpService;

  int earnedXpFor(ChallengeResultInput input) {
    if (input.mode.isQuiz) {
      return xpService.quizResultXp(
        correctCount: input.correctCount,
        totalCount: input.totalCount,
      );
    }
    return xpService.gameResultXp(
      correctCount: input.mode == ChallengeMode.flipBoard
          ? input.flippedTileCount
          : input.correctCount,
      totalCount: input.totalCount,
    );
  }

  String xpEventId({
    required String studentKey,
    required String learningDate,
    required String resultId,
  }) {
    return '$studentKey-$learningDate-challenge-$resultId';
  }
}

class ClassRankingService {
  const ClassRankingService();

  Map<ClassRankingMetric, List<ClassRankingRow>> buildRowsByMetric({
    required List<ClassRankingRecord> records,
    required String currentStudentKey,
  }) {
    return {
      ClassRankingMetric.xp: _rank(
        records: records,
        currentStudentKey: currentStudentKey,
        valueFor: (record) => record.totalXp,
        scoreTextFor: (record) => '${record.totalXp} XP',
      ),
      ClassRankingMetric.today: _rank(
        records: records,
        currentStudentKey: currentStudentKey,
        valueFor: (record) => record.todayChallengeScore,
        scoreTextFor: (record) => '${record.todayChallengeScore}점',
      ),
      ClassRankingMetric.flipBoard: _rank(
        records: records,
        currentStudentKey: currentStudentKey,
        valueFor: (record) => record.flipBoardTiles,
        scoreTextFor: (record) => '${record.flipBoardTiles}판',
      ),
    };
  }

  List<ClassRankingRow> _rank({
    required List<ClassRankingRecord> records,
    required String currentStudentKey,
    required int Function(ClassRankingRecord record) valueFor,
    required String Function(ClassRankingRecord record) scoreTextFor,
  }) {
    final sorted = [...records]
      ..sort((a, b) {
        final scoreCompare = valueFor(b).compareTo(valueFor(a));
        if (scoreCompare != 0) {
          return scoreCompare;
        }
        return a.displayName.compareTo(b.displayName);
      });

    return [
      for (var index = 0; index < sorted.length; index += 1)
        ClassRankingRow(
          rank: index + 1,
          studentKey: sorted[index].studentKey,
          displayName: sorted[index].displayName,
          scoreText: scoreTextFor(sorted[index]),
          isMe: sorted[index].studentKey == currentStudentKey,
        ),
    ];
  }
}
