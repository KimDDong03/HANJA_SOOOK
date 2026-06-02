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
import '../../domain/services/thinking_unit_image_service.dart';
import '../writing/free_writing_score_controller.dart';
import '../writing/svg_path_parser.dart';
import '../writing/widgets/hanja_free_writing_canvas.dart';
import '../writing/widgets/hanja_writing_practice_canvas.dart';
import 'daily_session_controller.dart';

enum _DailyLearningType { guidedWriting, quiz, randomWriting }

class DailySessionScreen extends ConsumerWidget {
  const DailySessionScreen({super.key, this.chapterKey});

  final String? chapterKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(dailySessionProvider(chapterKey));

    return Scaffold(
      body: session.when(
        data: (state) {
          if (state.items.isEmpty) {
            return PlayfulPage(
              title: '오늘 학습',
              subtitle: '오늘 학습할 한자가 없습니다',
              children: [
                PlayfulPanel(
                  child: FilledButton.icon(
                    onPressed: () => context.go(RoutePaths.appLearn),
                    icon: const Icon(Icons.menu_book),
                    label: const Text('한자장 보기'),
                  ),
                ),
              ],
            );
          }

          final isCompactWriting =
              state.phase == DailySessionPhase.randomWriting;
          return PopScope<Object?>(
            canPop: !_handlesBackWithinSession(state),
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) {
                return;
              }
              ref
                  .read(dailySessionProvider(chapterKey).notifier)
                  .goBackWithinSession();
            },
            child: PlayfulPage(
              title: _titleFor(state.phase),
              subtitle: state.phase == DailySessionPhase.intro
                  ? ''
                  : _subtitleFor(state),
              trailing: state.phase == DailySessionPhase.intro
                  ? null
                  : _SessionCountBadge(count: state.items.length),
              padding: isCompactWriting
                  ? const EdgeInsets.fromLTRB(16, 2, 16, 16)
                  : state.phase == DailySessionPhase.intro
                  ? const EdgeInsets.fromLTRB(18, 0, 18, 12)
                  : state.phase == DailySessionPhase.guidedWriting
                  ? const EdgeInsets.fromLTRB(20, 4, 20, 18)
                  : const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: _childrenFor(state, isCompactWriting),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => PlayfulPage(
          title: '오늘 학습',
          subtitle: '학습을 불러오지 못했습니다',
          children: [
            PlayfulPanel(
              child: FilledButton.icon(
                onPressed: () =>
                    ref.invalidate(dailySessionProvider(chapterKey)),
                icon: const Icon(Icons.refresh),
                label: const Text('다시 불러오기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _titleFor(DailySessionPhase phase) {
    return switch (phase) {
      DailySessionPhase.intro => '오늘 학습',
      DailySessionPhase.guidedWriting => '따라쓰기',
      DailySessionPhase.hanjaToHunQuiz => '훈음 맞히기',
      DailySessionPhase.hunToHanjaQuiz => '한자 찾기',
      DailySessionPhase.randomWriting => '랜덤 쓰기',
      DailySessionPhase.mistakeReview => '한 번 더',
      DailySessionPhase.complete => '오늘 학습 완료',
    };
  }

  String _subtitleFor(DailySessionState state) {
    return switch (state.phase) {
      DailySessionPhase.intro =>
        state.chapterName == null
            ? '오늘의 한자 ${state.items.length}자'
            : '${_chapterDisplayName(state)} · ${state.items.length}자',
      DailySessionPhase.guidedWriting =>
        '${state.index + 1}/${state.items.length} · 획을 따라 써요',
      DailySessionPhase.hanjaToHunQuiz =>
        '${state.index + 1}/${state.hanjaToHunQuestions.length} · 한자를 보고 골라요',
      DailySessionPhase.hunToHanjaQuiz =>
        '${state.index + 1}/${state.hunToHanjaQuestions.length} · 훈음을 보고 골라요',
      DailySessionPhase.randomWriting =>
        '${state.index + 1}/${state.randomWritingItems.length} · 순서 없이 써요',
      DailySessionPhase.mistakeReview => '${state.missedItems.length}자 확인',
      DailySessionPhase.complete => '오늘 한자를 모두 확인했어요',
    };
  }

  List<Widget> _childrenFor(DailySessionState state, bool isCompactWriting) {
    final hasPhaseSwitcher = _showsLearningTypeSwitcher(state);
    if (state.phase == DailySessionPhase.intro) {
      return [_StepBody(state: state)];
    }

    if (hasPhaseSwitcher) {
      return [
        _LearningTypeSwitcher(state: state),
        SizedBox(height: isCompactWriting ? 8 : 10),
        _ProgressPanel(state: state),
        SizedBox(height: isCompactWriting ? 10 : 12),
        _StepBody(state: state),
      ];
    }

    return [
      _ProgressPanel(state: state),
      const SizedBox(height: 14),
      _StepBody(state: state),
    ];
  }

  bool _handlesBackWithinSession(DailySessionState state) {
    return state.phase != DailySessionPhase.intro &&
        state.phase != DailySessionPhase.complete;
  }

  bool _showsLearningTypeSwitcher(DailySessionState state) {
    return switch (state.phase) {
      DailySessionPhase.guidedWriting ||
      DailySessionPhase.hanjaToHunQuiz ||
      DailySessionPhase.hunToHanjaQuiz ||
      DailySessionPhase.randomWriting => true,
      DailySessionPhase.intro ||
      DailySessionPhase.mistakeReview ||
      DailySessionPhase.complete => false,
    };
  }
}

class _StepBody extends ConsumerWidget {
  const _StepBody({required this.state});

  final DailySessionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (state.phase) {
      DailySessionPhase.intro => _IntroStep(state: state),
      DailySessionPhase.guidedWriting => _GuidedWritingStep(state: state),
      DailySessionPhase.hanjaToHunQuiz ||
      DailySessionPhase.hunToHanjaQuiz => _QuizStep(state: state),
      DailySessionPhase.randomWriting => _RandomWritingStep(
        key: ValueKey(
          'random-writing-${state.currentHanja?.id}-${state.index}',
        ),
        state: state,
      ),
      DailySessionPhase.mistakeReview => _MistakeReviewStep(state: state),
      DailySessionPhase.complete => _CompleteStep(state: state),
    };
  }
}

class _LearningTypeSwitcher extends ConsumerWidget {
  const _LearningTypeSwitcher({required this.state});

  final DailySessionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = _typeForPhase(state.phase);
    final controller = ref.read(
      dailySessionProvider(state.chapterKey).notifier,
    );

    return PlayfulPanel(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _LearningTypeButton(
            icon: Icons.edit,
            label: '따라쓰기',
            selected: selectedType == _DailyLearningType.guidedWriting,
            onTap: controller.showGuidedWriting,
          ),
          const SizedBox(width: 8),
          _LearningTypeButton(
            icon: Icons.quiz,
            label: '훈음 맞히기',
            selected: selectedType == _DailyLearningType.quiz,
            onTap: controller.showQuiz,
          ),
          const SizedBox(width: 8),
          _LearningTypeButton(
            icon: Icons.shuffle,
            label: '랜덤쓰기',
            selected: selectedType == _DailyLearningType.randomWriting,
            onTap: controller.showRandomWriting,
          ),
        ],
      ),
    );
  }

  _DailyLearningType _typeForPhase(DailySessionPhase phase) {
    return switch (phase) {
      DailySessionPhase.guidedWriting => _DailyLearningType.guidedWriting,
      DailySessionPhase.hanjaToHunQuiz ||
      DailySessionPhase.hunToHanjaQuiz => _DailyLearningType.quiz,
      DailySessionPhase.randomWriting => _DailyLearningType.randomWriting,
      _ => _DailyLearningType.guidedWriting,
    };
  }
}

class _LearningTypeButton extends StatelessWidget {
  const _LearningTypeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton.tonalIcon(
        onPressed: selected ? null : onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: FilledButton.styleFrom(
          backgroundColor: selected ? AppColors.yellow : AppColors.surfaceMuted,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.yellow,
          disabledForegroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size(0, 44),
          textStyle: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _IntroStep extends ConsumerWidget {
  const _IntroStep({required this.state});

  final DailySessionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlayfulPanel(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IntroLessonSummary(state: state),
          const SizedBox(height: 8),
          _IntroThinkingImage(assetPath: state.imageAssetPath),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 6,
              childAspectRatio: 1.82,
            ),
            itemBuilder: (context, index) {
              return _IntroHanjaCard(item: state.items[index]);
            },
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => ref
                .read(dailySessionProvider(state.chapterKey).notifier)
                .start(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('시작'),
          ),
        ],
      ),
    );
  }
}

class _IntroThinkingImage extends StatelessWidget {
  const _IntroThinkingImage({required this.assetPath});

  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 128,
        child: path == null
            ? const ColoredBox(
                color: AppColors.surfaceMuted,
                child: Center(
                  child: Icon(Icons.image_not_supported_outlined, size: 38),
                ),
              )
            : ColoredBox(
                color: Colors.white,
                child: Image.asset(
                  path,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const ColoredBox(
                      color: AppColors.surfaceMuted,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 38,
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _IntroLessonSummary extends StatelessWidget {
  const _IntroLessonSummary({required this.state});

  final DailySessionState state;

  @override
  Widget build(BuildContext context) {
    final displayName = _chapterDisplayName(state);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.menu_book, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${state.items.length}자',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _chapterDisplayName(DailySessionState state) {
  final chapterName = state.chapterName ?? '오늘의 한자';
  final chapterKey = state.chapterKey;
  if (chapterKey == null) {
    return chapterName;
  }
  return const ThinkingUnitImageService().displayTitleForChapterKey(
    chapterKey: chapterKey,
    fallbackName: chapterName,
  );
}

class _GuidedWritingStep extends ConsumerStatefulWidget {
  const _GuidedWritingStep({required this.state});

  final DailySessionState state;

  @override
  ConsumerState<_GuidedWritingStep> createState() => _GuidedWritingStepState();
}

class _GuidedWritingStepState extends ConsumerState<_GuidedWritingStep> {
  bool _isComplete = false;
  bool _showSuccessPopup = false;

  @override
  void didUpdateWidget(covariant _GuidedWritingStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentHanja?.id != widget.state.currentHanja?.id ||
        oldWidget.state.index != widget.state.index) {
      _isComplete = false;
      _showSuccessPopup = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final item = state.currentHanja!;
    final paths = state.svgPathsFor(item.id);
    final controller = ref.read(
      dailySessionProvider(state.chapterKey).notifier,
    );
    final isLastItem = state.index >= state.items.length - 1;
    final canContinue =
        _isComplete || paths.isEmpty || state.guidedWritingCompleted;

    return Stack(
      alignment: Alignment.center,
      children: [
        PlayfulPanel(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HanjaPrompt(item: item, showCharacter: true, compact: true),
              const SizedBox(height: 10),
              if (paths.isEmpty)
                HanjaFreeWritingCanvas(
                  key: ValueKey('guided-free-${item.id}'),
                  expectedStrokeCount: item.strokeCount,
                  canvasExtent: 264,
                  showTitle: false,
                )
              else
                HanjaWritingPracticeCanvas(
                  key: ValueKey('guided-${item.id}'),
                  svgPaths: paths,
                  canvasExtent: 264,
                  onCompleted: _handleCompleted,
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: canContinue
                    ? controller.completeGuidedWriting
                    : null,
                icon: Icon(isLastItem ? Icons.quiz : Icons.chevron_right),
                label: Text(isLastItem ? '확인 문제로' : '다음 한자'),
              ),
            ],
          ),
        ),
        if (_showSuccessPopup && paths.isNotEmpty)
          const IgnorePointer(child: SuccessFeedbackPopup()),
      ],
    );
  }

  void _handleCompleted() {
    if (_isComplete) {
      return;
    }
    setState(() {
      _isComplete = true;
      _showSuccessPopup = true;
    });
    ref.read(appAudioControllerProvider).playSuccess();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted || !_isComplete) {
        return;
      }
      setState(() => _showSuccessPopup = false);
    });
  }
}

class _QuizStep extends ConsumerStatefulWidget {
  const _QuizStep({required this.state});

  final DailySessionState state;

  @override
  ConsumerState<_QuizStep> createState() => _QuizStepState();
}

class _QuizStepState extends ConsumerState<_QuizStep> {
  bool _showSuccessPopup = false;

  @override
  void didUpdateWidget(covariant _QuizStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.phase != widget.state.phase ||
        oldWidget.state.index != widget.state.index) {
      _showSuccessPopup = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final question = state.currentQuizQuestion!;
    final controller = ref.read(
      dailySessionProvider(state.chapterKey).notifier,
    );
    final selectedAnswer = state.selectedAnswer;
    final incorrectAnswer = state.incorrectAnswer;
    final isLastQuiz =
        state.phase == DailySessionPhase.hunToHanjaQuiz &&
        state.index >= state.hunToHanjaQuestions.length - 1;

    return Stack(
      alignment: Alignment.center,
      children: [
        PlayfulPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _QuizPrompt(question: question),
              const SizedBox(height: 16),
              for (final option in question.options) ...[
                _AnswerButton(
                  label: option,
                  isSelected: selectedAnswer == option,
                  isIncorrect: incorrectAnswer == option,
                  isCorrect: option == question.correctAnswer,
                  showResult: selectedAnswer != null,
                  onPressed: selectedAnswer == null
                      ? () => _selectAnswer(controller, question, option)
                      : null,
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 4),
              FilledButton.icon(
                onPressed: selectedAnswer == null ? null : controller.nextQuiz,
                icon: Icon(isLastQuiz ? Icons.edit : Icons.chevron_right),
                label: Text(isLastQuiz ? '랜덤 쓰기로' : '다음'),
              ),
              if (incorrectAnswer != null && selectedAnswer == null) ...[
                const SizedBox(height: 8),
                _FeedbackPanel(
                  icon: Icons.refresh,
                  message: '틀렸어요! 다시 골라보세요.',
                  color: AppColors.peach,
                ),
              ],
            ],
          ),
        ),
        if (_showSuccessPopup)
          const IgnorePointer(child: SuccessFeedbackPopup()),
      ],
    );
  }

  void _selectAnswer(
    DailySessionController controller,
    DailyQuizQuestion question,
    String answer,
  ) {
    controller.selectQuizAnswer(answer);
    if (answer != question.correctAnswer) {
      return;
    }
    setState(() => _showSuccessPopup = true);
    ref.read(appAudioControllerProvider).playSuccess();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      setState(() => _showSuccessPopup = false);
    });
  }
}

class _RandomWritingStep extends ConsumerStatefulWidget {
  const _RandomWritingStep({super.key, required this.state});

  final DailySessionState state;

  @override
  ConsumerState<_RandomWritingStep> createState() => _RandomWritingStepState();
}

class _RandomWritingStepState extends ConsumerState<_RandomWritingStep> {
  bool _hasStrokes = false;
  bool _showCharacterHint = false;
  bool _showFirstStrokeHint = false;
  bool _showSuccessPopup = false;
  List<Path> _strokes = const [];
  FreeWritingScoreResult? _scoreResult;

  @override
  void didUpdateWidget(covariant _RandomWritingStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentHanja?.id != widget.state.currentHanja?.id ||
        oldWidget.state.index != widget.state.index) {
      _hasStrokes = false;
      _showCharacterHint = false;
      _showFirstStrokeHint = false;
      _showSuccessPopup = false;
      _strokes = const [];
      _scoreResult = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.state.currentHanja!;
    final controller = ref.read(
      dailySessionProvider(widget.state.chapterKey).notifier,
    );
    final scoreResult = _scoreResult;
    final canContinue =
        widget.state.randomWritingCompleted ||
        scoreResult?.canContinueDemoFlow == true;
    final firstHintPath = _showFirstStrokeHint
        ? _firstExpectedHintPath(widget.state.svgPathsFor(item.id))
        : null;

    return Stack(
      alignment: Alignment.center,
      children: [
        PlayfulPanel(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HanjaPrompt(
                item: item,
                showCharacter: _showCharacterHint,
                compact: true,
              ),
              const SizedBox(height: 8),
              _RandomWritingHints(
                showCharacterHint: _showCharacterHint,
                showFirstStrokeHint: _showFirstStrokeHint,
                hasStrokeHint: widget.state.svgPathsFor(item.id).isNotEmpty,
                onToggleCharacterHint: () {
                  setState(() => _showCharacterHint = !_showCharacterHint);
                },
                onToggleFirstStrokeHint: () {
                  setState(() => _showFirstStrokeHint = !_showFirstStrokeHint);
                },
              ),
              const SizedBox(height: 8),
              HanjaFreeWritingCanvas(
                key: ValueKey('random-free-${item.id}'),
                expectedStrokeCount: item.strokeCount,
                canvasExtent: 252,
                showTitle: false,
                failedStrokeIndex: scoreResult?.failedStrokeIndex,
                expectedHintPath:
                    scoreResult?.expectedHintPath ?? firstHintPath,
                onStrokesChanged: (strokes) {
                  setState(() {
                    _strokes = strokes;
                    _hasStrokes = strokes.isNotEmpty;
                    _showSuccessPopup = false;
                    _scoreResult = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              if (scoreResult != null && !scoreResult.passed) ...[
                _WritingFeedbackPanel(result: scoreResult),
                const SizedBox(height: 10),
              ],
              if (canContinue)
                FilledButton.icon(
                  onPressed: controller.completeRandomWriting,
                  icon: Icon(
                    widget.state.index >=
                            widget.state.randomWritingItems.length - 1
                        ? Icons.flag
                        : Icons.chevron_right,
                  ),
                  label: Text(
                    widget.state.index >=
                            widget.state.randomWritingItems.length - 1
                        ? '마무리'
                        : '다음 쓰기',
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: _hasStrokes ? _checkWriting : null,
                  icon: const Icon(Icons.check),
                  label: const Text('확인하기'),
                ),
            ],
          ),
        ),
        if (_showSuccessPopup)
          const IgnorePointer(child: SuccessFeedbackPopup()),
      ],
    );
  }

  void _checkWriting() {
    final item = widget.state.currentHanja!;
    final result = ref
        .read(freeWritingScoreControllerProvider)
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
      return;
    }
    ref.read(appAudioControllerProvider).playSuccess();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      setState(() => _showSuccessPopup = false);
    });
  }

  Path? _firstExpectedHintPath(List<String> svgPaths) {
    if (svgPaths.isEmpty) {
      return null;
    }
    return SvgPathParser.tryParse(svgPaths.first);
  }
}

class _RandomWritingHints extends StatelessWidget {
  const _RandomWritingHints({
    required this.showCharacterHint,
    required this.showFirstStrokeHint,
    required this.hasStrokeHint,
    required this.onToggleCharacterHint,
    required this.onToggleFirstStrokeHint,
  });

  final bool showCharacterHint;
  final bool showFirstStrokeHint;
  final bool hasStrokeHint;
  final VoidCallback onToggleCharacterHint;
  final VoidCallback onToggleFirstStrokeHint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onToggleCharacterHint,
            icon: Icon(
              showCharacterHint ? Icons.visibility_off : Icons.visibility,
              size: 18,
            ),
            label: Text(showCharacterHint ? '한자 가리기' : '한자 힌트'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: hasStrokeHint ? onToggleFirstStrokeHint : null,
            icon: Icon(
              showFirstStrokeHint ? Icons.layers_clear : Icons.gesture,
              size: 18,
            ),
            label: Text(showFirstStrokeHint ? '획 힌트 끄기' : '첫 획 힌트'),
          ),
        ),
      ],
    );
  }
}

class _MistakeReviewStep extends ConsumerWidget {
  const _MistakeReviewStep({required this.state});

  final DailySessionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in state.missedItems) ...[
            _MistakeRow(item: item),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: state.isSaving
                ? null
                : () => ref
                      .read(dailySessionProvider(state.chapterKey).notifier)
                      .finish(),
            icon: state.isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('완료'),
          ),
        ],
      ),
    );
  }
}

class _CompleteStep extends StatelessWidget {
  const _CompleteStep({required this.state});

  final DailySessionState state;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PlayfulStat(
                icon: Icons.auto_awesome,
                label: '완료',
                value: '${state.items.length}자',
                color: AppColors.green,
              ),
              const SizedBox(width: 10),
              PlayfulStat(
                icon: Icons.quiz,
                label: '정답',
                value: '${state.correctCount}/${state.totalQuizCount}',
                color: AppColors.blue,
              ),
              const SizedBox(width: 10),
              PlayfulStat(
                icon: Icons.bolt,
                label: 'XP',
                value: '+${state.earnedXp}',
                color: AppColors.yellow,
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => context.go(RoutePaths.appHome),
            icon: const Icon(Icons.home),
            label: const Text('홈으로'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.go(RoutePaths.appLearn),
            icon: const Icon(Icons.menu_book),
            label: const Text('한자장 보기'),
          ),
        ],
      ),
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.state});

  final DailySessionState state;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: state.progress,
            minHeight: 10,
            color: AppColors.primary,
            backgroundColor: AppColors.border.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(99),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final item in state.items)
                Text(
                  item.character,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: AppFonts.hanjaSerif,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HanjaPrompt extends StatelessWidget {
  const _HanjaPrompt({
    required this.item,
    required this.showCharacter,
    this.compact = false,
  });

  final HanjaCharacter item;
  final bool showCharacter;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tileSize = compact ? 72.0 : 90.0;
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: SizedBox.square(
            dimension: tileSize,
            child: Center(
              child: Text(
                showCharacter ? item.character : '?',
                style:
                    (compact
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.displaySmall)
                        ?.copyWith(
                          fontFamily: AppFonts.hanjaSerif,
                          fontWeight: FontWeight.w900,
                        ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.meaning,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: compact ? 2 : 4),
              Text(
                '${item.strokeCount ?? '-'}획',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuizPrompt extends StatelessWidget {
  const _QuizPrompt({required this.question});

  final DailyQuizQuestion question;

  @override
  Widget build(BuildContext context) {
    final isHanjaPrompt = question.kind == DailyQuizKind.hanjaToHun;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          question.prompt,
          textAlign: TextAlign.center,
          style: isHanjaPrompt
              ? Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontFamily: AppFonts.hanjaSerif,
                  fontWeight: FontWeight.w900,
                )
              : Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.isSelected,
    required this.isIncorrect,
    required this.isCorrect,
    required this.showResult,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final bool isIncorrect;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final background = !showResult
        ? isIncorrect
              ? AppColors.peach
              : AppColors.surface
        : isCorrect
        ? AppColors.green
        : isSelected
        ? AppColors.peach
        : AppColors.surface;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        textStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
      ),
      onPressed: onPressed,
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

class _WritingFeedbackPanel extends StatelessWidget {
  const _WritingFeedbackPanel({required this.result});

  final FreeWritingScoreResult result;

  @override
  Widget build(BuildContext context) {
    if (result.failureReason == FreeWritingFailureReason.missingStrokeData) {
      return const _FeedbackPanel(
        icon: Icons.info_outline,
        message: '획순 데이터가 부족해서 정확한 판정은 어려워요. 그래도 연습했어요!',
        color: AppColors.blue,
      );
    }
    if (result.passed) {
      return _FeedbackPanel(
        icon: Icons.check_circle,
        message: '맞았어요! ${result.message}',
        color: AppColors.green,
      );
    }
    return _FeedbackPanel(
      icon: Icons.refresh,
      message: result.failureMessage ?? '틀렸어요! 다시 써보세요.',
      color: AppColors.peach,
    );
  }
}

class _IntroHanjaCard extends StatelessWidget {
  const _IntroHanjaCard({required this.item});

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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.character,
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: AppFonts.hanjaSerif,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.meaning,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MistakeRow extends StatelessWidget {
  const _MistakeRow({required this.item});

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
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.meaning,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

class _SessionCountBadge extends StatelessWidget {
  const _SessionCountBadge({required this.count});

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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
