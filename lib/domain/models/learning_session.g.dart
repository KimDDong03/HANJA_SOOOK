// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LearningSession _$LearningSessionFromJson(Map<String, dynamic> json) =>
    _LearningSession(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      mode: $enumDecode(_$LearningModeEnumMap, json['mode']),
      grade: (json['grade'] as num?)?.toInt(),
      unitCode: json['unit_code'] as String?,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
      score: (json['score'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      timeSec: (json['time_sec'] as num?)?.toInt() ?? 0,
      earnedXp: (json['earned_xp'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$LearningSessionToJson(_LearningSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'mode': _$LearningModeEnumMap[instance.mode]!,
      'grade': instance.grade,
      'unit_code': instance.unitCode,
      'started_at': instance.startedAt?.toIso8601String(),
      'ended_at': instance.endedAt?.toIso8601String(),
      'score': instance.score,
      'accuracy': instance.accuracy,
      'time_sec': instance.timeSec,
      'earned_xp': instance.earnedXp,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$LearningModeEnumMap = {
  LearningMode.card: 'card',
  LearningMode.writing: 'writing',
  LearningMode.quiz: 'quiz',
  LearningMode.game: 'game',
};
