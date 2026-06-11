import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/challenge_result_repository_provider.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/challenge_result.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/stroke_asset.dart';
import '../../domain/services/challenge_result_service.dart';
import '../../domain/services/free_writing_score_service.dart';
import '../../domain/services/xp_service.dart';
import '../challenge/challenge_result_tick.dart';
import '../challenge/challenge_hanja_pool.dart';
import '../learning/learning_progress_controller.dart';

final flipBoardProvider = AsyncNotifierProvider.autoDispose
    .family<FlipBoardController, FlipBoardState, FlipBoardGameConfig>(
      FlipBoardController.new,
    );

class FlipBoardGameConfig {
  const FlipBoardGameConfig({
    required this.mode,
    this.timeLimitSeconds = AppConstants.flipBoardTimeLimitSeconds,
  });

  final FlipBoardPlayMode mode;
  final int timeLimitSeconds;

  static int timeLimitFromRouteValue(String? value) {
    final seconds = int.tryParse(value ?? '');
    if (AppConstants.flipBoardTimeLimitOptionsSeconds.contains(seconds)) {
      return seconds!;
    }
    return AppConstants.flipBoardTimeLimitSeconds;
  }

  @override
  bool operator ==(Object other) {
    return other is FlipBoardGameConfig &&
        other.mode == mode &&
        other.timeLimitSeconds == timeLimitSeconds;
  }

  @override
  int get hashCode => Object.hash(mode, timeLimitSeconds);
}

enum FlipBoardPlayMode {
  drawHanja('draw-hanja', '솔로 판뒤집기'),
  typeMeaning('type-meaning', '한자 보고 뜻 쓰기'),
  competitiveDrawHanja('competitive-draw-hanja', '경쟁 판뒤집기');

  const FlipBoardPlayMode(this.routeValue, this.label);

  final String routeValue;
  final String label;

  bool get usesDrawing => switch (this) {
    FlipBoardPlayMode.drawHanja ||
    FlipBoardPlayMode.competitiveDrawHanja => true,
    FlipBoardPlayMode.typeMeaning => false,
  };

  bool get isCompetitive => this == FlipBoardPlayMode.competitiveDrawHanja;

  static FlipBoardPlayMode fromRouteValue(String? value) {
    return switch (value) {
      'type-meaning' => FlipBoardPlayMode.typeMeaning,
      'competitive-draw-hanja' => FlipBoardPlayMode.competitiveDrawHanja,
      _ => FlipBoardPlayMode.drawHanja,
    };
  }
}

enum FlipBoardTileOwner { player, opponent }

class FlipBoardController extends AsyncNotifier<FlipBoardState> {
  FlipBoardController(this.config);

  static const _drawingMatchMinScore = 65;
  static const _correctFlashDuration = Duration(milliseconds: 520);

  final FlipBoardGameConfig config;
  DateTime Function() now = DateTime.now;
  Timer? _timer;
  Timer? _replacementTimer;

  FlipBoardPlayMode get mode => config.mode;

  @override
  Future<FlipBoardState> build() async {
    final contentRepository = ref.watch(contentRepositoryProvider);
    final learnedItems = await loadLearnedChallengeHanjaPool(
      ref: ref,
      seedOffset: mode.index,
      maxCount: null,
    );
    if (learnedItems.length < AppConstants.flipBoardMinLearnedHanjaCount) {
      return FlipBoardState(
        startedAt: now(),
        mode: mode,
        timeLimitSeconds: config.timeLimitSeconds,
        remainingSeconds: config.timeLimitSeconds,
        tiles: const [],
        remainingTiles: const [],
        tilePool: const [],
        learnedHanjaCount: learnedItems.length,
      );
    }
    final allTiles = <FlipBoardTile>[];
    for (var index = 0; index < learnedItems.length; index += 1) {
      final hanja = learnedItems[index];
      final strokeAsset = mode.usesDrawing
          ? await contentRepository.getStrokeAsset(hanja.id)
          : null;
      allTiles.add(
        _tileFor(hanja: hanja, strokeAsset: strokeAsset, tileIndex: index),
      );
    }
    final visibleCount = AppConstants.flipBoardVisibleTileCount.clamp(
      0,
      allTiles.length,
    );
    final visibleTiles = allTiles.take(visibleCount).toList();
    _startTimer();
    ref.onDispose(() {
      _timer?.cancel();
      _replacementTimer?.cancel();
    });
    return FlipBoardState(
      startedAt: now(),
      mode: mode,
      timeLimitSeconds: config.timeLimitSeconds,
      remainingSeconds: config.timeLimitSeconds,
      tiles: visibleTiles,
      remainingTiles: allTiles.skip(visibleCount).toList(),
      tilePool: allTiles,
      learnedHanjaCount: learnedItems.length,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state.value;
      if (current == null ||
          current.completedResult != null ||
          current.isSaving ||
          !current.canPlay) {
        return;
      }
      if (current.remainingSeconds <= 1) {
        state = AsyncData(current.copyWith(remainingSeconds: 0));
        unawaited(finishGame());
        return;
      }
      state = AsyncData(
        current.copyWith(remainingSeconds: current.remainingSeconds - 1),
      );
    });
  }

  FlipBoardTile _tileFor({
    required HanjaCharacter hanja,
    required StrokeAsset? strokeAsset,
    required int tileIndex,
  }) {
    return FlipBoardTile(
      hanjaId: hanja.id,
      label: mode.usesDrawing ? hanja.meaning : hanja.character,
      answer: mode.usesDrawing ? hanja.character : hanja.meaning,
      owner: mode.isCompetitive && tileIndex.isOdd
          ? FlipBoardTileOwner.opponent
          : FlipBoardTileOwner.player,
      extraAnswers: mode.usesDrawing ? const [] : _textAnswersFor(hanja),
      expectedStrokeCount: hanja.strokeCount,
      expectedSvgPaths:
          strokeAsset?.svgPaths?.whereType<String>().toList() ?? const [],
    );
  }

  List<String> _textAnswersFor(HanjaCharacter hanja) {
    final meaningParts = hanja.meaning
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    return {hanja.meaning, ...meaningParts}.toList();
  }

  void updateAnswer(String answer) {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(answerText: answer, feedbackMessage: null),
    );
  }

  void selectTile(int index) {
    final current = state.value;
    if (current == null ||
        current.mode.usesDrawing ||
        index < 0 ||
        index >= current.tiles.length ||
        current.isTileOwned(index) ||
        !current.isActive) {
      return;
    }
    state = AsyncData(
      current.copyWith(selectedTileIndex: index, feedbackMessage: null),
    );
  }

  void submitAnswer() {
    final current = state.value;
    if (current == null || !current.isActive) {
      return;
    }
    final selectedTile = current.selectedTile;
    if (selectedTile == null) {
      state = AsyncData(current.copyWith(feedbackMessage: '뒤집을 판을 먼저 골라주세요.'));
      return;
    }
    if (current.answerText.trim().isEmpty) {
      return;
    }
    if (current.mode != FlipBoardPlayMode.typeMeaning) {
      state = AsyncData(
        current.copyWith(feedbackMessage: '이 모드는 한자를 그려서 뒤집어요.'),
      );
      return;
    }

    if (!selectedTile.acceptsText(current.answerText)) {
      state = AsyncData(current.copyWith(feedbackMessage: '아쉬워요. 다시 적어봐요.'));
      return;
    }
    markTileCorrect(current.selectedTileIndex!);
  }

  void submitDrawing({required List<Path> strokes}) {
    final current = state.value;
    if (current == null || !current.isActive) {
      return;
    }
    if (current.correctTileIndex != null) {
      return;
    }
    if (strokes.isEmpty) {
      return;
    }
    if (!current.mode.usesDrawing) {
      state = AsyncData(
        current.copyWith(feedbackMessage: '이 모드는 훈음을 적어서 뒤집어요.'),
      );
      return;
    }

    final matchedTileIndex = _matchedDrawingTileIndex(
      current: current,
      strokes: strokes,
    );
    if (matchedTileIndex == null) {
      state = AsyncData(current.copyWith(feedbackMessage: '아쉬워요. 다시 그려봐요.'));
      return;
    }
    final matchedTile = current.tiles[matchedTileIndex];
    if (current.mode.isCompetitive &&
        matchedTile.owner != FlipBoardTileOwner.player) {
      state = AsyncData(current.copyWith(feedbackMessage: '내 색깔 판만 뒤집어요.'));
      return;
    }
    markTileCorrect(matchedTileIndex);
  }

  int? _matchedDrawingTileIndex({
    required FlipBoardState current,
    required List<Path> strokes,
  }) {
    var bestScore = -1;
    int? bestIndex;
    for (var index = 0; index < current.tiles.length; index += 1) {
      if (current.isTileOwned(index)) {
        continue;
      }
      final tile = current.tiles[index];
      if (current.mode.isCompetitive &&
          tile.owner != FlipBoardTileOwner.player) {
        continue;
      }
      final score = _drawingScore(tile: tile, strokes: strokes);
      if (score > bestScore) {
        bestScore = score;
        bestIndex = index;
      }
    }
    return bestScore >= _drawingMatchMinScore ? bestIndex : null;
  }

  int _drawingScore({
    required FlipBoardTile tile,
    required List<Path> strokes,
  }) {
    final scorer = ref.read(freeWritingScoreServiceProvider);
    return scorer
        .score(
          userStrokes: strokes,
          expectedSvgPaths: tile.expectedSvgPaths,
          expectedStrokeCount: tile.expectedStrokeCount,
        )
        .score;
  }

  void markTileCorrect(int index) {
    final current = state.value;
    if (current == null || index < 0 || index >= current.tiles.length) {
      return;
    }
    final tile = current.tiles[index];
    if (current.ownedHanjaIds.contains(tile.hanjaId)) {
      return;
    }
    if (current.mode.usesDrawing) {
      _markDrawingTileCorrect(current: current, index: index, tile: tile);
      return;
    }

    state = AsyncData(
      current.copyWith(
        score: current.score + _scoreFor(tile),
        correctAttemptCount: current.correctAttemptCount + 1,
        flippedTileCount: current.flippedTileCount + 1,
        ownedHanjaIds: {...current.ownedHanjaIds, tile.hanjaId},
        selectedTileIndex: null,
        answerText: '',
        feedbackMessage: '정답! ${_scoreFor(tile)}점을 얻었어요.',
      ),
    );
  }

  void _markDrawingTileCorrect({
    required FlipBoardState current,
    required int index,
    required FlipBoardTile tile,
  }) {
    _replacementTimer?.cancel();
    final replacement = _takeReplacementTile(
      remainingTiles: current.remainingTiles,
      tilePool: current.tilePool,
      visibleTiles: current.tiles,
      replaceIndex: index,
      owner: current.mode.isCompetitive ? tile.owner : null,
      randomSeed: now().microsecondsSinceEpoch + current.flippedTileCount,
    );
    if (replacement.tile == null) {
      final ownedHanjaIds = {...current.ownedHanjaIds, tile.hanjaId};
      state = AsyncData(
        current.copyWith(
          score: current.score + _scoreFor(tile),
          correctAttemptCount: current.correctAttemptCount + 1,
          flippedTileCount: current.flippedTileCount + 1,
          ownedHanjaIds: ownedHanjaIds,
          selectedTileIndex: null,
          correctTileIndex: index,
          answerText: '',
          feedbackMessage: '정답! ${_scoreFor(tile)}점을 얻었어요.',
        ),
      );
      if (_allPlayableDrawingTilesOwned(state.value!)) {
        unawaited(finishGame());
      }
      return;
    }

    state = AsyncData(
      current.copyWith(
        score: current.score + _scoreFor(tile),
        correctAttemptCount: current.correctAttemptCount + 1,
        flippedTileCount: current.flippedTileCount + 1,
        selectedTileIndex: null,
        correctTileIndex: index,
        answerText: '',
        feedbackMessage: '정답! ${_scoreFor(tile)}점을 얻었어요.',
      ),
    );
    _replacementTimer = Timer(_correctFlashDuration, () {
      final latest = state.value;
      if (latest == null ||
          latest.completedResult != null ||
          index < 0 ||
          index >= latest.tiles.length ||
          latest.tiles[index].hanjaId != tile.hanjaId) {
        return;
      }
      final nextTiles = latest.tiles.toList()..[index] = replacement.tile!;
      state = AsyncData(
        latest.copyWith(
          tiles: nextTiles,
          remainingTiles: replacement.remainingTiles,
          correctTileIndex: null,
        ),
      );
    });
  }

  _TileReplacement _takeReplacementTile({
    required List<FlipBoardTile> remainingTiles,
    required List<FlipBoardTile> tilePool,
    required List<FlipBoardTile> visibleTiles,
    required int replaceIndex,
    required FlipBoardTileOwner? owner,
    required int randomSeed,
  }) {
    if (remainingTiles.isNotEmpty && owner == null) {
      return _TileReplacement(
        tile: remainingTiles.first,
        remainingTiles: remainingTiles.skip(1).toList(),
      );
    }
    for (var index = 0; index < remainingTiles.length; index += 1) {
      final tile = remainingTiles[index];
      if (tile.owner != owner) {
        continue;
      }
      return _TileReplacement(
        tile: tile,
        remainingTiles: [
          ...remainingTiles.take(index),
          ...remainingTiles.skip(index + 1),
        ],
      );
    }
    final replacement = _randomReplacementTile(
      tilePool: tilePool,
      visibleTiles: visibleTiles,
      replaceIndex: replaceIndex,
      owner: owner,
      randomSeed: randomSeed,
    );
    return _TileReplacement(tile: replacement, remainingTiles: remainingTiles);
  }

  FlipBoardTile? _randomReplacementTile({
    required List<FlipBoardTile> tilePool,
    required List<FlipBoardTile> visibleTiles,
    required int replaceIndex,
    required FlipBoardTileOwner? owner,
    required int randomSeed,
  }) {
    if (tilePool.isEmpty) {
      return null;
    }
    final visibleOtherIds = <String>{
      for (var index = 0; index < visibleTiles.length; index += 1)
        if (index != replaceIndex) visibleTiles[index].hanjaId,
    };
    final currentHanjaId =
        replaceIndex >= 0 && replaceIndex < visibleTiles.length
        ? visibleTiles[replaceIndex].hanjaId
        : null;
    var candidates = [
      for (final tile in tilePool)
        if ((owner == null || tile.owner == owner) &&
            !visibleOtherIds.contains(tile.hanjaId))
          tile,
    ];
    if (candidates.length > 1 && currentHanjaId != null) {
      candidates = [
        for (final tile in candidates)
          if (tile.hanjaId != currentHanjaId) tile,
      ];
    }
    if (candidates.isEmpty) {
      candidates = [
        for (final tile in tilePool)
          if (owner == null || tile.owner == owner) tile,
      ];
    }
    if (candidates.isEmpty) {
      return null;
    }
    candidates.shuffle(math.Random(randomSeed));
    return candidates.first;
  }

  bool _allPlayableDrawingTilesOwned(FlipBoardState current) {
    for (var index = 0; index < current.tiles.length; index += 1) {
      final tile = current.tiles[index];
      if (current.mode.isCompetitive &&
          tile.owner != FlipBoardTileOwner.player) {
        continue;
      }
      if (!current.ownedHanjaIds.contains(tile.hanjaId)) {
        return false;
      }
    }
    return true;
  }

  int _scoreFor(FlipBoardTile tile) {
    final strokeCount = tile.expectedStrokeCount ?? 1;
    return 10 + strokeCount.clamp(1, 20);
  }

  Future<void> finishGame() async {
    final current = state.value;
    if (current == null ||
        current.isSaving ||
        current.completedResult != null) {
      return;
    }

    state = AsyncData(current.copyWith(isSaving: true, feedbackMessage: null));
    _timer?.cancel();

    const challengeService = ChallengeResultService();
    final studentKey = currentStudentKey(ref);
    final learningDate = currentLearningDate();
    final input = ChallengeResultInput(
      mode: ChallengeMode.flipBoard,
      score: current.score,
      correctCount: current.correctAttemptCount,
      totalCount: current.learnedHanjaCount,
      timeSec: current.timeLimitSeconds - current.remainingSeconds,
      flippedTileCount: current.flippedTileCount,
    );
    final earnedXp = challengeService.earnedXpFor(input);
    final result = await ref
        .read(challengeResultRepositoryProvider)
        .saveChallengeResult(
          studentKey: studentKey,
          learningDate: learningDate,
          input: input,
          earnedXp: earnedXp,
        );

    if (earnedXp > 0) {
      final wroteXp = await ref
          .read(learningProgressRepositoryProvider)
          .addXpEvent(
            id: challengeService.xpEventId(
              studentKey: studentKey,
              learningDate: learningDate,
              resultId: result.id,
            ),
            studentKey: studentKey,
            source: XpService.challengeResultSource,
            amount: earnedXp,
            refId: result.id,
          );
      if (wroteXp) {
        ref.read(learningProgressTickProvider.notifier).increase();
      }
    }

    ref.read(challengeResultTickProvider.notifier).increase();
    state = AsyncData(
      current.copyWith(
        isSaving: false,
        completedResult: result,
        feedbackMessage: '결과를 저장했어요. XP $earnedXp를 얻었어요.',
      ),
    );
  }
}

class _TileReplacement {
  const _TileReplacement({required this.tile, required this.remainingTiles});

  final FlipBoardTile? tile;
  final List<FlipBoardTile> remainingTiles;
}

class FlipBoardState {
  const FlipBoardState({
    required this.startedAt,
    required this.mode,
    required this.timeLimitSeconds,
    required this.tiles,
    required this.remainingTiles,
    required this.tilePool,
    required this.learnedHanjaCount,
    this.remainingSeconds = AppConstants.flipBoardTimeLimitSeconds,
    this.answerText = '',
    this.flippedTileCount = 0,
    this.correctAttemptCount = 0,
    this.score = 0,
    this.selectedTileIndex,
    this.correctTileIndex,
    this.ownedHanjaIds = const {},
    this.isSaving = false,
    this.completedResult,
    this.feedbackMessage,
  });

  final DateTime startedAt;
  final FlipBoardPlayMode mode;
  final int timeLimitSeconds;
  final List<FlipBoardTile> tiles;
  final List<FlipBoardTile> remainingTiles;
  final List<FlipBoardTile> tilePool;
  final int learnedHanjaCount;
  final int remainingSeconds;
  final String answerText;
  final int flippedTileCount;
  final int correctAttemptCount;
  final int score;
  final int? selectedTileIndex;
  final int? correctTileIndex;
  final Set<String> ownedHanjaIds;
  final bool isSaving;
  final ChallengeResult? completedResult;
  final String? feedbackMessage;

  int get minLearnedHanjaCount => AppConstants.flipBoardMinLearnedHanjaCount;

  bool get canPlay => learnedHanjaCount >= minLearnedHanjaCount;

  bool get isActive =>
      canPlay && remainingSeconds > 0 && completedResult == null && !isSaving;

  FlipBoardTile? get selectedTile {
    final index = selectedTileIndex;
    if (index == null || index < 0 || index >= tiles.length) {
      return null;
    }
    return tiles[index];
  }

  bool isTileOwned(int index) {
    if (index < 0 || index >= tiles.length) {
      return false;
    }
    return ownedHanjaIds.contains(tiles[index].hanjaId);
  }

  bool isTileCorrect(int index) {
    return correctTileIndex == index;
  }

  FlipBoardState copyWith({
    DateTime? startedAt,
    FlipBoardPlayMode? mode,
    int? timeLimitSeconds,
    List<FlipBoardTile>? tiles,
    List<FlipBoardTile>? remainingTiles,
    List<FlipBoardTile>? tilePool,
    int? learnedHanjaCount,
    int? remainingSeconds,
    String? answerText,
    int? flippedTileCount,
    int? correctAttemptCount,
    int? score,
    Object? selectedTileIndex = _sentinel,
    Object? correctTileIndex = _sentinel,
    Set<String>? ownedHanjaIds,
    bool? isSaving,
    ChallengeResult? completedResult,
    Object? feedbackMessage = _sentinel,
  }) {
    return FlipBoardState(
      startedAt: startedAt ?? this.startedAt,
      mode: mode ?? this.mode,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      tiles: tiles ?? this.tiles,
      remainingTiles: remainingTiles ?? this.remainingTiles,
      tilePool: tilePool ?? this.tilePool,
      learnedHanjaCount: learnedHanjaCount ?? this.learnedHanjaCount,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      answerText: answerText ?? this.answerText,
      flippedTileCount: flippedTileCount ?? this.flippedTileCount,
      correctAttemptCount: correctAttemptCount ?? this.correctAttemptCount,
      score: score ?? this.score,
      selectedTileIndex: identical(selectedTileIndex, _sentinel)
          ? this.selectedTileIndex
          : selectedTileIndex as int?,
      correctTileIndex: identical(correctTileIndex, _sentinel)
          ? this.correctTileIndex
          : correctTileIndex as int?,
      ownedHanjaIds: ownedHanjaIds ?? this.ownedHanjaIds,
      isSaving: isSaving ?? this.isSaving,
      completedResult: completedResult ?? this.completedResult,
      feedbackMessage: identical(feedbackMessage, _sentinel)
          ? this.feedbackMessage
          : feedbackMessage as String?,
    );
  }
}

class FlipBoardTile {
  const FlipBoardTile({
    required this.hanjaId,
    required this.label,
    required this.answer,
    this.owner = FlipBoardTileOwner.player,
    this.extraAnswers = const [],
    this.expectedStrokeCount,
    this.expectedSvgPaths = const [],
  });

  final String hanjaId;
  final String label;
  final String answer;
  final FlipBoardTileOwner owner;
  final List<String> extraAnswers;
  final int? expectedStrokeCount;
  final List<String> expectedSvgPaths;

  bool acceptsText(String input) {
    final normalized = _normalizeAnswer(input);
    if (normalized.isEmpty) {
      return false;
    }
    return normalized == _normalizeAnswer(answer) ||
        extraAnswers.any((answer) => _normalizeAnswer(answer) == normalized);
  }
}

const Object _sentinel = Object();

String _normalizeAnswer(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}
