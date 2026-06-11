import 'dart:async';
import 'dart:math' as math;

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
import '../../domain/services/thinking_unit_image_service.dart';
import '../learning/session_reward_panel.dart';
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
          if (chapterKey == null && state.chapterKey != null) {
            _replaceWithResolvedChapterRoute(context, state.chapterKey!);
            return const Center(child: CircularProgressIndicator());
          }

          if (state.items.isEmpty) {
            return PlayfulPage(
              title: '단원 학습',
              subtitle: '단원 학습할 한자가 없습니다',
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

          final compactLayout = _usesCompactLearningLayout(state);
          final fixedLearningLayout =
              _usesFixedLearningLayout(state) &&
              MediaQuery.sizeOf(context).height >= 700;
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
              compactHeader: compactLayout,
              scrollable: !fixedLearningLayout,
              padding: state.phase == DailySessionPhase.intro
                  ? const EdgeInsets.fromLTRB(18, 0, 18, 12)
                  : compactLayout
                  ? const EdgeInsets.fromLTRB(20, 0, 20, 12)
                  : const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: _childrenFor(
                state,
                compact: compactLayout,
                fixed: fixedLearningLayout,
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => PlayfulPage(
          title: '단원 학습',
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

  void _replaceWithResolvedChapterRoute(
    BuildContext context,
    String resolvedChapterKey,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      context.replace(RoutePaths.dailySessionForChapter(resolvedChapterKey));
    });
  }

  String _titleFor(DailySessionPhase phase) {
    return switch (phase) {
      DailySessionPhase.intro => '단원 학습',
      DailySessionPhase.guidedWriting => '따라쓰기',
      DailySessionPhase.hanjaToHunQuiz => '훈음 맞히기',
      DailySessionPhase.hunToHanjaQuiz => '한자 찾기',
      DailySessionPhase.randomWriting => '랜덤 쓰기',
      DailySessionPhase.mistakeReview => '한 번 더',
      DailySessionPhase.complete => '단원 학습 완료',
    };
  }

  String _subtitleFor(DailySessionState state) {
    return switch (state.phase) {
      DailySessionPhase.intro =>
        state.chapterName == null
            ? '단원 한자 ${state.items.length}자'
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
      DailySessionPhase.complete => '단원 한자를 모두 확인했어요',
    };
  }

  List<Widget> _childrenFor(
    DailySessionState state, {
    required bool compact,
    required bool fixed,
  }) {
    final hasPhaseSwitcher = _showsLearningTypeSwitcher(state);
    if (state.phase == DailySessionPhase.intro) {
      return [_StepBody(state: state)];
    }

    final stepBody = _StepBody(state: state);
    if (hasPhaseSwitcher) {
      return [
        _LearningTypeSwitcher(state: state, compact: compact),
        SizedBox(height: compact ? 6 : 10),
        stepBody,
      ];
    }

    final remainingStepBody = fixed ? Expanded(child: stepBody) : stepBody;
    return [
      _HanjaJumpPanel(state: state, compact: compact),
      SizedBox(height: compact ? 8 : 14),
      remainingStepBody,
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

  bool _usesCompactLearningLayout(DailySessionState state) {
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

  bool _usesFixedLearningLayout(DailySessionState state) {
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
  const _LearningTypeSwitcher({required this.state, required this.compact});

  final DailySessionState state;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = _typeForPhase(state.phase);
    final controller = ref.read(
      dailySessionProvider(state.chapterKey).notifier,
    );

    return PlayfulPanel(
      padding: EdgeInsets.all(compact ? 6 : 8),
      child: Row(
        children: [
          _LearningTypeButton(
            icon: Icons.edit,
            label: '따라쓰기',
            selected: selectedType == _DailyLearningType.guidedWriting,
            compact: compact,
            onTap: controller.showGuidedWriting,
          ),
          SizedBox(width: compact ? 6 : 8),
          _LearningTypeButton(
            icon: Icons.quiz,
            label: '훈음 맞히기',
            selected: selectedType == _DailyLearningType.quiz,
            compact: compact,
            onTap: controller.showQuiz,
          ),
          SizedBox(width: compact ? 6 : 8),
          _LearningTypeButton(
            icon: Icons.shuffle,
            label: '랜덤쓰기',
            selected: selectedType == _DailyLearningType.randomWriting,
            compact: compact,
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
    required this.compact,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton.tonalIcon(
        onPressed: selected ? null : onTap,
        icon: Icon(icon, size: compact ? 17 : 18),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: FilledButton.styleFrom(
          backgroundColor: selected ? AppColors.yellow : AppColors.surfaceMuted,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.yellow,
          disabledForegroundColor: AppColors.textPrimary,
          padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 8),
          minimumSize: Size(0, compact ? 38 : 44),
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
  final chapterName = state.chapterName ?? '단원 한자';
  final chapterKey = state.chapterKey;
  if (chapterKey == null) {
    return chapterName;
  }
  return const ThinkingUnitImageService().displayTitleForChapterKey(
    chapterKey: chapterKey,
    fallbackName: chapterName,
  );
}

double _adaptiveCanvasExtent(
  BoxConstraints constraints, {
  required double reservedHeight,
  required double fallback,
  double minExtent = 80,
}) {
  final height = constraints.maxHeight;
  final width = constraints.maxWidth;
  if ((!height.isFinite || height <= 0) && (!width.isFinite || width <= 0)) {
    return fallback;
  }
  final widthBound = width.isFinite && width > 0 ? width : fallback;
  if (!height.isFinite || height <= 0) {
    return widthBound.clamp(minExtent, 560.0).toDouble();
  }
  final heightBound = height - reservedHeight;
  return math.min(heightBound, widthBound).clamp(minExtent, 560.0).toDouble();
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
        _isComplete || paths.isEmpty || state.isGuidedWritingComplete(item.id);

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasExtent = _adaptiveCanvasExtent(
          constraints,
          reservedHeight: paths.isEmpty ? 196 : 146,
          fallback: 304,
        );
        return Stack(
          alignment: Alignment.center,
          children: [
            PlayfulPanel(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (paths.isEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HanjaPrompt(
                          item: item,
                          showCharacter: true,
                          compact: true,
                        ),
                        const SizedBox(height: 6),
                        HanjaFreeWritingCanvas(
                          key: ValueKey('guided-free-${item.id}'),
                          expectedStrokeCount: item.strokeCount,
                          canvasExtent: canvasExtent,
                          onStrokeTexture: () => ref
                              .read(appAudioControllerProvider)
                              .playStrokeTexture(),
                          onStrokeTextureStop: () => ref
                              .read(appAudioControllerProvider)
                              .stopStrokeTexture(),
                          showTitle: false,
                        ),
                      ],
                    )
                  else
                    HanjaWritingPracticeCanvas(
                      key: ValueKey('guided-${item.id}'),
                      svgPaths: paths,
                      canvasExtent: canvasExtent,
                      onStrokeTexture: () => ref
                          .read(appAudioControllerProvider)
                          .playStrokeTexture(),
                      onStrokeTextureStop: () => ref
                          .read(appAudioControllerProvider)
                          .stopStrokeTexture(),
                      completedStrokeCount:
                          state.isGuidedWritingComplete(item.id)
                          ? paths.length
                          : 0,
                      headerLeading: _HanjaPrompt(
                        item: item,
                        showCharacter: true,
                        compact: true,
                      ),
                      onCompleted: _handleCompleted,
                    ),
                  const SizedBox(height: 8),
                  _WritingBottomControls(
                    onPrevious: state.canMovePreviousInPhase
                        ? controller.movePreviousInPhase
                        : null,
                    onNext: state.canMoveNextInPhase
                        ? controller.moveNextInPhase
                        : null,
                    primary: FilledButton.icon(
                      onPressed: canContinue
                          ? controller.completeGuidedWriting
                          : null,
                      icon: Icon(isLastItem ? Icons.quiz : Icons.chevron_right),
                      label: Text(isLastItem ? '확인 문제로' : '다음 한자'),
                    ),
                  ),
                ],
              ),
            ),
            if (_showSuccessPopup && paths.isNotEmpty)
              const IgnorePointer(child: SuccessFeedbackPopup()),
          ],
        );
      },
    );
  }

  void _handleCompleted() {
    if (_isComplete) {
      return;
    }
    final item = widget.state.currentHanja;
    if (item != null) {
      ref
          .read(dailySessionProvider(widget.state.chapterKey).notifier)
          .markGuidedWritingCompleted(item.id);
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
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _QuizPrompt(question: question),
              const SizedBox(height: 10),
              for (final option in question.options) ...[
                _AnswerButton(
                  label: option,
                  compact: true,
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
              const SizedBox(height: 10),
              _WritingBottomControls(
                onPrevious: state.canMovePreviousInPhase
                    ? controller.movePreviousInPhase
                    : null,
                onNext: state.canMoveNextInPhase
                    ? controller.moveNextInPhase
                    : null,
                primary: FilledButton.icon(
                  onPressed: selectedAnswer == null
                      ? null
                      : controller.nextQuiz,
                  icon: Icon(isLastQuiz ? Icons.edit : Icons.chevron_right),
                  label: Text(isLastQuiz ? '랜덤 쓰기로' : '다음'),
                ),
              ),
              if (incorrectAnswer != null && selectedAnswer == null) ...[
                const SizedBox(height: 8),
                _FeedbackPanel(
                  icon: Icons.refresh,
                  message: '틀렸어요! 다시 골라보세요.',
                  color: AppColors.peach,
                  compact: true,
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
  bool _showStrokeGuideHint = false;
  bool _showSuccessPopup = false;
  List<Path> _strokes = const [];
  FreeWritingScoreResult? _scoreResult;

  @override
  void initState() {
    super.initState();
    _restoreSavedStrokes();
  }

  @override
  void didUpdateWidget(covariant _RandomWritingStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentHanja?.id != widget.state.currentHanja?.id ||
        oldWidget.state.index != widget.state.index) {
      _hasStrokes = false;
      _showCharacterHint = false;
      _showStrokeGuideHint = false;
      _showSuccessPopup = false;
      _scoreResult = null;
      _restoreSavedStrokes();
    }
  }

  void _restoreSavedStrokes() {
    final item = widget.state.currentHanja;
    final savedStrokes = item == null
        ? const <Path>[]
        : widget.state.randomWritingStrokesFor(item.id);
    _strokes = savedStrokes;
    _hasStrokes = savedStrokes.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.state.currentHanja!;
    final controller = ref.read(
      dailySessionProvider(widget.state.chapterKey).notifier,
    );
    final scoreResult = _scoreResult;
    final isComplete = widget.state.isRandomWritingComplete(item.id);
    final canContinue =
        isComplete ||
        widget.state.randomWritingCompleted ||
        scoreResult?.passed == true;
    final strokeOrderPaths = _expectedHintPaths(
      widget.state.svgPathsFor(item.id),
    );
    final expectedHintPaths = _showStrokeGuideHint
        ? strokeOrderPaths
        : const <Path>[];
    final hasStrokeHint = strokeOrderPaths.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showsFailure = scoreResult != null && !scoreResult.passed;
        final canvasExtent = _adaptiveCanvasExtent(
          constraints,
          reservedHeight: showsFailure ? 264 : 184,
          fallback: 336,
        );
        return Stack(
          alignment: Alignment.center,
          children: [
            PlayfulPanel(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RandomWritingPromptBar(
                    item: item,
                    showCharacter: _showCharacterHint,
                  ),
                  const SizedBox(height: 6),
                  HanjaFreeWritingCanvas(
                    key: ValueKey('random-free-${item.id}'),
                    expectedStrokeCount: item.strokeCount,
                    initialStrokes: widget.state.randomWritingStrokesFor(
                      item.id,
                    ),
                    canvasExtent: canvasExtent,
                    onStrokeTexture: () => ref
                        .read(appAudioControllerProvider)
                        .playStrokeTexture(),
                    onStrokeTextureStop: () => ref
                        .read(appAudioControllerProvider)
                        .stopStrokeTexture(),
                    toolbarLeading: _RandomWritingHintTools(
                      showCharacterHint: _showCharacterHint,
                      showStrokeGuideHint: _showStrokeGuideHint,
                      hasStrokeHint: hasStrokeHint,
                      onToggleCharacterHint: () {
                        setState(
                          () => _showCharacterHint = !_showCharacterHint,
                        );
                      },
                      onToggleStrokeGuideHint: () {
                        final nextValue = !_showStrokeGuideHint;
                        setState(() => _showStrokeGuideHint = nextValue);
                        if (nextValue) {
                          controller.markRandomWritingHintUsed(item.id);
                        }
                      },
                    ),
                    showTitle: false,
                    failedStrokeIndex: scoreResult?.failedStrokeIndex,
                    expectedHintPath: scoreResult?.expectedHintPath,
                    expectedHintPaths: expectedHintPaths,
                    showStrokeOrderButton: true,
                    strokeOrderPreviewPaths: strokeOrderPaths,
                    onStrokesChanged: (strokes) {
                      ref
                          .read(
                            dailySessionProvider(
                              widget.state.chapterKey,
                            ).notifier,
                          )
                          .saveRandomWritingStrokes(
                            hanjaId: item.id,
                            strokes: strokes,
                          );
                      setState(() {
                        _strokes = strokes;
                        _hasStrokes = strokes.isNotEmpty;
                        _showSuccessPopup = false;
                        _scoreResult = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (showsFailure) ...[
                    _WritingFeedbackPanel(result: scoreResult, compact: true),
                    const SizedBox(height: 8),
                  ],
                  _WritingBottomControls(
                    onPrevious: widget.state.canMovePreviousInPhase
                        ? controller.movePreviousInPhase
                        : null,
                    onNext:
                        widget.state.canMoveNextInPhase &&
                            widget.state.canAdvanceCurrentRandomWriting
                        ? controller.moveNextInPhase
                        : null,
                    primary: canContinue
                        ? FilledButton.icon(
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
                        : FilledButton.icon(
                            onPressed: _hasStrokes
                                ? () => unawaited(_checkWriting())
                                : null,
                            icon: const Icon(Icons.check),
                            label: const Text('확인하기'),
                          ),
                  ),
                ],
              ),
            ),
            if (_showSuccessPopup)
              const IgnorePointer(child: SuccessFeedbackPopup()),
          ],
        );
      },
    );
  }

  Future<void> _checkWriting() async {
    final item = widget.state.currentHanja!;
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
    if (result.passed) {
      ref
          .read(dailySessionProvider(widget.state.chapterKey).notifier)
          .markRandomWritingCompleted(item.id);
    }
    if (!result.passed) {
      await ref
          .read(dailySessionProvider(widget.state.chapterKey).notifier)
          .recordRandomWritingFailure(item.id);
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

  List<Path> _expectedHintPaths(List<String> svgPaths) {
    final paths = <Path>[];
    for (final pathData in svgPaths) {
      final path = SvgPathParser.tryParse(pathData);
      if (path != null) {
        paths.add(path);
      }
    }
    return paths;
  }
}

class _RandomWritingHintTools extends StatelessWidget {
  const _RandomWritingHintTools({
    required this.showCharacterHint,
    required this.showStrokeGuideHint,
    required this.hasStrokeHint,
    required this.onToggleCharacterHint,
    required this.onToggleStrokeGuideHint,
  });

  final bool showCharacterHint;
  final bool showStrokeGuideHint;
  final bool hasStrokeHint;
  final VoidCallback onToggleCharacterHint;
  final VoidCallback onToggleStrokeGuideHint;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RandomWritingToolButton(
          selected: showCharacterHint,
          onPressed: onToggleCharacterHint,
          icon: showCharacterHint ? Icons.visibility_off : Icons.visibility,
          tooltip: showCharacterHint ? '한자 힌트 끄기' : '한자 힌트',
        ),
        const SizedBox(width: 6),
        _RandomWritingToolButton(
          selected: showStrokeGuideHint,
          onPressed: hasStrokeHint ? onToggleStrokeGuideHint : null,
          icon: showStrokeGuideHint ? Icons.layers_clear : Icons.gesture,
          tooltip: showStrokeGuideHint ? '획 힌트 끄기' : '획 힌트',
        ),
      ],
    );
  }
}

class _RandomWritingPromptBar extends StatelessWidget {
  const _RandomWritingPromptBar({
    required this.item,
    required this.showCharacter,
  });

  final HanjaCharacter item;
  final bool showCharacter;

  @override
  Widget build(BuildContext context) {
    final strokeCount = item.strokeCount == null ? '-' : '${item.strokeCount}';
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: SizedBox.square(
            dimension: 46,
            child: Center(
              child: Text(
                showCharacter ? item.character : '?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: AppFonts.hanjaSerif,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${item.meaning} · $strokeCount획',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _RandomWritingToolButton extends StatelessWidget {
  const _RandomWritingToolButton({
    required this.selected,
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  });

  final bool selected;
  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: IconButton.filledTonal(
        style: IconButton.styleFrom(
          backgroundColor: selected ? AppColors.yellow : AppColors.surfaceMuted,
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.surfaceMuted,
          disabledForegroundColor: AppColors.textMuted,
          padding: EdgeInsets.zero,
          minimumSize: const Size.square(40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        tooltip: tooltip,
      ),
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

class _CompleteStep extends ConsumerWidget {
  const _CompleteStep({required this.state});

  final DailySessionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalQuizCount = state.totalQuizCount;
    return SessionRewardPanel(
      icon: Icons.auto_awesome,
      title: '단원 학습 완료',
      message: '완료 보상이 성장에 반영됐어요.',
      stats: [
        SessionRewardStat(
          icon: Icons.menu_book,
          label: '완료',
          value: '${state.items.length}자',
          color: AppColors.green,
        ),
        SessionRewardStat(
          icon: Icons.percent,
          label: '정답률',
          value: _percentText(state.correctCount, totalQuizCount),
          color: AppColors.blue,
        ),
        SessionRewardStat(
          icon: Icons.star,
          label: '별점',
          value: sessionStarsText(
            successCount: state.correctCount,
            totalCount: totalQuizCount,
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
          onPressed: () {
            ref.invalidate(dailySessionProvider(state.chapterKey));
            context.go(RoutePaths.appHome);
          },
          icon: const Icon(Icons.home),
          label: const Text('홈으로'),
        ),
        OutlinedButton.icon(
          onPressed: () => context.push(RoutePaths.growth),
          icon: const Icon(Icons.auto_graph),
          label: const Text('성장 보기'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            ref.invalidate(dailySessionProvider(state.chapterKey));
            context.go(RoutePaths.appLearn);
          },
          icon: const Icon(Icons.menu_book),
          label: const Text('한자장 보기'),
        ),
      ],
    );
  }
}

String _percentText(int successCount, int totalCount) {
  if (totalCount <= 0) {
    return '-';
  }
  return '${((successCount / totalCount) * 100).round()}%';
}

class _HanjaJumpPanel extends StatelessWidget {
  const _HanjaJumpPanel({required this.state, required this.compact});

  final DailySessionState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 6 : 10,
      ),
      child: Wrap(
        spacing: compact ? 5 : 7,
        runSpacing: compact ? 5 : 7,
        alignment: WrapAlignment.center,
        children: List.generate(state.items.length, (index) {
          final item = state.items[index];
          return _HanjaProgressBadge(
            item: item,
            compact: compact,
            completed: _isCompleteInCurrentPhase(
              state: state,
              hanjaId: item.id,
            ),
          );
        }),
      ),
    );
  }
}

class _WritingBottomControls extends StatelessWidget {
  const _WritingBottomControls({
    required this.onPrevious,
    required this.onNext,
    required this.primary,
  });

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Widget primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepNavigationArrow(
          icon: Icons.chevron_left,
          tooltip: '이전 한자',
          onPressed: onPrevious,
        ),
        const SizedBox(width: 8),
        Expanded(child: primary),
        const SizedBox(width: 8),
        _StepNavigationArrow(
          icon: Icons.chevron_right,
          tooltip: '다음 한자',
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _StepNavigationArrow extends StatelessWidget {
  const _StepNavigationArrow({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (onPressed != null)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: SizedBox.square(
        dimension: 36,
        child: IconButton.filledTonal(
          style: IconButton.styleFrom(
            backgroundColor: onPressed == null
                ? AppColors.surfaceMuted.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.94),
            foregroundColor: AppColors.textPrimary,
            disabledForegroundColor: AppColors.textMuted,
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 24),
          tooltip: tooltip,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

bool _isCompleteInCurrentPhase({
  required DailySessionState state,
  required String hanjaId,
}) {
  return switch (state.phase) {
    DailySessionPhase.guidedWriting => state.isGuidedWritingComplete(hanjaId),
    DailySessionPhase.hanjaToHunQuiz || DailySessionPhase.hunToHanjaQuiz =>
      _quizAnswerForHanja(state: state, hanjaId: hanjaId) != null,
    DailySessionPhase.randomWriting => state.isRandomWritingComplete(hanjaId),
    _ => state.isGuidedWritingComplete(hanjaId),
  };
}

String? _quizAnswerForHanja({
  required DailySessionState state,
  required String hanjaId,
}) {
  final question = switch (state.phase) {
    DailySessionPhase.hanjaToHunQuiz =>
      state.hanjaToHunQuestions
          .where((question) => question.item.id == hanjaId)
          .firstOrNullSafe,
    DailySessionPhase.hunToHanjaQuiz =>
      state.hunToHanjaQuestions
          .where((question) => question.item.id == hanjaId)
          .firstOrNullSafe,
    _ => null,
  };
  if (question == null) {
    return null;
  }
  return state.quizSelectedAnswers['${question.kind.name}:${question.item.id}'];
}

extension _FirstOrNullSafe<T> on Iterable<T> {
  T? get firstOrNullSafe {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}

class _HanjaProgressBadge extends StatelessWidget {
  const _HanjaProgressBadge({
    required this.item,
    required this.completed,
    required this.compact,
  });

  final HanjaCharacter item;
  final bool completed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final background = completed
        ? AppColors.green.withValues(alpha: 0.46)
        : AppColors.surfaceMuted;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SizedBox(
        width: compact ? 38 : 44,
        height: compact ? 34 : 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              item.character,
              style:
                  (compact
                          ? Theme.of(context).textTheme.titleMedium
                          : Theme.of(context).textTheme.titleLarge)
                      ?.copyWith(
                        fontFamily: AppFonts.hanjaSerif,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
            ),
            if (completed)
              const Positioned(
                right: 3,
                top: 3,
                child: Icon(
                  Icons.check_circle,
                  size: 12,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
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
    final tileSize = compact ? 56.0 : 90.0;
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
                style:
                    (compact
                            ? Theme.of(context).textTheme.titleMedium
                            : Theme.of(context).textTheme.titleLarge)
                        ?.copyWith(
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
          overflow: TextOverflow.clip,
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
    this.compact = false,
    required this.isSelected,
    required this.isIncorrect,
    required this.isCorrect,
    required this.showResult,
    required this.onPressed,
  });

  final String label;
  final bool compact;
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
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 14,
          vertical: compact ? 8 : 14,
        ),
        minimumSize: Size(0, compact ? 38 : 48),
        textStyle:
            (compact
                    ? Theme.of(context).textTheme.titleSmall
                    : Theme.of(context).textTheme.titleMedium)
                ?.copyWith(fontWeight: FontWeight.w900),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        maxLines: compact ? 2 : null,
        overflow: compact ? TextOverflow.ellipsis : TextOverflow.clip,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.icon,
    required this.message,
    required this.color,
    this.compact = false,
  });

  final IconData icon;
  final String message;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 8 : 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: compact ? 20 : 24),
            SizedBox(width: compact ? 6 : 8),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style:
                    (compact
                            ? Theme.of(context).textTheme.bodyMedium
                            : Theme.of(context).textTheme.titleMedium)
                        ?.copyWith(
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
  const _WritingFeedbackPanel({required this.result, this.compact = false});

  final FreeWritingScoreResult result;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (result.failureReason == FreeWritingFailureReason.missingStrokeData) {
      return _FeedbackPanel(
        icon: Icons.info_outline,
        message: '획순 데이터가 부족해서 정확한 판정은 어려워요. 그래도 연습했어요!',
        color: AppColors.blue,
        compact: compact,
      );
    }
    if (result.passed) {
      return _FeedbackPanel(
        icon: Icons.check_circle,
        message: '맞았어요! ${result.message}',
        color: AppColors.green,
        compact: compact,
      );
    }
    return _FeedbackPanel(
      icon: Icons.refresh,
      message: result.failureMessage ?? '틀렸어요! 다시 써보세요.',
      color: AppColors.peach,
      compact: compact,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.character,
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontFamily: AppFonts.hanjaSerif,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              item.meaning,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
