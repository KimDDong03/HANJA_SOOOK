import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/local/app_database.dart';
import 'package:hanja_soook/data/repositories/game_result_repository_impl.dart';

void main() {
  group('GameResultRepositoryImpl', () {
    late AppDatabase database;
    late DateTime now;
    late GameResultRepositoryImpl repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      now = DateTime(2026, 5, 28, 12);
      repository = GameResultRepositoryImpl(database, now: () => now);
    });

    tearDown(() async {
      await database.close();
    });

    test('saves and reads the latest local game result', () async {
      await repository.saveGameResult(
        studentKey: 'student-1',
        learningDate: '20260528',
        score: 3,
        correctCount: 3,
        totalCount: 5,
        timeSec: 42,
      );
      now = DateTime(2026, 5, 28, 12, 1);
      final saved = await repository.saveGameResult(
        studentKey: 'student-1',
        learningDate: '20260528',
        score: 4,
        correctCount: 4,
        totalCount: 5,
        timeSec: 38,
      );

      final latest = await repository.getLatestGameResult(
        studentKey: 'student-1',
      );

      expect(saved.correctCount, 4);
      expect(latest?.score, 4);
      expect(latest?.correctCount, 4);
      expect(latest?.totalCount, 5);
      expect(latest?.timeSec, 38);
    });

    test('keeps latest game result separated by student', () async {
      await repository.saveGameResult(
        studentKey: 'student-1',
        learningDate: '20260528',
        score: 5,
        correctCount: 5,
        totalCount: 5,
        timeSec: 30,
      );
      now = DateTime(2026, 5, 28, 12, 1);
      await repository.saveGameResult(
        studentKey: 'student-2',
        learningDate: '20260528',
        score: 2,
        correctCount: 2,
        totalCount: 5,
        timeSec: 45,
      );

      final latest = await repository.getLatestGameResult(
        studentKey: 'student-1',
      );

      expect(latest?.score, 5);
    });
  });
}
