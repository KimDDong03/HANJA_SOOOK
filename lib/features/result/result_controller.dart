import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_progress_controller.dart';

final resultProvider = FutureProvider.family<ResultState, ResultArgs>((
  ref,
  args,
) async {
  final grade = ref.watch(currentProfileProvider)?.grade;
  final contentRepository = ref.watch(contentRepositoryProvider);
  final progressRepository = ref.watch(learningProgressRepositoryProvider);
  final studentKey = currentStudentKey(ref);
  final learningDate = currentLearningDate();

  final todaySet = await contentRepository.getTodayHanjaSet(
    grade: grade,
    limit: AppConstants.dailyHanjaCount,
  );
  final completedIds = await progressRepository.getCompletedHanjaIds(
    studentKey: studentKey,
    learningDate: learningDate,
  );

  HanjaCharacter? completedHanja;
  if (args.hanjaId != null) {
    completedHanja = await contentRepository.getHanjaById(args.hanjaId!);
  }

  HanjaCharacter? nextHanja;
  for (final hanja in todaySet) {
    if (!completedIds.contains(hanja.id)) {
      nextHanja = hanja;
      break;
    }
  }
  final completedCount = todaySet.where((hanja) {
    return completedIds.contains(hanja.id);
  }).length;

  return ResultState(
    completedHanja: completedHanja,
    nextHanja: nextHanja,
    earnedXp: args.earnedXp ?? 0,
    completedCount: args.completedCount ?? completedCount,
    totalCount: args.totalCount ?? todaySet.length,
  );
});

class ResultArgs {
  const ResultArgs({
    required this.hanjaId,
    required this.earnedXp,
    required this.completedCount,
    required this.totalCount,
  });

  final String? hanjaId;
  final int? earnedXp;
  final int? completedCount;
  final int? totalCount;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ResultArgs &&
            other.hanjaId == hanjaId &&
            other.earnedXp == earnedXp &&
            other.completedCount == completedCount &&
            other.totalCount == totalCount;
  }

  @override
  int get hashCode {
    return Object.hash(hanjaId, earnedXp, completedCount, totalCount);
  }
}

class ResultState {
  const ResultState({
    required this.completedHanja,
    required this.nextHanja,
    required this.earnedXp,
    required this.completedCount,
    required this.totalCount,
  });

  final HanjaCharacter? completedHanja;
  final HanjaCharacter? nextHanja;
  final int earnedXp;
  final int completedCount;
  final int totalCount;

  bool get isDailyComplete => totalCount > 0 && completedCount >= totalCount;
}
