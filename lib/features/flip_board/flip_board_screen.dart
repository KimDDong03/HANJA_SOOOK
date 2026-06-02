import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';
import '../writing/widgets/hanja_free_writing_canvas.dart';
import 'flip_board_controller.dart';

class FlipBoardScreen extends ConsumerStatefulWidget {
  const FlipBoardScreen({
    super.key,
    required this.mode,
    this.timeLimitSeconds = AppConstants.flipBoardTimeLimitSeconds,
  });

  final FlipBoardPlayMode mode;
  final int timeLimitSeconds;

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
    final provider = flipBoardProvider(
      FlipBoardGameConfig(
        mode: widget.mode,
        timeLimitSeconds: widget.timeLimitSeconds,
      ),
    );
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
                subtitle: _subtitleFor(state.mode),
                leading: _BackToChallengeButton(
                  onTap: () => context.go(RoutePaths.appChallenge),
                ),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _FlipBoardStatusBar(
                    remainingSeconds: state.remainingSeconds,
                    flippedTileCount: state.flippedTileCount,
                    score: state.score,
                  ),
                  const SizedBox(height: 10),
                  PlayfulPanel(
                    padding: const EdgeInsets.all(10),
                    child: GridView.builder(
                      itemCount: state.tiles.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.22,
                          ),
                      itemBuilder: (context, index) {
                        final tile = state.tiles[index];
                        return _FlipTile(
                          frontLabel: _frontLabelForTile(state, index),
                          backLabel: tile.answer,
                          owner: tile.owner,
                          isCompetitive: state.mode.isCompetitive,
                          isBackHanja: state.mode.usesDrawing,
                          isSelected:
                              !state.mode.usesDrawing &&
                              state.selectedTileIndex == index,
                          isOwned: state.isTileOwned(index),
                          isCorrect: state.isTileCorrect(index),
                          onTap: state.isTileOwned(index)
                              ? () => _showSnack(context, '이미 뒤집은 판이에요.')
                              : state.mode.usesDrawing
                              ? null
                              : () {
                                  controller.selectTile(index);
                                  _showSnack(context, '아래 입력칸에 훈음을 적어봐요.');
                                },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  PlayfulPanel(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.mode == FlipBoardPlayMode.typeMeaning) ...[
                          Text(
                            state.selectedTile == null
                                ? '뒤집을 판을 먼저 골라요'
                                : '선택한 한자의 훈음을 적어요',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 8),
                        ] else ...[
                          HanjaFreeWritingCanvas(
                            key: ValueKey(
                              'flip-drawing-${state.flippedTileCount}',
                            ),
                            expectedStrokeCount: null,
                            canvasExtent: 260,
                            showTitle: false,
                            onStrokesChanged: (strokes) {
                              setState(() => _strokes = strokes);
                            },
                          ),
                          const SizedBox(height: 6),
                        ],
                        OutlinedButton.icon(
                          onPressed: state.isActive
                              ? _submitAction(context, controller, state)
                              : null,
                          icon: const Icon(Icons.check),
                          label: const Text('답 확인'),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 24,
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 160),
                              child: state.feedbackMessage == null
                                  ? const SizedBox.shrink(
                                      key: ValueKey('flip-feedback-empty'),
                                    )
                                  : Text(
                                      state.feedbackMessage!,
                                      key: const ValueKey(
                                        'flip-feedback-message',
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.completedResult != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      '획득 XP ${state.completedResult!.earnedXp}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  String _subtitleFor(FlipBoardPlayMode mode) {
    return switch (mode) {
      FlipBoardPlayMode.drawHanja => '보이는 훈음 중 아는 한자를 빠르게 그려요',
      FlipBoardPlayMode.competitiveDrawHanja => '내 색깔 판의 훈음만 뒤집어요',
      FlipBoardPlayMode.typeMeaning => '한자만 보고 훈음을 적어서 판을 뒤집어요',
    };
  }

  String _frontLabelForTile(FlipBoardState state, int index) {
    final tile = state.tiles[index];
    if (!state.mode.usesDrawing) {
      return tile.label;
    }
    if (state.mode.isCompetitive) {
      return tile.owner == FlipBoardTileOwner.player ? tile.label : '상대 판';
    }
    return tile.label;
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
      leading: _BackToChallengeButton(
        onTap: () => context.go(RoutePaths.appChallenge),
      ),
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

class _BackToChallengeButton extends StatelessWidget {
  const _BackToChallengeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const SizedBox.square(
          dimension: 48,
          child: Icon(Icons.arrow_back, size: 28, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _FlipBoardStatusBar extends StatelessWidget {
  const _FlipBoardStatusBar({
    required this.remainingSeconds,
    required this.flippedTileCount,
    required this.score,
  });

  final int remainingSeconds;
  final int flippedTileCount;
  final int score;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            _FlipBoardStatusItem(
              icon: Icons.timer,
              label: '시간',
              value: '$remainingSeconds초',
            ),
            _FlipBoardStatusDivider(),
            _FlipBoardStatusItem(
              icon: Icons.grid_view,
              label: '판',
              value: '$flippedTileCount',
            ),
            _FlipBoardStatusDivider(),
            _FlipBoardStatusItem(
              icon: Icons.bolt,
              label: '점수',
              value: '$score',
            ),
          ],
        ),
      ),
    );
  }
}

class _FlipBoardStatusItem extends StatelessWidget {
  const _FlipBoardStatusItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlipBoardStatusDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 22, color: AppColors.border);
  }
}

class _FlipTile extends StatelessWidget {
  const _FlipTile({
    required this.frontLabel,
    required this.backLabel,
    required this.owner,
    required this.isCompetitive,
    required this.isBackHanja,
    required this.isSelected,
    required this.isOwned,
    required this.isCorrect,
    required this.onTap,
  });

  final String frontLabel;
  final String backLabel;
  final FlipBoardTileOwner owner;
  final bool isCompetitive;
  final bool isBackHanja;
  final bool isSelected;
  final bool isOwned;
  final bool isCorrect;
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
        final frontColor = isCorrect
            ? AppColors.green
            : isSelected
            ? AppColors.yellow
            : _frontColorFor(owner, isCompetitive);
        final tileColor =
            Color.lerp(frontColor, AppColors.green, colorProgress) ??
            frontColor;
        final displayLabel = isBackVisible ? backLabel : frontLabel;

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
                color: isCorrect
                    ? AppColors.primary
                    : isSelected
                    ? AppColors.primary
                    : AppColors.border,
                width: isCorrect || isSelected ? 2 : 1,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      displayLabel,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontFamily: isBackVisible && isBackHanja
                                ? AppFonts.hanjaSerif
                                : null,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  if (isCorrect)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _frontColorFor(FlipBoardTileOwner owner, bool isCompetitive) {
    if (!isCompetitive) {
      return AppColors.surface;
    }
    return switch (owner) {
      FlipBoardTileOwner.player => AppColors.blue,
      FlipBoardTileOwner.opponent => AppColors.navSelected,
    };
  }
}
