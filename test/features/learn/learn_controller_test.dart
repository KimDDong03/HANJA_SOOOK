import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/domain/models/hanja_character.dart';
import 'package:hanja_soook/domain/models/learning_diagnostics.dart';
import 'package:hanja_soook/domain/services/learning_plan_service.dart';
import 'package:hanja_soook/features/learn/learn_controller.dart';

void main() {
  group('LearnLibraryState', () {
    test('prioritizes review items as the primary study action', () {
      final state = LearnLibraryState(
        grade: 3,
        items: _hanjaList,
        todayCompletedIds: const {},
        completedHanjaIds: const {'HJ-1'},
        reviewItems: const [_one],
        chapters: const [],
        activeChapterKey: null,
      );

      expect(state.primaryItem, _one);
      expect(state.hasReviewDue, isTrue);
      expect(state.hasPendingItems, isTrue);
      expect(state.weakItems, isEmpty);
      expect(state.statusOf('HJ-1'), LearnItemStatus.reviewDue);
      expect(state.statusOf('HJ-2'), LearnItemStatus.notLearned);
    });

    test('uses active weakness records separately from review items', () {
      final state = LearnLibraryState(
        grade: 3,
        items: _hanjaList,
        todayCompletedIds: const {},
        completedHanjaIds: const {'HJ-1', 'HJ-2'},
        reviewItems: const [_one],
        weaknessesByHanja: {
          'HJ-2': [
            HanjaWeaknessRecord(
              studentKey: 'student-1',
              hanjaId: 'HJ-2',
              weaknessType: HanjaWeaknessType.hanjaRecognition,
              score: 4,
              status: HanjaWeaknessStatus.active,
              mistakeCount: 2,
              successStreak: 0,
              lastEventAt: _date,
              createdAt: _date,
              updatedAt: _date,
            ),
          ],
        },
        chapters: const [],
        activeChapterKey: null,
      );

      expect(state.weakItems, const [_two]);
      expect(state.statusOf('HJ-1'), LearnItemStatus.reviewDue);
      expect(state.statusOf('HJ-2'), LearnItemStatus.weak);
      expect(state.primaryWeaknessFor('HJ-2')?.score, 4);
    });

    test('uses the next unlearned item when there are no reviews', () {
      final state = LearnLibraryState(
        grade: 3,
        items: _hanjaList,
        todayCompletedIds: const {},
        completedHanjaIds: const {'HJ-1'},
        reviewItems: const [],
        chapters: const [],
        activeChapterKey: null,
      );

      expect(state.primaryItem, _two);
      expect(state.hasReviewDue, isFalse);
      expect(state.hasPendingItems, isTrue);
      expect(state.statusOf('HJ-1'), LearnItemStatus.learned);
      expect(state.statusOf('HJ-2'), LearnItemStatus.notLearned);
    });

    test(
      'uses the primary item chapter when today completion advanced ahead',
      () {
        final state = LearnLibraryState(
          grade: 3,
          items: _hanjaList,
          todayCompletedIds: const {'HJ-1', 'HJ-2'},
          completedHanjaIds: const {'HJ-1', 'HJ-2'},
          reviewItems: const [],
          chapters: const [
            HanjaChapter(key: '3-1', name: '첫 단원', items: [_one, _two]),
            HanjaChapter(key: '3-2', name: '둘째 단원', items: [_three]),
          ],
          activeChapterKey: '3-1',
        );

        expect(state.primaryItem, _three);
        expect(state.activeChapter?.key, '3-1');
        expect(state.primaryChapter?.key, '3-2');
        expect(state.primaryChapterKey, '3-2');
      },
    );
  });
}

const _one = HanjaCharacter(
  id: 'HJ-1',
  character: '一',
  sound: '일',
  meaning: '한 일',
  grade: 3,
  unitCode: '3-1',
  unitName: '첫 단원',
);

const _two = HanjaCharacter(
  id: 'HJ-2',
  character: '二',
  sound: '이',
  meaning: '두 이',
  grade: 3,
  unitCode: '3-1',
  unitName: '첫 단원',
);

const _three = HanjaCharacter(
  id: 'HJ-3',
  character: '三',
  sound: '삼',
  meaning: '석 삼',
  grade: 3,
  unitCode: '3-2',
  unitName: '둘째 단원',
);

const _hanjaList = [_one, _two, _three];
final _date = DateTime(2026, 6, 3);
