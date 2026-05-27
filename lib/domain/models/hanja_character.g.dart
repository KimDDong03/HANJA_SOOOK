// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hanja_character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HanjaCharacter _$HanjaCharacterFromJson(Map<String, dynamic> json) =>
    _HanjaCharacter(
      id: json['id'] as String,
      character: json['character'] as String,
      sound: json['sound'] as String,
      meaning: json['meaning'] as String,
      strokeCount: (json['stroke_count'] as num?)?.toInt(),
      grade: (json['grade'] as num).toInt(),
      unitCode: json['unit_code'] as String?,
      unitName: json['unit_name'] as String?,
      lessonNo: (json['lesson_no'] as num?)?.toInt(),
      difficulty:
          $enumDecodeNullable(_$ContentDifficultyEnumMap, json['difficulty']) ??
          ContentDifficulty.normal,
      exampleSentence: json['example_sentence'] as String?,
      exampleMeaning: json['example_meaning'] as String?,
      imageAssetId: json['image_asset_id'] as String?,
      strokeAssetId: json['stroke_asset_id'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      contentVersionId: json['content_version_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$HanjaCharacterToJson(_HanjaCharacter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'character': instance.character,
      'sound': instance.sound,
      'meaning': instance.meaning,
      'stroke_count': instance.strokeCount,
      'grade': instance.grade,
      'unit_code': instance.unitCode,
      'unit_name': instance.unitName,
      'lesson_no': instance.lessonNo,
      'difficulty': _$ContentDifficultyEnumMap[instance.difficulty]!,
      'example_sentence': instance.exampleSentence,
      'example_meaning': instance.exampleMeaning,
      'image_asset_id': instance.imageAssetId,
      'stroke_asset_id': instance.strokeAssetId,
      'sort_order': instance.sortOrder,
      'content_version_id': instance.contentVersionId,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$ContentDifficultyEnumMap = {
  ContentDifficulty.easy: 'easy',
  ContentDifficulty.normal: 'normal',
  ContentDifficulty.hard: 'hard',
};
