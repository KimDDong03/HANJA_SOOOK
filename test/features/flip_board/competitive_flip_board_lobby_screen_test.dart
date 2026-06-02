import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/repositories/class_room_repository_provider.dart';
import 'package:hanja_soook/data/repositories/student_link_repository_provider.dart';
import 'package:hanja_soook/domain/models/app_user_profile.dart';
import 'package:hanja_soook/domain/models/class_room.dart';
import 'package:hanja_soook/domain/models/student_link.dart';
import 'package:hanja_soook/domain/repositories/class_room_repository.dart';
import 'package:hanja_soook/domain/repositories/student_link_repository.dart';
import 'package:hanja_soook/features/auth/current_profile_controller.dart';
import 'package:hanja_soook/features/flip_board/competitive_flip_board_lobby_screen.dart';

void main() {
  testWidgets('competitive flip board lobby requires a joined class room', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        classRoomRepositoryProvider.overrideWithValue(
          _FakeClassRoomRepository(hasMember: false),
        ),
        studentLinkRepositoryProvider.overrideWithValue(
          _FakeStudentLinkRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(currentProfileProvider.notifier)
        .setProfile(
          const AppUserProfile(id: 'student-1', displayName: '김하준', grade: 3),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CompetitiveFlipBoardLobbyScreen()),
      ),
    );
    await _pumpUntilFound(tester, find.text('참여한 반이 필요해요'));

    expect(find.text('경쟁 판뒤집기'), findsOneWidget);
    expect(find.text('반 코드로 참여하기'), findsOneWidget);
    expect(find.text('새 방 만들기'), findsNothing);
  });

  testWidgets(
    'competitive flip board lobby shows room actions for class member',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          classRoomRepositoryProvider.overrideWithValue(
            _FakeClassRoomRepository(hasMember: true),
          ),
          studentLinkRepositoryProvider.overrideWithValue(
            _FakeStudentLinkRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(currentProfileProvider.notifier)
          .setProfile(
            const AppUserProfile(id: 'student-1', displayName: '김하준', grade: 3),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: CompetitiveFlipBoardLobbyScreen()),
        ),
      );
      await _pumpUntilFound(tester, find.text('새 방 만들기'));

      expect(find.text('3학년 1반 대결방'), findsOneWidget);
      expect(find.text('코드로 입장'), findsOneWidget);
      expect(find.text('방 입장'), findsOneWidget);
      expect(find.text('시작'), findsNothing);

      await tester.tap(find.text('새 방 만들기'));
      await tester.pump();

      expect(find.text('대기방'), findsOneWidget);
      expect(find.text('준비'), findsOneWidget);
      expect(find.text('시작'), findsOneWidget);
    },
  );
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
  _FakeClassRoomRepository({required this.hasMember});

  final bool hasMember;

  @override
  Future<List<ClassRoom>> getClasses() async {
    return [
      ClassRoom(
        id: 'class-1',
        className: '3학년 1반',
        classCode: 'HSCLASS1',
        schoolName: '한빛초등학교',
        grade: 3,
        createdAt: DateTime(2026, 5, 30),
      ),
    ];
  }

  @override
  Future<List<ClassMember>> getClassMembers({required String classId}) async {
    if (!hasMember) {
      return const [];
    }
    return [
      ClassMember(
        classId: classId,
        studentKey: 'student-1',
        displayName: '김하준',
        joinedAt: DateTime(2026, 5, 30),
      ),
    ];
  }

  @override
  Future<void> saveClass(ClassRoom classRoom) async {}

  @override
  Future<void> saveClassMember(ClassMember member) async {}
}
