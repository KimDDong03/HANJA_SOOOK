import 'package:freezed_annotation/freezed_annotation.dart';

part 'stroke_asset.freezed.dart';
part 'stroke_asset.g.dart';

@JsonEnum()
enum StrokeDataFormat {
  @JsonValue('median_json')
  medianJson,
  @JsonValue('svg')
  svg,
  @JsonValue('path_json')
  pathJson,
  @JsonValue('manual')
  manual,
}

@JsonEnum()
enum StrokeReviewStatus {
  @JsonValue('available')
  available,
  @JsonValue('needs_review')
  needsReview,
  @JsonValue('missing')
  missing,
  @JsonValue('manual_required')
  manualRequired,
}

@freezed
abstract class StrokeAsset with _$StrokeAsset {
  const factory StrokeAsset({
    String? id,
    @JsonKey(name: 'hanja_id') String? hanjaId,
    required String character,
    @Default('fallback') String source,
    @JsonKey(name: 'data_format')
    @Default(StrokeDataFormat.manual)
    StrokeDataFormat dataFormat,
    @JsonKey(name: 'storage_path') String? storagePath,
    @JsonKey(name: 'stroke_count') int? strokeCount,
    @JsonKey(name: 'median_points') List<dynamic>? medianPoints,
    @JsonKey(name: 'svg_paths') List<dynamic>? svgPaths,
    @JsonKey(name: 'license_note') String? licenseNote,
    @JsonKey(name: 'review_status')
    @Default(StrokeReviewStatus.missing)
    StrokeReviewStatus reviewStatus,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _StrokeAsset;

  factory StrokeAsset.fromJson(Map<String, dynamic> json) =>
      _$StrokeAssetFromJson(json);
}
