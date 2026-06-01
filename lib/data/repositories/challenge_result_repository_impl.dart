import '../../domain/models/challenge_result.dart';
import '../../domain/repositories/challenge_result_repository.dart';
import '../local/app_database.dart';

class ChallengeResultRepositoryImpl implements ChallengeResultRepository {
  ChallengeResultRepositoryImpl(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  @override
  Future<ChallengeResult> saveChallengeResult({
    required String studentKey,
    required String learningDate,
    required ChallengeResultInput input,
    required int earnedXp,
  }) async {
    final completedAt = _now();
    final id =
        '$studentKey-$learningDate-${input.mode.storageValue}-${completedAt.microsecondsSinceEpoch}';
    await _database.saveChallengeResult(
      id: id,
      studentKey: studentKey,
      learningDate: learningDate,
      mode: input.mode.storageValue,
      score: input.score,
      correctCount: input.correctCount,
      totalCount: input.totalCount,
      timeSec: input.timeSec,
      flippedTileCount: input.flippedTileCount,
      earnedXp: earnedXp,
      completedAt: completedAt,
    );
    return ChallengeResult(
      id: id,
      studentKey: studentKey,
      learningDate: learningDate,
      mode: input.mode,
      score: input.score,
      correctCount: input.correctCount,
      totalCount: input.totalCount,
      timeSec: input.timeSec,
      flippedTileCount: input.flippedTileCount,
      earnedXp: earnedXp,
      completedAt: completedAt,
    );
  }

  @override
  Future<ChallengeResult?> getLatestChallengeResult({
    required String studentKey,
    ChallengeMode? mode,
  }) async {
    final row = await _database.getLatestChallengeResult(
      studentKey: studentKey,
      mode: mode?.storageValue,
    );
    return row == null ? null : _mapRow(row);
  }

  @override
  Future<ChallengeResult?> getChallengeResultById(String id) async {
    final row = await _database.getChallengeResultById(id);
    return row == null ? null : _mapRow(row);
  }

  @override
  Future<List<ChallengeResult>> getChallengeResults({
    Set<String>? studentKeys,
    String? learningDate,
  }) async {
    final rows = await _database.getChallengeResults(
      studentKeys: studentKeys,
      learningDate: learningDate,
    );
    return [for (final row in rows) _mapRow(row)];
  }

  ChallengeResult _mapRow(LocalChallengeResult row) {
    return ChallengeResult(
      id: row.id,
      studentKey: row.studentKey,
      learningDate: row.learningDate,
      mode: ChallengeMode.fromStorageValue(row.mode),
      score: row.score,
      correctCount: row.correctCount,
      totalCount: row.totalCount,
      timeSec: row.timeSec,
      flippedTileCount: row.flippedTileCount,
      earnedXp: row.earnedXp,
      completedAt: row.completedAt,
    );
  }
}
