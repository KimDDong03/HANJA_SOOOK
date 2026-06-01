import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/challenge_result_repository_provider.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/challenge_result.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/services/learning_plan_service.dart';
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

  HanjaCharacter? completedHanja;
  if (args.hanjaId != null) {
    completedHanja = await contentRepository.getHanjaById(args.hanjaId!);
  }

  ChallengeResult? challengeResult;
  if (args.challengeResultId != null) {
    challengeResult = await ref
        .watch(challengeResultRepositoryProvider)
        .getChallengeResultById(args.challengeResultId!);
  }

  HanjaCharacter? nextHanja;
  for (final hanja in plan.items) {
    if (!completedIds.contains(hanja.id)) {
      nextHanja = hanja;
      break;
    }
  }
  if (nextHanja == null && completedHanja != null) {
    final learnedIds = progressRecords.map((record) => record.hanjaId).toSet();
    nextHanja = _nextUnlearnedAfter(
      items: allItems,
      currentHanjaId: completedHanja.id,
      learnedIds: learnedIds,
    );
  }
  final completedCount = plan.items.where((hanja) {
    return completedIds.contains(hanja.id);
  }).length;

  return ResultState(
    completedHanja: completedHanja,
    challengeResult: challengeResult,
    nextHanja: nextHanja,
    earnedXp: challengeResult?.earnedXp ?? args.earnedXp ?? 0,
    completedCount: args.completedCount ?? completedCount,
    totalCount: args.totalCount ?? plan.items.length,
    writingPassed: args.writingPassed,
    writingScore: args.writingScore,
    writingAccuracy: args.writingAccuracy,
    writingStars: args.writingStars,
    writingTimeSec: args.writingTimeSec,
    requestedChallengeResultId: args.challengeResultId,
  );
});

HanjaCharacter? _nextUnlearnedAfter({
  required List<HanjaCharacter> items,
  required String currentHanjaId,
  required Set<String> learnedIds,
}) {
  final currentIndex = items.indexWhere((item) => item.id == currentHanjaId);
  if (currentIndex < 0) {
    return null;
  }
  for (var index = currentIndex + 1; index < items.length; index += 1) {
    if (!learnedIds.contains(items[index].id)) {
      return items[index];
    }
  }
  for (var index = 0; index < currentIndex; index += 1) {
    if (!learnedIds.contains(items[index].id)) {
      return items[index];
    }
  }
  return null;
}

class ResultArgs {
  const ResultArgs({
    required this.hanjaId,
    required this.earnedXp,
    required this.completedCount,
    required this.totalCount,
    required this.writingPassed,
    this.writingScore,
    this.writingAccuracy,
    this.writingStars,
    this.writingTimeSec,
    this.challengeResultId,
  });

  final String? hanjaId;
  final int? earnedXp;
  final int? completedCount;
  final int? totalCount;
  final bool? writingPassed;
  final int? writingScore;
  final int? writingAccuracy;
  final int? writingStars;
  final int? writingTimeSec;
  final String? challengeResultId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ResultArgs &&
            other.hanjaId == hanjaId &&
            other.earnedXp == earnedXp &&
            other.completedCount == completedCount &&
            other.totalCount == totalCount &&
            other.writingPassed == writingPassed &&
            other.writingScore == writingScore &&
            other.writingAccuracy == writingAccuracy &&
            other.writingStars == writingStars &&
            other.writingTimeSec == writingTimeSec &&
            other.challengeResultId == challengeResultId;
  }

  @override
  int get hashCode {
    return Object.hash(
      hanjaId,
      earnedXp,
      completedCount,
      totalCount,
      writingPassed,
      writingScore,
      writingAccuracy,
      writingStars,
      writingTimeSec,
      challengeResultId,
    );
  }
}

class ResultState {
  const ResultState({
    required this.completedHanja,
    required this.challengeResult,
    required this.nextHanja,
    required this.earnedXp,
    required this.completedCount,
    required this.totalCount,
    required this.writingPassed,
    required this.writingScore,
    required this.writingAccuracy,
    required this.writingStars,
    required this.writingTimeSec,
    required this.requestedChallengeResultId,
  });

  final HanjaCharacter? completedHanja;
  final ChallengeResult? challengeResult;
  final HanjaCharacter? nextHanja;
  final int earnedXp;
  final int completedCount;
  final int totalCount;
  final bool? writingPassed;
  final int? writingScore;
  final int? writingAccuracy;
  final int? writingStars;
  final int? writingTimeSec;
  final String? requestedChallengeResultId;

  bool get isDailyComplete => totalCount > 0 && completedCount >= totalCount;

  bool get isChallengeResult => challengeResult != null;

  bool get isMissingChallengeResult =>
      requestedChallengeResultId != null && challengeResult == null;

  int get challengeAccuracyPercent {
    final result = challengeResult;
    if (result == null || result.totalCount == 0) {
      return 0;
    }
    return ((result.correctCount / result.totalCount) * 100).round();
  }

  int get challengeStars {
    if (challengeResult?.mode == ChallengeMode.flipBoard) {
      return challengeResult!.flippedTileCount > 0 ? 3 : 0;
    }
    if (challengeAccuracyPercent >= 90) {
      return 3;
    }
    if (challengeAccuracyPercent >= 70) {
      return 2;
    }
    if (challengeAccuracyPercent > 0) {
      return 1;
    }
    return 0;
  }

  String get starsText {
    if (challengeStars == 0) {
      return '별 없음';
    }
    return List.filled(challengeStars, '★').join();
  }

  String? get writingResultLabel {
    return switch (writingPassed) {
      true => '자유쓰기 통과',
      false => '자유쓰기 다시 연습',
      null => null,
    };
  }

  bool get hasWritingMetrics {
    return writingScore != null ||
        writingAccuracy != null ||
        writingStars != null ||
        writingTimeSec != null;
  }

  int? get writingAccuracyPercent => writingAccuracy ?? writingScore;

  String get writingStarsText {
    final stars = writingStars;
    if (stars == null) {
      return '-';
    }
    if (stars <= 0) {
      return '별 없음';
    }
    return List.filled(stars, '★').join();
  }
}
