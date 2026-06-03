import 'dart:convert';

enum PendingSyncOperationType {
  insert('insert'),
  upsert('upsert'),
  update('update'),
  delete('delete');

  const PendingSyncOperationType(this.storageValue);

  final String storageValue;

  static PendingSyncOperationType fromStorageValue(String value) {
    return PendingSyncOperationType.values.firstWhere(
      (type) => type.storageValue == value,
      orElse: () => PendingSyncOperationType.upsert,
    );
  }
}

class PendingSyncTables {
  const PendingSyncTables._();

  static const learningSessions = 'learning_sessions';
  static const writingAttempts = 'writing_attempts';
  static const userHanjaProgress = 'user_hanja_progress';
  static const userHanjaWeaknesses = 'user_hanja_weaknesses';
  static const xpEvents = 'xp_events';
}

class PendingSyncOperation {
  const PendingSyncOperation({
    required this.id,
    required this.operationType,
    required this.targetTable,
    required this.payloadJson,
    required this.attemptCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastError,
  });

  final String id;
  final PendingSyncOperationType operationType;
  final String targetTable;
  final String payloadJson;
  final int attemptCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> get payload {
    final decoded = jsonDecode(payloadJson);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    return const {};
  }
}

abstract class PendingSyncRepository {
  Future<void> enqueue({
    required String id,
    required PendingSyncOperationType operationType,
    required String targetTable,
    required Map<String, Object?> payload,
  });

  Future<List<PendingSyncOperation>> getPendingOperations({
    int limit = 50,
    String? targetTable,
  });

  Future<void> recordAttemptFailure({
    required PendingSyncOperation operation,
    required String errorMessage,
  });

  Future<void> markSynced(String id);
}
