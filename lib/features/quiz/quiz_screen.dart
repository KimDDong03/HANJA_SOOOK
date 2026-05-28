import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import 'quiz_controller.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('퀴즈')),
      body: SafeArea(
        child: state.when(
          data: (data) {
            if (data.questions.isEmpty) {
              return const Center(child: Text('퀴즈 데이터가 아직 없습니다.'));
            }
            if (data.isComplete) {
              return _QuizCompleteView(data: data);
            }
            return _QuizQuestionView(data: data);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('퀴즈를 불러오지 못했습니다.')),
        ),
      ),
    );
  }
}

class _QuizQuestionView extends ConsumerWidget {
  const _QuizQuestionView({required this.data});

  final QuizState data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final question = data.currentQuestion!;
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
          question.prompt,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        for (final option in question.options) ...[
          _AnswerButton(
            option: option,
            correctAnswer: question.correctAnswer,
            selectedAnswer: selectedAnswer,
            onPressed: () =>
                ref.read(quizProvider.notifier).selectAnswer(option),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
        if (selectedAnswer != null) ...[
          Text(
            data.isSelectedCorrect ? '정답이에요.' : '다시 기억해 볼게요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (question.explanation != null) ...[
            const SizedBox(height: 8),
            Text(
              question.explanation!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: selectedAnswer == null
              ? null
              : () => ref.read(quizProvider.notifier).goNextOrSave(),
          child: Text(data.isLastQuestion ? '결과 저장' : '다음 문제'),
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

class _QuizCompleteView extends StatelessWidget {
  const _QuizCompleteView({required this.data});

  final QuizState data;

  @override
  Widget build(BuildContext context) {
    final result = data.savedResult!;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          '퀴즈 완료',
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
