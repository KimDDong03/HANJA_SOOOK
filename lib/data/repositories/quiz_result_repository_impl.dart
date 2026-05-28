import '../../domain/models/learning_result.dart';
import '../../domain/models/learning_session.dart';
import '../../domain/repositories/quiz_result_repository.dart';
import '../local/app_database.dart';

class QuizResultRepositoryImpl implements QuizResultRepository {
  QuizResultRepositoryImpl(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  @override
  Future<LearningResult> saveQuizResult({
    required String studentKey,
    required String learningDate,
    required int score,
    required int correctCount,
    required int totalCount,
    required int timeSec,
  }) async {
    final completedAt = _now();
    final id =
        '$studentKey-$learningDate-${completedAt.microsecondsSinceEpoch}';
    await _database.saveQuizResult(
      id: id,
      studentKey: studentKey,
      learningDate: learningDate,
      score: score,
      correctCount: correctCount,
      totalCount: totalCount,
      timeSec: timeSec,
      completedAt: completedAt,
    );
    return LearningResult(
      id: id,
      mode: LearningMode.quiz,
      score: score,
      timeSec: timeSec,
      correctCount: correctCount,
      totalCount: totalCount,
      completedAt: completedAt,
    );
  }

  @override
  Future<LearningResult?> getLatestQuizResult({
    required String studentKey,
  }) async {
    final row = await _database.getLatestQuizResult(studentKey: studentKey);
    if (row == null) {
      return null;
    }
    return LearningResult(
      id: row.id,
      mode: LearningMode.quiz,
      score: row.score,
      timeSec: row.timeSec,
      correctCount: row.correctCount,
      totalCount: row.totalCount,
      completedAt: row.completedAt,
    );
  }
}
