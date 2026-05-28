import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/content_repository_provider.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/stroke_asset.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_progress_controller.dart';

final writingProvider = FutureProvider.family<WritingState, String>((
  ref,
  hanjaId,
) async {
  final repository = ref.watch(contentRepositoryProvider);
  final hanja = await repository.getHanjaById(hanjaId);
  final strokeAsset = await repository.getStrokeAsset(hanjaId);
  return WritingState(hanja: hanja, strokeAsset: strokeAsset);
});

final writingCompletionControllerProvider =
    Provider<WritingCompletionController>(WritingCompletionController.new);

class WritingCompletionController {
  const WritingCompletionController(this._ref);

  final Ref _ref;

  Future<LearningCompletionResult> completePractice(String hanjaId) async {
    final grade = _ref.read(currentProfileProvider)?.grade;
    final todaySet = await _ref
        .read(contentRepositoryProvider)
        .getTodayHanjaSet(grade: grade, limit: AppConstants.dailyHanjaCount);
    return _ref
        .read(learningProgressControllerProvider)
        .markHanjaCompleted(
          hanjaId: hanjaId,
          todayHanjaIds: todaySet.map((hanja) => hanja.id).toSet(),
        );
  }
}

class WritingState {
  const WritingState({required this.hanja, required this.strokeAsset});

  final HanjaCharacter? hanja;
  final StrokeAsset? strokeAsset;

  List<String> get svgPaths {
    return strokeAsset?.svgPaths?.whereType<String>().toList() ?? const [];
  }

  bool get hasStrokeGuide => svgPaths.isNotEmpty;
}
