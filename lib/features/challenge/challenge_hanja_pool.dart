import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_progress_controller.dart';

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

  if (maxCount == null || learnedItems.length <= maxCount) {
    return learnedItems;
  }

  final seed = int.tryParse(currentLearningDate()) ?? learnedItems.length;
  return ([
    ...learnedItems,
  ]..shuffle(Random(seed + seedOffset))).take(maxCount).toList();
}
