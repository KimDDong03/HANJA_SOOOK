import '../models/hanja_character.dart';
import '../models/learning_progress_record.dart';

class LearningPlanService {
  const LearningPlanService();

  DailyLearningPlan buildDailyPlan({
    required List<HanjaCharacter> allItems,
    required List<LearningProgressRecord> progressRecords,
    required String learningDate,
    required int newItemLimit,
    required int reviewItemLimit,
    Set<String> reviewCompletedHanjaIds = const <String>{},
    String? chapterKey,
  }) {
    final recordsByHanja = _recordsByHanja(progressRecords);
    final learnedBeforeTodayIds = progressRecords
        .where((record) => record.learningDate.compareTo(learningDate) < 0)
        .map((record) => record.hanjaId)
        .toSet();
    final todayCompletedIds = progressRecords
        .where((record) => record.learningDate == learningDate)
        .map((record) => record.hanjaId)
        .toSet();
    final activeChapter = _activeChapter(
      allItems: allItems,
      learnedBeforeTodayIds: learnedBeforeTodayIds,
      chapterKey: chapterKey,
    );
    final selectedChapterKey = chapterKey?.trim();
    final isSelectedChapter =
        selectedChapterKey != null &&
        selectedChapterKey.isNotEmpty &&
        activeChapter?.key == selectedChapterKey;

    if (isSelectedChapter && activeChapter != null) {
      return DailyLearningPlan(
        reviewItems: const [],
        newItems: activeChapter.items,
        todayCompletedIds: todayCompletedIds,
        chapterKey: activeChapter.key,
        chapterName: activeChapter.name,
      );
    }

    final reviewItems = allItems
        .where((item) {
          final records = recordsByHanja[item.id];
          if (reviewCompletedHanjaIds.contains(item.id)) {
            return false;
          }
          return records != null &&
              _isReviewDue(records: records, learningDate: learningDate);
        })
        .take(reviewItemLimit)
        .toList();
    final reviewItemIds = reviewItems.map((item) => item.id).toSet();

    final newItemCandidates = (activeChapter?.items ?? allItems)
        .where(
          (item) =>
              !learnedBeforeTodayIds.contains(item.id) &&
              !reviewItemIds.contains(item.id),
        )
        .toList();
    final newItemSlots = activeChapter == null
        ? (newItemLimit - reviewItems.length).clamp(0, newItemLimit)
        : newItemCandidates.length;
    final newItems = newItemCandidates.take(newItemSlots).toList();

    return DailyLearningPlan(
      reviewItems: reviewItems,
      newItems: newItems,
      todayCompletedIds: todayCompletedIds,
      chapterKey: activeChapter?.key,
      chapterName: activeChapter?.name,
    );
  }

  HanjaChapter? _activeChapter({
    required List<HanjaCharacter> allItems,
    required Set<String> learnedBeforeTodayIds,
    required String? chapterKey,
  }) {
    final chapters = buildChapters(allItems);
    if (chapters.isEmpty) {
      return null;
    }

    if (chapterKey != null && chapterKey.trim().isNotEmpty) {
      for (final chapter in chapters) {
        if (chapter.key == chapterKey) {
          return chapter;
        }
      }
    }

    final hasChapterMetadata = allItems.any((item) {
      final unitCode = item.unitCode?.trim();
      final unitName = item.unitName?.trim();
      return (unitCode != null && unitCode.isNotEmpty) ||
          (unitName != null && unitName.isNotEmpty);
    });
    if (!hasChapterMetadata) {
      return null;
    }

    for (final chapter in chapters) {
      final hasPending = chapter.items.any(
        (item) => !learnedBeforeTodayIds.contains(item.id),
      );
      if (hasPending) {
        return chapter;
      }
    }
    return chapters.first;
  }

  List<HanjaChapter> buildChapters(List<HanjaCharacter> items) {
    final grouped = <String, List<HanjaCharacter>>{};
    for (final item in items) {
      final key = chapterKeyFor(item);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return [
      for (final entry in grouped.entries)
        HanjaChapter(
          key: entry.key,
          name: _chapterNameFor(entry.value),
          items: List<HanjaCharacter>.unmodifiable(entry.value),
        ),
    ];
  }

  String chapterKeyFor(HanjaCharacter item) {
    final unitCode = item.unitCode?.trim();
    if (unitCode != null && unitCode.isNotEmpty) {
      return unitCode;
    }
    final unitName = item.unitName?.trim();
    if (unitName != null && unitName.isNotEmpty) {
      return '${item.grade}-$unitName';
    }
    return '${item.grade}-default';
  }

  String _chapterNameFor(List<HanjaCharacter> items) {
    final first = items.first;
    final unitName = first.unitName?.trim();
    if (unitName != null && unitName.isNotEmpty) {
      return unitName;
    }
    return '${first.grade}학년 한자';
  }

  Map<String, List<LearningProgressRecord>> _recordsByHanja(
    List<LearningProgressRecord> records,
  ) {
    final grouped = <String, List<LearningProgressRecord>>{};
    for (final record in records) {
      grouped.putIfAbsent(record.hanjaId, () => []).add(record);
    }
    for (final rows in grouped.values) {
      rows.sort((a, b) => a.learningDate.compareTo(b.learningDate));
    }
    return grouped;
  }

  bool _isReviewDue({
    required List<LearningProgressRecord> records,
    required String learningDate,
  }) {
    final latestDate = records.last.learningDate;
    if (latestDate.compareTo(learningDate) > 0) {
      return false;
    }
    if (latestDate == learningDate) {
      return true;
    }

    final daysSinceLatest = _daysBetween(latestDate, learningDate);
    return daysSinceLatest >= _reviewIntervalDays(records.length);
  }

  int _reviewIntervalDays(int completionCount) {
    if (completionCount <= 1) {
      return 1;
    }
    if (completionCount == 2) {
      return 1;
    }
    if (completionCount == 3) {
      return 3;
    }
    if (completionCount == 4) {
      return 7;
    }
    return 14;
  }

  int _daysBetween(String fromDate, String toDate) {
    final from = _parseLearningDate(fromDate);
    final to = _parseLearningDate(toDate);
    if (from == null || to == null) {
      return 0;
    }
    return to.difference(from).inDays;
  }

  DateTime? _parseLearningDate(String value) {
    if (value.length != 8) {
      return null;
    }
    final year = int.tryParse(value.substring(0, 4));
    final month = int.tryParse(value.substring(4, 6));
    final day = int.tryParse(value.substring(6, 8));
    if (year == null || month == null || day == null) {
      return null;
    }
    return DateTime(year, month, day);
  }
}

class DailyLearningPlan {
  const DailyLearningPlan({
    required this.reviewItems,
    required this.newItems,
    required this.todayCompletedIds,
    this.chapterKey,
    this.chapterName,
  });

  final List<HanjaCharacter> reviewItems;
  final List<HanjaCharacter> newItems;
  final Set<String> todayCompletedIds;
  final String? chapterKey;
  final String? chapterName;

  List<HanjaCharacter> get items => [...reviewItems, ...newItems];

  Set<String> get itemIds => items.map((item) => item.id).toSet();

  int get completedCount {
    return items.where((item) => todayCompletedIds.contains(item.id)).length;
  }

  int get totalCount => items.length;

  HanjaCharacter? get currentItem {
    for (final item in items) {
      if (!todayCompletedIds.contains(item.id)) {
        return item;
      }
    }
    return items.isEmpty ? null : items.first;
  }

  bool isCompletedToday(String hanjaId) => todayCompletedIds.contains(hanjaId);

  bool isReviewItem(String hanjaId) {
    return reviewItems.any((item) => item.id == hanjaId);
  }
}

class HanjaChapter {
  const HanjaChapter({
    required this.key,
    required this.name,
    required this.items,
  });

  final String key;
  final String name;
  final List<HanjaCharacter> items;
}
