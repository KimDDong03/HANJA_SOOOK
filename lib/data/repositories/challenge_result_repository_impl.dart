import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/challenge_result.dart';
import '../../domain/repositories/pending_sync_repository.dart';
import '../../domain/repositories/challenge_result_repository.dart';
import '../local/app_database.dart';

class ChallengeResultRepositoryImpl implements ChallengeResultRepository {
  ChallengeResultRepositoryImpl(
    this._database, {
    DateTime Function()? now,
    this.remoteClient,
    this.pendingSyncRepository,
  }) : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;
  final SupabaseClient? remoteClient;
  final PendingSyncRepository? pendingSyncRepository;

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
    await _syncLearningSession(
      id: id,
      studentKey: studentKey,
      input: input,
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

  Future<void> _syncLearningSession({
    required String id,
    required String studentKey,
    required ChallengeResultInput input,
    required int earnedXp,
    required DateTime completedAt,
  }) async {
    final payload = {
      'user_id': studentKey,
      'mode': _sessionModeFor(input.mode),
      'score': input.score,
      'accuracy': input.totalCount <= 0
          ? 0
          : ((input.correctCount / input.totalCount) * 100).round(),
      'time_sec': input.timeSec,
      'earned_xp': earnedXp,
      'started_at': completedAt.toUtc().toIso8601String(),
      'ended_at': completedAt.toUtc().toIso8601String(),
      'created_at': completedAt.toUtc().toIso8601String(),
    };
    final client = remoteClient;
    if (!_canSyncFor(studentKey) || client == null) {
      await _enqueuePendingSync(
        id: 'session-$id',
        targetTable: PendingSyncTables.learningSessions,
        payload: payload,
      );
      return;
    }

    try {
      await client.from(PendingSyncTables.learningSessions).insert(
        payload,
      );
    } catch (error) {
      await _enqueuePendingSync(
        id: 'session-$id',
        targetTable: PendingSyncTables.learningSessions,
        payload: {...payload, 'last_error': error.toString()},
      );
    }
  }

  bool _canSyncFor(String studentKey) {
    final client = remoteClient;
    final user = client?.auth.currentUser;
    return client != null && user != null && user.id == studentKey;
  }

  Future<void> _enqueuePendingSync({
    required String id,
    required String targetTable,
    required Map<String, Object?> payload,
  }) async {
    final repository = pendingSyncRepository;
    if (repository == null) {
      return;
    }
    await repository.enqueue(
      id: id,
      operationType: PendingSyncOperationType.insert,
      targetTable: targetTable,
      payload: payload,
    );
  }

  String _sessionModeFor(ChallengeMode mode) {
    return switch (mode) {
      ChallengeMode.quizHanjaToHun ||
      ChallengeMode.quizHunToHanja ||
      ChallengeMode.quizMixed => 'quiz',
      ChallengeMode.speedChoice || ChallengeMode.flipBoard => 'game',
    };
  }
}
