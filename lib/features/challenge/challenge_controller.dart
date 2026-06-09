import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/challenge_result_repository_provider.dart';
import '../../data/repositories/class_room_repository_provider.dart';
import '../../data/repositories/learning_progress_repository_provider.dart';
import '../../domain/models/challenge_result.dart';
import '../../domain/models/class_ranking.dart';
import '../../domain/models/class_room.dart';
import '../../domain/repositories/class_room_repository.dart';
import '../../domain/services/challenge_result_service.dart';
import '../../domain/services/class_participation_service.dart';
import '../../core/constants/app_constants.dart';
import '../auth/current_profile_controller.dart';
import '../learning/learning_progress_controller.dart';
import 'challenge_result_tick.dart';

final challengeSummaryProvider = FutureProvider<ChallengeSummaryState>((
  ref,
) async {
  ref.watch(challengeResultTickProvider);
  ref.watch(learningProgressTickProvider);

  final profile = ref.watch(currentProfileProvider);
  final studentKey = currentStudentKey(ref);
  final learningDate = currentLearningDate();
  final challengeRepository = ref.watch(challengeResultRepositoryProvider);
  final progressRepository = ref.watch(learningProgressRepositoryProvider);
  final learnedHanjaIds = await progressRepository
      .getCompletedHanjaIdsForStudent(studentKey: studentKey);
  final todayResults = await challengeRepository.getChallengeResults(
    studentKeys: {studentKey},
    learningDate: learningDate,
  );

  var rankText = '준비중';
  var className = '반 미가입';
  var isSample = true;
  var hasJoinedClass = false;
  var rankingRows = _sampleTodayRankingRows;
  if (profile != null) {
    final classRepository = ref.watch(classRoomRepositoryProvider);
    final joinedClass = await const ClassParticipationService()
        .findPrimaryJoinedClass(
          classRepository: classRepository,
          studentKey: profile.id,
        );
    if (joinedClass != null) {
      className = joinedClass.className;
      hasJoinedClass = true;
      rankingRows = await _todayRankingRowsFor(
        ref: ref,
        classRepository: classRepository,
        classRoom: joinedClass,
        learningDate: learningDate,
        currentStudentKey: profile.id,
      );
      final myRank = _myRankFrom(rankingRows);
      if (myRank != null) {
        rankText = '${myRank.rank}위';
      }
      isSample = false;
    } else {
      rankText = '참여 필요';
    }
  } else {
    rankText = '참여 필요';
  }

  return ChallengeSummaryState(
    className: className,
    rankText: rankText,
    todayScore: todayResults.fold<int>(0, (sum, result) => sum + result.score),
    todayXp: todayResults.fold<int>(0, (sum, result) => sum + result.earnedXp),
    learnedHanjaCount: learnedHanjaIds.length,
    latestResult: todayResults.isEmpty ? null : todayResults.first,
    isSample: isSample,
    hasJoinedClass: hasJoinedClass,
    rankingRows: rankingRows,
  );
});

const _choiceChallengeMinLearnedHanjaCount =
    AppConstants.challengeMinLearnedHanjaCount;

Future<List<ClassRankingRow>> _todayRankingRowsFor({
  required Ref ref,
  required ClassRoomRepository classRepository,
  required ClassRoom classRoom,
  required String learningDate,
  required String currentStudentKey,
}) async {
  final members = await classRepository.getClassMembers(classId: classRoom.id);
  final studentKeys = {for (final member in members) member.studentKey};
  final challengeResults = await ref
      .watch(challengeResultRepositoryProvider)
      .getChallengeResults(
        studentKeys: studentKeys,
        learningDate: learningDate,
      );
  final progressRepository = ref.watch(learningProgressRepositoryProvider);
  final records = <ClassRankingRecord>[];

  for (var index = 0; index < members.length; index += 1) {
    final member = members[index];
    final memberResults = challengeResults.where(
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

  final rows = const ClassRankingService().buildRowsByMetric(
    records: records,
    currentStudentKey: currentStudentKey,
  )[ClassRankingMetric.today];
  return rows ?? const [];
}

ClassRankingRow? _myRankFrom(List<ClassRankingRow> rows) {
  for (final row in rows) {
    if (row.isMe) {
      return row;
    }
  }
  return null;
}

class ChallengeSummaryState {
  const ChallengeSummaryState({
    required this.className,
    required this.rankText,
    required this.todayScore,
    required this.todayXp,
    required this.learnedHanjaCount,
    required this.isSample,
    required this.hasJoinedClass,
    required this.rankingRows,
    this.latestResult,
  });

  final String className;
  final String rankText;
  final int todayScore;
  final int todayXp;
  final int learnedHanjaCount;
  final bool isSample;
  final bool hasJoinedClass;
  final List<ClassRankingRow> rankingRows;
  final ChallengeResult? latestResult;

  int get minLearnedHanjaCount => _choiceChallengeMinLearnedHanjaCount;

  int get flipBoardMinLearnedHanjaCount =>
      AppConstants.flipBoardMinLearnedHanjaCount;

  bool get canPlayChallengeGames => learnedHanjaCount >= minLearnedHanjaCount;

  bool get canPlayFlipBoard =>
      learnedHanjaCount >= flipBoardMinLearnedHanjaCount;

  String get latestSummary {
    final result = latestResult;
    if (result == null) {
      return '아직 기록 없음';
    }
    return switch (result.mode) {
      ChallengeMode.quizHanjaToHun ||
      ChallengeMode.quizHunToHanja ||
      ChallengeMode.quizMixed =>
        '퀴즈 ${result.correctCount}/${result.totalCount}',
      ChallengeMode.speedChoice =>
        '스피드 퀴즈 ${result.correctCount}/${result.totalCount}',
      ChallengeMode.flipBoard => '판뒤집기 ${result.flippedTileCount}판',
    };
  }
}

const _sampleTodayRankingRows = [
  ClassRankingRow(
    rank: 1,
    studentKey: 'sample-jiwoo',
    displayName: '지우',
    scoreText: '1,680점',
    isMe: false,
  ),
  ClassRankingRow(
    rank: 2,
    studentKey: 'sample-me',
    displayName: '나',
    scoreText: '1,250점',
    isMe: true,
  ),
  ClassRankingRow(
    rank: 3,
    studentKey: 'sample-seoyeon',
    displayName: '서연',
    scoreText: '1,120점',
    isMe: false,
  ),
];
