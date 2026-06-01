import 'dart:convert';

import '../../domain/repositories/pending_sync_repository.dart';
import '../local/app_database.dart';

class PendingSyncRepositoryImpl implements PendingSyncRepository {
  PendingSyncRepositoryImpl(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  @override
  Future<void> enqueue({
    required String id,
    required PendingSyncOperationType operationType,
    required String targetTable,
    required Map<String, Object?> payload,
  }) {
    return _database.enqueuePendingSyncOperation(
      id: id,
      operationType: operationType.storageValue,
      targetTable: targetTable,
      payloadJson: jsonEncode(payload),
      createdAt: _now(),
    );
  }

  @override
  Future<List<PendingSyncOperation>> getPendingOperations({
    int limit = 50,
    String? targetTable,
  }) async {
    final rows = await _database.getPendingSyncOperations(
      limit: limit,
      targetTable: targetTable,
    );
    return [for (final row in rows) _mapRow(row)];
  }

  @override
  Future<void> recordAttemptFailure({
    required PendingSyncOperation operation,
    required String errorMessage,
  }) {
    return _database.markPendingSyncAttempt(
      id: operation.id,
      attemptCount: operation.attemptCount + 1,
      lastError: errorMessage,
      updatedAt: _now(),
    );
  }

  @override
  Future<void> markSynced(String id) {
    return _database.deletePendingSyncOperation(id);
  }

  PendingSyncOperation _mapRow(LocalPendingSyncOperation row) {
    return PendingSyncOperation(
      id: row.id,
      operationType: PendingSyncOperationType.fromStorageValue(
        row.operationType,
      ),
      targetTable: row.targetTable,
      payloadJson: row.payloadJson,
      attemptCount: row.attemptCount,
      lastError: row.lastError,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
