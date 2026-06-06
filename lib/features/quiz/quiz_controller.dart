import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/challenge_result_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../data/repositories/quiz_result_repository_provider.dart';
import '../../domain/models/challenge_result.dart';
import '../../domain/models/learning_diagnostics.dart';
import '../../domain/models/learning_result.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/quiz_question.dart';
import '../../domain/services/challenge_result_service.dart';
import '../../domain/services/xp_service.dart';
import '../challenge/challenge_result_tick.dart';
import '../challenge/challenge_hanja_pool.dart';
import '../learning/learning_diagnostics_controller.dart';
import '../learning/learning_progress_controller.dart';

final quizProvider = AsyncNotifierProvider.autoDispose
    .family<QuizController, QuizState, QuizPlayMode>(QuizController.new);

enum QuizPlayMode {
  hanjaToHun('hanja-to-hun', '한자 보고 훈음 맞추기'),
  hunToHanja('hun-to-hanja', '훈음 보고 한자 맞추기'),
  mixed('mixed', '혼합');

  const QuizPlayMode(this.routeValue, this.label);

  final String routeValue;
  final String label;

  static QuizPlayMode fromRouteValue(String? value) {
    return switch (value) {
      'hanja-to-sound' ||
      'hanja-to-meaning' ||
      'hanja-to-hun' => QuizPlayMode.hanjaToHun,
      'meaning-to-hanja' || 'hun-to-hanja' => QuizPlayMode.hunToHanja,
      _ => QuizPlayMode.mixed,
    };
  }
}

class QuizController extends AsyncNotifier<QuizState> {
  QuizController(this.mode);

  static const minChoiceHanjaCount = 4;

  final QuizPlayMode mode;
  DateTime Function() now = DateTime.now;

  @override
  Future<QuizState> build() async {
    final studentKey = currentStudentKey(ref);
    final learnedItems = await loadLearnedChallengeHanjaPool(
      ref: ref,
      seedOffset: mode.index + 11,
    );
    final seed = ref.watch(challengeHanjaPoolSeedProvider);
    final questionRandom = seed == null
        ? null
        : Random(seed + 101 + mode.index * 17);
    final questions = learnedItems.length < QuizController.minChoiceHanjaCount
        ? const <QuizQuestion>[]
        : _buildModeQuestions(
            mode: mode,
            items: learnedItems,
            random: questionRandom,
          );
    final latestResult = await ref
        .watch(quizResultRepositoryProvider)
        .getLatestQuizResult(studentKey: studentKey);

    return QuizState(
      mode: mode,
      questions: questions,
      startedAt: now(),
      latestResult: latestResult,
      learnedHanjaCount: learnedItems.length,
    );
  }

  void selectAnswer(String answer) {
    final current = state.value;
    if (current == null || current.selectedAnswer != null) {
      return;
    }

    final isCorrect = current.currentQuestion?.correctAnswer == answer;
    final question = current.currentQuestion;
    if (question?.hanjaId != null) {
      unawaited(
        ref
            .read(learningDiagnosticsControllerProvider)
            .recordAttempt(
              hanjaId: question!.hanjaId!,
              source: HanjaPracticeSource.quiz,
              activityType: _activityTypeFor(question.type),
              result: isCorrect
                  ? HanjaPracticeResult.correct
                  : HanjaPracticeResult.incorrect,
              isLearned: true,
            ),
      );
    }
    state = AsyncData(
      current.copyWith(
        selectedAnswer: answer,
        correctCount: isCorrect
            ? current.correctCount + 1
            : current.correctCount,
      ),
    );
  }

  HanjaPracticeActivityType _activityTypeFor(QuizQuestionType type) {
    return switch (type) {
      QuizQuestionType.hanjaChoice => HanjaPracticeActivityType.hunToHanja,
      QuizQuestionType.soundChoice ||
      QuizQuestionType.meaningChoice => HanjaPracticeActivityType.hanjaToHun,
      QuizQuestionType.sentenceBlank => HanjaPracticeActivityType.mixed,
    };
  }

  Future<void> goNextOrSave() async {
    final current = state.value;
    if (current == null || current.selectedAnswer == null) {
      return;
    }

    if (!current.isLastQuestion) {
      state = AsyncData(
        current.copyWith(
          currentIndex: current.currentIndex + 1,
          selectedAnswer: null,
        ),
      );
      return;
    }

    final completedAt = now();
    final timeSec = completedAt.difference(current.startedAt).inSeconds;
    final result = await ref
        .read(quizResultRepositoryProvider)
        .saveQuizResult(
          studentKey: currentStudentKey(ref),
          learningDate: currentLearningDate(),
          score: current.correctCount,
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
    required QuizState current,
    required int timeSec,
  }) async {
    const challengeService = ChallengeResultService();
    final studentKey = currentStudentKey(ref);
    final learningDate = currentLearningDate();
    final input = ChallengeResultInput(
      mode: _challengeModeFor(current.mode),
      score: current.correctCount,
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

  List<QuizQuestion> _buildModeQuestions({
    required QuizPlayMode mode,
    required List<HanjaCharacter> items,
    required Random? random,
  }) {
    return switch (mode) {
      QuizPlayMode.hanjaToHun => _buildHanjaToHunQuestions(
        items,
        random: random,
      ),
      QuizPlayMode.hunToHanja => _buildHunToHanjaQuestions(
        items,
        random: random,
      ),
      QuizPlayMode.mixed => _buildMixedQuestions(items, random: random),
    };
  }

  List<QuizQuestion> _buildMixedQuestions(
    List<HanjaCharacter> items, {
    required Random? random,
  }) {
    final hanjaToHunQuestions = _buildHanjaToHunQuestions(
      items,
      random: random,
    );
    final hunToHanjaQuestions = _buildHunToHanjaQuestions(
      items,
      random: random,
    );
    final mixed = <QuizQuestion>[];
    if (random != null) {
      mixed
        ..addAll(hanjaToHunQuestions)
        ..addAll(hunToHanjaQuestions)
        ..shuffle(random);
      return mixed.take(10).toList();
    }
    for (var index = 0; index < items.length; index += 1) {
      mixed.add(hanjaToHunQuestions[index]);
      mixed.add(hunToHanjaQuestions[index]);
      if (mixed.length >= 10) {
        break;
      }
    }
    return mixed.take(10).toList();
  }

  List<QuizQuestion> _buildHanjaToHunQuestions(
    List<HanjaCharacter> items, {
    required Random? random,
  }) {
    return [
      for (var index = 0; index < items.length; index += 1)
        QuizQuestion(
          id: 'generated-hanja-to-hun-${items[index].id}',
          hanjaId: items[index].id,
          grade: items[index].grade,
          unitCode: items[index].unitCode,
          type: QuizQuestionType.meaningChoice,
          prompt: items[index].character,
          correctAnswer: _hunAnswer(items[index]),
          options: _buildHunOptions(items, index, random: random),
          explanation:
              '${items[index].character}의 훈음은 ${_hunAnswer(items[index])}입니다.',
          difficulty: items[index].difficulty,
        ),
    ];
  }

  List<QuizQuestion> _buildHunToHanjaQuestions(
    List<HanjaCharacter> items, {
    required Random? random,
  }) {
    return [
      for (var index = 0; index < items.length; index += 1)
        QuizQuestion(
          id: 'generated-hun-to-hanja-${items[index].id}',
          hanjaId: items[index].id,
          grade: items[index].grade,
          unitCode: items[index].unitCode,
          type: QuizQuestionType.hanjaChoice,
          prompt: _hunAnswer(items[index]),
          correctAnswer: items[index].character,
          options: _buildHanjaOptions(items, index, random: random),
          explanation:
              '${items[index].character}의 훈음은 ${_hunAnswer(items[index])}입니다.',
          difficulty: items[index].difficulty,
        ),
    ];
  }

  List<String> _buildHunOptions(
    List<HanjaCharacter> items,
    int index, {
    required Random? random,
  }) {
    return _insertCorrect(
      correct: _hunAnswer(items[index]),
      distractors: items
          .where((item) => item.id != items[index].id)
          .map(_hunAnswer)
          .toList(),
      index: index,
      random: random,
    );
  }

  List<String> _buildHanjaOptions(
    List<HanjaCharacter> items,
    int index, {
    required Random? random,
  }) {
    return _insertCorrect(
      correct: items[index].character,
      distractors: items
          .where((item) => item.id != items[index].id)
          .map((item) => item.character)
          .toList(),
      index: index,
      random: random,
    );
  }

  List<String> _insertCorrect({
    required String correct,
    required List<String> distractors,
    required int index,
    required Random? random,
  }) {
    final uniqueOptions = <String>[
      ...{...distractors.where((option) => option != correct)}.take(3),
    ];
    if (random != null) {
      final options = [correct, ...uniqueOptions]..shuffle(random);
      return options;
    }
    final insertIndex = index % (uniqueOptions.length + 1);
    uniqueOptions.insert(insertIndex, correct);
    return uniqueOptions;
  }

  String _hunAnswer(HanjaCharacter hanja) {
    return hanja.meaning;
  }

  ChallengeMode _challengeModeFor(QuizPlayMode mode) {
    return switch (mode) {
      QuizPlayMode.hanjaToHun => ChallengeMode.quizHanjaToHun,
      QuizPlayMode.hunToHanja => ChallengeMode.quizHunToHanja,
      QuizPlayMode.mixed => ChallengeMode.quizMixed,
    };
  }
}

class QuizState {
  const QuizState({
    required this.mode,
    required this.questions,
    required this.startedAt,
    required this.learnedHanjaCount,
    this.currentIndex = 0,
    this.selectedAnswer,
    this.correctCount = 0,
    this.latestResult,
    this.savedResult,
    this.savedChallengeResult,
  });

  final QuizPlayMode mode;
  final List<QuizQuestion> questions;
  final DateTime startedAt;
  final int learnedHanjaCount;
  final int currentIndex;
  final String? selectedAnswer;
  final int correctCount;
  final LearningResult? latestResult;
  final LearningResult? savedResult;
  final ChallengeResult? savedChallengeResult;

  int get totalCount => questions.length;

  int get minLearnedHanjaCount => QuizController.minChoiceHanjaCount;

  bool get canPlay => learnedHanjaCount >= minLearnedHanjaCount;

  QuizQuestion? get currentQuestion {
    if (questions.isEmpty || currentIndex >= questions.length) {
      return null;
    }
    return questions[currentIndex];
  }

  bool get isLastQuestion => currentIndex == questions.length - 1;

  bool get isComplete => savedResult != null;

  bool get isSelectedCorrect {
    final question = currentQuestion;
    return question != null && selectedAnswer == question.correctAnswer;
  }

  bool isCorrectOption(String option) {
    return currentQuestion?.correctAnswer == option;
  }

  bool isSelectedOption(String option) {
    return selectedAnswer == option;
  }

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

  QuizState copyWith({
    QuizPlayMode? mode,
    List<QuizQuestion>? questions,
    DateTime? startedAt,
    int? learnedHanjaCount,
    int? currentIndex,
    Object? selectedAnswer = _sentinel,
    int? correctCount,
    LearningResult? latestResult,
    LearningResult? savedResult,
    ChallengeResult? savedChallengeResult,
  }) {
    return QuizState(
      mode: mode ?? this.mode,
      questions: questions ?? this.questions,
      startedAt: startedAt ?? this.startedAt,
      learnedHanjaCount: learnedHanjaCount ?? this.learnedHanjaCount,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: identical(selectedAnswer, _sentinel)
          ? this.selectedAnswer
          : selectedAnswer as String?,
      correctCount: correctCount ?? this.correctCount,
      latestResult: latestResult ?? this.latestResult,
      savedResult: savedResult ?? this.savedResult,
      savedChallengeResult: savedChallengeResult ?? this.savedChallengeResult,
    );
  }
}

const Object _sentinel = Object();
