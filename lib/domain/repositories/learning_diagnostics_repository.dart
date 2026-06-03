import '../models/learning_diagnostics.dart';

abstract class LearningDiagnosticsRepository {
  Future<void> recordPracticeEvent(HanjaPracticeEventInput input);

  Future<List<HanjaWeaknessRecord>> getActiveWeaknesses({
    required String studentKey,
  });

  Future<Map<String, List<HanjaWeaknessRecord>>> getWeaknessesByHanja({
    required String studentKey,
    required Set<String> hanjaIds,
  });

  Future<void> markWeaknessResolved({
    required String studentKey,
    required String hanjaId,
    required HanjaWeaknessType weaknessType,
  });

  Future<List<HanjaPracticeEvent>> getPracticeEventsForHanja({
    required String studentKey,
    required String hanjaId,
  });
}
