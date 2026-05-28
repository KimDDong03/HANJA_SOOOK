import '../../domain/models/hanja_character.dart';
import '../../domain/models/hanja_example.dart';
import '../../domain/models/quiz_question.dart';
import '../../domain/models/stroke_asset.dart';
import '../../domain/repositories/content_repository.dart';
import '../local/content_seed_data_source.dart';

class ContentRepositoryImpl implements ContentRepository {
  const ContentRepositoryImpl(this._seedDataSource);

  final ContentSeedDataSource _seedDataSource;

  @override
  Future<HanjaCharacter?> getTodayHanja({int? grade}) async {
    final items = await getTodayHanjaSet(grade: grade, limit: 1);
    return items.isEmpty ? null : items.first;
  }

  @override
  Future<List<HanjaCharacter>> getTodayHanjaSet({
    int? grade,
    int limit = 5,
  }) async {
    final hanjaList = await _seedDataSource.loadHanjaCharacters();
    final filtered = grade == null
        ? hanjaList
        : hanjaList.where((hanja) => hanja.grade == grade).toList();
    if (filtered.isEmpty) {
      return hanjaList.take(limit).toList();
    }
    return filtered.take(limit).toList();
  }

  @override
  Future<HanjaCharacter?> getHanjaById(String hanjaId) async {
    final normalizedId = hanjaId.trim();
    if (normalizedId.isEmpty) {
      return null;
    }
    final hanjaList = await _seedDataSource.loadHanjaCharacters();
    for (final hanja in hanjaList) {
      if (hanja.id == normalizedId) {
        return hanja;
      }
    }
    return null;
  }

  @override
  Future<List<HanjaExample>> getExamples(String hanjaId) async {
    final normalizedId = hanjaId.trim();
    if (normalizedId.isEmpty) {
      return const [];
    }
    final examples = await _seedDataSource.loadExamples();
    return examples
        .where((example) => example.hanjaId == normalizedId)
        .toList();
  }

  @override
  Future<List<QuizQuestion>> getQuizQuestions({
    int? grade,
    String? unitCode,
    int limit = 10,
  }) async {
    final questions = await _seedDataSource.loadQuizQuestions();
    final filtered = questions
        .where((question) {
          final matchesGrade = grade == null || question.grade == grade;
          final matchesUnit =
              unitCode == null ||
              unitCode.isEmpty ||
              question.unitCode == unitCode;
          return matchesGrade && matchesUnit;
        })
        .take(limit)
        .toList();
    return filtered;
  }

  @override
  Future<List<QuizQuestion>> getTodayQuizQuestions({
    int? grade,
    int limit = 5,
  }) async {
    final todaySet = await getTodayHanjaSet(grade: grade, limit: limit);
    if (todaySet.isEmpty) {
      return const [];
    }

    final seededQuestions = await getQuizQuestions(
      grade: grade,
      unitCode: todaySet.first.unitCode,
      limit: limit,
    );
    final seededHanjaIds = seededQuestions
        .map((question) => question.hanjaId)
        .whereType<String>()
        .toSet();

    final generatedQuestions = <QuizQuestion>[];
    for (final hanja in todaySet) {
      if (seededHanjaIds.contains(hanja.id)) {
        continue;
      }
      generatedQuestions.add(await _buildHanjaChoiceQuestion(hanja));
    }

    return [...seededQuestions, ...generatedQuestions].take(limit).toList();
  }

  @override
  Future<StrokeAsset?> getStrokeAsset(String hanjaId) async {
    final normalizedId = hanjaId.trim();
    if (normalizedId.isEmpty) {
      return null;
    }
    final assets = await _seedDataSource.loadStrokeAssets();
    for (final asset in assets) {
      if (asset.hanjaId == normalizedId && asset.isActive) {
        return asset;
      }
    }
    return null;
  }

  Future<QuizQuestion> _buildHanjaChoiceQuestion(HanjaCharacter hanja) async {
    final hanjaList = await _seedDataSource.loadHanjaCharacters();
    final distractors = hanjaList
        .where((item) => item.id != hanja.id && item.grade == hanja.grade)
        .map((item) => item.character)
        .take(3)
        .toList();
    final options = <String>{hanja.character, ...distractors}.toList();

    return QuizQuestion(
      id: 'generated-${hanja.id}',
      hanjaId: hanja.id,
      grade: hanja.grade,
      unitCode: hanja.unitCode,
      type: QuizQuestionType.hanjaChoice,
      prompt: "'${hanja.meaning}'의 한자를 고르세요.",
      correctAnswer: hanja.character,
      options: options,
      explanation: '${hanja.character}은 ${hanja.meaning}입니다.',
      difficulty: hanja.difficulty,
    );
  }
}
