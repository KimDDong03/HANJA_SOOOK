import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/services/xp_service.dart';
import '../auth/current_profile_controller.dart';

const _localStudentKey = 'local-student';

final learningProgressTickProvider =
    NotifierProvider<LearningProgressTick, int>(LearningProgressTick.new);

final learningProgressControllerProvider = Provider<LearningProgressController>(
  LearningProgressController.new,
);

class LearningProgressController {
  const LearningProgressController(this._ref);

  final Ref _ref;
  XpService get _xpService => const XpService();

  Future<LearningCompletionResult> markHanjaCompleted({
    required String hanjaId,
    required Set<String> todayHanjaIds,
    Set<String>? rewardEligibleHanjaIds,
  }) async {
    final normalizedId = hanjaId.trim();
    if (normalizedId.isEmpty) {
      return const LearningCompletionResult(
        earnedXp: 0,
        completedCount: 0,
        totalCount: 0,
      );
    }

    final studentKey = currentStudentKey(_ref);
    final learningDate = currentLearningDate();
    final repository = _ref.read(learningProgressRepositoryProvider);
    final completedBeforeStudentIds = await repository
        .getCompletedHanjaIdsForStudent(studentKey: studentKey);
    final eligibleRewardIds =
        (rewardEligibleHanjaIds ??
                todayHanjaIds.where(
                  (id) => !completedBeforeStudentIds.contains(id),
                ))
            .map((id) => id.trim())
            .where((id) => id.isNotEmpty)
            .toSet();
    final wasAlreadyCompletedForStudent = completedBeforeStudentIds.contains(
      normalizedId,
    );
    final wasNewlyCompleted = await repository.markHanjaCompleted(
      studentKey: studentKey,
      learningDate: learningDate,
      hanjaId: normalizedId,
    );

    var earnedXp = 0;
    if (wasNewlyCompleted &&
        !wasAlreadyCompletedForStudent &&
        eligibleRewardIds.contains(normalizedId)) {
      final writingXp = _xpService.writingCompletionXp();
      final wroteWritingXp = await repository.addXpEvent(
        id: '$studentKey-$learningDate-writing-$normalizedId',
        studentKey: studentKey,
        source: XpService.writingCompletionSource,
        amount: writingXp,
        refId: normalizedId,
      );
      if (wroteWritingXp) {
        earnedXp += writingXp;
      }
    }

    final completedIds = await repository.getCompletedHanjaIds(
      studentKey: studentKey,
      learningDate: learningDate,
    );
    final completedTodayCount = todayHanjaIds
        .where(completedIds.contains)
        .length;
    final totalCount = todayHanjaIds.length;

    if (totalCount > 0 && completedTodayCount >= totalCount) {
      final bonusXp = _xpService.dailyCompletionBonusXp();
      if (eligibleRewardIds.isNotEmpty) {
        final wroteBonus = await repository.addXpEvent(
          id: '$studentKey-$learningDate-daily-complete',
          studentKey: studentKey,
          source: XpService.dailyCompletionSource,
          amount: bonusXp,
          refId: learningDate,
        );
        if (wroteBonus) {
          earnedXp += bonusXp;
        }
      }
    }

    _ref.read(learningProgressTickProvider.notifier).increase();

    return LearningCompletionResult(
      earnedXp: earnedXp,
      completedCount: completedTodayCount,
      totalCount: totalCount,
    );
  }
}

class LearningCompletionResult {
  const LearningCompletionResult({
    required this.earnedXp,
    required this.completedCount,
    required this.totalCount,
  });

  final int earnedXp;
  final int completedCount;
  final int totalCount;

  bool get isDailyComplete => totalCount > 0 && completedCount >= totalCount;
}

class LearningProgressTick extends Notifier<int> {
  @override
  int build() => 0;

  void increase() {
    state += 1;
  }
}

String currentStudentKey(Ref ref) {
  return ref.read(currentProfileProvider)?.id ?? _localStudentKey;
}

String currentLearningDate([DateTime? now]) {
  final date = now ?? DateTime.now();
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}$month$day';
}
