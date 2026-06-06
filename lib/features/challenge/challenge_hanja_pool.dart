import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_progress_controller.dart';

final challengeHanjaPoolSeedProvider = Provider.autoDispose<int?>(
  (_) => DateTime.now().microsecondsSinceEpoch,
);

Future<List<HanjaCharacter>> loadLearnedChallengeHanjaPool({
  required Ref ref,
  int seedOffset = 0,
  int? maxCount = AppConstants.challengeQuestionCount,
}) async {
  final grade = ref.watch(currentProfileProvider)?.grade;
  final studentKey = currentStudentKey(ref);
  final contentRepository = ref.watch(contentRepositoryProvider);
  final progressRepository = ref.watch(learningProgressRepositoryProvider);
  final allItems = await contentRepository.getHanjaList(grade: grade);
  final completedIds = await progressRepository.getCompletedHanjaIdsForStudent(
    studentKey: studentKey,
  );
  final learnedItems = [
    for (final item in allItems)
      if (item.isActive && completedIds.contains(item.id)) item,
  ];

  if (learnedItems.length <= 1) {
    return learnedItems;
  }

  final seed = ref.watch(challengeHanjaPoolSeedProvider);
  if (seed == null) {
    return maxCount == null
        ? learnedItems
        : learnedItems.take(maxCount).toList();
  }
  final randomizedItems = [...learnedItems]..shuffle(Random(seed + seedOffset));
  if (maxCount == null) {
    return randomizedItems;
  }
  return randomizedItems.take(maxCount).toList();
}
