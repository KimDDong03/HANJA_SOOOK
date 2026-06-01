class LearningProgressRecord {
  const LearningProgressRecord({
    required this.studentKey,
    required this.learningDate,
    required this.hanjaId,
    required this.completedAt,
  });

  final String studentKey;
  final String learningDate;
  final String hanjaId;
  final DateTime completedAt;
}
