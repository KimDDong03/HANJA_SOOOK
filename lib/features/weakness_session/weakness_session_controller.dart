import 'dart:math';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_diagnostics_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/learning_diagnostics.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_diagnostics_controller.dart';
import '../learning/learning_progress_controller.dart';

final weaknessSessionProvider = AsyncNotifierProvider.autoDispose
    .family<WeaknessSessionController, WeaknessSessionState, String?>(
      WeaknessSessionController.new,
    );

enum WeaknessTaskKind { hanjaToHun, hunToHanja, writing }

class WeaknessSessionController extends AsyncNotifier<WeaknessSessionState> {
  WeaknessSessionController(this.focusHanjaId);

  final String? focusHanjaId;

  @override
  Future<WeaknessSessionState> build() async {
    final studentKey = currentStudentKey(ref);
    final weaknesses = await ref
        .watch(learningDiagnosticsRepositoryProvider)
        .getActiveWeaknesses(studentKey: studentKey);
    final contentRepository = ref.watch(contentRepositoryProvider);
    final allItems = await contentRepository.getHanjaList(
      grade: ref.watch(currentProfileProvider)?.grade,
    );
    final itemsById = {for (final item in allItems) item.id: item};
    final focused = _prioritizeFocus(weaknesses, focusHanjaId).take(6).toList();
    final tasks = <WeaknessTask>[];
    for (final weakness in focused) {
      final item = itemsById[weakness.hanjaId];
      if (item == null) {
        continue;
      }
      tasks.addAll(
        _tasksFor(item: item, weakness: weakness, allItems: allItems),
      );
    }
    return WeaknessSessionState(tasks: tasks);
  }

  Future<void> selectAnswer(String answer) async {
    final current = state.value;
    final task = current?.currentTask;
    if (current == null ||
        task == null ||
        task.kind == WeaknessTaskKind.writing ||
        current.selectedAnswer != null) {
      return;
    }
    final isCorrect = answer == task.correctAnswer;
    await _recordAttempt(
      task: task,
      result: isCorrect
          ? HanjaPracticeResult.correct
          : HanjaPracticeResult.incorrect,
    );
    state = AsyncData(
      current.copyWith(
        selectedAnswer: answer,
        passedTaskKeys: isCorrect
            ? {...current.passedTaskKeys, task.key}
            : current.passedTaskKeys,
        failedHanjaIds: isCorrect
            ? current.failedHanjaIds
            : {...current.failedHanjaIds, task.item.id},
      ),
    );
  }

  Future<void> recordWritingHint() async {
    final current = state.value;
    final task = current?.currentTask;
    if (current == null ||
        task == null ||
        task.kind != WeaknessTaskKind.writing) {
      return;
    }
    final nextHintLevel = (current.hintLevelFor(task.item.id) + 1)
        .clamp(0, 3)
        .toInt();
    await _recordAttempt(
      task: task,
      result: HanjaPracticeResult.hinted,
      hintLevel: nextHintLevel,
    );
    state = AsyncData(
      current.copyWith(
        hintLevelByHanjaId: {
          ...current.hintLevelByHanjaId,
          task.item.id: nextHintLevel,
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
    final task = current?.currentTask;
    if (current == null ||
        task == null ||
        task.kind != WeaknessTaskKind.writing) {
      return;
    }
    await _recordAttempt(
      task: task,
      result: HanjaPracticeResult.correct,
      hintLevel: current.hintLevelFor(task.item.id),
    );
    state = AsyncData(
      current.copyWith(passedTaskKeys: {...current.passedTaskKeys, task.key}),
    );
  }

  Future<void> nextOrFinish() async {
    final current = state.value;
    if (current == null) {
      return;
    }
    if (current.currentTask?.kind != WeaknessTaskKind.writing &&
        current.selectedAnswer == null) {
      return;
    }
    if (current.currentTask?.kind == WeaknessTaskKind.writing &&
        !current.passedTaskKeys.contains(current.currentTask!.key)) {
      return;
    }
    if (current.index < current.tasks.length - 1) {
      state = AsyncData(
        current.copyWith(index: current.index + 1, selectedAnswer: null),
      );
      return;
    }
    await _recordCompletion(current);
    state = AsyncData(
      current.copyWith(phaseComplete: true, selectedAnswer: null),
    );
  }

  Future<void> _recordCompletion(WeaknessSessionState current) async {
    final tasksByHanja = <String, List<WeaknessTask>>{};
    for (final task in current.tasks) {
      tasksByHanja.putIfAbsent(task.item.id, () => []).add(task);
    }
    for (final entry in tasksByHanja.entries) {
      final tasks = entry.value;
      final passedAll = tasks.every((task) {
        return current.passedTaskKeys.contains(task.key);
      });
      if (!passedAll) {
        continue;
      }
      await ref
          .read(learningDiagnosticsControllerProvider)
          .recordAttempt(
            hanjaId: entry.key,
            source: HanjaPracticeSource.weaknessSession,
            activityType: HanjaPracticeActivityType.weaknessPass,
            result: HanjaPracticeResult.passed,
            isLearned: true,
            weaknessType: tasks.first.weakness.weaknessType,
          );
    }
  }

  Future<void> _recordAttempt({
    required WeaknessTask task,
    required HanjaPracticeResult result,
    int? hintLevel,
  }) {
    return ref
        .read(learningDiagnosticsControllerProvider)
        .recordAttempt(
          hanjaId: task.item.id,
          source: HanjaPracticeSource.weaknessSession,
          activityType: task.activityType,
          result: result,
          isLearned: true,
          weaknessType: task.weakness.weaknessType,
          hintLevel: hintLevel,
        );
  }
}

class WeaknessSessionState {
  const WeaknessSessionState({
    required this.tasks,
    this.index = 0,
    this.selectedAnswer,
    this.passedTaskKeys = const <String>{},
    this.failedHanjaIds = const <String>{},
    this.hintLevelByHanjaId = const <String, int>{},
    this.writingStrokesByHanjaId = const <String, List<Path>>{},
    this.phaseComplete = false,
  });

  final List<WeaknessTask> tasks;
  final int index;
  final String? selectedAnswer;
  final Set<String> passedTaskKeys;
  final Set<String> failedHanjaIds;
  final Map<String, int> hintLevelByHanjaId;
  final Map<String, List<Path>> writingStrokesByHanjaId;
  final bool phaseComplete;

  WeaknessTask? get currentTask {
    if (index < 0 || index >= tasks.length) {
      return null;
    }
    return tasks[index];
  }

  int hintLevelFor(String hanjaId) => hintLevelByHanjaId[hanjaId] ?? 0;

  List<Path> writingStrokesFor(String hanjaId) {
    return writingStrokesByHanjaId[hanjaId] ?? const [];
  }

  int get hanjaCount => tasks.map((task) => task.item.id).toSet().length;

  int get completedHanjaCount {
    final ids = tasks.map((task) => task.item.id).toSet();
    return ids.where((id) {
      final itemTasks = tasks.where((task) => task.item.id == id);
      return itemTasks.every((task) => passedTaskKeys.contains(task.key));
    }).length;
  }

  WeaknessSessionState copyWith({
    int? index,
    Object? selectedAnswer = _sentinel,
    Set<String>? passedTaskKeys,
    Set<String>? failedHanjaIds,
    Map<String, int>? hintLevelByHanjaId,
    Map<String, List<Path>>? writingStrokesByHanjaId,
    bool? phaseComplete,
  }) {
    return WeaknessSessionState(
      tasks: tasks,
      index: index ?? this.index,
      selectedAnswer: identical(selectedAnswer, _sentinel)
          ? this.selectedAnswer
          : selectedAnswer as String?,
      passedTaskKeys: passedTaskKeys ?? this.passedTaskKeys,
      failedHanjaIds: failedHanjaIds ?? this.failedHanjaIds,
      hintLevelByHanjaId: hintLevelByHanjaId ?? this.hintLevelByHanjaId,
      writingStrokesByHanjaId:
          writingStrokesByHanjaId ?? this.writingStrokesByHanjaId,
      phaseComplete: phaseComplete ?? this.phaseComplete,
    );
  }
}

class WeaknessTask {
  const WeaknessTask({
    required this.item,
    required this.weakness,
    required this.kind,
    required this.prompt,
    required this.correctAnswer,
    required this.options,
  });

  final HanjaCharacter item;
  final HanjaWeaknessRecord weakness;
  final WeaknessTaskKind kind;
  final String prompt;
  final String correctAnswer;
  final List<String> options;

  String get key => '${item.id}:${kind.name}';

  HanjaPracticeActivityType get activityType {
    return switch (kind) {
      WeaknessTaskKind.hanjaToHun => HanjaPracticeActivityType.hanjaToHun,
      WeaknessTaskKind.hunToHanja => HanjaPracticeActivityType.hunToHanja,
      WeaknessTaskKind.writing => HanjaPracticeActivityType.writing,
    };
  }
}

const Object _sentinel = Object();

List<HanjaWeaknessRecord> _prioritizeFocus(
  List<HanjaWeaknessRecord> weaknesses,
  String? focusHanjaId,
) {
  final sorted = [...weaknesses]
    ..sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) {
        return byScore;
      }
      return b.lastEventAt.compareTo(a.lastEventAt);
    });
  final focus = focusHanjaId?.trim();
  if (focus == null || focus.isEmpty) {
    return sorted;
  }
  return [
    ...sorted.where((weakness) => weakness.hanjaId == focus),
    ...sorted.where((weakness) => weakness.hanjaId != focus),
  ];
}

List<WeaknessTask> _tasksFor({
  required HanjaCharacter item,
  required HanjaWeaknessRecord weakness,
  required List<HanjaCharacter> allItems,
}) {
  final order = switch (weakness.weaknessType) {
    HanjaWeaknessType.writing => [
      WeaknessTaskKind.writing,
      WeaknessTaskKind.hanjaToHun,
      WeaknessTaskKind.hunToHanja,
    ],
    HanjaWeaknessType.hanjaRecognition => [
      WeaknessTaskKind.hunToHanja,
      WeaknessTaskKind.hanjaToHun,
      WeaknessTaskKind.writing,
    ],
    _ => [
      WeaknessTaskKind.hanjaToHun,
      WeaknessTaskKind.hunToHanja,
      WeaknessTaskKind.writing,
    ],
  };
  return [
    for (final kind in order)
      WeaknessTask(
        item: item,
        weakness: weakness,
        kind: kind,
        prompt: switch (kind) {
          WeaknessTaskKind.hanjaToHun => item.character,
          WeaknessTaskKind.hunToHanja => item.meaning,
          WeaknessTaskKind.writing => item.meaning,
        },
        correctAnswer: switch (kind) {
          WeaknessTaskKind.hanjaToHun => item.meaning,
          WeaknessTaskKind.hunToHanja => item.character,
          WeaknessTaskKind.writing => item.character,
        },
        options: switch (kind) {
          WeaknessTaskKind.hanjaToHun => _optionsFor(
            correct: item.meaning,
            candidates: allItems.map((candidate) => candidate.meaning),
          ),
          WeaknessTaskKind.hunToHanja => _optionsFor(
            correct: item.character,
            candidates: allItems.map((candidate) => candidate.character),
          ),
          WeaknessTaskKind.writing => const [],
        },
      ),
  ];
}

List<String> _optionsFor({
  required String correct,
  required Iterable<String> candidates,
}) {
  final options = candidates
      .where((candidate) => candidate != correct)
      .toSet()
      .take(3)
      .toList();
  options.shuffle(Random(correct.hashCode));
  options.insert(0, correct);
  options.shuffle(Random(correct.hashCode + options.length));
  return options;
}
