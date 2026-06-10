import 'dart:math';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_diagnostics_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/learning_diagnostics.dart';
import '../../domain/models/stroke_asset.dart';
import '../../domain/services/learning_plan_service.dart';
import '../../domain/services/xp_service.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_diagnostics_controller.dart';
import '../learning/learning_progress_controller.dart';

final reviewSessionProvider =
    AsyncNotifierProvider.family<
      ReviewSessionController,
      ReviewSessionState,
      String?
    >(ReviewSessionController.new);

enum ReviewSessionPhase { quiz, writing, correction, retry, complete }

const int _inlineRetryDistance = 3;
const int _maxInlineRetryCount = 2;
const int _maxFinalRetryRound = 1;

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
    final activeWeaknesses = await ref
        .watch(learningDiagnosticsRepositoryProvider)
        .getActiveWeaknesses(studentKey: studentKey);
    final weaknessesByHanja = _weaknessesByHanja(activeWeaknesses);
    final items = _sessionItems(
      allItems: allItems,
      dueItems: plan.reviewItems,
      focusHanjaId: focusHanjaId,
      limit: AppConstants.dailyReviewCount,
    );
    final strokeRows = await Future.wait([
      for (final item in items) contentRepository.getStrokeAsset(item.id),
    ]);
    final strokeAssets = <String, StrokeAsset?>{
      for (var index = 0; index < items.length; index += 1)
        items[index].id: strokeRows[index],
    };
    final random = Random(int.tryParse(learningDate) ?? items.length);
    return ReviewSessionState(
      items: items,
      strokeAssets: strokeAssets,
      weaknessesByHanja: weaknessesByHanja,
      quizQuestions: _buildReviewQuestions(
        items: items,
        weaknessesByHanja: weaknessesByHanja,
        random: random,
        focusHanjaId: focusHanjaId,
      ),
      weakWritingHanjaIds: _weakWritingHanjaIds(weaknessesByHanja),
    );
  }

  Future<void> selectAnswer(String answer) async {
    final current = state.value;
    final question = current?.currentQuestion;
    if (current == null || question == null || current.selectedAnswer != null) {
      return;
    }

    final isCorrect = answer == question.correctAnswer;
    final quizQuestions = isCorrect
        ? current.quizQuestions
        : _quizQuestionsWithRetry(
            questions: current.quizQuestions,
            currentIndex: current.index,
            failedQuestion: question,
            candidates: current.items,
          );
    await _recordAttempt(
      hanjaId: question.item.id,
      activityType: question.activityType,
      result: isCorrect
          ? HanjaPracticeResult.correct
          : HanjaPracticeResult.incorrect,
    );
    state = AsyncData(
      current.copyWith(
        quizQuestions: quizQuestions,
        selectedAnswer: answer,
        correctCount:
            isCorrect &&
                question.retryCount == 0 &&
                !current.missedHanjaIds.contains(question.item.id)
            ? current.correctCount + 1
            : current.correctCount,
        passedHanjaIds: isCorrect
            ? {...current.passedHanjaIds, question.item.id}
            : current.passedHanjaIds,
        missedHanjaIds: isCorrect
            ? current.missedHanjaIds
            : {...current.missedHanjaIds, question.item.id},
      ),
    );
  }

  Future<void> next() async {
    final current = state.value;
    if (current == null || current.selectedAnswer == null) {
      return;
    }
    final questions = current.quizQuestions;
    if (current.index < questions.length - 1) {
      state = AsyncData(
        current.copyWith(index: current.index + 1, selectedAnswer: null),
      );
      return;
    }
    if (current.writingItems.isNotEmpty) {
      state = AsyncData(
        current.copyWith(
          phase: ReviewSessionPhase.writing,
          index: 0,
          selectedAnswer: null,
        ),
      );
      return;
    }
    if (current.unresolvedMissedItems.isNotEmpty) {
      state = AsyncData(
        current.copyWith(
          phase: ReviewSessionPhase.correction,
          index: 0,
          selectedAnswer: null,
        ),
      );
      return;
    }
    final earnedXp = await _finishReview(current);
    state = AsyncData(
      current.copyWith(
        phase: ReviewSessionPhase.complete,
        index: 0,
        selectedAnswer: null,
        earnedXp: earnedXp,
      ),
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
        hintedHanjaIds: {...current.hintedHanjaIds, item.id},
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
        writingPassedHanjaIds: {...current.writingPassedHanjaIds}
          ..remove(hanjaId),
        writingStrokesByHanjaId: {
          ...current.writingStrokesByHanjaId,
          hanjaId: List<Path>.unmodifiable(strokes),
        },
      ),
    );
  }

  void markWritingPassed(String hanjaId) {
    final current = state.value;
    final item = current?.currentWritingItem;
    if (current == null || item == null || item.id != hanjaId) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        writingPassedHanjaIds: {...current.writingPassedHanjaIds, hanjaId},
      ),
    );
  }

  Future<void> recordWritingFailure() async {
    final current = state.value;
    final item = current?.currentWritingItem;
    if (current == null || item == null) {
      return;
    }
    await _recordAttempt(
      hanjaId: item.id,
      activityType: HanjaPracticeActivityType.writing,
      result: HanjaPracticeResult.failed,
      hintLevel: current.hintLevelFor(item.id),
    );
    state = AsyncData(
      current.copyWith(missedHanjaIds: {...current.missedHanjaIds, item.id}),
    );
  }

  Future<void> completeWriting() async {
    final current = state.value;
    final item = current?.currentWritingItem;
    if (current == null || item == null) {
      return;
    }
    if (!current.writingPassedHanjaIds.contains(item.id)) {
      return;
    }
    await _recordAttempt(
      hanjaId: item.id,
      activityType: HanjaPracticeActivityType.writing,
      result: HanjaPracticeResult.correct,
      hintLevel: current.hintLevelFor(item.id),
    );
    final updated = current.copyWith(
      passedHanjaIds: {...current.passedHanjaIds, item.id},
    );
    if (updated.index < updated.writingItems.length - 1) {
      state = AsyncData(updated.copyWith(index: updated.index + 1));
      return;
    }
    if (updated.unresolvedMissedItems.isNotEmpty) {
      state = AsyncData(
        updated.copyWith(phase: ReviewSessionPhase.correction, index: 0),
      );
      return;
    }
    final earnedXp = await _finishReview(updated);
    state = AsyncData(
      updated.copyWith(
        phase: ReviewSessionPhase.complete,
        index: 0,
        earnedXp: earnedXp,
      ),
    );
  }

  Future<void> startRetryOrComplete() async {
    final current = state.value;
    if (current == null) {
      return;
    }
    if (current.unresolvedMissedItems.isEmpty) {
      final earnedXp = await _finishReview(current);
      state = AsyncData(
        current.copyWith(
          phase: ReviewSessionPhase.complete,
          earnedXp: earnedXp,
        ),
      );
      return;
    }
    state = AsyncData(
      current.copyWith(
        phase: ReviewSessionPhase.retry,
        index: 0,
        selectedAnswer: null,
        retryRound: 0,
      ),
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
        passedHanjaIds: isCorrect
            ? {...current.passedHanjaIds, question.item.id}
            : current.passedHanjaIds,
        missedHanjaIds: isCorrect
            ? current.missedHanjaIds
            : {...current.missedHanjaIds, question.item.id},
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
    final nextState = current.copyWith(selectedAnswer: null);
    if (nextState.unresolvedMissedItems.isNotEmpty &&
        current.retryRound < _maxFinalRetryRound) {
      state = AsyncData(
        nextState.copyWith(index: 0, retryRound: current.retryRound + 1),
      );
      return;
    }
    final earnedXp = await _finishReview(current);
    state = AsyncData(
      current.copyWith(
        phase: ReviewSessionPhase.complete,
        selectedAnswer: null,
        earnedXp: earnedXp,
      ),
    );
  }

  Future<int> _finishReview(ReviewSessionState current) async {
    final repository = ref.read(learningProgressRepositoryProvider);
    final studentKey = currentStudentKey(ref);
    final learningDate = currentLearningDate();
    var didChangeProgress = false;
    for (final item in current.items) {
      final didMark = await repository.markHanjaCompleted(
        studentKey: studentKey,
        learningDate: learningDate,
        hanjaId: item.id,
      );
      didChangeProgress = didChangeProgress || didMark;
    }
    const xpService = XpService();
    final earnedXp = xpService.reviewSessionCompletionXp(
      reviewedCount: current.items.length,
      firstTryCorrectCount: current.correctCount,
    );
    var didWriteXp = false;
    if (earnedXp > 0) {
      didWriteXp = await repository.addXpEvent(
        id: xpService.reviewSessionXpEventId(
          studentKey: studentKey,
          learningDate: learningDate,
          focusHanjaId: focusHanjaId,
        ),
        studentKey: studentKey,
        source: XpService.reviewSessionSource,
        amount: earnedXp,
        refId: focusHanjaId?.trim().isEmpty ?? true
            ? learningDate
            : focusHanjaId!.trim(),
      );
    }
    if (didChangeProgress || didWriteXp) {
      ref.read(learningProgressTickProvider.notifier).increase();
    }
    return didWriteXp ? earnedXp : 0;
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
    required this.strokeAssets,
    required this.weaknessesByHanja,
    required this.quizQuestions,
    required this.weakWritingHanjaIds,
    this.phase = ReviewSessionPhase.quiz,
    this.index = 0,
    this.selectedAnswer,
    this.correctCount = 0,
    this.passedHanjaIds = const <String>{},
    this.missedHanjaIds = const <String>{},
    this.hintedHanjaIds = const <String>{},
    this.retryCorrectHanjaIds = const <String>{},
    this.writingPassedHanjaIds = const <String>{},
    this.retryRound = 0,
    this.hintLevelByHanjaId = const <String, int>{},
    this.writingStrokesByHanjaId = const <String, List<Path>>{},
    this.earnedXp = 0,
  });

  final List<HanjaCharacter> items;
  final Map<String, StrokeAsset?> strokeAssets;
  final Map<String, List<HanjaWeaknessRecord>> weaknessesByHanja;
  final List<ReviewQuestion> quizQuestions;
  final Set<String> weakWritingHanjaIds;
  final ReviewSessionPhase phase;
  final int index;
  final String? selectedAnswer;
  final int correctCount;
  final Set<String> passedHanjaIds;
  final Set<String> missedHanjaIds;
  final Set<String> hintedHanjaIds;
  final Set<String> retryCorrectHanjaIds;
  final Set<String> writingPassedHanjaIds;
  final int retryRound;
  final Map<String, int> hintLevelByHanjaId;
  final Map<String, List<Path>> writingStrokesByHanjaId;
  final int earnedXp;

  ReviewQuestion? get currentQuestion {
    if (phase != ReviewSessionPhase.quiz ||
        index < 0 ||
        index >= quizQuestions.length) {
      return null;
    }
    return quizQuestions[index];
  }

  List<HanjaCharacter> get missedItems {
    return items.where((item) => missedHanjaIds.contains(item.id)).toList();
  }

  List<HanjaCharacter> get unresolvedMissedItems {
    return items.where((item) {
      return missedHanjaIds.contains(item.id) &&
          !passedHanjaIds.contains(item.id);
    }).toList();
  }

  List<HanjaCharacter> get writingItems {
    return items;
  }

  List<ReviewQuestion> get retryQuestions {
    return _buildRetryQuestions(
      items: unresolvedMissedItems,
      candidates: items,
      retryRound: retryRound,
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
    final targets = writingItems;
    if (index < 0 || index >= targets.length) {
      return null;
    }
    return targets[index];
  }

  int hintLevelFor(String hanjaId) => hintLevelByHanjaId[hanjaId] ?? 0;

  List<Path> writingStrokesFor(String hanjaId) {
    return writingStrokesByHanjaId[hanjaId] ?? const [];
  }

  List<String> svgPathsFor(String hanjaId) {
    return strokeAssets[hanjaId]?.svgPaths?.whereType<String>().toList() ??
        const [];
  }

  ReviewSessionState copyWith({
    List<ReviewQuestion>? quizQuestions,
    ReviewSessionPhase? phase,
    int? index,
    Object? selectedAnswer = _sentinel,
    int? correctCount,
    Set<String>? passedHanjaIds,
    Set<String>? missedHanjaIds,
    Set<String>? hintedHanjaIds,
    Set<String>? retryCorrectHanjaIds,
    Set<String>? writingPassedHanjaIds,
    int? retryRound,
    Map<String, int>? hintLevelByHanjaId,
    Map<String, List<Path>>? writingStrokesByHanjaId,
    int? earnedXp,
  }) {
    return ReviewSessionState(
      items: items,
      strokeAssets: strokeAssets,
      weaknessesByHanja: weaknessesByHanja,
      quizQuestions: quizQuestions ?? this.quizQuestions,
      weakWritingHanjaIds: weakWritingHanjaIds,
      phase: phase ?? this.phase,
      index: index ?? this.index,
      selectedAnswer: identical(selectedAnswer, _sentinel)
          ? this.selectedAnswer
          : selectedAnswer as String?,
      correctCount: correctCount ?? this.correctCount,
      passedHanjaIds: passedHanjaIds ?? this.passedHanjaIds,
      missedHanjaIds: missedHanjaIds ?? this.missedHanjaIds,
      hintedHanjaIds: hintedHanjaIds ?? this.hintedHanjaIds,
      retryCorrectHanjaIds: retryCorrectHanjaIds ?? this.retryCorrectHanjaIds,
      writingPassedHanjaIds:
          writingPassedHanjaIds ?? this.writingPassedHanjaIds,
      retryRound: retryRound ?? this.retryRound,
      hintLevelByHanjaId: hintLevelByHanjaId ?? this.hintLevelByHanjaId,
      writingStrokesByHanjaId:
          writingStrokesByHanjaId ?? this.writingStrokesByHanjaId,
      earnedXp: earnedXp ?? this.earnedXp,
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
    this.retryCount = 0,
  });

  final HanjaCharacter item;
  final HanjaPracticeActivityType activityType;
  final String prompt;
  final String correctAnswer;
  final List<String> options;
  final int retryCount;

  bool get isRetry => retryCount > 0;

  String get key => '${item.id}:${activityType.name}:$retryCount';
}

const Object _sentinel = Object();

Map<String, List<HanjaWeaknessRecord>> _weaknessesByHanja(
  List<HanjaWeaknessRecord> rows,
) {
  final grouped = <String, List<HanjaWeaknessRecord>>{};
  for (final row in rows) {
    if (!row.isActive) {
      continue;
    }
    grouped.putIfAbsent(row.hanjaId, () => []).add(row);
  }
  for (final weaknesses in grouped.values) {
    weaknesses.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) {
        return byScore;
      }
      return b.lastEventAt.compareTo(a.lastEventAt);
    });
  }
  return grouped;
}

Set<String> _weakWritingHanjaIds(
  Map<String, List<HanjaWeaknessRecord>> weaknessesByHanja,
) {
  return {
    for (final entry in weaknessesByHanja.entries)
      if (entry.value.any((weakness) {
        return weakness.weaknessType == HanjaWeaknessType.writing;
      }))
        entry.key,
  };
}

List<HanjaCharacter> _sessionItems({
  required List<HanjaCharacter> allItems,
  required List<HanjaCharacter> dueItems,
  required String? focusHanjaId,
  required int limit,
}) {
  final itemsById = {for (final item in allItems) item.id: item};
  final dueIds = dueItems.map((item) => item.id).toSet();
  final selected = <HanjaCharacter>[];
  final selectedIds = <String>{};

  void addById(String id) {
    if (selectedIds.contains(id)) {
      return;
    }
    final item = itemsById[id];
    if (item == null) {
      return;
    }
    selected.add(item);
    selectedIds.add(id);
  }

  final focus = focusHanjaId?.trim();
  if (focus != null && focus.isNotEmpty && dueIds.contains(focus)) {
    addById(focus);
  }

  for (final item in dueItems) {
    addById(item.id);
  }

  if (limit <= 0 || selected.length <= limit) {
    return selected;
  }
  final focusedIndex = focus == null
      ? -1
      : selected.indexWhere((item) => item.id == focus);
  if (focusedIndex <= 0) {
    return selected.take(limit).toList();
  }
  return [
    selected[focusedIndex],
    ...selected.where((item) => item.id != focus).take(limit - 1),
  ];
}

List<ReviewQuestion> _buildReviewQuestions({
  required List<HanjaCharacter> items,
  required Map<String, List<HanjaWeaknessRecord>> weaknessesByHanja,
  required Random random,
  String? focusHanjaId,
}) {
  final shuffled = _questionOrder(
    items: items,
    random: random,
    focusHanjaId: focusHanjaId,
  );
  final questions = <ReviewQuestion>[];
  var previousCorrectIndex = -1;
  for (var index = 0; index < shuffled.length; index += 1) {
    final item = shuffled[index];
    final activityType = _activityTypeFor(
      item: item,
      weaknesses: weaknessesByHanja[item.id] ?? const [],
      random: random,
    );
    final question = _questionFor(
      item: item,
      activityType: activityType,
      candidates: items,
      seed: _seedFor([item.id, activityType.name, '$index']),
      avoidCorrectIndex: previousCorrectIndex,
    );
    questions.add(question);
    previousCorrectIndex = question.options.indexOf(question.correctAnswer);
  }
  return questions;
}

List<HanjaCharacter> _questionOrder({
  required List<HanjaCharacter> items,
  required Random random,
  String? focusHanjaId,
}) {
  final focus = focusHanjaId?.trim();
  if (focus == null || focus.isEmpty) {
    return [...items]..shuffle(random);
  }
  final focusedIndex = items.indexWhere((item) => item.id == focus);
  if (focusedIndex < 0) {
    return [...items]..shuffle(random);
  }
  final rest = [
    for (final item in items)
      if (item.id != focus) item,
  ]..shuffle(random);
  return [items[focusedIndex], ...rest];
}

HanjaPracticeActivityType _activityTypeFor({
  required HanjaCharacter item,
  required List<HanjaWeaknessRecord> weaknesses,
  required Random random,
}) {
  if (weaknesses.any((weakness) {
    return weakness.weaknessType == HanjaWeaknessType.hanjaRecognition ||
        weakness.weaknessType == HanjaWeaknessType.shapeConfusion;
  })) {
    return HanjaPracticeActivityType.hunToHanja;
  }
  if (weaknesses.any((weakness) {
    return weakness.weaknessType == HanjaWeaknessType.hunMeaning;
  })) {
    return HanjaPracticeActivityType.hanjaToHun;
  }
  final seed = _seedFor([item.id, '${random.nextInt(1 << 20)}']);
  return seed.isEven
      ? HanjaPracticeActivityType.hanjaToHun
      : HanjaPracticeActivityType.hunToHanja;
}

ReviewQuestion _questionFor({
  required HanjaCharacter item,
  required HanjaPracticeActivityType activityType,
  required List<HanjaCharacter> candidates,
  required int seed,
  int retryCount = 0,
  int avoidCorrectIndex = -1,
}) {
  final correct = activityType == HanjaPracticeActivityType.hanjaToHun
      ? item.meaning
      : item.character;
  return ReviewQuestion(
    item: item,
    activityType: activityType,
    prompt: activityType == HanjaPracticeActivityType.hanjaToHun
        ? item.character
        : item.meaning,
    correctAnswer: correct,
    options: _optionsFor(
      correct: correct,
      candidates: activityType == HanjaPracticeActivityType.hanjaToHun
          ? candidates.map((candidate) => candidate.meaning)
          : candidates.map((candidate) => candidate.character),
      seed: _seedFor([item.id, activityType.name, '$retryCount', '$seed']),
      avoidCorrectIndex: avoidCorrectIndex,
    ),
    retryCount: retryCount,
  );
}

List<ReviewQuestion> _quizQuestionsWithRetry({
  required List<ReviewQuestion> questions,
  required int currentIndex,
  required ReviewQuestion failedQuestion,
  required List<HanjaCharacter> candidates,
}) {
  if (failedQuestion.retryCount >= _maxInlineRetryCount) {
    return questions;
  }
  final retryCount = failedQuestion.retryCount + 1;
  final retryQuestion = _questionFor(
    item: failedQuestion.item,
    activityType: failedQuestion.activityType,
    candidates: candidates,
    seed: _seedFor([failedQuestion.key, '$retryCount']),
    retryCount: retryCount,
  );
  final insertIndex = (currentIndex + _inlineRetryDistance).clamp(
    currentIndex + 1,
    questions.length,
  );
  return [
    ...questions.take(insertIndex),
    retryQuestion,
    ...questions.skip(insertIndex),
  ];
}

List<ReviewQuestion> _buildRetryQuestions({
  required List<HanjaCharacter> items,
  required List<HanjaCharacter> candidates,
  required int retryRound,
}) {
  return [
    for (var index = 0; index < items.length; index += 1)
      _questionFor(
        item: items[index],
        activityType: HanjaPracticeActivityType.hunToHanja,
        candidates: candidates,
        seed: _seedFor([
          items[index].id,
          'final-retry',
          '$retryRound',
          '$index',
        ]),
        retryCount: _maxInlineRetryCount + retryRound + 1,
      ),
  ];
}

List<String> _optionsFor({
  required String correct,
  required Iterable<String> candidates,
  required int seed,
  int avoidCorrectIndex = -1,
}) {
  final distractors = candidates
      .where((candidate) => candidate != correct)
      .toSet()
      .toList();
  distractors.shuffle(Random(seed));
  final options = <String>[correct, ...distractors.take(3)];
  options.shuffle(Random(seed + 31));
  final correctIndex = options.indexOf(correct);
  if (options.length > 1 &&
      avoidCorrectIndex >= 0 &&
      correctIndex == avoidCorrectIndex) {
    final swapIndex = (correctIndex + 1) % options.length;
    final temp = options[swapIndex];
    options[swapIndex] = correct;
    options[correctIndex] = temp;
  }
  return options;
}

int _seedFor(List<String> parts) {
  var hash = 0x811c9dc5;
  for (final codeUnit in parts.join('|').codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}
