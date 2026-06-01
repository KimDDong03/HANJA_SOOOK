import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/features/game/typing_game_controller.dart';

void main() {
  test('TypingGameState exposes score, accuracy, and stars from state', () {
    final state = TypingGameState(
      rounds: const [
        TypingGameRound(
          hanjaId: 'one',
          prompt: '하나',
          correctAnswer: '一',
          options: ['一', '二'],
        ),
        TypingGameRound(
          hanjaId: 'two',
          prompt: '둘',
          correctAnswer: '二',
          options: ['一', '二'],
        ),
      ],
      startedAt: DateTime(2026),
      roundStartedAt: DateTime(2026),
      learnedHanjaCount: 6,
      correctCount: 1,
      wrongCount: 1,
      score: 35,
    );

    expect(state.score, 35);
    expect(state.accuracyPercent, 50);
    expect(state.stars, 1);
  });

  test('TypingGameState gives no stars without correct answers', () {
    final state = TypingGameState(
      rounds: const [
        TypingGameRound(
          hanjaId: 'one',
          prompt: '하나',
          correctAnswer: '一',
          options: ['一', '二'],
        ),
      ],
      startedAt: DateTime(2026),
      roundStartedAt: DateTime(2026),
      learnedHanjaCount: 6,
      wrongCount: 3,
    );

    expect(state.score, 0);
    expect(state.accuracyPercent, 0);
    expect(state.stars, 0);
  });
}
