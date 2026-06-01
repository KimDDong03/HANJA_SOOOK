import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';
import '../writing/widgets/hanja_free_writing_canvas.dart';
import 'flip_board_controller.dart';

class FlipBoardScreen extends ConsumerStatefulWidget {
  const FlipBoardScreen({super.key, required this.mode});

  final FlipBoardPlayMode mode;

  @override
  ConsumerState<FlipBoardScreen> createState() => _FlipBoardScreenState();
}

class _FlipBoardScreenState extends ConsumerState<FlipBoardScreen> {
  List<Path> _strokes = const [];
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = flipBoardProvider(widget.mode);
    ref.listen(provider, (previous, next) {
      final previousResult = previous?.value?.completedResult;
      final nextResult = next.value?.completedResult;
      if (previousResult == null && nextResult != null) {
        context.go(RoutePaths.resultForChallenge(nextResult.id));
      }
      final previousFlippedCount = previous?.value?.flippedTileCount ?? 0;
      final nextState = next.value;
      final nextFlippedCount = nextState?.flippedTileCount ?? 0;
      if (nextFlippedCount > previousFlippedCount && _strokes.isNotEmpty) {
        setState(() => _strokes = const []);
      }
      if (nextState?.mode == FlipBoardPlayMode.typeMeaning &&
          nextState?.answerText.isEmpty == true &&
          _answerController.text.isNotEmpty) {
        _answerController.clear();
      }
    });
    final asyncState = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return Scaffold(
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton.icon(
            onPressed: () => ref.invalidate(provider),
            icon: const Icon(Icons.refresh),
            label: const Text('판뒤집기 다시 불러오기'),
          ),
        ),
        data: (state) => !state.canPlay
            ? _ChallengeLockedView(
                mode: state.mode,
                learnedCount: state.learnedHanjaCount,
                minCount: state.minLearnedHanjaCount,
              )
            : PlayfulPage(
                title: state.mode.label,
                subtitle: state.mode == FlipBoardPlayMode.drawHanja
                    ? '훈음만 보고 한자를 그려서 판을 뒤집어요'
                    : '한자만 보고 훈음을 적어서 판을 뒤집어요',
                children: [
                  Row(
                    children: [
                      PlayfulStat(
                        icon: Icons.timer,
                        label: '남은 시간',
                        value: '${state.remainingSeconds}초',
                        color: AppColors.yellow,
                      ),
                      const SizedBox(width: 10),
                      PlayfulStat(
                        icon: Icons.grid_view,
                        label: '뒤집은 판',
                        value: '${state.flippedTileCount}',
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 10),
                      PlayfulStat(
                        icon: Icons.bolt,
                        label: '점수',
                        value: '${state.score}',
                        color: AppColors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PlayfulPanel(
                    child: GridView.builder(
                      itemCount: state.tiles.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                      itemBuilder: (context, index) {
                        return _FlipTile(
                          label: state.tiles[index].label,
                          isSelected: state.selectedTileIndex == index,
                          isOwned: state.isTileOwned(index),
                          onTap: state.isTileOwned(index)
                              ? () => _showSnack(context, '이미 뒤집은 판이에요.')
                              : () {
                                  controller.selectTile(index);
                                  _showSnack(
                                    context,
                                    state.mode == FlipBoardPlayMode.typeMeaning
                                        ? '아래 입력칸에 훈음을 적어봐요.'
                                        : '아래 칸에 한자를 그려봐요.',
                                  );
                                },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  PlayfulPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          state.selectedTile == null
                              ? '뒤집을 판을 먼저 골라요'
                              : state.mode == FlipBoardPlayMode.typeMeaning
                              ? '선택한 한자의 훈음을 적어요'
                              : '선택한 훈음에 맞는 한자를 그려요',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 12),
                        if (state.mode == FlipBoardPlayMode.typeMeaning) ...[
                          TextFormField(
                            key: const ValueKey('flip-type-answer'),
                            controller: _answerController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: '예: 한 일',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: controller.updateAnswer,
                            onFieldSubmitted: (_) => controller.submitAnswer(),
                          ),
                          const SizedBox(height: 12),
                        ] else ...[
                          HanjaFreeWritingCanvas(
                            key: ValueKey(
                              'flip-drawing-${state.flippedTileCount}',
                            ),
                            expectedStrokeCount: null,
                            canvasExtent: 220,
                            showTitle: false,
                            onStrokesChanged: (strokes) {
                              setState(() => _strokes = strokes);
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                        OutlinedButton.icon(
                          onPressed: state.isActive
                              ? _submitAction(context, controller, state)
                              : null,
                          icon: const Icon(Icons.check),
                          label: const Text('답 확인'),
                        ),
                        if (state.feedbackMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            state.feedbackMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: state.isSaving
                        ? () => _showSnack(context, '결과를 저장하는 중이에요.')
                        : state.completedResult == null
                        ? controller.finishGame
                        : null,
                    icon: state.isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      state.completedResult == null ? '끝내기' : '저장 완료',
                    ),
                  ),
                  if (state.completedResult != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '획득 XP ${state.completedResult!.earnedXp}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => context.go(RoutePaths.classRanking),
                    icon: const Icon(Icons.leaderboard),
                    label: const Text('랭킹 보기'),
                  ),
                ],
              ),
      ),
    );
  }

  VoidCallback _submitAction(
    BuildContext context,
    FlipBoardController controller,
    FlipBoardState state,
  ) {
    if (state.mode == FlipBoardPlayMode.typeMeaning) {
      if (state.selectedTile == null) {
        return () => _showSnack(context, '뒤집을 판을 먼저 골라주세요.');
      }
      return state.answerText.trim().isEmpty
          ? () => _showSnack(context, '답을 먼저 적어주세요.')
          : controller.submitAnswer;
    }
    if (state.selectedTile == null) {
      return () => _showSnack(context, '뒤집을 판을 먼저 골라주세요.');
    }
    return _strokes.isEmpty
        ? () => _showSnack(context, '한자를 먼저 그려주세요.')
        : () => controller.submitDrawing(strokes: _strokes);
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _ChallengeLockedView extends StatelessWidget {
  const _ChallengeLockedView({
    required this.mode,
    required this.learnedCount,
    required this.minCount,
  });

  final FlipBoardPlayMode mode;
  final int learnedCount;
  final int minCount;

  @override
  Widget build(BuildContext context) {
    return PlayfulPage(
      title: mode.label,
      subtitle: '배운 한자로 도전해요',
      children: [
        PlayfulPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '배운 한자 $minCount개부터 시작할 수 있어요.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text('지금 $learnedCount개 배웠어요.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go(RoutePaths.appLearn),
                icon: const Icon(Icons.menu_book),
                label: const Text('학습하러 가기'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlipTile extends StatelessWidget {
  const _FlipTile({
    required this.label,
    required this.isSelected,
    required this.isOwned,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isOwned;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: isOwned ? 1 : 0),
      duration: const Duration(milliseconds: 460),
      curve: Curves.easeInOutCubic,
      builder: (context, flipProgress, child) {
        final isBackVisible = flipProgress > 0.5;
        final angle = isBackVisible
            ? (flipProgress * math.pi) - math.pi
            : flipProgress * math.pi;
        final colorProgress = isOwned ? flipProgress : 0.0;
        final frontColor = isSelected ? AppColors.yellow : AppColors.surface;
        final tileColor =
            Color.lerp(frontColor, AppColors.green, colorProgress) ??
            frontColor;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle),
          child: Material(
            color: tileColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
