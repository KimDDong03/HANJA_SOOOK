import '../models/learning_result.dart';

abstract class QuizResultRepository {
  Future<LearningResult> saveQuizResult({
    required String studentKey,
    required String learningDate,
    required int score,
    required int correctCount,
    required int totalCount,
    required int timeSec,
  });

  Future<LearningResult?> getLatestQuizResult({required String studentKey});
}
