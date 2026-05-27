// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hanja_character.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HanjaCharacter {

 String get id; String get character; String get sound; String get meaning;@JsonKey(name: 'stroke_count') int? get strokeCount; int get grade;@JsonKey(name: 'unit_code') String? get unitCode;@JsonKey(name: 'unit_name') String? get unitName;@JsonKey(name: 'lesson_no') int? get lessonNo; ContentDifficulty get difficulty;@JsonKey(name: 'example_sentence') String? get exampleSentence;@JsonKey(name: 'example_meaning') String? get exampleMeaning;@JsonKey(name: 'image_asset_id') String? get imageAssetId;@JsonKey(name: 'stroke_asset_id') String? get strokeAssetId;@JsonKey(name: 'sort_order') int get sortOrder;@JsonKey(name: 'content_version_id') String? get contentVersionId;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of HanjaCharacter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HanjaCharacterCopyWith<HanjaCharacter> get copyWith => _$HanjaCharacterCopyWithImpl<HanjaCharacter>(this as HanjaCharacter, _$identity);

  /// Serializes this HanjaCharacter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HanjaCharacter&&(identical(other.id, id) || other.id == id)&&(identical(other.character, character) || other.character == character)&&(identical(other.sound, sound) || other.sound == sound)&&(identical(other.meaning, meaning) || other.meaning == meaning)&&(identical(other.strokeCount, strokeCount) || other.strokeCount == strokeCount)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.unitCode, unitCode) || other.unitCode == unitCode)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.lessonNo, lessonNo) || other.lessonNo == lessonNo)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.exampleSentence, exampleSentence) || other.exampleSentence == exampleSentence)&&(identical(other.exampleMeaning, exampleMeaning) || other.exampleMeaning == exampleMeaning)&&(identical(other.imageAssetId, imageAssetId) || other.imageAssetId == imageAssetId)&&(identical(other.strokeAssetId, strokeAssetId) || other.strokeAssetId == strokeAssetId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.contentVersionId, contentVersionId) || other.contentVersionId == contentVersionId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,character,sound,meaning,strokeCount,grade,unitCode,unitName,lessonNo,difficulty,exampleSentence,exampleMeaning,imageAssetId,strokeAssetId,sortOrder,contentVersionId,isActive,createdAt,updatedAt]);

@override
String toString() {
  return 'HanjaCharacter(id: $id, character: $character, sound: $sound, meaning: $meaning, strokeCount: $strokeCount, grade: $grade, unitCode: $unitCode, unitName: $unitName, lessonNo: $lessonNo, difficulty: $difficulty, exampleSentence: $exampleSentence, exampleMeaning: $exampleMeaning, imageAssetId: $imageAssetId, strokeAssetId: $strokeAssetId, sortOrder: $sortOrder, contentVersionId: $contentVersionId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $HanjaCharacterCopyWith<$Res>  {
  factory $HanjaCharacterCopyWith(HanjaCharacter value, $Res Function(HanjaCharacter) _then) = _$HanjaCharacterCopyWithImpl;
@useResult
$Res call({
 String id, String character, String sound, String meaning,@JsonKey(name: 'stroke_count') int? strokeCount, int grade,@JsonKey(name: 'unit_code') String? unitCode,@JsonKey(name: 'unit_name') String? unitName,@JsonKey(name: 'lesson_no') int? lessonNo, ContentDifficulty difficulty,@JsonKey(name: 'example_sentence') String? exampleSentence,@JsonKey(name: 'example_meaning') String? exampleMeaning,@JsonKey(name: 'image_asset_id') String? imageAssetId,@JsonKey(name: 'stroke_asset_id') String? strokeAssetId,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'content_version_id') String? contentVersionId,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$HanjaCharacterCopyWithImpl<$Res>
    implements $HanjaCharacterCopyWith<$Res> {
  _$HanjaCharacterCopyWithImpl(this._self, this._then);

  final HanjaCharacter _self;
  final $Res Function(HanjaCharacter) _then;

/// Create a copy of HanjaCharacter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? character = null,Object? sound = null,Object? meaning = null,Object? strokeCount = freezed,Object? grade = null,Object? unitCode = freezed,Object? unitName = freezed,Object? lessonNo = freezed,Object? difficulty = null,Object? exampleSentence = freezed,Object? exampleMeaning = freezed,Object? imageAssetId = freezed,Object? strokeAssetId = freezed,Object? sortOrder = null,Object? contentVersionId = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,character: null == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String,sound: null == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as String,meaning: null == meaning ? _self.meaning : meaning // ignore: cast_nullable_to_non_nullable
as String,strokeCount: freezed == strokeCount ? _self.strokeCount : strokeCount // ignore: cast_nullable_to_non_nullable
as int?,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as int,unitCode: freezed == unitCode ? _self.unitCode : unitCode // ignore: cast_nullable_to_non_nullable
as String?,unitName: freezed == unitName ? _self.unitName : unitName // ignore: cast_nullable_to_non_nullable
as String?,lessonNo: freezed == lessonNo ? _self.lessonNo : lessonNo // ignore: cast_nullable_to_non_nullable
as int?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as ContentDifficulty,exampleSentence: freezed == exampleSentence ? _self.exampleSentence : exampleSentence // ignore: cast_nullable_to_non_nullable
as String?,exampleMeaning: freezed == exampleMeaning ? _self.exampleMeaning : exampleMeaning // ignore: cast_nullable_to_non_nullable
as String?,imageAssetId: freezed == imageAssetId ? _self.imageAssetId : imageAssetId // ignore: cast_nullable_to_non_nullable
as String?,strokeAssetId: freezed == strokeAssetId ? _self.strokeAssetId : strokeAssetId // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,contentVersionId: freezed == contentVersionId ? _self.contentVersionId : contentVersionId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [HanjaCharacter].
extension HanjaCharacterPatterns on HanjaCharacter {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HanjaCharacter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HanjaCharacter() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HanjaCharacter value)  $default,){
final _that = this;
switch (_that) {
case _HanjaCharacter():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HanjaCharacter value)?  $default,){
final _that = this;
switch (_that) {
case _HanjaCharacter() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String character,  String sound,  String meaning, @JsonKey(name: 'stroke_count')  int? strokeCount,  int grade, @JsonKey(name: 'unit_code')  String? unitCode, @JsonKey(name: 'unit_name')  String? unitName, @JsonKey(name: 'lesson_no')  int? lessonNo,  ContentDifficulty difficulty, @JsonKey(name: 'example_sentence')  String? exampleSentence, @JsonKey(name: 'example_meaning')  String? exampleMeaning, @JsonKey(name: 'image_asset_id')  String? imageAssetId, @JsonKey(name: 'stroke_asset_id')  String? strokeAssetId, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'content_version_id')  String? contentVersionId, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HanjaCharacter() when $default != null:
return $default(_that.id,_that.character,_that.sound,_that.meaning,_that.strokeCount,_that.grade,_that.unitCode,_that.unitName,_that.lessonNo,_that.difficulty,_that.exampleSentence,_that.exampleMeaning,_that.imageAssetId,_that.strokeAssetId,_that.sortOrder,_that.contentVersionId,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String character,  String sound,  String meaning, @JsonKey(name: 'stroke_count')  int? strokeCount,  int grade, @JsonKey(name: 'unit_code')  String? unitCode, @JsonKey(name: 'unit_name')  String? unitName, @JsonKey(name: 'lesson_no')  int? lessonNo,  ContentDifficulty difficulty, @JsonKey(name: 'example_sentence')  String? exampleSentence, @JsonKey(name: 'example_meaning')  String? exampleMeaning, @JsonKey(name: 'image_asset_id')  String? imageAssetId, @JsonKey(name: 'stroke_asset_id')  String? strokeAssetId, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'content_version_id')  String? contentVersionId, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _HanjaCharacter():
return $default(_that.id,_that.character,_that.sound,_that.meaning,_that.strokeCount,_that.grade,_that.unitCode,_that.unitName,_that.lessonNo,_that.difficulty,_that.exampleSentence,_that.exampleMeaning,_that.imageAssetId,_that.strokeAssetId,_that.sortOrder,_that.contentVersionId,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String character,  String sound,  String meaning, @JsonKey(name: 'stroke_count')  int? strokeCount,  int grade, @JsonKey(name: 'unit_code')  String? unitCode, @JsonKey(name: 'unit_name')  String? unitName, @JsonKey(name: 'lesson_no')  int? lessonNo,  ContentDifficulty difficulty, @JsonKey(name: 'example_sentence')  String? exampleSentence, @JsonKey(name: 'example_meaning')  String? exampleMeaning, @JsonKey(name: 'image_asset_id')  String? imageAssetId, @JsonKey(name: 'stroke_asset_id')  String? strokeAssetId, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'content_version_id')  String? contentVersionId, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _HanjaCharacter() when $default != null:
return $default(_that.id,_that.character,_that.sound,_that.meaning,_that.strokeCount,_that.grade,_that.unitCode,_that.unitName,_that.lessonNo,_that.difficulty,_that.exampleSentence,_that.exampleMeaning,_that.imageAssetId,_that.strokeAssetId,_that.sortOrder,_that.contentVersionId,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HanjaCharacter implements HanjaCharacter {
  const _HanjaCharacter({required this.id, required this.character, required this.sound, required this.meaning, @JsonKey(name: 'stroke_count') this.strokeCount, required this.grade, @JsonKey(name: 'unit_code') this.unitCode, @JsonKey(name: 'unit_name') this.unitName, @JsonKey(name: 'lesson_no') this.lessonNo, this.difficulty = ContentDifficulty.normal, @JsonKey(name: 'example_sentence') this.exampleSentence, @JsonKey(name: 'example_meaning') this.exampleMeaning, @JsonKey(name: 'image_asset_id') this.imageAssetId, @JsonKey(name: 'stroke_asset_id') this.strokeAssetId, @JsonKey(name: 'sort_order') this.sortOrder = 0, @JsonKey(name: 'content_version_id') this.contentVersionId, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _HanjaCharacter.fromJson(Map<String, dynamic> json) => _$HanjaCharacterFromJson(json);

@override final  String id;
@override final  String character;
@override final  String sound;
@override final  String meaning;
@override@JsonKey(name: 'stroke_count') final  int? strokeCount;
@override final  int grade;
@override@JsonKey(name: 'unit_code') final  String? unitCode;
@override@JsonKey(name: 'unit_name') final  String? unitName;
@override@JsonKey(name: 'lesson_no') final  int? lessonNo;
@override@JsonKey() final  ContentDifficulty difficulty;
@override@JsonKey(name: 'example_sentence') final  String? exampleSentence;
@override@JsonKey(name: 'example_meaning') final  String? exampleMeaning;
@override@JsonKey(name: 'image_asset_id') final  String? imageAssetId;
@override@JsonKey(name: 'stroke_asset_id') final  String? strokeAssetId;
@override@JsonKey(name: 'sort_order') final  int sortOrder;
@override@JsonKey(name: 'content_version_id') final  String? contentVersionId;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of HanjaCharacter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HanjaCharacterCopyWith<_HanjaCharacter> get copyWith => __$HanjaCharacterCopyWithImpl<_HanjaCharacter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HanjaCharacterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HanjaCharacter&&(identical(other.id, id) || other.id == id)&&(identical(other.character, character) || other.character == character)&&(identical(other.sound, sound) || other.sound == sound)&&(identical(other.meaning, meaning) || other.meaning == meaning)&&(identical(other.strokeCount, strokeCount) || other.strokeCount == strokeCount)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.unitCode, unitCode) || other.unitCode == unitCode)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.lessonNo, lessonNo) || other.lessonNo == lessonNo)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.exampleSentence, exampleSentence) || other.exampleSentence == exampleSentence)&&(identical(other.exampleMeaning, exampleMeaning) || other.exampleMeaning == exampleMeaning)&&(identical(other.imageAssetId, imageAssetId) || other.imageAssetId == imageAssetId)&&(identical(other.strokeAssetId, strokeAssetId) || other.strokeAssetId == strokeAssetId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.contentVersionId, contentVersionId) || other.contentVersionId == contentVersionId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,character,sound,meaning,strokeCount,grade,unitCode,unitName,lessonNo,difficulty,exampleSentence,exampleMeaning,imageAssetId,strokeAssetId,sortOrder,contentVersionId,isActive,createdAt,updatedAt]);

@override
String toString() {
  return 'HanjaCharacter(id: $id, character: $character, sound: $sound, meaning: $meaning, strokeCount: $strokeCount, grade: $grade, unitCode: $unitCode, unitName: $unitName, lessonNo: $lessonNo, difficulty: $difficulty, exampleSentence: $exampleSentence, exampleMeaning: $exampleMeaning, imageAssetId: $imageAssetId, strokeAssetId: $strokeAssetId, sortOrder: $sortOrder, contentVersionId: $contentVersionId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$HanjaCharacterCopyWith<$Res> implements $HanjaCharacterCopyWith<$Res> {
  factory _$HanjaCharacterCopyWith(_HanjaCharacter value, $Res Function(_HanjaCharacter) _then) = __$HanjaCharacterCopyWithImpl;
@override @useResult
$Res call({
 String id, String character, String sound, String meaning,@JsonKey(name: 'stroke_count') int? strokeCount, int grade,@JsonKey(name: 'unit_code') String? unitCode,@JsonKey(name: 'unit_name') String? unitName,@JsonKey(name: 'lesson_no') int? lessonNo, ContentDifficulty difficulty,@JsonKey(name: 'example_sentence') String? exampleSentence,@JsonKey(name: 'example_meaning') String? exampleMeaning,@JsonKey(name: 'image_asset_id') String? imageAssetId,@JsonKey(name: 'stroke_asset_id') String? strokeAssetId,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'content_version_id') String? contentVersionId,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$HanjaCharacterCopyWithImpl<$Res>
    implements _$HanjaCharacterCopyWith<$Res> {
  __$HanjaCharacterCopyWithImpl(this._self, this._then);

  final _HanjaCharacter _self;
  final $Res Function(_HanjaCharacter) _then;

/// Create a copy of HanjaCharacter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? character = null,Object? sound = null,Object? meaning = null,Object? strokeCount = freezed,Object? grade = null,Object? unitCode = freezed,Object? unitName = freezed,Object? lessonNo = freezed,Object? difficulty = null,Object? exampleSentence = freezed,Object? exampleMeaning = freezed,Object? imageAssetId = freezed,Object? strokeAssetId = freezed,Object? sortOrder = null,Object? contentVersionId = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_HanjaCharacter(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,character: null == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String,sound: null == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as String,meaning: null == meaning ? _self.meaning : meaning // ignore: cast_nullable_to_non_nullable
as String,strokeCount: freezed == strokeCount ? _self.strokeCount : strokeCount // ignore: cast_nullable_to_non_nullable
as int?,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as int,unitCode: freezed == unitCode ? _self.unitCode : unitCode // ignore: cast_nullable_to_non_nullable
as String?,unitName: freezed == unitName ? _self.unitName : unitName // ignore: cast_nullable_to_non_nullable
as String?,lessonNo: freezed == lessonNo ? _self.lessonNo : lessonNo // ignore: cast_nullable_to_non_nullable
as int?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as ContentDifficulty,exampleSentence: freezed == exampleSentence ? _self.exampleSentence : exampleSentence // ignore: cast_nullable_to_non_nullable
as String?,exampleMeaning: freezed == exampleMeaning ? _self.exampleMeaning : exampleMeaning // ignore: cast_nullable_to_non_nullable
as String?,imageAssetId: freezed == imageAssetId ? _self.imageAssetId : imageAssetId // ignore: cast_nullable_to_non_nullable
as String?,strokeAssetId: freezed == strokeAssetId ? _self.strokeAssetId : strokeAssetId // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,contentVersionId: freezed == contentVersionId ? _self.contentVersionId : contentVersionId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
