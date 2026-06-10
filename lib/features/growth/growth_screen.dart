import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';
import 'growth_controller.dart';

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(growthProvider);

    return Scaffold(
      body: state.when(
        data: (data) => PlayfulPage(
          title: '성장 앨범',
          subtitle: '모은 XP와 오늘의 성장을 확인해요',
          leading: _GrowthBackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
                return;
              }
              context.go(RoutePaths.appHome);
            },
          ),
          children: [
            _LevelHero(data: data),
            const SizedBox(height: 14),
            _TodayQuestPanel(data: data),
            const SizedBox(height: 14),
            _RewardTrack(data: data),
            const SizedBox(height: 14),
            _MotivationPanel(data: data),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton.icon(
            onPressed: () => ref.invalidate(growthProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('성장 정보 다시 불러오기'),
          ),
        ),
      ),
    );
  }
}

class _GrowthBackButton extends StatelessWidget {
  const _GrowthBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back),
        tooltip: '뒤로가기',
      ),
    );
  }
}

class _LevelHero extends StatelessWidget {
  const _LevelHero({required this.data});

  final GrowthViewState data;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryDark),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -22,
            child: Icon(
              Icons.auto_awesome,
              size: 120,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Icon(
                          Icons.military_tech,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '레벨 ${data.level}',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data.titleForLevel,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${data.totalXp}',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'XP',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: data.levelProgressValue.clamp(0, 1),
                    minHeight: 16,
                    color: AppColors.yellow,
                    backgroundColor: Colors.white.withValues(alpha: 0.26),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '다음 레벨까지 ${data.remainingXp} XP',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayQuestPanel extends StatelessWidget {
  const _TodayQuestPanel({required this.data});

  final GrowthViewState data;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '오늘의 성장 미션',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${data.completedTodayCount}/${data.todayTotalCount}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: data.todayProgressValue.clamp(0, 1),
              minHeight: 14,
              color: AppColors.green,
              backgroundColor: AppColors.border.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              PlayfulStat(
                icon: Icons.check_circle,
                label: '완료',
                value: '${data.completedTodayCount}개',
                color: AppColors.green,
              ),
              const SizedBox(width: 10),
              PlayfulStat(
                icon: Icons.pending_actions,
                label: '남은 한자',
                value: '${data.remainingTodayCount}개',
                color: AppColors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardTrack extends StatelessWidget {
  const _RewardTrack({required this.data});

  final GrowthViewState data;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '보상 트랙',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.rewardTrackMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _RewardBadge(
                icon: Icons.star,
                label: '30 XP',
                color: AppColors.yellow,
                isUnlocked: data.isRewardUnlocked(30),
              ),
              const Expanded(child: _RewardLine()),
              _RewardBadge(
                icon: Icons.workspace_premium,
                label: '60 XP',
                color: AppColors.mint,
                isUnlocked: data.isRewardUnlocked(60),
              ),
              const Expanded(child: _RewardLine()),
              _RewardBadge(
                icon: Icons.emoji_events,
                label: '100 XP',
                color: AppColors.peach,
                isUnlocked: data.isRewardUnlocked(99),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  const _RewardBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.isUnlocked,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: isUnlocked ? color : AppColors.surfaceMuted,
            shape: BoxShape.circle,
            border: Border.all(
              color: isUnlocked ? AppColors.primary : AppColors.border,
              width: isUnlocked ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Icon(
              icon,
              color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _RewardLine extends StatelessWidget {
  const _RewardLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      margin: const EdgeInsets.only(bottom: 22),
      color: AppColors.border,
    );
  }
}

class _MotivationPanel extends StatelessWidget {
  const _MotivationPanel({required this.data});

  final GrowthViewState data;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      color: data.isTodayComplete ? AppColors.yellow : AppColors.lavender,
      child: Row(
        children: [
          Icon(
            data.isTodayComplete
                ? Icons.celebration
                : Icons.local_fire_department,
            color: AppColors.textPrimary,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.motivationMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
