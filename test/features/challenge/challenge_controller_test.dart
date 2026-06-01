import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/repositories/challenge_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/class_room_repository_provider.dart';
import 'package:hanja_soook/data/repositories/learning_progress_repository_provider.dart';
import 'package:hanja_soook/domain/models/app_user_profile.dart';
import 'package:hanja_soook/domain/models/challenge_result.dart';
import 'package:hanja_soook/domain/models/class_room.dart';
import 'package:hanja_soook/domain/models/learning_progress_record.dart';
import 'package:hanja_soook/domain/repositories/challenge_result_repository.dart';
import 'package:hanja_soook/domain/repositories/class_room_repository.dart';
import 'package:hanja_soook/domain/repositories/learning_progress_repository.dart';
import 'package:hanja_soook/features/auth/current_profile_controller.dart';
import 'package:hanja_soook/features/challenge/challenge_controller.dart';
import 'package:hanja_soook/features/learning/learning_progress_controller.dart';

void main() {
  test('challenge summary uses today results and class rank', () async {
    final container = ProviderContainer(
      overrides: [
        challengeResultRepositoryProvider.overrideWithValue(
          _FakeChallengeResultRepository(),
        ),
        classRoomRepositoryProvider.overrideWithValue(
          _FakeClassRoomRepository(),
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

    final summary = await container.read(challengeSummaryProvider.future);

    expect(summary.className, '3학년 1반');
    expect(summary.rankText, '2위');
    expect(summary.todayScore, 3);
    expect(summary.todayXp, 30);
    expect(summary.latestSummary, '판뒤집기 2판');
    expect(summary.rankingRows.map((row) => row.displayName), ['친구2', '나']);
    expect(summary.rankingRows.map((row) => row.scoreText), ['5점', '3점']);
    expect(summary.isSample, isFalse);
    expect(summary.hasJoinedClass, isTrue);
  });

  test(
    'challenge summary prompts class join when student has no class',
    () async {
      final container = ProviderContainer(
        overrides: [
          challengeResultRepositoryProvider.overrideWithValue(
            _FakeChallengeResultRepository(),
          ),
          classRoomRepositoryProvider.overrideWithValue(
            _EmptyClassRoomRepository(),
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

      final summary = await container.read(challengeSummaryProvider.future);

      expect(summary.className, '반 미가입');
      expect(summary.rankText, '참여 필요');
      expect(summary.rankingRows, isNotEmpty);
      expect(summary.hasJoinedClass, isFalse);
    },
  );
}

class _FakeChallengeResultRepository implements ChallengeResultRepository {
  @override
  Future<List<ChallengeResult>> getChallengeResults({
    Set<String>? studentKeys,
    String? learningDate,
  }) async {
    final today = currentLearningDate();
    final results = [
      ChallengeResult(
        id: 'result-1',
        studentKey: 'me',
        learningDate: today,
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
        learningDate: today,
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
    return [
      for (final result in results)
        if ((studentKeys == null || studentKeys.contains(result.studentKey)) &&
            (learningDate == null || learningDate == result.learningDate))
          result,
    ];
  }

  @override
  Future<ChallengeResult?> getChallengeResultById(String id) async => null;

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

class _EmptyClassRoomRepository implements ClassRoomRepository {
  @override
  Future<List<ClassRoom>> getClasses() async => const [];

  @override
  Future<List<ClassMember>> getClassMembers({required String classId}) async {
    return const [];
  }

  @override
  Future<void> saveClass(ClassRoom classRoom) async {}

  @override
  Future<void> saveClassMember(ClassMember member) async {}
}

class _FakeLearningProgressRepository implements LearningProgressRepository {
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
