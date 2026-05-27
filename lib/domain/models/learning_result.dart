import 'package:freezed_annotation/freezed_annotation.dart';

import 'learning_session.dart';

part 'learning_result.freezed.dart';
part 'learning_result.g.dart';

@freezed
abstract class LearningResult with _$LearningResult {
  const factory LearningResult({
    String? id,
    @JsonKey(name: 'session_id') String? sessionId,
    @JsonKey(name: 'hanja_id') String? hanjaId,
    required LearningMode mode,
    @Default(0) int score,
    @Default(0) double accuracy,
    @Default(0) int stars,
    @JsonKey(name: 'time_sec') @Default(0) int timeSec,
    @JsonKey(name: 'earned_xp') @Default(0) int earnedXp,
    @Default(0) int coins,
    @JsonKey(name: 'correct_count') @Default(0) int correctCount,
    @JsonKey(name: 'total_count') @Default(0) int totalCount,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
  }) = _LearningResult;

  factory LearningResult.fromJson(Map<String, dynamic> json) =>
      _$LearningResultFromJson(json);
}
