import 'dart:math';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/learning_diagnostics.dart';
import '../../domain/services/learning_plan_service.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_diagnostics_controller.dart';
import '../learning/learning_progress_controller.dart';

final reviewSessionProvider = AsyncNotifierProvider.autoDispose
    .family<ReviewSessionController, ReviewSessionState, String?>(
      ReviewSessionController.new,
    );

enum ReviewSessionPhase {
  hanjaToHun,
  hunToHanja,
  writing,
  correction,
  retry,
  complete,
}

class ReviewSessionController extends AsyncNotifier<ReviewSessionState> {
  ReviewSessionController(this.focusHanjaId);

  final String? focusHanjaId;

  @override
  Future<ReviewSessionState> build() async {
    final grade = ref.watch(currentProfileProvider)?.grade;
    final studentKey = currentStudentKey(ref);
    final learningDate = currentLearningDate();
    final contentRepository = ref.watch(contentRepositoryProvider);
    final progressRepository = ref.watch(learningProgressRepositoryProvider);
    final allItems = await contentRepository.getHanjaList(grade: grade);
    final records = await progressRepository.getCompletedHanjaRecordsForStudent(
      studentKey: studentKey,
    );
    final plan = const LearningPlanService().buildDailyPlan(
      allItems: allItems,
      progressRecords: records,
      learningDate: learningDate,
      newItemLimit: AppConstants.dailyHanjaCount,
      reviewItemLimit: AppConstants.dailyReviewCount,
    );
    final items = _prioritizeFocus(plan.reviewItems, focusHanjaId);
    final random = Random(int.tryParse(learningDate) ?? items.length);
    return ReviewSessionState(
      items: items,
      hanjaToHunQuestions: _buildQuestions(
        activityType: HanjaPracticeActivityType.hanjaToHun,
        items: items,
        random: random,
      ),
      hunToHanjaQuestions: _buildQuestions(
        activityType: HanjaPracticeActivityType.hunToHanja,
        items: items,
        random: random,
      ),
    );
  }

  Future<void> selectAnswer(String answer) async {
    final current = state.value;
    final question = current?.currentQuestion;
    if (current == null || question == null || current.selectedAnswer != null) {
      return;
    }

    final isCorrect = answer == question.correctAnswer;
    await _recordAttempt(
      hanjaId: question.item.id,
      activityType: question.activityType,
      result: isCorrect
          ? HanjaPracticeResult.correct
          : HanjaPracticeResult.incorrect,
    );
    state = AsyncData(
      current.copyWith(
        selectedAnswer: answer,
        correctCount: isCorrect
            ? current.correctCount + 1
            : current.correctCount,
        missedHanjaIds: isCorrect
            ? current.missedHanjaIds
            : {...current.missedHanjaIds, question.item.id},
      ),
    );
  }

  void next() {
    final current = state.value;
    if (current == null || current.selectedAnswer == null) {
      return;
    }
    final questions = current.currentQuestions;
    if (current.index < questions.length - 1) {
      state = AsyncData(
        current.copyWith(index: current.index + 1, selectedAnswer: null),
      );
      return;
    }
    final nextPhase = current.phase == ReviewSessionPhase.hanjaToHun
        ? ReviewSessionPhase.hunToHanja
        : ReviewSessionPhase.writing;
    state = AsyncData(
      current.copyWith(phase: nextPhase, index: 0, selectedAnswer: null),
    );
  }

  Future<void> recordWritingHint() async {
    final current = state.value;
    final item = current?.currentWritingItem;
    if (current == null || item == null) {
      return;
    }
    final nextHintLevel = (current.hintLevelFor(item.id) + 1)
        .clamp(0, 3)
        .toInt();
    await _recordAttempt(
      hanjaId: item.id,
      activityType: HanjaPracticeActivityType.writing,
      result: HanjaPracticeResult.hinted,
      hintLevel: nextHintLevel,
    );
    state = AsyncData(
      current.copyWith(
        hintLevelByHanjaId: {
          ...current.hintLevelByHanjaId,
          item.id: nextHintLevel,
        },
      ),
    );
  }

  void saveWritingStrokes({
    required String hanjaId,
    required List<Path> strokes,
  }) {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        writingStrokesByHanjaId: {
          ...current.writingStrokesByHanjaId,
          hanjaId: List<Path>.unmodifiable(strokes),
        },
      ),
    );
  }

  Future<void> completeWriting() async {
    final current = state.value;
    final item = current?.currentWritingItem;
    if (current == null || item == null) {
      return;
    }
    await _recordAttempt(
      hanjaId: item.id,
      activityType: HanjaPracticeActivityType.writing,
      result: HanjaPracticeResult.correct,
      hintLevel: current.hintLevelFor(item.id),
    );
    if (current.index < current.items.length - 1) {
      state = AsyncData(current.copyWith(index: current.index + 1));
      return;
    }
    state = AsyncData(
      current.copyWith(
        phase: current.missedHanjaIds.isEmpty
            ? ReviewSessionPhase.complete
            : ReviewSessionPhase.correction,
        index: 0,
      ),
    );
    if (current.missedHanjaIds.isEmpty) {
      await _finishReview(current);
    }
  }

  void startRetryOrComplete() {
    final current = state.value;
    if (current == null) {
      return;
    }
    if (current.missedItems.isEmpty) {
      state = AsyncData(current.copyWith(phase: ReviewSessionPhase.complete));
      return;
    }
    state = AsyncData(
      current.copyWith(phase: ReviewSessionPhase.retry, index: 0),
    );
  }

  Future<void> selectRetryAnswer(String answer) async {
    final current = state.value;
    final question = current?.currentRetryQuestion;
    if (current == null || question == null || current.selectedAnswer != null) {
      return;
    }
    final isCorrect = answer == question.correctAnswer;
    await _recordAttempt(
      hanjaId: question.item.id,
      activityType: question.activityType,
      result: isCorrect
          ? HanjaPracticeResult.correct
          : HanjaPracticeResult.incorrect,
    );
    state = AsyncData(
      current.copyWith(
        selectedAnswer: answer,
        retryCorrectHanjaIds: isCorrect
            ? {...current.retryCorrectHanjaIds, question.item.id}
            : current.retryCorrectHanjaIds,
      ),
    );
  }

  Future<void> nextRetryOrFinish() async {
    final current = state.value;
    if (current == null || current.selectedAnswer == null) {
      return;
    }
    if (current.index < current.retryQuestions.length - 1) {
      state = AsyncData(
        current.copyWith(index: current.index + 1, selectedAnswer: null),
      );
      return;
    }
    await _finishReview(current);
    state = AsyncData(
      current.copyWith(
        phase: ReviewSessionPhase.complete,
        selectedAnswer: null,
      ),
    );
  }

  Future<void> _finishReview(ReviewSessionState current) async {
    final repository = ref.read(learningProgressRepositoryProvider);
    final studentKey = currentStudentKey(ref);
    final learningDate = currentLearningDate();
    for (final item in current.items) {
      await repository.markHanjaCompleted(
        studentKey: studentKey,
        learningDate: learningDate,
        hanjaId: item.id,
      );
    }
  }

  Future<void> _recordAttempt({
    required String hanjaId,
    required HanjaPracticeActivityType activityType,
    required HanjaPracticeResult result,
    int? hintLevel,
  }) {
    return ref
        .read(learningDiagnosticsControllerProvider)
        .recordAttempt(
          hanjaId: hanjaId,
          source: HanjaPracticeSource.reviewSession,
          activityType: activityType,
          result: result,
          isLearned: true,
          hintLevel: hintLevel,
        );
  }
}

class ReviewSessionState {
  const ReviewSessionState({
    required this.items,
    required this.hanjaToHunQuestions,
    required this.hunToHanjaQuestions,
    this.phase = ReviewSessionPhase.hanjaToHun,
    this.index = 0,
    this.selectedAnswer,
    this.correctCount = 0,
    this.missedHanjaIds = const <String>{},
    this.retryCorrectHanjaIds = const <String>{},
    this.hintLevelByHanjaId = const <String, int>{},
    this.writingStrokesByHanjaId = const <String, List<Path>>{},
  });

  final List<HanjaCharacter> items;
  final List<ReviewQuestion> hanjaToHunQuestions;
  final List<ReviewQuestion> hunToHanjaQuestions;
  final ReviewSessionPhase phase;
  final int index;
  final String? selectedAnswer;
  final int correctCount;
  final Set<String> missedHanjaIds;
  final Set<String> retryCorrectHanjaIds;
  final Map<String, int> hintLevelByHanjaId;
  final Map<String, List<Path>> writingStrokesByHanjaId;

  List<ReviewQuestion> get currentQuestions {
    return switch (phase) {
      ReviewSessionPhase.hanjaToHun => hanjaToHunQuestions,
      ReviewSessionPhase.hunToHanja => hunToHanjaQuestions,
      _ => const [],
    };
  }

  ReviewQuestion? get currentQuestion {
    final questions = currentQuestions;
    if (index < 0 || index >= questions.length) {
      return null;
    }
    return questions[index];
  }

  List<HanjaCharacter> get missedItems {
    return items.where((item) => missedHanjaIds.contains(item.id)).toList();
  }

  List<ReviewQuestion> get retryQuestions {
    return _buildQuestions(
      activityType: HanjaPracticeActivityType.hunToHanja,
      items: missedItems,
      random: Random(items.length + missedHanjaIds.length),
    );
  }

  ReviewQuestion? get currentRetryQuestion {
    final questions = retryQuestions;
    if (index < 0 || index >= questions.length) {
      return null;
    }
    return questions[index];
  }

  HanjaCharacter? get currentWritingItem {
    if (index < 0 || index >= items.length) {
      return null;
    }
    return items[index];
  }

  int hintLevelFor(String hanjaId) => hintLevelByHanjaId[hanjaId] ?? 0;

  List<Path> writingStrokesFor(String hanjaId) {
    return writingStrokesByHanjaId[hanjaId] ?? const [];
  }

  ReviewSessionState copyWith({
    ReviewSessionPhase? phase,
    int? index,
    Object? selectedAnswer = _sentinel,
    int? correctCount,
    Set<String>? missedHanjaIds,
    Set<String>? retryCorrectHanjaIds,
    Map<String, int>? hintLevelByHanjaId,
    Map<String, List<Path>>? writingStrokesByHanjaId,
  }) {
    return ReviewSessionState(
      items: items,
      hanjaToHunQuestions: hanjaToHunQuestions,
      hunToHanjaQuestions: hunToHanjaQuestions,
      phase: phase ?? this.phase,
      index: index ?? this.index,
      selectedAnswer: identical(selectedAnswer, _sentinel)
          ? this.selectedAnswer
          : selectedAnswer as String?,
      correctCount: correctCount ?? this.correctCount,
      missedHanjaIds: missedHanjaIds ?? this.missedHanjaIds,
      retryCorrectHanjaIds: retryCorrectHanjaIds ?? this.retryCorrectHanjaIds,
      hintLevelByHanjaId: hintLevelByHanjaId ?? this.hintLevelByHanjaId,
      writingStrokesByHanjaId:
          writingStrokesByHanjaId ?? this.writingStrokesByHanjaId,
    );
  }
}

class ReviewQuestion {
  const ReviewQuestion({
    required this.item,
    required this.activityType,
    required this.prompt,
    required this.correctAnswer,
    required this.options,
  });

  final HanjaCharacter item;
  final HanjaPracticeActivityType activityType;
  final String prompt;
  final String correctAnswer;
  final List<String> options;
}

const Object _sentinel = Object();

List<HanjaCharacter> _prioritizeFocus(
  List<HanjaCharacter> items,
  String? focusHanjaId,
) {
  final focus = focusHanjaId?.trim();
  if (focus == null || focus.isEmpty) {
    return items;
  }
  final focused = items.where((item) => item.id == focus).toList();
  if (focused.isEmpty) {
    return items;
  }
  return [...focused, ...items.where((item) => item.id != focus)];
}

List<ReviewQuestion> _buildQuestions({
  required HanjaPracticeActivityType activityType,
  required List<HanjaCharacter> items,
  required Random random,
}) {
  final shuffled = [...items]..shuffle(random);
  return [
    for (var index = 0; index < shuffled.length; index += 1)
      ReviewQuestion(
        item: shuffled[index],
        activityType: activityType,
        prompt: activityType == HanjaPracticeActivityType.hanjaToHun
            ? shuffled[index].character
            : shuffled[index].meaning,
        correctAnswer: activityType == HanjaPracticeActivityType.hanjaToHun
            ? shuffled[index].meaning
            : shuffled[index].character,
        options: activityType == HanjaPracticeActivityType.hanjaToHun
            ? _optionsFor(
                correct: shuffled[index].meaning,
                candidates: items.map((item) => item.meaning),
                index: index,
              )
            : _optionsFor(
                correct: shuffled[index].character,
                candidates: items.map((item) => item.character),
                index: index,
              ),
      ),
  ];
}

List<String> _optionsFor({
  required String correct,
  required Iterable<String> candidates,
  required int index,
}) {
  final options = candidates
      .where((candidate) => candidate != correct)
      .toSet()
      .take(3)
      .toList();
  final insertIndex = options.isEmpty ? 0 : index % (options.length + 1);
  options.insert(insertIndex, correct);
  return options;
}
