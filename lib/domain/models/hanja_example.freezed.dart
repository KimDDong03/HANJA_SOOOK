// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hanja_example.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HanjaExample {

 String? get id;@JsonKey(name: 'hanja_id') String get hanjaId; String get sentence; String? get meaning; String? get source; ContentDifficulty get difficulty;@JsonKey(name: 'sort_order') int get sortOrder;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of HanjaExample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HanjaExampleCopyWith<HanjaExample> get copyWith => _$HanjaExampleCopyWithImpl<HanjaExample>(this as HanjaExample, _$identity);

  /// Serializes this HanjaExample to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HanjaExample&&(identical(other.id, id) || other.id == id)&&(identical(other.hanjaId, hanjaId) || other.hanjaId == hanjaId)&&(identical(other.sentence, sentence) || other.sentence == sentence)&&(identical(other.meaning, meaning) || other.meaning == meaning)&&(identical(other.source, source) || other.source == source)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hanjaId,sentence,meaning,source,difficulty,sortOrder,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'HanjaExample(id: $id, hanjaId: $hanjaId, sentence: $sentence, meaning: $meaning, source: $source, difficulty: $difficulty, sortOrder: $sortOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $HanjaExampleCopyWith<$Res>  {
  factory $HanjaExampleCopyWith(HanjaExample value, $Res Function(HanjaExample) _then) = _$HanjaExampleCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'hanja_id') String hanjaId, String sentence, String? meaning, String? source, ContentDifficulty difficulty,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$HanjaExampleCopyWithImpl<$Res>
    implements $HanjaExampleCopyWith<$Res> {
  _$HanjaExampleCopyWithImpl(this._self, this._then);

  final HanjaExample _self;
  final $Res Function(HanjaExample) _then;

/// Create a copy of HanjaExample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? hanjaId = null,Object? sentence = null,Object? meaning = freezed,Object? source = freezed,Object? difficulty = null,Object? sortOrder = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,hanjaId: null == hanjaId ? _self.hanjaId : hanjaId // ignore: cast_nullable_to_non_nullable
as String,sentence: null == sentence ? _self.sentence : sentence // ignore: cast_nullable_to_non_nullable
as String,meaning: freezed == meaning ? _self.meaning : meaning // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as ContentDifficulty,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [HanjaExample].
extension HanjaExamplePatterns on HanjaExample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HanjaExample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HanjaExample() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HanjaExample value)  $default,){
final _that = this;
switch (_that) {
case _HanjaExample():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HanjaExample value)?  $default,){
final _that = this;
switch (_that) {
case _HanjaExample() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'hanja_id')  String hanjaId,  String sentence,  String? meaning,  String? source,  ContentDifficulty difficulty, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HanjaExample() when $default != null:
return $default(_that.id,_that.hanjaId,_that.sentence,_that.meaning,_that.source,_that.difficulty,_that.sortOrder,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'hanja_id')  String hanjaId,  String sentence,  String? meaning,  String? source,  ContentDifficulty difficulty, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _HanjaExample():
return $default(_that.id,_that.hanjaId,_that.sentence,_that.meaning,_that.source,_that.difficulty,_that.sortOrder,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'hanja_id')  String hanjaId,  String sentence,  String? meaning,  String? source,  ContentDifficulty difficulty, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _HanjaExample() when $default != null:
return $default(_that.id,_that.hanjaId,_that.sentence,_that.meaning,_that.source,_that.difficulty,_that.sortOrder,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HanjaExample implements HanjaExample {
  const _HanjaExample({this.id, @JsonKey(name: 'hanja_id') required this.hanjaId, required this.sentence, this.meaning, this.source, this.difficulty = ContentDifficulty.normal, @JsonKey(name: 'sort_order') this.sortOrder = 0, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _HanjaExample.fromJson(Map<String, dynamic> json) => _$HanjaExampleFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'hanja_id') final  String hanjaId;
@override final  String sentence;
@override final  String? meaning;
@override final  String? source;
@override@JsonKey() final  ContentDifficulty difficulty;
@override@JsonKey(name: 'sort_order') final  int sortOrder;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of HanjaExample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HanjaExampleCopyWith<_HanjaExample> get copyWith => __$HanjaExampleCopyWithImpl<_HanjaExample>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HanjaExampleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HanjaExample&&(identical(other.id, id) || other.id == id)&&(identical(other.hanjaId, hanjaId) || other.hanjaId == hanjaId)&&(identical(other.sentence, sentence) || other.sentence == sentence)&&(identical(other.meaning, meaning) || other.meaning == meaning)&&(identical(other.source, source) || other.source == source)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hanjaId,sentence,meaning,source,difficulty,sortOrder,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'HanjaExample(id: $id, hanjaId: $hanjaId, sentence: $sentence, meaning: $meaning, source: $source, difficulty: $difficulty, sortOrder: $sortOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$HanjaExampleCopyWith<$Res> implements $HanjaExampleCopyWith<$Res> {
  factory _$HanjaExampleCopyWith(_HanjaExample value, $Res Function(_HanjaExample) _then) = __$HanjaExampleCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'hanja_id') String hanjaId, String sentence, String? meaning, String? source, ContentDifficulty difficulty,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$HanjaExampleCopyWithImpl<$Res>
    implements _$HanjaExampleCopyWith<$Res> {
  __$HanjaExampleCopyWithImpl(this._self, this._then);

  final _HanjaExample _self;
  final $Res Function(_HanjaExample) _then;

/// Create a copy of HanjaExample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? hanjaId = null,Object? sentence = null,Object? meaning = freezed,Object? source = freezed,Object? difficulty = null,Object? sortOrder = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_HanjaExample(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,hanjaId: null == hanjaId ? _self.hanjaId : hanjaId // ignore: cast_nullable_to_non_nullable
as String,sentence: null == sentence ? _self.sentence : sentence // ignore: cast_nullable_to_non_nullable
as String,meaning: freezed == meaning ? _self.meaning : meaning // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as ContentDifficulty,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
