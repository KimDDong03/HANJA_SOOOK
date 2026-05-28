import '../models/hanja_character.dart';
import '../models/hanja_example.dart';
import '../models/quiz_question.dart';
import '../models/stroke_asset.dart';

abstract class ContentRepository {
  Future<HanjaCharacter?> getTodayHanja({int? grade});

  Future<List<HanjaCharacter>> getTodayHanjaSet({int? grade, int limit = 5});

  Future<HanjaCharacter?> getHanjaById(String hanjaId);

  Future<List<HanjaExample>> getExamples(String hanjaId);

  Future<List<QuizQuestion>> getQuizQuestions({
    int? grade,
    String? unitCode,
    int limit = 10,
  });

  Future<List<QuizQuestion>> getTodayQuizQuestions({int? grade, int limit = 5});

  Future<StrokeAsset?> getStrokeAsset(String hanjaId);
}
