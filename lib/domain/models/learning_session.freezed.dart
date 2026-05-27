// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'learning_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LearningSession {

 String? get id;@JsonKey(name: 'user_id') String get userId; LearningMode get mode; int? get grade;@JsonKey(name: 'unit_code') String? get unitCode;@JsonKey(name: 'started_at') DateTime? get startedAt;@JsonKey(name: 'ended_at') DateTime? get endedAt; int get score; double get accuracy;@JsonKey(name: 'time_sec') int get timeSec;@JsonKey(name: 'earned_xp') int get earnedXp;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of LearningSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LearningSessionCopyWith<LearningSession> get copyWith => _$LearningSessionCopyWithImpl<LearningSession>(this as LearningSession, _$identity);

  /// Serializes this LearningSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LearningSession&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.unitCode, unitCode) || other.unitCode == unitCode)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.score, score) || other.score == score)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.timeSec, timeSec) || other.timeSec == timeSec)&&(identical(other.earnedXp, earnedXp) || other.earnedXp == earnedXp)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,mode,grade,unitCode,startedAt,endedAt,score,accuracy,timeSec,earnedXp,createdAt);

@override
String toString() {
  return 'LearningSession(id: $id, userId: $userId, mode: $mode, grade: $grade, unitCode: $unitCode, startedAt: $startedAt, endedAt: $endedAt, score: $score, accuracy: $accuracy, timeSec: $timeSec, earnedXp: $earnedXp, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $LearningSessionCopyWith<$Res>  {
  factory $LearningSessionCopyWith(LearningSession value, $Res Function(LearningSession) _then) = _$LearningSessionCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'user_id') String userId, LearningMode mode, int? grade,@JsonKey(name: 'unit_code') String? unitCode,@JsonKey(name: 'started_at') DateTime? startedAt,@JsonKey(name: 'ended_at') DateTime? endedAt, int score, double accuracy,@JsonKey(name: 'time_sec') int timeSec,@JsonKey(name: 'earned_xp') int earnedXp,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$LearningSessionCopyWithImpl<$Res>
    implements $LearningSessionCopyWith<$Res> {
  _$LearningSessionCopyWithImpl(this._self, this._then);

  final LearningSession _self;
  final $Res Function(LearningSession) _then;

/// Create a copy of LearningSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? userId = null,Object? mode = null,Object? grade = freezed,Object? unitCode = freezed,Object? startedAt = freezed,Object? endedAt = freezed,Object? score = null,Object? accuracy = null,Object? timeSec = null,Object? earnedXp = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as LearningMode,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as int?,unitCode: freezed == unitCode ? _self.unitCode : unitCode // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,timeSec: null == timeSec ? _self.timeSec : timeSec // ignore: cast_nullable_to_non_nullable
as int,earnedXp: null == earnedXp ? _self.earnedXp : earnedXp // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LearningSession].
extension LearningSessionPatterns on LearningSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LearningSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LearningSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LearningSession value)  $default,){
final _that = this;
switch (_that) {
case _LearningSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LearningSession value)?  $default,){
final _that = this;
switch (_that) {
case _LearningSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'user_id')  String userId,  LearningMode mode,  int? grade, @JsonKey(name: 'unit_code')  String? unitCode, @JsonKey(name: 'started_at')  DateTime? startedAt, @JsonKey(name: 'ended_at')  DateTime? endedAt,  int score,  double accuracy, @JsonKey(name: 'time_sec')  int timeSec, @JsonKey(name: 'earned_xp')  int earnedXp, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LearningSession() when $default != null:
return $default(_that.id,_that.userId,_that.mode,_that.grade,_that.unitCode,_that.startedAt,_that.endedAt,_that.score,_that.accuracy,_that.timeSec,_that.earnedXp,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'user_id')  String userId,  LearningMode mode,  int? grade, @JsonKey(name: 'unit_code')  String? unitCode, @JsonKey(name: 'started_at')  DateTime? startedAt, @JsonKey(name: 'ended_at')  DateTime? endedAt,  int score,  double accuracy, @JsonKey(name: 'time_sec')  int timeSec, @JsonKey(name: 'earned_xp')  int earnedXp, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _LearningSession():
return $default(_that.id,_that.userId,_that.mode,_that.grade,_that.unitCode,_that.startedAt,_that.endedAt,_that.score,_that.accuracy,_that.timeSec,_that.earnedXp,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'user_id')  String userId,  LearningMode mode,  int? grade, @JsonKey(name: 'unit_code')  String? unitCode, @JsonKey(name: 'started_at')  DateTime? startedAt, @JsonKey(name: 'ended_at')  DateTime? endedAt,  int score,  double accuracy, @JsonKey(name: 'time_sec')  int timeSec, @JsonKey(name: 'earned_xp')  int earnedXp, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _LearningSession() when $default != null:
return $default(_that.id,_that.userId,_that.mode,_that.grade,_that.unitCode,_that.startedAt,_that.endedAt,_that.score,_that.accuracy,_that.timeSec,_that.earnedXp,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LearningSession implements LearningSession {
  const _LearningSession({this.id, @JsonKey(name: 'user_id') required this.userId, required this.mode, this.grade, @JsonKey(name: 'unit_code') this.unitCode, @JsonKey(name: 'started_at') this.startedAt, @JsonKey(name: 'ended_at') this.endedAt, this.score = 0, this.accuracy = 0, @JsonKey(name: 'time_sec') this.timeSec = 0, @JsonKey(name: 'earned_xp') this.earnedXp = 0, @JsonKey(name: 'created_at') this.createdAt});
  factory _LearningSession.fromJson(Map<String, dynamic> json) => _$LearningSessionFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  LearningMode mode;
@override final  int? grade;
@override@JsonKey(name: 'unit_code') final  String? unitCode;
@override@JsonKey(name: 'started_at') final  DateTime? startedAt;
@override@JsonKey(name: 'ended_at') final  DateTime? endedAt;
@override@JsonKey() final  int score;
@override@JsonKey() final  double accuracy;
@override@JsonKey(name: 'time_sec') final  int timeSec;
@override@JsonKey(name: 'earned_xp') final  int earnedXp;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of LearningSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LearningSessionCopyWith<_LearningSession> get copyWith => __$LearningSessionCopyWithImpl<_LearningSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LearningSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LearningSession&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.unitCode, unitCode) || other.unitCode == unitCode)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.score, score) || other.score == score)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.timeSec, timeSec) || other.timeSec == timeSec)&&(identical(other.earnedXp, earnedXp) || other.earnedXp == earnedXp)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,mode,grade,unitCode,startedAt,endedAt,score,accuracy,timeSec,earnedXp,createdAt);

@override
String toString() {
  return 'LearningSession(id: $id, userId: $userId, mode: $mode, grade: $grade, unitCode: $unitCode, startedAt: $startedAt, endedAt: $endedAt, score: $score, accuracy: $accuracy, timeSec: $timeSec, earnedXp: $earnedXp, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LearningSessionCopyWith<$Res> implements $LearningSessionCopyWith<$Res> {
  factory _$LearningSessionCopyWith(_LearningSession value, $Res Function(_LearningSession) _then) = __$LearningSessionCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'user_id') String userId, LearningMode mode, int? grade,@JsonKey(name: 'unit_code') String? unitCode,@JsonKey(name: 'started_at') DateTime? startedAt,@JsonKey(name: 'ended_at') DateTime? endedAt, int score, double accuracy,@JsonKey(name: 'time_sec') int timeSec,@JsonKey(name: 'earned_xp') int earnedXp,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$LearningSessionCopyWithImpl<$Res>
    implements _$LearningSessionCopyWith<$Res> {
  __$LearningSessionCopyWithImpl(this._self, this._then);

  final _LearningSession _self;
  final $Res Function(_LearningSession) _then;

/// Create a copy of LearningSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? userId = null,Object? mode = null,Object? grade = freezed,Object? unitCode = freezed,Object? startedAt = freezed,Object? endedAt = freezed,Object? score = null,Object? accuracy = null,Object? timeSec = null,Object? earnedXp = null,Object? createdAt = freezed,}) {
  return _then(_LearningSession(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as LearningMode,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as int?,unitCode: freezed == unitCode ? _self.unitCode : unitCode // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,timeSec: null == timeSec ? _self.timeSec : timeSec // ignore: cast_nullable_to_non_nullable
as int,earnedXp: null == earnedXp ? _self.earnedXp : earnedXp // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
