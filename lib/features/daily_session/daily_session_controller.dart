import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/stroke_asset.dart';
import '../../domain/services/learning_plan_service.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_progress_controller.dart';

final dailySessionProvider =
    AsyncNotifierProvider.family<
      DailySessionController,
      DailySessionState,
      String?
    >(DailySessionController.new);

enum DailySessionPhase {
  intro,
  guidedWriting,
  hanjaToHunQuiz,
  hunToHanjaQuiz,
  randomWriting,
  mistakeReview,
  complete,
}

enum DailyQuizKind { hanjaToHun, hunToHanja }

class DailySessionController extends AsyncNotifier<DailySessionState> {
  DailySessionController(this.chapterKey);

  final String? chapterKey;

  @override
  Future<DailySessionState> build() async {
    final grade = ref.watch(currentProfileProvider)?.grade;
    final learningDate = currentLearningDate();
    final contentRepository = ref.watch(contentRepositoryProvider);
    final progressRepository = ref.watch(learningProgressRepositoryProvider);
    final allItems = await contentRepository.getHanjaList(grade: grade);
    final progressRecords = await progressRepository
        .getCompletedHanjaRecordsForStudent(studentKey: currentStudentKey(ref));
    final plan = const LearningPlanService().buildDailyPlan(
      allItems: allItems,
      progressRecords: progressRecords,
      learningDate: learningDate,
      newItemLimit: AppConstants.dailyHanjaCount,
      reviewItemLimit: AppConstants.dailyReviewCount,
      chapterKey: chapterKey,
    );
    final items = plan.items;
    final strokeRows = await Future.wait([
      for (final item in items) contentRepository.getStrokeAsset(item.id),
    ]);
    final strokeAssets = <String, StrokeAsset?>{
      for (var index = 0; index < items.length; index += 1)
        items[index].id: strokeRows[index],
    };
    final random = Random(int.tryParse(learningDate) ?? items.length);
    final hanjaToHunQuestions = _buildQuestions(
      kind: DailyQuizKind.hanjaToHun,
      items: items,
      random: random,
    );
    final hunToHanjaQuestions = _buildQuestions(
      kind: DailyQuizKind.hunToHanja,
      items: items,
      random: random,
    );
    final randomWritingItems = [...items]..shuffle(random);

    return DailySessionState(
      items: items,
      strokeAssets: strokeAssets,
      hanjaToHunQuestions: hanjaToHunQuestions,
      hunToHanjaQuestions: hunToHanjaQuestions,
      randomWritingItems: randomWritingItems,
      chapterKey: plan.chapterKey,
      chapterName: plan.chapterName,
    );
  }

  void start() {
    final current = state.value;
    if (current == null || current.items.isEmpty) {
      return;
    }
    state = AsyncData(
      current.copyWith(phase: DailySessionPhase.guidedWriting, index: 0),
    );
  }

  void completeGuidedWriting() {
    final current = state.value;
    if (current == null) {
      return;
    }
    if (current.index < current.items.length - 1) {
      state = AsyncData(current.copyWith(index: current.index + 1));
      return;
    }
    state = AsyncData(
      current.copyWith(
        phase: DailySessionPhase.hanjaToHunQuiz,
        index: 0,
        selectedAnswer: null,
      ),
    );
  }

  void selectQuizAnswer(String answer) {
    final current = state.value;
    final question = current?.currentQuizQuestion;
    if (current == null || question == null || current.selectedAnswer != null) {
      return;
    }
    state = AsyncData(current.answerQuiz(answer));
  }

  void nextQuiz() {
    final current = state.value;
    if (current == null || current.selectedAnswer == null) {
      return;
    }

    if (current.index < current.currentQuizQuestions.length - 1) {
      state = AsyncData(
        current.copyWith(
          index: current.index + 1,
          selectedAnswer: null,
          incorrectAnswer: null,
          currentQuestionHadMistake: false,
        ),
      );
      return;
    }

    if (current.phase == DailySessionPhase.hanjaToHunQuiz) {
      state = AsyncData(
        current.copyWith(
          phase: DailySessionPhase.hunToHanjaQuiz,
          index: 0,
          selectedAnswer: null,
          incorrectAnswer: null,
          currentQuestionHadMistake: false,
        ),
      );
      return;
    }

    state = AsyncData(
      current.copyWith(
        phase: DailySessionPhase.randomWriting,
        index: 0,
        selectedAnswer: null,
        incorrectAnswer: null,
        currentQuestionHadMistake: false,
      ),
    );
  }

  Future<void> completeRandomWriting() async {
    final current = state.value;
    if (current == null) {
      return;
    }
    if (current.index < current.randomWritingItems.length - 1) {
      state = AsyncData(current.copyWith(index: current.index + 1));
      return;
    }
    if (current.missedHanjaIds.isNotEmpty) {
      state = AsyncData(
        current.copyWith(phase: DailySessionPhase.mistakeReview, index: 0),
      );
      return;
    }
    await finish();
  }

  Future<void> finish() async {
    final current = state.value;
    if (current == null || current.isSaving) {
      return;
    }
    state = AsyncData(current.copyWith(isSaving: true));

    var earnedXp = 0;
    LearningCompletionResult? result;
    final todayHanjaIds = current.itemIds;
    for (final item in current.items) {
      result = await ref
          .read(learningProgressControllerProvider)
          .markHanjaCompleted(hanjaId: item.id, todayHanjaIds: todayHanjaIds);
      earnedXp += result.earnedXp;
    }

    state = AsyncData(
      current.copyWith(
        phase: DailySessionPhase.complete,
        isSaving: false,
        earnedXp: earnedXp,
        completionResult: result,
      ),
    );
  }

  List<DailyQuizQuestion> _buildQuestions({
    required DailyQuizKind kind,
    required List<HanjaCharacter> items,
    required Random random,
  }) {
    final shuffledItems = [...items]..shuffle(random);
    return [
      for (final item in shuffledItems)
        DailyQuizQuestion(
          kind: kind,
          item: item,
          prompt: switch (kind) {
            DailyQuizKind.hanjaToHun => item.character,
            DailyQuizKind.hunToHanja => _hunAnswer(item),
          },
          correctAnswer: switch (kind) {
            DailyQuizKind.hanjaToHun => _hunAnswer(item),
            DailyQuizKind.hunToHanja => item.character,
          },
          options: _optionsFor(kind: kind, item: item, items: items),
        ),
    ];
  }

  List<String> _optionsFor({
    required DailyQuizKind kind,
    required HanjaCharacter item,
    required List<HanjaCharacter> items,
  }) {
    final correct = switch (kind) {
      DailyQuizKind.hanjaToHun => _hunAnswer(item),
      DailyQuizKind.hunToHanja => item.character,
    };
    final distractors = items
        .where((other) => other.id != item.id)
        .map(
          (other) => switch (kind) {
            DailyQuizKind.hanjaToHun => _hunAnswer(other),
            DailyQuizKind.hunToHanja => other.character,
          },
        )
        .where((option) => option != correct)
        .toSet()
        .take(3)
        .toList();
    final options = <String>[correct, ...distractors];
    options.shuffle(Random(item.id.hashCode + kind.index));
    return options;
  }

  String _hunAnswer(HanjaCharacter item) => item.meaning;
}

class DailySessionState {
  const DailySessionState({
    required this.items,
    required this.strokeAssets,
    required this.hanjaToHunQuestions,
    required this.hunToHanjaQuestions,
    required this.randomWritingItems,
    this.chapterKey,
    this.chapterName,
    this.phase = DailySessionPhase.intro,
    this.index = 0,
    this.selectedAnswer,
    this.incorrectAnswer,
    this.currentQuestionHadMistake = false,
    this.correctCount = 0,
    this.missedHanjaIds = const <String>{},
    this.isSaving = false,
    this.earnedXp = 0,
    this.completionResult,
  });

  final List<HanjaCharacter> items;
  final Map<String, StrokeAsset?> strokeAssets;
  final List<DailyQuizQuestion> hanjaToHunQuestions;
  final List<DailyQuizQuestion> hunToHanjaQuestions;
  final List<HanjaCharacter> randomWritingItems;
  final String? chapterKey;
  final String? chapterName;
  final DailySessionPhase phase;
  final int index;
  final String? selectedAnswer;
  final String? incorrectAnswer;
  final bool currentQuestionHadMistake;
  final int correctCount;
  final Set<String> missedHanjaIds;
  final bool isSaving;
  final int earnedXp;
  final LearningCompletionResult? completionResult;

  Set<String> get itemIds => items.map((item) => item.id).toSet();

  int get totalQuizCount =>
      hanjaToHunQuestions.length + hunToHanjaQuestions.length;

  double get progress {
    if (items.isEmpty) {
      return 0;
    }
    final completedUnits = switch (phase) {
      DailySessionPhase.intro => 0,
      DailySessionPhase.guidedWriting => index,
      DailySessionPhase.hanjaToHunQuiz => items.length + index,
      DailySessionPhase.hunToHanjaQuiz => items.length * 2 + index,
      DailySessionPhase.randomWriting => items.length * 3 + index,
      DailySessionPhase.mistakeReview => items.length * 4,
      DailySessionPhase.complete => items.length * 4,
    };
    return (completedUnits / (items.length * 4)).clamp(0.0, 1.0);
  }

  HanjaCharacter? get currentHanja {
    final source = switch (phase) {
      DailySessionPhase.guidedWriting => items,
      DailySessionPhase.randomWriting => randomWritingItems,
      _ => items,
    };
    if (source.isEmpty || index >= source.length) {
      return null;
    }
    return source[index];
  }

  List<String> svgPathsFor(String hanjaId) {
    return strokeAssets[hanjaId]?.svgPaths?.whereType<String>().toList() ??
        const [];
  }

  List<DailyQuizQuestion> get currentQuizQuestions {
    return switch (phase) {
      DailySessionPhase.hanjaToHunQuiz => hanjaToHunQuestions,
      DailySessionPhase.hunToHanjaQuiz => hunToHanjaQuestions,
      _ => const [],
    };
  }

  DailyQuizQuestion? get currentQuizQuestion {
    final questions = currentQuizQuestions;
    if (questions.isEmpty || index >= questions.length) {
      return null;
    }
    return questions[index];
  }

  List<HanjaCharacter> get missedItems {
    return items.where((item) => missedHanjaIds.contains(item.id)).toList();
  }

  DailySessionState answerQuiz(String answer) {
    final question = currentQuizQuestion;
    if (question == null || selectedAnswer != null) {
      return this;
    }

    final isCorrect = answer == question.correctAnswer;
    if (!isCorrect) {
      return copyWith(
        incorrectAnswer: answer,
        currentQuestionHadMistake: true,
        missedHanjaIds: {...missedHanjaIds, question.item.id},
      );
    }

    return copyWith(
      selectedAnswer: answer,
      incorrectAnswer: null,
      correctCount: currentQuestionHadMistake ? correctCount : correctCount + 1,
    );
  }

  DailySessionState copyWith({
    DailySessionPhase? phase,
    int? index,
    Object? selectedAnswer = _sentinel,
    Object? incorrectAnswer = _sentinel,
    bool? currentQuestionHadMistake,
    int? correctCount,
    Set<String>? missedHanjaIds,
    bool? isSaving,
    int? earnedXp,
    LearningCompletionResult? completionResult,
  }) {
    return DailySessionState(
      items: items,
      strokeAssets: strokeAssets,
      hanjaToHunQuestions: hanjaToHunQuestions,
      hunToHanjaQuestions: hunToHanjaQuestions,
      randomWritingItems: randomWritingItems,
      chapterKey: chapterKey,
      chapterName: chapterName,
      phase: phase ?? this.phase,
      index: index ?? this.index,
      selectedAnswer: identical(selectedAnswer, _sentinel)
          ? this.selectedAnswer
          : selectedAnswer as String?,
      incorrectAnswer: identical(incorrectAnswer, _sentinel)
          ? this.incorrectAnswer
          : incorrectAnswer as String?,
      currentQuestionHadMistake:
          currentQuestionHadMistake ?? this.currentQuestionHadMistake,
      correctCount: correctCount ?? this.correctCount,
      missedHanjaIds: missedHanjaIds ?? this.missedHanjaIds,
      isSaving: isSaving ?? this.isSaving,
      earnedXp: earnedXp ?? this.earnedXp,
      completionResult: completionResult ?? this.completionResult,
    );
  }
}

class DailyQuizQuestion {
  const DailyQuizQuestion({
    required this.kind,
    required this.item,
    required this.prompt,
    required this.correctAnswer,
    required this.options,
  });

  final DailyQuizKind kind;
  final HanjaCharacter item;
  final String prompt;
  final String correctAnswer;
  final List<String> options;
}

const Object _sentinel = Object();
