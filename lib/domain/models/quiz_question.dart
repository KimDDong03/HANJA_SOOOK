import 'package:freezed_annotation/freezed_annotation.dart';

import 'hanja_character.dart';

part 'quiz_question.freezed.dart';
part 'quiz_question.g.dart';

@JsonEnum()
enum QuizQuestionType {
  @JsonValue('sound_choice')
  soundChoice,
  @JsonValue('meaning_choice')
  meaningChoice,
  @JsonValue('hanja_choice')
  hanjaChoice,
  @JsonValue('sentence_blank')
  sentenceBlank,
}

@freezed
abstract class QuizQuestion with _$QuizQuestion {
  const factory QuizQuestion({
    required String id,
    @JsonKey(name: 'hanja_id') String? hanjaId,
    required int grade,
    @JsonKey(name: 'unit_code') String? unitCode,
    required QuizQuestionType type,
    required String prompt,
    @JsonKey(name: 'correct_answer') required String correctAnswer,
    @Default(<String>[]) List<String> options,
    String? explanation,
    @Default(ContentDifficulty.normal) ContentDifficulty difficulty,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _QuizQuestion;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);
}
