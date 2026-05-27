// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hanja_example.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HanjaExample _$HanjaExampleFromJson(Map<String, dynamic> json) =>
    _HanjaExample(
      id: json['id'] as String?,
      hanjaId: json['hanja_id'] as String,
      sentence: json['sentence'] as String,
      meaning: json['meaning'] as String?,
      source: json['source'] as String?,
      difficulty:
          $enumDecodeNullable(_$ContentDifficultyEnumMap, json['difficulty']) ??
          ContentDifficulty.normal,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$HanjaExampleToJson(_HanjaExample instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hanja_id': instance.hanjaId,
      'sentence': instance.sentence,
      'meaning': instance.meaning,
      'source': instance.source,
      'difficulty': _$ContentDifficultyEnumMap[instance.difficulty]!,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$ContentDifficultyEnumMap = {
  ContentDifficulty.easy: 'easy',
  ContentDifficulty.normal: 'normal',
  ContentDifficulty.hard: 'hard',
};
