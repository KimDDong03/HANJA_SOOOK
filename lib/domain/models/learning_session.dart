import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_session.freezed.dart';
part 'learning_session.g.dart';

@JsonEnum()
enum LearningMode {
  @JsonValue('card')
  card,
  @JsonValue('writing')
  writing,
  @JsonValue('quiz')
  quiz,
  @JsonValue('game')
  game,
}

@freezed
abstract class LearningSession with _$LearningSession {
  const factory LearningSession({
    String? id,
    @JsonKey(name: 'user_id') required String userId,
    required LearningMode mode,
    int? grade,
    @JsonKey(name: 'unit_code') String? unitCode,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'ended_at') DateTime? endedAt,
    @Default(0) int score,
    @Default(0) double accuracy,
    @JsonKey(name: 'time_sec') @Default(0) int timeSec,
    @JsonKey(name: 'earned_xp') @Default(0) int earnedXp,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _LearningSession;

  factory LearningSession.fromJson(Map<String, dynamic> json) =>
      _$LearningSessionFromJson(json);
}
