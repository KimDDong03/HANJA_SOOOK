import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/repositories/challenge_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/class_room_repository_provider.dart';
import 'package:hanja_soook/data/repositories/content_repository_provider.dart';
import 'package:hanja_soook/data/repositories/learning_progress_repository_provider.dart';
import 'package:hanja_soook/domain/models/app_user_profile.dart';
import 'package:hanja_soook/domain/models/challenge_result.dart';
import 'package:hanja_soook/domain/models/class_room.dart';
import 'package:hanja_soook/domain/models/hanja_character.dart';
import 'package:hanja_soook/domain/models/hanja_example.dart';
import 'package:hanja_soook/domain/models/learning_progress_record.dart';
import 'package:hanja_soook/domain/models/quiz_question.dart';
import 'package:hanja_soook/domain/models/stroke_asset.dart';
import 'package:hanja_soook/domain/repositories/challenge_result_repository.dart';
import 'package:hanja_soook/domain/repositories/class_room_repository.dart';
import 'package:hanja_soook/domain/repositories/content_repository.dart';
import 'package:hanja_soook/domain/repositories/learning_progress_repository.dart';
import 'package:hanja_soook/features/auth/current_profile_controller.dart';
import 'package:hanja_soook/features/teacher_preview/teacher_preview_screen.dart';

void main() {
  testWidgets('TeacherPreviewScreen shows class code management', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        classRoomRepositoryProvider.overrideWithValue(
          _FakeClassRoomRepository(),
        ),
        contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
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
          const AppUserProfile(
            id: 'teacher-1',
            displayName: '담임',
            schoolName: '한빛초등학교',
            grade: 3,
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TeacherPreviewScreen()),
      ),
    );
    await _pumpUntilFound(tester, find.text('반 코드 관리'));

    expect(find.text('내 반 만들기'), findsOneWidget);
    expect(find.text('반 코드 보기'), findsOneWidget);
    expect(find.text('3학년 1반'), findsOneWidget);
    expect(find.text('참여 학생 수 2명'), findsOneWidget);
    expect(find.text('반 코드 복사'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('실제 학생 현황'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('실제 학생 현황'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('학생별 실제 기록'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('학생별 실제 기록'), findsOneWidget);
    expect(find.text('김하준'), findsOneWidget);
    expect(find.text('이서윤'), findsOneWidget);
    expect(find.text('오늘 3점 · 오늘 XP 30'), findsOneWidget);
    expect(find.text('오늘 5점 · 오늘 XP 45'), findsOneWidget);
    expect(find.text('2판'), findsWidgets);
  });

  testWidgets('TeacherPreviewScreen creates a class and shows its code', (
    tester,
  ) async {
    final classRepository = _MutableClassRoomRepository();
    final container = ProviderContainer(
      overrides: [
        classRoomRepositoryProvider.overrideWithValue(classRepository),
        contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
        challengeResultRepositoryProvider.overrideWithValue(
          _EmptyChallengeResultRepository(),
        ),
        learningProgressRepositoryProvider.overrideWithValue(
          _FakeLearningProgressRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TeacherPreviewScreen()),
      ),
    );
    await _pumpUntilFound(tester, find.text('반 코드 관리'));

    await tester.enterText(find.byType(TextField).first, '3학년 2반');
    await tester.pump();
    await tester.tap(find.text('반 코드 만들기'));
    await _pumpUntilFound(tester, find.text('3학년 2반'));

    expect(classRepository.classes.single.className, '3학년 2반');
    expect(classRepository.classes.single.classCode.startsWith('HC1.'), isTrue);
    expect(find.text('반 코드 복사'), findsOneWidget);
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 20,
}) async {
  for (var i = 0; i < maxPumps; i += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
}

class _FakeClassRoomRepository implements ClassRoomRepository {
  @override
  Future<List<ClassRoom>> getClasses() async {
    return [
      ClassRoom(
        id: 'class-1',
        className: '3학년 1반',
        classCode: 'HC1.sample',
        schoolName: '한빛초등학교',
        grade: 3,
        createdAt: DateTime(2026, 5, 30),
      ),
    ];
  }

  @override
  Future<List<ClassMember>> getClassMembers({required String classId}) async {
    return [
      ClassMember(
        classId: classId,
        studentKey: 'student-1',
        displayName: '김하준',
        joinedAt: DateTime(2026, 5, 30),
      ),
      ClassMember(
        classId: classId,
        studentKey: 'student-2',
        displayName: '이서윤',
        joinedAt: DateTime(2026, 5, 30),
      ),
    ];
  }

  @override
  Future<void> saveClass(ClassRoom classRoom) async {}

  @override
  Future<void> saveClassMember(ClassMember member) async {}
}

class _MutableClassRoomRepository implements ClassRoomRepository {
  final classes = <ClassRoom>[];

  @override
  Future<List<ClassRoom>> getClasses() async => classes;

  @override
  Future<List<ClassMember>> getClassMembers({required String classId}) async {
    return const [];
  }

  @override
  Future<void> saveClass(ClassRoom classRoom) async {
    classes.add(classRoom);
  }

  @override
  Future<void> saveClassMember(ClassMember member) async {}
}

class _FakeContentRepository implements ContentRepository {
  @override
  Future<HanjaCharacter?> getTodayHanja({int? grade}) async => _hanja.first;

  @override
  Future<List<HanjaCharacter>> getTodayHanjaSet({
    int? grade,
    int limit = 4,
  }) async {
    return _hanja.take(limit).toList();
  }

  @override
  Future<List<HanjaCharacter>> getHanjaList({int? grade, int? limit}) async {
    return limit == null ? _hanja : _hanja.take(limit).toList();
  }

  @override
  Future<HanjaCharacter?> getHanjaById(String hanjaId) async => null;

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

class _FakeChallengeResultRepository implements ChallengeResultRepository {
  @override
  Future<List<ChallengeResult>> getChallengeResults({
    Set<String>? studentKeys,
    String? learningDate,
  }) async {
    final results = [
      ChallengeResult(
        id: 'result-1',
        studentKey: 'student-1',
        learningDate: learningDate ?? '20260530',
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
        studentKey: 'student-2',
        learningDate: learningDate ?? '20260530',
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
    if (studentKeys == null) {
      return results;
    }
    return results
        .where((result) => studentKeys.contains(result.studentKey))
        .toList();
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
      'student-1' => 70,
      'student-2' => 90,
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

const _hanja = [
  HanjaCharacter(
    id: 'HJ-1',
    character: '山',
    sound: '산',
    meaning: '메',
    grade: 3,
  ),
];
