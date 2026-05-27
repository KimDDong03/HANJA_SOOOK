// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LearningResult _$LearningResultFromJson(Map<String, dynamic> json) =>
    _LearningResult(
      id: json['id'] as String?,
      sessionId: json['session_id'] as String?,
      hanjaId: json['hanja_id'] as String?,
      mode: $enumDecode(_$LearningModeEnumMap, json['mode']),
      score: (json['score'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      stars: (json['stars'] as num?)?.toInt() ?? 0,
      timeSec: (json['time_sec'] as num?)?.toInt() ?? 0,
      earnedXp: (json['earned_xp'] as num?)?.toInt() ?? 0,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$LearningResultToJson(_LearningResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_id': instance.sessionId,
      'hanja_id': instance.hanjaId,
      'mode': _$LearningModeEnumMap[instance.mode]!,
      'score': instance.score,
      'accuracy': instance.accuracy,
      'stars': instance.stars,
      'time_sec': instance.timeSec,
      'earned_xp': instance.earnedXp,
      'coins': instance.coins,
      'correct_count': instance.correctCount,
      'total_count': instance.totalCount,
      'completed_at': instance.completedAt?.toIso8601String(),
    };

const _$LearningModeEnumMap = {
  LearningMode.card: 'card',
  LearningMode.writing: 'writing',
  LearningMode.quiz: 'quiz',
  LearningMode.game: 'game',
};
