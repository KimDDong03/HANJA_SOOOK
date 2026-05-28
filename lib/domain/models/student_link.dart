class StudentLink {
  const StudentLink({
    required this.studentKey,
    required this.displayName,
    required this.relationType,
    required this.linkedAt,
    this.schoolName,
    this.grade,
  });

  final String studentKey;
  final String displayName;
  final String? schoolName;
  final int? grade;
  final String relationType;
  final DateTime linkedAt;
}
