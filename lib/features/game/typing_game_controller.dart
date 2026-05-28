import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/game_result_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/learning_result.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_progress_controller.dart';

final typingGameProvider =
    AsyncNotifierProvider<TypingGameController, TypingGameState>(
      TypingGameController.new,
    );

class TypingGameController extends AsyncNotifier<TypingGameState> {
  DateTime Function() now = DateTime.now;

  @override
  Future<TypingGameState> build() async {
    final grade = ref.watch(currentProfileProvider)?.grade;
    final studentKey = currentStudentKey(ref);
    final contentRepository = ref.watch(contentRepositoryProvider);
    final resultRepository = ref.watch(gameResultRepositoryProvider);
    final todaySet = await contentRepository.getTodayHanjaSet(
      grade: grade,
      limit: AppConstants.dailyHanjaCount,
    );
    final latestResult = await resultRepository.getLatestGameResult(
      studentKey: studentKey,
    );

    return TypingGameState(
      rounds: _buildRounds(todaySet),
      startedAt: now(),
      latestResult: latestResult,
    );
  }

  void selectAnswer(String answer) {
    final current = state.value;
    if (current == null || current.selectedAnswer != null) {
      return;
    }

    final isCorrect = current.currentRound?.correctAnswer == answer;
    state = AsyncData(
      current.copyWith(
        selectedAnswer: answer,
        correctCount: isCorrect
            ? current.correctCount + 1
            : current.correctCount,
      ),
    );
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
        ),
      );
      return;
    }

    final completedAt = now();
    final result = await ref
        .read(gameResultRepositoryProvider)
        .saveGameResult(
          studentKey: currentStudentKey(ref),
          learningDate: currentLearningDate(),
          score: current.correctCount,
          correctCount: current.correctCount,
          totalCount: current.totalCount,
          timeSec: completedAt.difference(current.startedAt).inSeconds,
        );
    state = AsyncData(current.copyWith(savedResult: result));
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
    this.currentIndex = 0,
    this.selectedAnswer,
    this.correctCount = 0,
    this.latestResult,
    this.savedResult,
  });

  final List<TypingGameRound> rounds;
  final DateTime startedAt;
  final int currentIndex;
  final String? selectedAnswer;
  final int correctCount;
  final LearningResult? latestResult;
  final LearningResult? savedResult;

  int get totalCount => rounds.length;

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

  TypingGameState copyWith({
    List<TypingGameRound>? rounds,
    DateTime? startedAt,
    int? currentIndex,
    Object? selectedAnswer = _sentinel,
    int? correctCount,
    LearningResult? latestResult,
    LearningResult? savedResult,
  }) {
    return TypingGameState(
      rounds: rounds ?? this.rounds,
      startedAt: startedAt ?? this.startedAt,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: identical(selectedAnswer, _sentinel)
          ? this.selectedAnswer
          : selectedAnswer as String?,
      correctCount: correctCount ?? this.correctCount,
      latestResult: latestResult ?? this.latestResult,
      savedResult: savedResult ?? this.savedResult,
    );
  }
}

const Object _sentinel = Object();
