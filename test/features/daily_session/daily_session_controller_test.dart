import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/domain/models/hanja_character.dart';
import 'package:hanja_soook/features/daily_session/daily_session_controller.dart';

void main() {
  test(
    'daily quiz keeps the question open until the correct answer is chosen',
    () {
      const item = HanjaCharacter(
        id: 'HJ-0001',
        character: '一',
        sound: '일',
        meaning: '하나',
        strokeCount: 1,
        grade: 3,
      );
      const question = DailyQuizQuestion(
        kind: DailyQuizKind.hanjaToHun,
        item: item,
        prompt: '一',
        correctAnswer: '하나',
        options: ['둘', '하나'],
      );
      const state = DailySessionState(
        items: [item],
        strokeAssets: {},
        hanjaToHunQuestions: [question],
        hunToHanjaQuestions: [],
        randomWritingItems: [item],
        phase: DailySessionPhase.hanjaToHunQuiz,
      );

      final afterWrong = state.answerQuiz('둘');

      expect(afterWrong.selectedAnswer, isNull);
      expect(afterWrong.incorrectAnswer, '둘');
      expect(afterWrong.currentQuestionHadMistake, isTrue);
      expect(afterWrong.correctCount, 0);
      expect(afterWrong.missedHanjaIds, contains('HJ-0001'));

      final afterCorrect = afterWrong.answerQuiz('하나');

      expect(afterCorrect.selectedAnswer, '하나');
      expect(afterCorrect.incorrectAnswer, isNull);
      expect(afterCorrect.correctCount, 0);
      expect(afterCorrect.missedHanjaIds, contains('HJ-0001'));
    },
  );

  test('daily quiz counts a first-try correct answer', () {
    const item = HanjaCharacter(
      id: 'HJ-0001',
      character: '一',
      sound: '일',
      meaning: '하나',
      strokeCount: 1,
      grade: 3,
    );
    const question = DailyQuizQuestion(
      kind: DailyQuizKind.hanjaToHun,
      item: item,
      prompt: '一',
      correctAnswer: '하나',
      options: ['둘', '하나'],
    );
    const state = DailySessionState(
      items: [item],
      strokeAssets: {},
      hanjaToHunQuestions: [question],
      hunToHanjaQuestions: [],
      randomWritingItems: [item],
      phase: DailySessionPhase.hanjaToHunQuiz,
    );

    final afterCorrect = state.answerQuiz('하나');

    expect(afterCorrect.selectedAnswer, '하나');
    expect(afterCorrect.correctCount, 1);
    expect(afterCorrect.missedHanjaIds, isEmpty);
  });

  test('daily quiz keeps a correct answer after phase changes', () {
    const item = HanjaCharacter(
      id: 'HJ-0001',
      character: '一',
      sound: '일',
      meaning: '하나',
      strokeCount: 1,
      grade: 3,
    );
    const question = DailyQuizQuestion(
      kind: DailyQuizKind.hanjaToHun,
      item: item,
      prompt: '一',
      correctAnswer: '하나',
      options: ['둘', '하나'],
    );
    const state = DailySessionState(
      items: [item],
      strokeAssets: {},
      hanjaToHunQuestions: [question],
      hunToHanjaQuestions: [],
      randomWritingItems: [item],
      phase: DailySessionPhase.hanjaToHunQuiz,
    );

    final afterCorrect = state.answerQuiz('하나');
    final afterPhaseChange = afterCorrect.copyWith(
      phase: DailySessionPhase.randomWriting,
      index: 0,
    );

    expect(
      afterPhaseChange.quizSelectedAnswers,
      containsPair('hanjaToHun:HJ-0001', '하나'),
    );
  });

  test('guided writing keeps per-hanja completion in session state', () {
    const first = HanjaCharacter(
      id: 'HJ-0001',
      character: '一',
      sound: '일',
      meaning: '하나',
      strokeCount: 1,
      grade: 3,
    );
    const second = HanjaCharacter(
      id: 'HJ-0002',
      character: '二',
      sound: '이',
      meaning: '둘',
      strokeCount: 2,
      grade: 3,
    );
    const state = DailySessionState(
      items: [first, second],
      strokeAssets: {},
      hanjaToHunQuestions: [],
      hunToHanjaQuestions: [],
      randomWritingItems: [second, first],
      phase: DailySessionPhase.guidedWriting,
    );

    final afterFirst = state.markGuidedWritingComplete(first.id);
    final afterPhaseChange = afterFirst.copyWith(
      phase: DailySessionPhase.hanjaToHunQuiz,
      index: 0,
    );

    expect(afterPhaseChange.isGuidedWritingComplete(first.id), isTrue);
    expect(afterPhaseChange.isGuidedWritingComplete(second.id), isFalse);

    final afterAll = afterPhaseChange.markGuidedWritingComplete(second.id);

    expect(afterAll.guidedWritingCompleted, isTrue);
  });

  test('random writing keeps per-hanja completion in session state', () {
    const first = HanjaCharacter(
      id: 'HJ-0001',
      character: '一',
      sound: '일',
      meaning: '하나',
      strokeCount: 1,
      grade: 3,
    );
    const second = HanjaCharacter(
      id: 'HJ-0002',
      character: '二',
      sound: '이',
      meaning: '둘',
      strokeCount: 2,
      grade: 3,
    );
    const state = DailySessionState(
      items: [first, second],
      strokeAssets: {},
      hanjaToHunQuestions: [],
      hunToHanjaQuestions: [],
      randomWritingItems: [second, first],
      phase: DailySessionPhase.randomWriting,
    );

    final afterSecond = state.markRandomWritingComplete(second.id);
    final afterPhaseChange = afterSecond.copyWith(
      phase: DailySessionPhase.guidedWriting,
      index: 0,
    );

    expect(afterPhaseChange.isRandomWritingComplete(second.id), isTrue);
    expect(afterPhaseChange.isRandomWritingComplete(first.id), isFalse);

    final afterAll = afterPhaseChange.markRandomWritingComplete(first.id);

    expect(afterAll.randomWritingCompleted, isTrue);
  });

  test('random writing keeps saved strokes in session state', () {
    const item = HanjaCharacter(
      id: 'HJ-0001',
      character: '一',
      sound: '일',
      meaning: '하나',
      strokeCount: 1,
      grade: 3,
    );
    const state = DailySessionState(
      items: [item],
      strokeAssets: {},
      hanjaToHunQuestions: [],
      hunToHanjaQuestions: [],
      randomWritingItems: [item],
      phase: DailySessionPhase.randomWriting,
    );
    final stroke = Path()
      ..moveTo(0, 0)
      ..lineTo(10, 10);

    final afterStroke = state.saveRandomWritingStrokes(item.id, [stroke]);
    final afterPhaseChange = afterStroke.copyWith(
      phase: DailySessionPhase.guidedWriting,
      index: 0,
    );

    expect(afterPhaseChange.randomWritingStrokesFor(item.id), hasLength(1));
  });

  test('random writing can advance only after the current hanja passes', () {
    const first = HanjaCharacter(
      id: 'HJ-0001',
      character: '一',
      sound: '일',
      meaning: '하나',
      strokeCount: 1,
      grade: 3,
    );
    const second = HanjaCharacter(
      id: 'HJ-0002',
      character: '二',
      sound: '이',
      meaning: '둘',
      strokeCount: 2,
      grade: 3,
    );
    const state = DailySessionState(
      items: [first, second],
      strokeAssets: {},
      hanjaToHunQuestions: [],
      hunToHanjaQuestions: [],
      randomWritingItems: [first, second],
      phase: DailySessionPhase.randomWriting,
    );

    expect(state.canAdvanceCurrentRandomWriting, isFalse);

    final afterPass = state.markRandomWritingComplete(first.id);

    expect(afterPass.canAdvanceCurrentRandomWriting, isTrue);
  });
}
