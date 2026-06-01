import '../models/class_room.dart';
import '../repositories/class_room_repository.dart';

class ClassParticipationService {
  const ClassParticipationService();

  Future<List<ClassRoom>> getJoinedClasses({
    required ClassRoomRepository classRepository,
    required String studentKey,
  }) async {
    final classes = await classRepository.getClasses();
    final joinedClasses = <ClassRoom>[];
    for (final classRoom in classes) {
      final members = await classRepository.getClassMembers(
        classId: classRoom.id,
      );
      if (members.any((member) => member.studentKey == studentKey)) {
        joinedClasses.add(classRoom);
      }
    }
    return joinedClasses;
  }

  Future<ClassRoom?> findPrimaryJoinedClass({
    required ClassRoomRepository classRepository,
    required String studentKey,
  }) async {
    final joinedClasses = await getJoinedClasses(
      classRepository: classRepository,
      studentKey: studentKey,
    );
    return joinedClasses.isEmpty ? null : joinedClasses.first;
  }
}
