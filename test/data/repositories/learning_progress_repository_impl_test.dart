import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/local/app_database.dart';
import 'package:hanja_soook/data/repositories/learning_progress_repository_impl.dart';

void main() {
  group('LearningProgressRepositoryImpl', () {
    late AppDatabase database;
    late LearningProgressRepositoryImpl repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = LearningProgressRepositoryImpl(
        database,
        now: () => DateTime(2026, 5, 28),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('marks and reads completed Hanja ids for one local day', () async {
      await repository.markHanjaCompleted(
        studentKey: 'student-1',
        learningDate: '20260528',
        hanjaId: 'HJ-0001',
      );

      final completed = await repository.getCompletedHanjaIds(
        studentKey: 'student-1',
        learningDate: '20260528',
      );

      expect(completed, {'HJ-0001'});
    });

    test('keeps different students and dates separate', () async {
      await repository.markHanjaCompleted(
        studentKey: 'student-1',
        learningDate: '20260528',
        hanjaId: 'HJ-0001',
      );
      await repository.markHanjaCompleted(
        studentKey: 'student-2',
        learningDate: '20260528',
        hanjaId: 'HJ-0002',
      );
      await repository.markHanjaCompleted(
        studentKey: 'student-1',
        learningDate: '20260529',
        hanjaId: 'HJ-0003',
      );

      final completed = await repository.getCompletedHanjaIds(
        studentKey: 'student-1',
        learningDate: '20260528',
      );

      expect(completed, {'HJ-0001'});
    });

    test('stores xp events once and sums total xp', () async {
      final inserted = await repository.addXpEvent(
        id: 'student-1-20260528-writing-HJ-0001',
        studentKey: 'student-1',
        source: 'writing_completion',
        amount: 10,
        refId: 'HJ-0001',
      );
      final duplicate = await repository.addXpEvent(
        id: 'student-1-20260528-writing-HJ-0001',
        studentKey: 'student-1',
        source: 'writing_completion',
        amount: 10,
        refId: 'HJ-0001',
      );
      await repository.addXpEvent(
        id: 'student-1-20260528-daily-complete',
        studentKey: 'student-1',
        source: 'daily_completion_bonus',
        amount: 20,
        refId: '20260528',
      );

      expect(inserted, isTrue);
      expect(duplicate, isFalse);
      expect(await repository.getTotalXp(studentKey: 'student-1'), 30);
      expect(
        await repository.getXpForRef(
          studentKey: 'student-1',
          source: 'writing_completion',
          refId: 'HJ-0001',
        ),
        10,
      );
    });
  });
}
