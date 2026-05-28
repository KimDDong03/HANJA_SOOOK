import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/domain/models/app_user_profile.dart';
import 'package:hanja_soook/domain/services/class_code_service.dart';

void main() {
  group('ClassCodeService', () {
    const service = ClassCodeService();

    test('creates a class code and decodes a student member', () {
      final classRoom = service.createClass(
        className: '3학년 1반',
        teacherProfile: const AppUserProfile(
          id: 'teacher-1',
          displayName: '교사',
          schoolName: '서울새솔초등학교',
          grade: 3,
        ),
        createdAt: DateTime(2026, 5, 28),
      );
      final member = service.decodeMember(
        code: classRoom.classCode,
        studentProfile: const AppUserProfile(
          id: 'student-1',
          displayName: '김하준',
          schoolName: '서울새솔초등학교',
          grade: 3,
        ),
        joinedAt: DateTime(2026, 5, 28),
      );

      expect(classRoom.classCode.startsWith('HC1.'), isTrue);
      expect(classRoom.className, '3학년 1반');
      expect(member.classId, classRoom.id);
      expect(member.studentKey, 'student-1');
      expect(member.displayName, '김하준');
    });

    test('rejects invalid class codes', () {
      expect(
        () => service.decodeMember(
          code: 'bad-code',
          studentProfile: const AppUserProfile(
            id: 'student-1',
            displayName: '김하준',
          ),
          joinedAt: DateTime(2026, 5, 28),
        ),
        throwsFormatException,
      );
    });
  });
}
