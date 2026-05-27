// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'badge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Badge {

 String get code; String get title; String? get description;@JsonKey(name: 'condition_type') String? get conditionType;@JsonKey(name: 'condition_value') int? get conditionValue;@JsonKey(name: 'asset_id') String? get assetId;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of Badge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BadgeCopyWith<Badge> get copyWith => _$BadgeCopyWithImpl<Badge>(this as Badge, _$identity);

  /// Serializes this Badge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Badge&&(identical(other.code, code) || other.code == code)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.conditionType, conditionType) || other.conditionType == conditionType)&&(identical(other.conditionValue, conditionValue) || other.conditionValue == conditionValue)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,title,description,conditionType,conditionValue,assetId,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'Badge(code: $code, title: $title, description: $description, conditionType: $conditionType, conditionValue: $conditionValue, assetId: $assetId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BadgeCopyWith<$Res>  {
  factory $BadgeCopyWith(Badge value, $Res Function(Badge) _then) = _$BadgeCopyWithImpl;
@useResult
$Res call({
 String code, String title, String? description,@JsonKey(name: 'condition_type') String? conditionType,@JsonKey(name: 'condition_value') int? conditionValue,@JsonKey(name: 'asset_id') String? assetId,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$BadgeCopyWithImpl<$Res>
    implements $BadgeCopyWith<$Res> {
  _$BadgeCopyWithImpl(this._self, this._then);

  final Badge _self;
  final $Res Function(Badge) _then;

/// Create a copy of Badge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? title = null,Object? description = freezed,Object? conditionType = freezed,Object? conditionValue = freezed,Object? assetId = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,conditionType: freezed == conditionType ? _self.conditionType : conditionType // ignore: cast_nullable_to_non_nullable
as String?,conditionValue: freezed == conditionValue ? _self.conditionValue : conditionValue // ignore: cast_nullable_to_non_nullable
as int?,assetId: freezed == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Badge].
extension BadgePatterns on Badge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Badge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Badge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Badge value)  $default,){
final _that = this;
switch (_that) {
case _Badge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Badge value)?  $default,){
final _that = this;
switch (_that) {
case _Badge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String title,  String? description, @JsonKey(name: 'condition_type')  String? conditionType, @JsonKey(name: 'condition_value')  int? conditionValue, @JsonKey(name: 'asset_id')  String? assetId, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Badge() when $default != null:
return $default(_that.code,_that.title,_that.description,_that.conditionType,_that.conditionValue,_that.assetId,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String title,  String? description, @JsonKey(name: 'condition_type')  String? conditionType, @JsonKey(name: 'condition_value')  int? conditionValue, @JsonKey(name: 'asset_id')  String? assetId, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Badge():
return $default(_that.code,_that.title,_that.description,_that.conditionType,_that.conditionValue,_that.assetId,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String title,  String? description, @JsonKey(name: 'condition_type')  String? conditionType, @JsonKey(name: 'condition_value')  int? conditionValue, @JsonKey(name: 'asset_id')  String? assetId, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Badge() when $default != null:
return $default(_that.code,_that.title,_that.description,_that.conditionType,_that.conditionValue,_that.assetId,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Badge implements Badge {
  const _Badge({required this.code, required this.title, this.description, @JsonKey(name: 'condition_type') this.conditionType, @JsonKey(name: 'condition_value') this.conditionValue, @JsonKey(name: 'asset_id') this.assetId, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);

@override final  String code;
@override final  String title;
@override final  String? description;
@override@JsonKey(name: 'condition_type') final  String? conditionType;
@override@JsonKey(name: 'condition_value') final  int? conditionValue;
@override@JsonKey(name: 'asset_id') final  String? assetId;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of Badge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BadgeCopyWith<_Badge> get copyWith => __$BadgeCopyWithImpl<_Badge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BadgeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Badge&&(identical(other.code, code) || other.code == code)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.conditionType, conditionType) || other.conditionType == conditionType)&&(identical(other.conditionValue, conditionValue) || other.conditionValue == conditionValue)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,title,description,conditionType,conditionValue,assetId,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'Badge(code: $code, title: $title, description: $description, conditionType: $conditionType, conditionValue: $conditionValue, assetId: $assetId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BadgeCopyWith<$Res> implements $BadgeCopyWith<$Res> {
  factory _$BadgeCopyWith(_Badge value, $Res Function(_Badge) _then) = __$BadgeCopyWithImpl;
@override @useResult
$Res call({
 String code, String title, String? description,@JsonKey(name: 'condition_type') String? conditionType,@JsonKey(name: 'condition_value') int? conditionValue,@JsonKey(name: 'asset_id') String? assetId,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$BadgeCopyWithImpl<$Res>
    implements _$BadgeCopyWith<$Res> {
  __$BadgeCopyWithImpl(this._self, this._then);

  final _Badge _self;
  final $Res Function(_Badge) _then;

/// Create a copy of Badge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? title = null,Object? description = freezed,Object? conditionType = freezed,Object? conditionValue = freezed,Object? assetId = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Badge(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,conditionType: freezed == conditionType ? _self.conditionType : conditionType // ignore: cast_nullable_to_non_nullable
as String?,conditionValue: freezed == conditionValue ? _self.conditionValue : conditionValue // ignore: cast_nullable_to_non_nullable
as int?,assetId: freezed == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
