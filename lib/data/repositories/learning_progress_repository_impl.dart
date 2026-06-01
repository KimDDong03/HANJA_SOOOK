import '../../domain/models/learning_progress_record.dart';
import '../../domain/repositories/learning_progress_repository.dart';
import '../local/app_database.dart';

class LearningProgressRepositoryImpl implements LearningProgressRepository {
  LearningProgressRepositoryImpl(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  @override
  Future<Set<String>> getCompletedHanjaIds({
    required String studentKey,
    required String learningDate,
  }) async {
    final rows = await _database.getCompletedHanja(
      studentKey: studentKey,
      learningDate: learningDate,
    );
    return rows.map((row) => row.hanjaId).toSet();
  }

  @override
  Future<Set<String>> getCompletedHanjaIdsForStudent({
    required String studentKey,
  }) async {
    final rows = await _database.getCompletedHanjaForStudent(
      studentKey: studentKey,
    );
    return rows.map((row) => row.hanjaId).toSet();
  }

  @override
  Future<List<LearningProgressRecord>> getCompletedHanjaRecordsForStudent({
    required String studentKey,
  }) async {
    final rows = await _database.getCompletedHanjaForStudent(
      studentKey: studentKey,
    );
    return rows.map(_toProgressRecord).toList();
  }

  LearningProgressRecord _toProgressRecord(DailyLearningProgressData row) {
    return LearningProgressRecord(
      studentKey: row.studentKey,
      learningDate: row.learningDate,
      hanjaId: row.hanjaId,
      completedAt: row.completedAt,
    );
  }

  @override
  Future<bool> markHanjaCompleted({
    required String studentKey,
    required String learningDate,
    required String hanjaId,
  }) {
    return _database.markHanjaCompleted(
      studentKey: studentKey,
      learningDate: learningDate,
      hanjaId: hanjaId,
      completedAt: _now(),
    );
  }

  @override
  Future<bool> addXpEvent({
    required String id,
    required String studentKey,
    required String source,
    required int amount,
    String? refId,
  }) {
    return _database.addXpEvent(
      id: id,
      studentKey: studentKey,
      source: source,
      amount: amount,
      refId: refId,
      createdAt: _now(),
    );
  }

  @override
  Future<int> getTotalXp({required String studentKey}) {
    return _database.getTotalXp(studentKey: studentKey);
  }

  @override
  Future<int> getXpForRef({
    required String studentKey,
    required String source,
    required String refId,
  }) {
    return _database.getXpForRef(
      studentKey: studentKey,
      source: source,
      refId: refId,
    );
  }
}
