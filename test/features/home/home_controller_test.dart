import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/domain/models/hanja_character.dart';
import 'package:hanja_soook/domain/services/learning_plan_service.dart';
import 'package:hanja_soook/domain/services/thinking_unit_image_service.dart';
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

  test('HomeUnitSlide maps chapter keys to thinking image assets', () {
    const chapter = HanjaChapter(
      key: 'G5-U08-L04',
      name: '초5 8단원 4. 조선 시대 역사 인물4',
      items: [
        HanjaCharacter(
          id: 'HJ-1',
          character: '一',
          sound: '일',
          meaning: '한 일',
          grade: 5,
        ),
        HanjaCharacter(
          id: 'HJ-2',
          character: '二',
          sound: '이',
          meaning: '두 이',
          grade: 5,
        ),
      ],
    );

    final slide = HomeUnitSlide.fromChapter(
      chapter: chapter,
      learningDate: '20260602',
      progressRecords: const [],
      completedHanjaIds: const {'HJ-1'},
      isUnlocked: true,
    );

    expect(slide.chapterKey, 'G5-U08-L04');
    expect(
      slide.imageAssetPath,
      'assets/images/thinking_units/g5/g5_u08_l04.png',
    );
    expect(slide.completedCount, 1);
    expect(slide.totalCount, 2);
    expect(slide.newCount, 2);
    expect(slide.reviewCount, 0);
    expect(slide.isUnlocked, isTrue);
    expect(slide.isComplete, isFalse);
    expect(
      const ThinkingUnitImageService().imageAssetPathForChapterKey('3-1'),
      isNull,
    );
  });

  test('ThinkingUnitImageService maps chapter keys to major unit keys', () {
    const service = ThinkingUnitImageService();

    expect(service.majorUnitKeyForChapterKey('G3-U01-L04'), 'G3-U01');
    expect(
      service.imageAssetPathForChapterKey('G3-U01-L04'),
      'assets/images/thinking_units/g3/g3_u01_l04.png',
    );
    expect(service.majorUnitKeyForChapterKey('bad-key'), isNull);
  });
}
