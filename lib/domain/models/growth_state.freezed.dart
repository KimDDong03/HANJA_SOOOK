// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'growth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GrowthState {

@JsonKey(name: 'user_id') String get userId; int get level;@JsonKey(name: 'total_xp') int get totalXp; int get coins;@JsonKey(name: 'current_level_required_xp') int get currentLevelRequiredXp;@JsonKey(name: 'next_level_required_xp') int? get nextLevelRequiredXp; List<Badge> get badges;@JsonKey(name: 'ability_scores') Map<String, int> get abilityScores;
/// Create a copy of GrowthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GrowthStateCopyWith<GrowthState> get copyWith => _$GrowthStateCopyWithImpl<GrowthState>(this as GrowthState, _$identity);

  /// Serializes this GrowthState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GrowthState&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.level, level) || other.level == level)&&(identical(other.totalXp, totalXp) || other.totalXp == totalXp)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.currentLevelRequiredXp, currentLevelRequiredXp) || other.currentLevelRequiredXp == currentLevelRequiredXp)&&(identical(other.nextLevelRequiredXp, nextLevelRequiredXp) || other.nextLevelRequiredXp == nextLevelRequiredXp)&&const DeepCollectionEquality().equals(other.badges, badges)&&const DeepCollectionEquality().equals(other.abilityScores, abilityScores));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,level,totalXp,coins,currentLevelRequiredXp,nextLevelRequiredXp,const DeepCollectionEquality().hash(badges),const DeepCollectionEquality().hash(abilityScores));

@override
String toString() {
  return 'GrowthState(userId: $userId, level: $level, totalXp: $totalXp, coins: $coins, currentLevelRequiredXp: $currentLevelRequiredXp, nextLevelRequiredXp: $nextLevelRequiredXp, badges: $badges, abilityScores: $abilityScores)';
}


}

/// @nodoc
abstract mixin class $GrowthStateCopyWith<$Res>  {
  factory $GrowthStateCopyWith(GrowthState value, $Res Function(GrowthState) _then) = _$GrowthStateCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId, int level,@JsonKey(name: 'total_xp') int totalXp, int coins,@JsonKey(name: 'current_level_required_xp') int currentLevelRequiredXp,@JsonKey(name: 'next_level_required_xp') int? nextLevelRequiredXp, List<Badge> badges,@JsonKey(name: 'ability_scores') Map<String, int> abilityScores
});




}
/// @nodoc
class _$GrowthStateCopyWithImpl<$Res>
    implements $GrowthStateCopyWith<$Res> {
  _$GrowthStateCopyWithImpl(this._self, this._then);

  final GrowthState _self;
  final $Res Function(GrowthState) _then;

/// Create a copy of GrowthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? level = null,Object? totalXp = null,Object? coins = null,Object? currentLevelRequiredXp = null,Object? nextLevelRequiredXp = freezed,Object? badges = null,Object? abilityScores = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,totalXp: null == totalXp ? _self.totalXp : totalXp // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,currentLevelRequiredXp: null == currentLevelRequiredXp ? _self.currentLevelRequiredXp : currentLevelRequiredXp // ignore: cast_nullable_to_non_nullable
as int,nextLevelRequiredXp: freezed == nextLevelRequiredXp ? _self.nextLevelRequiredXp : nextLevelRequiredXp // ignore: cast_nullable_to_non_nullable
as int?,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<Badge>,abilityScores: null == abilityScores ? _self.abilityScores : abilityScores // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [GrowthState].
extension GrowthStatePatterns on GrowthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GrowthState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GrowthState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GrowthState value)  $default,){
final _that = this;
switch (_that) {
case _GrowthState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GrowthState value)?  $default,){
final _that = this;
switch (_that) {
case _GrowthState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  int level, @JsonKey(name: 'total_xp')  int totalXp,  int coins, @JsonKey(name: 'current_level_required_xp')  int currentLevelRequiredXp, @JsonKey(name: 'next_level_required_xp')  int? nextLevelRequiredXp,  List<Badge> badges, @JsonKey(name: 'ability_scores')  Map<String, int> abilityScores)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GrowthState() when $default != null:
return $default(_that.userId,_that.level,_that.totalXp,_that.coins,_that.currentLevelRequiredXp,_that.nextLevelRequiredXp,_that.badges,_that.abilityScores);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  int level, @JsonKey(name: 'total_xp')  int totalXp,  int coins, @JsonKey(name: 'current_level_required_xp')  int currentLevelRequiredXp, @JsonKey(name: 'next_level_required_xp')  int? nextLevelRequiredXp,  List<Badge> badges, @JsonKey(name: 'ability_scores')  Map<String, int> abilityScores)  $default,) {final _that = this;
switch (_that) {
case _GrowthState():
return $default(_that.userId,_that.level,_that.totalXp,_that.coins,_that.currentLevelRequiredXp,_that.nextLevelRequiredXp,_that.badges,_that.abilityScores);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId,  int level, @JsonKey(name: 'total_xp')  int totalXp,  int coins, @JsonKey(name: 'current_level_required_xp')  int currentLevelRequiredXp, @JsonKey(name: 'next_level_required_xp')  int? nextLevelRequiredXp,  List<Badge> badges, @JsonKey(name: 'ability_scores')  Map<String, int> abilityScores)?  $default,) {final _that = this;
switch (_that) {
case _GrowthState() when $default != null:
return $default(_that.userId,_that.level,_that.totalXp,_that.coins,_that.currentLevelRequiredXp,_that.nextLevelRequiredXp,_that.badges,_that.abilityScores);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GrowthState implements GrowthState {
  const _GrowthState({@JsonKey(name: 'user_id') required this.userId, this.level = 1, @JsonKey(name: 'total_xp') this.totalXp = 0, this.coins = 0, @JsonKey(name: 'current_level_required_xp') this.currentLevelRequiredXp = 0, @JsonKey(name: 'next_level_required_xp') this.nextLevelRequiredXp, final  List<Badge> badges = const <Badge>[], @JsonKey(name: 'ability_scores') final  Map<String, int> abilityScores = const <String, int>{}}): _badges = badges,_abilityScores = abilityScores;
  factory _GrowthState.fromJson(Map<String, dynamic> json) => _$GrowthStateFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey() final  int level;
@override@JsonKey(name: 'total_xp') final  int totalXp;
@override@JsonKey() final  int coins;
@override@JsonKey(name: 'current_level_required_xp') final  int currentLevelRequiredXp;
@override@JsonKey(name: 'next_level_required_xp') final  int? nextLevelRequiredXp;
 final  List<Badge> _badges;
@override@JsonKey() List<Badge> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}

 final  Map<String, int> _abilityScores;
@override@JsonKey(name: 'ability_scores') Map<String, int> get abilityScores {
  if (_abilityScores is EqualUnmodifiableMapView) return _abilityScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_abilityScores);
}


/// Create a copy of GrowthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GrowthStateCopyWith<_GrowthState> get copyWith => __$GrowthStateCopyWithImpl<_GrowthState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GrowthStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GrowthState&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.level, level) || other.level == level)&&(identical(other.totalXp, totalXp) || other.totalXp == totalXp)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.currentLevelRequiredXp, currentLevelRequiredXp) || other.currentLevelRequiredXp == currentLevelRequiredXp)&&(identical(other.nextLevelRequiredXp, nextLevelRequiredXp) || other.nextLevelRequiredXp == nextLevelRequiredXp)&&const DeepCollectionEquality().equals(other._badges, _badges)&&const DeepCollectionEquality().equals(other._abilityScores, _abilityScores));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,level,totalXp,coins,currentLevelRequiredXp,nextLevelRequiredXp,const DeepCollectionEquality().hash(_badges),const DeepCollectionEquality().hash(_abilityScores));

@override
String toString() {
  return 'GrowthState(userId: $userId, level: $level, totalXp: $totalXp, coins: $coins, currentLevelRequiredXp: $currentLevelRequiredXp, nextLevelRequiredXp: $nextLevelRequiredXp, badges: $badges, abilityScores: $abilityScores)';
}


}

/// @nodoc
abstract mixin class _$GrowthStateCopyWith<$Res> implements $GrowthStateCopyWith<$Res> {
  factory _$GrowthStateCopyWith(_GrowthState value, $Res Function(_GrowthState) _then) = __$GrowthStateCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId, int level,@JsonKey(name: 'total_xp') int totalXp, int coins,@JsonKey(name: 'current_level_required_xp') int currentLevelRequiredXp,@JsonKey(name: 'next_level_required_xp') int? nextLevelRequiredXp, List<Badge> badges,@JsonKey(name: 'ability_scores') Map<String, int> abilityScores
});




}
/// @nodoc
class __$GrowthStateCopyWithImpl<$Res>
    implements _$GrowthStateCopyWith<$Res> {
  __$GrowthStateCopyWithImpl(this._self, this._then);

  final _GrowthState _self;
  final $Res Function(_GrowthState) _then;

/// Create a copy of GrowthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? level = null,Object? totalXp = null,Object? coins = null,Object? currentLevelRequiredXp = null,Object? nextLevelRequiredXp = freezed,Object? badges = null,Object? abilityScores = null,}) {
  return _then(_GrowthState(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,totalXp: null == totalXp ? _self.totalXp : totalXp // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,currentLevelRequiredXp: null == currentLevelRequiredXp ? _self.currentLevelRequiredXp : currentLevelRequiredXp // ignore: cast_nullable_to_non_nullable
as int,nextLevelRequiredXp: freezed == nextLevelRequiredXp ? _self.nextLevelRequiredXp : nextLevelRequiredXp // ignore: cast_nullable_to_non_nullable
as int?,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<Badge>,abilityScores: null == abilityScores ? _self._abilityScores : abilityScores // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
