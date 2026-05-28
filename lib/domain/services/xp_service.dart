class XpService {
  const XpService();

  static const writingCompletionSource = 'writing_completion';
  static const dailyCompletionSource = 'daily_completion_bonus';

  int writingCompletionXp() => 10;

  int dailyCompletionBonusXp() => 20;

  int levelForTotalXp(int totalXp) {
    return (totalXp ~/ 100) + 1;
  }

  int currentLevelRequiredXp(int level) {
    return (level - 1) * 100;
  }

  int nextLevelRequiredXp(int level) {
    return level * 100;
  }
}
