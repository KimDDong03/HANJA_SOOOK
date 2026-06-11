import 'dart:ui';

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
import 'package:hanja_soook/features/weakness_session/weakness_session_controller.dart';

void main() {
  test('focus session requeues a missed choice and records feedback', () async {
    final diagnosticsRepository = _FakeLearningDiagnosticsRepository(
      activeWeaknesses: [_weakness('HJ-2', HanjaWeaknessType.hanjaRecognition)],
    );
    final container = ProviderContainer(
      overrides: [
        contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
        learningDiagnosticsRepositoryProvider.overrideWithValue(
          diagnosticsRepository,
        ),
        learningProgressRepositoryProvider.overrideWithValue(
          _FakeLearningProgressRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final provider = weaknessSessionProvider('HJ-2');
    final initial = await container.read(provider.future);
    final firstTask = initial.currentTask!;
    final wrongAnswer = firstTask.options.firstWhere(
      (option) => option != firstTask.correctAnswer,
    );

    expect(firstTask.item.id, 'HJ-2');
    expect(firstTask.kind, WeaknessTaskKind.hunToHanja);
    expect(firstTask.prompt, '두 이');
    expect(firstTask.correctAnswer, '二');

    await container.read(provider.notifier).selectAnswer(wrongAnswer);

    final afterWrong = container.read(provider).value!;
    expect(afterWrong.selectedAnswer, wrongAnswer);
    expect(afterWrong.tasks.length, initial.tasks.length + 1);
    expect(afterWrong.failedHanjaIds, contains('HJ-2'));
    expect(
      diagnosticsRepository.events.last.result,
      HanjaPracticeResult.incorrect,
    );
    expect(
      afterWrong.tasks.skip(1).any((task) {
        return task.item.id == firstTask.item.id &&
            task.kind == firstTask.kind &&
            task.isRetry;
      }),
      isTrue,
    );
  });

  test(
    'focus session answer positions are not fixed to the first slot',
    () async {
      final diagnosticsRepository = _FakeLearningDiagnosticsRepository(
        activeWeaknesses: [
          _weakness('HJ-1', HanjaWeaknessType.hanjaRecognition),
          _weakness('HJ-2', HanjaWeaknessType.hunMeaning),
          _weakness('HJ-3', HanjaWeaknessType.hanjaRecognition),
          _weakness('HJ-4', HanjaWeaknessType.hunMeaning),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
          learningDiagnosticsRepositoryProvider.overrideWithValue(
            diagnosticsRepository,
          ),
          learningProgressRepositoryProvider.overrideWithValue(
            _FakeLearningProgressRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final initial = await container.read(
        weaknessSessionProvider(null).future,
      );
      final correctPositions = [
        for (final task in initial.tasks.where(
          (task) => task.kind != WeaknessTaskKind.writing,
        ))
          task.options.indexOf(task.correctAnswer),
      ];

      expect(correctPositions, isNotEmpty);
      expect(correctPositions.toSet().length, greaterThan(1));
    },
  );

  test('selected focus session only includes the selected Hanja', () async {
    final diagnosticsRepository = _FakeLearningDiagnosticsRepository(
      activeWeaknesses: [
        _weakness('HJ-1', HanjaWeaknessType.hanjaRecognition),
        _weakness('HJ-2', HanjaWeaknessType.hunMeaning),
        _weakness('HJ-3', HanjaWeaknessType.writing),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
        learningDiagnosticsRepositoryProvider.overrideWithValue(
          diagnosticsRepository,
        ),
        learningProgressRepositoryProvider.overrideWithValue(
          _FakeLearningProgressRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(
      weaknessSessionProvider('HJ-2').future,
    );

    expect(initial.hanjaCount, 1);
    expect(initial.tasks, isNotEmpty);
    expect(initial.tasks.every((task) => task.item.id == 'HJ-2'), isTrue);
  });

  test('focus writing requires a passed check before completion', () async {
    final diagnosticsRepository = _FakeLearningDiagnosticsRepository(
      activeWeaknesses: [_weakness('HJ-2', HanjaWeaknessType.writing)],
    );
    final container = ProviderContainer(
      overrides: [
        contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
        learningDiagnosticsRepositoryProvider.overrideWithValue(
          diagnosticsRepository,
        ),
        learningProgressRepositoryProvider.overrideWithValue(
          _FakeLearningProgressRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final provider = weaknessSessionProvider('HJ-2');
    var state = await container.read(provider.future);
    final writingTask = state.currentTask!;

    expect(writingTask.kind, WeaknessTaskKind.writing);
    expect(writingTask.prompt, '두 이');
    expect(writingTask.correctAnswer, '二');

    await container.read(provider.notifier).completeWriting();
    state = container.read(provider).value!;

    expect(state.passedTaskKeys, isNot(contains(writingTask.key)));
    expect(diagnosticsRepository.events, isEmpty);

    await container.read(provider.notifier).recordWritingFailure();
    state = container.read(provider).value!;

    expect(state.passedTaskKeys, isNot(contains(writingTask.key)));
    expect(state.failedHanjaIds, contains('HJ-2'));
    expect(
      diagnosticsRepository.events.last.result,
      HanjaPracticeResult.failed,
    );

    container.read(provider.notifier).markWritingPassed('HJ-2');
    await container.read(provider.notifier).completeWriting();
    state = container.read(provider).value!;

    expect(state.passedTaskKeys, contains(writingTask.key));
    expect(
      diagnosticsRepository.events.last.result,
      HanjaPracticeResult.correct,
    );

    container
        .read(provider.notifier)
        .saveWritingStrokes(hanjaId: 'HJ-2', strokes: [Path()..lineTo(10, 10)]);
    state = container.read(provider).value!;

    expect(state.passedTaskKeys, isNot(contains(writingTask.key)));
    expect(state.writingPassedTaskKeys, isNot(contains(writingTask.key)));
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

  @override
  Future<Set<String>> getReviewCompletedHanjaIds({
    required String studentKey,
    required String learningDate,
  }) async => const {};
}

class _FakeLearningProgressRepository implements LearningProgressRepository {
  @override
  Future<Set<String>> getCompletedHanjaIds({
    required String studentKey,
    required String learningDate,
  }) async => const {};

  @override
  Future<Set<String>> getCompletedHanjaIdsForStudent({
    required String studentKey,
  }) async => const {};

  @override
  Future<List<LearningProgressRecord>> getCompletedHanjaRecordsForStudent({
    required String studentKey,
  }) async => const [];

  @override
  Future<bool> markHanjaCompleted({
    required String studentKey,
    required String learningDate,
    required String hanjaId,
  }) async => true;

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

HanjaWeaknessRecord _weakness(String hanjaId, HanjaWeaknessType weaknessType) {
  final now = DateTime(2026, 6, 9);
  return HanjaWeaknessRecord(
    studentKey: 'local-student',
    hanjaId: hanjaId,
    weaknessType: weaknessType,
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
