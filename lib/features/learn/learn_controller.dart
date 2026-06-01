import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/services/learning_plan_service.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_progress_controller.dart';

final learnLibraryProvider = FutureProvider<LearnLibraryState>((ref) async {
  final grade = ref.watch(currentProfileProvider)?.grade;
  ref.watch(learningProgressTickProvider);

  final learningDate = currentLearningDate();
  final items = await ref
      .watch(contentRepositoryProvider)
      .getHanjaList(grade: grade);
  final progressRecords = await ref
      .watch(learningProgressRepositoryProvider)
      .getCompletedHanjaRecordsForStudent(studentKey: currentStudentKey(ref));
  final plan = const LearningPlanService().buildDailyPlan(
    allItems: items,
    progressRecords: progressRecords,
    learningDate: learningDate,
    newItemLimit: AppConstants.dailyHanjaCount,
    reviewItemLimit: AppConstants.dailyReviewCount,
  );
  final chapters = const LearningPlanService().buildChapters(items);
  final completedHanjaIds = progressRecords
      .map((record) => record.hanjaId)
      .toSet();

  return LearnLibraryState(
    grade: grade,
    items: items,
    todayCompletedIds: plan.todayCompletedIds,
    completedHanjaIds: completedHanjaIds,
    reviewItems: plan.reviewItems,
    chapters: chapters,
    activeChapterKey: plan.chapterKey,
  );
});

enum LearnItemStatus { reviewDue, learned, notLearned }

class LearnLibraryState {
  const LearnLibraryState({
    required this.grade,
    required this.items,
    required this.todayCompletedIds,
    required this.completedHanjaIds,
    required this.reviewItems,
    required this.chapters,
    required this.activeChapterKey,
  });

  final int? grade;
  final List<HanjaCharacter> items;
  final Set<String> todayCompletedIds;
  final Set<String> completedHanjaIds;
  final List<HanjaCharacter> reviewItems;
  final List<HanjaChapter> chapters;
  final String? activeChapterKey;

  List<HanjaCharacter> get learnedItems {
    return items.where((item) => completedHanjaIds.contains(item.id)).toList();
  }

  List<HanjaCharacter> get pendingItems {
    return items.where((item) => !completedHanjaIds.contains(item.id)).toList();
  }

  List<HanjaCharacter> get weakItems {
    return reviewItems;
  }

  HanjaCharacter? get nextItem {
    if (pendingItems.isNotEmpty) {
      return pendingItems.first;
    }
    return items.isEmpty ? null : items.first;
  }

  HanjaCharacter? get primaryItem {
    if (reviewItems.isNotEmpty) {
      return reviewItems.first;
    }
    if (pendingItems.isNotEmpty) {
      return pendingItems.first;
    }
    return learnedItems.isEmpty ? null : learnedItems.first;
  }

  bool get hasReviewDue => reviewItems.isNotEmpty;

  bool get hasPendingItems => pendingItems.isNotEmpty;

  int get completedCount => learnedItems.length;

  int get totalCount => items.length;

  int get weakCount => weakItems.length;

  HanjaChapter? get activeChapter {
    for (final chapter in chapters) {
      if (chapter.key == activeChapterKey) {
        return chapter;
      }
    }
    return chapters.isEmpty ? null : chapters.first;
  }

  HanjaChapter? chapterForItem(HanjaCharacter item) {
    final key = const LearningPlanService().chapterKeyFor(item);
    for (final chapter in chapters) {
      if (chapter.key == key) {
        return chapter;
      }
    }
    return null;
  }

  HanjaChapter? get primaryChapter {
    final item = primaryItem;
    if (item == null) {
      return activeChapter;
    }
    return chapterForItem(item) ?? activeChapter;
  }

  String? get primaryChapterKey => primaryChapter?.key;

  int completedCountInChapter(HanjaChapter chapter) {
    return chapter.items
        .where((item) => completedHanjaIds.contains(item.id))
        .length;
  }

  double get progressRatio {
    if (totalCount == 0) {
      return 0;
    }
    return completedCount / totalCount;
  }

  bool isCompleted(String hanjaId) => completedHanjaIds.contains(hanjaId);

  bool isReviewDue(String hanjaId) {
    return reviewItems.any((item) => item.id == hanjaId);
  }

  LearnItemStatus statusOf(String hanjaId) {
    if (isReviewDue(hanjaId)) {
      return LearnItemStatus.reviewDue;
    }
    if (isCompleted(hanjaId)) {
      return LearnItemStatus.learned;
    }
    return LearnItemStatus.notLearned;
  }
}
