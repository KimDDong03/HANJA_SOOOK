import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/repositories/challenge_result_repository_provider.dart';
import 'package:hanja_soook/data/repositories/content_repository_provider.dart';
import 'package:hanja_soook/data/repositories/learning_progress_repository_provider.dart';
import 'package:hanja_soook/domain/models/challenge_result.dart';
import 'package:hanja_soook/domain/models/hanja_character.dart';
import 'package:hanja_soook/domain/models/hanja_example.dart';
import 'package:hanja_soook/domain/models/learning_progress_record.dart';
import 'package:hanja_soook/domain/models/quiz_question.dart';
import 'package:hanja_soook/domain/models/stroke_asset.dart';
import 'package:hanja_soook/domain/repositories/challenge_result_repository.dart';
import 'package:hanja_soook/domain/repositories/content_repository.dart';
import 'package:hanja_soook/domain/repositories/learning_progress_repository.dart';
import 'package:hanja_soook/features/flip_board/flip_board_controller.dart';

void main() {
  test('draw mode flips the matching tile from drawn Hanja', () async {
    final container = _container();
    addTearDown(container.dispose);

    final provider = flipBoardProvider(FlipBoardPlayMode.drawHanja);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final controller = container.read(provider.notifier);
    await container.read(provider.future);
    expect(container.read(provider).value!.tiles.map((tile) => tile.label), [
      '한 일',
      '두 이',
      '석 삼',
      '넉 사',
      '다섯 오',
      '여섯 육',
    ]);
    controller.submitDrawing(strokes: [_lineStroke()]);

    final state = container.read(provider).value!;
    expect(state.mode, FlipBoardPlayMode.drawHanja);
    expect(state.flippedTileCount, 1);
    expect(state.isTileCorrect(0), isTrue);
    expect(state.isTileOwned(0), isFalse);
    expect(state.tiles[0].label, '한 일');

    await Future<void>.delayed(const Duration(milliseconds: 560));
    final replacedState = container.read(provider).value!;
    expect(replacedState.isTileCorrect(0), isFalse);
    expect(replacedState.isTileOwned(0), isFalse);
    expect(replacedState.tiles[0].label, '일곱 칠');
    expect(replacedState.remainingTiles.length, 5);
    expect(replacedState.score, 11);
    subscription.close();
  });

  test('draw mode matches any visible prompt tile and replaces it', () async {
    final container = _container();
    addTearDown(container.dispose);

    final provider = flipBoardProvider(FlipBoardPlayMode.drawHanja);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final controller = container.read(provider.notifier);
    await container.read(provider.future);
    controller.submitDrawing(
      strokes: [_horizontalStroke(35), _horizontalStroke(70)],
    );

    var state = container.read(provider).value!;
    expect(state.flippedTileCount, 1);
    expect(state.isTileCorrect(1), isTrue);
    expect(state.isTileOwned(1), isFalse);
    expect(state.tiles[1].label, '두 이');
    expect(state.score, 12);
    expect(state.feedbackMessage, '정답! 12점을 얻었어요.');

    await Future<void>.delayed(const Duration(milliseconds: 560));
    state = container.read(provider).value!;
    expect(state.isTileCorrect(1), isFalse);
    expect(state.tiles[0].label, '한 일');
    expect(state.remainingTiles.length, 5);
    expect(state.tiles[1].label, '일곱 칠');
    subscription.close();
  });

  test(
    'competitive draw mode advances only through player owned tiles',
    () async {
      final container = _container();
      addTearDown(container.dispose);

      final provider = flipBoardProvider(
        FlipBoardPlayMode.competitiveDrawHanja,
      );
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      final controller = container.read(provider.notifier);
      await container.read(provider.future);

      var state = container.read(provider).value!;
      expect(state.tiles[0].owner, FlipBoardTileOwner.player);
      expect(state.tiles[1].owner, FlipBoardTileOwner.opponent);

      controller.submitDrawing(strokes: [_lineStroke()]);

      state = container.read(provider).value!;
      expect(state.isTileCorrect(0), isTrue);
      expect(state.isTileOwned(0), isFalse);
      expect(state.isTileOwned(1), isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 560));

      state = container.read(provider).value!;
      expect(state.tiles[0].label, '일곱 칠');
      expect(state.tiles[0].owner, FlipBoardTileOwner.player);
      subscription.close();
    },
  );

  test('type mode flips the matching tile from typed meaning text', () async {
    final container = _container();
    addTearDown(container.dispose);

    final provider = flipBoardProvider(FlipBoardPlayMode.typeMeaning);
    final controller = container.read(provider.notifier);
    await container.read(provider.future);
    controller.selectTile(1);
    controller.updateAnswer('두 이');
    controller.submitAnswer();

    final state = container.read(provider).value!;
    expect(state.mode, FlipBoardPlayMode.typeMeaning);
    expect(state.tiles.first.label, '一');
    expect(state.isTileOwned(1), isTrue);
    expect(state.flippedTileCount, 1);
    expect(state.score, 12);
  });

  test('type mode does not flip an unselected matching tile', () async {
    final container = _container();
    addTearDown(container.dispose);

    final provider = flipBoardProvider(FlipBoardPlayMode.typeMeaning);
    final controller = container.read(provider.notifier);
    await container.read(provider.future);
    controller.selectTile(0);
    controller.updateAnswer('두 이');
    controller.submitAnswer();

    final state = container.read(provider).value!;
    expect(state.flippedTileCount, 0);
    expect(state.isTileOwned(0), isFalse);
    expect(state.feedbackMessage, '아쉬워요. 다시 적어봐요.');
  });

  test('FlipBoardController saves a challenge result', () async {
    final repository = _FakeChallengeResultRepository();
    final container = _container(challengeRepository: repository);
    addTearDown(container.dispose);

    final provider = flipBoardProvider(FlipBoardPlayMode.drawHanja);
    final controller = container.read(provider.notifier);
    await container.read(provider.future);
    controller.selectTile(0);
    controller.submitDrawing(strokes: [_lineStroke()]);
    await controller.finishGame();

    final state = container.read(provider).value!;
    expect(repository.savedInput?.mode, ChallengeMode.flipBoard);
    expect(repository.savedInput?.flippedTileCount, 1);
    expect(state.completedResult?.earnedXp, 25);
  });
}

ProviderContainer _container({ChallengeResultRepository? challengeRepository}) {
  return ProviderContainer(
    overrides: [
      contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
      challengeResultRepositoryProvider.overrideWithValue(
        challengeRepository ?? _FakeChallengeResultRepository(),
      ),
      learningProgressRepositoryProvider.overrideWithValue(
        _FakeLearningProgressRepository(),
      ),
    ],
  );
}

Path _lineStroke() {
  return _horizontalStroke(54.25);
}

Path _horizontalStroke(double y) {
  return Path()
    ..moveTo(11, y)
    ..lineTo(96.88, y);
}

class _FakeContentRepository implements ContentRepository {
  static const _one = HanjaCharacter(
    id: 'HJ-0001',
    character: '一',
    sound: '일',
    meaning: '한 일',
    strokeCount: 1,
    grade: 3,
    isActive: true,
  );
  static const _two = HanjaCharacter(
    id: 'HJ-0002',
    character: '二',
    sound: '이',
    meaning: '두 이',
    strokeCount: 2,
    grade: 3,
    isActive: true,
  );
  static const _three = HanjaCharacter(
    id: 'HJ-0003',
    character: '三',
    sound: '삼',
    meaning: '석 삼',
    strokeCount: 3,
    grade: 3,
    isActive: true,
  );
  static const _four = HanjaCharacter(
    id: 'HJ-0004',
    character: '四',
    sound: '사',
    meaning: '넉 사',
    strokeCount: 5,
    grade: 3,
    isActive: true,
  );
  static const _five = HanjaCharacter(
    id: 'HJ-0005',
    character: '五',
    sound: '오',
    meaning: '다섯 오',
    strokeCount: 4,
    grade: 3,
    isActive: true,
  );
  static const _six = HanjaCharacter(
    id: 'HJ-0006',
    character: '六',
    sound: '육',
    meaning: '여섯 육',
    strokeCount: 4,
    grade: 3,
    isActive: true,
  );
  static const _seven = HanjaCharacter(
    id: 'HJ-0007',
    character: '七',
    sound: '칠',
    meaning: '일곱 칠',
    strokeCount: 2,
    grade: 3,
    isActive: true,
  );
  static const _eight = HanjaCharacter(
    id: 'HJ-0008',
    character: '八',
    sound: '팔',
    meaning: '여덟 팔',
    strokeCount: 2,
    grade: 3,
    isActive: true,
  );
  static const _nine = HanjaCharacter(
    id: 'HJ-0009',
    character: '九',
    sound: '구',
    meaning: '아홉 구',
    strokeCount: 2,
    grade: 3,
    isActive: true,
  );
  static const _ten = HanjaCharacter(
    id: 'HJ-0010',
    character: '十',
    sound: '십',
    meaning: '열 십',
    strokeCount: 2,
    grade: 3,
    isActive: true,
  );
  static const _hundred = HanjaCharacter(
    id: 'HJ-0011',
    character: '百',
    sound: '백',
    meaning: '일백 백',
    strokeCount: 6,
    grade: 3,
    isActive: true,
  );
  static const _thousand = HanjaCharacter(
    id: 'HJ-0012',
    character: '千',
    sound: '천',
    meaning: '일천 천',
    strokeCount: 3,
    grade: 3,
    isActive: true,
  );

  static const _items = [
    _one,
    _two,
    _three,
    _four,
    _five,
    _six,
    _seven,
    _eight,
    _nine,
    _ten,
    _hundred,
    _thousand,
  ];

  @override
  Future<List<HanjaCharacter>> getTodayHanjaSet({
    int? grade,
    int limit = 4,
  }) async {
    return _items.take(limit).toList();
  }

  @override
  Future<List<HanjaCharacter>> getHanjaList({int? grade, int? limit}) async {
    return limit == null ? _items : _items.take(limit).toList();
  }

  @override
  Future<StrokeAsset?> getStrokeAsset(String hanjaId) async {
    return switch (hanjaId) {
      'HJ-0002' => const StrokeAsset(
        hanjaId: 'HJ-0002',
        character: '二',
        strokeCount: 2,
        svgPaths: ['M11,35 L96.88,35', 'M11,70 L96.88,70'],
        reviewStatus: StrokeReviewStatus.available,
      ),
      'HJ-0003' => const StrokeAsset(
        hanjaId: 'HJ-0003',
        character: '三',
        strokeCount: 3,
        svgPaths: ['M11,25 L96.88,25', 'M11,54 L96.88,54', 'M11,84 L96.88,84'],
        reviewStatus: StrokeReviewStatus.available,
      ),
      'HJ-0004' => const StrokeAsset(
        hanjaId: 'HJ-0004',
        character: '四',
        strokeCount: 5,
        svgPaths: ['M25,11 L25,96.88'],
        reviewStatus: StrokeReviewStatus.available,
      ),
      'HJ-0005' => const StrokeAsset(
        hanjaId: 'HJ-0005',
        character: '五',
        strokeCount: 4,
        svgPaths: ['M11,11 L96.88,96.88'],
        reviewStatus: StrokeReviewStatus.available,
      ),
      'HJ-0006' => const StrokeAsset(
        hanjaId: 'HJ-0006',
        character: '六',
        strokeCount: 4,
        svgPaths: ['M96.88,11 L11,96.88'],
        reviewStatus: StrokeReviewStatus.available,
      ),
      _ => const StrokeAsset(
        hanjaId: 'HJ-0001',
        character: '一',
        strokeCount: 1,
        svgPaths: ['M11,54.25 L96.88,54.25'],
        reviewStatus: StrokeReviewStatus.available,
      ),
    };
  }

  @override
  Future<List<HanjaExample>> getExamples(String hanjaId) async => const [];

  @override
  Future<HanjaCharacter?> getHanjaById(String hanjaId) async {
    for (final hanja in _items) {
      if (hanja.id == hanjaId) {
        return hanja;
      }
    }
    return null;
  }

  @override
  Future<List<QuizQuestion>> getQuizQuestions({
    int? grade,
    String? unitCode,
    int limit = 10,
  }) async {
    return const [];
  }

  @override
  Future<HanjaCharacter?> getTodayHanja({int? grade}) async => _one;

  @override
  Future<List<QuizQuestion>> getTodayQuizQuestions({
    int? grade,
    int limit = 4,
  }) async {
    return const [];
  }
}

class _FakeChallengeResultRepository implements ChallengeResultRepository {
  ChallengeResultInput? savedInput;

  @override
  Future<ChallengeResult> saveChallengeResult({
    required String studentKey,
    required String learningDate,
    required ChallengeResultInput input,
    required int earnedXp,
  }) async {
    savedInput = input;
    return ChallengeResult(
      id: 'challenge-result-1',
      studentKey: studentKey,
      learningDate: learningDate,
      mode: input.mode,
      score: input.score,
      correctCount: input.correctCount,
      totalCount: input.totalCount,
      timeSec: input.timeSec,
      flippedTileCount: input.flippedTileCount,
      earnedXp: earnedXp,
      completedAt: DateTime(2026, 5, 30),
    );
  }

  @override
  Future<List<ChallengeResult>> getChallengeResults({
    Set<String>? studentKeys,
    String? learningDate,
  }) async {
    return const [];
  }

  @override
  Future<ChallengeResult?> getChallengeResultById(String id) async {
    return null;
  }

  @override
  Future<ChallengeResult?> getLatestChallengeResult({
    required String studentKey,
    ChallengeMode? mode,
  }) async {
    return null;
  }
}

class _FakeLearningProgressRepository implements LearningProgressRepository {
  @override
  Future<bool> addXpEvent({
    required String id,
    required String studentKey,
    required String source,
    required int amount,
    String? refId,
  }) async {
    return true;
  }

  @override
  Future<Set<String>> getCompletedHanjaIds({
    required String studentKey,
    required String learningDate,
  }) async {
    return _FakeContentRepository._items.map((hanja) => hanja.id).toSet();
  }

  @override
  Future<Set<String>> getCompletedHanjaIdsForStudent({
    required String studentKey,
  }) async {
    return _FakeContentRepository._items.map((hanja) => hanja.id).toSet();
  }

  @override
  Future<List<LearningProgressRecord>> getCompletedHanjaRecordsForStudent({
    required String studentKey,
  }) async {
    return const [];
  }

  @override
  Future<int> getTotalXp({required String studentKey}) async => 0;

  @override
  Future<int> getXpForRef({
    required String studentKey,
    required String source,
    required String refId,
  }) async {
    return 0;
  }

  @override
  Future<bool> markHanjaCompleted({
    required String studentKey,
    required String learningDate,
    required String hanjaId,
  }) async {
    return true;
  }
}
