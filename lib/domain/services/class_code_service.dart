import 'dart:convert';

import '../models/app_user_profile.dart';
import '../models/class_room.dart';

class ClassCodeService {
  const ClassCodeService();

  static const prefix = 'HC1';

  ClassRoom createClass({
    required String className,
    required AppUserProfile? teacherProfile,
    required DateTime createdAt,
  }) {
    final normalizedName = className.trim();
    if (normalizedName.isEmpty) {
      throw const FormatException('class name is required');
    }
    final id =
        '${createdAt.microsecondsSinceEpoch}-${normalizedName.hashCode.abs()}';
    final classRoom = ClassRoom(
      id: id,
      className: normalizedName,
      classCode: '',
      schoolName: teacherProfile?.schoolName,
      grade: teacherProfile?.grade,
      createdAt: createdAt,
    );
    return ClassRoom(
      id: id,
      className: normalizedName,
      classCode: encodeClass(classRoom),
      schoolName: classRoom.schoolName,
      grade: classRoom.grade,
      createdAt: createdAt,
    );
  }

  String encodeClass(ClassRoom classRoom) {
    final payload = {
      'classId': classRoom.id,
      'className': classRoom.className,
      'schoolName': classRoom.schoolName,
      'grade': classRoom.grade,
    };
    final encoded = base64Url.encode(utf8.encode(jsonEncode(payload)));
    return '$prefix.$encoded';
  }

  ClassMember decodeMember({
    required String code,
    required AppUserProfile studentProfile,
    required DateTime joinedAt,
  }) {
    final normalized = code.trim();
    final parts = normalized.split('.');
    if (parts.length != 2 || parts.first != prefix || parts.last.isEmpty) {
      throw const FormatException('invalid class code');
    }

    final rawJson = utf8.decode(base64Url.decode(parts.last));
    final payload = jsonDecode(rawJson);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('invalid class payload');
    }
    final classId = payload['classId'];
    if (classId is! String || classId.trim().isEmpty) {
      throw const FormatException('invalid class payload');
    }

    return ClassMember(
      classId: classId,
      studentKey: studentProfile.id,
      displayName: studentProfile.displayName,
      schoolName: studentProfile.schoolName,
      grade: studentProfile.grade,
      joinedAt: joinedAt,
    );
  }
}
