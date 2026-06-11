import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/app_slogan_banner.dart';
import '../../core/widgets/playful_page.dart';
import '../../domain/models/hanja_character.dart';
import '../../domain/models/learning_diagnostics.dart';
import '../../domain/services/learning_plan_service.dart';
import '../../domain/services/thinking_unit_image_service.dart';
import 'learn_controller.dart';

enum _LearnTab { review, library, weak }

const _learnPageSize = 6;

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  _LearnTab _selectedTab = _LearnTab.library;
  String? _selectedMajorUnitKey;
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
          const AppSloganBanner(),
          const SizedBox(height: 16),
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
                  _ProgressSummaryPanel(state: state),
                  const SizedBox(height: 16),
                  _LearnTabPanel(
                    state: state,
                    selectedTab: _selectedTab,
                    pageIndex: _pageByTab[_selectedTab] ?? 0,
                    onTabChanged: (tab) => setState(() => _selectedTab = tab),
                    onPageChanged: (pageIndex) =>
                        setState(() => _pageByTab[_selectedTab] = pageIndex),
                    selectedMajorUnitKey: _selectedMajorUnitKey,
                    onMajorUnitChanged: (key) =>
                        setState(() => _selectedMajorUnitKey = key),
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
          const SizedBox(height: 10),
          Text(
            '복습은 배운 날 바로 한 번 열리고 이후 1/3/7/14일 간격으로 이어져요. 집중은 같은 한자를 반복해서 틀리거나 쓰기 힌트/실패가 누적되면 생겨요.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
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
    required this.selectedMajorUnitKey,
    required this.onMajorUnitChanged,
  });

  final LearnLibraryState state;
  final _LearnTab selectedTab;
  final int pageIndex;
  final ValueChanged<_LearnTab> onTabChanged;
  final ValueChanged<int> onPageChanged;
  final String? selectedMajorUnitKey;
  final ValueChanged<String> onMajorUnitChanged;

  @override
  Widget build(BuildContext context) {
    final tabState = _TabState.from(state, selectedTab);
    if (selectedTab == _LearnTab.library) {
      return _ChapterTabPanel(
        state: state,
        selectedMajorUnitKey: selectedMajorUnitKey,
        onMajorUnitChanged: onMajorUnitChanged,
        onTabChanged: onTabChanged,
      );
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
          _LearnModeTabs(selectedTab: selectedTab, onTabChanged: onTabChanged),
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
                    status: state.statusForList(
                      pageItems[index].id,
                      _listKindForTab(selectedTab),
                    ),
                    weakness: selectedTab == _LearnTab.weak
                        ? state.primaryWeaknessFor(pageItems[index].id)
                        : null,
                    onTap: () => context.push(
                      _routeForTab(selectedTab, pageItems[index].id),
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
        subtitle: '단원 카드에서 단원 학습처럼 진행해요.',
        emptyText: '표시할 단원이 아직 없습니다.',
        items: state.items,
      ),
      _LearnTab.weak => _TabState(
        title: '집중해서 볼 한자',
        subtitle: '반복해서 헷갈린 한자를 유형별로 다시 잡아요.',
        emptyText: '지금 집중해서 볼 한자가 없어요.',
        items: state.weakItems,
      ),
    };
  }
}

class _ChapterTabPanel extends StatelessWidget {
  const _ChapterTabPanel({
    required this.state,
    required this.selectedMajorUnitKey,
    required this.onMajorUnitChanged,
    required this.onTabChanged,
  });

  final LearnLibraryState state;
  final String? selectedMajorUnitKey;
  final ValueChanged<String> onMajorUnitChanged;
  final ValueChanged<_LearnTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final majorUnits = _MajorUnitGroup.fromChapters(state.chapters);
    final activeUnit = _activeMajorUnit(
      majorUnits: majorUnits,
      selectedMajorUnitKey: selectedMajorUnitKey,
      activeChapterKey: state.primaryChapterKey,
    );

    return PlayfulPanel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LearnModeTabs(
            selectedTab: _LearnTab.library,
            onTabChanged: onTabChanged,
          ),
          const SizedBox(height: 16),
          Text(
            activeUnit == null ? '단원별 한자장' : activeUnit.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          if (majorUnits.isNotEmpty && activeUnit != null) ...[
            _MajorUnitSelector(
              groups: majorUnits,
              selectedKey: activeUnit.key,
              onSelected: onMajorUnitChanged,
            ),
            const SizedBox(height: 12),
          ],
          if (activeUnit == null)
            const _EmptyTabMessage(text: '표시할 단원이 아직 없습니다.')
          else
            for (final chapter in activeUnit.chapters)
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

class _MajorUnitSelector extends StatelessWidget {
  const _MajorUnitSelector({
    required this.groups,
    required this.selectedKey,
    required this.onSelected,
  });

  final List<_MajorUnitGroup> groups;
  final String selectedKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final group in groups) ...[
            _MajorUnitChip(
              label: group.shortLabel,
              selected: group.key == selectedKey,
              onTap: () => onSelected(group.key),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _LearnModeTabs extends StatelessWidget {
  const _LearnModeTabs({required this.selectedTab, required this.onTabChanged});

  final _LearnTab selectedTab;
  final ValueChanged<_LearnTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Material(
        color: Colors.white,
        shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LearnModeTabButton(
              icon: Icons.library_books,
              label: '한자장',
              selected: selectedTab == _LearnTab.library,
              onTap: () => onTabChanged(_LearnTab.library),
            ),
            const _TabDivider(),
            _LearnModeTabButton(
              icon: Icons.refresh,
              label: '복습',
              selected: selectedTab == _LearnTab.review,
              onTap: () => onTabChanged(_LearnTab.review),
            ),
            const _TabDivider(),
            _LearnModeTabButton(
              icon: Icons.flag,
              label: '집중',
              selected: selectedTab == _LearnTab.weak,
              onTap: () => onTabChanged(_LearnTab.weak),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnModeTabButton extends StatelessWidget {
  const _LearnModeTabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navSelected : Colors.white;
    return Expanded(
      child: Material(
        color: color,
        child: InkWell(
          onTap: selected ? null : onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabDivider extends StatelessWidget {
  const _TabDivider();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: AppColors.border, child: SizedBox(width: 1));
  }
}

class _MajorUnitChip extends StatelessWidget {
  const _MajorUnitChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.yellow : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: selected ? AppColors.yellow : AppColors.border),
      ),
      child: InkWell(
        onTap: selected ? null : onTap,
        borderRadius: BorderRadius.circular(999),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: Text(
            label,
            maxLines: 1,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _MajorUnitGroup {
  const _MajorUnitGroup({
    required this.key,
    required this.shortLabel,
    required this.title,
    required this.chapters,
  });

  final String key;
  final String shortLabel;
  final String title;
  final List<HanjaChapter> chapters;

  int get totalCount {
    return chapters.fold(0, (sum, chapter) => sum + chapter.items.length);
  }

  int completedCount(LearnLibraryState state) {
    return chapters.fold(
      0,
      (sum, chapter) => sum + state.completedCountInChapter(chapter),
    );
  }

  static List<_MajorUnitGroup> fromChapters(List<HanjaChapter> chapters) {
    final grouped = <String, List<HanjaChapter>>{};
    for (final chapter in chapters) {
      final key = _majorUnitKeyFor(chapter);
      grouped.putIfAbsent(key, () => []).add(chapter);
    }
    return [
      for (final entry in grouped.entries)
        _MajorUnitGroup(
          key: entry.key,
          shortLabel: _majorUnitShortLabel(entry.key, entry.value),
          title: _majorUnitTitle(entry.key, entry.value),
          chapters: List<HanjaChapter>.unmodifiable(entry.value),
        ),
    ];
  }
}

_MajorUnitGroup? _activeMajorUnit({
  required List<_MajorUnitGroup> majorUnits,
  required String? selectedMajorUnitKey,
  required String? activeChapterKey,
}) {
  for (final unit in majorUnits) {
    if (unit.key == selectedMajorUnitKey) {
      return unit;
    }
  }
  for (final unit in majorUnits) {
    if (unit.chapters.any((chapter) => chapter.key == activeChapterKey)) {
      return unit;
    }
  }
  return majorUnits.isEmpty ? null : majorUnits.first;
}

String _majorUnitKeyFor(HanjaChapter chapter) {
  final parsedKey = const ThinkingUnitImageService().majorUnitKeyForChapterKey(
    chapter.key,
  );
  if (parsedKey != null) {
    return parsedKey;
  }

  final keyMatch = RegExp(r'^(\d+)[-_](\d+)').firstMatch(chapter.key);
  if (keyMatch != null) {
    return 'G${keyMatch.group(1)}-U${keyMatch.group(2)!.padLeft(2, '0')}';
  }

  final nameMatch = RegExp(r'(\d+)\s*단원').firstMatch(chapter.name);
  if (nameMatch != null) {
    return 'U${nameMatch.group(1)!.padLeft(2, '0')}';
  }

  return chapter.key;
}

String _majorUnitShortLabel(String key, List<HanjaChapter> chapters) {
  final unitNumber = _unitNumberFromKey(key);
  if (unitNumber != null) {
    return '$unitNumber단원';
  }
  final nameMatch = RegExp(r'(\d+)\s*단원').firstMatch(chapters.first.name);
  if (nameMatch != null) {
    return '${nameMatch.group(1)}단원';
  }
  return chapters.first.name;
}

String _majorUnitTitle(String key, List<HanjaChapter> chapters) {
  final parts = _chapterTitleParts(chapters.first);
  if (parts.majorLabel != null && parts.storyTitle != null) {
    return '${parts.majorLabel} · ${parts.storyTitle}';
  }

  final gradeNumber = _gradeNumberFromKey(key);
  final unitNumber = _unitNumberFromKey(key);
  if (gradeNumber != null && unitNumber != null) {
    return '초$gradeNumber $unitNumber단원 한자장';
  }
  if (unitNumber != null) {
    return '$unitNumber단원 한자장';
  }
  return '${chapters.first.name} 한자장';
}

int? _gradeNumberFromKey(String key) {
  final match = RegExp(r'G(\d+)').firstMatch(key);
  return match == null ? null : int.tryParse(match.group(1)!);
}

int? _unitNumberFromKey(String key) {
  final match = RegExp(r'U(\d+)').firstMatch(key);
  return match == null ? null : int.tryParse(match.group(1)!);
}

_ChapterTitleParts _chapterTitleParts(HanjaChapter chapter) {
  final name = chapter.name.trim();
  final match = RegExp(
    r'^(초\d+)\s+(\d+단원)\s+(?:(\d+)\.\s*)?(.+)$',
  ).firstMatch(name);
  if (match == null) {
    return _ChapterTitleParts(rowTitle: name);
  }

  final majorLabel = '${match.group(1)} ${match.group(2)}';
  final lessonNumber = match.group(3);
  final storyTitle = match.group(4)?.trim();
  final subUnitTitle = const ThinkingUnitImageService()
      .subUnitTitleForChapterKey(chapter.key);
  final rowTitle = [
    if (lessonNumber != null) '$lessonNumber.',
    if (subUnitTitle != null)
      subUnitTitle
    else if (lessonNumber == null &&
        storyTitle != null &&
        storyTitle.isNotEmpty)
      storyTitle
    else if (lessonNumber != null)
      '소단원 $lessonNumber',
  ].join(' ');

  return _ChapterTitleParts(
    majorLabel: majorLabel,
    storyTitle: storyTitle,
    rowTitle: rowTitle.isEmpty ? name : rowTitle,
  );
}

class _ChapterTitleParts {
  const _ChapterTitleParts({
    required this.rowTitle,
    this.majorLabel,
    this.storyTitle,
  });

  final String? majorLabel;
  final String? storyTitle;
  final String rowTitle;
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
    final titleParts = _chapterTitleParts(chapter);
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
                        titleParts.rowTitle,
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
    this.weakness,
  });

  final HanjaCharacter item;
  final LearnItemStatus status;
  final VoidCallback onTap;
  final HanjaWeaknessRecord? weakness;

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
                        weakness == null
                            ? item.unitName ?? '교과서 단원 정보 없음'
                            : '${weakness!.typeLabel} · 집중 ${weakness!.score}점',
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
      LearnItemStatus.weak => AppColors.peach.withValues(alpha: 0.42),
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
      LearnItemStatus.weak => ('집중', AppColors.peach),
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

String _routeForTab(_LearnTab tab, String hanjaId) {
  return switch (tab) {
    _LearnTab.review => RoutePaths.reviewSessionFor(hanjaId),
    _LearnTab.weak => RoutePaths.weaknessSessionFor(hanjaId),
    _LearnTab.library => RoutePaths.guidedWriting(hanjaId),
  };
}

LearnItemListKind _listKindForTab(_LearnTab tab) {
  return switch (tab) {
    _LearnTab.review => LearnItemListKind.review,
    _LearnTab.library => LearnItemListKind.library,
    _LearnTab.weak => LearnItemListKind.weak,
  };
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
