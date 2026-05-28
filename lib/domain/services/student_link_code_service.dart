import 'dart:convert';

import '../models/app_user_profile.dart';
import '../models/student_link.dart';

class StudentLinkCodeService {
  const StudentLinkCodeService();

  static const prefix = 'HS1';

  String encodeProfile(AppUserProfile profile) {
    final payload = {
      'studentKey': profile.id,
      'displayName': profile.displayName,
      'schoolName': profile.schoolName,
      'grade': profile.grade,
    };
    final encoded = base64Url.encode(utf8.encode(jsonEncode(payload)));
    return '$prefix.$encoded';
  }

  StudentLink decode({
    required String code,
    required String relationType,
    required DateTime linkedAt,
  }) {
    final normalized = code.trim();
    final parts = normalized.split('.');
    if (parts.length != 2 || parts.first != prefix || parts.last.isEmpty) {
      throw const FormatException('invalid student link code');
    }

    final rawJson = utf8.decode(base64Url.decode(parts.last));
    final payload = jsonDecode(rawJson);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('invalid student link payload');
    }

    final studentKey = payload['studentKey'];
    final displayName = payload['displayName'];
    if (studentKey is! String ||
        studentKey.trim().isEmpty ||
        displayName is! String ||
        displayName.trim().isEmpty) {
      throw const FormatException('invalid student link payload');
    }

    return StudentLink(
      studentKey: studentKey,
      displayName: displayName,
      schoolName: payload['schoolName'] as String?,
      grade: payload['grade'] as int?,
      relationType: relationType,
      linkedAt: linkedAt,
    );
  }
}
