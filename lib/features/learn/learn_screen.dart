import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/services/learning_plan_service.dart';
import 'learn_controller.dart';

enum _LearnTab { review, library, weak }

const _learnPageSize = 6;

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  _LearnTab _selectedTab = _LearnTab.review;
  final Map<_LearnTab, int> _pageByTab = {
    _LearnTab.review: 0,
    _LearnTab.library: 0,
    _LearnTab.weak: 0,
  };

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(learnLibraryProvider);

    return Scaffold(
      body: PlayfulPage(
        title: '학습',
        subtitle: '복습하고, 한자장을 정리해요',
        children: [
          library.when(
            data: (state) {
              if (state.items.isEmpty) {
                return const PlayfulPanel(
                  child: Text(
                    '학습할 한자 데이터가 아직 없습니다.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PrimaryStudyPanel(state: state),
                  const SizedBox(height: 16),
                  _ProgressSummaryPanel(state: state),
                  const SizedBox(height: 16),
                  _LearnTabPanel(
                    state: state,
                    selectedTab: _selectedTab,
                    pageIndex: _pageByTab[_selectedTab] ?? 0,
                    onTabChanged: (tab) => setState(() => _selectedTab = tab),
                    onPageChanged: (pageIndex) =>
                        setState(() => _pageByTab[_selectedTab] = pageIndex),
                  ),
                ],
              );
            },
            loading: () => const PlayfulPanel(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const PlayfulPanel(
              child: Text('학습 데이터를 불러오지 못했습니다.', textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryStudyPanel extends StatelessWidget {
  const _PrimaryStudyPanel({required this.state});

  final LearnLibraryState state;

  @override
  Widget build(BuildContext context) {
    final item = state.primaryItem;
    final hasAction = item != null;
    final title = state.hasReviewDue
        ? '오늘 복습 ${state.reviewItems.length}개'
        : state.hasPendingItems
        ? state.activeChapter == null
              ? '다음 한자 학습'
              : state.primaryChapter!.name
        : '배운 한자 다시 보기';
    final subtitle = state.hasReviewDue
        ? '잊기 쉬운 한자부터 다시 써봐요'
        : state.hasPendingItems
        ? '단원에 들어있는 한자를 한 번에 배워요'
        : '완료한 한자를 한자장에서 확인해요';
    final buttonLabel = state.hasReviewDue
        ? '복습 시작'
        : state.hasPendingItems
        ? '학습 시작'
        : '한자장 보기';

    return PlayfulPanel(
      color: AppColors.yellow,
      borderColor: AppColors.yellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (item != null) ...[
                const SizedBox(width: 14),
                _HanjaPreviewMark(item: item),
              ],
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: hasAction
                ? () {
                    if (state.hasPendingItems || state.hasReviewDue) {
                      final chapterKey = state.primaryChapterKey;
                      context.push(
                        chapterKey == null
                            ? RoutePaths.dailySession
                            : RoutePaths.dailySessionForChapter(chapterKey),
                      );
                    } else {
                      context.push(RoutePaths.hanja(item.id));
                    }
                  }
                : null,
            icon: const Icon(Icons.play_arrow),
            label: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _ProgressSummaryPanel extends StatelessWidget {
  const _ProgressSummaryPanel({required this.state});

  final LearnLibraryState state;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  state.grade == null ? '내 한자장' : '${state.grade}학년 한자장',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${state.completedCount}/${state.totalCount}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: state.progressRatio,
            minHeight: 10,
            color: AppColors.primary,
            backgroundColor: AppColors.border.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(99),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              PlayfulStat(
                icon: Icons.menu_book,
                label: '배운 한자',
                value: '${state.completedCount}',
                color: AppColors.green,
              ),
              const SizedBox(width: 10),
              PlayfulStat(
                icon: Icons.refresh,
                label: '오늘 복습',
                value: '${state.reviewItems.length}',
                color: AppColors.blue,
              ),
              const SizedBox(width: 10),
              PlayfulStat(
                icon: Icons.flag,
                label: '더 연습',
                value: '${state.weakCount}',
                color: AppColors.peach,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LearnTabPanel extends StatelessWidget {
  const _LearnTabPanel({
    required this.state,
    required this.selectedTab,
    required this.pageIndex,
    required this.onTabChanged,
    required this.onPageChanged,
  });

  final LearnLibraryState state;
  final _LearnTab selectedTab;
  final int pageIndex;
  final ValueChanged<_LearnTab> onTabChanged;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final tabState = _TabState.from(state, selectedTab);
    if (selectedTab == _LearnTab.library) {
      return _ChapterTabPanel(state: state, onTabChanged: onTabChanged);
    }

    final pageCount = tabState.pageCount;
    final safePageIndex = pageCount == 0
        ? 0
        : pageIndex.clamp(0, pageCount - 1);
    final pageItems = tabState.items
        .skip(safePageIndex * _learnPageSize)
        .take(_learnPageSize)
        .toList();

    return PlayfulPanel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_LearnTab>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: _LearnTab.review,
                label: Text('복습'),
                icon: Icon(Icons.refresh),
              ),
              ButtonSegment(
                value: _LearnTab.library,
                label: Text('한자장'),
                icon: Icon(Icons.library_books),
              ),
              ButtonSegment(
                value: _LearnTab.weak,
                label: Text('약점'),
                icon: Icon(Icons.flag),
              ),
            ],
            selected: {selectedTab},
            onSelectionChanged: (selection) => onTabChanged(selection.first),
          ),
          const SizedBox(height: 16),
          Text(
            tabState.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tabState.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (tabState.items.isEmpty)
            _EmptyTabMessage(text: tabState.emptyText)
          else
            Column(
              children: [
                for (var index = 0; index < pageItems.length; index += 1)
                  _HanjaListRow(
                    item: pageItems[index],
                    status: state.statusOf(pageItems[index].id),
                    onTap: () => context.push(
                      RoutePaths.guidedWriting(pageItems[index].id),
                    ),
                  ),
                if (pageCount > 1) ...[
                  const SizedBox(height: 4),
                  _LearnPaginationBar(
                    pageIndex: safePageIndex,
                    pageCount: pageCount,
                    totalCount: tabState.items.length,
                    onPageChanged: onPageChanged,
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _TabState {
  const _TabState({
    required this.title,
    required this.subtitle,
    required this.emptyText,
    required this.items,
  });

  final String title;
  final String subtitle;
  final String emptyText;
  final List<HanjaCharacter> items;

  int get pageCount => (items.length / _learnPageSize).ceil();

  factory _TabState.from(LearnLibraryState state, _LearnTab tab) {
    return switch (tab) {
      _LearnTab.review => _TabState(
        title: '오늘 다시 볼 한자',
        subtitle: '복습할 한자만 모아 바로 연습해요.',
        emptyText: '오늘 복습할 한자는 없어요. 새 한자를 이어서 배워요.',
        items: state.reviewItems,
      ),
      _LearnTab.library => _TabState(
        title: '단원별 한자장',
        subtitle: '단원 카드에서 오늘 학습처럼 진행해요.',
        emptyText: '표시할 단원이 아직 없습니다.',
        items: state.items,
      ),
      _LearnTab.weak => _TabState(
        title: '더 연습할 한자',
        subtitle: '복습 시기가 된 한자를 먼저 보여줘요.',
        emptyText: '지금 더 연습할 한자가 없어요.',
        items: state.weakItems,
      ),
    };
  }
}

class _ChapterTabPanel extends StatelessWidget {
  const _ChapterTabPanel({required this.state, required this.onTabChanged});

  final LearnLibraryState state;
  final ValueChanged<_LearnTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_LearnTab>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: _LearnTab.review,
                label: Text('복습'),
                icon: Icon(Icons.refresh),
              ),
              ButtonSegment(
                value: _LearnTab.library,
                label: Text('한자장'),
                icon: Icon(Icons.library_books),
              ),
              ButtonSegment(
                value: _LearnTab.weak,
                label: Text('약점'),
                icon: Icon(Icons.flag),
              ),
            ],
            selected: const {_LearnTab.library},
            onSelectionChanged: (selection) => onTabChanged(selection.first),
          ),
          const SizedBox(height: 16),
          Text(
            '단원별 한자장',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '단원 카드에서 오늘 학습처럼 따라쓰기, 퀴즈, 랜덤 쓰기를 진행해요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (state.chapters.isEmpty)
            const _EmptyTabMessage(text: '표시할 단원이 아직 없습니다.')
          else
            for (final chapter in state.chapters)
              _ChapterListRow(
                chapter: chapter,
                completedCount: state.completedCountInChapter(chapter),
                isActive: chapter.key == state.primaryChapterKey,
                onTap: () => context.push(
                  RoutePaths.dailySessionForChapter(chapter.key),
                ),
              ),
        ],
      ),
    );
  }
}

class _ChapterListRow extends StatelessWidget {
  const _ChapterListRow({
    required this.chapter,
    required this.completedCount,
    required this.isActive,
    required this.onTap,
  });

  final HanjaChapter chapter;
  final int completedCount;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final totalCount = chapter.items.length;
    final ratio = totalCount == 0 ? 0.0 : completedCount / totalCount;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isActive
            ? AppColors.yellow.withValues(alpha: 0.82)
            : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        chapter.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$completedCount/$totalCount',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: ratio,
                  minHeight: 8,
                  color: AppColors.primary,
                  backgroundColor: AppColors.border.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(99),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final item in chapter.items.take(8))
                      Text(
                        item.character,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: AppFonts.hanjaSerif,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    if (chapter.items.length > 8)
                      Text(
                        '+${chapter.items.length - 8}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LearnPaginationBar extends StatelessWidget {
  const _LearnPaginationBar({
    required this.pageIndex,
    required this.pageCount,
    required this.totalCount,
    required this.onPageChanged,
  });

  final int pageIndex;
  final int pageCount;
  final int totalCount;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () {
            if (pageIndex == 0) {
              _showSnack(context, '첫 페이지예요.');
              return;
            }
            onPageChanged(pageIndex - 1);
          },
          icon: const Icon(Icons.chevron_left),
          tooltip: '이전 페이지',
        ),
        Expanded(
          child: Text(
            '${pageIndex + 1} / $pageCount · $totalCount개',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: () {
            if (pageIndex >= pageCount - 1) {
              _showSnack(context, '마지막 페이지예요.');
              return;
            }
            onPageChanged(pageIndex + 1);
          },
          icon: const Icon(Icons.chevron_right),
          tooltip: '다음 페이지',
        ),
      ],
    );
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}

class _HanjaListRow extends StatelessWidget {
  const _HanjaListRow({
    required this.item,
    required this.status,
    required this.onTap,
  });

  final HanjaCharacter item;
  final LearnItemStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: _statusBackground(status),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _HanjaSmallMark(item: item),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.meaning,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.unitName ?? '교과서 단원 정보 없음',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusBackground(LearnItemStatus status) {
    return switch (status) {
      LearnItemStatus.reviewDue => AppColors.blue.withValues(alpha: 0.32),
      LearnItemStatus.learned => AppColors.green.withValues(alpha: 0.32),
      LearnItemStatus.notLearned => AppColors.surface,
    };
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final LearnItemStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      LearnItemStatus.reviewDue => ('복습', AppColors.blue),
      LearnItemStatus.learned => ('배움', AppColors.green),
      LearnItemStatus.notLearned => ('미학습', AppColors.surfaceMuted),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _HanjaPreviewMark extends StatelessWidget {
  const _HanjaPreviewMark({required this.item});

  final HanjaCharacter item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: SizedBox.square(
        dimension: 82,
        child: Center(
          child: Text(
            item.character,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontFamily: AppFonts.hanjaSerif,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _HanjaSmallMark extends StatelessWidget {
  const _HanjaSmallMark({required this.item});

  final HanjaCharacter item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: SizedBox.square(
        dimension: 54,
        child: Center(
          child: Text(
            item.character,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: AppFonts.hanjaSerif,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyTabMessage extends StatelessWidget {
  const _EmptyTabMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
