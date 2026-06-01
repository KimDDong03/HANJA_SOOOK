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
import '../../domain/models/hanja_character.dart';
import 'widgets/hanja_free_writing_canvas.dart';
import 'widgets/hanja_writing_practice_canvas.dart';
import 'writing_controller.dart';

class WritingScreen extends ConsumerWidget {
  const WritingScreen({super.key, required this.hanjaId});

  final String hanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(writingProvider(hanjaId));

    return state.when(
      data: (data) => _WritingContent(data: data),
      loading: () =>
          const Scaffold(body: AppLoading(message: '따라쓰기 데이터를 불러오는 중이에요')),
      error: (_, _) => Scaffold(
        body: AppErrorView(
          message: '획순 데이터를 불러오지 못했습니다.',
          onRetry: () => ref.invalidate(writingProvider(hanjaId)),
        ),
      ),
    );
  }
}

class _WritingBottomAction extends StatelessWidget {
  const _WritingBottomAction({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

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

class _WritingContent extends ConsumerStatefulWidget {
  const _WritingContent({required this.data});

  final WritingState data;

  @override
  ConsumerState<_WritingContent> createState() => _WritingContentState();
}

class _WritingContentState extends ConsumerState<_WritingContent> {
  static const _requiredRounds = 3;
  static const _wordExampleFallbacks = {
    '天': '천국, 천문 같은 낱말에 쓰여요.',
    '才': '재능, 천재 같은 낱말에 쓰여요.',
    '工': '공장, 공사 같은 낱말에 쓰여요.',
    '夫': '부부, 농부 같은 낱말에 쓰여요.',
    '社': '사회, 회사 같은 낱말에 쓰여요.',
  };

  int _roundIndex = 0;
  int _canvasRevision = 0;
  bool _isRoundComplete = false;
  String? _successMessage;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final hanja = data.hanja;
    if (hanja == null) {
      return const Scaffold(body: AppErrorView(message: '한자 데이터를 찾을 수 없습니다.'));
    }

    if (!data.hasStrokeGuide) {
      return _FreeWritingFallback(
        hanjaId: hanja.id,
        character: hanja.character,
        meaning: hanja.meaning,
        expectedStrokeCount: hanja.strokeCount,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          PlayfulPage(
            title: '직접 써보기',
            subtitle: hanja.meaning,
            showHeader: false,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              PlayfulPanel(
                child: Column(
                  children: [
                    Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: SizedBox(
                            width: 76,
                            height: 76,
                            child: Center(
                              child: Text(
                                hanja.character,
                                style: Theme.of(context).textTheme.displaySmall
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hanja.meaning,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _exampleText(hanja),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PlayfulPanel(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        _roundTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    HanjaWritingPracticeCanvas(
                      key: ValueKey(_canvasRevision),
                      svgPaths: data.svgPaths,
                      canvasExtent: 344,
                      autoPlayOnStart: _roundIndex == 0,
                      onStrokeTexture: _playStrokeTexture,
                      onCompleted: _handleRoundCompleted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 88),
            ],
          ),
          if (_successMessage != null)
            _WritingSuccessOverlay(message: _successMessage!),
        ],
      ),
      bottomNavigationBar: _WritingBottomAction(
        onPressed: () => _goNext(context, hanja.id),
        icon: _isRoundComplete
            ? Icons.check_circle
            : _isLastRound
            ? Icons.fact_check
            : Icons.edit,
        label: _bottomLabel,
      ),
    );
  }

  bool get _isLastRound => _roundIndex >= _requiredRounds - 1;

  String get _roundTitle {
    final step = '${_roundIndex + 1}/$_requiredRounds';
    return switch (_roundIndex) {
      0 => '$step  획순을 보고 따라 써요',
      1 => '$step  한 번 더 따라 써요',
      _ => '$step  마지막으로 또 써요',
    };
  }

  String get _bottomLabel {
    if (_isLastRound) {
      return '자유쓰기 채점';
    }
    if (_isRoundComplete) {
      return '다음 연습';
    }
    return '다 썼으면 다음 연습';
  }

  String _exampleText(HanjaCharacter hanja) {
    final example = widget.data.examples.isEmpty
        ? null
        : widget.data.examples.first;
    final sentence = example?.sentence.trim().isNotEmpty == true
        ? example!.sentence.trim()
        : hanja.exampleSentence?.trim();
    if (sentence != null && sentence.isNotEmpty) {
      return '예: $sentence';
    }
    final wordExample = _wordExampleFallbacks[hanja.character];
    if (wordExample != null) {
      return '예: $wordExample';
    }
    return '예: ${hanja.meaning}라는 뜻으로 쓰여요.';
  }

  void _goNext(BuildContext context, String hanjaId) {
    if (_isLastRound) {
      setState(() {
        _successMessage = null;
      });
      context.push(RoutePaths.freeWriting(hanjaId));
      return;
    }
    setState(() {
      _roundIndex += 1;
      _canvasRevision += 1;
      _isRoundComplete = false;
      _successMessage = null;
    });
  }

  void _handleRoundCompleted() {
    if (_isRoundComplete) {
      return;
    }
    setState(() {
      _isRoundComplete = true;
      _successMessage = _isLastRound ? '잘했어요! 이제 자유쓰기예요' : '잘했어요!';
    });
  }

  void _playStrokeTexture() {
    ref.read(appAudioControllerProvider).playStrokeTexture();
  }
}

class _WritingSuccessOverlay extends StatelessWidget {
  const _WritingSuccessOverlay({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.88 + (value * 0.12),
                child: child,
              ),
            );
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 34,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FreeWritingFallback extends ConsumerWidget {
  const _FreeWritingFallback({
    required this.hanjaId,
    required this.character,
    required this.meaning,
    required this.expectedStrokeCount,
  });

  final String hanjaId;
  final String character;
  final String meaning;
  final int? expectedStrokeCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlayfulPage(
      title: '직접 써보기',
      subtitle: meaning,
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
                  height: 108,
                  child: Center(
                    child: Text(
                      character,
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
              const SizedBox(height: 10),
              const Text(
                '획순 데이터가 없어도 괜찮아요. 자유롭게 써보고 점수를 받아요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PlayfulPanel(
          child: HanjaFreeWritingCanvas(
            expectedStrokeCount: expectedStrokeCount,
            canvasExtent: 172,
            onStrokeTexture: () {
              ref.read(appAudioControllerProvider).playStrokeTexture();
            },
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.push(RoutePaths.freeWriting(hanjaId)),
          icon: const Icon(Icons.fact_check),
          label: const Text('채점받기'),
        ),
      ],
    );
  }
}
