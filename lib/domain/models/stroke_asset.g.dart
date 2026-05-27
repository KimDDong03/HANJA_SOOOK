// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stroke_asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StrokeAsset _$StrokeAssetFromJson(Map<String, dynamic> json) => _StrokeAsset(
  id: json['id'] as String?,
  hanjaId: json['hanja_id'] as String?,
  character: json['character'] as String,
  source: json['source'] as String? ?? 'fallback',
  dataFormat:
      $enumDecodeNullable(_$StrokeDataFormatEnumMap, json['data_format']) ??
      StrokeDataFormat.manual,
  storagePath: json['storage_path'] as String?,
  strokeCount: (json['stroke_count'] as num?)?.toInt(),
  medianPoints: json['median_points'] as List<dynamic>?,
  svgPaths: json['svg_paths'] as List<dynamic>?,
  licenseNote: json['license_note'] as String?,
  reviewStatus:
      $enumDecodeNullable(_$StrokeReviewStatusEnumMap, json['review_status']) ??
      StrokeReviewStatus.missing,
  isActive: json['is_active'] as bool? ?? true,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$StrokeAssetToJson(_StrokeAsset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hanja_id': instance.hanjaId,
      'character': instance.character,
      'source': instance.source,
      'data_format': _$StrokeDataFormatEnumMap[instance.dataFormat]!,
      'storage_path': instance.storagePath,
      'stroke_count': instance.strokeCount,
      'median_points': instance.medianPoints,
      'svg_paths': instance.svgPaths,
      'license_note': instance.licenseNote,
      'review_status': _$StrokeReviewStatusEnumMap[instance.reviewStatus]!,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$StrokeDataFormatEnumMap = {
  StrokeDataFormat.medianJson: 'median_json',
  StrokeDataFormat.svg: 'svg',
  StrokeDataFormat.pathJson: 'path_json',
  StrokeDataFormat.manual: 'manual',
};

const _$StrokeReviewStatusEnumMap = {
  StrokeReviewStatus.available: 'available',
  StrokeReviewStatus.needsReview: 'needs_review',
  StrokeReviewStatus.missing: 'missing',
  StrokeReviewStatus.manualRequired: 'manual_required',
};
