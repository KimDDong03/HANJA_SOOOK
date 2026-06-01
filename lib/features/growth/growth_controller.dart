import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/services/learning_plan_service.dart';
import '../../domain/services/xp_service.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_progress_controller.dart';

final growthProvider = FutureProvider<GrowthViewState>((ref) async {
  ref.watch(learningProgressTickProvider);

  final grade = ref.watch(currentProfileProvider)?.grade;
  final studentKey = currentStudentKey(ref);
  final learningDate = currentLearningDate();
  final progressRepository = ref.watch(learningProgressRepositoryProvider);
  const xpService = XpService();

  final contentRepository = ref.watch(contentRepositoryProvider);
  final allItems = await contentRepository.getHanjaList(grade: grade);
  final progressRecords = await progressRepository
      .getCompletedHanjaRecordsForStudent(studentKey: studentKey);
  final plan = const LearningPlanService().buildDailyPlan(
    allItems: allItems,
    progressRecords: progressRecords,
    learningDate: learningDate,
    newItemLimit: AppConstants.dailyHanjaCount,
    reviewItemLimit: AppConstants.dailyReviewCount,
  );
  final completedIds = await progressRepository.getCompletedHanjaIds(
    studentKey: studentKey,
    learningDate: learningDate,
  );
  final totalXp = await progressRepository.getTotalXp(studentKey: studentKey);
  final level = xpService.levelForTotalXp(totalXp);

  final levelSpan =
      xpService.nextLevelRequiredXp(level) -
      xpService.currentLevelRequiredXp(level);
  final levelProgress = totalXp - xpService.currentLevelRequiredXp(level);
  final todayTotalCount = plan.items.length;
  final completedTodayCount = plan.items.where((hanja) {
    return completedIds.contains(hanja.id);
  }).length;

  return GrowthViewState(
    level: level,
    totalXp: totalXp,
    currentLevelRequiredXp: xpService.currentLevelRequiredXp(level),
    nextLevelRequiredXp: xpService.nextLevelRequiredXp(level),
    remainingXp: (xpService.nextLevelRequiredXp(level) - totalXp).clamp(
      0,
      xpService.nextLevelRequiredXp(level),
    ),
    levelProgressValue: levelSpan <= 0 ? 0.0 : levelProgress / levelSpan,
    completedTodayCount: completedTodayCount,
    todayTotalCount: todayTotalCount,
    todayProgressValue: todayTotalCount <= 0
        ? 0.0
        : completedTodayCount / todayTotalCount,
    remainingTodayCount: (todayTotalCount - completedTodayCount).clamp(
      0,
      todayTotalCount,
    ),
    rewardTrackProgress: totalXp % 100,
  );
});

class GrowthViewState {
  const GrowthViewState({
    required this.level,
    required this.totalXp,
    required this.currentLevelRequiredXp,
    required this.nextLevelRequiredXp,
    required this.remainingXp,
    required this.levelProgressValue,
    required this.completedTodayCount,
    required this.todayTotalCount,
    required this.todayProgressValue,
    required this.remainingTodayCount,
    required this.rewardTrackProgress,
  });

  final int level;
  final int totalXp;
  final int currentLevelRequiredXp;
  final int nextLevelRequiredXp;
  final int remainingXp;
  final double levelProgressValue;
  final int completedTodayCount;
  final int todayTotalCount;
  final double todayProgressValue;
  final int remainingTodayCount;
  final int rewardTrackProgress;

  bool get isTodayComplete =>
      todayTotalCount > 0 && completedTodayCount >= todayTotalCount;

  String get titleForLevel {
    if (level >= 10) {
      return '한자 마스터';
    }
    if (level >= 7) {
      return '실력 쑥쑥 탐험가';
    }
    if (level >= 4) {
      return '별 모으는 학습가';
    }
    return '새싹 한자 탐험가';
  }

  String get motivationMessage {
    return isTodayComplete
        ? '오늘 목표 완료! 내일도 XP를 모아 새 칭호에 도전해요.'
        : '오늘 한자를 마치면 XP와 레벨 게이지가 바로 채워져요.';
  }

  String get rewardTrackMessage {
    if (rewardTrackProgress >= 99) {
      return '이번 보상 트랙을 모두 채웠어요.';
    }
    final nextReward = rewardTrackProgress < 30
        ? 30
        : rewardTrackProgress < 60
        ? 60
        : 100;
    return '다음 보상까지 ${nextReward - rewardTrackProgress} XP';
  }

  bool isRewardUnlocked(int requiredXp) {
    return rewardTrackProgress >= requiredXp;
  }
}
