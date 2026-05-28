import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/services/xp_service.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_progress_controller.dart';

final growthProvider = FutureProvider<GrowthViewState>((ref) async {
  final grade = ref.watch(currentProfileProvider)?.grade;
  final studentKey = currentStudentKey(ref);
  final learningDate = currentLearningDate();
  final progressRepository = ref.watch(learningProgressRepositoryProvider);
  const xpService = XpService();

  final todaySet = await ref
      .watch(contentRepositoryProvider)
      .getTodayHanjaSet(grade: grade, limit: AppConstants.dailyHanjaCount);
  final completedIds = await progressRepository.getCompletedHanjaIds(
    studentKey: studentKey,
    learningDate: learningDate,
  );
  final totalXp = await progressRepository.getTotalXp(studentKey: studentKey);
  final level = xpService.levelForTotalXp(totalXp);

  return GrowthViewState(
    level: level,
    totalXp: totalXp,
    currentLevelRequiredXp: xpService.currentLevelRequiredXp(level),
    nextLevelRequiredXp: xpService.nextLevelRequiredXp(level),
    completedTodayCount: todaySet.where((hanja) {
      return completedIds.contains(hanja.id);
    }).length,
    todayTotalCount: todaySet.length,
  );
});

class GrowthViewState {
  const GrowthViewState({
    required this.level,
    required this.totalXp,
    required this.currentLevelRequiredXp,
    required this.nextLevelRequiredXp,
    required this.completedTodayCount,
    required this.todayTotalCount,
  });

  final int level;
  final int totalXp;
  final int currentLevelRequiredXp;
  final int nextLevelRequiredXp;
  final int completedTodayCount;
  final int todayTotalCount;
}
