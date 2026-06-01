import '../models/challenge_result.dart';

abstract class ChallengeResultRepository {
  Future<ChallengeResult> saveChallengeResult({
    required String studentKey,
    required String learningDate,
    required ChallengeResultInput input,
    required int earnedXp,
  });

  Future<ChallengeResult?> getLatestChallengeResult({
    required String studentKey,
    ChallengeMode? mode,
  });

  Future<ChallengeResult?> getChallengeResultById(String id);

  Future<List<ChallengeResult>> getChallengeResults({
    Set<String>? studentKeys,
    String? learningDate,
  });
}
