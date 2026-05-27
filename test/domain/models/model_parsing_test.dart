import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/domain/models/hanja_character.dart';
import 'package:hanja_soook/domain/models/learning_result.dart';
import 'package:hanja_soook/domain/models/learning_session.dart';
import 'package:hanja_soook/domain/models/quiz_question.dart';
import 'package:hanja_soook/domain/models/school.dart';

void main() {
  group('domain model JSON parsing', () {
    test('School parses school import fields', () {
      final school = School.fromJson({
        'id': 'school-id',
        'standard_school_code': '1234567',
        'office_code': 'B10',
        'office_name': '서울특별시교육청',
        'school_name': '한빛초등학교',
        'school_name_eng': 'Hanbit Elementary School',
        'school_kind': '초등학교',
        'region_name': '서울특별시',
        'jurisdiction_name': '서울특별시강남서초교육지원청',
        'establishment_type': '공립',
        'road_zip_code': '12345',
        'road_address': '서울특별시 강남구 한빛로 1',
        'road_detail_address': '한빛초등학교',
        'phone_number': '02-000-0000',
        'homepage_url': 'https://example.edu',
        'coeducation_type': '남여공학',
        'fax_number': '02-000-0001',
        'founded_at': '19990301',
        'anniversary_at': '19990301',
        'source_updated_at': '20260331',
        'is_active': true,
        'is_demo': false,
        'created_at': '2026-05-27T00:00:00Z',
        'updated_at': '2026-05-27T00:00:00Z',
      });

      expect(school.standardSchoolCode, '1234567');
      expect(school.schoolName, '한빛초등학교');
      expect(school.regionName, '서울특별시');
      expect(school.toJson()['standard_school_code'], '1234567');
    });

    test('HanjaCharacter parses content fields and defaults', () {
      final hanja = HanjaCharacter.fromJson({
        'id': 'hanja-001',
        'character': '山',
        'sound': '산',
        'meaning': '메 산',
        'stroke_count': 3,
        'grade': 3,
        'unit_code': 'g3-u1',
        'unit_name': '자연',
        'lesson_no': 1,
        'example_sentence': '山이 높아요.',
        'example_meaning': '산이 높아요.',
        'sort_order': 1,
      });

      expect(hanja.character, '山');
      expect(hanja.difficulty, ContentDifficulty.normal);
      expect(hanja.isActive, isTrue);
      expect(hanja.toJson()['stroke_count'], 3);
    });

    test('QuizQuestion parses type, answer and options', () {
      final question = QuizQuestion.fromJson({
        'id': 'quiz-001',
        'hanja_id': 'hanja-001',
        'grade': 3,
        'unit_code': 'g3-u1',
        'type': 'meaning_choice',
        'prompt': '山의 뜻은 무엇인가요?',
        'correct_answer': '메 산',
        'options': ['메 산', '물 수', '큰 대', '작을 소'],
        'explanation': '山은 산을 뜻해요.',
      });

      expect(question.type, QuizQuestionType.meaningChoice);
      expect(question.correctAnswer, '메 산');
      expect(question.options, hasLength(4));
      expect(question.toJson()['type'], 'meaning_choice');
    });

    test('LearningResult parses result summary fields', () {
      final result = LearningResult.fromJson({
        'id': 'result-001',
        'session_id': 'session-001',
        'hanja_id': 'hanja-001',
        'mode': 'quiz',
        'score': 90,
        'accuracy': 90.5,
        'stars': 3,
        'time_sec': 42,
        'earned_xp': 45,
        'coins': 10,
        'correct_count': 9,
        'total_count': 10,
        'completed_at': '2026-05-27T00:00:00Z',
      });

      expect(result.mode, LearningMode.quiz);
      expect(result.accuracy, 90.5);
      expect(result.correctCount, 9);
      expect(result.toJson()['earned_xp'], 45);
    });
  });
}
