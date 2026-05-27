import 'package:freezed_annotation/freezed_annotation.dart';

part 'writing_attempt.freezed.dart';
part 'writing_attempt.g.dart';

@JsonEnum()
enum WritingScoringMode {
  @JsonValue('guided')
  guided,
  @JsonValue('free')
  free,
  @JsonValue('fallback')
  fallback,
}

@freezed
abstract class WritingAttempt with _$WritingAttempt {
  const factory WritingAttempt({
    String? id,
    @JsonKey(name: 'session_id') String? sessionId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'hanja_id') String? hanjaId,
    @Default(0) double accuracy,
    @Default(0) int stars,
    @JsonKey(name: 'expected_stroke_count') int? expectedStrokeCount,
    @JsonKey(name: 'user_stroke_count') int? userStrokeCount,
    @JsonKey(name: 'time_sec') @Default(0) int timeSec,
    @JsonKey(name: 'scoring_mode')
    @Default(WritingScoringMode.fallback)
    WritingScoringMode scoringMode,
    @JsonKey(name: 'raw_path_saved') @Default(false) bool rawPathSaved,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _WritingAttempt;

  factory WritingAttempt.fromJson(Map<String, dynamic> json) =>
      _$WritingAttemptFromJson(json);
}
