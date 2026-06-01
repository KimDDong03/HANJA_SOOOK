import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/local/app_database.dart';
import 'package:hanja_soook/data/repositories/pending_sync_repository_impl.dart';
import 'package:hanja_soook/domain/repositories/pending_sync_repository.dart';

void main() {
  group('PendingSyncRepositoryImpl', () {
    late AppDatabase database;
    late PendingSyncRepositoryImpl repository;
    var now = DateTime(2026, 6, 1, 9);

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = PendingSyncRepositoryImpl(database, now: () => now);
    });

    tearDown(() async {
      await database.close();
    });

    test('queues failed Supabase writes for later sync', () async {
      await repository.enqueue(
        id: 'learning-session-1',
        operationType: PendingSyncOperationType.insert,
        targetTable: PendingSyncTables.learningSessions,
        payload: const {'id': 'learning-session-1'},
      );

      final pending = await repository.getPendingOperations();

      expect(pending, hasLength(1));
      expect(pending.single.operationType, PendingSyncOperationType.insert);
      expect(pending.single.targetTable, PendingSyncTables.learningSessions);
      expect(pending.single.payload, {'id': 'learning-session-1'});
      expect(pending.single.attemptCount, 0);
      expect(pending.single.lastError, isNull);
    });

    test('filters queued operations by target table', () async {
      await repository.enqueue(
        id: 'learning-session-1',
        operationType: PendingSyncOperationType.insert,
        targetTable: PendingSyncTables.learningSessions,
        payload: const {'id': 'learning-session-1'},
      );
      await repository.enqueue(
        id: 'xp-event-1',
        operationType: PendingSyncOperationType.insert,
        targetTable: PendingSyncTables.xpEvents,
        payload: const {'id': 'xp-event-1'},
      );

      final pending = await repository.getPendingOperations(
        targetTable: PendingSyncTables.xpEvents,
      );

      expect(pending, hasLength(1));
      expect(pending.single.id, 'xp-event-1');
    });

    test('tracks retry failures and removes synced operations', () async {
      await repository.enqueue(
        id: 'xp-event-1',
        operationType: PendingSyncOperationType.insert,
        targetTable: PendingSyncTables.xpEvents,
        payload: const {'id': 'xp-event-1'},
      );
      final operation = (await repository.getPendingOperations()).single;

      now = DateTime(2026, 6, 1, 10);
      await repository.recordAttemptFailure(
        operation: operation,
        errorMessage: 'network unavailable',
      );

      final failed = (await repository.getPendingOperations()).single;
      expect(failed.attemptCount, 1);
      expect(failed.lastError, 'network unavailable');
      expect(failed.updatedAt, now);

      await repository.markSynced(failed.id);
      expect(await repository.getPendingOperations(), isEmpty);
    });
  });
}
