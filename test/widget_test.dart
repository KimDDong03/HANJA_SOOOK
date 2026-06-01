import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/app/app.dart';
import 'package:hanja_soook/app/router.dart';
import 'package:hanja_soook/core/constants/route_paths.dart';
import 'package:hanja_soook/data/repositories/challenge_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/class_room_repository_provider.dart';
import 'package:hanja_soook/data/repositories/game_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/quiz_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/school_repository_provider.dart';
import 'package:hanja_soook/data/repositories/student_link_repository_provider.dart';
import 'package:hanja_soook/domain/models/app_user_profile.dart';
import 'package:hanja_soook/domain/models/challenge_result.dart';
import 'package:hanja_soook/domain/models/class_room.dart';
import 'package:hanja_soook/domain/models/learning_result.dart';
import 'package:hanja_soook/domain/models/learning_progress_record.dart';
import 'package:hanja_soook/domain/models/learning_session.dart';
import 'package:hanja_soook/domain/models/student_link.dart';
import 'package:hanja_soook/domain/repositories/game_result_repository.dart';
import 'package:hanja_soook/domain/models/school.dart';
import 'package:hanja_soook/domain/repositories/challenge_result_repository.dart';
import 'package:hanja_soook/domain/repositories/class_room_repository.dart';
import 'package:hanja_soook/domain/repositories/learning_progress_repository.dart';
import 'package:hanja_soook/domain/repositories/quiz_result_repository.dart';
import 'package:hanja_soook/domain/repositories/school_repository.dart';
import 'package:hanja_soook/domain/repositories/student_link_repository.dart';
import 'package:hanja_soook/data/repositories/learning_progress_repository_provider.dart';

class _FakeSchoolRepository implements SchoolRepository {
  @override
  Future<AppUserProfile?> getCurrentProfile() async => null;

  @override
  Future<School?> getSchoolByStandardCode(String standardSchoolCode) async =>
      null;

  @override
  Future<List<School>> searchSchools({
    required String keyword,
    String? regionName,
    int limit = 20,
  }) async => const [];

  @override
  Future<AppUserProfile> signInStudentWithSchool({
    required School school,
    required String displayName,
    required int grade,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppUserProfile> updateStudentProfile({
    required String profileId,
    required String displayName,
    required int grade,
    required School school,
    required String avatarKey,
  }) async {
    return AppUserProfile(
      id: profileId,
      displayName: displayName.trim(),
      schoolId: school.id,
      standardSchoolCode: school.standardSchoolCode,
      schoolName: school.schoolName,
      grade: grade,
      avatarKey: avatarKey,
      isDemo: true,
    );
  }

  @override
  Future<void> signOut() async {}
}

class _FakeLearningProgressRepository implements LearningProgressRepository {
  @override
  Future<Set<String>> getCompletedHanjaIds({
    required String studentKey,
    required String learningDate,
  }) async {
    return const <String>{};
  }

  @override
  Future<Set<String>> getCompletedHanjaIdsForStudent({
    required String studentKey,
  }) async {
    return const <String>{
      'HJ-0001',
      'HJ-0002',
      'HJ-0003',
      'HJ-0004',
      'HJ-0005',
      'HJ-0006',
    };
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
    return true;
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
      id: 'game-result-1',
      mode: LearningMode.game,
      score: score,
      correctCount: correctCount,
      totalCount: totalCount,
      timeSec: timeSec,
      completedAt: DateTime(2026, 5, 28),
    );
  }
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
      id: 'quiz-result-1',
      mode: LearningMode.quiz,
      score: score,
      correctCount: correctCount,
      totalCount: totalCount,
      timeSec: timeSec,
      completedAt: DateTime(2026, 5, 28),
    );
  }
}

class _FakeChallengeResultRepository implements ChallengeResultRepository {
  @override
  Future<ChallengeResult?> getChallengeResultById(String id) async {
    return null;
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
  }) async {
    return ChallengeResult(
      id: 'challenge-result-1',
      studentKey: studentKey,
      learningDate: learningDate,
      mode: input.mode,
      score: input.score,
      correctCount: input.correctCount,
      totalCount: input.totalCount,
      timeSec: input.timeSec,
      flippedTileCount: input.flippedTileCount,
      earnedXp: earnedXp,
      completedAt: DateTime(2026, 5, 30),
    );
  }
}

class _FakeStudentLinkRepository implements StudentLinkRepository {
  @override
  Future<List<StudentLink>> getStudentLinks({
    required String relationType,
  }) async {
    return const [];
  }

  @override
  Future<void> saveStudentLink(StudentLink link) async {}
}

class _FakeClassRoomRepository implements ClassRoomRepository {
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

Widget _testApp() {
  return ProviderScope(
    overrides: [
      schoolRepositoryProvider.overrideWithValue(_FakeSchoolRepository()),
      learningProgressRepositoryProvider.overrideWithValue(
        _FakeLearningProgressRepository(),
      ),
      gameResultRepositoryProvider.overrideWithValue(
        _FakeGameResultRepository(),
      ),
      quizResultRepositoryProvider.overrideWithValue(
        _FakeQuizResultRepository(),
      ),
      challengeResultRepositoryProvider.overrideWithValue(
        _FakeChallengeResultRepository(),
      ),
      studentLinkRepositoryProvider.overrideWithValue(
        _FakeStudentLinkRepository(),
      ),
      classRoomRepositoryProvider.overrideWithValue(_FakeClassRoomRepository()),
    ],
    child: const HanjaSoookApp(),
  );
}

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 100,
}) async {
  for (var i = 0; i < maxPumps; i += 1) {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
}

void main() {
  testWidgets('ticket 00 routes render placeholders', (tester) async {
    await tester.pumpWidget(_testApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('어떤 모드로 시작할까요?'), findsOneWidget);

    appRouter.go(RoutePaths.studentSetup);
    await pumpUntilFound(tester, find.text('학년 선택'));

    expect(find.text('학년 선택'), findsOneWidget);

    appRouter.go(RoutePaths.home);
    await pumpUntilFound(tester, find.text('한자쏘옥 모험'));

    expect(find.text('한자쏘옥 모험'), findsOneWidget);
    await pumpUntilFound(tester, find.text('오늘 학습 시작'));
    expect(find.text('오늘 학습 시작'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '오늘 학습 시작'));
    await pumpUntilFound(tester, find.text('오늘 학습'));
    expect(find.text('시작'), findsOneWidget);

    final routeChecks = <String, String>{
      RoutePaths.hanja('HJ-0001'): '쓰기 연습 시작',
      RoutePaths.writing('HJ-0001'): '획순 보기',
      RoutePaths.appLearn: '복습하고, 한자장을 정리해요',
      RoutePaths.appChallenge: '오늘 점수와 반 순위를 올려요',
      RoutePaths.appSettings: '학습 연결',
      RoutePaths.quiz: '퀴즈 선택',
      RoutePaths.game: '빠르게 고를수록 콤보 점수가 올라가요.',
      RoutePaths.result: '연습 완료',
      RoutePaths.growth: '성장 앨범',
      RoutePaths.studentLinks: '학습 연결',
      RoutePaths.teacherPreview: '반 코드 관리',
    };

    for (final entry in routeChecks.entries) {
      appRouter.go(entry.key);
      await pumpUntilFound(tester, find.text(entry.value));

      expect(find.text(entry.value), findsOneWidget);
    }
  });

  testWidgets('login validates required school before start', (tester) async {
    await tester.pumpWidget(_testApp());
    appRouter.go(RoutePaths.login);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -260));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('학교를 선택해주세요.'), findsOneWidget);
  });

  testWidgets('top-level app tabs confirm before app exit', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final tabChecks = <String, String>{
      RoutePaths.appHome: '한자쏘옥 모험',
      RoutePaths.appLearn: '복습하고, 한자장을 정리해요',
      RoutePaths.appChallenge: '오늘 점수와 반 순위를 올려요',
      RoutePaths.appSettings: '학습 연결',
    };

    for (final entry in tabChecks.entries) {
      appRouter.go(entry.key);
      await pumpUntilFound(tester, find.text(entry.value));

      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('종료하시겠습니까?'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, '취소'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('종료하시겠습니까?'), findsNothing);
      expect(find.text(entry.value), findsOneWidget);
    }
  });
}
