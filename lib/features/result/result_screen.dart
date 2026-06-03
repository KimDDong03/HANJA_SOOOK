import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/app_audio_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';
import '../../domain/models/challenge_result.dart';
import 'result_controller.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({
    super.key,
    required this.hanjaId,
    required this.challengeResultId,
    required this.earnedXp,
    required this.completedCount,
    required this.totalCount,
    this.writingPassed,
    this.writingScore,
    this.writingAccuracy,
    this.writingStars,
    this.writingTimeSec,
  });

  final String? hanjaId;
  final String? challengeResultId;
  final int? earnedXp;
  final int? completedCount;
  final int? totalCount;
  final bool? writingPassed;
  final int? writingScore;
  final int? writingAccuracy;
  final int? writingStars;
  final int? writingTimeSec;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(appAudioControllerProvider).playSuccess());
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ResultArgs(
      hanjaId: widget.hanjaId,
      earnedXp: widget.earnedXp,
      completedCount: widget.completedCount,
      totalCount: widget.totalCount,
      challengeResultId: widget.challengeResultId,
      writingPassed: widget.writingPassed,
      writingScore: widget.writingScore,
      writingAccuracy: widget.writingAccuracy,
      writingStars: widget.writingStars,
      writingTimeSec: widget.writingTimeSec,
    );
    final state = ref.watch(resultProvider(args));

    return Scaffold(
      body: state.when(
        data: (data) => data.isMissingChallengeResult
            ? _MissingResultView(
                onRetry: () => ref.invalidate(resultProvider(args)),
              )
            : PlayfulPage(
                title: data.isChallengeResult
                    ? '${_challengeTitle(data.challengeResult!.mode)} 완료'
                    : data.isDailyComplete
                    ? '오늘 학습 완료'
                    : '연습 완료',
                subtitle: data.isChallengeResult
                    ? '점수와 랭킹 변화를 확인해요'
                    : '모은 별과 XP를 확인해요',
                children: [
                  if (data.completedHanja != null) ...[
                    PlayfulPanel(
                      child: Column(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 120,
                              child: Center(
                                child: Text(
                                  data.completedHanja!.character,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontFamily: AppFonts.hanjaSerif,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.completedHanja!.meaning,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (data.challengeResult != null) ...[
                    _ChallengeResultPanel(data: data),
                    const SizedBox(height: 16),
                    PlayfulPanel(
                      child: Row(
                        children: [
                          PlayfulStat(
                            icon: Icons.bolt,
                            label: '획득 XP',
                            value: '${data.challengeResult!.earnedXp}',
                            color: AppColors.yellow,
                          ),
                          const SizedBox(width: 10),
                          const PlayfulStat(
                            icon: Icons.leaderboard,
                            label: '랭킹 반영',
                            value: '완료',
                            color: AppColors.green,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    PlayfulPanel(
                      child: Column(
                        children: [
                          if (data.writingResultLabel != null) ...[
                            Text(
                              data.writingResultLabel!,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            '오늘의 한자 ${data.completedCount}/${data.totalCount}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '+${data.earnedXp} XP',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (data.hasWritingMetrics) ...[
                      const SizedBox(height: 16),
                      _WritingResultPanel(data: data),
                    ],
                  ],
                  const SizedBox(height: 16),
                  if (data.challengeResult != null) ...[
                    FilledButton.icon(
                      onPressed: () =>
                          context.go(_retryRoute(data.challengeResult!)),
                      icon: const Icon(Icons.replay),
                      label: const Text('다시 도전'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.go(RoutePaths.classRanking),
                      icon: const Icon(Icons.leaderboard),
                      label: const Text('랭킹 보기'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.go(RoutePaths.appChallenge),
                      icon: const Icon(Icons.emoji_events),
                      label: const Text('도전으로'),
                    ),
                  ] else ...[
                    if (data.nextHanja != null)
                      FilledButton.icon(
                        onPressed: () => context.push(
                          RoutePaths.guidedWriting(data.nextHanja!.id),
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('다음 한자 학습'),
                      )
                    else
                      FilledButton.icon(
                        onPressed: () => context.go(RoutePaths.home),
                        icon: const Icon(Icons.home),
                        label: const Text('홈으로'),
                      ),
                    if (data.nextHanja != null) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.go(RoutePaths.home),
                        icon: const Icon(Icons.home),
                        label: const Text('홈으로'),
                      ),
                    ],
                  ],
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _ResultLoadError(
          onRetry: () => ref.invalidate(resultProvider(args)),
        ),
      ),
    );
  }
}

class _ChallengeResultPanel extends StatelessWidget {
  const _ChallengeResultPanel({required this.data});

  final ResultState data;

  @override
  Widget build(BuildContext context) {
    final result = data.challengeResult!;

    return PlayfulPanel(
      child: Column(
        children: [
          Text(
            _challengeTitle(result.mode),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (result.mode == ChallengeMode.flipBoard)
            Row(
              children: [
                PlayfulStat(
                  icon: Icons.grid_view,
                  label: '뒤집은 판',
                  value: '${result.flippedTileCount}',
                  color: AppColors.yellow,
                ),
                const SizedBox(width: 10),
                PlayfulStat(
                  icon: Icons.star,
                  label: '점수',
                  value: '${result.score}',
                  color: AppColors.green,
                ),
              ],
            )
          else
            Row(
              children: [
                PlayfulStat(
                  icon: Icons.check,
                  label: '정답',
                  value: '${result.correctCount}/${result.totalCount}',
                  color: AppColors.yellow,
                ),
                const SizedBox(width: 10),
                PlayfulStat(
                  icon: Icons.percent,
                  label: '정답률',
                  value: '${data.challengeAccuracyPercent}%',
                  color: AppColors.green,
                ),
              ],
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              PlayfulStat(
                icon: Icons.timer,
                label: '소요 시간',
                value: '${result.timeSec}초',
                color: AppColors.blue,
              ),
              const SizedBox(width: 10),
              PlayfulStat(
                icon: Icons.star,
                label: '별점',
                value: data.starsText,
                color: AppColors.peach,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WritingResultPanel extends StatelessWidget {
  const _WritingResultPanel({required this.data});

  final ResultState data;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      child: Column(
        children: [
          Row(
            children: [
              PlayfulStat(
                icon: Icons.star,
                label: '점수',
                value: data.writingScore == null ? '-' : '${data.writingScore}',
                color: AppColors.yellow,
              ),
              const SizedBox(width: 10),
              PlayfulStat(
                icon: Icons.percent,
                label: '정확도',
                value: data.writingAccuracyPercent == null
                    ? '-'
                    : '${data.writingAccuracyPercent}%',
                color: AppColors.green,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              PlayfulStat(
                icon: Icons.timer,
                label: '소요 시간',
                value: data.writingTimeSec == null
                    ? '-'
                    : '${data.writingTimeSec}초',
                color: AppColors.blue,
              ),
              const SizedBox(width: 10),
              PlayfulStat(
                icon: Icons.auto_awesome,
                label: '별점',
                value: data.writingStarsText,
                color: AppColors.peach,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MissingResultView extends StatelessWidget {
  const _MissingResultView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return PlayfulPage(
      title: '결과를 찾지 못했어요',
      subtitle: '저장된 도전 결과를 다시 불러와요',
      children: [
        PlayfulPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('결과 저장이 아직 끝나지 않았거나 기록을 찾을 수 없어요.'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 불러오기'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultLoadError extends StatelessWidget {
  const _ResultLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('결과 다시 불러오기'),
      ),
    );
  }
}

String _challengeTitle(ChallengeMode mode) {
  return switch (mode) {
    ChallengeMode.quizHanjaToHun => '한자 보고 훈음',
    ChallengeMode.quizHunToHanja => '훈음 보고 한자',
    ChallengeMode.quizMixed => '혼합 퀴즈',
    ChallengeMode.speedChoice => '스피드 퀴즈',
    ChallengeMode.flipBoard => '판뒤집기',
  };
}

String _retryRoute(ChallengeResult result) {
  return switch (result.mode) {
    ChallengeMode.quizHanjaToHun => RoutePaths.quizPlayFor('hanja-to-hun'),
    ChallengeMode.quizHunToHanja => RoutePaths.quizPlayFor('hun-to-hanja'),
    ChallengeMode.quizMixed => RoutePaths.quizPlayFor('mixed'),
    ChallengeMode.speedChoice => RoutePaths.challengeSpeedGame,
    ChallengeMode.flipBoard => RoutePaths.flipBoard,
  };
}
