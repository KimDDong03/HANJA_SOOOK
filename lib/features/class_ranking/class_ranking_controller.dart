import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/challenge_result_repository_provider.dart';
import '../../data/repositories/class_room_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/challenge_result.dart';
import '../../domain/models/class_ranking.dart';
import '../../domain/models/class_room.dart';
import '../../domain/services/challenge_result_service.dart';
import '../../domain/services/class_participation_service.dart';
import '../auth/current_profile_controller.dart';
import '../challenge/challenge_result_tick.dart';
import '../learning/learning_progress_controller.dart';

final classRankingProvider =
    AsyncNotifierProvider<ClassRankingController, ClassRankingState>(
      ClassRankingController.new,
    );

class ClassRankingController extends AsyncNotifier<ClassRankingState> {
  final ClassRankingService _rankingService = const ClassRankingService();

  @override
  Future<ClassRankingState> build() async {
    ref.watch(challengeResultTickProvider);
    ref.watch(learningProgressTickProvider);

    final selectedFilter = state.value?.selectedFilter ?? ClassRankingMetric.xp;
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) {
      return _sampleState(selectedFilter);
    }

    final classRepository = ref.watch(classRoomRepositoryProvider);
    final classRoom = await const ClassParticipationService()
        .findPrimaryJoinedClass(
          classRepository: classRepository,
          studentKey: profile.id,
        );
    if (classRoom == null) {
      return _sampleState(selectedFilter);
    }

    final members = await classRepository.getClassMembers(
      classId: classRoom.id,
    );
    if (members.isEmpty) {
      return ClassRankingState(
        className: classRoom.className,
        entriesByFilter: const {
          ClassRankingMetric.xp: [],
          ClassRankingMetric.today: [],
          ClassRankingMetric.flipBoard: [],
        },
        selectedFilter: selectedFilter,
        status: ClassRankingStatus.emptyClass,
      );
    }

    final records = await _buildRecords(
      members: members,
      currentStudentKey: profile.id,
    );

    return ClassRankingState(
      className: classRoom.className,
      entriesByFilter: _rankingService.buildRowsByMetric(
        records: records,
        currentStudentKey: profile.id,
      ),
      selectedFilter: selectedFilter,
      status: ClassRankingStatus.active,
    );
  }

  void selectFilter(ClassRankingMetric filter) {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(selectedFilter: filter));
  }

  Future<List<ClassRankingRecord>> _buildRecords({
    required List<ClassMember> members,
    required String currentStudentKey,
  }) async {
    final studentKeys = {for (final member in members) member.studentKey};
    final learningDate = currentLearningDate();
    final results = await ref
        .watch(challengeResultRepositoryProvider)
        .getChallengeResults(
          studentKeys: studentKeys,
          learningDate: learningDate,
        );
    final progressRepository = ref.watch(learningProgressRepositoryProvider);
    final records = <ClassRankingRecord>[];

    for (var index = 0; index < members.length; index += 1) {
      final member = members[index];
      final memberResults = results.where(
        (result) => result.studentKey == member.studentKey,
      );
      records.add(
        ClassRankingRecord(
          studentKey: member.studentKey,
          displayName: member.studentKey == currentStudentKey
              ? '나'
              : '친구${index + 1}',
          totalXp: await progressRepository.getTotalXp(
            studentKey: member.studentKey,
          ),
          todayChallengeScore: memberResults.fold<int>(
            0,
            (sum, result) => sum + result.score,
          ),
          flipBoardTiles: memberResults
              .where((result) => result.mode == ChallengeMode.flipBoard)
              .fold<int>(0, (sum, result) => sum + result.flippedTileCount),
        ),
      );
    }
    return records;
  }

  ClassRankingState _sampleState(ClassRankingMetric selectedFilter) {
    return ClassRankingState(
      className: '샘플 반',
      entriesByFilter: _sampleEntriesByFilter,
      selectedFilter: selectedFilter,
      status: ClassRankingStatus.sample,
    );
  }
}

enum ClassRankingStatus { sample, emptyClass, active }

class ClassRankingState {
  const ClassRankingState({
    required this.className,
    required this.entriesByFilter,
    this.selectedFilter = ClassRankingMetric.xp,
    this.status = ClassRankingStatus.active,
  });

  final String className;
  final Map<ClassRankingMetric, List<ClassRankingRow>> entriesByFilter;
  final ClassRankingMetric selectedFilter;
  final ClassRankingStatus status;

  bool get isSample => status == ClassRankingStatus.sample;

  bool get isEmptyClass => status == ClassRankingStatus.emptyClass;

  bool get isActual => status == ClassRankingStatus.active;

  List<ClassRankingRow> get entries {
    return entriesByFilter[selectedFilter] ?? const [];
  }

  ClassRankingRow? get myEntry {
    for (final entry in entries) {
      if (entry.isMe) {
        return entry;
      }
    }
    return null;
  }

  ClassRankingState copyWith({ClassRankingMetric? selectedFilter}) {
    return ClassRankingState(
      className: className,
      entriesByFilter: entriesByFilter,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      status: status,
    );
  }
}

const _sampleEntriesByFilter = {
  ClassRankingMetric.xp: [
    ClassRankingRow(
      rank: 1,
      studentKey: 'sample-1',
      displayName: '친구1',
      scoreText: '320 XP',
      isMe: false,
    ),
    ClassRankingRow(
      rank: 2,
      studentKey: 'sample-2',
      displayName: '친구2',
      scoreText: '280 XP',
      isMe: false,
    ),
    ClassRankingRow(
      rank: 3,
      studentKey: 'sample-me',
      displayName: '나',
      scoreText: '240 XP',
      isMe: true,
    ),
  ],
  ClassRankingMetric.today: [
    ClassRankingRow(
      rank: 1,
      studentKey: 'sample-2',
      displayName: '친구2',
      scoreText: '9점',
      isMe: false,
    ),
    ClassRankingRow(
      rank: 2,
      studentKey: 'sample-me',
      displayName: '나',
      scoreText: '8점',
      isMe: true,
    ),
    ClassRankingRow(
      rank: 3,
      studentKey: 'sample-1',
      displayName: '친구1',
      scoreText: '7점',
      isMe: false,
    ),
  ],
  ClassRankingMetric.flipBoard: [
    ClassRankingRow(
      rank: 1,
      studentKey: 'sample-me',
      displayName: '나',
      scoreText: '12판',
      isMe: true,
    ),
    ClassRankingRow(
      rank: 2,
      studentKey: 'sample-1',
      displayName: '친구1',
      scoreText: '10판',
      isMe: false,
    ),
    ClassRankingRow(
      rank: 3,
      studentKey: 'sample-2',
      displayName: '친구2',
      scoreText: '8판',
      isMe: false,
    ),
  ],
};
