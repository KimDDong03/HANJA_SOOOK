import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import 'typing_game_controller.dart';

class TypingGameScreen extends ConsumerWidget {
  const TypingGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(typingGameProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('선택 게임')),
      body: SafeArea(
        child: state.when(
          data: (data) {
            if (data.rounds.isEmpty) {
              return const Center(child: Text('게임 데이터가 아직 없습니다.'));
            }
            if (data.isComplete) {
              return _GameCompleteView(data: data);
            }
            return _GameRoundView(data: data);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('게임을 불러오지 못했습니다.')),
        ),
      ),
    );
  }
}

class _GameRoundView extends ConsumerWidget {
  const _GameRoundView({required this.data});

  final TypingGameState data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final round = data.currentRound!;
    final selectedAnswer = data.selectedAnswer;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          '${data.currentIndex + 1}/${data.totalCount}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 20),
        Text(
          round.prompt,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '뜻에 맞는 한자를 고르세요.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        for (final option in round.options) ...[
          _AnswerButton(
            option: option,
            correctAnswer: round.correctAnswer,
            selectedAnswer: selectedAnswer,
            onPressed: () =>
                ref.read(typingGameProvider.notifier).selectAnswer(option),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
        if (selectedAnswer != null)
          Text(
            data.isSelectedCorrect ? '정답이에요.' : '다시 기억해 볼게요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: selectedAnswer == null
              ? null
              : () => ref.read(typingGameProvider.notifier).goNextOrSave(),
          child: Text(data.isLastRound ? '결과 저장' : '다음 문제'),
        ),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.option,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.onPressed,
  });

  final String option;
  final String correctAnswer;
  final String? selectedAnswer;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedAnswer != null;
    final isSelected = selectedAnswer == option;
    final isCorrect = correctAnswer == option;

    if (!hasSelection) {
      return OutlinedButton(onPressed: onPressed, child: Text(option));
    }

    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isCorrect
        ? colorScheme.primaryContainer
        : isSelected
        ? colorScheme.errorContainer
        : null;

    return OutlinedButton(
      onPressed: null,
      style: OutlinedButton.styleFrom(
        disabledBackgroundColor: backgroundColor,
        disabledForegroundColor: backgroundColor == null
            ? null
            : colorScheme.onPrimaryContainer,
      ),
      child: Text(option),
    );
  }
}

class _GameCompleteView extends StatelessWidget {
  const _GameCompleteView({required this.data});

  final TypingGameState data;

  @override
  Widget build(BuildContext context) {
    final result = data.savedResult!;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          '게임 완료',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '${result.correctCount}/${result.totalCount}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('점수 ${result.score}'),
                const SizedBox(height: 8),
                Text('걸린 시간 ${result.timeSec}초'),
              ],
            ),
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
        FilledButton(
          onPressed: () => context.go(RoutePaths.home),
          child: const Text('홈으로'),
        ),
      ],
    );
  }
}
