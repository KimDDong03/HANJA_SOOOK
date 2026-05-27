// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GrowthState _$GrowthStateFromJson(Map<String, dynamic> json) => _GrowthState(
  userId: json['user_id'] as String,
  level: (json['level'] as num?)?.toInt() ?? 1,
  totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
  coins: (json['coins'] as num?)?.toInt() ?? 0,
  currentLevelRequiredXp:
      (json['current_level_required_xp'] as num?)?.toInt() ?? 0,
  nextLevelRequiredXp: (json['next_level_required_xp'] as num?)?.toInt(),
  badges:
      (json['badges'] as List<dynamic>?)
          ?.map((e) => Badge.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Badge>[],
  abilityScores:
      (json['ability_scores'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
);

Map<String, dynamic> _$GrowthStateToJson(_GrowthState instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'level': instance.level,
      'total_xp': instance.totalXp,
      'coins': instance.coins,
      'current_level_required_xp': instance.currentLevelRequiredXp,
      'next_level_required_xp': instance.nextLevelRequiredXp,
      'badges': instance.badges,
      'ability_scores': instance.abilityScores,
    };
