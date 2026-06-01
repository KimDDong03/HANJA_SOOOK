import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/services/learning_plan_service.dart';
import '../auth/current_profile_controller.dart';
import '../growth/growth_controller.dart';
import '../learning/learning_progress_controller.dart';

final todayLearningProvider = FutureProvider<TodayLearningState>((ref) async {
  final grade = ref.watch(currentProfileProvider)?.grade;
  ref.watch(learningProgressTickProvider);

  final contentRepository = ref.watch(contentRepositoryProvider);
  final progressRepository = ref.watch(learningProgressRepositoryProvider);
  final studentKey = currentStudentKey(ref);
  final learningDate = currentLearningDate();
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
  final completedHanjaIds = await progressRepository.getCompletedHanjaIds(
    studentKey: studentKey,
    learningDate: learningDate,
  );
  return TodayLearningState(
    reviewItems: plan.reviewItems,
    newItems: plan.newItems,
    completedHanjaIds: completedHanjaIds,
    chapterKey: plan.chapterKey,
    chapterName: plan.chapterName,
  );
});

final todayHanjaProvider = FutureProvider<HanjaCharacter?>((ref) async {
  final state = await ref.watch(todayLearningProvider.future);
  return state.firstHanja;
});

final homeGrowthSummaryProvider = Provider<AsyncValue<HomeGrowthSummaryState>>((
  ref,
) {
  return ref.watch(growthProvider).whenData(HomeGrowthSummaryState.fromGrowth);
});

final homeGrowthSummaryRetryProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(growthProvider);
    ref.invalidate(homeGrowthSummaryProvider);
  };
});

class HomeGrowthSummaryState {
  const HomeGrowthSummaryState({
    required this.level,
    required this.totalXp,
    required this.levelTitle,
    required this.progress,
    required this.remainingXp,
    required this.completedTodayCount,
    required this.todayTotalCount,
    required this.todayRemainingCount,
    required this.rewardLabel,
    required this.message,
  });

  final int level;
  final int totalXp;
  final String levelTitle;
  final double progress;
  final int remainingXp;
  final int completedTodayCount;
  final int todayTotalCount;
  final int todayRemainingCount;
  final String rewardLabel;
  final String message;

  factory HomeGrowthSummaryState.fromGrowth(GrowthViewState state) {
    return HomeGrowthSummaryState(
      level: state.level,
      totalXp: state.totalXp,
      levelTitle: state.titleForLevel,
      progress: state.levelProgressValue,
      remainingXp: state.remainingXp,
      completedTodayCount: state.completedTodayCount,
      todayTotalCount: state.todayTotalCount,
      todayRemainingCount: state.remainingTodayCount,
      rewardLabel: _rewardLabelForProgress(state.rewardTrackProgress),
      message: state.isTodayComplete
          ? '오늘 미션 완료! 누적 XP가 성장 게이지에 반영됐어요.'
          : '오늘 학습을 끝내면 XP가 바로 채워지고 다음 보상이 열려요.',
    );
  }
}

String _rewardLabelForProgress(int rewardProgress) {
  if (rewardProgress >= 60) {
    return '큰 배지';
  }
  if (rewardProgress >= 30) {
    return '별 배지';
  }
  return '도전중';
}

class TodayLearningState {
  const TodayLearningState({
    required this.reviewItems,
    required this.newItems,
    this.chapterKey,
    this.chapterName,
    this.completedHanjaIds = const <String>{},
  });

  final List<HanjaCharacter> reviewItems;
  final List<HanjaCharacter> newItems;
  final String? chapterKey;
  final String? chapterName;
  final Set<String> completedHanjaIds;

  List<HanjaCharacter> get items => [...reviewItems, ...newItems];

  int get completedCount {
    return items.where((item) => completedHanjaIds.contains(item.id)).length;
  }

  int get totalCount => items.length;

  int get reviewCount => reviewItems.length;

  int get newCount => newItems.length;

  HanjaCharacter? get firstHanja => items.isEmpty ? null : items.first;

  HanjaCharacter? get currentHanja {
    for (final item in items) {
      if (!isCompleted(item.id)) {
        return item;
      }
    }
    return null;
  }

  bool get isComplete => totalCount > 0 && completedCount >= totalCount;

  bool isCompleted(String hanjaId) => completedHanjaIds.contains(hanjaId);

  bool isReviewItem(String hanjaId) {
    return reviewItems.any((item) => item.id == hanjaId);
  }
}
