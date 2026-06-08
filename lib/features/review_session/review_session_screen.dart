import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/app_audio_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';
import '../../domain/models/hanja_character.dart';
import '../writing/svg_path_parser.dart';
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
      ReviewSessionPhase.hanjaToHun =>
        '${state.index + 1}/${state.hanjaToHunQuestions.length} · 한자 보고 훈음',
      ReviewSessionPhase.hunToHanja =>
        '${state.index + 1}/${state.hunToHanjaQuestions.length} · 훈음 보고 한자',
      ReviewSessionPhase.writing =>
        '${state.index + 1}/${state.items.length} · 직접 써보기',
      ReviewSessionPhase.correction => '틀린 한자만 짧게 확인',
      ReviewSessionPhase.retry =>
        '${state.index + 1}/${state.retryQuestions.length} · 다시 확인',
      ReviewSessionPhase.complete => '오늘 복습 완료',
    };
  }

  Widget _bodyFor(
    BuildContext context,
    WidgetRef ref,
    ReviewSessionState state,
    String? focusHanjaId,
  ) {
    return switch (state.phase) {
      ReviewSessionPhase.hanjaToHun || ReviewSessionPhase.hunToHanja =>
        _QuestionStep(state: state, focusHanjaId: focusHanjaId),
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
      ReviewSessionPhase.complete => _CompleteStep(focusHanjaId: focusHanjaId),
    };
  }
}

class _QuestionStep extends ConsumerWidget {
  const _QuestionStep({required this.state, required this.focusHanjaId});

  final ReviewSessionState state;
  final String? focusHanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final question = state.currentQuestion!;
    final selected = state.selectedAnswer;
    return PlayfulPanel(
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
              onPressed: () => ref
                  .read(reviewSessionProvider(focusHanjaId).notifier)
                  .selectAnswer(option),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: selected == null
                ? null
                : ref.read(reviewSessionProvider(focusHanjaId).notifier).next,
            icon: const Icon(Icons.chevron_right),
            label: const Text('다음'),
          ),
        ],
      ),
    );
  }
}

class _RetryStep extends ConsumerWidget {
  const _RetryStep({required this.state, required this.focusHanjaId});

  final ReviewSessionState state;
  final String? focusHanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final question = state.currentRetryQuestion!;
    final selected = state.selectedAnswer;
    return PlayfulPanel(
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
              onPressed: () => ref
                  .read(reviewSessionProvider(focusHanjaId).notifier)
                  .selectRetryAnswer(option),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: selected == null
                ? null
                : () => ref
                      .read(reviewSessionProvider(focusHanjaId).notifier)
                      .nextRetryOrFinish(),
            icon: const Icon(Icons.check),
            label: Text(
              state.index >= state.retryQuestions.length - 1 ? '완료' : '다음',
            ),
          ),
        ],
      ),
    );
  }
}

class _WritingStep extends ConsumerWidget {
  const _WritingStep({required this.state, required this.focusHanjaId});

  final ReviewSessionState state;
  final String? focusHanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = state.currentWritingItem!;
    final hintLevel = state.hintLevelFor(item.id);
    final provider = reviewSessionProvider(focusHanjaId);
    final svgPaths = state.svgPathsFor(item.id);
    final strokeOrderPaths = _expectedPaths(svgPaths);
    return PlayfulPanel(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HanjaHeader(item: item),
          const SizedBox(height: 10),
          HanjaFreeWritingCanvas(
            key: ValueKey('review-writing-${item.id}-$hintLevel'),
            expectedStrokeCount: item.strokeCount,
            canvasExtent: 286,
            showTitle: false,
            initialStrokes: state.writingStrokesFor(item.id),
            expectedHintPath: hintLevel == 1
                ? _firstHintPath(strokeOrderPaths)
                : null,
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
                  onPressed: ref.read(provider.notifier).completeWriting,
                  icon: const Icon(Icons.check),
                  label: const Text('다 썼어요'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _hintTextFor(int hintLevel, HanjaCharacter item) {
    return switch (hintLevel) {
      0 => '기억나는 대로 먼저 써봐요.',
      1 => '표시된 첫 획부터 천천히 시작해요.',
      2 => '획순을 보고 빈칸에 다시 써요.',
      _ => '${item.character} · ${item.meaning}',
    };
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
          for (final item in state.missedItems) ...[
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
  const _CompleteStep({required this.focusHanjaId});

  final String? focusHanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle, size: 56, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(
            '복습 완료',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {
              ref.invalidate(reviewSessionProvider(focusHanjaId));
              context.go(RoutePaths.appLearn);
            },
            icon: const Icon(Icons.menu_book),
            label: const Text('학습으로'),
          ),
        ],
      ),
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
