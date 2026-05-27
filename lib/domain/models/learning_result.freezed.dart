// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'learning_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LearningResult {

 String? get id;@JsonKey(name: 'session_id') String? get sessionId;@JsonKey(name: 'hanja_id') String? get hanjaId; LearningMode get mode; int get score; double get accuracy; int get stars;@JsonKey(name: 'time_sec') int get timeSec;@JsonKey(name: 'earned_xp') int get earnedXp; int get coins;@JsonKey(name: 'correct_count') int get correctCount;@JsonKey(name: 'total_count') int get totalCount;@JsonKey(name: 'completed_at') DateTime? get completedAt;
/// Create a copy of LearningResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LearningResultCopyWith<LearningResult> get copyWith => _$LearningResultCopyWithImpl<LearningResult>(this as LearningResult, _$identity);

  /// Serializes this LearningResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LearningResult&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.hanjaId, hanjaId) || other.hanjaId == hanjaId)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.score, score) || other.score == score)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.timeSec, timeSec) || other.timeSec == timeSec)&&(identical(other.earnedXp, earnedXp) || other.earnedXp == earnedXp)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.correctCount, correctCount) || other.correctCount == correctCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,hanjaId,mode,score,accuracy,stars,timeSec,earnedXp,coins,correctCount,totalCount,completedAt);

@override
String toString() {
  return 'LearningResult(id: $id, sessionId: $sessionId, hanjaId: $hanjaId, mode: $mode, score: $score, accuracy: $accuracy, stars: $stars, timeSec: $timeSec, earnedXp: $earnedXp, coins: $coins, correctCount: $correctCount, totalCount: $totalCount, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $LearningResultCopyWith<$Res>  {
  factory $LearningResultCopyWith(LearningResult value, $Res Function(LearningResult) _then) = _$LearningResultCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'session_id') String? sessionId,@JsonKey(name: 'hanja_id') String? hanjaId, LearningMode mode, int score, double accuracy, int stars,@JsonKey(name: 'time_sec') int timeSec,@JsonKey(name: 'earned_xp') int earnedXp, int coins,@JsonKey(name: 'correct_count') int correctCount,@JsonKey(name: 'total_count') int totalCount,@JsonKey(name: 'completed_at') DateTime? completedAt
});




}
/// @nodoc
class _$LearningResultCopyWithImpl<$Res>
    implements $LearningResultCopyWith<$Res> {
  _$LearningResultCopyWithImpl(this._self, this._then);

  final LearningResult _self;
  final $Res Function(LearningResult) _then;

/// Create a copy of LearningResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? sessionId = freezed,Object? hanjaId = freezed,Object? mode = null,Object? score = null,Object? accuracy = null,Object? stars = null,Object? timeSec = null,Object? earnedXp = null,Object? coins = null,Object? correctCount = null,Object? totalCount = null,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,hanjaId: freezed == hanjaId ? _self.hanjaId : hanjaId // ignore: cast_nullable_to_non_nullable
as String?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as LearningMode,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,timeSec: null == timeSec ? _self.timeSec : timeSec // ignore: cast_nullable_to_non_nullable
as int,earnedXp: null == earnedXp ? _self.earnedXp : earnedXp // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,correctCount: null == correctCount ? _self.correctCount : correctCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LearningResult].
extension LearningResultPatterns on LearningResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LearningResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LearningResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LearningResult value)  $default,){
final _that = this;
switch (_that) {
case _LearningResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LearningResult value)?  $default,){
final _that = this;
switch (_that) {
case _LearningResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'session_id')  String? sessionId, @JsonKey(name: 'hanja_id')  String? hanjaId,  LearningMode mode,  int score,  double accuracy,  int stars, @JsonKey(name: 'time_sec')  int timeSec, @JsonKey(name: 'earned_xp')  int earnedXp,  int coins, @JsonKey(name: 'correct_count')  int correctCount, @JsonKey(name: 'total_count')  int totalCount, @JsonKey(name: 'completed_at')  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LearningResult() when $default != null:
return $default(_that.id,_that.sessionId,_that.hanjaId,_that.mode,_that.score,_that.accuracy,_that.stars,_that.timeSec,_that.earnedXp,_that.coins,_that.correctCount,_that.totalCount,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'session_id')  String? sessionId, @JsonKey(name: 'hanja_id')  String? hanjaId,  LearningMode mode,  int score,  double accuracy,  int stars, @JsonKey(name: 'time_sec')  int timeSec, @JsonKey(name: 'earned_xp')  int earnedXp,  int coins, @JsonKey(name: 'correct_count')  int correctCount, @JsonKey(name: 'total_count')  int totalCount, @JsonKey(name: 'completed_at')  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _LearningResult():
return $default(_that.id,_that.sessionId,_that.hanjaId,_that.mode,_that.score,_that.accuracy,_that.stars,_that.timeSec,_that.earnedXp,_that.coins,_that.correctCount,_that.totalCount,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'session_id')  String? sessionId, @JsonKey(name: 'hanja_id')  String? hanjaId,  LearningMode mode,  int score,  double accuracy,  int stars, @JsonKey(name: 'time_sec')  int timeSec, @JsonKey(name: 'earned_xp')  int earnedXp,  int coins, @JsonKey(name: 'correct_count')  int correctCount, @JsonKey(name: 'total_count')  int totalCount, @JsonKey(name: 'completed_at')  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _LearningResult() when $default != null:
return $default(_that.id,_that.sessionId,_that.hanjaId,_that.mode,_that.score,_that.accuracy,_that.stars,_that.timeSec,_that.earnedXp,_that.coins,_that.correctCount,_that.totalCount,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LearningResult implements LearningResult {
  const _LearningResult({this.id, @JsonKey(name: 'session_id') this.sessionId, @JsonKey(name: 'hanja_id') this.hanjaId, required this.mode, this.score = 0, this.accuracy = 0, this.stars = 0, @JsonKey(name: 'time_sec') this.timeSec = 0, @JsonKey(name: 'earned_xp') this.earnedXp = 0, this.coins = 0, @JsonKey(name: 'correct_count') this.correctCount = 0, @JsonKey(name: 'total_count') this.totalCount = 0, @JsonKey(name: 'completed_at') this.completedAt});
  factory _LearningResult.fromJson(Map<String, dynamic> json) => _$LearningResultFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'session_id') final  String? sessionId;
@override@JsonKey(name: 'hanja_id') final  String? hanjaId;
@override final  LearningMode mode;
@override@JsonKey() final  int score;
@override@JsonKey() final  double accuracy;
@override@JsonKey() final  int stars;
@override@JsonKey(name: 'time_sec') final  int timeSec;
@override@JsonKey(name: 'earned_xp') final  int earnedXp;
@override@JsonKey() final  int coins;
@override@JsonKey(name: 'correct_count') final  int correctCount;
@override@JsonKey(name: 'total_count') final  int totalCount;
@override@JsonKey(name: 'completed_at') final  DateTime? completedAt;

/// Create a copy of LearningResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LearningResultCopyWith<_LearningResult> get copyWith => __$LearningResultCopyWithImpl<_LearningResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LearningResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LearningResult&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.hanjaId, hanjaId) || other.hanjaId == hanjaId)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.score, score) || other.score == score)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.timeSec, timeSec) || other.timeSec == timeSec)&&(identical(other.earnedXp, earnedXp) || other.earnedXp == earnedXp)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.correctCount, correctCount) || other.correctCount == correctCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,hanjaId,mode,score,accuracy,stars,timeSec,earnedXp,coins,correctCount,totalCount,completedAt);

@override
String toString() {
  return 'LearningResult(id: $id, sessionId: $sessionId, hanjaId: $hanjaId, mode: $mode, score: $score, accuracy: $accuracy, stars: $stars, timeSec: $timeSec, earnedXp: $earnedXp, coins: $coins, correctCount: $correctCount, totalCount: $totalCount, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$LearningResultCopyWith<$Res> implements $LearningResultCopyWith<$Res> {
  factory _$LearningResultCopyWith(_LearningResult value, $Res Function(_LearningResult) _then) = __$LearningResultCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'session_id') String? sessionId,@JsonKey(name: 'hanja_id') String? hanjaId, LearningMode mode, int score, double accuracy, int stars,@JsonKey(name: 'time_sec') int timeSec,@JsonKey(name: 'earned_xp') int earnedXp, int coins,@JsonKey(name: 'correct_count') int correctCount,@JsonKey(name: 'total_count') int totalCount,@JsonKey(name: 'completed_at') DateTime? completedAt
});




}
/// @nodoc
class __$LearningResultCopyWithImpl<$Res>
    implements _$LearningResultCopyWith<$Res> {
  __$LearningResultCopyWithImpl(this._self, this._then);

  final _LearningResult _self;
  final $Res Function(_LearningResult) _then;

/// Create a copy of LearningResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? sessionId = freezed,Object? hanjaId = freezed,Object? mode = null,Object? score = null,Object? accuracy = null,Object? stars = null,Object? timeSec = null,Object? earnedXp = null,Object? coins = null,Object? correctCount = null,Object? totalCount = null,Object? completedAt = freezed,}) {
  return _then(_LearningResult(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,hanjaId: freezed == hanjaId ? _self.hanjaId : hanjaId // ignore: cast_nullable_to_non_nullable
as String?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as LearningMode,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,timeSec: null == timeSec ? _self.timeSec : timeSec // ignore: cast_nullable_to_non_nullable
as int,earnedXp: null == earnedXp ? _self.earnedXp : earnedXp // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,correctCount: null == correctCount ? _self.correctCount : correctCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
