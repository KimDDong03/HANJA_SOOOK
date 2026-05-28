import '../models/class_room.dart';

abstract class ClassRoomRepository {
  Future<void> saveClass(ClassRoom classRoom);

  Future<List<ClassRoom>> getClasses();

  Future<void> saveClassMember(ClassMember member);

  Future<List<ClassMember>> getClassMembers({required String classId});
}
