import 'package:freezed_annotation/freezed_annotation.dart';

import 'hanja_character.dart';

part 'hanja_example.freezed.dart';
part 'hanja_example.g.dart';

@freezed
abstract class HanjaExample with _$HanjaExample {
  const factory HanjaExample({
    String? id,
    @JsonKey(name: 'hanja_id') required String hanjaId,
    required String sentence,
    String? meaning,
    String? source,
    @Default(ContentDifficulty.normal) ContentDifficulty difficulty,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _HanjaExample;

  factory HanjaExample.fromJson(Map<String, dynamic> json) =>
      _$HanjaExampleFromJson(json);
}
