import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import '../writing/widgets/animated_hanja_stroke_preview.dart';
import 'hanja_card_controller.dart';

class HanjaCardScreen extends ConsumerWidget {
  const HanjaCardScreen({super.key, required this.hanjaId});

  final String hanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hanjaCardProvider(hanjaId));

    return Scaffold(
      appBar: AppBar(title: const Text('한자 카드')),
      body: SafeArea(
        child: state.when(
          data: (data) {
            final hanja = data.hanja;
            if (hanja == null) {
              return const Center(child: Text('한자 데이터를 찾을 수 없습니다.'));
            }

            final example = data.examples.isEmpty ? null : data.examples.first;
            final svgPaths =
                data.strokeAsset?.svgPaths
                    ?.whereType<String>()
                    .where((path) => path.trim().isNotEmpty)
                    .toList() ??
                const <String>[];
            final hasStroke = svgPaths.isNotEmpty;

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  hanja.character,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  '${hanja.sound} · ${hanja.meaning}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '획수 ${hanja.strokeCount ?? '-'} · ${hanja.unitName ?? '단원 정보 없음'}',
                  textAlign: TextAlign.center,
                ),
                if (example != null) ...[
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            example.sentence,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (example.meaning != null) ...[
                            const SizedBox(height: 8),
                            Text(example.meaning!),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                if (hasStroke) ...[
                  const SizedBox(height: 24),
                  Text(
                    '획순 미리보기',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  AnimatedHanjaStrokePreview(svgPaths: svgPaths),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.push(RoutePaths.writing(hanja.id)),
                  child: Text(hasStroke ? '따라쓰기' : '자유쓰기'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push(RoutePaths.quiz),
                  child: const Text('퀴즈 시작'),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('한자 데이터를 불러오지 못했습니다.')),
        ),
      ),
    );
  }
}
