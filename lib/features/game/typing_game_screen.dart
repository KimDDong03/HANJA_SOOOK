import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/app_audio_controller.dart';
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
      title: '뜻 보고 한자 선택',
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
          title: '뜻 보고 한자 선택',
          subtitle: '라운드 ${data.currentIndex + 1}/${data.totalCount}',
          children: [
            LinearProgressIndicator(
              value: (data.currentIndex + 1) / data.totalCount,
              minHeight: 12,
              borderRadius: BorderRadius.circular(99),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 12,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: [
                  Text(
                    '남은 시간 ${data.remainingSeconds}초',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '콤보 ${data.comboCount}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '점수 ${data.score}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PlayfulPanel(
              color: const Color(0xFFD9F99D),
              child: Column(
                children: [
                  Text(
                    round.prompt,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '빠르게 고를수록 콤보 점수가 올라가요.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final option in round.options) ...[
              _AnswerButton(
                option: option,
                isCorrect: data.isCorrectOption(option),
                isSelected: data.isSelectedOption(option),
                hasSelection: selectedAnswer != null,
                onPressed: () => _selectAnswer(option),
              ),
              const SizedBox(height: 8),
            ],
            if (data.timedOut) ...[
              const SizedBox(height: 8),
              Text(
                '시간이 끝났어요. 다음 라운드로 넘어가요.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ] else if (selectedAnswer != null && data.lastEarnedScore > 0) ...[
              const SizedBox(height: 8),
              Text(
                '+${data.lastEarnedScore}점',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: selectedAnswer == null
                  ? () => _showSnack(context, '답을 먼저 골라주세요.')
                  : data.isSelectedCorrect
                  ? null
                  : ref.read(typingGameProvider.notifier).goNextOrSave,
              icon: Icon(data.isLastRound ? Icons.emoji_events : Icons.gamepad),
              label: Text(
                data.isSelectedCorrect
                    ? '다음으로 이동 중'
                    : data.isLastRound
                    ? '결과 저장'
                    : '다음 라운드',
              ),
            ),
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
      Future<void>.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) {
          return;
        }
        setState(() => _showFeedbackPopup = false);
      });
      return;
    }
    if (_isAutoAdvancing) {
      return;
    }
    setState(() => _isAutoAdvancing = true);
    ref.read(appAudioControllerProvider).playSuccess();
    Future<void>.delayed(const Duration(milliseconds: 620), () {
      if (!mounted) {
        return;
      }
      ref.read(typingGameProvider.notifier).goNextOrSave();
    });
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.option,
    required this.isCorrect,
    required this.isSelected,
    required this.hasSelection,
    required this.onPressed,
  });

  final String option;
  final bool isCorrect;
  final bool isSelected;
  final bool hasSelection;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: hasSelection
          ? () => _showSnack(context, '이미 답을 골랐어요.')
          : onPressed,
      style: FilledButton.styleFrom(
        foregroundColor: const Color(0xFF10201A),
        minimumSize: const Size.fromHeight(72),
        backgroundColor: !hasSelection
            ? null
            : isCorrect
            ? Theme.of(context).colorScheme.primaryContainer
            : isSelected
            ? Theme.of(context).colorScheme.errorContainer
            : null,
      ),
      child: Text(
        option,
        style: const TextStyle(
          fontFamily: AppFonts.hanjaSerif,
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: Color(0xFF10201A),
          height: 1,
        ),
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
      title: '게임 완료',
      subtitle: '속도 도전 보상을 확인해요',
      showMascot: true,
      children: [
        PlayfulPanel(
          color: const Color(0xFFD9F99D),
          child: Column(
            children: [
              Text(
                '${result.correctCount}/${result.totalCount}',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text('점수 ${result.score}'),
              const SizedBox(height: 8),
              Text(
                '정답률 ${data.accuracyPercent}% · 별 ${List.filled(data.stars, '★').join()}',
              ),
              const SizedBox(height: 8),
              Text('최고 콤보 ${data.bestCombo}'),
              const SizedBox(height: 8),
              Text('획득 XP ${data.savedChallengeResult?.earnedXp ?? 0}'),
              const SizedBox(height: 8),
              Text('걸린 시간 ${result.timeSec}초'),
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
