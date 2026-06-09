import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/core/constants/app_constants.dart';
import 'package:hanja_soook/domain/services/xp_service.dart';

void main() {
  group('XpService', () {
    const service = XpService();

    test('matches product and seed XP rules', () {
      expect(service.writingCompletionXp(), 15);
      expect(service.dailyCompletionBonusXp(), 30);
      expect(service.quizCorrectXp(), 5);
      expect(service.quizCompletionXp(), 20);
      expect(service.gameCorrectXp(), 5);
      expect(service.gameCompletionXp(), 20);
      expect(
        service.reviewSessionCompletionXp(
          reviewedCount: 4,
          firstTryCorrectCount: 3,
        ),
        35,
      );
      expect(service.weaknessSessionCompletionXp(completedHanjaCount: 2), 30);
    });

    test('uses level thresholds from product spec and migration seed', () {
      expect(service.levelForTotalXp(0), 1);
      expect(service.levelForTotalXp(99), 1);
      expect(service.levelForTotalXp(100), 2);
      expect(service.levelForTotalXp(249), 2);
      expect(service.levelForTotalXp(250), 3);
      expect(service.levelForTotalXp(2700), 10);
      expect(service.levelForTotalXp(10450), 20);

      expect(service.currentLevelRequiredXp(5), 700);
      expect(service.nextLevelRequiredXp(5), 1000);
      expect(service.nextLevelRequiredXp(20), 10450);
    });

    test('matches product data count settings', () {
      expect(AppConstants.dailyHanjaCount, 5);
      expect(AppConstants.challengeMinLearnedHanjaCount, 4);
      expect(AppConstants.challengeQuestionCount, 10);
      expect(AppConstants.flipBoardTimeLimitSeconds, 30);
      expect(AppConstants.flipBoardTimeLimitOptionsSeconds, [30, 60]);
    });
  });
}
