import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';
import '../auth/current_profile_controller.dart';
import 'home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final unitCarousel = ref.watch(homeUnitCarouselProvider);
    final growth = ref.watch(homeGrowthSummaryProvider);

    return Scaffold(
      body: PlayfulPage(
        title: profile == null ? '한자쏘옥 모험' : '안녕하세요, ${profile.displayName}!',
        subtitle: profile == null
            ? '오늘의 한자를 모아 별을 채워요'
            : '${profile.schoolName ?? '학교 미설정'} · ${profile.grade ?? '-'}학년',
        children: [
          unitCarousel.when(
            data: (state) => _UnitSlideCarousel(state: state),
            loading: () => const PlayfulPanel(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => PlayfulPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '단원 이미지를 불러오지 못했습니다.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(homeUnitCarouselProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 불러오기'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          growth.when(
            data: (state) => _GrowthSummaryPanel(state: state),
            loading: () => const PlayfulPanel(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => PlayfulPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('성장 정보를 불러오지 못했습니다.', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: ref.read(homeGrowthSummaryRetryProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 불러오기'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitSlideCarousel extends StatefulWidget {
  const _UnitSlideCarousel({required this.state});

  final HomeUnitCarouselState state;

  @override
  State<_UnitSlideCarousel> createState() => _UnitSlideCarouselState();
}

class _UnitSlideCarouselState extends State<_UnitSlideCarousel> {
  late final PageController _pageController;
  late int _pageIndex;

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.state.activeSlideIndex;
    _pageController = PageController(
      initialPage: _pageIndex,
      viewportFraction: 0.92,
    );
  }

  @override
  void didUpdateWidget(covariant _UnitSlideCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.grade == widget.state.grade &&
        oldWidget.state.slides.length == widget.state.slides.length) {
      return;
    }
    final nextIndex = widget.state.activeSlideIndex;
    _pageIndex = nextIndex;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(nextIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.state.slides;
    if (slides.isEmpty) {
      return PlayfulPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('표시할 단원이 아직 없습니다.', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go(RoutePaths.appLearn),
              icon: const Icon(Icons.menu_book),
              label: const Text('한자장 보기'),
            ),
          ],
        ),
      );
    }

    final pageIndex = _pageIndex >= slides.length
        ? slides.length - 1
        : _pageIndex;
    final activeSlide = slides[pageIndex];

    return _HomeUnitPanel(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _UnitSlideHeader(slide: activeSlide),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              onPageChanged: (index) => setState(() => _pageIndex = index),
              itemBuilder: (context, index) {
                return _UnitImagePage(
                  controller: _pageController,
                  index: index,
                  slide: slides[index],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _UnitSlideIndicator(index: pageIndex, count: slides.length),
          const SizedBox(height: 10),
          _UnitStudyStats(slide: activeSlide),
          const SizedBox(height: 10),
          _UnitStartButton(slide: activeSlide),
        ],
      ),
    );
  }
}

class _HomeUnitPanel extends StatelessWidget {
  const _HomeUnitPanel({required this.padding, required this.child});

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.018),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

Widget _subtleLiftTransition(Widget child, Animation<double> animation) {
  final offsetAnimation = Tween<Offset>(
    begin: const Offset(0, 0.035),
    end: Offset.zero,
  ).animate(animation);
  return FadeTransition(
    opacity: animation,
    child: SlideTransition(position: offsetAnimation, child: child),
  );
}

class _UnitSlideHeader extends StatelessWidget {
  const _UnitSlideHeader({required this.slide});

  final HomeUnitSlide slide;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 140),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: _subtleLiftTransition,
      child: DecoratedBox(
        key: ValueKey('title-${slide.chapterKey}'),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(
                slide.isUnlocked ? Icons.menu_book : Icons.lock,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  slide.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${slide.totalCount}자',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitImagePage extends StatelessWidget {
  const _UnitImagePage({
    required this.controller,
    required this.index,
    required this.slide,
  });

  final PageController controller;
  final int index;
  final HomeUnitSlide slide;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        var page = controller.initialPage.toDouble();
        if (controller.hasClients && controller.position.hasContentDimensions) {
          page = controller.page ?? page;
        }
        final distance = (page - index).abs().clamp(0.0, 1.0).toDouble();
        final scale = 1 - (distance * 0.028);
        final opacity = 1 - (distance * 0.18);
        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _UnitImage(assetPath: slide.imageAssetPath),
              if (!slide.isUnlocked) const _LockedUnitOverlay(),
              if (slide.isComplete) const _CompletedUnitOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitStartButton extends StatelessWidget {
  const _UnitStartButton({required this.slide});

  final HomeUnitSlide slide;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: slide.isUnlocked
          ? () => context.push(
              RoutePaths.dailySessionForChapter(slide.chapterKey),
            )
          : null,
      icon: Icon(
        slide.isComplete
            ? Icons.replay
            : slide.isUnlocked
            ? Icons.play_arrow
            : Icons.lock,
      ),
      label: Text(
        slide.isComplete
            ? '완료한 학습 다시 보기'
            : slide.isUnlocked
            ? '오늘 학습 시작'
            : '이전 학습 완료 후 열림',
      ),
    );
  }
}

class _UnitStudyStats extends StatelessWidget {
  const _UnitStudyStats({required this.slide});

  final HomeUnitSlide slide;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _UnitStudyStat(
          icon: Icons.auto_awesome,
          label: '완료',
          value: '${slide.completedCount}/${slide.totalCount}',
          color: AppColors.green,
        ),
        const SizedBox(width: 8),
        _UnitStudyStat(
          icon: Icons.local_fire_department,
          label: '새 한자',
          value: '${slide.newCount}개',
          color: AppColors.peach,
        ),
        const SizedBox(width: 8),
        _UnitStudyStat(
          icon: Icons.refresh,
          label: '복습',
          value: '${slide.reviewCount}개',
          color: AppColors.blue,
        ),
      ],
    );
  }
}

class _UnitStudyStat extends StatelessWidget {
  const _UnitStudyStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: AppColors.textPrimary),
              const SizedBox(width: 5),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitImage extends StatelessWidget {
  const _UnitImage({required this.assetPath});

  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    if (path == null) {
      return const ColoredBox(
        color: AppColors.surfaceMuted,
        child: Center(
          child: Icon(Icons.image_not_supported_outlined, size: 38),
        ),
      );
    }

    return ColoredBox(
      color: Colors.white,
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const ColoredBox(
            color: AppColors.surfaceMuted,
            child: Center(
              child: Icon(Icons.image_not_supported_outlined, size: 38),
            ),
          );
        },
      ),
    );
  }
}

class _LockedUnitOverlay extends StatelessWidget {
  const _LockedUnitOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white.withValues(alpha: 0.68),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.88),
            shape: BoxShape.circle,
          ),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Icon(Icons.lock, color: Colors.white, size: 34),
          ),
        ),
      ),
    );
  }
}

class _CompletedUnitOverlay extends StatelessWidget {
  const _CompletedUnitOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: AppColors.green.withValues(alpha: 0.20)),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.green, width: 4),
              ),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.76),
          child: Material(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '학습 완료',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
      ],
    );
  }
}

class _UnitSlideIndicator extends StatelessWidget {
  const _UnitSlideIndicator({required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var dotIndex = 0; dotIndex < count; dotIndex += 1)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: dotIndex == index ? 14 : 5,
                  height: dotIndex == index ? 6 : 5,
                  decoration: BoxDecoration(
                    color: dotIndex == index
                        ? AppColors.textPrimary
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GrowthSummaryPanel extends StatelessWidget {
  const _GrowthSummaryPanel({required this.state});

  final HomeGrowthSummaryState state;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryDark),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -26,
            child: Icon(
              Icons.auto_awesome,
              size: 116,
              color: Colors.white.withValues(alpha: 0.13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.military_tech,
                          color: AppColors.primary,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '레벨 ${state.level}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.levelTitle,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${state.totalXp}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Text(
                        'XP',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Spacer(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        child: Text(
                          '다음까지 ${state.remainingXp} XP',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 14,
                    color: AppColors.yellow,
                    backgroundColor: Colors.white.withValues(alpha: 0.24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
