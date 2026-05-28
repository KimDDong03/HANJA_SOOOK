import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/local/content_seed_data_source.dart';
import 'package:hanja_soook/data/repositories/content_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContentRepositoryImpl', () {
    late ContentRepositoryImpl repository;

    setUp(() {
      repository = ContentRepositoryImpl(
        ContentSeedDataSource(assetBundle: rootBundle),
      );
    });

    test('loads today Hanja from textbook local seed', () async {
      final hanja = await repository.getTodayHanja();

      expect(hanja, isNotNull);
      expect(hanja!.id, 'HJ-0001');
      expect(hanja.character, '一');
      expect(hanja.unitName, '초3 1단원 1. 나라를 세운 역사 인물');
    });

    test('loads today Hanja set from textbook local seed', () async {
      final items = await repository.getTodayHanjaSet(grade: 3);

      expect(items, hasLength(5));
      expect(items.map((hanja) => hanja.id), [
        'HJ-0001',
        'HJ-0002',
        'HJ-0003',
        'HJ-0004',
        'HJ-0005',
      ]);
    });

    test('loads Hanja details and examples by id', () async {
      final hanja = await repository.getHanjaById('HJ-0001');
      final examples = await repository.getExamples('HJ-0001');

      expect(hanja?.meaning, '한 일');
      expect(examples, isEmpty);
    });

    test('loads quiz questions and stroke asset', () async {
      final questions = await repository.getQuizQuestions();
      final strokeAsset = await repository.getStrokeAsset('HJ-0001');

      expect(questions, hasLength(1));
      expect(questions.first.correctAnswer, '一');
      expect(strokeAsset, isNotNull);
      expect(strokeAsset!.reviewStatus.name, 'available');
      expect(strokeAsset.source, 'hanja_demo');
      expect(strokeAsset.svgPaths, hasLength(1));
    });

    test('builds today quiz questions from today Hanja set', () async {
      final questions = await repository.getTodayQuizQuestions(grade: 3);

      expect(questions, hasLength(5));
      expect(questions.map((question) => question.hanjaId), [
        'HJ-0001',
        'HJ-0002',
        'HJ-0003',
        'HJ-0004',
        'HJ-0005',
      ]);
      expect(questions.first.correctAnswer, '一');
      expect(questions.last.options, contains('千'));
    });

    test('returns safe empty states for missing content', () async {
      expect(await repository.getHanjaById('missing'), isNull);
      expect(await repository.getExamples('missing'), isEmpty);
      expect(await repository.getStrokeAsset('missing'), isNull);
    });
  });
}
