import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/local/app_database.dart';
import 'package:hanja_soook/data/repositories/challenge_result_repository_impl.dart';
import 'package:hanja_soook/domain/models/challenge_result.dart';

void main() {
  group('ChallengeResultRepositoryImpl', () {
    late AppDatabase database;
    late DateTime now;
    late ChallengeResultRepositoryImpl repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      now = DateTime(2026, 5, 30, 12);
      repository = ChallengeResultRepositoryImpl(database, now: () => now);
    });

    tearDown(() async {
      await database.close();
    });

    test('saves and reads local challenge results', () async {
      final saved = await repository.saveChallengeResult(
        studentKey: 'student-1',
        learningDate: '20260530',
        input: const ChallengeResultInput(
          mode: ChallengeMode.flipBoard,
          score: 7,
          correctCount: 4,
          totalCount: 9,
          timeSec: 60,
          flippedTileCount: 4,
        ),
        earnedXp: 40,
      );

      final latest = await repository.getLatestChallengeResult(
        studentKey: 'student-1',
        mode: ChallengeMode.flipBoard,
      );
      final byId = await repository.getChallengeResultById(saved.id);
      final results = await repository.getChallengeResults(
        studentKeys: {'student-1'},
        learningDate: '20260530',
      );

      expect(saved.mode, ChallengeMode.flipBoard);
      expect(latest?.id, saved.id);
      expect(byId?.id, saved.id);
      expect(results, hasLength(1));
      expect(results.single.flippedTileCount, 4);
      expect(results.single.earnedXp, 40);
    });

    test('filters challenge results by student and date', () async {
      await repository.saveChallengeResult(
        studentKey: 'student-1',
        learningDate: '20260530',
        input: const ChallengeResultInput(
          mode: ChallengeMode.speedChoice,
          score: 5,
          correctCount: 5,
          totalCount: 5,
          timeSec: 30,
        ),
        earnedXp: 45,
      );
      now = DateTime(2026, 5, 31, 12);
      await repository.saveChallengeResult(
        studentKey: 'student-2',
        learningDate: '20260531',
        input: const ChallengeResultInput(
          mode: ChallengeMode.speedChoice,
          score: 2,
          correctCount: 2,
          totalCount: 5,
          timeSec: 45,
        ),
        earnedXp: 30,
      );

      final results = await repository.getChallengeResults(
        studentKeys: {'student-1'},
        learningDate: '20260530',
      );

      expect(results, hasLength(1));
      expect(results.single.studentKey, 'student-1');
    });
  });
}
