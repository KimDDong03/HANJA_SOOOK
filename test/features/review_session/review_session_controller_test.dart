import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/repositories/content_repository_provider.dart';
import 'package:hanja_soook/data/repositories/learning_diagnostics_repository_provider.dart';
import 'package:hanja_soook/data/repositories/learning_progress_repository_provider.dart';
import 'package:hanja_soook/domain/models/hanja_character.dart';
import 'package:hanja_soook/domain/models/hanja_example.dart';
import 'package:hanja_soook/domain/models/learning_diagnostics.dart';
import 'package:hanja_soook/domain/models/learning_progress_record.dart';
import 'package:hanja_soook/domain/models/quiz_question.dart';
import 'package:hanja_soook/domain/models/stroke_asset.dart';
import 'package:hanja_soook/domain/repositories/content_repository.dart';
import 'package:hanja_soook/domain/repositories/learning_diagnostics_repository.dart';
import 'package:hanja_soook/domain/repositories/learning_progress_repository.dart';
import 'package:hanja_soook/features/review_session/review_session_controller.dart';
import 'package:hanja_soook/features/review_session/review_session_screen.dart';

void main() {
  test(
    'review session starts from selected hanja and keeps in-progress state',
    () async {
      final container = ProviderContainer(
        overrides: [
          contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
          learningProgressRepositoryProvider.overrideWithValue(
            _FakeLearningProgressRepository(),
          ),
          learningDiagnosticsRepositoryProvider.overrideWithValue(
            _FakeLearningDiagnosticsRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final provider = reviewSessionProvider('HJ-2');
      final subscription = container.listen(
        provider,
        (_, _) {},
        fireImmediately: true,
      );
      final initial = await container.read(provider.future);

      expect(initial.items.first.id, 'HJ-2');
      expect(initial.quizQuestions.first.item.id, 'HJ-2');
      expect(initial.svgPathsFor('HJ-2'), isNotEmpty);

      final correctAnswer = initial.currentQuestion!.correctAnswer;
      await container.read(provider.notifier).selectAnswer(correctAnswer);
      expect(container.read(provider).value!.selectedAnswer, correctAnswer);

      subscription.close();
      await Future<void>.delayed(Duration.zero);

      final resumedSubscription = container.listen(
        provider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(resumedSubscription.close);

      expect(container.read(provider).value!.selectedAnswer, correctAnswer);
    },
  );

  test(
    'review session shuffles answer positions and requeues missed items',
    () async {
      final container = ProviderContainer(
        overrides: [
          contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
          learningProgressRepositoryProvider.overrideWithValue(
            _FakeLearningProgressRepository(),
          ),
          learningDiagnosticsRepositoryProvider.overrideWithValue(
            _FakeLearningDiagnosticsRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final provider = reviewSessionProvider(null);
      final initial = await container.read(provider.future);
      final correctPositions = [
        for (final question in initial.quizQuestions)
          question.options.indexOf(question.correctAnswer),
      ];

      expect(correctPositions.toSet().length, greaterThan(1));

      final firstQuestion = initial.currentQuestion!;
      final wrongAnswer = firstQuestion.options.firstWhere(
        (option) => option != firstQuestion.correctAnswer,
      );
      await container.read(provider.notifier).selectAnswer(wrongAnswer);

      final afterWrong = container.read(provider).value!;
      expect(afterWrong.quizQuestions.length, initial.quizQuestions.length + 1);
      expect(afterWrong.missedHanjaIds, contains(firstQuestion.item.id));
      expect(
        afterWrong.quizQuestions.skip(1).any((question) {
          return question.item.id == firstQuestion.item.id && question.isRetry;
        }),
        isTrue,
      );
    },
  );

  test('writing phase includes every review item after quiz', () async {
    final progressRepository = _FakeLearningProgressRepository();
    final container = ProviderContainer(
      overrides: [
        contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
        learningProgressRepositoryProvider.overrideWithValue(
          progressRepository,
        ),
        learningDiagnosticsRepositoryProvider.overrideWithValue(
          _FakeLearningDiagnosticsRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final provider = reviewSessionProvider(null);
    var state = await container.read(provider.future);
    while (state.phase == ReviewSessionPhase.quiz) {
      await container
          .read(provider.notifier)
          .selectAnswer(state.currentQuestion!.correctAnswer);
      await container.read(provider.notifier).next();
      state = container.read(provider).value!;
    }

    expect(state.phase, ReviewSessionPhase.writing);
    expect(
      state.writingItems.map((item) => item.id),
      state.items.map((item) => item.id),
    );

    while (state.phase == ReviewSessionPhase.writing) {
      final item = state.currentWritingItem!;
      container.read(provider.notifier).markWritingPassed(item.id);
      await container.read(provider.notifier).completeWriting();
      state = container.read(provider).value!;
    }

    expect(state.phase, ReviewSessionPhase.complete);
    expect(
      progressRepository.markedHanjaIds,
      state.items.map((item) => item.id),
    );
  });

  test('review writing requires a passed check before completion', () async {
    final diagnosticsRepository = _FakeLearningDiagnosticsRepository(
      activeWeaknesses: [_writingWeakness('HJ-2')],
    );
    final container = ProviderContainer(
      overrides: [
        contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
        learningProgressRepositoryProvider.overrideWithValue(
          _FakeLearningProgressRepository(),
        ),
        learningDiagnosticsRepositoryProvider.overrideWithValue(
          diagnosticsRepository,
        ),
      ],
    );
    addTearDown(container.dispose);

    final provider = reviewSessionProvider('HJ-2');
    var state = await container.read(provider.future);
    while (state.phase == ReviewSessionPhase.quiz) {
      await container
          .read(provider.notifier)
          .selectAnswer(state.currentQuestion!.correctAnswer);
      await container.read(provider.notifier).next();
      state = container.read(provider).value!;
    }

    expect(state.phase, ReviewSessionPhase.writing);
    expect(state.currentWritingItem!.id, 'HJ-2');

    await container.read(provider.notifier).recordWritingFailure();
    state = container.read(provider).value!;

    expect(state.phase, ReviewSessionPhase.writing);
    expect(state.missedHanjaIds, contains('HJ-2'));
    expect(
      diagnosticsRepository.events.last.result,
      HanjaPracticeResult.failed,
    );

    final eventCountBeforeBlockedComplete = diagnosticsRepository.events.length;
    await container.read(provider.notifier).completeWriting();
    state = container.read(provider).value!;

    expect(state.phase, ReviewSessionPhase.writing);
    expect(
      diagnosticsRepository.events.length,
      eventCountBeforeBlockedComplete,
    );

    container.read(provider.notifier).markWritingPassed('HJ-2');
    await container.read(provider.notifier).completeWriting();
    state = container.read(provider).value!;

    expect(state.phase, ReviewSessionPhase.writing);
    expect(state.currentWritingItem!.id, isNot('HJ-2'));
    expect(state.passedHanjaIds, contains('HJ-2'));
    expect(
      diagnosticsRepository.events.last.result,
      HanjaPracticeResult.correct,
    );

    while (state.phase == ReviewSessionPhase.writing) {
      final item = state.currentWritingItem!;
      container.read(provider.notifier).markWritingPassed(item.id);
      await container.read(provider.notifier).completeWriting();
      state = container.read(provider).value!;
    }

    expect(state.phase, ReviewSessionPhase.complete);
  });

  testWidgets('review writing prompt hides the Hanja answer', (tester) async {
    final container = ProviderContainer(
      overrides: [
        contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
        learningProgressRepositoryProvider.overrideWithValue(
          _FakeLearningProgressRepository(),
        ),
        learningDiagnosticsRepositoryProvider.overrideWithValue(
          _FakeLearningDiagnosticsRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final provider = reviewSessionProvider('HJ-2');
    var state = await container.read(provider.future);
    while (state.phase == ReviewSessionPhase.quiz) {
      await container
          .read(provider.notifier)
          .selectAnswer(state.currentQuestion!.correctAnswer);
      await container.read(provider.notifier).next();
      state = container.read(provider).value!;
    }

    expect(state.phase, ReviewSessionPhase.writing);
    expect(state.currentWritingItem!.id, 'HJ-2');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: ReviewSessionScreen(focusHanjaId: 'HJ-2'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('뜻과 소리를 보고 직접 써요'), findsNothing);
    expect(find.text('두 이'), findsWidgets);
    expect(find.text('二'), findsNothing);
  });
}

class _FakeContentRepository implements ContentRepository {
  @override
  Future<HanjaCharacter?> getTodayHanja({int? grade}) async => _items.first;

  @override
  Future<List<HanjaCharacter>> getTodayHanjaSet({
    int? grade,
    int limit = 4,
  }) async => _items.take(limit).toList();

  @override
  Future<List<HanjaCharacter>> getHanjaList({int? grade, int? limit}) async {
    return limit == null ? _items : _items.take(limit).toList();
  }

  @override
  Future<HanjaCharacter?> getHanjaById(String hanjaId) async {
    return _items.where((item) => item.id == hanjaId).firstOrNull;
  }

  @override
  Future<List<HanjaExample>> getExamples(String hanjaId) async => const [];

  @override
  Future<List<QuizQuestion>> getQuizQuestions({
    int? grade,
    String? unitCode,
    int limit = 10,
  }) async => const [];

  @override
  Future<List<QuizQuestion>> getTodayQuizQuestions({
    int? grade,
    int limit = 4,
  }) async => const [];

  @override
  Future<StrokeAsset?> getStrokeAsset(String hanjaId) async {
    final item = await getHanjaById(hanjaId);
    if (item == null) {
      return null;
    }
    return StrokeAsset(
      hanjaId: hanjaId,
      character: item.character,
      strokeCount: item.strokeCount,
      svgPaths: const ['M 10 10 L 90 10'],
      reviewStatus: StrokeReviewStatus.available,
    );
  }
}

class _FakeLearningProgressRepository implements LearningProgressRepository {
  final markedHanjaIds = <String>[];

  @override
  Future<Set<String>> getCompletedHanjaIds({
    required String studentKey,
    required String learningDate,
  }) async => const {};

  @override
  Future<Set<String>> getCompletedHanjaIdsForStudent({
    required String studentKey,
  }) async => _items.map((item) => item.id).toSet();

  @override
  Future<List<LearningProgressRecord>> getCompletedHanjaRecordsForStudent({
    required String studentKey,
  }) async {
    return [
      for (final item in _items)
        LearningProgressRecord(
          studentKey: studentKey,
          learningDate: '20260601',
          hanjaId: item.id,
          completedAt: DateTime(2026, 6, 1),
        ),
    ];
  }

  @override
  Future<bool> markHanjaCompleted({
    required String studentKey,
    required String learningDate,
    required String hanjaId,
  }) async {
    markedHanjaIds.add(hanjaId);
    return true;
  }

  @override
  Future<bool> addXpEvent({
    required String id,
    required String studentKey,
    required String source,
    required int amount,
    String? refId,
  }) async => true;

  @override
  Future<int> getTotalXp({required String studentKey}) async => 0;

  @override
  Future<int> getXpForRef({
    required String studentKey,
    required String source,
    required String refId,
  }) async => 0;
}

class _FakeLearningDiagnosticsRepository
    implements LearningDiagnosticsRepository {
  _FakeLearningDiagnosticsRepository({this.activeWeaknesses = const []});

  final List<HanjaWeaknessRecord> activeWeaknesses;
  final events = <HanjaPracticeEventInput>[];

  @override
  Future<void> recordPracticeEvent(HanjaPracticeEventInput input) async {
    events.add(input);
  }

  @override
  Future<List<HanjaWeaknessRecord>> getActiveWeaknesses({
    required String studentKey,
  }) async => activeWeaknesses;

  @override
  Future<Map<String, List<HanjaWeaknessRecord>>> getWeaknessesByHanja({
    required String studentKey,
    required Set<String> hanjaIds,
  }) async => const {};

  @override
  Future<void> markWeaknessResolved({
    required String studentKey,
    required String hanjaId,
    required HanjaWeaknessType weaknessType,
  }) async {}

  @override
  Future<List<HanjaPracticeEvent>> getPracticeEventsForHanja({
    required String studentKey,
    required String hanjaId,
  }) async => const [];
}

HanjaWeaknessRecord _writingWeakness(String hanjaId) {
  final now = DateTime(2026, 6, 8);
  return HanjaWeaknessRecord(
    studentKey: 'local-student',
    hanjaId: hanjaId,
    weaknessType: HanjaWeaknessType.writing,
    score: 6,
    status: HanjaWeaknessStatus.active,
    mistakeCount: 2,
    successStreak: 0,
    lastEventAt: now,
    createdAt: now,
    updatedAt: now,
  );
}

const _items = [
  HanjaCharacter(
    id: 'HJ-1',
    character: '一',
    sound: '일',
    meaning: '한 일',
    strokeCount: 1,
    grade: 3,
  ),
  HanjaCharacter(
    id: 'HJ-2',
    character: '二',
    sound: '이',
    meaning: '두 이',
    strokeCount: 2,
    grade: 3,
  ),
  HanjaCharacter(
    id: 'HJ-3',
    character: '三',
    sound: '삼',
    meaning: '석 삼',
    strokeCount: 3,
    grade: 3,
  ),
  HanjaCharacter(
    id: 'HJ-4',
    character: '四',
    sound: '사',
    meaning: '넉 사',
    strokeCount: 5,
    grade: 3,
  ),
  HanjaCharacter(
    id: 'HJ-5',
    character: '五',
    sound: '오',
    meaning: '다섯 오',
    strokeCount: 4,
    grade: 3,
  ),
  HanjaCharacter(
    id: 'HJ-6',
    character: '六',
    sound: '륙',
    meaning: '여섯 륙',
    strokeCount: 4,
    grade: 3,
  ),
];

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
