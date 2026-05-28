import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/app/app.dart';
import 'package:hanja_soook/app/router.dart';
import 'package:hanja_soook/core/constants/route_paths.dart';
import 'package:hanja_soook/data/repositories/class_room_repository_provider.dart';
import 'package:hanja_soook/data/repositories/game_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/quiz_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/school_repository_provider.dart';
import 'package:hanja_soook/data/repositories/student_link_repository_provider.dart';
import 'package:hanja_soook/domain/models/app_user_profile.dart';
import 'package:hanja_soook/domain/models/class_room.dart';
import 'package:hanja_soook/domain/models/learning_result.dart';
import 'package:hanja_soook/domain/models/learning_session.dart';
import 'package:hanja_soook/domain/models/student_link.dart';
import 'package:hanja_soook/domain/repositories/game_result_repository.dart';
import 'package:hanja_soook/domain/models/school.dart';
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

    expect(find.text('한자쏘옥'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('학교와 학생 정보를 입력해요'), findsOneWidget);

    appRouter.go(RoutePaths.home);
    await pumpUntilFound(tester, find.text('오늘의 한자를 시작해요'));

    expect(find.text('오늘의 한자를 시작해요'), findsOneWidget);

    final routeChecks = <String, String>{
      RoutePaths.hanja('HJ-0001'): '획수 1 · 초3 1단원 1. 나라를 세운 역사 인물',
      RoutePaths.writing('HJ-0001'): '획순 애니메이션',
      RoutePaths.quiz: "'한 일'이라는 뜻을 가진 한자를 고르세요.",
      RoutePaths.game: '뜻에 맞는 한자를 고르세요.',
      RoutePaths.result: '학습 결과',
      RoutePaths.growth: '성장',
      RoutePaths.studentLinks: '학생 연결 관리',
      RoutePaths.teacherPreview: '샘플 미리보기 화면입니다. 실제 과제 저장이나 알림은 실행되지 않습니다.',
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

    await tester.tap(find.byType(FilledButton).last);
    await tester.pumpAndSettle();

    expect(find.text('학교를 선택해주세요.'), findsOneWidget);
  });
}
