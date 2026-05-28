import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/local/app_database.dart';
import 'package:hanja_soook/data/repositories/student_link_repository_impl.dart';
import 'package:hanja_soook/domain/models/student_link.dart';

void main() {
  group('StudentLinkRepositoryImpl', () {
    late AppDatabase database;
    late StudentLinkRepositoryImpl repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = StudentLinkRepositoryImpl(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('saves and reads local student links by relation type', () async {
      await repository.saveStudentLink(
        StudentLink(
          studentKey: 'student-1',
          displayName: '김하준',
          schoolName: '서울새솔초등학교',
          grade: 3,
          relationType: 'guardian',
          linkedAt: DateTime(2026, 5, 28),
        ),
      );
      await repository.saveStudentLink(
        StudentLink(
          studentKey: 'student-2',
          displayName: '이서윤',
          relationType: 'teacher',
          linkedAt: DateTime(2026, 5, 28),
        ),
      );

      final links = await repository.getStudentLinks(relationType: 'guardian');

      expect(links, hasLength(1));
      expect(links.single.studentKey, 'student-1');
      expect(links.single.displayName, '김하준');
    });
  });
}
