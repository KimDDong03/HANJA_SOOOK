import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/challenge_result_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../data/repositories/quiz_result_repository_provider.dart';
import '../../domain/models/challenge_result.dart';
import '../../domain/models/learning_result.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/quiz_question.dart';
import '../../domain/services/challenge_result_service.dart';
import '../../domain/services/xp_service.dart';
import '../challenge/challenge_result_tick.dart';
import '../challenge/challenge_hanja_pool.dart';
import '../learning/learning_progress_controller.dart';

final quizProvider = AsyncNotifierProvider.autoDispose
    .family<QuizController, QuizState, QuizPlayMode>(QuizController.new);

enum QuizPlayMode {
  hanjaToSound('hanja-to-sound', '한자 보고 음'),
  hanjaToMeaning('hanja-to-meaning', '한자 보고 뜻'),
  meaningToHanja('meaning-to-hanja', '뜻 보고 한자'),
  mixed('mixed', '혼합 퀴즈');

  const QuizPlayMode(this.routeValue, this.label);

  final String routeValue;
  final String label;

  static QuizPlayMode fromRouteValue(String? value) {
    return switch (value) {
      'hanja-to-sound' || 'hanja-to-hun' => QuizPlayMode.hanjaToSound,
      'hanja-to-meaning' => QuizPlayMode.hanjaToMeaning,
      'meaning-to-hanja' || 'hun-to-hanja' => QuizPlayMode.meaningToHanja,
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
    final questions = learnedItems.length < QuizController.minChoiceHanjaCount
        ? const <QuizQuestion>[]
        : _buildModeQuestions(mode: mode, items: learnedItems);
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
  }) {
    return switch (mode) {
      QuizPlayMode.hanjaToSound => _buildHanjaToSoundQuestions(items),
      QuizPlayMode.hanjaToMeaning => _buildHanjaToMeaningQuestions(items),
      QuizPlayMode.meaningToHanja => _buildMeaningToHanjaQuestions(items),
      QuizPlayMode.mixed => _buildMixedQuestions(items),
    };
  }

  List<QuizQuestion> _buildMixedQuestions(List<HanjaCharacter> items) {
    final soundQuestions = _buildHanjaToSoundQuestions(items);
    final meaningQuestions = _buildHanjaToMeaningQuestions(items);
    final hanjaQuestions = _buildMeaningToHanjaQuestions(items);
    final mixed = <QuizQuestion>[];
    for (var index = 0; index < items.length; index += 1) {
      mixed.add(soundQuestions[index]);
      mixed.add(meaningQuestions[index]);
      mixed.add(hanjaQuestions[index]);
      if (mixed.length >= 10) {
        break;
      }
    }
    return mixed.take(10).toList();
  }

  List<QuizQuestion> _buildHanjaToSoundQuestions(List<HanjaCharacter> items) {
    return [
      for (var index = 0; index < items.length; index += 1)
        QuizQuestion(
          id: 'generated-hanja-to-sound-${items[index].id}',
          hanjaId: items[index].id,
          grade: items[index].grade,
          unitCode: items[index].unitCode,
          type: QuizQuestionType.soundChoice,
          prompt: items[index].character,
          correctAnswer: _soundAnswer(items[index]),
          options: _buildSoundOptions(items, index),
          explanation:
              '${items[index].character}의 음은 ${items[index].sound}입니다.',
          difficulty: items[index].difficulty,
        ),
    ];
  }

  List<QuizQuestion> _buildHanjaToMeaningQuestions(List<HanjaCharacter> items) {
    return [
      for (var index = 0; index < items.length; index += 1)
        QuizQuestion(
          id: 'generated-hanja-to-meaning-${items[index].id}',
          hanjaId: items[index].id,
          grade: items[index].grade,
          unitCode: items[index].unitCode,
          type: QuizQuestionType.meaningChoice,
          prompt: items[index].character,
          correctAnswer: _meaningAnswer(items[index]),
          options: _buildMeaningOptions(items, index),
          explanation:
              '${items[index].character}의 뜻은 ${items[index].meaning}입니다.',
          difficulty: items[index].difficulty,
        ),
    ];
  }

  List<QuizQuestion> _buildMeaningToHanjaQuestions(List<HanjaCharacter> items) {
    return [
      for (var index = 0; index < items.length; index += 1)
        QuizQuestion(
          id: 'generated-meaning-to-hanja-${items[index].id}',
          hanjaId: items[index].id,
          grade: items[index].grade,
          unitCode: items[index].unitCode,
          type: QuizQuestionType.hanjaChoice,
          prompt: _meaningAnswer(items[index]),
          correctAnswer: items[index].character,
          options: _buildHanjaOptions(items, index),
          explanation: '${items[index].character}은 ${items[index].meaning}입니다.',
          difficulty: items[index].difficulty,
        ),
    ];
  }

  List<String> _buildSoundOptions(List<HanjaCharacter> items, int index) {
    return _insertCorrect(
      correct: _soundAnswer(items[index]),
      distractors: items
          .where((item) => item.id != items[index].id)
          .map(_soundAnswer)
          .toList(),
      index: index,
    );
  }

  List<String> _buildMeaningOptions(List<HanjaCharacter> items, int index) {
    return _insertCorrect(
      correct: _meaningAnswer(items[index]),
      distractors: items
          .where((item) => item.id != items[index].id)
          .map(_meaningAnswer)
          .toList(),
      index: index,
    );
  }

  List<String> _buildHanjaOptions(List<HanjaCharacter> items, int index) {
    return _insertCorrect(
      correct: items[index].character,
      distractors: items
          .where((item) => item.id != items[index].id)
          .map((item) => item.character)
          .toList(),
      index: index,
    );
  }

  List<String> _insertCorrect({
    required String correct,
    required List<String> distractors,
    required int index,
  }) {
    final uniqueOptions = <String>[
      ...{...distractors.where((option) => option != correct)}.take(3),
    ];
    final insertIndex = index % (uniqueOptions.length + 1);
    uniqueOptions.insert(insertIndex, correct);
    return uniqueOptions;
  }

  String _soundAnswer(HanjaCharacter hanja) {
    return hanja.sound;
  }

  String _meaningAnswer(HanjaCharacter hanja) {
    return hanja.meaning;
  }

  ChallengeMode _challengeModeFor(QuizPlayMode mode) {
    return switch (mode) {
      QuizPlayMode.hanjaToSound => ChallengeMode.quizHanjaToHun,
      QuizPlayMode.hanjaToMeaning => ChallengeMode.quizHanjaToHun,
      QuizPlayMode.meaningToHanja => ChallengeMode.quizHunToHanja,
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
