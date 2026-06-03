import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';
import '../../domain/models/hanja_character.dart';
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
              title: '약점',
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
            title: '약점',
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
            label: const Text('약점 다시 불러오기'),
          ),
        ),
      ),
    );
  }
}

class _ChoiceTask extends ConsumerWidget {
  const _ChoiceTask({required this.state, required this.focusHanjaId});

  final WeaknessSessionState state;
  final String? focusHanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = state.currentTask!;
    final selected = state.selectedAnswer;
    final useHanjaFont = task.kind == WeaknessTaskKind.hunToHanja;
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TaskHeader(item: task.item),
          const SizedBox(height: 12),
          Text(
            task.prompt,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontFamily: task.kind == WeaknessTaskKind.hanjaToHun
                  ? AppFonts.hanjaSerif
                  : null,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          for (final option in task.options) ...[
            _AnswerButton(
              label: option,
              useHanjaFont: useHanjaFont,
              selected: selected == option,
              correct: option == task.correctAnswer,
              hasSelection: selected != null,
              onPressed: () => ref
                  .read(weaknessSessionProvider(focusHanjaId).notifier)
                  .selectAnswer(option),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: selected == null
                ? null
                : () => ref
                      .read(weaknessSessionProvider(focusHanjaId).notifier)
                      .nextOrFinish(),
            icon: const Icon(Icons.chevron_right),
            label: const Text('다음'),
          ),
        ],
      ),
    );
  }
}

class _WritingTask extends ConsumerWidget {
  const _WritingTask({required this.state, required this.focusHanjaId});

  final WeaknessSessionState state;
  final String? focusHanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = state.currentTask!;
    final item = task.item;
    final hintLevel = state.hintLevelFor(item.id);
    final provider = weaknessSessionProvider(focusHanjaId);
    final isPassed = state.passedTaskKeys.contains(task.key);
    return PlayfulPanel(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TaskHeader(item: item),
          const SizedBox(height: 10),
          HanjaFreeWritingCanvas(
            key: ValueKey('weakness-writing-${item.id}-$hintLevel'),
            expectedStrokeCount: item.strokeCount,
            canvasExtent: 286,
            showTitle: false,
            initialStrokes: state.writingStrokesFor(item.id),
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
                      : ref.read(provider.notifier).completeWriting,
                  icon: Icon(isPassed ? Icons.chevron_right : Icons.check),
                  label: Text(isPassed ? '다음' : '다 썼어요'),
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
      0 => '${item.meaning}을 보고 기억나는 대로 써요.',
      1 => '첫 획부터 떠올려요.',
      2 => '${item.character}의 큰 모양을 떠올려요.',
      _ => '${item.character} · ${item.meaning}',
    };
  }
}

class _CompleteView extends ConsumerWidget {
  const _CompleteView({required this.state, required this.focusHanjaId});

  final WeaknessSessionState state;
  final String? focusHanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlayfulPage(
      title: '약점 완료',
      subtitle: '연속 성공하면 약점이 해제돼요',
      children: [
        PlayfulPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  PlayfulStat(
                    icon: Icons.flag,
                    label: '확인',
                    value: '${state.completedHanjaCount}/${state.hanjaCount}',
                    color: AppColors.peach,
                  ),
                  const SizedBox(width: 10),
                  PlayfulStat(
                    icon: Icons.check_circle,
                    label: '성공',
                    value: '${state.passedTaskKeys.length}',
                    color: AppColors.green,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  ref.invalidate(weaknessSessionProvider(focusHanjaId));
                  context.go(RoutePaths.appLearn);
                },
                icon: const Icon(Icons.menu_book),
                label: const Text('학습으로'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskHeader extends StatelessWidget {
  const _TaskHeader({required this.item});

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
