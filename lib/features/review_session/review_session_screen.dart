import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/app_audio_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';
import '../../core/widgets/success_feedback_popup.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/services/free_writing_score_service.dart';
import '../../domain/services/svg_path_parser.dart';
import '../learning/session_reward_panel.dart';
import '../writing/widgets/hanja_free_writing_canvas.dart';
import 'review_session_controller.dart';

class ReviewSessionScreen extends ConsumerWidget {
  const ReviewSessionScreen({super.key, this.focusHanjaId});

  final String? focusHanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(reviewSessionProvider(focusHanjaId));
    return Scaffold(
      body: session.when(
        data: (state) {
          if (state.items.isEmpty) {
            return PlayfulPage(
              title: '복습',
              subtitle: '오늘 복습할 한자가 없어요',
              children: [
                PlayfulPanel(
                  child: FilledButton.icon(
                    onPressed: () => context.go(RoutePaths.appLearn),
                    icon: const Icon(Icons.menu_book),
                    label: const Text('학습으로'),
                  ),
                ),
              ],
            );
          }
          return PlayfulPage(
            title: '복습',
            subtitle: _subtitleFor(state),
            trailing: _CountBadge(count: state.items.length),
            children: [_bodyFor(context, ref, state, focusHanjaId)],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton.icon(
            onPressed: () =>
                ref.invalidate(reviewSessionProvider(focusHanjaId)),
            icon: const Icon(Icons.refresh),
            label: const Text('복습 다시 불러오기'),
          ),
        ),
      ),
    );
  }

  String _subtitleFor(ReviewSessionState state) {
    return switch (state.phase) {
      ReviewSessionPhase.quiz =>
        '${state.index + 1}/${state.quizQuestions.length} · 섞어서 복습',
      ReviewSessionPhase.writing =>
        '${state.index + 1}/${state.writingItems.length} · 직접 써보기',
      ReviewSessionPhase.correction => '아직 헷갈린 한자 확인',
      ReviewSessionPhase.retry =>
        '${state.index + 1}/${state.retryQuestions.length} · 다시 확인',
      ReviewSessionPhase.complete => '복습 완료',
    };
  }

  Widget _bodyFor(
    BuildContext context,
    WidgetRef ref,
    ReviewSessionState state,
    String? focusHanjaId,
  ) {
    return switch (state.phase) {
      ReviewSessionPhase.quiz => _QuestionStep(
        state: state,
        focusHanjaId: focusHanjaId,
      ),
      ReviewSessionPhase.writing => _WritingStep(
        state: state,
        focusHanjaId: focusHanjaId,
      ),
      ReviewSessionPhase.correction => _CorrectionStep(
        state: state,
        focusHanjaId: focusHanjaId,
      ),
      ReviewSessionPhase.retry => _RetryStep(
        state: state,
        focusHanjaId: focusHanjaId,
      ),
      ReviewSessionPhase.complete => _CompleteStep(
        state: state,
        focusHanjaId: focusHanjaId,
      ),
    };
  }
}

class _QuestionStep extends ConsumerStatefulWidget {
  const _QuestionStep({required this.state, required this.focusHanjaId});

  final ReviewSessionState state;
  final String? focusHanjaId;

  @override
  ConsumerState<_QuestionStep> createState() => _QuestionStepState();
}

class _QuestionStepState extends ConsumerState<_QuestionStep> {
  bool _showFeedbackPopup = false;
  bool _isFeedbackSuccess = true;

  @override
  void didUpdateWidget(covariant _QuestionStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentQuestion?.key !=
        widget.state.currentQuestion?.key) {
      _showFeedbackPopup = false;
      _isFeedbackSuccess = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.state.currentQuestion!;
    final selected = widget.state.selectedAnswer;
    final isCorrect = selected == question.correctAnswer;
    return Stack(
      alignment: Alignment.center,
      children: [
        PlayfulPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PromptText(
                text: question.prompt,
                useHanjaFont: question.activityType.name == 'hanjaToHun',
              ),
              const SizedBox(height: 16),
              for (final option in question.options) ...[
                _AnswerButton(
                  label: option,
                  selected: selected == option,
                  correct: option == question.correctAnswer,
                  hasSelection: selected != null,
                  onPressed: () => _selectAnswer(question, option),
                ),
                const SizedBox(height: 8),
              ],
              if (selected != null) ...[
                const SizedBox(height: 2),
                _AnswerFeedbackText(
                  isCorrect: isCorrect,
                  correctAnswer: question.correctAnswer,
                ),
              ],
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: selected == null
                    ? null
                    : ref
                          .read(
                            reviewSessionProvider(widget.focusHanjaId).notifier,
                          )
                          .next,
                icon: const Icon(Icons.chevron_right),
                label: const Text('다음'),
              ),
            ],
          ),
        ),
        if (_showFeedbackPopup)
          IgnorePointer(
            child: SuccessFeedbackPopup(
              message: _isFeedbackSuccess ? '정답이에요!' : '다시 확인해요',
              isSuccess: _isFeedbackSuccess,
            ),
          ),
      ],
    );
  }

  Future<void> _selectAnswer(ReviewQuestion question, String answer) async {
    final provider = reviewSessionProvider(widget.focusHanjaId);
    await ref.read(provider.notifier).selectAnswer(answer);
    final isCorrect = answer == question.correctAnswer;
    if (!mounted) {
      return;
    }
    setState(() {
      _showFeedbackPopup = true;
      _isFeedbackSuccess = isCorrect;
    });
    if (isCorrect) {
      ref.read(appAudioControllerProvider).playSuccess();
    }
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      setState(() => _showFeedbackPopup = false);
    });
  }
}

class _RetryStep extends ConsumerStatefulWidget {
  const _RetryStep({required this.state, required this.focusHanjaId});

  final ReviewSessionState state;
  final String? focusHanjaId;

  @override
  ConsumerState<_RetryStep> createState() => _RetryStepState();
}

class _RetryStepState extends ConsumerState<_RetryStep> {
  bool _showFeedbackPopup = false;
  bool _isFeedbackSuccess = true;

  @override
  void didUpdateWidget(covariant _RetryStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentRetryQuestion?.key !=
        widget.state.currentRetryQuestion?.key) {
      _showFeedbackPopup = false;
      _isFeedbackSuccess = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.state.currentRetryQuestion!;
    final selected = widget.state.selectedAnswer;
    final isCorrect = selected == question.correctAnswer;
    return Stack(
      alignment: Alignment.center,
      children: [
        PlayfulPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PromptText(text: question.prompt),
              const SizedBox(height: 16),
              for (final option in question.options) ...[
                _AnswerButton(
                  label: option,
                  selected: selected == option,
                  correct: option == question.correctAnswer,
                  hasSelection: selected != null,
                  onPressed: () => _selectAnswer(question, option),
                ),
                const SizedBox(height: 8),
              ],
              if (selected != null) ...[
                const SizedBox(height: 2),
                _AnswerFeedbackText(
                  isCorrect: isCorrect,
                  correctAnswer: question.correctAnswer,
                ),
              ],
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: selected == null
                    ? null
                    : () => ref
                          .read(
                            reviewSessionProvider(widget.focusHanjaId).notifier,
                          )
                          .nextRetryOrFinish(),
                icon: const Icon(Icons.check),
                label: Text(
                  widget.state.index >= widget.state.retryQuestions.length - 1
                      ? '완료'
                      : '다음',
                ),
              ),
            ],
          ),
        ),
        if (_showFeedbackPopup)
          IgnorePointer(
            child: SuccessFeedbackPopup(
              message: _isFeedbackSuccess ? '정답이에요!' : '다시 확인해요',
              isSuccess: _isFeedbackSuccess,
            ),
          ),
      ],
    );
  }

  Future<void> _selectAnswer(ReviewQuestion question, String answer) async {
    final provider = reviewSessionProvider(widget.focusHanjaId);
    await ref.read(provider.notifier).selectRetryAnswer(answer);
    final isCorrect = answer == question.correctAnswer;
    if (!mounted) {
      return;
    }
    setState(() {
      _showFeedbackPopup = true;
      _isFeedbackSuccess = isCorrect;
    });
    if (isCorrect) {
      ref.read(appAudioControllerProvider).playSuccess();
    }
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      setState(() => _showFeedbackPopup = false);
    });
  }
}

class _WritingStep extends ConsumerStatefulWidget {
  const _WritingStep({required this.state, required this.focusHanjaId});

  final ReviewSessionState state;
  final String? focusHanjaId;

  @override
  ConsumerState<_WritingStep> createState() => _WritingStepState();
}

class _WritingStepState extends ConsumerState<_WritingStep> {
  bool _hasStrokes = false;
  bool _showSuccessPopup = false;
  List<Path> _strokes = const [];
  FreeWritingScoreResult? _scoreResult;

  @override
  void initState() {
    super.initState();
    _restoreSavedStrokes();
  }

  @override
  void didUpdateWidget(covariant _WritingStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentWritingItem?.id !=
            widget.state.currentWritingItem?.id ||
        oldWidget.state.index != widget.state.index) {
      _showSuccessPopup = false;
      _scoreResult = null;
      _restoreSavedStrokes();
    }
  }

  void _restoreSavedStrokes() {
    final item = widget.state.currentWritingItem;
    final savedStrokes = item == null
        ? const <Path>[]
        : widget.state.writingStrokesFor(item.id);
    _strokes = savedStrokes;
    _hasStrokes = savedStrokes.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.state.currentWritingItem!;
    final hintLevel = widget.state.hintLevelFor(item.id);
    final provider = reviewSessionProvider(widget.focusHanjaId);
    final svgPaths = widget.state.svgPathsFor(item.id);
    final strokeOrderPaths = _expectedPaths(svgPaths);
    final scoreResult = _scoreResult;
    final passed = scoreResult?.passed == true;
    final showsFailure = scoreResult != null && !scoreResult.passed;
    return Stack(
      alignment: Alignment.center,
      children: [
        PlayfulPanel(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WritingPromptHeader(item: item),
              const SizedBox(height: 10),
              HanjaFreeWritingCanvas(
                key: ValueKey('review-writing-${item.id}-$hintLevel'),
                expectedStrokeCount: item.strokeCount,
                canvasExtent: 286,
                showTitle: false,
                initialStrokes: widget.state.writingStrokesFor(item.id),
                failedStrokeIndex: scoreResult?.failedStrokeIndex,
                expectedHintPath:
                    scoreResult?.expectedHintPath ??
                    (hintLevel == 1 ? _firstHintPath(strokeOrderPaths) : null),
                strokeOrderPreviewPaths: strokeOrderPaths,
                strokeOrderPreviewRequest: hintLevel >= 2 ? hintLevel : 0,
                onStrokeTexture: () =>
                    ref.read(appAudioControllerProvider).playStrokeTexture(),
                onStrokeTextureStop: () =>
                    ref.read(appAudioControllerProvider).stopStrokeTexture(),
                onStrokesChanged: (strokes) {
                  ref
                      .read(provider.notifier)
                      .saveWritingStrokes(hanjaId: item.id, strokes: strokes);
                  setState(() {
                    _strokes = strokes;
                    _hasStrokes = strokes.isNotEmpty;
                    _showSuccessPopup = false;
                    _scoreResult = null;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                _hintTextFor(hintLevel, item),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (showsFailure) ...[
                const SizedBox(height: 8),
                _ReviewWritingFeedbackPanel(result: scoreResult),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: hintLevel >= 3
                          ? null
                          : ref.read(provider.notifier).recordWritingHint,
                      icon: const Icon(Icons.lightbulb),
                      label: Text(hintLevel == 0 ? '첫 획 힌트' : '힌트 더 보기'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: passed
                          ? ref.read(provider.notifier).completeWriting
                          : _hasStrokes
                          ? _checkWriting
                          : null,
                      icon: Icon(passed ? Icons.chevron_right : Icons.check),
                      label: Text(passed ? _nextWritingLabel() : '확인하기'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_showSuccessPopup)
          const IgnorePointer(child: SuccessFeedbackPopup(message: '정답이에요!')),
      ],
    );
  }

  Future<void> _checkWriting() async {
    final item = widget.state.currentWritingItem!;
    final result = ref
        .read(freeWritingScoreServiceProvider)
        .score(
          userStrokes: _strokes,
          expectedSvgPaths: widget.state.svgPathsFor(item.id),
          expectedStrokeCount: item.strokeCount,
        );
    setState(() {
      _scoreResult = result;
      _showSuccessPopup = result.passed;
    });
    if (!result.passed) {
      await ref
          .read(reviewSessionProvider(widget.focusHanjaId).notifier)
          .recordWritingFailure();
      return;
    }
    ref
        .read(reviewSessionProvider(widget.focusHanjaId).notifier)
        .markWritingPassed(item.id);
    ref.read(appAudioControllerProvider).playSuccess();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      setState(() => _showSuccessPopup = false);
    });
  }

  String _nextWritingLabel() {
    final state = widget.state;
    return state.index >= state.writingItems.length - 1 ? '마무리' : '다음 쓰기';
  }

  String _hintTextFor(int hintLevel, HanjaCharacter item) {
    return switch (hintLevel) {
      0 => '기억나는 대로 먼저 써봐요.',
      1 => '표시된 첫 획부터 천천히 시작해요.',
      2 => '획순을 보고 빈칸에 다시 써요.',
      _ => '${item.meaning} · 획순을 다시 확인해요.',
    };
  }
}

class _ReviewWritingFeedbackPanel extends StatelessWidget {
  const _ReviewWritingFeedbackPanel({required this.result});

  final FreeWritingScoreResult result;

  @override
  Widget build(BuildContext context) {
    final isPassed = result.passed;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isPassed
            ? AppColors.green.withValues(alpha: 0.2)
            : AppColors.peach.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              isPassed ? Icons.check_circle : Icons.refresh,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isPassed
                    ? '맞았어요! ${result.message}'
                    : result.failureMessage ?? '틀렸어요! 다시 써보세요.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Path? _firstHintPath(List<Path> paths) {
  return paths.isEmpty ? null : paths.first;
}

List<Path> _expectedPaths(List<String> svgPaths) {
  final paths = <Path>[];
  for (final pathData in svgPaths) {
    final path = SvgPathParser.tryParse(pathData);
    if (path != null) {
      paths.add(path);
    }
  }
  return paths;
}

class _CorrectionStep extends ConsumerWidget {
  const _CorrectionStep({required this.state, required this.focusHanjaId});

  final ReviewSessionState state;
  final String? focusHanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in state.unresolvedMissedItems) ...[
            _HanjaHeader(item: item),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: ref
                .read(reviewSessionProvider(focusHanjaId).notifier)
                .startRetryOrComplete,
            icon: const Icon(Icons.refresh),
            label: const Text('틀린 한자 다시 확인'),
          ),
        ],
      ),
    );
  }
}

class _CompleteStep extends ConsumerWidget {
  const _CompleteStep({required this.state, required this.focusHanjaId});

  final ReviewSessionState state;
  final String? focusHanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstTrySuccessCount =
        state.items.length - state.missedHanjaIds.length;
    return SessionRewardPanel(
      icon: Icons.check_circle,
      title: '복습 완료',
      message: '복습 보상이 성장에 반영됐어요.',
      stats: [
        SessionRewardStat(
          icon: Icons.refresh,
          label: '복습',
          value: '${state.items.length}자',
          color: AppColors.blue,
        ),
        SessionRewardStat(
          icon: Icons.check,
          label: '첫 정답',
          value: '${state.correctCount}/${state.items.length}',
          color: AppColors.green,
        ),
        SessionRewardStat(
          icon: Icons.star,
          label: '별점',
          value: sessionStarsText(
            successCount: firstTrySuccessCount,
            totalCount: state.items.length,
          ),
          color: AppColors.peach,
        ),
        SessionRewardStat(
          icon: Icons.bolt,
          label: 'XP',
          value: '+${state.earnedXp}',
          color: AppColors.yellow,
        ),
      ],
      actions: [
        FilledButton.icon(
          onPressed: () => context.push(RoutePaths.growth),
          icon: const Icon(Icons.auto_graph),
          label: const Text('성장 보기'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            ref.invalidate(reviewSessionProvider(focusHanjaId));
            context.go(RoutePaths.appLearn);
          },
          icon: const Icon(Icons.menu_book),
          label: const Text('학습으로'),
        ),
      ],
    );
  }
}

class _PromptText extends StatelessWidget {
  const _PromptText({required this.text, this.useHanjaFont = false});

  final String text;
  final bool useHanjaFont;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
        fontFamily: useHanjaFont ? AppFonts.hanjaSerif : null,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _HanjaHeader extends StatelessWidget {
  const _HanjaHeader({required this.item});

  final HanjaCharacter item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(
              item.character,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: AppFonts.hanjaSerif,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.meaning,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WritingPromptHeader extends StatelessWidget {
  const _WritingPromptHeader({required this.item});

  final HanjaCharacter item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          item.meaning,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _AnswerFeedbackText extends StatelessWidget {
  const _AnswerFeedbackText({
    required this.isCorrect,
    required this.correctAnswer,
  });

  final bool isCorrect;
  final String correctAnswer;

  @override
  Widget build(BuildContext context) {
    return Text(
      isCorrect ? '정답이에요!' : '정답은 $correctAnswer예요. 잠시 뒤 다시 나와요.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: isCorrect ? AppColors.primaryDark : AppColors.textSecondary,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.selected,
    required this.correct,
    required this.hasSelection,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final bool correct;
  final bool hasSelection;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final background = !hasSelection
        ? AppColors.surface
        : correct
        ? AppColors.green
        : selected
        ? AppColors.peach
        : AppColors.surfaceMuted;
    return OutlinedButton(
      onPressed: hasSelection ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        textStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Text(
          '$count자',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
