// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'writing_attempt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WritingAttempt {

 String? get id;@JsonKey(name: 'session_id') String? get sessionId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'hanja_id') String? get hanjaId; double get accuracy; int get stars;@JsonKey(name: 'expected_stroke_count') int? get expectedStrokeCount;@JsonKey(name: 'user_stroke_count') int? get userStrokeCount;@JsonKey(name: 'time_sec') int get timeSec;@JsonKey(name: 'scoring_mode') WritingScoringMode get scoringMode;@JsonKey(name: 'raw_path_saved') bool get rawPathSaved;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of WritingAttempt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WritingAttemptCopyWith<WritingAttempt> get copyWith => _$WritingAttemptCopyWithImpl<WritingAttempt>(this as WritingAttempt, _$identity);

  /// Serializes this WritingAttempt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WritingAttempt&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.hanjaId, hanjaId) || other.hanjaId == hanjaId)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.expectedStrokeCount, expectedStrokeCount) || other.expectedStrokeCount == expectedStrokeCount)&&(identical(other.userStrokeCount, userStrokeCount) || other.userStrokeCount == userStrokeCount)&&(identical(other.timeSec, timeSec) || other.timeSec == timeSec)&&(identical(other.scoringMode, scoringMode) || other.scoringMode == scoringMode)&&(identical(other.rawPathSaved, rawPathSaved) || other.rawPathSaved == rawPathSaved)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,userId,hanjaId,accuracy,stars,expectedStrokeCount,userStrokeCount,timeSec,scoringMode,rawPathSaved,createdAt);

@override
String toString() {
  return 'WritingAttempt(id: $id, sessionId: $sessionId, userId: $userId, hanjaId: $hanjaId, accuracy: $accuracy, stars: $stars, expectedStrokeCount: $expectedStrokeCount, userStrokeCount: $userStrokeCount, timeSec: $timeSec, scoringMode: $scoringMode, rawPathSaved: $rawPathSaved, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $WritingAttemptCopyWith<$Res>  {
  factory $WritingAttemptCopyWith(WritingAttempt value, $Res Function(WritingAttempt) _then) = _$WritingAttemptCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'session_id') String? sessionId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'hanja_id') String? hanjaId, double accuracy, int stars,@JsonKey(name: 'expected_stroke_count') int? expectedStrokeCount,@JsonKey(name: 'user_stroke_count') int? userStrokeCount,@JsonKey(name: 'time_sec') int timeSec,@JsonKey(name: 'scoring_mode') WritingScoringMode scoringMode,@JsonKey(name: 'raw_path_saved') bool rawPathSaved,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$WritingAttemptCopyWithImpl<$Res>
    implements $WritingAttemptCopyWith<$Res> {
  _$WritingAttemptCopyWithImpl(this._self, this._then);

  final WritingAttempt _self;
  final $Res Function(WritingAttempt) _then;

/// Create a copy of WritingAttempt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? sessionId = freezed,Object? userId = null,Object? hanjaId = freezed,Object? accuracy = null,Object? stars = null,Object? expectedStrokeCount = freezed,Object? userStrokeCount = freezed,Object? timeSec = null,Object? scoringMode = null,Object? rawPathSaved = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,hanjaId: freezed == hanjaId ? _self.hanjaId : hanjaId // ignore: cast_nullable_to_non_nullable
as String?,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,expectedStrokeCount: freezed == expectedStrokeCount ? _self.expectedStrokeCount : expectedStrokeCount // ignore: cast_nullable_to_non_nullable
as int?,userStrokeCount: freezed == userStrokeCount ? _self.userStrokeCount : userStrokeCount // ignore: cast_nullable_to_non_nullable
as int?,timeSec: null == timeSec ? _self.timeSec : timeSec // ignore: cast_nullable_to_non_nullable
as int,scoringMode: null == scoringMode ? _self.scoringMode : scoringMode // ignore: cast_nullable_to_non_nullable
as WritingScoringMode,rawPathSaved: null == rawPathSaved ? _self.rawPathSaved : rawPathSaved // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WritingAttempt].
extension WritingAttemptPatterns on WritingAttempt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WritingAttempt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WritingAttempt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WritingAttempt value)  $default,){
final _that = this;
switch (_that) {
case _WritingAttempt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WritingAttempt value)?  $default,){
final _that = this;
switch (_that) {
case _WritingAttempt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'session_id')  String? sessionId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'hanja_id')  String? hanjaId,  double accuracy,  int stars, @JsonKey(name: 'expected_stroke_count')  int? expectedStrokeCount, @JsonKey(name: 'user_stroke_count')  int? userStrokeCount, @JsonKey(name: 'time_sec')  int timeSec, @JsonKey(name: 'scoring_mode')  WritingScoringMode scoringMode, @JsonKey(name: 'raw_path_saved')  bool rawPathSaved, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WritingAttempt() when $default != null:
return $default(_that.id,_that.sessionId,_that.userId,_that.hanjaId,_that.accuracy,_that.stars,_that.expectedStrokeCount,_that.userStrokeCount,_that.timeSec,_that.scoringMode,_that.rawPathSaved,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'session_id')  String? sessionId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'hanja_id')  String? hanjaId,  double accuracy,  int stars, @JsonKey(name: 'expected_stroke_count')  int? expectedStrokeCount, @JsonKey(name: 'user_stroke_count')  int? userStrokeCount, @JsonKey(name: 'time_sec')  int timeSec, @JsonKey(name: 'scoring_mode')  WritingScoringMode scoringMode, @JsonKey(name: 'raw_path_saved')  bool rawPathSaved, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _WritingAttempt():
return $default(_that.id,_that.sessionId,_that.userId,_that.hanjaId,_that.accuracy,_that.stars,_that.expectedStrokeCount,_that.userStrokeCount,_that.timeSec,_that.scoringMode,_that.rawPathSaved,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'session_id')  String? sessionId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'hanja_id')  String? hanjaId,  double accuracy,  int stars, @JsonKey(name: 'expected_stroke_count')  int? expectedStrokeCount, @JsonKey(name: 'user_stroke_count')  int? userStrokeCount, @JsonKey(name: 'time_sec')  int timeSec, @JsonKey(name: 'scoring_mode')  WritingScoringMode scoringMode, @JsonKey(name: 'raw_path_saved')  bool rawPathSaved, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _WritingAttempt() when $default != null:
return $default(_that.id,_that.sessionId,_that.userId,_that.hanjaId,_that.accuracy,_that.stars,_that.expectedStrokeCount,_that.userStrokeCount,_that.timeSec,_that.scoringMode,_that.rawPathSaved,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WritingAttempt implements WritingAttempt {
  const _WritingAttempt({this.id, @JsonKey(name: 'session_id') this.sessionId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'hanja_id') this.hanjaId, this.accuracy = 0, this.stars = 0, @JsonKey(name: 'expected_stroke_count') this.expectedStrokeCount, @JsonKey(name: 'user_stroke_count') this.userStrokeCount, @JsonKey(name: 'time_sec') this.timeSec = 0, @JsonKey(name: 'scoring_mode') this.scoringMode = WritingScoringMode.fallback, @JsonKey(name: 'raw_path_saved') this.rawPathSaved = false, @JsonKey(name: 'created_at') this.createdAt});
  factory _WritingAttempt.fromJson(Map<String, dynamic> json) => _$WritingAttemptFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'session_id') final  String? sessionId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'hanja_id') final  String? hanjaId;
@override@JsonKey() final  double accuracy;
@override@JsonKey() final  int stars;
@override@JsonKey(name: 'expected_stroke_count') final  int? expectedStrokeCount;
@override@JsonKey(name: 'user_stroke_count') final  int? userStrokeCount;
@override@JsonKey(name: 'time_sec') final  int timeSec;
@override@JsonKey(name: 'scoring_mode') final  WritingScoringMode scoringMode;
@override@JsonKey(name: 'raw_path_saved') final  bool rawPathSaved;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of WritingAttempt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WritingAttemptCopyWith<_WritingAttempt> get copyWith => __$WritingAttemptCopyWithImpl<_WritingAttempt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WritingAttemptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WritingAttempt&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.hanjaId, hanjaId) || other.hanjaId == hanjaId)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.expectedStrokeCount, expectedStrokeCount) || other.expectedStrokeCount == expectedStrokeCount)&&(identical(other.userStrokeCount, userStrokeCount) || other.userStrokeCount == userStrokeCount)&&(identical(other.timeSec, timeSec) || other.timeSec == timeSec)&&(identical(other.scoringMode, scoringMode) || other.scoringMode == scoringMode)&&(identical(other.rawPathSaved, rawPathSaved) || other.rawPathSaved == rawPathSaved)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,userId,hanjaId,accuracy,stars,expectedStrokeCount,userStrokeCount,timeSec,scoringMode,rawPathSaved,createdAt);

@override
String toString() {
  return 'WritingAttempt(id: $id, sessionId: $sessionId, userId: $userId, hanjaId: $hanjaId, accuracy: $accuracy, stars: $stars, expectedStrokeCount: $expectedStrokeCount, userStrokeCount: $userStrokeCount, timeSec: $timeSec, scoringMode: $scoringMode, rawPathSaved: $rawPathSaved, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WritingAttemptCopyWith<$Res> implements $WritingAttemptCopyWith<$Res> {
  factory _$WritingAttemptCopyWith(_WritingAttempt value, $Res Function(_WritingAttempt) _then) = __$WritingAttemptCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'session_id') String? sessionId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'hanja_id') String? hanjaId, double accuracy, int stars,@JsonKey(name: 'expected_stroke_count') int? expectedStrokeCount,@JsonKey(name: 'user_stroke_count') int? userStrokeCount,@JsonKey(name: 'time_sec') int timeSec,@JsonKey(name: 'scoring_mode') WritingScoringMode scoringMode,@JsonKey(name: 'raw_path_saved') bool rawPathSaved,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$WritingAttemptCopyWithImpl<$Res>
    implements _$WritingAttemptCopyWith<$Res> {
  __$WritingAttemptCopyWithImpl(this._self, this._then);

  final _WritingAttempt _self;
  final $Res Function(_WritingAttempt) _then;

/// Create a copy of WritingAttempt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? sessionId = freezed,Object? userId = null,Object? hanjaId = freezed,Object? accuracy = null,Object? stars = null,Object? expectedStrokeCount = freezed,Object? userStrokeCount = freezed,Object? timeSec = null,Object? scoringMode = null,Object? rawPathSaved = null,Object? createdAt = freezed,}) {
  return _then(_WritingAttempt(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,hanjaId: freezed == hanjaId ? _self.hanjaId : hanjaId // ignore: cast_nullable_to_non_nullable
as String?,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,expectedStrokeCount: freezed == expectedStrokeCount ? _self.expectedStrokeCount : expectedStrokeCount // ignore: cast_nullable_to_non_nullable
as int?,userStrokeCount: freezed == userStrokeCount ? _self.userStrokeCount : userStrokeCount // ignore: cast_nullable_to_non_nullable
as int?,timeSec: null == timeSec ? _self.timeSec : timeSec // ignore: cast_nullable_to_non_nullable
as int,scoringMode: null == scoringMode ? _self.scoringMode : scoringMode // ignore: cast_nullable_to_non_nullable
as WritingScoringMode,rawPathSaved: null == rawPathSaved ? _self.rawPathSaved : rawPathSaved // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
