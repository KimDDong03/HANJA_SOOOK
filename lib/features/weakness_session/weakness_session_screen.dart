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
import 'weakness_session_controller.dart';

class WeaknessSessionScreen extends ConsumerWidget {
  const WeaknessSessionScreen({super.key, this.focusHanjaId});

  final String? focusHanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(weaknessSessionProvider(focusHanjaId));
    return Scaffold(
      body: session.when(
        data: (state) {
          if (state.tasks.isEmpty) {
            return PlayfulPage(
              title: '집중',
              subtitle: '지금 더 연습할 한자가 없어요',
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
          if (state.phaseComplete) {
            return _CompleteView(state: state, focusHanjaId: focusHanjaId);
          }
          final task = state.currentTask!;
          return PlayfulPage(
            title: '집중',
            subtitle:
                '${state.index + 1}/${state.tasks.length} · ${task.weakness.typeLabel}',
            trailing: _ScoreBadge(score: task.weakness.score),
            children: [
              task.kind == WeaknessTaskKind.writing
                  ? _WritingTask(state: state, focusHanjaId: focusHanjaId)
                  : _ChoiceTask(state: state, focusHanjaId: focusHanjaId),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton.icon(
            onPressed: () =>
                ref.invalidate(weaknessSessionProvider(focusHanjaId)),
            icon: const Icon(Icons.refresh),
            label: const Text('집중 다시 불러오기'),
          ),
        ),
      ),
    );
  }
}

class _ChoiceTask extends ConsumerStatefulWidget {
  const _ChoiceTask({required this.state, required this.focusHanjaId});

  final WeaknessSessionState state;
  final String? focusHanjaId;

  @override
  ConsumerState<_ChoiceTask> createState() => _ChoiceTaskState();
}

class _ChoiceTaskState extends ConsumerState<_ChoiceTask> {
  bool _showFeedbackPopup = false;
  bool _isFeedbackSuccess = true;

  @override
  void didUpdateWidget(covariant _ChoiceTask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentTask?.key != widget.state.currentTask?.key ||
        oldWidget.state.currentTask?.retryCount !=
            widget.state.currentTask?.retryCount) {
      _showFeedbackPopup = false;
      _isFeedbackSuccess = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.state.currentTask!;
    final selected = widget.state.selectedAnswer;
    final isCorrect = selected == task.correctAnswer;
    final useHanjaFont = task.kind == WeaknessTaskKind.hunToHanja;
    return Stack(
      alignment: Alignment.center,
      children: [
        PlayfulPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TaskPrompt(task: task),
              const SizedBox(height: 16),
              for (final option in task.options) ...[
                _AnswerButton(
                  label: option,
                  useHanjaFont: useHanjaFont,
                  selected: selected == option,
                  correct: option == task.correctAnswer,
                  hasSelection: selected != null,
                  onPressed: () => _selectAnswer(task, option),
                ),
                const SizedBox(height: 8),
              ],
              if (selected != null) ...[
                const SizedBox(height: 2),
                _AnswerFeedbackText(
                  isCorrect: isCorrect,
                  correctAnswer: task.correctAnswer,
                ),
              ],
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: selected == null
                    ? null
                    : () => ref
                          .read(
                            weaknessSessionProvider(
                              widget.focusHanjaId,
                            ).notifier,
                          )
                          .nextOrFinish(),
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

  Future<void> _selectAnswer(WeaknessTask task, String answer) async {
    final provider = weaknessSessionProvider(widget.focusHanjaId);
    await ref.read(provider.notifier).selectAnswer(answer);
    final isCorrect = answer == task.correctAnswer;
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

class _WritingTask extends ConsumerStatefulWidget {
  const _WritingTask({required this.state, required this.focusHanjaId});

  final WeaknessSessionState state;
  final String? focusHanjaId;

  @override
  ConsumerState<_WritingTask> createState() => _WritingTaskState();
}

class _WritingTaskState extends ConsumerState<_WritingTask> {
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
  void didUpdateWidget(covariant _WritingTask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentTask?.key != widget.state.currentTask?.key ||
        oldWidget.state.index != widget.state.index) {
      _showSuccessPopup = false;
      _scoreResult = null;
      _restoreSavedStrokes();
    }
  }

  void _restoreSavedStrokes() {
    final task = widget.state.currentTask;
    final savedStrokes = task == null
        ? const <Path>[]
        : widget.state.writingStrokesFor(task.item.id);
    _strokes = savedStrokes;
    _hasStrokes = savedStrokes.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.state.currentTask!;
    final item = task.item;
    final hintLevel = widget.state.hintLevelFor(item.id);
    final provider = weaknessSessionProvider(widget.focusHanjaId);
    final isPassed = widget.state.passedTaskKeys.contains(task.key);
    final strokeOrderPaths = _expectedPaths(widget.state.svgPathsFor(item.id));
    final scoreResult = _scoreResult;
    final showsFailure = scoreResult != null && !scoreResult.passed;
    return Stack(
      alignment: Alignment.center,
      children: [
        PlayfulPanel(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TaskPrompt(task: task),
              const SizedBox(height: 10),
              HanjaFreeWritingCanvas(
                key: ValueKey('weakness-writing-${item.id}-$hintLevel'),
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
                _WritingFeedbackPanel(result: scoreResult),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: hintLevel >= 3 || isPassed
                          ? null
                          : ref.read(provider.notifier).recordWritingHint,
                      icon: const Icon(Icons.lightbulb),
                      label: Text(hintLevel == 0 ? '첫 획 힌트' : '힌트 더 보기'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isPassed
                          ? () => ref.read(provider.notifier).nextOrFinish()
                          : _hasStrokes
                          ? _checkWriting
                          : null,
                      icon: Icon(isPassed ? Icons.chevron_right : Icons.check),
                      label: Text(isPassed ? '다음' : '확인하기'),
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
    final task = widget.state.currentTask!;
    final item = task.item;
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
          .read(weaknessSessionProvider(widget.focusHanjaId).notifier)
          .recordWritingFailure();
      return;
    }
    ref
        .read(weaknessSessionProvider(widget.focusHanjaId).notifier)
        .markWritingPassed(item.id);
    await ref
        .read(weaknessSessionProvider(widget.focusHanjaId).notifier)
        .completeWriting();
    ref.read(appAudioControllerProvider).playSuccess();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      setState(() => _showSuccessPopup = false);
    });
  }

  String _hintTextFor(int hintLevel, HanjaCharacter item) {
    return switch (hintLevel) {
      0 => '${item.meaning}을 떠올리며 빈칸에 써요.',
      1 => '표시된 첫 획부터 천천히 시작해요.',
      2 => '획순을 보고 빈칸에 다시 써요.',
      _ => '${item.meaning} · 획순을 다시 확인해요.',
    };
  }
}

class _WritingFeedbackPanel extends StatelessWidget {
  const _WritingFeedbackPanel({required this.result});

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

class _CompleteView extends ConsumerWidget {
  const _CompleteView({required this.state, required this.focusHanjaId});

  final WeaknessSessionState state;
  final String? focusHanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlayfulPage(
      title: '집중 완료',
      subtitle: '연속 성공하면 집중 항목이 줄어들어요',
      children: [
        SessionRewardPanel(
          icon: Icons.flag_circle,
          title: '집중 완료',
          message: '약점 극복 보상이 성장에 반영됐어요.',
          stats: [
            SessionRewardStat(
              icon: Icons.flag,
              label: '확인',
              value: '${state.completedHanjaCount}/${state.hanjaCount}',
              color: AppColors.peach,
            ),
            SessionRewardStat(
              icon: Icons.check_circle,
              label: '성공',
              value: '${state.passedTaskKeys.length}/${state.tasks.length}',
              color: AppColors.green,
            ),
            SessionRewardStat(
              icon: Icons.star,
              label: '별점',
              value: sessionStarsText(
                successCount: state.completedHanjaCount,
                totalCount: state.hanjaCount,
              ),
              color: AppColors.blue,
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
                ref.invalidate(weaknessSessionProvider(focusHanjaId));
                context.go(RoutePaths.appLearn);
              },
              icon: const Icon(Icons.menu_book),
              label: const Text('학습으로'),
            ),
          ],
        ),
      ],
    );
  }
}

class _TaskPrompt extends StatelessWidget {
  const _TaskPrompt({required this.task});

  final WeaknessTask task;

  @override
  Widget build(BuildContext context) {
    final useHanjaFont = task.kind == WeaknessTaskKind.hanjaToHun;
    final label = switch (task.kind) {
      WeaknessTaskKind.hanjaToHun => '한자의 뜻과 소리를 골라요',
      WeaknessTaskKind.hunToHanja => '뜻과 소리에 맞는 한자를 골라요',
      WeaknessTaskKind.writing => null,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (label != null) ...[
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              task.prompt,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: useHanjaFont ? AppFonts.hanjaSerif : null,
                fontWeight: FontWeight.w900,
                fontSize: useHanjaFont ? 48 : 28,
              ),
            ),
          ],
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
      isCorrect ? '정답이에요!' : '틀렸어요. 정답은 $correctAnswer예요.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.useHanjaFont,
    required this.selected,
    required this.correct,
    required this.hasSelection,
    required this.onPressed,
  });

  final String label;
  final bool useHanjaFont;
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
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: useHanjaFont ? AppFonts.hanjaSerif : null,
          fontSize: useHanjaFont ? 28 : null,
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final int score;

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
          '$score점',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
