import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/quiz_result_repository_provider.dart';
import '../../domain/models/learning_result.dart';
import '../../domain/models/quiz_question.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_progress_controller.dart';

final quizProvider = AsyncNotifierProvider<QuizController, QuizState>(
  QuizController.new,
);

class QuizController extends AsyncNotifier<QuizState> {
  DateTime Function() now = DateTime.now;

  @override
  Future<QuizState> build() async {
    final grade = ref.watch(currentProfileProvider)?.grade;
    final studentKey = currentStudentKey(ref);
    final questions = await ref
        .watch(contentRepositoryProvider)
        .getTodayQuizQuestions(grade: grade);
    final latestResult = await ref
        .watch(quizResultRepositoryProvider)
        .getLatestQuizResult(studentKey: studentKey);

    return QuizState(
      questions: questions,
      startedAt: now(),
      latestResult: latestResult,
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
    final result = await ref
        .read(quizResultRepositoryProvider)
        .saveQuizResult(
          studentKey: currentStudentKey(ref),
          learningDate: currentLearningDate(),
          score: current.correctCount,
          correctCount: current.correctCount,
          totalCount: current.totalCount,
          timeSec: completedAt.difference(current.startedAt).inSeconds,
        );
    state = AsyncData(current.copyWith(savedResult: result));
  }
}

class QuizState {
  const QuizState({
    required this.questions,
    required this.startedAt,
    this.currentIndex = 0,
    this.selectedAnswer,
    this.correctCount = 0,
    this.latestResult,
    this.savedResult,
  });

  final List<QuizQuestion> questions;
  final DateTime startedAt;
  final int currentIndex;
  final String? selectedAnswer;
  final int correctCount;
  final LearningResult? latestResult;
  final LearningResult? savedResult;

  int get totalCount => questions.length;

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

  QuizState copyWith({
    List<QuizQuestion>? questions,
    DateTime? startedAt,
    int? currentIndex,
    Object? selectedAnswer = _sentinel,
    int? correctCount,
    LearningResult? latestResult,
    LearningResult? savedResult,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
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
