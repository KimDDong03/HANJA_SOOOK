enum HanjaPracticeSource {
  dailySession('daily_session'),
  reviewSession('review_session'),
  weaknessSession('weakness_session'),
  quiz('quiz'),
  speedQuiz('speed_quiz');

  const HanjaPracticeSource(this.storageValue);

  final String storageValue;

  static HanjaPracticeSource fromStorageValue(String value) {
    return HanjaPracticeSource.values.firstWhere(
      (source) => source.storageValue == value,
      orElse: () => HanjaPracticeSource.quiz,
    );
  }
}

enum HanjaPracticeActivityType {
  hanjaToHun('hanja_to_hun'),
  hunToHanja('hun_to_hanja'),
  writing('writing'),
  mixed('mixed'),
  hint('hint'),
  reviewComplete('review_complete'),
  weaknessPass('weakness_pass');

  const HanjaPracticeActivityType(this.storageValue);

  final String storageValue;

  static HanjaPracticeActivityType fromStorageValue(String value) {
    return HanjaPracticeActivityType.values.firstWhere(
      (type) => type.storageValue == value,
      orElse: () => HanjaPracticeActivityType.mixed,
    );
  }
}

enum HanjaPracticeResult {
  correct('correct'),
  incorrect('incorrect'),
  failed('failed'),
  hinted('hinted'),
  passed('passed');

  const HanjaPracticeResult(this.storageValue);

  final String storageValue;

  static HanjaPracticeResult fromStorageValue(String value) {
    return HanjaPracticeResult.values.firstWhere(
      (result) => result.storageValue == value,
      orElse: () => HanjaPracticeResult.incorrect,
    );
  }
}

enum HanjaWeaknessType {
  hunMeaning('hun_meaning', '훈음'),
  hanjaRecognition('hanja_recognition', '한자 선택'),
  writing('writing', '쓰기'),
  shapeConfusion('shape_confusion', '모양 혼동'),
  retention('retention', '기억 유지');

  const HanjaWeaknessType(this.storageValue, this.label);

  final String storageValue;
  final String label;

  static HanjaWeaknessType fromStorageValue(String value) {
    return HanjaWeaknessType.values.firstWhere(
      (type) => type.storageValue == value,
      orElse: () => HanjaWeaknessType.retention,
    );
  }
}

enum HanjaWeaknessStatus {
  watching('watching'),
  active('active'),
  resolved('resolved');

  const HanjaWeaknessStatus(this.storageValue);

  final String storageValue;

  static HanjaWeaknessStatus fromStorageValue(String value) {
    return HanjaWeaknessStatus.values.firstWhere(
      (status) => status.storageValue == value,
      orElse: () => HanjaWeaknessStatus.watching,
    );
  }
}

class HanjaPracticeEventInput {
  const HanjaPracticeEventInput({
    required this.studentKey,
    required this.hanjaId,
    required this.learningDate,
    required this.source,
    required this.activityType,
    required this.result,
    required this.scoreDelta,
    required this.createdAt,
    this.weaknessType,
    this.hintLevel,
    this.elapsedMs,
    this.confusedWithHanjaId,
  });

  final String studentKey;
  final String hanjaId;
  final String learningDate;
  final HanjaPracticeSource source;
  final HanjaPracticeActivityType activityType;
  final HanjaPracticeResult result;
  final HanjaWeaknessType? weaknessType;
  final int scoreDelta;
  final int? hintLevel;
  final int? elapsedMs;
  final String? confusedWithHanjaId;
  final DateTime createdAt;
}

class HanjaPracticeEvent {
  const HanjaPracticeEvent({
    required this.id,
    required this.studentKey,
    required this.hanjaId,
    required this.learningDate,
    required this.source,
    required this.activityType,
    required this.result,
    required this.scoreDelta,
    required this.createdAt,
    this.weaknessType,
    this.hintLevel,
    this.elapsedMs,
    this.confusedWithHanjaId,
  });

  final String id;
  final String studentKey;
  final String hanjaId;
  final String learningDate;
  final HanjaPracticeSource source;
  final HanjaPracticeActivityType activityType;
  final HanjaPracticeResult result;
  final HanjaWeaknessType? weaknessType;
  final int scoreDelta;
  final int? hintLevel;
  final int? elapsedMs;
  final String? confusedWithHanjaId;
  final DateTime createdAt;
}

class HanjaWeaknessRecord {
  const HanjaWeaknessRecord({
    required this.studentKey,
    required this.hanjaId,
    required this.weaknessType,
    required this.score,
    required this.status,
    required this.mistakeCount,
    required this.successStreak,
    required this.lastEventAt,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  final String studentKey;
  final String hanjaId;
  final HanjaWeaknessType weaknessType;
  final int score;
  final HanjaWeaknessStatus status;
  final int mistakeCount;
  final int successStreak;
  final DateTime lastEventAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  bool get isActive => status == HanjaWeaknessStatus.active;

  String get typeLabel => weaknessType.label;
}
