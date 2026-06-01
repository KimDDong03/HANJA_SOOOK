import '../models/learning_progress_record.dart';

abstract class LearningProgressRepository {
  Future<Set<String>> getCompletedHanjaIds({
    required String studentKey,
    required String learningDate,
  });

  Future<Set<String>> getCompletedHanjaIdsForStudent({
    required String studentKey,
  });

  Future<List<LearningProgressRecord>> getCompletedHanjaRecordsForStudent({
    required String studentKey,
  });

  Future<bool> markHanjaCompleted({
    required String studentKey,
    required String learningDate,
    required String hanjaId,
  });

  Future<bool> addXpEvent({
    required String id,
    required String studentKey,
    required String source,
    required int amount,
    String? refId,
  });

  Future<int> getTotalXp({required String studentKey});

  Future<int> getXpForRef({
    required String studentKey,
    required String source,
    required String refId,
  });
}
