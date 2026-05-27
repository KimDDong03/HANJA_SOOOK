// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuizQuestion _$QuizQuestionFromJson(Map<String, dynamic> json) =>
    _QuizQuestion(
      id: json['id'] as String,
      hanjaId: json['hanja_id'] as String?,
      grade: (json['grade'] as num).toInt(),
      unitCode: json['unit_code'] as String?,
      type: $enumDecode(_$QuizQuestionTypeEnumMap, json['type']),
      prompt: json['prompt'] as String,
      correctAnswer: json['correct_answer'] as String,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      explanation: json['explanation'] as String?,
      difficulty:
          $enumDecodeNullable(_$ContentDifficultyEnumMap, json['difficulty']) ??
          ContentDifficulty.normal,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$QuizQuestionToJson(_QuizQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hanja_id': instance.hanjaId,
      'grade': instance.grade,
      'unit_code': instance.unitCode,
      'type': _$QuizQuestionTypeEnumMap[instance.type]!,
      'prompt': instance.prompt,
      'correct_answer': instance.correctAnswer,
      'options': instance.options,
      'explanation': instance.explanation,
      'difficulty': _$ContentDifficultyEnumMap[instance.difficulty]!,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$QuizQuestionTypeEnumMap = {
  QuizQuestionType.soundChoice: 'sound_choice',
  QuizQuestionType.meaningChoice: 'meaning_choice',
  QuizQuestionType.hanjaChoice: 'hanja_choice',
  QuizQuestionType.sentenceBlank: 'sentence_blank',
};

const _$ContentDifficultyEnumMap = {
  ContentDifficulty.easy: 'easy',
  ContentDifficulty.normal: 'normal',
  ContentDifficulty.hard: 'hard',
};
