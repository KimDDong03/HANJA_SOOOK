import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge.freezed.dart';
part 'badge.g.dart';

@freezed
abstract class Badge with _$Badge {
  const factory Badge({
    required String code,
    required String title,
    String? description,
    @JsonKey(name: 'condition_type') String? conditionType,
    @JsonKey(name: 'condition_value') int? conditionValue,
    @JsonKey(name: 'asset_id') String? assetId,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Badge;

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
}
