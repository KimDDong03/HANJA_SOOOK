import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/repositories/class_room_repository_provider.dart';
import 'package:hanja_soook/data/repositories/school_repository_provider.dart';
import 'package:hanja_soook/data/repositories/student_link_repository_provider.dart';
import 'package:hanja_soook/domain/models/app_user_profile.dart';
import 'package:hanja_soook/domain/models/class_room.dart';
import 'package:hanja_soook/domain/models/school.dart';
import 'package:hanja_soook/domain/models/student_link.dart';
import 'package:hanja_soook/domain/repositories/class_room_repository.dart';
import 'package:hanja_soook/domain/repositories/school_repository.dart';
import 'package:hanja_soook/domain/repositories/student_link_repository.dart';
import 'package:hanja_soook/features/auth/current_profile_controller.dart';
import 'package:hanja_soook/features/settings/settings_screen.dart';

void main() {
  testWidgets('teacher settings explains local demo storage accurately', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SettingsScreen(role: 'teacher')),
      ),
    );

    expect(find.text('미리보기 도구'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('미리보기에서 만든 반 코드는 이 기기에 데모 데이터로 저장돼요. 실제 과제 배포나 알림은 실행되지 않아요.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('미리보기에서 만든 반 코드는 이 기기에 데모 데이터로 저장돼요. 실제 과제 배포나 알림은 실행되지 않아요.'),
      findsOneWidget,
    );
  });

  testWidgets('student settings opens own student link code sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          schoolRepositoryProvider.overrideWithValue(_FakeSchoolRepository()),
          classRoomRepositoryProvider.overrideWithValue(
            _FakeClassRoomRepository(),
          ),
          studentLinkRepositoryProvider.overrideWithValue(
            _FakeStudentLinkRepository(),
          ),
        ],
        child: const MaterialApp(
          home: _SeedProfile(child: SettingsScreen(role: 'student')),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('내 학생 연결 코드'), findsOneWidget);

    await tester.tap(find.text('내 학생 연결 코드'));
    await tester.pumpAndSettle();

    expect(
      find.text('보호자에게 이 코드를 전달하면 보호자 기기에서 학생을 연결할 수 있어요.'),
      findsOneWidget,
    );
    expect(find.text('코드 복사'), findsOneWidget);
  });

  testWidgets('student can edit name grade school and avatar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          schoolRepositoryProvider.overrideWithValue(_FakeSchoolRepository()),
          classRoomRepositoryProvider.overrideWithValue(
            _FakeClassRoomRepository(),
          ),
          studentLinkRepositoryProvider.overrideWithValue(
            _FakeStudentLinkRepository(),
          ),
        ],
        child: const MaterialApp(
          home: _SeedProfile(child: SettingsScreen(role: 'student')),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('프로필 편집'));
    await tester.pumpAndSettle();

    expect(find.text('내 정보 바꾸기'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, '이름'), '김하준');
    await tester.tap(find.text('새싹'));
    await tester.tap(find.text('4학년'));
    await tester.enterText(find.widgetWithText(TextField, '학교 변경'), '새솔');
    await tester.tap(find.widgetWithText(OutlinedButton, '학교 검색'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('서울새솔초등학교'));
    await tester.pumpAndSettle();
    final saveButton = find.widgetWithText(FilledButton, '저장하기');
    await tester.ensureVisible(saveButton);
    await tester.pump();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('김하준'), findsOneWidget);
    expect(find.textContaining('4학년'), findsOneWidget);
    expect(find.textContaining('서울새솔초등학교'), findsWidgets);
  });
}

class _SeedProfile extends ConsumerStatefulWidget {
  const _SeedProfile({required this.child});

  final Widget child;

  @override
  ConsumerState<_SeedProfile> createState() => _SeedProfileState();
}

class _SeedProfileState extends ConsumerState<_SeedProfile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(currentProfileProvider.notifier)
          .setProfile(
            const AppUserProfile(
              id: 'student-1',
              displayName: '김동건',
              schoolId: 'school-old',
              standardSchoolCode: '1111111',
              schoolName: '서울한자초등학교',
              grade: 3,
              isDemo: true,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _FakeSchoolRepository implements SchoolRepository {
  @override
  Future<AppUserProfile?> getCurrentProfile() async => null;

  @override
  Future<School?> getSchoolByStandardCode(String standardSchoolCode) async {
    return standardSchoolCode == _school.standardSchoolCode ? _school : null;
  }

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

const _school = School(
  id: 'school-new',
  standardSchoolCode: '1234567',
  schoolName: '서울새솔초등학교',
  schoolKind: '초등학교',
  regionName: '서울특별시',
  roadAddress: '서울특별시 중구 세종대로 1',
);
