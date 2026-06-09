import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/env.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/app_slogan_banner.dart';
import '../../core/widgets/future_features_panel.dart';
import '../../core/widgets/playful_page.dart';
import '../../domain/models/class_ranking.dart';
import '../flip_board/flip_board_controller.dart';
import '../flip_board/flip_board_time_limit_picker.dart';
import 'challenge_controller.dart';

class ChallengeScreen extends ConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(challengeSummaryProvider);

    return Scaffold(
      body: PlayfulPage(
        title: '도전',
        subtitle: AppEnv.isProduction ? '게임으로 배운 한자를 복습해요' : '오늘 점수와 반 순위를 올려요',
        children: [
          const AppSloganBanner(),
          const SizedBox(height: 16),
          summary.when(
            data: (data) => _ChallengeContent(data: data),
            loading: () => const PlayfulPanel(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) =>
                const PlayfulPanel(child: Text('도전 기록을 불러오지 못했습니다.')),
          ),
        ],
      ),
    );
  }
}

class _ChallengeContent extends StatelessWidget {
  const _ChallengeContent({required this.data});

  final ChallengeSummaryState data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (AppEnv.showsPreviewFeatures) ...[
          if (data.hasJoinedClass)
            _ChallengeSummaryPanel(data: data)
          else
            const _JoinClassPrompt(),
          const SizedBox(height: 18),
        ],
        Text(
          '도전 모드',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        _ChallengeModeGrid(data: data),
        if (AppEnv.isProduction) ...[
          const SizedBox(height: 18),
          const FutureFeaturesPanel(),
        ],
        if (!data.canPlayChallengeGames) ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.push(RoutePaths.dailySession),
            icon: const Icon(Icons.play_arrow),
            label: const Text('단원 학습 먼저 시작'),
          ),
        ],
      ],
    );
  }
}

class _JoinClassPrompt extends StatelessWidget {
  const _JoinClassPrompt();

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.meeting_room_outlined,
            size: 54,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            '반 랭킹은 반 코드가 필요해요',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '게임은 바로 할 수 있어요.\n선생님이 알려준 반 코드를 붙여넣으면 친구들과 점수를 비교할 수 있어요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () =>
                context.push(RoutePaths.studentLinksFor('student')),
            icon: const Icon(Icons.login),
            label: const Text('반 코드로 참여하기'),
          ),
        ],
      ),
    );
  }
}

class _ChallengeSummaryPanel extends StatelessWidget {
  const _ChallengeSummaryPanel({required this.data});

  final ChallengeSummaryState data;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.isSample ? '우리 반 랭킹' : data.className,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => context.push(RoutePaths.classRanking),
                icon: const Icon(Icons.chevron_right),
                iconAlignment: IconAlignment.end,
                label: const Text('더보기'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _RankingPodium(rows: data.rankingRows),
          const SizedBox(height: 12),
          Row(
            children: [
              _RankingSummaryChip(label: '내 순위', value: data.rankText),
              const SizedBox(width: 10),
              _RankingSummaryChip(label: '오늘 점수', value: '${data.todayScore}점'),
            ],
          ),
          if (!data.canPlayChallengeGames) ...[
            const SizedBox(height: 12),
            Text(
              '도전 게임은 배운 한자 ${data.minLearnedHanjaCount}개부터 열려요. 지금 ${data.learnedHanjaCount}개 배웠어요.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (data.canPlayChallengeGames && !data.canPlayFlipBoard) ...[
            const SizedBox(height: 12),
            Text(
              '판뒤집기는 배운 한자 ${data.flipBoardMinLearnedHanjaCount}개부터 열려요.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RankingPodium extends StatelessWidget {
  const _RankingPodium({required this.rows});

  final List<ClassRankingRow> rows;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 164,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _PodiumCard(rank: 2, row: _rowForRank(2), height: 130),
          const SizedBox(width: 10),
          _PodiumCard(rank: 1, row: _rowForRank(1), height: 156),
          const SizedBox(width: 10),
          _PodiumCard(rank: 3, row: _rowForRank(3), height: 130),
        ],
      ),
    );
  }

  ClassRankingRow? _rowForRank(int rank) {
    for (final row in rows) {
      if (row.rank == rank) {
        return row;
      }
    }
    return null;
  }
}

class _PodiumCard extends StatelessWidget {
  const _PodiumCard({
    required this.rank,
    required this.row,
    required this.height,
  });

  final int rank;
  final ClassRankingRow? row;
  final double height;

  @override
  Widget build(BuildContext context) {
    final entry = row;
    final isMe = entry?.isMe ?? false;
    final medalColor = switch (rank) {
      1 => const Color(0xFFF6B800),
      2 => const Color(0xFF9CA3AF),
      _ => const Color(0xFFC08457),
    };

    return Expanded(
      child: SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isMe ? AppColors.navSelected : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isMe
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: rank == 1 ? 22 : 19,
                  backgroundColor: medalColor,
                  foregroundColor: Colors.white,
                  child: Text(
                    '$rank',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry?.displayName ?? '대기',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry?.scoreText ?? '-',
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
      ),
    );
  }
}

class _RankingSummaryChip extends StatelessWidget {
  const _RankingSummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
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

class _ChallengeModeGrid extends StatelessWidget {
  const _ChallengeModeGrid({required this.data});

  final ChallengeSummaryState data;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _ChallengeModeCard(
          icon: Icons.quiz,
          title: '퀴즈 선택',
          subtitle: data.canPlayChallengeGames
              ? '유형별로 맞혀요'
              : '${data.minLearnedHanjaCount}개부터',
          color: AppColors.peach,
          isEnabled: data.canPlayChallengeGames,
          onTap: () => context.push(RoutePaths.quizModes),
        ),
        _ChallengeModeCard(
          icon: Icons.speed,
          title: '스피드 퀴즈',
          subtitle: data.canPlayChallengeGames
              ? '혼합 문제를 빠르게 풀어요'
              : '${data.minLearnedHanjaCount}개부터',
          color: AppColors.blue,
          isEnabled: data.canPlayChallengeGames,
          onTap: () => context.push(RoutePaths.challengeSpeedGame),
        ),
        _ChallengeModeCard(
          icon: Icons.grid_view,
          title: '솔로 판뒤집기',
          subtitle: data.canPlayFlipBoard ? '30초 / 1분 선택' : '12개부터',
          color: AppColors.green,
          isEnabled: data.canPlayFlipBoard,
          onTap: () async {
            final seconds = await showFlipBoardTimeLimitPicker(
              context,
              title: '솔로 판뒤집기',
              subtitle: '제한시간을 골라서 시작해요',
            );
            if (seconds == null || !context.mounted) {
              return;
            }
            context.push(
              RoutePaths.flipBoardFor(
                FlipBoardPlayMode.drawHanja.routeValue,
                timeLimitSeconds: seconds,
              ),
            );
          },
        ),
        if (AppEnv.showsPreviewFeatures)
          _ChallengeModeCard(
            icon: Icons.leaderboard,
            title: '반 랭킹',
            subtitle: '순위 확인',
            color: AppColors.yellow,
            isEnabled: true,
            onTap: () => context.push(RoutePaths.classRanking),
          ),
      ],
    );
  }
}

class _ChallengeModeCard extends StatelessWidget {
  const _ChallengeModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isEnabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final veryCompact = constraints.maxHeight < 90;
        final compact = constraints.maxHeight < 104;
        return Material(
          color: isEnabled ? color : AppColors.surfaceMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.all(compact ? 8 : 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        icon,
                        size: compact ? 22 : 30,
                        color: isEnabled
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                      const Spacer(),
                      Icon(
                        isEnabled ? Icons.chevron_right : Icons.lock,
                        size: compact ? 18 : 22,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (compact
                                    ? Theme.of(context).textTheme.bodyMedium
                                    : Theme.of(context).textTheme.titleMedium)
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                      if (!veryCompact) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
