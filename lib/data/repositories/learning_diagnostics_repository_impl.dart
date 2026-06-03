import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/learning_diagnostics.dart';
import '../../domain/repositories/learning_diagnostics_repository.dart';
import '../../domain/repositories/pending_sync_repository.dart';
import '../local/app_database.dart';

class LearningDiagnosticsRepositoryImpl
    implements LearningDiagnosticsRepository {
  LearningDiagnosticsRepositoryImpl(
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
  Future<void> recordPracticeEvent(HanjaPracticeEventInput input) async {
    final id =
        '${input.studentKey}-${input.hanjaId}-${input.createdAt.microsecondsSinceEpoch}';
    await _database.saveHanjaPracticeEvent(
      id: id,
      studentKey: input.studentKey,
      hanjaId: input.hanjaId,
      learningDate: input.learningDate,
      source: input.source.storageValue,
      activityType: input.activityType.storageValue,
      result: input.result.storageValue,
      weaknessType: input.weaknessType?.storageValue,
      scoreDelta: input.scoreDelta,
      hintLevel: input.hintLevel,
      elapsedMs: input.elapsedMs,
      confusedWithHanjaId: input.confusedWithHanjaId,
      createdAt: input.createdAt,
    );

    final weaknessType = input.weaknessType;
    if (weaknessType == null || input.scoreDelta == 0) {
      return;
    }

    final previous = await _database.getHanjaWeakness(
      studentKey: input.studentKey,
      hanjaId: input.hanjaId,
      weaknessType: weaknessType.storageValue,
    );
    final previousRecord = previous == null ? null : _toWeakness(previous);
    final nextScore = ((previousRecord?.score ?? 0) + input.scoreDelta)
        .clamp(0, 10)
        .toInt();
    final nextMistakeCount =
        (previousRecord?.mistakeCount ?? 0) + (input.scoreDelta > 0 ? 1 : 0);
    final nextSuccessStreak =
        input.result == HanjaPracticeResult.passed && input.scoreDelta < 0
        ? (previousRecord?.successStreak ?? 0) + 1
        : input.scoreDelta > 0
        ? 0
        : previousRecord?.successStreak ?? 0;
    final nextStatus = _statusFor(
      nextScore: nextScore,
      successStreak: nextSuccessStreak,
      previousStatus: previousRecord?.status,
    );
    final resolvedAt = nextStatus == HanjaWeaknessStatus.resolved
        ? input.createdAt
        : null;
    final createdAt = previousRecord?.createdAt ?? input.createdAt;

    await _database.upsertHanjaWeakness(
      studentKey: input.studentKey,
      hanjaId: input.hanjaId,
      weaknessType: weaknessType.storageValue,
      score: nextScore,
      status: nextStatus.storageValue,
      mistakeCount: nextMistakeCount,
      successStreak: nextSuccessStreak,
      lastEventAt: input.createdAt,
      resolvedAt: resolvedAt,
      createdAt: createdAt,
      updatedAt: input.createdAt,
    );
    await _syncWeakness(
      HanjaWeaknessRecord(
        studentKey: input.studentKey,
        hanjaId: input.hanjaId,
        weaknessType: weaknessType,
        score: nextScore,
        status: nextStatus,
        mistakeCount: nextMistakeCount,
        successStreak: nextSuccessStreak,
        lastEventAt: input.createdAt,
        resolvedAt: resolvedAt,
        createdAt: createdAt,
        updatedAt: input.createdAt,
      ),
    );
  }

  @override
  Future<List<HanjaWeaknessRecord>> getActiveWeaknesses({
    required String studentKey,
  }) async {
    final rows = await _database.getActiveHanjaWeaknesses(
      studentKey: studentKey,
    );
    return rows.map(_toWeakness).toList();
  }

  @override
  Future<Map<String, List<HanjaWeaknessRecord>>> getWeaknessesByHanja({
    required String studentKey,
    required Set<String> hanjaIds,
  }) async {
    final rows = await _database.getHanjaWeaknessesForHanjaIds(
      studentKey: studentKey,
      hanjaIds: hanjaIds,
    );
    final grouped = <String, List<HanjaWeaknessRecord>>{};
    for (final row in rows) {
      grouped.putIfAbsent(row.hanjaId, () => []).add(_toWeakness(row));
    }
    return grouped;
  }

  @override
  Future<void> markWeaknessResolved({
    required String studentKey,
    required String hanjaId,
    required HanjaWeaknessType weaknessType,
  }) async {
    final resolvedAt = _now();
    await _database.markHanjaWeaknessResolved(
      studentKey: studentKey,
      hanjaId: hanjaId,
      weaknessType: weaknessType.storageValue,
      resolvedAt: resolvedAt,
    );
    await _syncWeakness(
      HanjaWeaknessRecord(
        studentKey: studentKey,
        hanjaId: hanjaId,
        weaknessType: weaknessType,
        score: 0,
        status: HanjaWeaknessStatus.resolved,
        mistakeCount: 0,
        successStreak: 0,
        lastEventAt: resolvedAt,
        resolvedAt: resolvedAt,
        createdAt: resolvedAt,
        updatedAt: resolvedAt,
      ),
    );
  }

  @override
  Future<List<HanjaPracticeEvent>> getPracticeEventsForHanja({
    required String studentKey,
    required String hanjaId,
  }) async {
    final rows = await _database.getHanjaPracticeEventsForHanja(
      studentKey: studentKey,
      hanjaId: hanjaId,
    );
    return rows.map(_toEvent).toList();
  }

  HanjaWeaknessStatus _statusFor({
    required int nextScore,
    required int successStreak,
    required HanjaWeaknessStatus? previousStatus,
  }) {
    if (nextScore <= 0 || successStreak >= 2) {
      return HanjaWeaknessStatus.resolved;
    }
    if (nextScore >= 4) {
      return HanjaWeaknessStatus.active;
    }
    if (previousStatus == HanjaWeaknessStatus.active) {
      return HanjaWeaknessStatus.active;
    }
    return HanjaWeaknessStatus.watching;
  }

  HanjaPracticeEvent _toEvent(LocalHanjaPracticeEvent row) {
    return HanjaPracticeEvent(
      id: row.id,
      studentKey: row.studentKey,
      hanjaId: row.hanjaId,
      learningDate: row.learningDate,
      source: HanjaPracticeSource.fromStorageValue(row.source),
      activityType: HanjaPracticeActivityType.fromStorageValue(
        row.activityType,
      ),
      result: HanjaPracticeResult.fromStorageValue(row.result),
      weaknessType: row.weaknessType == null
          ? null
          : HanjaWeaknessType.fromStorageValue(row.weaknessType!),
      scoreDelta: row.scoreDelta,
      hintLevel: row.hintLevel,
      elapsedMs: row.elapsedMs,
      confusedWithHanjaId: row.confusedWithHanjaId,
      createdAt: row.createdAt,
    );
  }

  HanjaWeaknessRecord _toWeakness(LocalHanjaWeaknessesData row) {
    return HanjaWeaknessRecord(
      studentKey: row.studentKey,
      hanjaId: row.hanjaId,
      weaknessType: HanjaWeaknessType.fromStorageValue(row.weaknessType),
      score: row.score,
      status: HanjaWeaknessStatus.fromStorageValue(row.status),
      mistakeCount: row.mistakeCount,
      successStreak: row.successStreak,
      lastEventAt: row.lastEventAt,
      resolvedAt: row.resolvedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<void> _syncWeakness(HanjaWeaknessRecord record) async {
    final payload = {
      'user_id': record.studentKey,
      'hanja_id': record.hanjaId,
      'weakness_type': record.weaknessType.storageValue,
      'score': record.score,
      'status': record.status.storageValue,
      'mistake_count': record.mistakeCount,
      'success_streak': record.successStreak,
      'last_event_at': record.lastEventAt.toUtc().toIso8601String(),
      'resolved_at': record.resolvedAt?.toUtc().toIso8601String(),
      'updated_at': record.updatedAt.toUtc().toIso8601String(),
    };
    final client = remoteClient;
    if (!_canSyncFor(record.studentKey) || client == null) {
      await _enqueuePendingSync(record, payload);
      return;
    }

    try {
      await client
          .from(PendingSyncTables.userHanjaWeaknesses)
          .upsert(payload, onConflict: 'user_id,hanja_id,weakness_type');
    } catch (error) {
      await _enqueuePendingSync(record, {
        ...payload,
        'last_error': error.toString(),
      });
    }
  }

  Future<void> _enqueuePendingSync(
    HanjaWeaknessRecord record,
    Map<String, Object?> payload,
  ) async {
    final repository = pendingSyncRepository;
    if (repository == null) {
      return;
    }
    await repository.enqueue(
      id: 'weakness-${record.studentKey}-${record.hanjaId}-${record.weaknessType.storageValue}-${record.updatedAt.microsecondsSinceEpoch}',
      operationType: PendingSyncOperationType.upsert,
      targetTable: PendingSyncTables.userHanjaWeaknesses,
      payload: payload,
    );
  }

  bool _canSyncFor(String studentKey) {
    final client = remoteClient;
    final user = client?.auth.currentUser;
    return client != null && user != null && user.id == studentKey;
  }
}
