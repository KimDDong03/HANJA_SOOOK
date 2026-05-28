import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/local/app_database.dart';
import 'package:hanja_soook/data/repositories/class_room_repository_impl.dart';
import 'package:hanja_soook/domain/models/class_room.dart';

void main() {
  group('ClassRoomRepositoryImpl', () {
    late AppDatabase database;
    late ClassRoomRepositoryImpl repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = ClassRoomRepositoryImpl(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('saves classes and class members locally', () async {
      await repository.saveClass(
        ClassRoom(
          id: 'class-1',
          className: '3학년 1반',
          classCode: 'HC1.sample',
          schoolName: '서울새솔초등학교',
          grade: 3,
          createdAt: DateTime(2026, 5, 28),
        ),
      );
      await repository.saveClassMember(
        ClassMember(
          classId: 'class-1',
          studentKey: 'student-1',
          displayName: '김하준',
          schoolName: '서울새솔초등학교',
          grade: 3,
          joinedAt: DateTime(2026, 5, 28),
        ),
      );

      final classes = await repository.getClasses();
      final members = await repository.getClassMembers(classId: 'class-1');

      expect(classes, hasLength(1));
      expect(classes.single.className, '3학년 1반');
      expect(members, hasLength(1));
      expect(members.single.displayName, '김하준');
    });
  });
}
