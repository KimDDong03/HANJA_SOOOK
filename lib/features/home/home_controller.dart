import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_progress_controller.dart';

final todayLearningProvider = FutureProvider<TodayLearningState>((ref) async {
  final grade = ref.watch(currentProfileProvider)?.grade;
  ref.watch(learningProgressTickProvider);

  final items = await ref
      .watch(contentRepositoryProvider)
      .getTodayHanjaSet(grade: grade, limit: AppConstants.dailyHanjaCount);
  final completedHanjaIds = await ref
      .watch(learningProgressRepositoryProvider)
      .getCompletedHanjaIds(
        studentKey: currentStudentKey(ref),
        learningDate: currentLearningDate(),
      );
  return TodayLearningState(items: items, completedHanjaIds: completedHanjaIds);
});

final todayHanjaProvider = FutureProvider<HanjaCharacter?>((ref) async {
  final state = await ref.watch(todayLearningProvider.future);
  return state.firstHanja;
});

class TodayLearningState {
  const TodayLearningState({
    required this.items,
    this.completedHanjaIds = const <String>{},
  });

  final List<HanjaCharacter> items;
  final Set<String> completedHanjaIds;

  int get completedCount {
    return items.where((item) => completedHanjaIds.contains(item.id)).length;
  }

  int get totalCount => items.length;

  HanjaCharacter? get firstHanja => items.isEmpty ? null : items.first;

  bool isCompleted(String hanjaId) => completedHanjaIds.contains(hanjaId);
}
