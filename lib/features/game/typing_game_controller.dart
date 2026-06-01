import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/challenge_result_repository_provider.dart';
import '../../data/repositories/game_result_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/challenge_result.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/learning_result.dart';
import '../../domain/services/challenge_result_service.dart';
import '../../domain/services/xp_service.dart';
import '../../core/constants/app_constants.dart';
import '../challenge/challenge_result_tick.dart';
import '../challenge/challenge_hanja_pool.dart';
import '../learning/learning_progress_controller.dart';

final typingGameProvider =
    AsyncNotifierProvider.autoDispose<TypingGameController, TypingGameState>(
      TypingGameController.new,
    );

class TypingGameController extends AsyncNotifier<TypingGameState> {
  static const _roundTimeLimitSeconds = 20;
  static const minChoiceHanjaCount = 4;

  DateTime Function() now = DateTime.now;
  Timer? _timer;

  @override
  Future<TypingGameState> build() async {
    final studentKey = currentStudentKey(ref);
    final resultRepository = ref.watch(gameResultRepositoryProvider);
    final learnedItems = await loadLearnedChallengeHanjaPool(
      ref: ref,
      seedOffset: 31,
    );
    final latestResult = await resultRepository.getLatestGameResult(
      studentKey: studentKey,
    );

    _startTimer();
    ref.onDispose(() => _timer?.cancel());

    return TypingGameState(
      rounds: learnedItems.length < TypingGameController.minChoiceHanjaCount
          ? const []
          : _buildRounds(learnedItems),
      startedAt: now(),
      roundStartedAt: now(),
      latestResult: latestResult,
      learnedHanjaCount: learnedItems.length,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state.value;
      if (current == null ||
          !current.canPlay ||
          current.isComplete ||
          current.selectedAnswer != null) {
        return;
      }
      if (current.remainingSeconds <= 1) {
        state = AsyncData(
          current.copyWith(
            selectedAnswer: '',
            wrongCount: current.wrongCount + 1,
            comboCount: 0,
            remainingSeconds: 0,
            timedOut: true,
          ),
        );
        return;
      }
      state = AsyncData(
        current.copyWith(remainingSeconds: current.remainingSeconds - 1),
      );
    });
  }

  void selectAnswer(String answer) {
    final current = state.value;
    if (current == null || current.selectedAnswer != null) {
      return;
    }

    final isCorrect = current.currentRound?.correctAnswer == answer;
    final nextCombo = isCorrect ? current.comboCount + 1 : 0;
    final earnedScore = isCorrect ? _scoreForCorrect(current, nextCombo) : 0;

    state = AsyncData(
      current.copyWith(
        selectedAnswer: answer,
        correctCount: isCorrect
            ? current.correctCount + 1
            : current.correctCount,
        wrongCount: isCorrect ? current.wrongCount : current.wrongCount + 1,
        comboCount: nextCombo,
        bestCombo: nextCombo > current.bestCombo
            ? nextCombo
            : current.bestCombo,
        score: current.score + earnedScore,
        lastEarnedScore: earnedScore,
        timedOut: false,
      ),
    );
  }

  int _scoreForCorrect(TypingGameState current, int nextCombo) {
    final speedBonus = current.remainingSeconds.clamp(
      0,
      current.roundTimeLimit,
    );
    final comboBonus = (nextCombo - 1).clamp(0, current.totalCount) * 2;
    return AppConstants.speedChoiceScorePerQuestion + speedBonus + comboBonus;
  }

  Future<void> goNextOrSave() async {
    final current = state.value;
    if (current == null || current.selectedAnswer == null) {
      return;
    }

    if (!current.isLastRound) {
      state = AsyncData(
        current.copyWith(
          currentIndex: current.currentIndex + 1,
          selectedAnswer: null,
          roundStartedAt: now(),
          remainingSeconds: current.roundTimeLimit,
          lastEarnedScore: 0,
          timedOut: false,
        ),
      );
      return;
    }

    final completedAt = now();
    final timeSec = completedAt.difference(current.startedAt).inSeconds;
    final result = await ref
        .read(gameResultRepositoryProvider)
        .saveGameResult(
          studentKey: currentStudentKey(ref),
          learningDate: currentLearningDate(),
          score: current.score,
          correctCount: current.correctCount,
          totalCount: current.totalCount,
          timeSec: timeSec,
        );
    final challengeResult = await _saveChallengeResult(
      current: current,
      timeSec: timeSec,
    );
    state = AsyncData(
      current.copyWith(
        savedResult: result,
        savedChallengeResult: challengeResult,
      ),
    );
  }

  Future<ChallengeResult> _saveChallengeResult({
    required TypingGameState current,
    required int timeSec,
  }) async {
    const challengeService = ChallengeResultService();
    final studentKey = currentStudentKey(ref);
    final learningDate = currentLearningDate();
    final input = ChallengeResultInput(
      mode: ChallengeMode.speedChoice,
      score: current.score,
      correctCount: current.correctCount,
      totalCount: current.totalCount,
      timeSec: timeSec,
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
    return result;
  }

  List<TypingGameRound> _buildRounds(List<HanjaCharacter> items) {
    final activeItems = items.where((item) => item.isActive).toList();
    return [
      for (var index = 0; index < activeItems.length; index++)
        TypingGameRound(
          hanjaId: activeItems[index].id,
          prompt: activeItems[index].meaning,
          correctAnswer: activeItems[index].character,
          options: _buildOptions(activeItems, index),
        ),
    ];
  }

  List<String> _buildOptions(List<HanjaCharacter> items, int index) {
    final correct = items[index].character;
    final options = items
        .where((item) => item.character != correct)
        .map((item) => item.character)
        .take(3)
        .toList();
    final insertIndex = index % (options.length + 1);
    options.insert(insertIndex, correct);
    return options;
  }
}

class TypingGameRound {
  const TypingGameRound({
    required this.hanjaId,
    required this.prompt,
    required this.correctAnswer,
    required this.options,
  });

  final String hanjaId;
  final String prompt;
  final String correctAnswer;
  final List<String> options;
}

class TypingGameState {
  const TypingGameState({
    required this.rounds,
    required this.startedAt,
    required this.roundStartedAt,
    required this.learnedHanjaCount,
    this.currentIndex = 0,
    this.selectedAnswer,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.comboCount = 0,
    this.bestCombo = 0,
    this.score = 0,
    this.remainingSeconds = TypingGameController._roundTimeLimitSeconds,
    this.lastEarnedScore = 0,
    this.timedOut = false,
    this.latestResult,
    this.savedResult,
    this.savedChallengeResult,
  });

  final List<TypingGameRound> rounds;
  final DateTime startedAt;
  final DateTime roundStartedAt;
  final int learnedHanjaCount;
  final int currentIndex;
  final String? selectedAnswer;
  final int correctCount;
  final int wrongCount;
  final int comboCount;
  final int bestCombo;
  final int score;
  final int remainingSeconds;
  final int lastEarnedScore;
  final bool timedOut;
  final LearningResult? latestResult;
  final LearningResult? savedResult;
  final ChallengeResult? savedChallengeResult;

  int get totalCount => rounds.length;

  int get minLearnedHanjaCount => TypingGameController.minChoiceHanjaCount;

  bool get canPlay => learnedHanjaCount >= minLearnedHanjaCount;

  int get roundTimeLimit => TypingGameController._roundTimeLimitSeconds;

  int get accuracyPercent =>
      totalCount <= 0 ? 0 : ((correctCount / totalCount) * 100).round();

  int get stars {
    if (accuracyPercent >= 90) {
      return 3;
    }
    if (accuracyPercent >= 70) {
      return 2;
    }
    if (accuracyPercent > 0) {
      return 1;
    }
    return 0;
  }

  TypingGameRound? get currentRound {
    if (rounds.isEmpty || currentIndex >= rounds.length) {
      return null;
    }
    return rounds[currentIndex];
  }

  bool get isLastRound => currentIndex == rounds.length - 1;

  bool get isComplete => savedResult != null;

  bool get isSelectedCorrect {
    final round = currentRound;
    return round != null && selectedAnswer == round.correctAnswer;
  }

  bool isCorrectOption(String option) {
    return currentRound?.correctAnswer == option;
  }

  bool isSelectedOption(String option) {
    return selectedAnswer == option;
  }

  TypingGameState copyWith({
    List<TypingGameRound>? rounds,
    DateTime? startedAt,
    DateTime? roundStartedAt,
    int? learnedHanjaCount,
    int? currentIndex,
    Object? selectedAnswer = _sentinel,
    int? correctCount,
    int? wrongCount,
    int? comboCount,
    int? bestCombo,
    int? score,
    int? remainingSeconds,
    int? lastEarnedScore,
    bool? timedOut,
    LearningResult? latestResult,
    LearningResult? savedResult,
    ChallengeResult? savedChallengeResult,
  }) {
    return TypingGameState(
      rounds: rounds ?? this.rounds,
      startedAt: startedAt ?? this.startedAt,
      roundStartedAt: roundStartedAt ?? this.roundStartedAt,
      learnedHanjaCount: learnedHanjaCount ?? this.learnedHanjaCount,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: identical(selectedAnswer, _sentinel)
          ? this.selectedAnswer
          : selectedAnswer as String?,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      comboCount: comboCount ?? this.comboCount,
      bestCombo: bestCombo ?? this.bestCombo,
      score: score ?? this.score,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      lastEarnedScore: lastEarnedScore ?? this.lastEarnedScore,
      timedOut: timedOut ?? this.timedOut,
      latestResult: latestResult ?? this.latestResult,
      savedResult: savedResult ?? this.savedResult,
      savedChallengeResult: savedChallengeResult ?? this.savedChallengeResult,
    );
  }
}

const Object _sentinel = Object();
