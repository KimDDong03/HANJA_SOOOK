import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/models/hanja_character.dart';
import '../../domain/models/hanja_example.dart';
import '../../domain/models/quiz_question.dart';
import '../../domain/models/stroke_asset.dart';

class ContentSeedDataSource {
  ContentSeedDataSource({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;

  Future<List<HanjaCharacter>> loadHanjaCharacters() async {
    final rows = await _loadList('assets/data/hanja_seed.example.json');
    return rows
        .map(_normalizeHanja)
        .map(HanjaCharacter.fromJson)
        .where((hanja) => hanja.isActive)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<List<HanjaExample>> loadExamples() async {
    final hanjaList = await loadHanjaCharacters();
    return [
      for (final hanja in hanjaList)
        if (hanja.exampleSentence != null &&
            hanja.exampleSentence!.trim().isNotEmpty)
          HanjaExample(
            id: '${hanja.id}-example-1',
            hanjaId: hanja.id,
            sentence: hanja.exampleSentence!,
            meaning: hanja.exampleMeaning,
            source: 'local_seed',
            difficulty: hanja.difficulty,
            sortOrder: 1,
          ),
    ];
  }

  Future<List<QuizQuestion>> loadQuizQuestions() async {
    final rows = await _loadList('assets/data/quiz_seed.example.json');
    return rows
        .map(_normalizeQuiz)
        .map(QuizQuestion.fromJson)
        .where((question) => question.isActive)
        .toList();
  }

  Future<List<StrokeAsset>> loadStrokeAssets() async {
    final rows = await _loadList('assets/data/stroke_seed.example.json');
    return rows.map(_normalizeStroke).map(StrokeAsset.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> _loadList(String assetPath) async {
    final text = await _assetBundle.loadString(assetPath);
    final decoded = jsonDecode(text);
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Map<String, dynamic> _normalizeHanja(Map<String, dynamic> row) {
    return {
      'id': row['id'],
      'character': row['character'],
      'sound': row['sound'],
      'meaning': row['meaning'],
      'stroke_count': row['stroke_count'] ?? row['strokeCount'],
      'grade': row['grade'],
      'unit_code': row['unit_code'] ?? row['unitCode'],
      'unit_name': row['unit_name'] ?? row['unitName'],
      'lesson_no': row['lesson_no'] ?? row['lessonNo'],
      'difficulty': row['difficulty'],
      'example_sentence': row['example_sentence'] ?? row['exampleSentence'],
      'example_meaning': row['example_meaning'] ?? row['exampleMeaning'],
      'image_asset_id': row['image_asset_id'] ?? row['imageAssetId'],
      'stroke_asset_id': row['stroke_asset_id'] ?? row['strokeAssetId'],
      'sort_order': row['sort_order'] ?? row['sortOrder'],
      'content_version_id':
          row['content_version_id'] ?? row['contentVersionId'],
      'is_active': row['is_active'] ?? row['isActive'],
      'created_at': row['created_at'] ?? row['createdAt'],
      'updated_at': row['updated_at'] ?? row['updatedAt'],
    };
  }

  Map<String, dynamic> _normalizeQuiz(Map<String, dynamic> row) {
    return {
      'id': row['id'],
      'hanja_id': row['hanja_id'] ?? row['hanjaId'],
      'grade': row['grade'],
      'unit_code': row['unit_code'] ?? row['unitCode'],
      'type': row['type'],
      'prompt': row['prompt'],
      'correct_answer': row['correct_answer'] ?? row['correctAnswer'],
      'options': row['options'],
      'explanation': row['explanation'],
      'difficulty': row['difficulty'],
      'is_active': row['is_active'] ?? row['isActive'],
      'created_at': row['created_at'] ?? row['createdAt'],
      'updated_at': row['updated_at'] ?? row['updatedAt'],
    };
  }

  Map<String, dynamic> _normalizeStroke(Map<String, dynamic> row) {
    final hanjaId = row['hanja_id'] ?? row['hanjaId'];
    return {
      'id': row['id'] ?? 'stroke-$hanjaId',
      'hanja_id': hanjaId,
      'character': row['character'],
      'source': row['source'] ?? 'fallback',
      'data_format': row['data_format'] ?? row['dataFormat'] ?? 'manual',
      'storage_path': row['storage_path'] ?? row['storagePath'],
      'stroke_count': row['stroke_count'] ?? row['strokeCount'],
      'median_points': row['median_points'] ?? row['medianPoints'],
      'svg_paths': row['svg_paths'] ?? row['svgPaths'],
      'license_note': row['license_note'] ?? row['licenseNote'],
      'review_status': row['review_status'] ?? row['reviewStatus'],
      'is_active': row['is_active'] ?? row['isActive'] ?? true,
      'created_at': row['created_at'] ?? row['createdAt'],
      'updated_at': row['updated_at'] ?? row['updatedAt'],
    };
  }
}
