import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/local/app_database.dart';
import 'package:hanja_soook/data/local/app_database_provider.dart';
import 'package:hanja_soook/domain/models/hanja_character.dart';
import 'package:hanja_soook/domain/models/learning_diagnostics.dart';
import 'package:hanja_soook/domain/models/learning_progress_record.dart';
import 'package:hanja_soook/domain/services/learning_plan_service.dart';
import 'package:hanja_soook/features/learning/demo_review_focus_seed_controller.dart';

void main() {
  test('demo seed adds review due items and active focus items', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final container = _container(database);
    addTearDown(container.dispose);

    await container
        .read(demoReviewFocusSeedControllerProvider)
        .ensureSeeded(items: _items);

    final progressRows = await database.getCompletedHanjaForStudent(
      studentKey: 'local-student',
    );
    final activeWeaknesses = await database.getActiveHanjaWeaknesses(
      studentKey: 'local-student',
    );
    final plan = const LearningPlanService().buildDailyPlan(
      allItems: _items,
      progressRecords: progressRows.map(_toRecord).toList(),
      learningDate: '20260609',
      newItemLimit: 5,
      reviewItemLimit: 4,
    );

    expect(progressRows.map((row) => row.hanjaId).toSet(), {
      'HJ-0001',
      'HJ-0002',
      'HJ-0003',
      'HJ-0004',
      'HJ-0005',
      'HJ-0006',
      'HJ-0007',
    });
    expect(plan.reviewItems.map((item) => item.id), [
      'HJ-0001',
      'HJ-0002',
      'HJ-0003',
      'HJ-0004',
    ]);
    expect(activeWeaknesses.map((row) => row.hanjaId), [
      'HJ-0005',
      'HJ-0006',
      'HJ-0007',
    ]);
    expect(activeWeaknesses.map((row) => row.weaknessType), [
      HanjaWeaknessType.hanjaRecognition.storageValue,
      HanjaWeaknessType.hunMeaning.storageValue,
      HanjaWeaknessType.writing.storageValue,
    ]);
  });

  test(
    'demo seed does not revive a resolved focus item after restart',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final firstContainer = _container(database);

      await firstContainer
          .read(demoReviewFocusSeedControllerProvider)
          .ensureSeeded(items: _items);
      firstContainer.dispose();

      await database.markHanjaWeaknessResolved(
        studentKey: 'local-student',
        hanjaId: 'HJ-0005',
        weaknessType: HanjaWeaknessType.hanjaRecognition.storageValue,
        resolvedAt: DateTime(2026, 6, 9, 10),
      );

      final secondContainer = _container(database);
      addTearDown(secondContainer.dispose);
      await secondContainer
          .read(demoReviewFocusSeedControllerProvider)
          .ensureSeeded(items: _items);

      final activeWeaknesses = await database.getActiveHanjaWeaknesses(
        studentKey: 'local-student',
      );
      final resolved = await database.getHanjaWeakness(
        studentKey: 'local-student',
        hanjaId: 'HJ-0005',
        weaknessType: HanjaWeaknessType.hanjaRecognition.storageValue,
      );

      expect(activeWeaknesses.map((row) => row.hanjaId), [
        'HJ-0006',
        'HJ-0007',
      ]);
      expect(resolved?.status, HanjaWeaknessStatus.resolved.storageValue);
    },
  );
}

ProviderContainer _container(AppDatabase database) {
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      demoReviewFocusSeedEnabledProvider.overrideWithValue(true),
    ],
  );
}

LearningProgressRecord _toRecord(DailyLearningProgressData row) {
  return LearningProgressRecord(
    studentKey: row.studentKey,
    learningDate: row.learningDate,
    hanjaId: row.hanjaId,
    completedAt: row.completedAt,
  );
}

const _items = [
  HanjaCharacter(
    id: 'HJ-0001',
    character: '一',
    sound: '일',
    meaning: '한 일',
    grade: 3,
    sortOrder: 1,
  ),
  HanjaCharacter(
    id: 'HJ-0002',
    character: '百',
    sound: '백',
    meaning: '일백 백',
    grade: 3,
    sortOrder: 2,
  ),
  HanjaCharacter(
    id: 'HJ-0003',
    character: '二',
    sound: '이',
    meaning: '두 이',
    grade: 3,
    sortOrder: 3,
  ),
  HanjaCharacter(
    id: 'HJ-0004',
    character: '三',
    sound: '삼',
    meaning: '석 삼',
    grade: 3,
    sortOrder: 4,
  ),
  HanjaCharacter(
    id: 'HJ-0005',
    character: '四',
    sound: '사',
    meaning: '넉 사',
    grade: 3,
    sortOrder: 5,
  ),
  HanjaCharacter(
    id: 'HJ-0006',
    character: '五',
    sound: '오',
    meaning: '다섯 오',
    grade: 3,
    sortOrder: 6,
  ),
  HanjaCharacter(
    id: 'HJ-0007',
    character: '六',
    sound: '륙',
    meaning: '여섯 륙',
    grade: 3,
    sortOrder: 7,
  ),
];
