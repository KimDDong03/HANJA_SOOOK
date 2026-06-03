import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/learning_diagnostics_repository_provider.dart';
import '../../domain/models/learning_diagnostics.dart';
import '../../domain/services/weakness_scoring_service.dart';
import 'learning_progress_controller.dart';

final learningDiagnosticsTickProvider =
    NotifierProvider<LearningDiagnosticsTick, int>(LearningDiagnosticsTick.new);

final learningDiagnosticsControllerProvider =
    Provider<LearningDiagnosticsController>(LearningDiagnosticsController.new);

class LearningDiagnosticsController {
  const LearningDiagnosticsController(this._ref);

  final Ref _ref;
  WeaknessScoringService get _scoringService => const WeaknessScoringService();

  Future<void> recordAttempt({
    required String hanjaId,
    required HanjaPracticeSource source,
    required HanjaPracticeActivityType activityType,
    required HanjaPracticeResult result,
    required bool isLearned,
    HanjaWeaknessType? weaknessType,
    int? hintLevel,
    int? elapsedMs,
    String? confusedWithHanjaId,
  }) async {
    final normalizedId = hanjaId.trim();
    if (normalizedId.isEmpty) {
      return;
    }

    final studentKey = currentStudentKey(_ref);
    try {
      final repository = _ref.read(learningDiagnosticsRepositoryProvider);
      final currentRows = await repository.getWeaknessesByHanja(
        studentKey: studentKey,
        hanjaIds: {normalizedId},
      );
      final current = _matchingWeakness(
        currentRows[normalizedId] ?? const [],
        weaknessType,
        activityType,
        source,
        result,
      );
      final scoringInput = WeaknessScoringInput(
        source: source,
        activityType: activityType,
        result: result,
        isLearned: isLearned,
        weaknessType: weaknessType,
        hintLevel: hintLevel,
        elapsedMs: elapsedMs,
        confusedWithHanjaId: confusedWithHanjaId,
      );
      final scored = _scoringService.score(scoringInput, current: current);

      await repository.recordPracticeEvent(
        HanjaPracticeEventInput(
          studentKey: studentKey,
          hanjaId: normalizedId,
          learningDate: currentLearningDate(),
          source: source,
          activityType: activityType,
          result: result,
          weaknessType: scored.shouldUpdateWeakness
              ? scored.weaknessType
              : weaknessType ?? scored.weaknessType,
          scoreDelta: scored.shouldUpdateWeakness ? scored.scoreDelta : 0,
          hintLevel: hintLevel,
          elapsedMs: elapsedMs,
          confusedWithHanjaId: confusedWithHanjaId,
          createdAt: DateTime.now(),
        ),
      );
      _ref.read(learningDiagnosticsTickProvider.notifier).increase();
    } catch (_) {
      return;
    }
  }

  HanjaWeaknessRecord? _matchingWeakness(
    List<HanjaWeaknessRecord> records,
    HanjaWeaknessType? requestedType,
    HanjaPracticeActivityType activityType,
    HanjaPracticeSource source,
    HanjaPracticeResult result,
  ) {
    if (records.isEmpty) {
      return null;
    }
    final type =
        requestedType ??
        _scoringService.typeFor(
          WeaknessScoringInput(
            source: source,
            activityType: activityType,
            result: result,
            isLearned: true,
          ),
        );
    for (final record in records) {
      if (record.weaknessType == type) {
        return record;
      }
    }
    return null;
  }
}

class LearningDiagnosticsTick extends Notifier<int> {
  @override
  int build() => 0;

  void increase() {
    state += 1;
  }
}
