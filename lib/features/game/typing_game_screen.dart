import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/app_audio_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';
import '../../core/widgets/success_feedback_popup.dart';
import 'typing_game_controller.dart';

class TypingGameScreen extends ConsumerWidget {
  const TypingGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(typingGameProvider, (previous, next) {
      final previousResult = previous?.value?.savedChallengeResult;
      final nextResult = next.value?.savedChallengeResult;
      if (previousResult == null && nextResult != null) {
        context.go(RoutePaths.resultForChallenge(nextResult.id));
      }
    });
    final state = ref.watch(typingGameProvider);

    return Scaffold(
      body: state.when(
        data: (data) {
          if (!data.canPlay) {
            return _ChallengeLockedView(
              learnedCount: data.learnedHanjaCount,
              minCount: data.minLearnedHanjaCount,
            );
          }
          if (data.rounds.isEmpty) {
            return const Center(child: Text('게임 데이터가 아직 없습니다.'));
          }
          if (data.isComplete) {
            return _GameCompleteView(data: data);
          }
          return _GameRoundView(data: data);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton.icon(
            onPressed: () => ref.invalidate(typingGameProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('게임 다시 불러오기'),
          ),
        ),
      ),
    );
  }
}

class _ChallengeLockedView extends StatelessWidget {
  const _ChallengeLockedView({
    required this.learnedCount,
    required this.minCount,
  });

  final int learnedCount;
  final int minCount;

  @override
  Widget build(BuildContext context) {
    return PlayfulPage(
      title: '스피드 퀴즈',
      subtitle: '배운 한자로 도전해요',
      children: [
        PlayfulPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '배운 한자 $minCount개부터 시작할 수 있어요.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text('지금 $learnedCount개 배웠어요.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go(RoutePaths.appLearn),
                icon: const Icon(Icons.menu_book),
                label: const Text('학습하러 가기'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GameRoundView extends ConsumerStatefulWidget {
  const _GameRoundView({required this.data});

  final TypingGameState data;

  @override
  ConsumerState<_GameRoundView> createState() => _GameRoundViewState();
}

class _GameRoundViewState extends ConsumerState<_GameRoundView> {
  bool _showFeedbackPopup = false;
  bool _isFeedbackSuccess = true;
  bool _isAutoAdvancing = false;

  @override
  void didUpdateWidget(covariant _GameRoundView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.currentIndex != widget.data.currentIndex) {
      _showFeedbackPopup = false;
      _isFeedbackSuccess = true;
      _isAutoAdvancing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final round = data.currentRound!;
    final selectedAnswer = data.selectedAnswer;

    return Stack(
      alignment: Alignment.center,
      children: [
        PlayfulPage(
          title: '스피드 퀴즈',
          subtitle: '문제 ${data.currentIndex + 1}/${data.totalCount}',
          children: [
            _SpeedStatusPanel(data: data),
            const SizedBox(height: 14),
            _SpeedPromptPanel(round: round),
            const SizedBox(height: 14),
            for (final option in round.options) ...[
              _AnswerButton(
                option: option,
                isCorrect: data.isCorrectOption(option),
                isSelected: data.isSelectedOption(option),
                hasSelection: selectedAnswer != null,
                useHanjaFont: round.optionsUseHanjaFont,
                onPressed: () => _selectAnswer(option),
              ),
              const SizedBox(height: 8),
            ],
            if (data.timedOut) ...[
              const SizedBox(height: 8),
              const _RoundFeedbackText(message: '시간이 끝났어요. 다음 라운드로 넘어가요.'),
            ] else if (selectedAnswer != null && data.lastEarnedScore != 0) ...[
              const SizedBox(height: 8),
              _RoundFeedbackText(
                message: data.lastEarnedScore > 0
                    ? '+${data.lastEarnedScore}점'
                    : '${data.lastEarnedScore}점',
                isPositive: data.lastEarnedScore > 0,
              ),
            ],
          ],
        ),
        if (_showFeedbackPopup)
          IgnorePointer(
            child: SuccessFeedbackPopup(isSuccess: _isFeedbackSuccess),
          ),
      ],
    );
  }

  void _selectAnswer(String answer) {
    ref.read(typingGameProvider.notifier).selectAnswer(answer);
    final isCorrect =
        ref.read(typingGameProvider).value?.isSelectedCorrect ?? false;
    setState(() {
      _showFeedbackPopup = true;
      _isFeedbackSuccess = isCorrect;
    });
    if (!isCorrect) {
      _scheduleAutoAdvance();
      return;
    }
    if (_isAutoAdvancing) {
      return;
    }
    ref.read(appAudioControllerProvider).playSuccess();
    _scheduleAutoAdvance();
  }

  void _scheduleAutoAdvance() {
    if (_isAutoAdvancing) {
      return;
    }
    setState(() => _isAutoAdvancing = true);
    Future<void>.delayed(const Duration(milliseconds: 520), () {
      if (!mounted) {
        return;
      }
      setState(() => _showFeedbackPopup = false);
      ref.read(typingGameProvider.notifier).goNextOrSave();
    });
  }
}

class _SpeedStatusPanel extends StatelessWidget {
  const _SpeedStatusPanel({required this.data});

  final TypingGameState data;

  @override
  Widget build(BuildContext context) {
    final timeProgress = data.timeLimit <= 0
        ? 0.0
        : data.remainingSeconds / data.timeLimit;

    return PlayfulPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              _SpeedStatTile(
                icon: Icons.timer_outlined,
                label: '남은 시간',
                value: '${data.remainingSeconds}초',
                color: AppColors.blue,
              ),
              const SizedBox(width: 8),
              _SpeedStatTile(
                icon: Icons.bolt,
                label: '콤보',
                value: '${data.comboCount}',
                color: AppColors.yellow,
              ),
              const SizedBox(width: 8),
              _SpeedStatTile(
                icon: Icons.emoji_events_outlined,
                label: '점수',
                value: '${data.score}',
                color: AppColors.green,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: timeProgress.clamp(0.0, 1.0),
              minHeight: 10,
              color: AppColors.primary,
              backgroundColor: AppColors.border.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedStatTile extends StatelessWidget {
  const _SpeedStatTile({
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
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            children: [
              Icon(icon, size: 20, color: AppColors.textPrimary),
              const SizedBox(height: 4),
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
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
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

class _SpeedPromptPanel extends StatelessWidget {
  const _SpeedPromptPanel({required this.round});

  final TypingGameRound round;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        children: [
          Text(
            round.prompt,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontFamily: round.promptUsesHanjaFont
                  ? AppFonts.hanjaSerif
                  : null,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            round.optionsUseHanjaFont ? '맞는 한자를 골라요' : '맞는 훈음을 골라요',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundFeedbackText extends StatelessWidget {
  const _RoundFeedbackText({required this.message, this.isPositive = false});

  final String message;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: isPositive ? const Color(0xFF166534) : AppColors.primary,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.option,
    required this.isCorrect,
    required this.isSelected,
    required this.hasSelection,
    required this.useHanjaFont,
    required this.onPressed,
  });

  final String option;
  final bool isCorrect;
  final bool isSelected;
  final bool hasSelection;
  final bool useHanjaFont;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isSelectedCorrect = isSelected && isCorrect;
    final backgroundColor = !hasSelection
        ? AppColors.surface
        : isSelectedCorrect
        ? AppColors.green
        : isSelected
        ? AppColors.peach
        : AppColors.surfaceMuted;
    final borderColor = !hasSelection
        ? AppColors.border
        : isSelected
        ? AppColors.primary.withValues(alpha: 0.45)
        : AppColors.border;

    return FilledButton(
      onPressed: hasSelection
          ? () => _showSnack(context, '이미 답을 골랐어요.')
          : onPressed,
      style: FilledButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        backgroundColor: backgroundColor,
        minimumSize: const Size.fromHeight(64),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Row(
        children: [
          if (hasSelection) const SizedBox(width: 24),
          Expanded(
            child: Text(
              option,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: useHanjaFont ? AppFonts.hanjaSerif : null,
                fontSize: useHanjaFont ? 30 : 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.1,
              ),
            ),
          ),
          if (hasSelection)
            Icon(
              isSelected
                  ? isCorrect
                        ? Icons.check_circle
                        : Icons.cancel
                  : Icons.circle_outlined,
              color: isSelected
                  ? isCorrect
                        ? const Color(0xFF166534)
                        : AppColors.primary
                  : AppColors.textMuted,
              size: 24,
            ),
        ],
      ),
    );
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}

class _GameCompleteView extends StatelessWidget {
  const _GameCompleteView({required this.data});

  final TypingGameState data;

  @override
  Widget build(BuildContext context) {
    final result = data.savedResult!;

    return PlayfulPage(
      title: '스피드 퀴즈 완료',
      subtitle: '속도 도전 보상을 확인해요',
      children: [
        PlayfulPanel(
          child: Column(
            children: [
              Text(
                '스피드 퀴즈',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
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
                    icon: Icons.star,
                    label: '점수',
                    value: '${result.score}',
                    color: AppColors.green,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  PlayfulStat(
                    icon: Icons.bolt,
                    label: '최고 콤보',
                    value: '${data.bestCombo}',
                    color: AppColors.blue,
                  ),
                  const SizedBox(width: 10),
                  PlayfulStat(
                    icon: Icons.timer,
                    label: '시간',
                    value: '${result.timeSec}초',
                    color: AppColors.peach,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  PlayfulStat(
                    icon: Icons.percent,
                    label: '정답률',
                    value: '${data.accuracyPercent}%',
                    color: AppColors.mint,
                  ),
                  const SizedBox(width: 10),
                  PlayfulStat(
                    icon: Icons.grade,
                    label: '별점',
                    value: data.stars == 0
                        ? '별 없음'
                        : List.filled(data.stars, '★').join(),
                    color: AppColors.lavender,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  PlayfulStat(
                    icon: Icons.local_fire_department,
                    label: '획득 XP',
                    value: '${data.savedChallengeResult?.earnedXp ?? 0}',
                    color: AppColors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (data.latestResult != null) ...[
          const SizedBox(height: 24),
          Text(
            '이전 기록 ${data.latestResult!.correctCount}/${data.latestResult!.totalCount}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => data.savedChallengeResult == null
              ? context.go(RoutePaths.appChallenge)
              : context.go(
                  RoutePaths.resultForChallenge(data.savedChallengeResult!.id),
                ),
          icon: const Icon(Icons.emoji_events),
          label: Text(data.savedChallengeResult == null ? '도전으로' : '결과 보기'),
        ),
      ],
    );
  }
}
