import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/domain/models/challenge_result.dart';
import 'package:hanja_soook/domain/models/class_ranking.dart';
import 'package:hanja_soook/domain/services/challenge_result_service.dart';

void main() {
  test(
    'ChallengeResultService calculates quiz and game XP from product rules',
    () {
      const service = ChallengeResultService();

      final quizXp = service.earnedXpFor(
        const ChallengeResultInput(
          mode: ChallengeMode.quizMixed,
          score: 3,
          correctCount: 3,
          totalCount: 5,
          timeSec: 40,
        ),
      );
      final gameXp = service.earnedXpFor(
        const ChallengeResultInput(
          mode: ChallengeMode.flipBoard,
          score: 7,
          correctCount: 4,
          totalCount: 9,
          timeSec: 60,
          flippedTileCount: 4,
        ),
      );

      expect(quizXp, 35);
      expect(gameXp, 40);
    },
  );

  test('ClassRankingService ranks records by selected metric', () {
    const service = ClassRankingService();
    final rowsByMetric = service.buildRowsByMetric(
      currentStudentKey: 'me',
      records: const [
        ClassRankingRecord(
          studentKey: 'me',
          displayName: '나',
          totalXp: 70,
          todayChallengeScore: 3,
          flipBoardTiles: 4,
        ),
        ClassRankingRecord(
          studentKey: 'friend',
          displayName: '친구1',
          totalXp: 90,
          todayChallengeScore: 6,
          flipBoardTiles: 2,
        ),
      ],
    );

    expect(rowsByMetric[ClassRankingMetric.xp]!.first.studentKey, 'friend');
    expect(rowsByMetric[ClassRankingMetric.flipBoard]!.first.studentKey, 'me');
    expect(rowsByMetric[ClassRankingMetric.flipBoard]!.first.scoreText, '4판');
  });
}
