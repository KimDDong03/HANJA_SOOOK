import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/env.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/future_features_panel.dart';
import '../../core/widgets/playful_page.dart';
import '../../domain/models/class_ranking.dart';
import 'class_ranking_controller.dart';

class ClassRankingScreen extends ConsumerWidget {
  const ClassRankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (AppEnv.isProduction) {
      return const Scaffold(
        body: FutureFeaturesPage(
          title: '반 랭킹',
          subtitle: '친구들과 함께하는 랭킹은 향후 업데이트에서 제공될 예정입니다',
        ),
      );
    }

    final state = ref.watch(classRankingProvider);

    return Scaffold(
      body: state.when(
        data: (data) => _RankingContent(data: data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('랭킹을 불러오지 못했습니다.')),
      ),
    );
  }
}

class _RankingContent extends ConsumerWidget {
  const _RankingContent({required this.data});

  final ClassRankingState data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(classRankingProvider.notifier);
    final myEntry = data.myEntry;

    return PlayfulPage(
      title: '반 랭킹',
      subtitle: data.isSample
          ? '반 미가입 상태라 샘플 랭킹을 보여줘요'
          : data.isEmptyClass
          ? '${data.className}에 아직 학생이 없습니다'
          : '${data.className} 기록을 비교해요',
      children: [
        if (data.isSample) ...[
          const _RankingNotice(
            icon: Icons.info_outline,
            message: '현재는 샘플 랭킹입니다. 실제 반 랭킹은 반 코드 참여 후 이 기기의 도전 기록으로 표시됩니다.',
          ),
          const SizedBox(height: 12),
          PlayfulActionTile(
            icon: Icons.meeting_room,
            title: '반 코드로 참여하기',
            subtitle: '선생님이 알려준 반 코드로 실제 랭킹을 시작해요',
            color: AppColors.surface,
            onTap: () => context.push(RoutePaths.studentLinksFor('student')),
          ),
          const SizedBox(height: 16),
        ],
        PlayfulPanel(
          child: Row(
            children: [
              PlayfulStat(
                icon: Icons.person,
                label: '내 순위',
                value: myEntry == null ? '-' : '${myEntry.rank}위',
                color: AppColors.yellow,
              ),
              const SizedBox(width: 10),
              PlayfulStat(
                icon: Icons.star,
                label: '내 기록',
                value: myEntry == null ? '-' : myEntry.scoreText,
                color: AppColors.green,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PlayfulPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '통합 리그',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final filter in ClassRankingMetric.values)
                    ChoiceChip(
                      label: Text(filter.label),
                      selected: data.selectedFilter == filter,
                      onSelected: (_) => controller.selectFilter(filter),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (data.entries.isEmpty)
                _RankingEmptyState(
                  message: data.isEmptyClass
                      ? '참여한 반에 아직 학생이 없습니다.'
                      : '아직 비교할 반 기록이 없습니다.',
                  actionLabel: data.isSample ? '반 코드로 참여하기' : '도전하러 가기',
                  onPressed: data.isSample
                      ? () =>
                            context.push(RoutePaths.studentLinksFor('student'))
                      : () => context.go(RoutePaths.appChallenge),
                )
              else
                for (final entry in data.entries)
                  _RankingRow(
                    rank: entry.rank,
                    name: entry.displayName,
                    score: entry.scoreText,
                    isMe: entry.isMe,
                  ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.appChallenge),
          icon: const Icon(Icons.emoji_events),
          label: const Text('도전하러 가기'),
        ),
      ],
    );
  }
}

class _RankingNotice extends StatelessWidget {
  const _RankingNotice({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      color: AppColors.blue.withValues(alpha: 0.24),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingEmptyState extends StatelessWidget {
  const _RankingEmptyState({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          const Icon(
            Icons.leaderboard_outlined,
            size: 42,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.chevron_right),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.rank,
    required this.name,
    required this.score,
    required this.isMe,
  });

  final int rank;
  final String name;
  final String score;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isMe ? AppColors.yellow : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMe
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isMe ? AppColors.primary : AppColors.surface,
                foregroundColor: isMe ? Colors.white : AppColors.textPrimary,
                child: Text('$rank'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                score,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
