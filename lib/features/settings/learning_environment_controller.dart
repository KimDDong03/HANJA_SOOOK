import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database_provider.dart';
import '../../domain/models/learning_environment_settings.dart';

final learningEnvironmentControllerProvider =
    AsyncNotifierProvider<
      LearningEnvironmentController,
      LearningEnvironmentSettings
    >(LearningEnvironmentController.new);

class LearningEnvironmentController
    extends AsyncNotifier<LearningEnvironmentSettings> {
  @override
  Future<LearningEnvironmentSettings> build() async {
    final row = await ref
        .watch(appDatabaseProvider)
        .getLearningEnvironmentSettings();
    if (row == null) {
      return const LearningEnvironmentSettings();
    }
    return LearningEnvironmentSettings(
      backgroundMusicEnabled: row.backgroundMusicEnabled,
      soundEffectsEnabled: row.soundEffectsEnabled,
      strokeSoundEnabled: row.strokeSoundEnabled,
    );
  }

  Future<void> setBackgroundMusicEnabled(bool value) {
    return _save(_current.copyWith(backgroundMusicEnabled: value));
  }

  Future<void> setSoundEffectsEnabled(bool value) {
    return _save(_current.copyWith(soundEffectsEnabled: value));
  }

  Future<void> setStrokeSoundEnabled(bool value) {
    return _save(_current.copyWith(strokeSoundEnabled: value));
  }

  LearningEnvironmentSettings get _current {
    return state.asData?.value ?? const LearningEnvironmentSettings();
  }

  Future<void> _save(LearningEnvironmentSettings next) async {
    state = AsyncData(next);
    await ref
        .read(appDatabaseProvider)
        .saveLearningEnvironmentSettings(
          backgroundMusicEnabled: next.backgroundMusicEnabled,
          soundEffectsEnabled: next.soundEffectsEnabled,
          strokeSoundEnabled: next.strokeSoundEnabled,
          updatedAt: DateTime.now(),
        );
  }
}
