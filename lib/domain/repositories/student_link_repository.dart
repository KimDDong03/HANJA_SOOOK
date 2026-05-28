import '../models/student_link.dart';

abstract class StudentLinkRepository {
  Future<void> saveStudentLink(StudentLink link);

  Future<List<StudentLink>> getStudentLinks({required String relationType});
}
