import 'package:freezed_annotation/freezed_annotation.dart';

import 'badge.dart';

part 'growth_state.freezed.dart';
part 'growth_state.g.dart';

@freezed
abstract class GrowthState with _$GrowthState {
  const factory GrowthState({
    @JsonKey(name: 'user_id') required String userId,
    @Default(1) int level,
    @JsonKey(name: 'total_xp') @Default(0) int totalXp,
    @Default(0) int coins,
    @JsonKey(name: 'current_level_required_xp')
    @Default(0)
    int currentLevelRequiredXp,
    @JsonKey(name: 'next_level_required_xp') int? nextLevelRequiredXp,
    @Default(<Badge>[]) List<Badge> badges,
    @JsonKey(name: 'ability_scores')
    @Default(<String, int>{})
    Map<String, int> abilityScores,
  }) = _GrowthState;

  factory GrowthState.fromJson(Map<String, dynamic> json) =>
      _$GrowthStateFromJson(json);
}
