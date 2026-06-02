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
import 'package:hanja_soook/features/student_links/student_link_screen.dart';

void main() {
  testWidgets(
    'student link screen only shows student class panels for student role',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          classRoomRepositoryProvider.overrideWithValue(
            _FakeClassRoomRepository(),
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
          child: const MaterialApp(home: StudentLinkScreen()),
        ),
      );
      await _pumpUntilFound(tester, find.text('반 코드로 참여하기'));

      expect(find.text('학습 연결'), findsOneWidget);
      expect(find.text('내 학생 연결 코드'), findsOneWidget);
      expect(find.text('반 코드로 참여하기'), findsOneWidget);
      expect(find.text('3학년 1반'), findsOneWidget);
      expect(find.text('랭킹 보기'), findsOneWidget);
      expect(find.text('경쟁 판뒤집기'), findsOneWidget);
      expect(find.text('보호자 연결'), findsNothing);
      expect(find.text('연결된 학생'), findsNothing);

      final studentCodeTop = tester.getTopLeft(find.text('내 학생 연결 코드')).dy;
      final classJoinTop = tester.getTopLeft(find.text('반 코드로 참여하기')).dy;
      final joinedClassTop = tester.getTopLeft(find.text('참여한 반')).dy;
      expect(studentCodeTop, lessThan(classJoinTop));
      expect(classJoinTop, lessThan(joinedClassTop));
    },
  );

  testWidgets(
    'student link screen only shows guardian panels for parent role',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          classRoomRepositoryProvider.overrideWithValue(
            _FakeClassRoomRepository(),
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
            const AppUserProfile(id: 'parent-1', displayName: '김학부모', grade: 3),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: StudentLinkScreen(role: 'parent')),
        ),
      );
      await _pumpUntilFound(tester, find.text('보호자 연결'));

      expect(find.text('학생 연결'), findsWidgets);
      expect(find.text('보호자 연결'), findsOneWidget);
      expect(find.text('연결된 학생'), findsOneWidget);
      expect(find.text('내 학생 연결 코드'), findsNothing);
      expect(find.text('반 코드로 참여하기'), findsNothing);
      expect(find.text('참여한 반'), findsNothing);
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
