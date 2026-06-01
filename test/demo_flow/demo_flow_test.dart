import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/app/app.dart';
import 'package:hanja_soook/app/router.dart';
import 'package:hanja_soook/core/constants/route_paths.dart';
import 'package:hanja_soook/data/repositories/challenge_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/content_repository_provider.dart';
import 'package:hanja_soook/data/repositories/game_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/learning_progress_repository_provider.dart';
import 'package:hanja_soook/data/repositories/quiz_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/school_repository_provider.dart';
import 'package:hanja_soook/domain/models/app_user_profile.dart';
import 'package:hanja_soook/domain/models/challenge_result.dart';
import 'package:hanja_soook/domain/models/hanja_character.dart';
import 'package:hanja_soook/domain/models/hanja_example.dart';
import 'package:hanja_soook/domain/models/learning_progress_record.dart';
import 'package:hanja_soook/domain/models/learning_result.dart';
import 'package:hanja_soook/domain/models/learning_session.dart';
import 'package:hanja_soook/domain/models/quiz_question.dart';
import 'package:hanja_soook/domain/models/school.dart';
import 'package:hanja_soook/domain/models/stroke_asset.dart';
import 'package:hanja_soook/domain/repositories/challenge_result_repository.dart';
import 'package:hanja_soook/domain/repositories/content_repository.dart';
import 'package:hanja_soook/domain/repositories/game_result_repository.dart';
import 'package:hanja_soook/domain/repositories/learning_progress_repository.dart';
import 'package:hanja_soook/domain/repositories/quiz_result_repository.dart';
import 'package:hanja_soook/domain/repositories/school_repository.dart';

void main() {
  testWidgets('student setup can reach home and start today session', (
    tester,
  ) async {
    final progressRepository = _FakeLearningProgressRepository();
    await tester.pumpWidget(_demoApp(progressRepository: progressRepository));

    appRouter.go(RoutePaths.studentSetup);
    await _pumpUntilFound(tester, find.text('학년 선택'));

    await tester.enterText(find.widgetWithText(TextField, '학교명'), '새솔');
    await tester.tap(find.text('학교 검색'));
    await _pumpUntilFound(tester, find.text('서울새솔초등학교'));
    await tester.tap(find.text('서울새솔초등학교'));
    await tester.enterText(find.widgetWithText(TextField, '이름'), '김하준');
    await tester.tap(find.text('3학년'));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('시작하기').last);

    await _pumpUntilFound(tester, find.text('3학년 한자쏘옥'));
    await tester.tap(find.text('시작하기').last);

    await _pumpUntilFound(tester, find.text('안녕하세요, 김하준!'));
    expect(find.text('서울새솔초등학교 · 3학년'), findsOneWidget);

    await _tapVisibleText(tester, '오늘의 한자 시작');
    await _pumpUntilFound(tester, find.text('직접 써보기'));

    expect(find.text('채점받기'), findsOneWidget);
  });

  testWidgets('mixed quiz completes and navigates to result', (tester) async {
    final challengeRepository = _FakeChallengeResultRepository();
    await tester.pumpWidget(
      _demoApp(
        progressRepository: _FakeLearningProgressRepository(
          completedForStudent: _characters.map((item) => item.id).toSet(),
        ),
        challengeRepository: challengeRepository,
      ),
    );
    await _settleStartup(tester);

    appRouter.go(RoutePaths.quizPlayFor('mixed'));
    await _pumpUntilFound(tester, find.text('혼합 퀴즈'));

    final answers = <String>[
      _characters[0].sound,
      _characters[0].meaning,
      _characters[0].character,
      _characters[1].sound,
      _characters[1].meaning,
      _characters[1].character,
      _characters[2].sound,
      _characters[2].meaning,
      _characters[2].character,
      _characters[3].sound,
    ];
    for (var index = 0; index < answers.length; index += 1) {
      await _tapQuizAnswer(tester, answers[index]);
      await tester.pump(const Duration(milliseconds: 1000));
      await _tapFilledButtonText(
        tester,
        index == answers.length - 1 ? '결과 저장' : '다음 문제',
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    await _pumpUntilFound(tester, find.text('혼합 퀴즈 완료'));
    expect(
      challengeRepository.savedResults.single.mode,
      ChallengeMode.quizMixed,
    );
    expect(find.text('다시 도전'), findsOneWidget);
    await _scrollUntilTextVisible(tester, '랭킹 보기');
    expect(find.text('랭킹 보기'), findsOneWidget);
  });

  testWidgets('speed choice game completes and navigates to result', (
    tester,
  ) async {
    final challengeRepository = _FakeChallengeResultRepository();
    await tester.pumpWidget(
      _demoApp(
        progressRepository: _FakeLearningProgressRepository(
          completedForStudent: _characters.map((item) => item.id).toSet(),
        ),
        challengeRepository: challengeRepository,
      ),
    );
    await _settleStartup(tester);

    appRouter.go(RoutePaths.challengeSpeedGame);
    await _pumpUntilFound(tester, find.text('뜻 보고 한자 선택'));

    for (final item in _characters) {
      await _tapFilledButtonText(tester, item.character);
      await tester.pumpAndSettle();
    }

    await _pumpUntilFound(tester, find.text('뜻 보고 한자 선택 완료'));
    expect(
      challengeRepository.savedResults.single.mode,
      ChallengeMode.speedChoice,
    );
    expect(find.text('다시 도전'), findsOneWidget);
    await _scrollUntilTextVisible(tester, '도전으로');
    expect(find.text('도전으로'), findsOneWidget);
  });
}

Future<void> _settleStartup(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1100));
  await tester.pumpAndSettle();
}

Future<void> _tapVisibleText(WidgetTester tester, String text) async {
  final finder = find.text(text).last;
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

Future<void> _tapFilledButtonText(WidgetTester tester, String text) async {
  final finder = find.widgetWithText(FilledButton, text).last;
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

Future<void> _tapQuizAnswer(WidgetTester tester, String text) async {
  final textFinder = find.text(text).last;
  await tester.ensureVisible(textFinder);
  await tester.pump();
  final inkWell = find
      .ancestor(of: textFinder, matching: find.byType(InkWell))
      .last;
  await tester.tap(inkWell);
}

Future<void> _scrollUntilTextVisible(WidgetTester tester, String text) async {
  final finder = find.text(text);
  if (finder.evaluate().isNotEmpty) {
    await tester.ensureVisible(finder.last);
    await tester.pump();
    return;
  }
  await tester.scrollUntilVisible(
    finder,
    220,
    scrollable: find.byType(Scrollable).last,
  );
}

Widget _demoApp({
  _FakeLearningProgressRepository? progressRepository,
  _FakeChallengeResultRepository? challengeRepository,
}) {
  appRouter.go(RoutePaths.splash);
  return ProviderScope(
    overrides: [
      schoolRepositoryProvider.overrideWithValue(_FakeSchoolRepository()),
      contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
      learningProgressRepositoryProvider.overrideWithValue(
        progressRepository ?? _FakeLearningProgressRepository(),
      ),
      quizResultRepositoryProvider.overrideWithValue(
        _FakeQuizResultRepository(),
      ),
      gameResultRepositoryProvider.overrideWithValue(
        _FakeGameResultRepository(),
      ),
      challengeResultRepositoryProvider.overrideWithValue(
        challengeRepository ?? _FakeChallengeResultRepository(),
      ),
    ],
    child: const HanjaSoookApp(),
  );
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 80,
}) async {
  for (var i = 0; i < maxPumps; i += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
}

class _FakeSchoolRepository implements SchoolRepository {
  @override
  Future<AppUserProfile?> getCurrentProfile() async => null;

  @override
  Future<School?> getSchoolByStandardCode(String standardSchoolCode) async =>
      _school;

  @override
  Future<List<School>> searchSchools({
    required String keyword,
    String? regionName,
    int limit = 20,
  }) async {
    return keyword.trim().length < 2 ? const [] : const [_school];
  }

  @override
  Future<AppUserProfile> signInStudentWithSchool({
    required School school,
    required String displayName,
    required int grade,
  }) async {
    return AppUserProfile(
      id: 'student-1',
      displayName: displayName.trim(),
      schoolId: school.id,
      standardSchoolCode: school.standardSchoolCode,
      schoolName: school.schoolName,
      grade: grade,
      isDemo: true,
    );
  }

  @override
  Future<void> signOut() async {}
}

class _FakeContentRepository implements ContentRepository {
  @override
  Future<HanjaCharacter?> getTodayHanja({int? grade}) async =>
      _characters.first;

  @override
  Future<List<HanjaCharacter>> getTodayHanjaSet({
    int? grade,
    int limit = 4,
  }) async {
    return _characters.take(limit).toList();
  }

  @override
  Future<List<HanjaCharacter>> getHanjaList({int? grade, int? limit}) async {
    final items = grade == null
        ? _characters
        : _characters.where((item) => item.grade == grade).toList();
    return limit == null ? items : items.take(limit).toList();
  }

  @override
  Future<HanjaCharacter?> getHanjaById(String hanjaId) async {
    return _characters.where((item) => item.id == hanjaId).firstOrNull;
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
  _FakeLearningProgressRepository({Set<String>? completedForStudent})
    : _completedForStudent = {...?completedForStudent};

  final Set<String> _completedToday = {};
  final Set<String> _completedForStudent;

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
    return const [];
  }

  @override
  Future<bool> markHanjaCompleted({
    required String studentKey,
    required String learningDate,
    required String hanjaId,
  }) async {
    final wasNew = _completedToday.add(hanjaId);
    _completedForStudent.add(hanjaId);
    return wasNew;
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
  Future<int> getTotalXp({required String studentKey}) async => 120;

  @override
  Future<int> getXpForRef({
    required String studentKey,
    required String source,
    required String refId,
  }) async {
    return 0;
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
      completedAt: DateTime(2026, 6, 1),
    );
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
      completedAt: DateTime(2026, 6, 1),
    );
  }
}

class _FakeChallengeResultRepository implements ChallengeResultRepository {
  final List<ChallengeResult> savedResults = [];

  @override
  Future<ChallengeResult> saveChallengeResult({
    required String studentKey,
    required String learningDate,
    required ChallengeResultInput input,
    required int earnedXp,
  }) async {
    final result = ChallengeResult(
      id: 'challenge-result-${savedResults.length + 1}',
      studentKey: studentKey,
      learningDate: learningDate,
      mode: input.mode,
      score: input.score,
      correctCount: input.correctCount,
      totalCount: input.totalCount,
      timeSec: input.timeSec,
      flippedTileCount: input.flippedTileCount,
      earnedXp: earnedXp,
      completedAt: DateTime(2026, 6, 1),
    );
    savedResults.add(result);
    return result;
  }

  @override
  Future<ChallengeResult?> getChallengeResultById(String id) async {
    return savedResults.where((result) => result.id == id).firstOrNull;
  }

  @override
  Future<List<ChallengeResult>> getChallengeResults({
    Set<String>? studentKeys,
    String? learningDate,
  }) async {
    return savedResults;
  }

  @override
  Future<ChallengeResult?> getLatestChallengeResult({
    required String studentKey,
    ChallengeMode? mode,
  }) async {
    return null;
  }
}

const _school = School(
  id: 'school-1',
  standardSchoolCode: '1234567',
  schoolName: '서울새솔초등학교',
  schoolKind: '초등학교',
  regionName: '서울특별시',
  roadAddress: '서울특별시 중구 세종대로 1',
);

const _characters = <HanjaCharacter>[
  HanjaCharacter(
    id: 'HJ-1',
    character: '山',
    sound: '산',
    meaning: '메 산',
    strokeCount: 3,
    grade: 3,
    unitCode: '3-1',
    unitName: '1단원',
  ),
  HanjaCharacter(
    id: 'HJ-2',
    character: '水',
    sound: '수',
    meaning: '물 수',
    strokeCount: 4,
    grade: 3,
    unitCode: '3-1',
    unitName: '1단원',
  ),
  HanjaCharacter(
    id: 'HJ-3',
    character: '木',
    sound: '목',
    meaning: '나무 목',
    strokeCount: 4,
    grade: 3,
    unitCode: '3-1',
    unitName: '1단원',
  ),
  HanjaCharacter(
    id: 'HJ-4',
    character: '火',
    sound: '화',
    meaning: '불 화',
    strokeCount: 4,
    grade: 3,
    unitCode: '3-1',
    unitName: '1단원',
  ),
  HanjaCharacter(
    id: 'HJ-5',
    character: '土',
    sound: '토',
    meaning: '흙 토',
    strokeCount: 3,
    grade: 3,
    unitCode: '3-1',
    unitName: '1단원',
  ),
  HanjaCharacter(
    id: 'HJ-6',
    character: '日',
    sound: '일',
    meaning: '날 일',
    strokeCount: 4,
    grade: 3,
    unitCode: '3-1',
    unitName: '1단원',
  ),
];
