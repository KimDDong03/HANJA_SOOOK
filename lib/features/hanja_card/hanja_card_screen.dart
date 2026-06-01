import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';
import '../writing/widgets/animated_hanja_stroke_preview.dart';
import 'hanja_card_controller.dart';

class HanjaCardScreen extends ConsumerWidget {
  const HanjaCardScreen({super.key, required this.hanjaId});

  final String hanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hanjaCardProvider(hanjaId));

    return Scaffold(
      body: state.when(
        data: (data) {
          final hanja = data.hanja;
          if (hanja == null) {
            return const Center(child: Text('한자 데이터를 찾을 수 없습니다.'));
          }

          final example = data.examples.isEmpty ? null : data.examples.first;
          final svgPaths = data.svgPaths;
          final hasStroke = data.hasStrokeGuide;

          return PlayfulPage(
            title: '한자 카드',
            subtitle: '보스 한자의 힘을 살펴봐요',
            showHeader: false,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              PlayfulPanel(
                child: Column(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 132,
                        child: Center(
                          child: Text(
                            hanja.character,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontFamily: AppFonts.hanjaSerif,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${hanja.sound} · ${hanja.meaning}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '획수 ${hanja.strokeCount ?? '-'} · ${hanja.unitName ?? '단원 정보 없음'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (example != null) ...[
                const SizedBox(height: 14),
                PlayfulPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '예문 보물',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        example.sentence,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (example.meaning != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          example.meaning!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push(
                  hasStroke
                      ? RoutePaths.guidedWriting(hanja.id)
                      : RoutePaths.freeWriting(hanja.id),
                ),
                icon: const Icon(Icons.brush),
                label: const Text('쓰기 연습 시작'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => context.push(RoutePaths.quizModes),
                icon: const Icon(Icons.quiz),
                label: const Text('퀴즈 시작'),
              ),
              if (!hasStroke) ...[
                const SizedBox(height: 12),
                const Text(
                  '획순 데이터가 없어 자유쓰기 채점으로 이어져요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
              if (hasStroke) ...[
                const SizedBox(height: 14),
                PlayfulPanel(
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '색깔 획순',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedHanjaStrokePreview(
                        svgPaths: svgPaths,
                        previewExtent: 220,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('한자 데이터를 불러오지 못했습니다.')),
      ),
    );
  }
}
