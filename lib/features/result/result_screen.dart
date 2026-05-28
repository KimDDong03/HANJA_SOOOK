import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import 'result_controller.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({
    super.key,
    required this.hanjaId,
    required this.earnedXp,
    required this.completedCount,
    required this.totalCount,
  });

  final String? hanjaId;
  final int? earnedXp;
  final int? completedCount;
  final int? totalCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      resultProvider(
        ResultArgs(
          hanjaId: hanjaId,
          earnedXp: earnedXp,
          completedCount: completedCount,
          totalCount: totalCount,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('학습 결과')),
      body: SafeArea(
        child: state.when(
          data: (data) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                data.isDailyComplete ? '오늘 학습 완료' : '연습 완료',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              if (data.completedHanja != null) ...[
                Text(
                  data.completedHanja!.character,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${data.completedHanja!.sound} · ${data.completedHanja!.meaning}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        '오늘의 한자 ${data.completedCount}/${data.totalCount}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '+${data.earnedXp} XP',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (data.nextHanja != null)
                FilledButton(
                  onPressed: () =>
                      context.push(RoutePaths.writing(data.nextHanja!.id)),
                  child: const Text('다음 한자 연습'),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go(RoutePaths.quiz),
                child: const Text('퀴즈 풀기'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go(RoutePaths.home),
                child: const Text('홈으로'),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('결과를 불러오지 못했습니다.')),
        ),
      ),
    );
  }
}
