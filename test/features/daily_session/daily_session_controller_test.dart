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
}
