import '../../domain/models/class_room.dart';
import '../../domain/repositories/class_room_repository.dart';
import '../local/app_database.dart';

class ClassRoomRepositoryImpl implements ClassRoomRepository {
  const ClassRoomRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<void> saveClass(ClassRoom classRoom) {
    return _database.saveLocalClass(
      id: classRoom.id,
      className: classRoom.className,
      classCode: classRoom.classCode,
      schoolName: classRoom.schoolName,
      grade: classRoom.grade,
      createdAt: classRoom.createdAt,
    );
  }

  @override
  Future<List<ClassRoom>> getClasses() async {
    final rows = await _database.getLocalClasses();
    return [
      for (final row in rows)
        ClassRoom(
          id: row.id,
          className: row.className,
          classCode: row.classCode,
          schoolName: row.schoolName,
          grade: row.grade,
          createdAt: row.createdAt,
        ),
    ];
  }

  @override
  Future<void> saveClassMember(ClassMember member) {
    return _database.saveLocalClassMember(
      classId: member.classId,
      studentKey: member.studentKey,
      displayName: member.displayName,
      schoolName: member.schoolName,
      grade: member.grade,
      joinedAt: member.joinedAt,
    );
  }

  @override
  Future<List<ClassMember>> getClassMembers({required String classId}) async {
    final rows = await _database.getLocalClassMembers(classId: classId);
    return [
      for (final row in rows)
        ClassMember(
          classId: row.classId,
          studentKey: row.studentKey,
          displayName: row.displayName,
          schoolName: row.schoolName,
          grade: row.grade,
          joinedAt: row.joinedAt,
        ),
    ];
  }
}
