import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/domain/models/hanja_character.dart';
import 'package:hanja_soook/domain/models/learning_progress_record.dart';
import 'package:hanja_soook/domain/services/learning_plan_service.dart';

void main() {
  const service = LearningPlanService();

  test('buildDailyPlan puts due reviews before new items', () {
    final plan = service.buildDailyPlan(
      allItems: _items,
      progressRecords: [
        LearningProgressRecord(
          studentKey: 'student-1',
          learningDate: '20260529',
          hanjaId: 'HJ-1',
          completedAt: DateTime(2026, 5, 29),
        ),
      ],
      learningDate: '20260530',
      newItemLimit: 2,
      reviewItemLimit: 2,
    );

    expect(plan.reviewItems.map((item) => item.id), ['HJ-1']);
    expect(plan.newItems.map((item) => item.id), ['HJ-2']);
    expect(plan.items.map((item) => item.id), ['HJ-1', 'HJ-2']);
  });

  test('buildDailyPlan skips reviews already completed today', () {
    final plan = service.buildDailyPlan(
      allItems: _items,
      progressRecords: [
        LearningProgressRecord(
          studentKey: 'student-1',
          learningDate: '20260529',
          hanjaId: 'HJ-1',
          completedAt: DateTime(2026, 5, 29),
        ),
        LearningProgressRecord(
          studentKey: 'student-1',
          learningDate: '20260530',
          hanjaId: 'HJ-1',
          completedAt: DateTime(2026, 5, 30),
        ),
      ],
      learningDate: '20260530',
      newItemLimit: 2,
      reviewItemLimit: 2,
    );

    expect(plan.reviewItems, isEmpty);
    expect(plan.completedCount, 0);
    expect(plan.newItems.map((item) => item.id), ['HJ-2', 'HJ-3']);
  });

  test('buildDailyPlan keeps today new items stable after completion', () {
    final plan = service.buildDailyPlan(
      allItems: _items,
      progressRecords: [
        LearningProgressRecord(
          studentKey: 'student-1',
          learningDate: '20260530',
          hanjaId: 'HJ-1',
          completedAt: DateTime(2026, 5, 30),
        ),
      ],
      learningDate: '20260530',
      newItemLimit: 2,
      reviewItemLimit: 2,
    );

    expect(plan.newItems.map((item) => item.id), ['HJ-1', 'HJ-2']);
    expect(plan.completedCount, 1);
  });

  test('buildDailyPlan uses the whole active chapter as the daily new set', () {
    final plan = service.buildDailyPlan(
      allItems: _chapterItems,
      progressRecords: [
        LearningProgressRecord(
          studentKey: 'student-1',
          learningDate: '20260529',
          hanjaId: 'HJ-1',
          completedAt: DateTime(2026, 5, 29),
        ),
      ],
      learningDate: '20260530',
      newItemLimit: 2,
      reviewItemLimit: 0,
    );

    expect(plan.chapterKey, '3-1');
    expect(plan.newItems.map((item) => item.id), ['HJ-2', 'HJ-3']);
  });

  test('buildDailyPlan can target a selected chapter', () {
    final plan = service.buildDailyPlan(
      allItems: _chapterItems,
      progressRecords: const [],
      learningDate: '20260530',
      newItemLimit: 2,
      reviewItemLimit: 0,
      chapterKey: '3-2',
    );

    expect(plan.chapterKey, '3-2');
    expect(plan.chapterName, '둘째 단원');
    expect(plan.newItems.map((item) => item.id), ['HJ-4']);
  });
}

const _items = [
  HanjaCharacter(
    id: 'HJ-1',
    character: '一',
    sound: '일',
    meaning: '한 일',
    grade: 3,
  ),
  HanjaCharacter(
    id: 'HJ-2',
    character: '二',
    sound: '이',
    meaning: '두 이',
    grade: 3,
  ),
  HanjaCharacter(
    id: 'HJ-3',
    character: '三',
    sound: '삼',
    meaning: '석 삼',
    grade: 3,
  ),
  HanjaCharacter(
    id: 'HJ-4',
    character: '四',
    sound: '사',
    meaning: '넉 사',
    grade: 3,
  ),
];

const _chapterItems = [
  HanjaCharacter(
    id: 'HJ-1',
    character: '一',
    sound: '일',
    meaning: '한 일',
    grade: 3,
    unitCode: '3-1',
    unitName: '첫 단원',
  ),
  HanjaCharacter(
    id: 'HJ-2',
    character: '二',
    sound: '이',
    meaning: '두 이',
    grade: 3,
    unitCode: '3-1',
    unitName: '첫 단원',
  ),
  HanjaCharacter(
    id: 'HJ-3',
    character: '三',
    sound: '삼',
    meaning: '석 삼',
    grade: 3,
    unitCode: '3-1',
    unitName: '첫 단원',
  ),
  HanjaCharacter(
    id: 'HJ-4',
    character: '四',
    sound: '사',
    meaning: '넉 사',
    grade: 3,
    unitCode: '3-2',
    unitName: '둘째 단원',
  ),
];
