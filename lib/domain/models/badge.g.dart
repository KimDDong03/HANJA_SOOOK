// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Badge _$BadgeFromJson(Map<String, dynamic> json) => _Badge(
  code: json['code'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  conditionType: json['condition_type'] as String?,
  conditionValue: (json['condition_value'] as num?)?.toInt(),
  assetId: json['asset_id'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$BadgeToJson(_Badge instance) => <String, dynamic>{
  'code': instance.code,
  'title': instance.title,
  'description': instance.description,
  'condition_type': instance.conditionType,
  'condition_value': instance.conditionValue,
  'asset_id': instance.assetId,
  'is_active': instance.isActive,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
