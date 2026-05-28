import '../../domain/models/student_link.dart';
import '../../domain/repositories/student_link_repository.dart';
import '../local/app_database.dart';

class StudentLinkRepositoryImpl implements StudentLinkRepository {
  const StudentLinkRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<void> saveStudentLink(StudentLink link) {
    return _database.saveStudentLink(
      studentKey: link.studentKey,
      displayName: link.displayName,
      schoolName: link.schoolName,
      grade: link.grade,
      relationType: link.relationType,
      linkedAt: link.linkedAt,
    );
  }

  @override
  Future<List<StudentLink>> getStudentLinks({
    required String relationType,
  }) async {
    final rows = await _database.getStudentLinks(relationType: relationType);
    return [
      for (final row in rows)
        StudentLink(
          studentKey: row.studentKey,
          displayName: row.displayName,
          schoolName: row.schoolName,
          grade: row.grade,
          relationType: row.relationType,
          linkedAt: row.linkedAt,
        ),
    ];
  }
}
