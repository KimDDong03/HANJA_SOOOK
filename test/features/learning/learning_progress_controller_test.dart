import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/repositories/learning_progress_repository_provider.dart';
import 'package:hanja_soook/domain/models/learning_progress_record.dart';
import 'package:hanja_soook/domain/repositories/learning_progress_repository.dart';
import 'package:hanja_soook/features/learning/learning_progress_controller.dart';

void main() {
  test('does not award XP for a hanja already completed before', () async {
    final repository = _FakeLearningProgressRepository(
      completedForStudent: {'HJ-1'},
    );
    final container = ProviderContainer(
      overrides: [
        learningProgressRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(learningProgressControllerProvider)
        .markHanjaCompleted(hanjaId: 'HJ-1', todayHanjaIds: {'HJ-1'});

    expect(result.earnedXp, 0);
    expect(repository.xpEvents, isEmpty);
  });

  test('awards writing and daily XP for a first completion', () async {
    final repository = _FakeLearningProgressRepository();
    final container = ProviderContainer(
      overrides: [
        learningProgressRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(learningProgressControllerProvider)
        .markHanjaCompleted(hanjaId: 'HJ-1', todayHanjaIds: {'HJ-1'});

    expect(result.earnedXp, 45);
    expect(repository.xpEvents, hasLength(2));
  });
}

class _FakeLearningProgressRepository implements LearningProgressRepository {
  _FakeLearningProgressRepository({Set<String>? completedForStudent})
    : _completedForStudent = {...?completedForStudent};

  final Set<String> _completedForStudent;
  final Set<String> _completedToday = {};
  final List<_XpEvent> xpEvents = [];

  @override
  Future<Set<String>> getCompletedHanjaIds({
    required String studentKey,
    required String learningDate,
  }) async {
    return {..._completedToday};
  }

  @override
  Future<Set<String>> getCompletedHanjaIdsForStudent({
    required String studentKey,
  }) async {
    return {..._completedForStudent, ..._completedToday};
  }

  @override
  Future<List<LearningProgressRecord>> getCompletedHanjaRecordsForStudent({
    required String studentKey,
  }) async {
    return [
      for (final hanjaId in _completedForStudent)
        LearningProgressRecord(
          studentKey: studentKey,
          learningDate: '20260529',
          hanjaId: hanjaId,
          completedAt: DateTime(2026, 5, 29),
        ),
    ];
  }

  @override
  Future<bool> markHanjaCompleted({
    required String studentKey,
    required String learningDate,
    required String hanjaId,
  }) async {
    final didInsert = _completedToday.add(hanjaId);
    _completedForStudent.add(hanjaId);
    return didInsert;
  }

  @override
  Future<bool> addXpEvent({
    required String id,
    required String studentKey,
    required String source,
    required int amount,
    String? refId,
  }) async {
    if (xpEvents.any((event) => event.id == id)) {
      return false;
    }
    xpEvents.add(_XpEvent(id: id, amount: amount));
    return true;
  }

  @override
  Future<int> getTotalXp({required String studentKey}) async {
    return xpEvents.fold<int>(0, (sum, event) => sum + event.amount);
  }

  @override
  Future<int> getXpForRef({
    required String studentKey,
    required String source,
    required String refId,
  }) async {
    return 0;
  }
}

class _XpEvent {
  const _XpEvent({required this.id, required this.amount});

  final String id;
  final int amount;
}
