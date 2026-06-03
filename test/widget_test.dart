import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/app/app.dart';
import 'package:hanja_soook/app/router.dart';
import 'package:hanja_soook/core/constants/route_paths.dart';
import 'package:hanja_soook/data/repositories/challenge_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/class_room_repository_provider.dart';
import 'package:hanja_soook/data/repositories/content_repository_provider.dart';
import 'package:hanja_soook/data/repositories/game_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/learning_diagnostics_repository_provider.dart';
import 'package:hanja_soook/data/repositories/quiz_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/school_repository_provider.dart';
import 'package:hanja_soook/data/repositories/student_link_repository_provider.dart';
import 'package:hanja_soook/domain/models/app_user_profile.dart';
import 'package:hanja_soook/domain/models/challenge_result.dart';
import 'package:hanja_soook/domain/models/class_room.dart';
import 'package:hanja_soook/domain/models/hanja_character.dart';
import 'package:hanja_soook/domain/models/hanja_example.dart';
import 'package:hanja_soook/domain/models/learning_diagnostics.dart';
import 'package:hanja_soook/domain/models/learning_result.dart';
import 'package:hanja_soook/domain/models/learning_progress_record.dart';
import 'package:hanja_soook/domain/models/learning_session.dart';
import 'package:hanja_soook/domain/models/quiz_question.dart';
import 'package:hanja_soook/domain/models/stroke_asset.dart';
import 'package:hanja_soook/domain/models/student_link.dart';
import 'package:hanja_soook/domain/repositories/game_result_repository.dart';
import 'package:hanja_soook/domain/models/school.dart';
import 'package:hanja_soook/domain/repositories/challenge_result_repository.dart';
import 'package:hanja_soook/domain/repositories/class_room_repository.dart';
import 'package:hanja_soook/domain/repositories/content_repository.dart';
import 'package:hanja_soook/domain/repositories/learning_diagnostics_repository.dart';
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

const _testDailyCharacters = [
  HanjaCharacter(
    id: 'HJ-0001',
    character: '名',
    sound: '명',
    meaning: '이름',
    strokeCount: 6,
    grade: 3,
    unitCode: 'G3-U1',
    unitName: '테스트 단원',
    sortOrder: 1,
  ),
  HanjaCharacter(
    id: 'HJ-0002',
    character: '王',
    sound: '왕',
    meaning: '임금',
    strokeCount: 4,
    grade: 3,
    unitCode: 'G3-U1',
    unitName: '테스트 단원',
    sortOrder: 2,
  ),
  HanjaCharacter(
    id: 'HJ-0003',
    character: '世',
    sound: '세',
    meaning: '대',
    strokeCount: 5,
    grade: 3,
    unitCode: 'G3-U1',
    unitName: '테스트 단원',
    sortOrder: 3,
  ),
  HanjaCharacter(
    id: 'HJ-0004',
    character: '上',
    sound: '상',
    meaning: '위',
    strokeCount: 3,
    grade: 3,
    unitCode: 'G3-U1',
    unitName: '테스트 단원',
    sortOrder: 4,
  ),
  HanjaCharacter(
    id: 'HJ-0005',
    character: '山',
    sound: '산',
    meaning: '뫼',
    strokeCount: 3,
    grade: 3,
    unitCode: 'G3-U1',
    unitName: '테스트 단원',
    sortOrder: 5,
  ),
  HanjaCharacter(
    id: 'HJ-0006',
    character: '林',
    sound: '림',
    meaning: '수풀',
    strokeCount: 8,
    grade: 3,
    unitCode: 'G3-U1',
    unitName: '테스트 단원',
    sortOrder: 6,
  ),
];

class _FakeContentRepository implements ContentRepository {
  @override
  Future<HanjaCharacter?> getTodayHanja({int? grade}) async =>
      _testDailyCharacters.first;

  @override
  Future<List<HanjaCharacter>> getTodayHanjaSet({
    int? grade,
    int limit = 4,
  }) async => _charactersForGrade(grade).take(limit).toList();

  @override
  Future<List<HanjaCharacter>> getHanjaList({int? grade, int? limit}) async {
    final items = _charactersForGrade(grade);
    return limit == null ? items : items.take(limit).toList();
  }

  @override
  Future<HanjaCharacter?> getHanjaById(String hanjaId) async {
    return _testDailyCharacters.where((item) => item.id == hanjaId).firstOrNull;
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
      id: 'stroke-$hanjaId',
      hanjaId: hanjaId,
      character: item.character,
      dataFormat: StrokeDataFormat.svg,
      strokeCount: item.strokeCount,
      svgPaths: const ['M 10 20 L 90 20'],
      reviewStatus: StrokeReviewStatus.available,
    );
  }

  List<HanjaCharacter> _charactersForGrade(int? grade) {
    if (grade == null) {
      return _testDailyCharacters;
    }
    return _testDailyCharacters
        .where((item) => item.grade == grade)
        .toList(growable: false);
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

class _FakeLearningDiagnosticsRepository
    implements LearningDiagnosticsRepository {
  @override
  Future<List<HanjaPracticeEvent>> getPracticeEventsForHanja({
    required String studentKey,
    required String hanjaId,
  }) async {
    return const [];
  }

  @override
  Future<List<HanjaWeaknessRecord>> getActiveWeaknesses({
    required String studentKey,
  }) async {
    return const [];
  }

  @override
  Future<Map<String, List<HanjaWeaknessRecord>>> getWeaknessesByHanja({
    required String studentKey,
    required Set<String> hanjaIds,
  }) async {
    return const {};
  }

  @override
  Future<void> markWeaknessResolved({
    required String studentKey,
    required String hanjaId,
    required HanjaWeaknessType weaknessType,
  }) async {}

  @override
  Future<void> recordPracticeEvent(HanjaPracticeEventInput input) async {}
}

Widget _testApp() {
  return ProviderScope(
    overrides: [
      schoolRepositoryProvider.overrideWithValue(_FakeSchoolRepository()),
      contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
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
      learningDiagnosticsRepositoryProvider.overrideWithValue(
        _FakeLearningDiagnosticsRepository(),
      ),
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
    expect(find.text('한자 쏙쏙 실력 쑥쑥'), findsOneWidget);

    appRouter.go(RoutePaths.studentSetup);
    await pumpUntilFound(tester, find.text('학년 선택'));

    expect(find.text('학년 선택'), findsOneWidget);

    appRouter.go(RoutePaths.home);
    await pumpUntilFound(tester, find.text('한자쏘옥 모험'));

    expect(find.text('한자쏘옥 모험'), findsOneWidget);
    await pumpUntilFound(tester, find.text('오늘 학습 시작'));
    expect(find.text('오늘 학습 시작'), findsOneWidget);

    appRouter.go(RoutePaths.dailySession);
    await pumpUntilFound(tester, find.text('오늘 학습'));
    expect(find.text('시작'), findsOneWidget);

    final routeChecks = <String, String>{
      RoutePaths.hanja('HJ-0001'): '쓰기 연습 시작',
      RoutePaths.writing('HJ-0001'): '획순 보기',
      RoutePaths.appLearn: '복습하고, 한자장을 정리해요',
      RoutePaths.appChallenge: '오늘 점수와 반 순위를 올려요',
      RoutePaths.appSettings: '학습 연결',
      RoutePaths.quiz: '퀴즈 선택',
      RoutePaths.game: '시간 안에 많이 맞혀요. 오답은 점수가 깎여요.',
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

  testWidgets('daily learning modes share compact one-screen layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_testApp());
    await tester.pump(const Duration(seconds: 1));
    appRouter.go(RoutePaths.home);
    await pumpUntilFound(tester, find.text('오늘 학습 시작'));
    final dailyButton = find.text('오늘 학습 시작').last;
    await tester.ensureVisible(dailyButton);
    await tester.pump();
    await tester.tap(dailyButton);
    await pumpUntilFound(tester, find.text('오늘 학습'));
    await pumpUntilFound(tester, find.text('시작'));
    expect(find.text('시작'), findsWidgets);

    final startButton = find.text('시작').last;
    await tester.ensureVisible(startButton);
    await tester.pump();
    await tester.tap(startButton);
    await pumpUntilFound(tester, find.text('따라쓰기'));

    final guidedBackTop = tester
        .getTopLeft(find.byIcon(Icons.arrow_back).first)
        .dy;
    final guidedBadgeTop = tester.getTopLeft(find.text('6자').last).dy;
    _expectInViewport(tester, find.text('다음 한자').last);

    await tester.tap(find.text('훈음 맞히기').last);
    await tester.pump(const Duration(milliseconds: 300));

    final quizBackTop = tester
        .getTopLeft(find.byIcon(Icons.arrow_back).first)
        .dy;
    final quizBadgeTop = tester.getTopLeft(find.text('6자').last).dy;
    expect((quizBackTop - guidedBackTop).abs(), lessThanOrEqualTo(2));
    expect((quizBadgeTop - guidedBadgeTop).abs(), lessThanOrEqualTo(2));
    _expectInViewport(tester, find.text('다음').last);

    await tester.tap(find.text('랜덤쓰기').last);
    await tester.pump(const Duration(milliseconds: 300));

    final randomBackTop = tester
        .getTopLeft(find.byIcon(Icons.arrow_back).first)
        .dy;
    final randomBadgeTop = tester.getTopLeft(find.text('6자').last).dy;
    expect((randomBackTop - guidedBackTop).abs(), lessThanOrEqualTo(2));
    expect((randomBadgeTop - guidedBadgeTop).abs(), lessThanOrEqualTo(2));
    _expectInViewport(tester, find.text('확인하기').last);
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

void _expectInViewport(WidgetTester tester, Finder finder) {
  expect(finder, findsWidgets);
  final bottom = tester.getBottomLeft(finder).dy;
  expect(bottom, lessThanOrEqualTo(tester.view.physicalSize.height));
}
