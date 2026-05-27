// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuizQuestion {

 String get id;@JsonKey(name: 'hanja_id') String? get hanjaId; int get grade;@JsonKey(name: 'unit_code') String? get unitCode; QuizQuestionType get type; String get prompt;@JsonKey(name: 'correct_answer') String get correctAnswer; List<String> get options; String? get explanation; ContentDifficulty get difficulty;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of QuizQuestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuizQuestionCopyWith<QuizQuestion> get copyWith => _$QuizQuestionCopyWithImpl<QuizQuestion>(this as QuizQuestion, _$identity);

  /// Serializes this QuizQuestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuizQuestion&&(identical(other.id, id) || other.id == id)&&(identical(other.hanjaId, hanjaId) || other.hanjaId == hanjaId)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.unitCode, unitCode) || other.unitCode == unitCode)&&(identical(other.type, type) || other.type == type)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.correctAnswer, correctAnswer) || other.correctAnswer == correctAnswer)&&const DeepCollectionEquality().equals(other.options, options)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hanjaId,grade,unitCode,type,prompt,correctAnswer,const DeepCollectionEquality().hash(options),explanation,difficulty,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'QuizQuestion(id: $id, hanjaId: $hanjaId, grade: $grade, unitCode: $unitCode, type: $type, prompt: $prompt, correctAnswer: $correctAnswer, options: $options, explanation: $explanation, difficulty: $difficulty, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $QuizQuestionCopyWith<$Res>  {
  factory $QuizQuestionCopyWith(QuizQuestion value, $Res Function(QuizQuestion) _then) = _$QuizQuestionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'hanja_id') String? hanjaId, int grade,@JsonKey(name: 'unit_code') String? unitCode, QuizQuestionType type, String prompt,@JsonKey(name: 'correct_answer') String correctAnswer, List<String> options, String? explanation, ContentDifficulty difficulty,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$QuizQuestionCopyWithImpl<$Res>
    implements $QuizQuestionCopyWith<$Res> {
  _$QuizQuestionCopyWithImpl(this._self, this._then);

  final QuizQuestion _self;
  final $Res Function(QuizQuestion) _then;

/// Create a copy of QuizQuestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hanjaId = freezed,Object? grade = null,Object? unitCode = freezed,Object? type = null,Object? prompt = null,Object? correctAnswer = null,Object? options = null,Object? explanation = freezed,Object? difficulty = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hanjaId: freezed == hanjaId ? _self.hanjaId : hanjaId // ignore: cast_nullable_to_non_nullable
as String?,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as int,unitCode: freezed == unitCode ? _self.unitCode : unitCode // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as QuizQuestionType,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,correctAnswer: null == correctAnswer ? _self.correctAnswer : correctAnswer // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<String>,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as ContentDifficulty,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [QuizQuestion].
extension QuizQuestionPatterns on QuizQuestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuizQuestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuizQuestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuizQuestion value)  $default,){
final _that = this;
switch (_that) {
case _QuizQuestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuizQuestion value)?  $default,){
final _that = this;
switch (_that) {
case _QuizQuestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'hanja_id')  String? hanjaId,  int grade, @JsonKey(name: 'unit_code')  String? unitCode,  QuizQuestionType type,  String prompt, @JsonKey(name: 'correct_answer')  String correctAnswer,  List<String> options,  String? explanation,  ContentDifficulty difficulty, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuizQuestion() when $default != null:
return $default(_that.id,_that.hanjaId,_that.grade,_that.unitCode,_that.type,_that.prompt,_that.correctAnswer,_that.options,_that.explanation,_that.difficulty,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'hanja_id')  String? hanjaId,  int grade, @JsonKey(name: 'unit_code')  String? unitCode,  QuizQuestionType type,  String prompt, @JsonKey(name: 'correct_answer')  String correctAnswer,  List<String> options,  String? explanation,  ContentDifficulty difficulty, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _QuizQuestion():
return $default(_that.id,_that.hanjaId,_that.grade,_that.unitCode,_that.type,_that.prompt,_that.correctAnswer,_that.options,_that.explanation,_that.difficulty,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'hanja_id')  String? hanjaId,  int grade, @JsonKey(name: 'unit_code')  String? unitCode,  QuizQuestionType type,  String prompt, @JsonKey(name: 'correct_answer')  String correctAnswer,  List<String> options,  String? explanation,  ContentDifficulty difficulty, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _QuizQuestion() when $default != null:
return $default(_that.id,_that.hanjaId,_that.grade,_that.unitCode,_that.type,_that.prompt,_that.correctAnswer,_that.options,_that.explanation,_that.difficulty,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuizQuestion implements QuizQuestion {
  const _QuizQuestion({required this.id, @JsonKey(name: 'hanja_id') this.hanjaId, required this.grade, @JsonKey(name: 'unit_code') this.unitCode, required this.type, required this.prompt, @JsonKey(name: 'correct_answer') required this.correctAnswer, final  List<String> options = const <String>[], this.explanation, this.difficulty = ContentDifficulty.normal, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _options = options;
  factory _QuizQuestion.fromJson(Map<String, dynamic> json) => _$QuizQuestionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'hanja_id') final  String? hanjaId;
@override final  int grade;
@override@JsonKey(name: 'unit_code') final  String? unitCode;
@override final  QuizQuestionType type;
@override final  String prompt;
@override@JsonKey(name: 'correct_answer') final  String correctAnswer;
 final  List<String> _options;
@override@JsonKey() List<String> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

@override final  String? explanation;
@override@JsonKey() final  ContentDifficulty difficulty;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of QuizQuestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuizQuestionCopyWith<_QuizQuestion> get copyWith => __$QuizQuestionCopyWithImpl<_QuizQuestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuizQuestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuizQuestion&&(identical(other.id, id) || other.id == id)&&(identical(other.hanjaId, hanjaId) || other.hanjaId == hanjaId)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.unitCode, unitCode) || other.unitCode == unitCode)&&(identical(other.type, type) || other.type == type)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.correctAnswer, correctAnswer) || other.correctAnswer == correctAnswer)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hanjaId,grade,unitCode,type,prompt,correctAnswer,const DeepCollectionEquality().hash(_options),explanation,difficulty,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'QuizQuestion(id: $id, hanjaId: $hanjaId, grade: $grade, unitCode: $unitCode, type: $type, prompt: $prompt, correctAnswer: $correctAnswer, options: $options, explanation: $explanation, difficulty: $difficulty, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$QuizQuestionCopyWith<$Res> implements $QuizQuestionCopyWith<$Res> {
  factory _$QuizQuestionCopyWith(_QuizQuestion value, $Res Function(_QuizQuestion) _then) = __$QuizQuestionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'hanja_id') String? hanjaId, int grade,@JsonKey(name: 'unit_code') String? unitCode, QuizQuestionType type, String prompt,@JsonKey(name: 'correct_answer') String correctAnswer, List<String> options, String? explanation, ContentDifficulty difficulty,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$QuizQuestionCopyWithImpl<$Res>
    implements _$QuizQuestionCopyWith<$Res> {
  __$QuizQuestionCopyWithImpl(this._self, this._then);

  final _QuizQuestion _self;
  final $Res Function(_QuizQuestion) _then;

/// Create a copy of QuizQuestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hanjaId = freezed,Object? grade = null,Object? unitCode = freezed,Object? type = null,Object? prompt = null,Object? correctAnswer = null,Object? options = null,Object? explanation = freezed,Object? difficulty = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_QuizQuestion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hanjaId: freezed == hanjaId ? _self.hanjaId : hanjaId // ignore: cast_nullable_to_non_nullable
as String?,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as int,unitCode: freezed == unitCode ? _self.unitCode : unitCode // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as QuizQuestionType,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,correctAnswer: null == correctAnswer ? _self.correctAnswer : correctAnswer // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<String>,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as ContentDifficulty,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
