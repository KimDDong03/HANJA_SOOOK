import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/learning_progress_record.dart';
import '../../domain/repositories/pending_sync_repository.dart';
import '../../domain/repositories/learning_progress_repository.dart';
import '../local/app_database.dart';

class LearningProgressRepositoryImpl implements LearningProgressRepository {
  LearningProgressRepositoryImpl(
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
  }) async {
    final completedAt = _now();
    final didInsert = await _database.markHanjaCompleted(
      studentKey: studentKey,
      learningDate: learningDate,
      hanjaId: hanjaId,
      completedAt: completedAt,
    );
    if (didInsert) {
      await _syncHanjaProgress(
        studentKey: studentKey,
        hanjaId: hanjaId,
        completedAt: completedAt,
      );
    }
    return didInsert;
  }

  @override
  Future<bool> addXpEvent({
    required String id,
    required String studentKey,
    required String source,
    required int amount,
    String? refId,
  }) async {
    final createdAt = _now();
    final didInsert = await _database.addXpEvent(
      id: id,
      studentKey: studentKey,
      source: source,
      amount: amount,
      refId: refId,
      createdAt: createdAt,
    );
    if (didInsert) {
      final totalXp = await _database.getTotalXp(studentKey: studentKey);
      await _syncXpEvent(
        id: id,
        studentKey: studentKey,
        source: source,
        amount: amount,
        refId: refId,
        totalXp: totalXp,
        createdAt: createdAt,
      );
    }
    return didInsert;
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

  Future<void> _syncHanjaProgress({
    required String studentKey,
    required String hanjaId,
    required DateTime completedAt,
  }) async {
    final payload = {
      'user_id': studentKey,
      'hanja_id': hanjaId,
      'status': 'completed',
      'writing_completed_count': 1,
      'last_studied_at': completedAt.toUtc().toIso8601String(),
    };
    final client = remoteClient;
    if (!_canSyncFor(studentKey) || client == null) {
      await _enqueuePendingSync(
        id: 'progress-$studentKey-$hanjaId-${completedAt.microsecondsSinceEpoch}',
        targetTable: PendingSyncTables.userHanjaProgress,
        payload: payload,
      );
      return;
    }

    try {
      await client
          .from(PendingSyncTables.userHanjaProgress)
          .upsert(payload, onConflict: 'user_id,hanja_id');
    } catch (error) {
      await _enqueuePendingSync(
        id: 'progress-$studentKey-$hanjaId-${completedAt.microsecondsSinceEpoch}',
        targetTable: PendingSyncTables.userHanjaProgress,
        payload: {...payload, 'last_error': error.toString()},
      );
    }
  }

  Future<void> _syncXpEvent({
    required String id,
    required String studentKey,
    required String source,
    required int amount,
    required int totalXp,
    required DateTime createdAt,
    String? refId,
  }) async {
    final payload = {
      'user_id': studentKey,
      'source': source,
      'amount': amount,
      'ref_table': _refTableFor(source),
      'ref_id': refId,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
    final client = remoteClient;
    if (!_canSyncFor(studentKey) || client == null) {
      await _enqueuePendingSync(
        id: 'xp-$id',
        targetTable: PendingSyncTables.xpEvents,
        payload: payload,
      );
      return;
    }

    try {
      await client.from(PendingSyncTables.xpEvents).insert(payload);
      await client
          .from('profiles')
          .update({'total_xp': totalXp})
          .eq('id', studentKey);
    } catch (error) {
      await _enqueuePendingSync(
        id: 'xp-$id',
        targetTable: PendingSyncTables.xpEvents,
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
      operationType: PendingSyncOperationType.upsert,
      targetTable: targetTable,
      payload: payload,
    );
  }

  String? _refTableFor(String source) {
    if (source.contains('writing')) {
      return 'hanja_characters';
    }
    if (source.contains('challenge')) {
      return 'challenge_results';
    }
    return null;
  }
}
