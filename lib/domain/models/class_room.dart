class ClassRoom {
  const ClassRoom({
    required this.id,
    required this.className,
    required this.classCode,
    required this.createdAt,
    this.schoolName,
    this.grade,
  });

  final String id;
  final String className;
  final String classCode;
  final String? schoolName;
  final int? grade;
  final DateTime createdAt;
}

class ClassMember {
  const ClassMember({
    required this.classId,
    required this.studentKey,
    required this.displayName,
    required this.joinedAt,
    this.schoolName,
    this.grade,
  });

  final String classId;
  final String studentKey;
  final String displayName;
  final DateTime joinedAt;
  final String? schoolName;
  final int? grade;
}
