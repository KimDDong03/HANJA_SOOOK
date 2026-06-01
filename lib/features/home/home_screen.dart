import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';
import '../../domain/models/hanja_character.dart';
import '../auth/current_profile_controller.dart';
import 'home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final todayLearning = ref.watch(todayLearningProvider);
    final growth = ref.watch(homeGrowthSummaryProvider);

    return Scaffold(
      body: PlayfulPage(
        title: profile == null ? '한자쏘옥 모험' : '안녕하세요, ${profile.displayName}!',
        subtitle: profile == null
            ? '오늘의 한자를 모아 별을 채워요'
            : '${profile.schoolName ?? '학교 미설정'} · ${profile.grade ?? '-'}학년',
        children: [
          todayLearning.when(
            data: (learning) {
              if (learning.items.isEmpty) {
                return PlayfulPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '오늘의 한자 데이터가 아직 없습니다.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.go(RoutePaths.appLearn),
                        icon: const Icon(Icons.menu_book),
                        label: const Text('한자장 보기'),
                      ),
                    ],
                  ),
                );
              }
              final hanja = learning.currentHanja;
              if (hanja == null || learning.isComplete) {
                return _TodayCompletePanel(learning: learning);
              }
              final chapterName = learning.chapterName;
              return PlayfulPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                learning.isReviewItem(hanja.id)
                                    ? '오늘의 복습'
                                    : chapterName ?? '오늘의 새 한자',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                hanja.meaning,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (chapterName == null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  hanja.unitName ?? '교과서 단원 정보 없음',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: Text(
                              hanja.character,
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    fontFamily: AppFonts.hanjaSerif,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        PlayfulStat(
                          icon: Icons.auto_awesome,
                          label: '완료',
                          value:
                              '${learning.completedCount}/${learning.totalCount}',
                          color: AppColors.green,
                        ),
                        const SizedBox(width: 10),
                        PlayfulStat(
                          icon: Icons.local_fire_department,
                          label: '새 한자',
                          value: '${learning.newCount}개',
                          color: AppColors.peach,
                        ),
                        const SizedBox(width: 10),
                        PlayfulStat(
                          icon: Icons.refresh,
                          label: '복습',
                          value: '${learning.reviewCount}개',
                          color: AppColors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final item in learning.items)
                          _HanjaChip(
                            item: item,
                            isCompleted: learning.isCompleted(item.id),
                            isReview: learning.isReviewItem(item.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () =>
                          context.push(RoutePaths.guidedWriting(hanja.id)),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('오늘의 한자 시작'),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => context.push(RoutePaths.hanja(hanja.id)),
                      icon: const Icon(Icons.menu_book_outlined),
                      label: const Text('한자 카드 보기'),
                    ),
                  ],
                ),
              );
            },
            loading: () => const PlayfulPanel(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => PlayfulPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '오늘의 한자를 불러오지 못했습니다.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(todayLearningProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 불러오기'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          growth.when(
            data: (state) => _GrowthSummaryPanel(state: state),
            loading: () => const PlayfulPanel(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => PlayfulPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('성장 정보를 불러오지 못했습니다.', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: ref.read(homeGrowthSummaryRetryProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 불러오기'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayCompletePanel extends StatelessWidget {
  const _TodayCompletePanel({required this.learning});

  final TodayLearningState learning;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '오늘 할 일을 모두 끝냈어요',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              PlayfulStat(
                icon: Icons.auto_awesome,
                label: '완료',
                value: '${learning.completedCount}/${learning.totalCount}',
                color: AppColors.green,
              ),
              const SizedBox(width: 10),
              PlayfulStat(
                icon: Icons.local_fire_department,
                label: '새 한자',
                value: '${learning.newCount}개',
                color: AppColors.peach,
              ),
              const SizedBox(width: 10),
              PlayfulStat(
                icon: Icons.refresh,
                label: '복습',
                value: '${learning.reviewCount}개',
                color: AppColors.blue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.go(RoutePaths.appLearn),
            icon: const Icon(Icons.menu_book),
            label: const Text('한자장 보기'),
          ),
        ],
      ),
    );
  }
}

class _GrowthSummaryPanel extends StatelessWidget {
  const _GrowthSummaryPanel({required this.state});

  final HomeGrowthSummaryState state;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryDark),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -26,
            child: Icon(
              Icons.auto_awesome,
              size: 116,
              color: Colors.white.withValues(alpha: 0.13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.military_tech,
                          color: AppColors.primary,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '레벨 ${state.level}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.levelTitle,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${state.totalXp}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Text(
                        'XP',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Spacer(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        child: Text(
                          '다음까지 ${state.remainingXp} XP',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 14,
                    color: AppColors.yellow,
                    backgroundColor: Colors.white.withValues(alpha: 0.24),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _HomeGrowthBadge(
                      icon: Icons.flag,
                      label: '오늘 완료',
                      value:
                          '${state.completedTodayCount}/${state.todayTotalCount}',
                      color: AppColors.green,
                    ),
                    const SizedBox(width: 8),
                    _HomeGrowthBadge(
                      icon: Icons.pending_actions,
                      label: '남은 한자',
                      value: '${state.todayRemainingCount}개',
                      color: AppColors.blue,
                    ),
                    const SizedBox(width: 8),
                    _HomeGrowthBadge(
                      icon: Icons.emoji_events,
                      label: '보상',
                      value: state.rewardLabel,
                      color: AppColors.peach,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _HomeGrowthBadge extends StatelessWidget {
  const _HomeGrowthBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Icon(icon, size: 18, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HanjaChip extends StatelessWidget {
  const _HanjaChip({
    required this.item,
    required this.isCompleted,
    required this.isReview,
  });

  final HanjaCharacter item;
  final bool isCompleted;
  final bool isReview;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: isCompleted
          ? const Icon(Icons.star, size: 18)
          : isReview
          ? const Icon(Icons.refresh, size: 18)
          : null,
      label: Text(
        item.character,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontFamily: AppFonts.hanjaSerif,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
