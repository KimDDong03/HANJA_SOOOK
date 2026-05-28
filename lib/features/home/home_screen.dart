import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import '../../domain/models/hanja_character.dart';
import '../auth/current_profile_controller.dart';
import 'home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final todayLearning = ref.watch(todayLearningProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('학생 홈')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              '오늘의 한자를 시작해요',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (profile != null) ...[
              const SizedBox(height: 12),
              Text(
                '${profile.displayName} · ${profile.schoolName ?? '학교 미설정'} · ${profile.grade ?? '-'}학년',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            todayLearning.when(
              data: (learning) {
                final hanja = learning.firstHanja;
                if (hanja == null) {
                  return const Text(
                    '오늘의 한자 데이터가 아직 없습니다.',
                    textAlign: TextAlign.center,
                  );
                }
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          hanja.character,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('${hanja.sound} · ${hanja.meaning}'),
                        const SizedBox(height: 8),
                        Text(
                          '오늘의 한자 ${learning.completedCount}/${learning.totalCount}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hanja.unitName ?? '교과서 단원 정보 없음',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final item in learning.items)
                              _HanjaChip(
                                item: item,
                                isCompleted: learning.isCompleted(item.id),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () =>
                              context.push(RoutePaths.hanja(hanja.id)),
                          child: const Text('오늘의 한자 보기'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Text(
                '오늘의 한자를 불러오지 못했습니다.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            todayLearning.maybeWhen(
              data: (learning) {
                final hanjaId = learning.firstHanja?.id;
                return Column(
                  children: [
                    _RouteButton(
                      label: '한자 카드',
                      onPressed: hanjaId == null
                          ? null
                          : () => context.push(RoutePaths.hanja(hanjaId)),
                    ),
                    _RouteButton(
                      label: '따라쓰기',
                      onPressed: hanjaId == null
                          ? null
                          : () => context.push(RoutePaths.writing(hanjaId)),
                    ),
                  ],
                );
              },
              orElse: () => const Column(
                children: [
                  _RouteButton(label: '한자 카드', onPressed: null),
                  _RouteButton(label: '따라쓰기', onPressed: null),
                ],
              ),
            ),
            _RouteButton(
              label: '퀴즈',
              onPressed: () => context.push(RoutePaths.quiz),
            ),
            _RouteButton(
              label: '게임',
              onPressed: () => context.push(RoutePaths.game),
            ),
            _RouteButton(
              label: '결과',
              onPressed: () => context.push(RoutePaths.result),
            ),
            _RouteButton(
              label: '성장',
              onPressed: () => context.push(RoutePaths.growth),
            ),
            _RouteButton(
              label: '학생 연결 관리',
              onPressed: () => context.push(RoutePaths.studentLinks),
            ),
            _RouteButton(
              label: '교사 미리보기',
              onPressed: () => context.push(RoutePaths.teacherPreview),
            ),
          ],
        ),
      ),
    );
  }
}

class _HanjaChip extends StatelessWidget {
  const _HanjaChip({required this.item, required this.isCompleted});

  final HanjaCharacter item;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: isCompleted ? const Icon(Icons.check, size: 18) : null,
      label: Text(
        item.character,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _RouteButton extends StatelessWidget {
  const _RouteButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FilledButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
