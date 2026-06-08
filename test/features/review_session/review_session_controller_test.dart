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
      expect(initial.hanjaToHunQuestions.first.item.id, 'HJ-2');
      expect(initial.hunToHanjaQuestions.first.item.id, 'HJ-2');
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

class _FakeLearningDiagnosticsRepository
    implements LearningDiagnosticsRepository {
  @override
  Future<void> recordPracticeEvent(HanjaPracticeEventInput input) async {}

  @override
  Future<List<HanjaWeaknessRecord>> getActiveWeaknesses({
    required String studentKey,
  }) async => const [];

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
