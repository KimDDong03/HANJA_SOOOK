import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/repositories/content_repository_provider.dart';
import 'package:hanja_soook/data/repositories/learning_progress_repository_provider.dart';
import 'package:hanja_soook/data/repositories/quiz_result_repository_provider.dart';
import 'package:hanja_soook/domain/models/hanja_character.dart';
import 'package:hanja_soook/domain/models/hanja_example.dart';
import 'package:hanja_soook/domain/models/learning_progress_record.dart';
import 'package:hanja_soook/domain/models/learning_result.dart';
import 'package:hanja_soook/domain/models/learning_session.dart';
import 'package:hanja_soook/domain/models/quiz_question.dart';
import 'package:hanja_soook/domain/models/stroke_asset.dart';
import 'package:hanja_soook/domain/repositories/content_repository.dart';
import 'package:hanja_soook/domain/repositories/learning_progress_repository.dart';
import 'package:hanja_soook/domain/repositories/quiz_result_repository.dart';
import 'package:hanja_soook/features/quiz/quiz_controller.dart';

void main() {
  test(
    'QuizController builds hanja-to-hun questions from learned set',
    () async {
      final container = _quizContainer();
      addTearDown(container.dispose);

      final state = await container.read(
        quizProvider(QuizPlayMode.hanjaToHun).future,
      );

      expect(state.mode, QuizPlayMode.hanjaToHun);
      expect(state.questions, hasLength(6));
      expect(state.questions.first.type, QuizQuestionType.meaningChoice);
      expect(state.questions.first.prompt, '山');
      expect(state.questions.first.correctAnswer, '메 산');
      expect(state.questions.first.options, contains('메 산'));
    },
  );

  test(
    'QuizController builds hun-to-hanja questions from learned set',
    () async {
      final container = _quizContainer();
      addTearDown(container.dispose);

      final state = await container.read(
        quizProvider(QuizPlayMode.hunToHanja).future,
      );

      expect(state.mode, QuizPlayMode.hunToHanja);
      expect(state.questions, hasLength(6));
      expect(state.questions.first.type, QuizQuestionType.hanjaChoice);
      expect(state.questions.first.prompt, '메 산');
      expect(state.questions.first.correctAnswer, '山');
      expect(state.questions.first.options, contains('山'));
    },
  );

  test('QuizController mixes both quiz directions', () async {
    final container = _quizContainer();
    addTearDown(container.dispose);

    final state = await container.read(quizProvider(QuizPlayMode.mixed).future);

    expect(state.mode, QuizPlayMode.mixed);
    expect(
      state.questions.map((question) => question.type),
      containsAll([
        QuizQuestionType.meaningChoice,
        QuizQuestionType.hanjaChoice,
      ]),
    );
  });

  test(
    'QuizController unlocks choice quizzes with five learned Hanja',
    () async {
      final container = _quizContainer(
        characters: _characters.take(5).toList(),
      );
      addTearDown(container.dispose);

      final state = await container.read(
        quizProvider(QuizPlayMode.hanjaToHun).future,
      );

      expect(state.canPlay, isTrue);
      expect(state.questions, hasLength(5));
    },
  );
}

ProviderContainer _quizContainer({
  List<HanjaCharacter> characters = _characters,
}) {
  return ProviderContainer(
    overrides: [
      contentRepositoryProvider.overrideWithValue(
        _FakeContentRepository(characters),
      ),
      quizResultRepositoryProvider.overrideWithValue(
        _FakeQuizResultRepository(),
      ),
      learningProgressRepositoryProvider.overrideWithValue(
        _FakeLearningProgressRepository(characters),
      ),
    ],
  );
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
    return characters.where((hanja) => hanja.id == hanjaId).firstOrNull;
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

class _FakeQuizResultRepository implements QuizResultRepository {
  @override
  Future<LearningResult?> getLatestQuizResult({
    required String studentKey,
  }) async {
    return null;
  }

  @override
  Future<LearningResult> saveQuizResult({
    required String studentKey,
    required String learningDate,
    required int score,
    required int correctCount,
    required int totalCount,
    required int timeSec,
  }) async {
    return LearningResult(
      mode: LearningMode.quiz,
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
  HanjaCharacter(
    id: 'HJ-5',
    character: '土',
    sound: '토',
    meaning: '흙 토',
    grade: 3,
  ),
  HanjaCharacter(
    id: 'HJ-6',
    character: '日',
    sound: '일',
    meaning: '날 일',
    grade: 3,
  ),
];
