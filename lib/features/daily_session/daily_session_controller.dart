import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/stroke_asset.dart';
import '../../domain/services/learning_plan_service.dart';
import '../../domain/services/thinking_unit_image_service.dart';
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
      imageAssetPath: plan.chapterKey == null
          ? null
          : const ThinkingUnitImageService().imageAssetPathForChapterKey(
              plan.chapterKey!,
            ),
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
        guidedWritingCompleted: true,
        phase: DailySessionPhase.hanjaToHunQuiz,
        index: 0,
        selectedAnswer: null,
      ),
    );
  }

  void showGuidedWriting() {
    _moveToPhase(DailySessionPhase.guidedWriting);
  }

  void showQuiz() {
    _moveToPhase(DailySessionPhase.hanjaToHunQuiz);
  }

  void showRandomWriting() {
    _moveToPhase(DailySessionPhase.randomWriting);
  }

  void _moveToPhase(DailySessionPhase phase) {
    final current = state.value;
    if (current == null || current.items.isEmpty) {
      return;
    }
    final targetIndex = _targetIndexForPhase(current: current, phase: phase);
    state = AsyncData(
      current.copyWith(
        phase: phase,
        index: targetIndex,
        selectedAnswer: _selectedAnswerForPhase(
          current: current,
          phase: phase,
          index: targetIndex,
        ),
        incorrectAnswer: null,
        currentQuestionHadMistake: false,
      ),
    );
  }

  void goBackWithinSession() {
    final current = state.value;
    if (current == null) {
      return;
    }

    switch (current.phase) {
      case DailySessionPhase.intro:
      case DailySessionPhase.complete:
        return;
      case DailySessionPhase.guidedWriting:
        if (current.index > 0) {
          state = AsyncData(current.copyWith(index: current.index - 1));
          return;
        }
        state = AsyncData(current.copyWith(phase: DailySessionPhase.intro));
        return;
      case DailySessionPhase.hanjaToHunQuiz:
        if (current.index > 0) {
          final previousIndex = current.index - 1;
          state = AsyncData(
            current.copyWith(
              index: previousIndex,
              selectedAnswer: _selectedAnswerForPhase(
                current: current,
                phase: DailySessionPhase.hanjaToHunQuiz,
                index: previousIndex,
              ),
              incorrectAnswer: null,
              currentQuestionHadMistake: false,
            ),
          );
          return;
        }
        state = AsyncData(
          current.copyWith(
            phase: DailySessionPhase.guidedWriting,
            index: _lastIndexOf(current.items),
            selectedAnswer: null,
            incorrectAnswer: null,
            currentQuestionHadMistake: false,
          ),
        );
        return;
      case DailySessionPhase.hunToHanjaQuiz:
        if (current.index > 0) {
          final previousIndex = current.index - 1;
          state = AsyncData(
            current.copyWith(
              index: previousIndex,
              selectedAnswer: _selectedAnswerForPhase(
                current: current,
                phase: DailySessionPhase.hunToHanjaQuiz,
                index: previousIndex,
              ),
              incorrectAnswer: null,
              currentQuestionHadMistake: false,
            ),
          );
          return;
        }
        state = AsyncData(
          current.copyWith(
            phase: DailySessionPhase.hanjaToHunQuiz,
            index: _lastIndexOf(current.hanjaToHunQuestions),
            selectedAnswer: _selectedAnswerForPhase(
              current: current,
              phase: DailySessionPhase.hanjaToHunQuiz,
              index: _lastIndexOf(current.hanjaToHunQuestions),
            ),
            incorrectAnswer: null,
            currentQuestionHadMistake: false,
          ),
        );
        return;
      case DailySessionPhase.randomWriting:
        if (current.index > 0) {
          state = AsyncData(current.copyWith(index: current.index - 1));
          return;
        }
        state = AsyncData(
          current.copyWith(
            phase: DailySessionPhase.hunToHanjaQuiz,
            index: _lastIndexOf(current.hunToHanjaQuestions),
            selectedAnswer: _selectedAnswerForPhase(
              current: current,
              phase: DailySessionPhase.hunToHanjaQuiz,
              index: _lastIndexOf(current.hunToHanjaQuestions),
            ),
            incorrectAnswer: null,
            currentQuestionHadMistake: false,
          ),
        );
        return;
      case DailySessionPhase.mistakeReview:
        state = AsyncData(
          current.copyWith(
            phase: DailySessionPhase.randomWriting,
            index: _lastIndexOf(current.randomWritingItems),
          ),
        );
        return;
    }
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
      final nextIndex = current.index + 1;
      state = AsyncData(
        current.copyWith(
          index: nextIndex,
          selectedAnswer: _selectedAnswerForPhase(
            current: current,
            phase: current.phase,
            index: nextIndex,
          ),
          incorrectAnswer: null,
          currentQuestionHadMistake: false,
        ),
      );
      return;
    }

    if (current.phase == DailySessionPhase.hanjaToHunQuiz) {
      state = AsyncData(
        current.copyWith(
          hanjaToHunQuizCompleted: true,
          phase: DailySessionPhase.hunToHanjaQuiz,
          index: 0,
          selectedAnswer: _selectedAnswerForPhase(
            current: current,
            phase: DailySessionPhase.hunToHanjaQuiz,
            index: 0,
          ),
          incorrectAnswer: null,
          currentQuestionHadMistake: false,
        ),
      );
      return;
    }

    state = AsyncData(
      current.copyWith(
        hunToHanjaQuizCompleted: true,
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
    final completed = current.copyWith(randomWritingCompleted: true);
    if (current.missedHanjaIds.isNotEmpty) {
      state = AsyncData(
        completed.copyWith(phase: DailySessionPhase.mistakeReview, index: 0),
      );
      return;
    }
    state = AsyncData(completed);
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

int _lastIndexOf(List<dynamic> values) {
  return values.isEmpty ? 0 : values.length - 1;
}

class DailySessionState {
  const DailySessionState({
    required this.items,
    required this.strokeAssets,
    required this.hanjaToHunQuestions,
    required this.hunToHanjaQuestions,
    required this.randomWritingItems,
    this.imageAssetPath,
    this.chapterKey,
    this.chapterName,
    this.phase = DailySessionPhase.intro,
    this.index = 0,
    this.selectedAnswer,
    this.incorrectAnswer,
    this.currentQuestionHadMistake = false,
    this.correctCount = 0,
    this.missedHanjaIds = const <String>{},
    this.guidedWritingCompleted = false,
    this.hanjaToHunQuizCompleted = false,
    this.hunToHanjaQuizCompleted = false,
    this.randomWritingCompleted = false,
    this.isSaving = false,
    this.earnedXp = 0,
    this.completionResult,
  });

  final List<HanjaCharacter> items;
  final Map<String, StrokeAsset?> strokeAssets;
  final List<DailyQuizQuestion> hanjaToHunQuestions;
  final List<DailyQuizQuestion> hunToHanjaQuestions;
  final List<HanjaCharacter> randomWritingItems;
  final String? imageAssetPath;
  final String? chapterKey;
  final String? chapterName;
  final DailySessionPhase phase;
  final int index;
  final String? selectedAnswer;
  final String? incorrectAnswer;
  final bool currentQuestionHadMistake;
  final int correctCount;
  final Set<String> missedHanjaIds;
  final bool guidedWritingCompleted;
  final bool hanjaToHunQuizCompleted;
  final bool hunToHanjaQuizCompleted;
  final bool randomWritingCompleted;
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
    bool? guidedWritingCompleted,
    bool? hanjaToHunQuizCompleted,
    bool? hunToHanjaQuizCompleted,
    bool? randomWritingCompleted,
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
      imageAssetPath: imageAssetPath,
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
      guidedWritingCompleted:
          guidedWritingCompleted ?? this.guidedWritingCompleted,
      hanjaToHunQuizCompleted:
          hanjaToHunQuizCompleted ?? this.hanjaToHunQuizCompleted,
      hunToHanjaQuizCompleted:
          hunToHanjaQuizCompleted ?? this.hunToHanjaQuizCompleted,
      randomWritingCompleted:
          randomWritingCompleted ?? this.randomWritingCompleted,
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

int _targetIndexForPhase({
  required DailySessionState current,
  required DailySessionPhase phase,
}) {
  return switch (phase) {
    DailySessionPhase.guidedWriting when current.guidedWritingCompleted =>
      _lastIndexOf(current.items),
    DailySessionPhase.hanjaToHunQuiz when current.hanjaToHunQuizCompleted =>
      _lastIndexOf(current.hanjaToHunQuestions),
    DailySessionPhase.hunToHanjaQuiz when current.hunToHanjaQuizCompleted =>
      _lastIndexOf(current.hunToHanjaQuestions),
    DailySessionPhase.randomWriting when current.randomWritingCompleted =>
      _lastIndexOf(current.randomWritingItems),
    _ => 0,
  };
}

String? _selectedAnswerForPhase({
  required DailySessionState current,
  required DailySessionPhase phase,
  required int index,
}) {
  final question = switch (phase) {
    DailySessionPhase.hanjaToHunQuiz when current.hanjaToHunQuizCompleted =>
      _questionAt(current.hanjaToHunQuestions, index),
    DailySessionPhase.hunToHanjaQuiz when current.hunToHanjaQuizCompleted =>
      _questionAt(current.hunToHanjaQuestions, index),
    _ => null,
  };
  return question?.correctAnswer;
}

DailyQuizQuestion? _questionAt(List<DailyQuizQuestion> questions, int index) {
  if (index < 0 || index >= questions.length) {
    return null;
  }
  return questions[index];
}
