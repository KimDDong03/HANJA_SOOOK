import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'growth_controller.dart';

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(growthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('성장')),
      body: SafeArea(
        child: state.when(
          data: (data) {
            final levelSpan =
                data.nextLevelRequiredXp - data.currentLevelRequiredXp;
            final levelProgress = data.totalXp - data.currentLevelRequiredXp;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  '레벨 ${data.level}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  '${data.totalXp} XP',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: levelSpan <= 0 ? 0 : levelProgress / levelSpan,
                ),
                const SizedBox(height: 8),
                Text(
                  '다음 레벨까지 ${data.nextLevelRequiredXp - data.totalXp} XP',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          '오늘의 학습',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${data.completedTodayCount}/${data.todayTotalCount}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('성장 정보를 불러오지 못했습니다.')),
        ),
      ),
    );
  }
}
