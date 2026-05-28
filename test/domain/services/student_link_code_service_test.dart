import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/domain/models/app_user_profile.dart';
import 'package:hanja_soook/domain/services/student_link_code_service.dart';

void main() {
  group('StudentLinkCodeService', () {
    const service = StudentLinkCodeService();

    test('encodes and decodes a student link payload', () {
      final code = service.encodeProfile(
        const AppUserProfile(
          id: 'student-1',
          displayName: '김하준',
          schoolName: '서울새솔초등학교',
          grade: 3,
        ),
      );

      final link = service.decode(
        code: code,
        relationType: 'guardian',
        linkedAt: DateTime(2026, 5, 28),
      );

      expect(code.startsWith('HS1.'), isTrue);
      expect(link.studentKey, 'student-1');
      expect(link.displayName, '김하준');
      expect(link.schoolName, '서울새솔초등학교');
      expect(link.grade, 3);
      expect(link.relationType, 'guardian');
    });

    test('rejects invalid student link codes', () {
      expect(
        () => service.decode(
          code: 'bad-code',
          relationType: 'guardian',
          linkedAt: DateTime(2026, 5, 28),
        ),
        throwsFormatException,
      );
    });
  });
}
