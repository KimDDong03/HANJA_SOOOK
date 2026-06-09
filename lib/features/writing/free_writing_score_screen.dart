import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/app_audio_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/playful_page.dart';
import '../../domain/services/free_writing_score_service.dart';
import 'widgets/hanja_free_writing_canvas.dart';
import 'writing_controller.dart';

class FreeWritingScoreScreen extends ConsumerStatefulWidget {
  const FreeWritingScoreScreen({super.key, required this.hanjaId});

  final String hanjaId;

  @override
  ConsumerState<FreeWritingScoreScreen> createState() =>
      _FreeWritingScoreScreenState();
}

class _FreeWritingScoreScreenState
    extends ConsumerState<FreeWritingScoreScreen> {
  List<Path> _strokes = const [];
  bool _isSaving = false;
  String? _feedbackMessage;
  int? _failedStrokeIndex;
  Path? _expectedHintPath;
  late DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(writingProvider(widget.hanjaId));

    return state.when(
      data: (data) {
        final hanja = data.hanja;
        if (hanja == null) {
          return const Scaffold(
            body: AppErrorView(message: '한자 데이터를 찾을 수 없습니다.'),
          );
        }

        return Scaffold(
          body: PlayfulPage(
            title: '자유쓰기 채점',
            subtitle: '가이드 없이 쓰고 실력을 확인해요',
            showHeader: false,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              PlayfulPanel(
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: SizedBox(
                        width: 76,
                        height: 76,
                        child: Center(
                          child: Text(
                            hanja.character,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontFamily: AppFonts.hanjaSerif,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        hanja.meaning,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PlayfulPanel(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                child: HanjaFreeWritingCanvas(
                  expectedStrokeCount: hanja.strokeCount,
                  canvasExtent: 344,
                  showTitle: false,
                  failedStrokeIndex: _failedStrokeIndex,
                  expectedHintPath: _expectedHintPath,
                  onStrokeTexture: _playStrokeTexture,
                  onStrokeTextureStop: _stopStrokeTexture,
                  onStrokesChanged: (strokes) {
                    setState(() {
                      _strokes = strokes;
                      _feedbackMessage = null;
                      _failedStrokeIndex = null;
                      _expectedHintPath = null;
                    });
                  },
                ),
              ),
              if (_feedbackMessage != null) ...[
                const SizedBox(height: 12),
                PlayfulPanel(
                  child: Row(
                    children: [
                      const Icon(Icons.refresh, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _feedbackMessage!,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 88),
            ],
          ),
          bottomNavigationBar: _FreeWritingBottomAction(
            icon: Icons.fact_check,
            label: _isSaving ? '채점 중' : '채점받기',
            onPressed: _scoreAndSaveResult(
              context: context,
              hanjaId: hanja.id,
              expectedSvgPaths: data.svgPaths,
              expectedStrokeCount: hanja.strokeCount,
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: AppLoading(message: '자유쓰기 데이터를 불러오는 중이에요')),
      error: (_, _) => Scaffold(
        body: AppErrorView(
          message: '자유쓰기 데이터를 불러오지 못했습니다.',
          onRetry: () => ref.invalidate(writingProvider(widget.hanjaId)),
        ),
      ),
    );
  }

  VoidCallback _scoreAndSaveResult({
    required BuildContext context,
    required String hanjaId,
    required List<String> expectedSvgPaths,
    required int? expectedStrokeCount,
  }) {
    return () async {
      if (_isSaving) {
        _showSnack(context, '채점하는 중이에요.');
        return;
      }
      if (_strokes.isEmpty) {
        _showSnack(context, '한자를 먼저 써주세요.');
        return;
      }
      setState(() => _isSaving = true);
      final scoreResult = ref
          .read(freeWritingScoreServiceProvider)
          .score(
            userStrokes: _strokes,
            expectedSvgPaths: expectedSvgPaths,
            expectedStrokeCount: expectedStrokeCount,
          );
      final timeSec = DateTime.now().difference(_startedAt).inSeconds;
      final result = await ref
          .read(writingCompletionControllerProvider)
          .completePractice(hanjaId);
      if (!context.mounted) {
        return;
      }
      context.go(
        RoutePaths.resultFor(
          hanjaId: hanjaId,
          earnedXp: result.earnedXp,
          completedCount: result.completedCount,
          totalCount: result.totalCount,
          writingPassed: scoreResult.passed,
          writingScore: scoreResult.score,
          writingAccuracy: scoreResult.score,
          writingStars: scoreResult.stars,
          writingTimeSec: timeSec,
        ),
      );
    };
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _playStrokeTexture() {
    ref.read(appAudioControllerProvider).playStrokeTexture();
  }

  void _stopStrokeTexture() {
    ref.read(appAudioControllerProvider).stopStrokeTexture();
  }
}

class _FreeWritingBottomAction extends StatelessWidget {
  const _FreeWritingBottomAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }
}
