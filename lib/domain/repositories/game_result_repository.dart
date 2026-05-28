import '../models/learning_result.dart';

abstract class GameResultRepository {
  Future<LearningResult> saveGameResult({
    required String studentKey,
    required String learningDate,
    required int score,
    required int correctCount,
    required int totalCount,
    required int timeSec,
  });

  Future<LearningResult?> getLatestGameResult({required String studentKey});
}
