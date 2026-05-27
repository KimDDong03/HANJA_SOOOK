// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writing_attempt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WritingAttempt _$WritingAttemptFromJson(Map<String, dynamic> json) =>
    _WritingAttempt(
      id: json['id'] as String?,
      sessionId: json['session_id'] as String?,
      userId: json['user_id'] as String,
      hanjaId: json['hanja_id'] as String?,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      stars: (json['stars'] as num?)?.toInt() ?? 0,
      expectedStrokeCount: (json['expected_stroke_count'] as num?)?.toInt(),
      userStrokeCount: (json['user_stroke_count'] as num?)?.toInt(),
      timeSec: (json['time_sec'] as num?)?.toInt() ?? 0,
      scoringMode:
          $enumDecodeNullable(
            _$WritingScoringModeEnumMap,
            json['scoring_mode'],
          ) ??
          WritingScoringMode.fallback,
      rawPathSaved: json['raw_path_saved'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$WritingAttemptToJson(_WritingAttempt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_id': instance.sessionId,
      'user_id': instance.userId,
      'hanja_id': instance.hanjaId,
      'accuracy': instance.accuracy,
      'stars': instance.stars,
      'expected_stroke_count': instance.expectedStrokeCount,
      'user_stroke_count': instance.userStrokeCount,
      'time_sec': instance.timeSec,
      'scoring_mode': _$WritingScoringModeEnumMap[instance.scoringMode]!,
      'raw_path_saved': instance.rawPathSaved,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$WritingScoringModeEnumMap = {
  WritingScoringMode.guided: 'guided',
  WritingScoringMode.free: 'free',
  WritingScoringMode.fallback: 'fallback',
};
