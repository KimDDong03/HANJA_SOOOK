import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/local/app_database.dart';
import 'package:hanja_soook/data/repositories/learning_diagnostics_repository_impl.dart';
import 'package:hanja_soook/domain/models/learning_diagnostics.dart';

void main() {
  group('LearningDiagnosticsRepositoryImpl', () {
    late AppDatabase database;
    late LearningDiagnosticsRepositoryImpl repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = LearningDiagnosticsRepositoryImpl(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('stores practice events and activates aggregate weaknesses', () async {
      await repository.recordPracticeEvent(
        _event(createdAt: DateTime(2026, 6, 3, 9), scoreDelta: 2),
      );
      await repository.recordPracticeEvent(
        _event(createdAt: DateTime(2026, 6, 3, 10), scoreDelta: 2),
      );

      final events = await repository.getPracticeEventsForHanja(
        studentKey: 'student-1',
        hanjaId: 'HJ-1',
      );
      final active = await repository.getActiveWeaknesses(
        studentKey: 'student-1',
      );

      expect(events, hasLength(2));
      expect(active, hasLength(1));
      expect(active.single.score, 4);
      expect(active.single.status, HanjaWeaknessStatus.active);
      expect(active.single.mistakeCount, 2);
    });

    test('resolves active weaknesses after repeated passes', () async {
      await repository.recordPracticeEvent(
        _event(createdAt: DateTime(2026, 6, 3, 9), scoreDelta: 4),
      );
      await repository.recordPracticeEvent(
        _event(
          createdAt: DateTime(2026, 6, 3, 10),
          result: HanjaPracticeResult.passed,
          scoreDelta: -3,
        ),
      );
      await repository.recordPracticeEvent(
        _event(
          createdAt: DateTime(2026, 6, 3, 11),
          result: HanjaPracticeResult.passed,
          scoreDelta: -3,
        ),
      );

      final active = await repository.getActiveWeaknesses(
        studentKey: 'student-1',
      );
      final byHanja = await repository.getWeaknessesByHanja(
        studentKey: 'student-1',
        hanjaIds: {'HJ-1'},
      );

      expect(active, isEmpty);
      expect(byHanja['HJ-1']!.single.status, HanjaWeaknessStatus.resolved);
      expect(byHanja['HJ-1']!.single.score, 0);
    });
  });
}

HanjaPracticeEventInput _event({
  required DateTime createdAt,
  required int scoreDelta,
  HanjaPracticeResult result = HanjaPracticeResult.incorrect,
}) {
  return HanjaPracticeEventInput(
    studentKey: 'student-1',
    hanjaId: 'HJ-1',
    learningDate: '20260603',
    source: HanjaPracticeSource.quiz,
    activityType: HanjaPracticeActivityType.hunToHanja,
    result: result,
    weaknessType: HanjaWeaknessType.hanjaRecognition,
    scoreDelta: scoreDelta,
    createdAt: createdAt,
  );
}
