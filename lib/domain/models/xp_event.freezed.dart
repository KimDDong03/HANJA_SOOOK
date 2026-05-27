// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'xp_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$XpEvent {

 String? get id;@JsonKey(name: 'user_id') String get userId; String get source; int get amount;@JsonKey(name: 'ref_table') String? get refTable;@JsonKey(name: 'ref_id') String? get refId;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of XpEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XpEventCopyWith<XpEvent> get copyWith => _$XpEventCopyWithImpl<XpEvent>(this as XpEvent, _$identity);

  /// Serializes this XpEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XpEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.source, source) || other.source == source)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.refTable, refTable) || other.refTable == refTable)&&(identical(other.refId, refId) || other.refId == refId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,source,amount,refTable,refId,createdAt);

@override
String toString() {
  return 'XpEvent(id: $id, userId: $userId, source: $source, amount: $amount, refTable: $refTable, refId: $refId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $XpEventCopyWith<$Res>  {
  factory $XpEventCopyWith(XpEvent value, $Res Function(XpEvent) _then) = _$XpEventCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'user_id') String userId, String source, int amount,@JsonKey(name: 'ref_table') String? refTable,@JsonKey(name: 'ref_id') String? refId,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$XpEventCopyWithImpl<$Res>
    implements $XpEventCopyWith<$Res> {
  _$XpEventCopyWithImpl(this._self, this._then);

  final XpEvent _self;
  final $Res Function(XpEvent) _then;

/// Create a copy of XpEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? userId = null,Object? source = null,Object? amount = null,Object? refTable = freezed,Object? refId = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,refTable: freezed == refTable ? _self.refTable : refTable // ignore: cast_nullable_to_non_nullable
as String?,refId: freezed == refId ? _self.refId : refId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [XpEvent].
extension XpEventPatterns on XpEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XpEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XpEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XpEvent value)  $default,){
final _that = this;
switch (_that) {
case _XpEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XpEvent value)?  $default,){
final _that = this;
switch (_that) {
case _XpEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'user_id')  String userId,  String source,  int amount, @JsonKey(name: 'ref_table')  String? refTable, @JsonKey(name: 'ref_id')  String? refId, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XpEvent() when $default != null:
return $default(_that.id,_that.userId,_that.source,_that.amount,_that.refTable,_that.refId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'user_id')  String userId,  String source,  int amount, @JsonKey(name: 'ref_table')  String? refTable, @JsonKey(name: 'ref_id')  String? refId, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _XpEvent():
return $default(_that.id,_that.userId,_that.source,_that.amount,_that.refTable,_that.refId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'user_id')  String userId,  String source,  int amount, @JsonKey(name: 'ref_table')  String? refTable, @JsonKey(name: 'ref_id')  String? refId, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _XpEvent() when $default != null:
return $default(_that.id,_that.userId,_that.source,_that.amount,_that.refTable,_that.refId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XpEvent implements XpEvent {
  const _XpEvent({this.id, @JsonKey(name: 'user_id') required this.userId, required this.source, required this.amount, @JsonKey(name: 'ref_table') this.refTable, @JsonKey(name: 'ref_id') this.refId, @JsonKey(name: 'created_at') this.createdAt});
  factory _XpEvent.fromJson(Map<String, dynamic> json) => _$XpEventFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String source;
@override final  int amount;
@override@JsonKey(name: 'ref_table') final  String? refTable;
@override@JsonKey(name: 'ref_id') final  String? refId;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of XpEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XpEventCopyWith<_XpEvent> get copyWith => __$XpEventCopyWithImpl<_XpEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XpEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _XpEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.source, source) || other.source == source)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.refTable, refTable) || other.refTable == refTable)&&(identical(other.refId, refId) || other.refId == refId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,source,amount,refTable,refId,createdAt);

@override
String toString() {
  return 'XpEvent(id: $id, userId: $userId, source: $source, amount: $amount, refTable: $refTable, refId: $refId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$XpEventCopyWith<$Res> implements $XpEventCopyWith<$Res> {
  factory _$XpEventCopyWith(_XpEvent value, $Res Function(_XpEvent) _then) = __$XpEventCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'user_id') String userId, String source, int amount,@JsonKey(name: 'ref_table') String? refTable,@JsonKey(name: 'ref_id') String? refId,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$XpEventCopyWithImpl<$Res>
    implements _$XpEventCopyWith<$Res> {
  __$XpEventCopyWithImpl(this._self, this._then);

  final _XpEvent _self;
  final $Res Function(_XpEvent) _then;

/// Create a copy of XpEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? userId = null,Object? source = null,Object? amount = null,Object? refTable = freezed,Object? refId = freezed,Object? createdAt = freezed,}) {
  return _then(_XpEvent(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,refTable: freezed == refTable ? _self.refTable : refTable // ignore: cast_nullable_to_non_nullable
as String?,refId: freezed == refId ? _self.refId : refId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
