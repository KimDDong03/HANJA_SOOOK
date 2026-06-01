class LearningEnvironmentSettings {
  const LearningEnvironmentSettings({
    this.backgroundMusicEnabled = true,
    this.soundEffectsEnabled = true,
    this.strokeSoundEnabled = true,
  });

  final bool backgroundMusicEnabled;
  final bool soundEffectsEnabled;
  final bool strokeSoundEnabled;

  LearningEnvironmentSettings copyWith({
    bool? backgroundMusicEnabled,
    bool? soundEffectsEnabled,
    bool? strokeSoundEnabled,
  }) {
    return LearningEnvironmentSettings(
      backgroundMusicEnabled:
          backgroundMusicEnabled ?? this.backgroundMusicEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      strokeSoundEnabled: strokeSoundEnabled ?? this.strokeSoundEnabled,
    );
  }
}
