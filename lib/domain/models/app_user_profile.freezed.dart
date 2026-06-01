// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUserProfile {

 String get id; UserRole get role;@JsonKey(name: 'display_name') String get displayName;@JsonKey(name: 'school_id') String? get schoolId;@JsonKey(name: 'standard_school_code') String? get standardSchoolCode;@JsonKey(name: 'school_name') String? get schoolName; int? get grade;@JsonKey(name: 'class_name') String? get className;@JsonKey(name: 'avatar_key') String get avatarKey; int get level;@JsonKey(name: 'total_xp') int get totalXp; int get coins;@JsonKey(name: 'is_demo') bool get isDemo;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of AppUserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserProfileCopyWith<AppUserProfile> get copyWith => _$AppUserProfileCopyWithImpl<AppUserProfile>(this as AppUserProfile, _$identity);

  /// Serializes this AppUserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.role, role) || other.role == role)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.standardSchoolCode, standardSchoolCode) || other.standardSchoolCode == standardSchoolCode)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.className, className) || other.className == className)&&(identical(other.avatarKey, avatarKey) || other.avatarKey == avatarKey)&&(identical(other.level, level) || other.level == level)&&(identical(other.totalXp, totalXp) || other.totalXp == totalXp)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.isDemo, isDemo) || other.isDemo == isDemo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,role,displayName,schoolId,standardSchoolCode,schoolName,grade,className,avatarKey,level,totalXp,coins,isDemo,createdAt,updatedAt);

@override
String toString() {
  return 'AppUserProfile(id: $id, role: $role, displayName: $displayName, schoolId: $schoolId, standardSchoolCode: $standardSchoolCode, schoolName: $schoolName, grade: $grade, className: $className, avatarKey: $avatarKey, level: $level, totalXp: $totalXp, coins: $coins, isDemo: $isDemo, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AppUserProfileCopyWith<$Res>  {
  factory $AppUserProfileCopyWith(AppUserProfile value, $Res Function(AppUserProfile) _then) = _$AppUserProfileCopyWithImpl;
@useResult
$Res call({
 String id, UserRole role,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'school_id') String? schoolId,@JsonKey(name: 'standard_school_code') String? standardSchoolCode,@JsonKey(name: 'school_name') String? schoolName, int? grade,@JsonKey(name: 'class_name') String? className,@JsonKey(name: 'avatar_key') String avatarKey, int level,@JsonKey(name: 'total_xp') int totalXp, int coins,@JsonKey(name: 'is_demo') bool isDemo,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$AppUserProfileCopyWithImpl<$Res>
    implements $AppUserProfileCopyWith<$Res> {
  _$AppUserProfileCopyWithImpl(this._self, this._then);

  final AppUserProfile _self;
  final $Res Function(AppUserProfile) _then;

/// Create a copy of AppUserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? role = null,Object? displayName = null,Object? schoolId = freezed,Object? standardSchoolCode = freezed,Object? schoolName = freezed,Object? grade = freezed,Object? className = freezed,Object? avatarKey = null,Object? level = null,Object? totalXp = null,Object? coins = null,Object? isDemo = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,schoolId: freezed == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String?,standardSchoolCode: freezed == standardSchoolCode ? _self.standardSchoolCode : standardSchoolCode // ignore: cast_nullable_to_non_nullable
as String?,schoolName: freezed == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String?,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as int?,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,avatarKey: null == avatarKey ? _self.avatarKey : avatarKey // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,totalXp: null == totalXp ? _self.totalXp : totalXp // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,isDemo: null == isDemo ? _self.isDemo : isDemo // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUserProfile].
extension AppUserProfilePatterns on AppUserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUserProfile value)  $default,){
final _that = this;
switch (_that) {
case _AppUserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _AppUserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  UserRole role, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'school_id')  String? schoolId, @JsonKey(name: 'standard_school_code')  String? standardSchoolCode, @JsonKey(name: 'school_name')  String? schoolName,  int? grade, @JsonKey(name: 'class_name')  String? className, @JsonKey(name: 'avatar_key')  String avatarKey,  int level, @JsonKey(name: 'total_xp')  int totalXp,  int coins, @JsonKey(name: 'is_demo')  bool isDemo, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUserProfile() when $default != null:
return $default(_that.id,_that.role,_that.displayName,_that.schoolId,_that.standardSchoolCode,_that.schoolName,_that.grade,_that.className,_that.avatarKey,_that.level,_that.totalXp,_that.coins,_that.isDemo,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  UserRole role, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'school_id')  String? schoolId, @JsonKey(name: 'standard_school_code')  String? standardSchoolCode, @JsonKey(name: 'school_name')  String? schoolName,  int? grade, @JsonKey(name: 'class_name')  String? className, @JsonKey(name: 'avatar_key')  String avatarKey,  int level, @JsonKey(name: 'total_xp')  int totalXp,  int coins, @JsonKey(name: 'is_demo')  bool isDemo, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AppUserProfile():
return $default(_that.id,_that.role,_that.displayName,_that.schoolId,_that.standardSchoolCode,_that.schoolName,_that.grade,_that.className,_that.avatarKey,_that.level,_that.totalXp,_that.coins,_that.isDemo,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  UserRole role, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'school_id')  String? schoolId, @JsonKey(name: 'standard_school_code')  String? standardSchoolCode, @JsonKey(name: 'school_name')  String? schoolName,  int? grade, @JsonKey(name: 'class_name')  String? className, @JsonKey(name: 'avatar_key')  String avatarKey,  int level, @JsonKey(name: 'total_xp')  int totalXp,  int coins, @JsonKey(name: 'is_demo')  bool isDemo, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AppUserProfile() when $default != null:
return $default(_that.id,_that.role,_that.displayName,_that.schoolId,_that.standardSchoolCode,_that.schoolName,_that.grade,_that.className,_that.avatarKey,_that.level,_that.totalXp,_that.coins,_that.isDemo,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUserProfile implements AppUserProfile {
  const _AppUserProfile({required this.id, this.role = UserRole.student, @JsonKey(name: 'display_name') required this.displayName, @JsonKey(name: 'school_id') this.schoolId, @JsonKey(name: 'standard_school_code') this.standardSchoolCode, @JsonKey(name: 'school_name') this.schoolName, this.grade, @JsonKey(name: 'class_name') this.className, @JsonKey(name: 'avatar_key') this.avatarKey = 'explorer', this.level = 1, @JsonKey(name: 'total_xp') this.totalXp = 0, this.coins = 0, @JsonKey(name: 'is_demo') this.isDemo = false, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _AppUserProfile.fromJson(Map<String, dynamic> json) => _$AppUserProfileFromJson(json);

@override final  String id;
@override@JsonKey() final  UserRole role;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey(name: 'school_id') final  String? schoolId;
@override@JsonKey(name: 'standard_school_code') final  String? standardSchoolCode;
@override@JsonKey(name: 'school_name') final  String? schoolName;
@override final  int? grade;
@override@JsonKey(name: 'class_name') final  String? className;
@override@JsonKey(name: 'avatar_key') final  String avatarKey;
@override@JsonKey() final  int level;
@override@JsonKey(name: 'total_xp') final  int totalXp;
@override@JsonKey() final  int coins;
@override@JsonKey(name: 'is_demo') final  bool isDemo;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of AppUserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserProfileCopyWith<_AppUserProfile> get copyWith => __$AppUserProfileCopyWithImpl<_AppUserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.role, role) || other.role == role)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.standardSchoolCode, standardSchoolCode) || other.standardSchoolCode == standardSchoolCode)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.className, className) || other.className == className)&&(identical(other.avatarKey, avatarKey) || other.avatarKey == avatarKey)&&(identical(other.level, level) || other.level == level)&&(identical(other.totalXp, totalXp) || other.totalXp == totalXp)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.isDemo, isDemo) || other.isDemo == isDemo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,role,displayName,schoolId,standardSchoolCode,schoolName,grade,className,avatarKey,level,totalXp,coins,isDemo,createdAt,updatedAt);

@override
String toString() {
  return 'AppUserProfile(id: $id, role: $role, displayName: $displayName, schoolId: $schoolId, standardSchoolCode: $standardSchoolCode, schoolName: $schoolName, grade: $grade, className: $className, avatarKey: $avatarKey, level: $level, totalXp: $totalXp, coins: $coins, isDemo: $isDemo, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AppUserProfileCopyWith<$Res> implements $AppUserProfileCopyWith<$Res> {
  factory _$AppUserProfileCopyWith(_AppUserProfile value, $Res Function(_AppUserProfile) _then) = __$AppUserProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, UserRole role,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'school_id') String? schoolId,@JsonKey(name: 'standard_school_code') String? standardSchoolCode,@JsonKey(name: 'school_name') String? schoolName, int? grade,@JsonKey(name: 'class_name') String? className,@JsonKey(name: 'avatar_key') String avatarKey, int level,@JsonKey(name: 'total_xp') int totalXp, int coins,@JsonKey(name: 'is_demo') bool isDemo,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$AppUserProfileCopyWithImpl<$Res>
    implements _$AppUserProfileCopyWith<$Res> {
  __$AppUserProfileCopyWithImpl(this._self, this._then);

  final _AppUserProfile _self;
  final $Res Function(_AppUserProfile) _then;

/// Create a copy of AppUserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? role = null,Object? displayName = null,Object? schoolId = freezed,Object? standardSchoolCode = freezed,Object? schoolName = freezed,Object? grade = freezed,Object? className = freezed,Object? avatarKey = null,Object? level = null,Object? totalXp = null,Object? coins = null,Object? isDemo = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_AppUserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,schoolId: freezed == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String?,standardSchoolCode: freezed == standardSchoolCode ? _self.standardSchoolCode : standardSchoolCode // ignore: cast_nullable_to_non_nullable
as String?,schoolName: freezed == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String?,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as int?,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,avatarKey: null == avatarKey ? _self.avatarKey : avatarKey // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,totalXp: null == totalXp ? _self.totalXp : totalXp // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,isDemo: null == isDemo ? _self.isDemo : isDemo // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
