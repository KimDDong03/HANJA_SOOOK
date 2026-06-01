import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/repositories/challenge_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/content_repository_provider.dart';
import 'package:hanja_soook/data/repositories/learning_progress_repository_provider.dart';
import 'package:hanja_soook/domain/models/challenge_result.dart';
import 'package:hanja_soook/domain/models/hanja_character.dart';
import 'package:hanja_soook/domain/models/hanja_example.dart';
import 'package:hanja_soook/domain/models/learning_progress_record.dart';
import 'package:hanja_soook/domain/models/quiz_question.dart';
import 'package:hanja_soook/domain/models/stroke_asset.dart';
import 'package:hanja_soook/domain/repositories/challenge_result_repository.dart';
import 'package:hanja_soook/domain/repositories/content_repository.dart';
import 'package:hanja_soook/domain/repositories/learning_progress_repository.dart';
import 'package:hanja_soook/features/learning/learning_progress_controller.dart';
import 'package:hanja_soook/features/result/result_controller.dart';

void main() {
  test('resultProvider loads a challenge result by id', () async {
    final container = ProviderContainer(
      overrides: [
        challengeResultRepositoryProvider.overrideWithValue(
          _FakeChallengeResultRepository(),
        ),
        contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
        learningProgressRepositoryProvider.overrideWithValue(
          _FakeLearningProgressRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(
      resultProvider(
        const ResultArgs(
          hanjaId: null,
          earnedXp: null,
          completedCount: null,
          totalCount: null,
          challengeResultId: 'challenge-result-1',
          writingPassed: null,
        ),
      ).future,
    );

    expect(state.challengeResult?.id, 'challenge-result-1');
    expect(state.challengeResult?.mode, ChallengeMode.flipBoard);
    expect(state.earnedXp, 40);
    expect(state.isChallengeResult, isTrue);
  });

  test(
    'resultProvider finds next Hanja from grade sequence after daily plan',
    () async {
      final container = ProviderContainer(
        overrides: [
          challengeResultRepositoryProvider.overrideWithValue(
            _FakeChallengeResultRepository(),
          ),
          contentRepositoryProvider.overrideWithValue(
            _FakeContentRepository(hanjaList: _hanjaList),
          ),
          learningProgressRepositoryProvider.overrideWithValue(
            _FakeLearningProgressRepository(
              records: [
                LearningProgressRecord(
                  studentKey: 'local-student',
                  learningDate: currentLearningDate(),
                  hanjaId: 'HJ-1',
                  completedAt: DateTime(2026, 5, 30),
                ),
                LearningProgressRecord(
                  studentKey: 'local-student',
                  learningDate: currentLearningDate(),
                  hanjaId: 'HJ-2',
                  completedAt: DateTime(2026, 5, 30),
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(
        resultProvider(
          const ResultArgs(
            hanjaId: 'HJ-2',
            earnedXp: 10,
            completedCount: 2,
            totalCount: 2,
            writingPassed: true,
            writingScore: 85,
            writingAccuracy: 85,
            writingStars: 3,
            writingTimeSec: 12,
          ),
        ).future,
      );

      expect(state.isDailyComplete, isTrue);
      expect(state.nextHanja?.id, 'HJ-3');
      expect(state.writingResultLabel, '자유쓰기 통과');
      expect(state.hasWritingMetrics, isTrue);
      expect(state.writingAccuracyPercent, 85);
      expect(state.writingStarsText, '★★★');
    },
  );
}

class _FakeChallengeResultRepository implements ChallengeResultRepository {
  @override
  Future<ChallengeResult?> getChallengeResultById(String id) async {
    return ChallengeResult(
      id: id,
      studentKey: 'student-1',
      learningDate: '20260530',
      mode: ChallengeMode.flipBoard,
      score: 7,
      correctCount: 4,
      totalCount: 9,
      timeSec: 60,
      flippedTileCount: 4,
      earnedXp: 40,
      completedAt: DateTime(2026, 5, 30),
    );
  }

  @override
  Future<List<ChallengeResult>> getChallengeResults({
    Set<String>? studentKeys,
    String? learningDate,
  }) async {
    return const [];
  }

  @override
  Future<ChallengeResult?> getLatestChallengeResult({
    required String studentKey,
    ChallengeMode? mode,
  }) async {
    return null;
  }

  @override
  Future<ChallengeResult> saveChallengeResult({
    required String studentKey,
    required String learningDate,
    required ChallengeResultInput input,
    required int earnedXp,
  }) {
    throw UnimplementedError();
  }
}

class _FakeContentRepository implements ContentRepository {
  const _FakeContentRepository({this.hanjaList = const []});

  final List<HanjaCharacter> hanjaList;

  @override
  Future<HanjaCharacter?> getTodayHanja({int? grade}) async {
    return hanjaList.isEmpty ? null : hanjaList.first;
  }

  @override
  Future<List<HanjaCharacter>> getTodayHanjaSet({
    int? grade,
    int limit = 4,
  }) async {
    return hanjaList.take(limit).toList();
  }

  @override
  Future<List<HanjaCharacter>> getHanjaList({int? grade, int? limit}) async {
    return limit == null ? hanjaList : hanjaList.take(limit).toList();
  }

  @override
  Future<HanjaCharacter?> getHanjaById(String hanjaId) async {
    for (final hanja in hanjaList) {
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
  const _FakeLearningProgressRepository({this.records = const []});

  final List<LearningProgressRecord> records;

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
    return records
        .where((record) {
          return record.studentKey == studentKey &&
              record.learningDate == learningDate;
        })
        .map((record) => record.hanjaId)
        .toSet();
  }

  @override
  Future<Set<String>> getCompletedHanjaIdsForStudent({
    required String studentKey,
  }) async {
    return records
        .where((record) => record.studentKey == studentKey)
        .map((record) => record.hanjaId)
        .toSet();
  }

  @override
  Future<List<LearningProgressRecord>> getCompletedHanjaRecordsForStudent({
    required String studentKey,
  }) async {
    return records.where((record) => record.studentKey == studentKey).toList();
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

const _hanjaList = [
  HanjaCharacter(
    id: 'HJ-1',
    character: '一',
    sound: '일',
    meaning: '한 일',
    grade: 3,
  ),
  HanjaCharacter(
    id: 'HJ-2',
    character: '二',
    sound: '이',
    meaning: '두 이',
    grade: 3,
  ),
  HanjaCharacter(
    id: 'HJ-3',
    character: '三',
    sound: '삼',
    meaning: '석 삼',
    grade: 3,
  ),
];
