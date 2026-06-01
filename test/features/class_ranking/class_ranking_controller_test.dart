import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/repositories/challenge_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/class_room_repository_provider.dart';
import 'package:hanja_soook/data/repositories/learning_progress_repository_provider.dart';
import 'package:hanja_soook/domain/models/app_user_profile.dart';
import 'package:hanja_soook/domain/models/challenge_result.dart';
import 'package:hanja_soook/domain/models/class_ranking.dart';
import 'package:hanja_soook/domain/models/class_room.dart';
import 'package:hanja_soook/domain/models/learning_progress_record.dart';
import 'package:hanja_soook/domain/repositories/challenge_result_repository.dart';
import 'package:hanja_soook/domain/repositories/class_room_repository.dart';
import 'package:hanja_soook/domain/repositories/learning_progress_repository.dart';
import 'package:hanja_soook/features/auth/current_profile_controller.dart';
import 'package:hanja_soook/features/class_ranking/class_ranking_controller.dart';

void main() {
  test('ClassRankingController switches fallback ranking filters', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(classRankingProvider.future);
    final controller = container.read(classRankingProvider.notifier);
    controller.selectFilter(ClassRankingMetric.flipBoard);

    final state = container.read(classRankingProvider).value!;
    expect(state.selectedFilter, ClassRankingMetric.flipBoard);
    expect(state.myEntry?.scoreText, '12판');
    expect(state.isSample, isTrue);
  });

  test('ClassRankingController ranks actual class records', () async {
    final container = ProviderContainer(
      overrides: [
        classRoomRepositoryProvider.overrideWithValue(
          _FakeClassRoomRepository(),
        ),
        challengeResultRepositoryProvider.overrideWithValue(
          _FakeChallengeResultRepository(),
        ),
        learningProgressRepositoryProvider.overrideWithValue(
          _FakeLearningProgressRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(currentProfileProvider.notifier)
        .setProfile(
          const AppUserProfile(id: 'me', displayName: '김하준', grade: 3),
        );

    final state = await container.read(classRankingProvider.future);

    expect(state.isSample, isFalse);
    expect(state.className, '3학년 1반');
    expect(state.entries.first.studentKey, 'friend-1');
    expect(state.entries.first.scoreText, '90 XP');

    container
        .read(classRankingProvider.notifier)
        .selectFilter(ClassRankingMetric.flipBoard);
    final flipState = container.read(classRankingProvider).value!;
    expect(flipState.entries.first.studentKey, 'me');
    expect(flipState.entries.first.scoreText, '2판');
  });

  test(
    'ClassRankingController keeps actual class rows at zero without records',
    () async {
      final container = ProviderContainer(
        overrides: [
          classRoomRepositoryProvider.overrideWithValue(
            _FakeClassRoomRepository(),
          ),
          challengeResultRepositoryProvider.overrideWithValue(
            _EmptyChallengeResultRepository(),
          ),
          learningProgressRepositoryProvider.overrideWithValue(
            _ZeroLearningProgressRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(currentProfileProvider.notifier)
          .setProfile(
            const AppUserProfile(id: 'me', displayName: '김하준', grade: 3),
          );

      final state = await container.read(classRankingProvider.future);

      expect(state.isSample, isFalse);
      expect(state.status, ClassRankingStatus.active);
      expect(state.entries, hasLength(2));
      expect(state.myEntry?.scoreText, '0 XP');
    },
  );
}

class _FakeClassRoomRepository implements ClassRoomRepository {
  @override
  Future<List<ClassRoom>> getClasses() async {
    return [
      ClassRoom(
        id: 'class-1',
        className: '3학년 1반',
        classCode: 'HSCLASS',
        createdAt: DateTime(2026, 5, 30),
      ),
    ];
  }

  @override
  Future<List<ClassMember>> getClassMembers({required String classId}) async {
    return [
      ClassMember(
        classId: classId,
        studentKey: 'me',
        displayName: '김하준',
        joinedAt: DateTime(2026, 5, 30),
      ),
      ClassMember(
        classId: classId,
        studentKey: 'friend-1',
        displayName: '박서연',
        joinedAt: DateTime(2026, 5, 30),
      ),
    ];
  }

  @override
  Future<void> saveClass(ClassRoom classRoom) async {}

  @override
  Future<void> saveClassMember(ClassMember member) async {}
}

class _FakeChallengeResultRepository implements ChallengeResultRepository {
  @override
  Future<List<ChallengeResult>> getChallengeResults({
    Set<String>? studentKeys,
    String? learningDate,
  }) async {
    return [
      ChallengeResult(
        id: 'result-1',
        studentKey: 'me',
        learningDate: '20260530',
        mode: ChallengeMode.flipBoard,
        score: 3,
        correctCount: 2,
        totalCount: 9,
        timeSec: 60,
        flippedTileCount: 2,
        earnedXp: 30,
        completedAt: DateTime(2026, 5, 30),
      ),
      ChallengeResult(
        id: 'result-2',
        studentKey: 'friend-1',
        learningDate: '20260530',
        mode: ChallengeMode.speedChoice,
        score: 5,
        correctCount: 5,
        totalCount: 5,
        timeSec: 30,
        flippedTileCount: 0,
        earnedXp: 45,
        completedAt: DateTime(2026, 5, 30),
      ),
    ];
  }

  @override
  Future<ChallengeResult?> getChallengeResultById(String id) async {
    return null;
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

class _EmptyChallengeResultRepository implements ChallengeResultRepository {
  @override
  Future<List<ChallengeResult>> getChallengeResults({
    Set<String>? studentKeys,
    String? learningDate,
  }) async {
    return const [];
  }

  @override
  Future<ChallengeResult?> getChallengeResultById(String id) async {
    return null;
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

class _FakeLearningProgressRepository implements LearningProgressRepository {
  @override
  Future<int> getTotalXp({required String studentKey}) async {
    return switch (studentKey) {
      'friend-1' => 90,
      'me' => 70,
      _ => 0,
    };
  }

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

class _ZeroLearningProgressRepository implements LearningProgressRepository {
  @override
  Future<int> getTotalXp({required String studentKey}) async => 0;

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
