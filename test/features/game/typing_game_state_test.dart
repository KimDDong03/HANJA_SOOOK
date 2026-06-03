import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/repositories/content_repository_provider.dart';
import 'package:hanja_soook/data/repositories/game_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/learning_diagnostics_repository_provider.dart';
import 'package:hanja_soook/data/repositories/learning_progress_repository_provider.dart';
import 'package:hanja_soook/domain/models/hanja_character.dart';
import 'package:hanja_soook/domain/models/hanja_example.dart';
import 'package:hanja_soook/domain/models/learning_diagnostics.dart';
import 'package:hanja_soook/domain/models/learning_progress_record.dart';
import 'package:hanja_soook/domain/models/learning_result.dart';
import 'package:hanja_soook/domain/models/learning_session.dart';
import 'package:hanja_soook/domain/models/quiz_question.dart';
import 'package:hanja_soook/domain/models/stroke_asset.dart';
import 'package:hanja_soook/domain/repositories/content_repository.dart';
import 'package:hanja_soook/domain/repositories/game_result_repository.dart';
import 'package:hanja_soook/domain/repositories/learning_diagnostics_repository.dart';
import 'package:hanja_soook/domain/repositories/learning_progress_repository.dart';
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

  test('TypingGameController applies wrong answer score penalty', () async {
    final container = ProviderContainer(
      overrides: [
        contentRepositoryProvider.overrideWithValue(
          const _FakeContentRepository(_characters),
        ),
        gameResultRepositoryProvider.overrideWithValue(
          _FakeGameResultRepository(),
        ),
        learningProgressRepositoryProvider.overrideWithValue(
          const _FakeLearningProgressRepository(_characters),
        ),
        learningDiagnosticsRepositoryProvider.overrideWithValue(
          _FakeLearningDiagnosticsRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(typingGameProvider.future);
    final wrongAnswer = initial.currentRound!.options.firstWhere(
      (option) => option != initial.currentRound!.correctAnswer,
    );

    container.read(typingGameProvider.notifier).selectAnswer(wrongAnswer);
    final state = container.read(typingGameProvider).value!;

    expect(state.selectedAnswer, wrongAnswer);
    expect(state.correctCount, 0);
    expect(state.wrongCount, 1);
    expect(state.score, 0);
    expect(state.lastEarnedScore, -5);
  });
}

class _FakeContentRepository implements ContentRepository {
  const _FakeContentRepository(this.characters);

  final List<HanjaCharacter> characters;

  @override
  Future<HanjaCharacter?> getTodayHanja({int? grade}) async => characters.first;

  @override
  Future<List<HanjaCharacter>> getTodayHanjaSet({
    int? grade,
    int limit = 4,
  }) async {
    return characters.take(limit).toList();
  }

  @override
  Future<List<HanjaCharacter>> getHanjaList({int? grade, int? limit}) async {
    return limit == null ? characters : characters.take(limit).toList();
  }

  @override
  Future<List<QuizQuestion>> getTodayQuizQuestions({
    int? grade,
    int limit = 4,
  }) async {
    return const [];
  }

  @override
  Future<HanjaCharacter?> getHanjaById(String hanjaId) async {
    for (final hanja in characters) {
      if (hanja.id == hanjaId) {
        return hanja;
      }
    }
    return null;
  }

  @override
  Future<List<HanjaExample>> getExamples(String hanjaId) async => const [];

  @override
  Future<List<QuizQuestion>> getQuizQuestions({
    int? grade,
    String? unitCode,
    int limit = 10,
  }) async {
    return const [];
  }

  @override
  Future<StrokeAsset?> getStrokeAsset(String hanjaId) async => null;
}

class _FakeGameResultRepository implements GameResultRepository {
  @override
  Future<LearningResult?> getLatestGameResult({
    required String studentKey,
  }) async {
    return null;
  }

  @override
  Future<LearningResult> saveGameResult({
    required String studentKey,
    required String learningDate,
    required int score,
    required int correctCount,
    required int totalCount,
    required int timeSec,
  }) async {
    return LearningResult(
      mode: LearningMode.game,
      score: score,
      correctCount: correctCount,
      totalCount: totalCount,
      timeSec: timeSec,
    );
  }
}

class _FakeLearningProgressRepository implements LearningProgressRepository {
  const _FakeLearningProgressRepository(this.characters);

  final List<HanjaCharacter> characters;

  @override
  Future<bool> addXpEvent({
    required String id,
    required String studentKey,
    required String source,
    required int amount,
    String? refId,
  }) async {
    return true;
  }

  @override
  Future<Set<String>> getCompletedHanjaIds({
    required String studentKey,
    required String learningDate,
  }) async {
    return characters.map((hanja) => hanja.id).toSet();
  }

  @override
  Future<Set<String>> getCompletedHanjaIdsForStudent({
    required String studentKey,
  }) async {
    return characters.map((hanja) => hanja.id).toSet();
  }

  @override
  Future<List<LearningProgressRecord>> getCompletedHanjaRecordsForStudent({
    required String studentKey,
  }) async {
    return const [];
  }

  @override
  Future<int> getTotalXp({required String studentKey}) async => 0;

  @override
  Future<int> getXpForRef({
    required String studentKey,
    required String source,
    required String refId,
  }) async {
    return 0;
  }

  @override
  Future<bool> markHanjaCompleted({
    required String studentKey,
    required String learningDate,
    required String hanjaId,
  }) async {
    return true;
  }
}

class _FakeLearningDiagnosticsRepository
    implements LearningDiagnosticsRepository {
  @override
  Future<List<HanjaPracticeEvent>> getPracticeEventsForHanja({
    required String studentKey,
    required String hanjaId,
  }) async {
    return const [];
  }

  @override
  Future<List<HanjaWeaknessRecord>> getActiveWeaknesses({
    required String studentKey,
  }) async {
    return const [];
  }

  @override
  Future<Map<String, List<HanjaWeaknessRecord>>> getWeaknessesByHanja({
    required String studentKey,
    required Set<String> hanjaIds,
  }) async {
    return const {};
  }

  @override
  Future<void> markWeaknessResolved({
    required String studentKey,
    required String hanjaId,
    required HanjaWeaknessType weaknessType,
  }) async {}

  @override
  Future<void> recordPracticeEvent(HanjaPracticeEventInput input) async {}
}

const _characters = <HanjaCharacter>[
  HanjaCharacter(
    id: 'HJ-1',
    character: '山',
    sound: '산',
    meaning: '메 산',
    grade: 3,
  ),
  HanjaCharacter(
    id: 'HJ-2',
    character: '水',
    sound: '수',
    meaning: '물 수',
    grade: 3,
  ),
  HanjaCharacter(
    id: 'HJ-3',
    character: '木',
    sound: '목',
    meaning: '나무 목',
    grade: 3,
  ),
  HanjaCharacter(
    id: 'HJ-4',
    character: '火',
    sound: '화',
    meaning: '불 화',
    grade: 3,
  ),
];
