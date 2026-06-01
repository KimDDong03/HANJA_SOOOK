import 'dart:async';
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
import '../../domain/services/xp_service.dart';
import '../challenge/challenge_result_tick.dart';
import '../challenge/challenge_hanja_pool.dart';
import '../learning/learning_progress_controller.dart';
import '../writing/free_writing_score_controller.dart';

final flipBoardProvider = AsyncNotifierProvider.autoDispose
    .family<FlipBoardController, FlipBoardState, FlipBoardPlayMode>(
      FlipBoardController.new,
    );

enum FlipBoardPlayMode {
  drawHanja('draw-hanja', '훈음 보고 한자 그리기'),
  typeMeaning('type-meaning', '한자 보고 뜻 쓰기');

  const FlipBoardPlayMode(this.routeValue, this.label);

  final String routeValue;
  final String label;

  static FlipBoardPlayMode fromRouteValue(String? value) {
    return switch (value) {
      'type-meaning' => FlipBoardPlayMode.typeMeaning,
      _ => FlipBoardPlayMode.drawHanja,
    };
  }
}

class FlipBoardController extends AsyncNotifier<FlipBoardState> {
  FlipBoardController(this.mode);

  static const _drawingMatchMinScore = 65;

  final FlipBoardPlayMode mode;
  DateTime Function() now = DateTime.now;
  Timer? _timer;

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
        tiles: const [],
        remainingTiles: const [],
        learnedHanjaCount: learnedItems.length,
      );
    }
    final allTiles = <FlipBoardTile>[];
    for (final hanja in learnedItems) {
      final strokeAsset = mode == FlipBoardPlayMode.drawHanja
          ? await contentRepository.getStrokeAsset(hanja.id)
          : null;
      allTiles.add(_tileFor(hanja: hanja, strokeAsset: strokeAsset));
    }
    final visibleCount = AppConstants.flipBoardVisibleTileCount.clamp(
      0,
      allTiles.length,
    );
    _startTimer();
    ref.onDispose(() => _timer?.cancel());
    return FlipBoardState(
      startedAt: now(),
      mode: mode,
      tiles: allTiles.take(visibleCount).toList(),
      remainingTiles: allTiles.skip(visibleCount).toList(),
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
  }) {
    return FlipBoardTile(
      hanjaId: hanja.id,
      label: mode == FlipBoardPlayMode.drawHanja
          ? hanja.meaning
          : hanja.character,
      answer: mode == FlipBoardPlayMode.drawHanja
          ? hanja.character
          : hanja.meaning,
      extraAnswers: mode == FlipBoardPlayMode.drawHanja
          ? const []
          : _textAnswersFor(hanja),
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
    if (current.selectedTile == null) {
      state = AsyncData(current.copyWith(feedbackMessage: '뒤집을 판을 먼저 골라주세요.'));
      return;
    }
    if (strokes.isEmpty) {
      return;
    }
    if (current.mode != FlipBoardPlayMode.drawHanja) {
      state = AsyncData(
        current.copyWith(feedbackMessage: '이 모드는 훈음을 적어서 뒤집어요.'),
      );
      return;
    }

    final isMatched = _selectedDrawingMatches(
      current: current,
      strokes: strokes,
    );
    if (isMatched) {
      markTileCorrect(current.selectedTileIndex!);
      return;
    }

    state = AsyncData(current.copyWith(feedbackMessage: '아쉬워요. 다시 그려봐요.'));
  }

  bool _selectedDrawingMatches({
    required FlipBoardState current,
    required List<Path> strokes,
  }) {
    final selectedTile = current.selectedTile;
    if (selectedTile == null) {
      return false;
    }
    final scorer = ref.read(freeWritingScoreControllerProvider);
    final scoreResult = scorer.score(
      userStrokes: strokes,
      expectedSvgPaths: selectedTile.expectedSvgPaths,
      expectedStrokeCount: selectedTile.expectedStrokeCount,
    );
    return scoreResult.score >= _drawingMatchMinScore;
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
      timeSec:
          AppConstants.flipBoardTimeLimitSeconds - current.remainingSeconds,
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

class FlipBoardState {
  const FlipBoardState({
    required this.startedAt,
    required this.mode,
    required this.tiles,
    required this.remainingTiles,
    required this.learnedHanjaCount,
    this.remainingSeconds = AppConstants.flipBoardTimeLimitSeconds,
    this.answerText = '',
    this.flippedTileCount = 0,
    this.correctAttemptCount = 0,
    this.score = 0,
    this.selectedTileIndex,
    this.ownedHanjaIds = const {},
    this.isSaving = false,
    this.completedResult,
    this.feedbackMessage,
  });

  final DateTime startedAt;
  final FlipBoardPlayMode mode;
  final List<FlipBoardTile> tiles;
  final List<FlipBoardTile> remainingTiles;
  final int learnedHanjaCount;
  final int remainingSeconds;
  final String answerText;
  final int flippedTileCount;
  final int correctAttemptCount;
  final int score;
  final int? selectedTileIndex;
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

  FlipBoardState copyWith({
    DateTime? startedAt,
    FlipBoardPlayMode? mode,
    List<FlipBoardTile>? tiles,
    List<FlipBoardTile>? remainingTiles,
    int? learnedHanjaCount,
    int? remainingSeconds,
    String? answerText,
    int? flippedTileCount,
    int? correctAttemptCount,
    int? score,
    Object? selectedTileIndex = _sentinel,
    Set<String>? ownedHanjaIds,
    bool? isSaving,
    ChallengeResult? completedResult,
    Object? feedbackMessage = _sentinel,
  }) {
    return FlipBoardState(
      startedAt: startedAt ?? this.startedAt,
      mode: mode ?? this.mode,
      tiles: tiles ?? this.tiles,
      remainingTiles: remainingTiles ?? this.remainingTiles,
      learnedHanjaCount: learnedHanjaCount ?? this.learnedHanjaCount,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      answerText: answerText ?? this.answerText,
      flippedTileCount: flippedTileCount ?? this.flippedTileCount,
      correctAttemptCount: correctAttemptCount ?? this.correctAttemptCount,
      score: score ?? this.score,
      selectedTileIndex: identical(selectedTileIndex, _sentinel)
          ? this.selectedTileIndex
          : selectedTileIndex as int?,
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
    this.extraAnswers = const [],
    this.expectedStrokeCount,
    this.expectedSvgPaths = const [],
  });

  final String hanjaId;
  final String label;
  final String answer;
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
