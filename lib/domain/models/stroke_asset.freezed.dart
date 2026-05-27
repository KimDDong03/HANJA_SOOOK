// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stroke_asset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StrokeAsset {

 String? get id;@JsonKey(name: 'hanja_id') String? get hanjaId; String get character; String get source;@JsonKey(name: 'data_format') StrokeDataFormat get dataFormat;@JsonKey(name: 'storage_path') String? get storagePath;@JsonKey(name: 'stroke_count') int? get strokeCount;@JsonKey(name: 'median_points') List<dynamic>? get medianPoints;@JsonKey(name: 'svg_paths') List<dynamic>? get svgPaths;@JsonKey(name: 'license_note') String? get licenseNote;@JsonKey(name: 'review_status') StrokeReviewStatus get reviewStatus;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of StrokeAsset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StrokeAssetCopyWith<StrokeAsset> get copyWith => _$StrokeAssetCopyWithImpl<StrokeAsset>(this as StrokeAsset, _$identity);

  /// Serializes this StrokeAsset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StrokeAsset&&(identical(other.id, id) || other.id == id)&&(identical(other.hanjaId, hanjaId) || other.hanjaId == hanjaId)&&(identical(other.character, character) || other.character == character)&&(identical(other.source, source) || other.source == source)&&(identical(other.dataFormat, dataFormat) || other.dataFormat == dataFormat)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.strokeCount, strokeCount) || other.strokeCount == strokeCount)&&const DeepCollectionEquality().equals(other.medianPoints, medianPoints)&&const DeepCollectionEquality().equals(other.svgPaths, svgPaths)&&(identical(other.licenseNote, licenseNote) || other.licenseNote == licenseNote)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hanjaId,character,source,dataFormat,storagePath,strokeCount,const DeepCollectionEquality().hash(medianPoints),const DeepCollectionEquality().hash(svgPaths),licenseNote,reviewStatus,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'StrokeAsset(id: $id, hanjaId: $hanjaId, character: $character, source: $source, dataFormat: $dataFormat, storagePath: $storagePath, strokeCount: $strokeCount, medianPoints: $medianPoints, svgPaths: $svgPaths, licenseNote: $licenseNote, reviewStatus: $reviewStatus, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $StrokeAssetCopyWith<$Res>  {
  factory $StrokeAssetCopyWith(StrokeAsset value, $Res Function(StrokeAsset) _then) = _$StrokeAssetCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'hanja_id') String? hanjaId, String character, String source,@JsonKey(name: 'data_format') StrokeDataFormat dataFormat,@JsonKey(name: 'storage_path') String? storagePath,@JsonKey(name: 'stroke_count') int? strokeCount,@JsonKey(name: 'median_points') List<dynamic>? medianPoints,@JsonKey(name: 'svg_paths') List<dynamic>? svgPaths,@JsonKey(name: 'license_note') String? licenseNote,@JsonKey(name: 'review_status') StrokeReviewStatus reviewStatus,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$StrokeAssetCopyWithImpl<$Res>
    implements $StrokeAssetCopyWith<$Res> {
  _$StrokeAssetCopyWithImpl(this._self, this._then);

  final StrokeAsset _self;
  final $Res Function(StrokeAsset) _then;

/// Create a copy of StrokeAsset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? hanjaId = freezed,Object? character = null,Object? source = null,Object? dataFormat = null,Object? storagePath = freezed,Object? strokeCount = freezed,Object? medianPoints = freezed,Object? svgPaths = freezed,Object? licenseNote = freezed,Object? reviewStatus = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,hanjaId: freezed == hanjaId ? _self.hanjaId : hanjaId // ignore: cast_nullable_to_non_nullable
as String?,character: null == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,dataFormat: null == dataFormat ? _self.dataFormat : dataFormat // ignore: cast_nullable_to_non_nullable
as StrokeDataFormat,storagePath: freezed == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String?,strokeCount: freezed == strokeCount ? _self.strokeCount : strokeCount // ignore: cast_nullable_to_non_nullable
as int?,medianPoints: freezed == medianPoints ? _self.medianPoints : medianPoints // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,svgPaths: freezed == svgPaths ? _self.svgPaths : svgPaths // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,licenseNote: freezed == licenseNote ? _self.licenseNote : licenseNote // ignore: cast_nullable_to_non_nullable
as String?,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as StrokeReviewStatus,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StrokeAsset].
extension StrokeAssetPatterns on StrokeAsset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StrokeAsset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StrokeAsset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StrokeAsset value)  $default,){
final _that = this;
switch (_that) {
case _StrokeAsset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StrokeAsset value)?  $default,){
final _that = this;
switch (_that) {
case _StrokeAsset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'hanja_id')  String? hanjaId,  String character,  String source, @JsonKey(name: 'data_format')  StrokeDataFormat dataFormat, @JsonKey(name: 'storage_path')  String? storagePath, @JsonKey(name: 'stroke_count')  int? strokeCount, @JsonKey(name: 'median_points')  List<dynamic>? medianPoints, @JsonKey(name: 'svg_paths')  List<dynamic>? svgPaths, @JsonKey(name: 'license_note')  String? licenseNote, @JsonKey(name: 'review_status')  StrokeReviewStatus reviewStatus, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StrokeAsset() when $default != null:
return $default(_that.id,_that.hanjaId,_that.character,_that.source,_that.dataFormat,_that.storagePath,_that.strokeCount,_that.medianPoints,_that.svgPaths,_that.licenseNote,_that.reviewStatus,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'hanja_id')  String? hanjaId,  String character,  String source, @JsonKey(name: 'data_format')  StrokeDataFormat dataFormat, @JsonKey(name: 'storage_path')  String? storagePath, @JsonKey(name: 'stroke_count')  int? strokeCount, @JsonKey(name: 'median_points')  List<dynamic>? medianPoints, @JsonKey(name: 'svg_paths')  List<dynamic>? svgPaths, @JsonKey(name: 'license_note')  String? licenseNote, @JsonKey(name: 'review_status')  StrokeReviewStatus reviewStatus, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _StrokeAsset():
return $default(_that.id,_that.hanjaId,_that.character,_that.source,_that.dataFormat,_that.storagePath,_that.strokeCount,_that.medianPoints,_that.svgPaths,_that.licenseNote,_that.reviewStatus,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'hanja_id')  String? hanjaId,  String character,  String source, @JsonKey(name: 'data_format')  StrokeDataFormat dataFormat, @JsonKey(name: 'storage_path')  String? storagePath, @JsonKey(name: 'stroke_count')  int? strokeCount, @JsonKey(name: 'median_points')  List<dynamic>? medianPoints, @JsonKey(name: 'svg_paths')  List<dynamic>? svgPaths, @JsonKey(name: 'license_note')  String? licenseNote, @JsonKey(name: 'review_status')  StrokeReviewStatus reviewStatus, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _StrokeAsset() when $default != null:
return $default(_that.id,_that.hanjaId,_that.character,_that.source,_that.dataFormat,_that.storagePath,_that.strokeCount,_that.medianPoints,_that.svgPaths,_that.licenseNote,_that.reviewStatus,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StrokeAsset implements StrokeAsset {
  const _StrokeAsset({this.id, @JsonKey(name: 'hanja_id') this.hanjaId, required this.character, this.source = 'fallback', @JsonKey(name: 'data_format') this.dataFormat = StrokeDataFormat.manual, @JsonKey(name: 'storage_path') this.storagePath, @JsonKey(name: 'stroke_count') this.strokeCount, @JsonKey(name: 'median_points') final  List<dynamic>? medianPoints, @JsonKey(name: 'svg_paths') final  List<dynamic>? svgPaths, @JsonKey(name: 'license_note') this.licenseNote, @JsonKey(name: 'review_status') this.reviewStatus = StrokeReviewStatus.missing, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _medianPoints = medianPoints,_svgPaths = svgPaths;
  factory _StrokeAsset.fromJson(Map<String, dynamic> json) => _$StrokeAssetFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'hanja_id') final  String? hanjaId;
@override final  String character;
@override@JsonKey() final  String source;
@override@JsonKey(name: 'data_format') final  StrokeDataFormat dataFormat;
@override@JsonKey(name: 'storage_path') final  String? storagePath;
@override@JsonKey(name: 'stroke_count') final  int? strokeCount;
 final  List<dynamic>? _medianPoints;
@override@JsonKey(name: 'median_points') List<dynamic>? get medianPoints {
  final value = _medianPoints;
  if (value == null) return null;
  if (_medianPoints is EqualUnmodifiableListView) return _medianPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<dynamic>? _svgPaths;
@override@JsonKey(name: 'svg_paths') List<dynamic>? get svgPaths {
  final value = _svgPaths;
  if (value == null) return null;
  if (_svgPaths is EqualUnmodifiableListView) return _svgPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'license_note') final  String? licenseNote;
@override@JsonKey(name: 'review_status') final  StrokeReviewStatus reviewStatus;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of StrokeAsset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StrokeAssetCopyWith<_StrokeAsset> get copyWith => __$StrokeAssetCopyWithImpl<_StrokeAsset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StrokeAssetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StrokeAsset&&(identical(other.id, id) || other.id == id)&&(identical(other.hanjaId, hanjaId) || other.hanjaId == hanjaId)&&(identical(other.character, character) || other.character == character)&&(identical(other.source, source) || other.source == source)&&(identical(other.dataFormat, dataFormat) || other.dataFormat == dataFormat)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.strokeCount, strokeCount) || other.strokeCount == strokeCount)&&const DeepCollectionEquality().equals(other._medianPoints, _medianPoints)&&const DeepCollectionEquality().equals(other._svgPaths, _svgPaths)&&(identical(other.licenseNote, licenseNote) || other.licenseNote == licenseNote)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hanjaId,character,source,dataFormat,storagePath,strokeCount,const DeepCollectionEquality().hash(_medianPoints),const DeepCollectionEquality().hash(_svgPaths),licenseNote,reviewStatus,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'StrokeAsset(id: $id, hanjaId: $hanjaId, character: $character, source: $source, dataFormat: $dataFormat, storagePath: $storagePath, strokeCount: $strokeCount, medianPoints: $medianPoints, svgPaths: $svgPaths, licenseNote: $licenseNote, reviewStatus: $reviewStatus, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$StrokeAssetCopyWith<$Res> implements $StrokeAssetCopyWith<$Res> {
  factory _$StrokeAssetCopyWith(_StrokeAsset value, $Res Function(_StrokeAsset) _then) = __$StrokeAssetCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'hanja_id') String? hanjaId, String character, String source,@JsonKey(name: 'data_format') StrokeDataFormat dataFormat,@JsonKey(name: 'storage_path') String? storagePath,@JsonKey(name: 'stroke_count') int? strokeCount,@JsonKey(name: 'median_points') List<dynamic>? medianPoints,@JsonKey(name: 'svg_paths') List<dynamic>? svgPaths,@JsonKey(name: 'license_note') String? licenseNote,@JsonKey(name: 'review_status') StrokeReviewStatus reviewStatus,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$StrokeAssetCopyWithImpl<$Res>
    implements _$StrokeAssetCopyWith<$Res> {
  __$StrokeAssetCopyWithImpl(this._self, this._then);

  final _StrokeAsset _self;
  final $Res Function(_StrokeAsset) _then;

/// Create a copy of StrokeAsset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? hanjaId = freezed,Object? character = null,Object? source = null,Object? dataFormat = null,Object? storagePath = freezed,Object? strokeCount = freezed,Object? medianPoints = freezed,Object? svgPaths = freezed,Object? licenseNote = freezed,Object? reviewStatus = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_StrokeAsset(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,hanjaId: freezed == hanjaId ? _self.hanjaId : hanjaId // ignore: cast_nullable_to_non_nullable
as String?,character: null == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,dataFormat: null == dataFormat ? _self.dataFormat : dataFormat // ignore: cast_nullable_to_non_nullable
as StrokeDataFormat,storagePath: freezed == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String?,strokeCount: freezed == strokeCount ? _self.strokeCount : strokeCount // ignore: cast_nullable_to_non_nullable
as int?,medianPoints: freezed == medianPoints ? _self._medianPoints : medianPoints // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,svgPaths: freezed == svgPaths ? _self._svgPaths : svgPaths // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,licenseNote: freezed == licenseNote ? _self.licenseNote : licenseNote // ignore: cast_nullable_to_non_nullable
as String?,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as StrokeReviewStatus,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
