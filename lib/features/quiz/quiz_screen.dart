import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/app_audio_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';
import '../../core/widgets/success_feedback_popup.dart';
import '../../domain/models/quiz_question.dart';
import 'quiz_controller.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key, required this.mode});

  final QuizPlayMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(quizProvider(mode), (previous, next) {
      final previousResult = previous?.value?.savedChallengeResult;
      final nextResult = next.value?.savedChallengeResult;
      if (previousResult == null && nextResult != null) {
        context.go(RoutePaths.resultForChallenge(nextResult.id));
      }
    });
    final state = ref.watch(quizProvider(mode));

    return Scaffold(
      body: state.when(
        data: (data) {
          if (!data.canPlay) {
            return _ChallengeLockedView(
              mode: data.mode,
              learnedCount: data.learnedHanjaCount,
              minCount: data.minLearnedHanjaCount,
            );
          }
          if (data.questions.isEmpty) {
            return const Center(child: Text('퀴즈 데이터가 아직 없습니다.'));
          }
          if (data.isComplete) {
            return _QuizCompleteView(data: data);
          }
          return _QuizQuestionView(data: data);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton.icon(
            onPressed: () => ref.invalidate(quizProvider(mode)),
            icon: const Icon(Icons.refresh),
            label: const Text('퀴즈 다시 불러오기'),
          ),
        ),
      ),
    );
  }
}

class _ChallengeLockedView extends StatelessWidget {
  const _ChallengeLockedView({
    required this.mode,
    required this.learnedCount,
    required this.minCount,
  });

  final QuizPlayMode mode;
  final int learnedCount;
  final int minCount;

  @override
  Widget build(BuildContext context) {
    return PlayfulPage(
      title: mode.label,
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

class _QuizQuestionView extends ConsumerStatefulWidget {
  const _QuizQuestionView({required this.data});

  final QuizState data;

  @override
  ConsumerState<_QuizQuestionView> createState() => _QuizQuestionViewState();
}

class _QuizQuestionViewState extends ConsumerState<_QuizQuestionView> {
  bool _showFeedbackPopup = false;
  bool _isFeedbackSuccess = true;

  @override
  void didUpdateWidget(covariant _QuizQuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.mode != widget.data.mode ||
        oldWidget.data.currentIndex != widget.data.currentIndex) {
      _showFeedbackPopup = false;
      _isFeedbackSuccess = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final question = data.currentQuestion!;
    final selectedAnswer = data.selectedAnswer;

    return Stack(
      alignment: Alignment.center,
      children: [
        PlayfulPage(
          title: data.mode.label,
          subtitle: '문제 ${data.currentIndex + 1}/${data.totalCount}',
          children: [
            LinearProgressIndicator(
              value: (data.currentIndex + 1) / data.totalCount,
              minHeight: 12,
              color: AppColors.primary,
              backgroundColor: AppColors.border.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(99),
            ),
            const SizedBox(height: 16),
            PlayfulPanel(
              child: Text(
                question.prompt,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (final option in question.options) ...[
              _AnswerButton(
                option: option,
                useHanjaFont: question.type == QuizQuestionType.hanjaChoice,
                isCorrect: data.isCorrectOption(option),
                isSelected: data.isSelectedOption(option),
                hasSelection: selectedAnswer != null,
                onPressed: () => _selectAnswer(option),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: selectedAnswer == null
                  ? null
                  : ref.read(quizProvider(data.mode).notifier).goNextOrSave,
              icon: Icon(data.isLastQuestion ? Icons.emoji_events : Icons.bolt),
              label: Text(data.isLastQuestion ? '결과 저장' : '다음 문제'),
            ),
            if (selectedAnswer != null && question.explanation != null) ...[
              const SizedBox(height: 8),
              Text(
                question.explanation!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
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
    final provider = quizProvider(widget.data.mode);
    ref.read(provider.notifier).selectAnswer(answer);
    final isCorrect = ref.read(provider).value?.isSelectedCorrect ?? false;
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
    ref.read(appAudioControllerProvider).playSuccess();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      setState(() => _showFeedbackPopup = false);
    });
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.option,
    required this.useHanjaFont,
    required this.isCorrect,
    required this.isSelected,
    required this.hasSelection,
    required this.onPressed,
  });

  final String option;
  final bool useHanjaFont;
  final bool isCorrect;
  final bool isSelected;
  final bool hasSelection;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = !hasSelection
        ? AppColors.surface
        : isCorrect
        ? AppColors.green
        : isSelected
        ? AppColors.peach
        : AppColors.surfaceMuted;
    final borderColor = !hasSelection
        ? AppColors.border
        : isSelected || isCorrect
        ? AppColors.primary.withValues(alpha: 0.45)
        : AppColors.border;

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: hasSelection
            ? () => _showSnack(context, '이미 답을 골랐어요. 다음 문제로 넘어가요.')
            : onPressed,
        borderRadius: BorderRadius.circular(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                if (hasSelection) const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    option,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: useHanjaFont ? AppFonts.hanjaSerif : null,
                      fontSize: useHanjaFont ? 28 : 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                ),
                if (hasSelection)
                  Icon(
                    isCorrect
                        ? Icons.check_circle
                        : isSelected
                        ? Icons.cancel
                        : Icons.circle_outlined,
                    color: isCorrect
                        ? const Color(0xFF166534)
                        : isSelected
                        ? AppColors.primary
                        : AppColors.textMuted,
                    size: 24,
                  ),
              ],
            ),
          ),
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

class _QuizCompleteView extends StatelessWidget {
  const _QuizCompleteView({required this.data});

  final QuizState data;

  @override
  Widget build(BuildContext context) {
    final result = data.savedResult!;

    return PlayfulPage(
      title: '퀴즈 완료',
      subtitle: '${data.mode.label} 보상을 확인해요',
      children: [
        PlayfulPanel(
          child: Column(
            children: [
              Text(
                data.mode.label,
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
                    label: '획득 XP',
                    value: '${data.savedChallengeResult?.earnedXp ?? 0}',
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
          icon: const Icon(Icons.home),
          label: Text(data.savedChallengeResult == null ? '도전으로' : '결과 보기'),
        ),
      ],
    );
  }
}
