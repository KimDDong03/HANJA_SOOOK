import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/app_loading.dart';
import 'widgets/animated_hanja_stroke_preview.dart';
import 'widgets/hanja_free_writing_canvas.dart';
import 'widgets/hanja_writing_practice_canvas.dart';
import 'writing_controller.dart';

class WritingScreen extends ConsumerWidget {
  const WritingScreen({super.key, required this.hanjaId});

  final String hanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(writingProvider(hanjaId));

    return Scaffold(
      appBar: AppBar(title: const Text('따라쓰기')),
      body: SafeArea(
        child: state.when(
          data: (data) => _WritingContent(data: data),
          loading: () => const AppLoading(message: '따라쓰기 데이터를 불러오는 중이에요'),
          error: (_, _) => AppErrorView(
            message: '획순 데이터를 불러오지 못했습니다.',
            onRetry: () => ref.invalidate(writingProvider(hanjaId)),
          ),
        ),
      ),
    );
  }
}

class _WritingContent extends ConsumerWidget {
  const _WritingContent({required this.data});

  final WritingState data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hanja = data.hanja;
    if (hanja == null) {
      return const AppErrorView(message: '한자 데이터를 찾을 수 없습니다.');
    }

    if (!data.hasStrokeGuide) {
      return _FreeWritingFallback(
        hanjaId: hanja.id,
        character: hanja.character,
        sound: hanja.sound,
        meaning: hanja.meaning,
        expectedStrokeCount: hanja.strokeCount,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          hanja.character,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '${hanja.sound} · ${hanja.meaning}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 18),
        Text('획순 애니메이션', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        AnimatedHanjaStrokePreview(svgPaths: data.svgPaths),
        const SizedBox(height: 12),
        _StrokeInfoBar(
          strokeCount: data.svgPaths.length,
          source: data.strokeAsset?.source ?? 'unknown',
        ),
        const SizedBox(height: 20),
        HanjaWritingPracticeCanvas(svgPaths: data.svgPaths),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => _completePractice(context, ref, hanja.id),
          icon: const Icon(Icons.check),
          label: const Text('연습 완료'),
        ),
      ],
    );
  }

  Future<void> _completePractice(
    BuildContext context,
    WidgetRef ref,
    String hanjaId,
  ) async {
    final result = await ref
        .read(writingCompletionControllerProvider)
        .completePractice(hanjaId);
    if (!context.mounted) {
      return;
    }
    context.push(
      RoutePaths.resultFor(
        hanjaId: hanjaId,
        earnedXp: result.earnedXp,
        completedCount: result.completedCount,
        totalCount: result.totalCount,
      ),
    );
  }
}

class _StrokeInfoBar extends StatelessWidget {
  const _StrokeInfoBar({required this.strokeCount, required this.source});

  final int strokeCount;
  final String source;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.gesture, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('$strokeCount획 · $source')),
            const Icon(Icons.play_arrow, size: 20),
            const SizedBox(width: 4),
            const Text('자동 재생'),
          ],
        ),
      ),
    );
  }
}

class _FreeWritingFallback extends ConsumerWidget {
  const _FreeWritingFallback({
    required this.hanjaId,
    required this.character,
    required this.sound,
    required this.meaning,
    required this.expectedStrokeCount,
  });

  final String hanjaId;
  final String character;
  final String sound;
  final String meaning;
  final int? expectedStrokeCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          character,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '$sound · $meaning',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 18),
        Text('획순 데이터가 없어 자유쓰기 모드로 진행합니다.', textAlign: TextAlign.center),
        const SizedBox(height: 20),
        HanjaFreeWritingCanvas(expectedStrokeCount: expectedStrokeCount),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () async {
            final result = await ref
                .read(writingCompletionControllerProvider)
                .completePractice(hanjaId);
            if (!context.mounted) {
              return;
            }
            context.push(
              RoutePaths.resultFor(
                hanjaId: hanjaId,
                earnedXp: result.earnedXp,
                completedCount: result.completedCount,
                totalCount: result.totalCount,
              ),
            );
          },
          icon: const Icon(Icons.check),
          label: const Text('완료'),
        ),
      ],
    );
  }
}
