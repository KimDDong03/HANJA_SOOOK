import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/hanja_example.dart';
import '../../domain/models/stroke_asset.dart';
import '../../domain/services/learning_plan_service.dart';
import '../../domain/services/svg_path_parser.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_progress_controller.dart';

final writingProvider = FutureProvider.family<WritingState, String>((
  ref,
  hanjaId,
) async {
  final repository = ref.watch(contentRepositoryProvider);
  final hanja = await repository.getHanjaById(hanjaId);
  final examples = await repository.getExamples(hanjaId);
  final strokeAsset = await repository.getStrokeAsset(hanjaId);
  return WritingState(
    hanja: hanja,
    examples: examples,
    strokeAsset: strokeAsset,
  );
});

final writingCompletionControllerProvider =
    Provider<WritingCompletionController>(WritingCompletionController.new);

class WritingCompletionController {
  const WritingCompletionController(this._ref);

  final Ref _ref;

  Future<LearningCompletionResult> completePractice(String hanjaId) async {
    final grade = _ref.read(currentProfileProvider)?.grade;
    final studentKey = currentStudentKey(_ref);
    final learningDate = currentLearningDate();
    final allItems = await _ref
        .read(contentRepositoryProvider)
        .getHanjaList(grade: grade);
    final progressRecords = await _ref
        .read(learningProgressRepositoryProvider)
        .getCompletedHanjaRecordsForStudent(studentKey: studentKey);
    final plan = const LearningPlanService().buildDailyPlan(
      allItems: allItems,
      progressRecords: progressRecords,
      learningDate: learningDate,
      newItemLimit: AppConstants.dailyHanjaCount,
      reviewItemLimit: AppConstants.dailyReviewCount,
    );
    return _ref
        .read(learningProgressControllerProvider)
        .markHanjaCompleted(hanjaId: hanjaId, todayHanjaIds: plan.itemIds);
  }
}

class WritingState {
  const WritingState({
    required this.hanja,
    required this.examples,
    required this.strokeAsset,
  });

  final HanjaCharacter? hanja;
  final List<HanjaExample> examples;
  final StrokeAsset? strokeAsset;

  List<String> get svgPaths {
    final paths = strokeAsset?.svgPaths?.whereType<String>().toList();
    if (paths == null || paths.isEmpty) {
      return const [];
    }
    final validPaths = <String>[];
    for (final path in paths) {
      if (path.trim().isEmpty) {
        continue;
      }
      if (SvgPathParser.tryParse(path) == null) {
        return const [];
      }
      validPaths.add(path);
    }
    return validPaths;
  }

  bool get hasStrokeGuide => svgPaths.isNotEmpty;
}
