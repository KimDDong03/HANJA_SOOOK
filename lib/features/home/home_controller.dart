import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/learning_progress_record.dart';
import '../../domain/services/learning_plan_service.dart';
import '../../domain/services/thinking_unit_image_service.dart';
import '../auth/current_profile_controller.dart';
import '../growth/growth_controller.dart';
import '../learning/demo_review_focus_seed_controller.dart';
import '../learning/learning_progress_controller.dart';

final todayLearningProvider = FutureProvider<TodayLearningState>((ref) async {
  final grade = ref.watch(currentProfileProvider)?.grade;
  ref.watch(learningProgressTickProvider);

  final contentRepository = ref.watch(contentRepositoryProvider);
  final progressRepository = ref.watch(learningProgressRepositoryProvider);
  final studentKey = currentStudentKey(ref);
  final learningDate = currentLearningDate();
  final allItems = await contentRepository.getHanjaList(grade: grade);
  await ref
      .read(demoReviewFocusSeedControllerProvider)
      .ensureSeeded(items: allItems);
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

final homeUnitCarouselProvider = FutureProvider<HomeUnitCarouselState>((
  ref,
) async {
  final profileGrade = ref.watch(currentProfileProvider)?.grade;
  final grade = profileGrade ?? 3;
  ref.watch(learningProgressTickProvider);

  final contentRepository = ref.watch(contentRepositoryProvider);
  final progressRepository = ref.watch(learningProgressRepositoryProvider);
  final studentKey = currentStudentKey(ref);
  final learningDate = currentLearningDate();
  final allItems = await contentRepository.getHanjaList(grade: grade);
  await ref
      .read(demoReviewFocusSeedControllerProvider)
      .ensureSeeded(items: allItems);
  final progressRecords = await progressRepository
      .getCompletedHanjaRecordsForStudent(studentKey: studentKey);
  final plan = const LearningPlanService().buildDailyPlan(
    allItems: allItems,
    progressRecords: progressRecords,
    learningDate: learningDate,
    newItemLimit: AppConstants.dailyHanjaCount,
    reviewItemLimit: AppConstants.dailyReviewCount,
  );
  final chapters = const LearningPlanService().buildChapters(allItems);

  return HomeUnitCarouselState.fromChapters(
    grade: grade,
    chapters: chapters,
    learningDate: learningDate,
    progressRecords: progressRecords,
    plannedChapterKey: plan.chapterKey,
  );
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
          ? '단원 학습 완료! 누적 XP가 성장 게이지에 반영됐어요.'
          : '단원 학습을 끝내면 XP가 바로 채워지고 다음 보상이 열려요.',
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

class HomeUnitCarouselState {
  const HomeUnitCarouselState({
    required this.grade,
    required this.slides,
    required this.activeSlideIndex,
  });

  factory HomeUnitCarouselState.fromChapters({
    required int grade,
    required List<HanjaChapter> chapters,
    required String learningDate,
    required List<LearningProgressRecord> progressRecords,
    String? plannedChapterKey,
  }) {
    final completedHanjaIds = progressRecords
        .map((record) => record.hanjaId)
        .toSet();
    final activeChapterKey = _activeHomeChapterKey(
      chapters: chapters,
      completedHanjaIds: completedHanjaIds,
      fallbackChapterKey: plannedChapterKey,
    );
    final slides = [
      for (var index = 0; index < chapters.length; index += 1)
        HomeUnitSlide.fromChapter(
          chapter: chapters[index],
          learningDate: learningDate,
          progressRecords: progressRecords,
          completedHanjaIds: completedHanjaIds,
          isUnlocked: _isChapterUnlocked(
            chapters: chapters,
            index: index,
            completedHanjaIds: completedHanjaIds,
          ),
        ),
    ];
    final activeSlideIndex = slides.indexWhere(
      (slide) => slide.chapterKey == activeChapterKey,
    );

    return HomeUnitCarouselState(
      grade: grade,
      slides: slides,
      activeSlideIndex: activeSlideIndex < 0 ? 0 : activeSlideIndex,
    );
  }

  final int grade;
  final List<HomeUnitSlide> slides;
  final int activeSlideIndex;
}

class HomeUnitSlide {
  const HomeUnitSlide({
    required this.chapterKey,
    required this.title,
    required this.imageAssetPath,
    required this.completedCount,
    required this.totalCount,
    required this.newCount,
    required this.reviewCount,
    required this.isUnlocked,
  });

  final String chapterKey;
  final String title;
  final String? imageAssetPath;
  final int completedCount;
  final int totalCount;
  final int newCount;
  final int reviewCount;
  final bool isUnlocked;

  bool get isComplete => totalCount > 0 && completedCount >= totalCount;

  factory HomeUnitSlide.fromChapter({
    required HanjaChapter chapter,
    required String learningDate,
    required List<LearningProgressRecord> progressRecords,
    required Set<String> completedHanjaIds,
    required bool isUnlocked,
  }) {
    final plan = const LearningPlanService().buildDailyPlan(
      allItems: chapter.items,
      progressRecords: progressRecords,
      learningDate: learningDate,
      newItemLimit: AppConstants.dailyHanjaCount,
      reviewItemLimit: AppConstants.dailyReviewCount,
      chapterKey: chapter.key,
    );
    const thinkingImageService = ThinkingUnitImageService();
    return HomeUnitSlide(
      chapterKey: chapter.key,
      title: thinkingImageService.displayTitleForChapterKey(
        chapterKey: chapter.key,
        fallbackName: chapter.name,
      ),
      imageAssetPath: thinkingImageService.imageAssetPathForChapterKey(
        chapter.key,
      ),
      completedCount: chapter.items
          .where((item) => completedHanjaIds.contains(item.id))
          .length,
      totalCount: chapter.items.length,
      newCount: plan.newItems.length,
      reviewCount: plan.reviewItems.length,
      isUnlocked: isUnlocked,
    );
  }
}

bool _isChapterUnlocked({
  required List<HanjaChapter> chapters,
  required int index,
  required Set<String> completedHanjaIds,
}) {
  if (index <= 0) {
    return true;
  }
  for (var previousIndex = 0; previousIndex < index; previousIndex += 1) {
    if (!_isChapterComplete(chapters[previousIndex], completedHanjaIds)) {
      return false;
    }
  }
  return true;
}

bool _isChapterComplete(HanjaChapter chapter, Set<String> completedHanjaIds) {
  return chapter.items.isNotEmpty &&
      chapter.items.every((item) => completedHanjaIds.contains(item.id));
}

String? _activeHomeChapterKey({
  required List<HanjaChapter> chapters,
  required Set<String> completedHanjaIds,
  required String? fallbackChapterKey,
}) {
  for (final chapter in chapters) {
    if (!_isChapterComplete(chapter, completedHanjaIds)) {
      return chapter.key;
    }
  }

  final normalizedFallback = fallbackChapterKey?.trim();
  if (normalizedFallback != null && normalizedFallback.isNotEmpty) {
    for (final chapter in chapters) {
      if (chapter.key == normalizedFallback) {
        return normalizedFallback;
      }
    }
  }

  return chapters.isEmpty ? null : chapters.first.key;
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
