import 'package:freezed_annotation/freezed_annotation.dart';

part 'hanja_character.freezed.dart';
part 'hanja_character.g.dart';

@JsonEnum()
enum ContentDifficulty {
  @JsonValue('easy')
  easy,
  @JsonValue('normal')
  normal,
  @JsonValue('hard')
  hard,
}

@freezed
abstract class HanjaCharacter with _$HanjaCharacter {
  const factory HanjaCharacter({
    required String id,
    required String character,
    required String sound,
    required String meaning,
    @JsonKey(name: 'stroke_count') int? strokeCount,
    required int grade,
    @JsonKey(name: 'unit_code') String? unitCode,
    @JsonKey(name: 'unit_name') String? unitName,
    @JsonKey(name: 'lesson_no') int? lessonNo,
    @Default(ContentDifficulty.normal) ContentDifficulty difficulty,
    @JsonKey(name: 'example_sentence') String? exampleSentence,
    @JsonKey(name: 'example_meaning') String? exampleMeaning,
    @JsonKey(name: 'image_asset_id') String? imageAssetId,
    @JsonKey(name: 'stroke_asset_id') String? strokeAssetId,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'content_version_id') String? contentVersionId,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _HanjaCharacter;

  factory HanjaCharacter.fromJson(Map<String, dynamic> json) =>
      _$HanjaCharacterFromJson(json);
}
