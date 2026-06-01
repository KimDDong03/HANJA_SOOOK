import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/domain/models/class_room.dart';
import 'package:hanja_soook/domain/repositories/class_room_repository.dart';
import 'package:hanja_soook/domain/services/class_participation_service.dart';

void main() {
  test(
    'ClassParticipationService finds joined classes through repository',
    () async {
      const service = ClassParticipationService();
      final repository = _FakeClassRoomRepository();

      final joinedClasses = await service.getJoinedClasses(
        classRepository: repository,
        studentKey: 'student-1',
      );
      final primaryClass = await service.findPrimaryJoinedClass(
        classRepository: repository,
        studentKey: 'student-1',
      );

      expect(joinedClasses, hasLength(1));
      expect(primaryClass?.className, '3학년 1반');
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
        classCode: 'HSCLASS1',
        createdAt: DateTime(2026, 5, 30),
      ),
      ClassRoom(
        id: 'class-2',
        className: '3학년 2반',
        classCode: 'HSCLASS2',
        createdAt: DateTime(2026, 5, 30),
      ),
    ];
  }

  @override
  Future<List<ClassMember>> getClassMembers({required String classId}) async {
    if (classId == 'class-1') {
      return [
        ClassMember(
          classId: classId,
          studentKey: 'student-1',
          displayName: '김하준',
          joinedAt: DateTime(2026, 5, 30),
        ),
      ];
    }
    return const [];
  }

  @override
  Future<void> saveClass(ClassRoom classRoom) async {}

  @override
  Future<void> saveClassMember(ClassMember member) async {}
}
