import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/features/growth/growth_controller.dart';
import 'package:hanja_soook/features/home/home_controller.dart';

void main() {
  test('HomeGrowthSummaryState precomputes display values for the home UI', () {
    final state = HomeGrowthSummaryState.fromGrowth(
      const GrowthViewState(
        level: 3,
        totalXp: 310,
        currentLevelRequiredXp: 250,
        nextLevelRequiredXp: 450,
        remainingXp: 140,
        levelProgressValue: 0.3,
        completedTodayCount: 2,
        todayTotalCount: 4,
        todayProgressValue: 0.5,
        remainingTodayCount: 2,
        rewardTrackProgress: 10,
      ),
    );

    expect(state.level, 3);
    expect(state.levelTitle, '새싹 한자 탐험가');
    expect(state.progress, 0.3);
    expect(state.remainingXp, 140);
    expect(state.todayRemainingCount, 2);
    expect(state.rewardLabel, '도전중');
    expect(state.message, '오늘 학습을 끝내면 XP가 바로 채워지고 다음 보상이 열려요.');
  });

  test('HomeGrowthSummaryState reports completion message', () {
    final state = HomeGrowthSummaryState.fromGrowth(
      const GrowthViewState(
        level: 4,
        totalXp: 480,
        currentLevelRequiredXp: 450,
        nextLevelRequiredXp: 700,
        remainingXp: 220,
        levelProgressValue: 0.12,
        completedTodayCount: 4,
        todayTotalCount: 4,
        todayProgressValue: 1,
        remainingTodayCount: 0,
        rewardTrackProgress: 80,
      ),
    );

    expect(state.levelTitle, '별 모으는 학습가');
    expect(state.todayRemainingCount, 0);
    expect(state.rewardLabel, '큰 배지');
    expect(state.message, '오늘 미션 완료! 누적 XP가 성장 게이지에 반영됐어요.');
  });
}
