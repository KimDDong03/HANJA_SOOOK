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
import 'package:hanja_soook/features/growth/growth_controller.dart';
import 'package:hanja_soook/features/learning/learning_progress_controller.dart';

void main() {
  test('growth reloads total XP when learning progress tick changes', () async {
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

    var state = await container.read(growthProvider.future);
    expect(state.totalXp, 0);

    progressRepository.totalXp = 130;
    container.read(learningProgressTickProvider.notifier).increase();

    state = await container.read(growthProvider.future);
    expect(state.totalXp, 130);
    expect(state.level, 2);
  });
}

class _FakeLearningDiagnosticsRepository
    implements LearningDiagnosticsRepository {
  @override
  Future<List<HanjaWeaknessRecord>> getActiveWeaknesses({
    required String studentKey,
  }) async => const [];

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
  Future<void> recordPracticeEvent(HanjaPracticeEventInput input) async {}
}

class _FakeContentRepository implements ContentRepository {
  final _items = const [
    HanjaCharacter(
      id: 'HJ-1',
      character: '一',
      sound: '일',
      meaning: '한 일',
      grade: 3,
      unitCode: '3-1',
      sortOrder: 1,
    ),
    HanjaCharacter(
      id: 'HJ-2',
      character: '二',
      sound: '이',
      meaning: '두 이',
      grade: 3,
      unitCode: '3-1',
      sortOrder: 2,
    ),
  ];

  @override
  Future<List<HanjaCharacter>> getHanjaList({int? grade, int? limit}) async {
    return _items;
  }

  @override
  Future<List<HanjaCharacter>> getTodayHanjaSet({
    int? grade,
    int limit = 4,
  }) async {
    return _items.take(limit).toList();
  }

  @override
  Future<HanjaCharacter?> getTodayHanja({int? grade}) async => _items.first;

  @override
  Future<HanjaCharacter?> getHanjaById(String hanjaId) async {
    for (final item in _items) {
      if (item.id == hanjaId) {
        return item;
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
  Future<List<QuizQuestion>> getTodayQuizQuestions({
    int? grade,
    int limit = 4,
  }) async {
    return const [];
  }

  @override
  Future<StrokeAsset?> getStrokeAsset(String hanjaId) async => null;
}

class _FakeLearningProgressRepository implements LearningProgressRepository {
  int totalXp = 0;

  @override
  Future<Set<String>> getCompletedHanjaIds({
    required String studentKey,
    required String learningDate,
  }) async {
    return const {};
  }

  @override
  Future<Set<String>> getCompletedHanjaIdsForStudent({
    required String studentKey,
  }) async {
    return const {};
  }

  @override
  Future<List<LearningProgressRecord>> getCompletedHanjaRecordsForStudent({
    required String studentKey,
  }) async {
    return const [];
  }

  @override
  Future<bool> markHanjaCompleted({
    required String studentKey,
    required String learningDate,
    required String hanjaId,
  }) async {
    return true;
  }

  @override
  Future<bool> addXpEvent({
    required String id,
    required String studentKey,
    required String source,
    required int amount,
    String? refId,
  }) async {
    totalXp += amount;
    return true;
  }

  @override
  Future<int> getTotalXp({required String studentKey}) async => totalXp;

  @override
  Future<int> getXpForRef({
    required String studentKey,
    required String source,
    required String refId,
  }) async {
    return 0;
  }
}
