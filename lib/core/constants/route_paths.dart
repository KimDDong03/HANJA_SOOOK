class RoutePaths {
  const RoutePaths._();

  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const quiz = '/quiz';
  static const game = '/game';
  static const result = '/result';
  static const growth = '/growth';
  static const studentLinks = '/student-links';
  static const teacherPreview = '/teacher-preview';
  static const roleSelect = '/role-select';
  static const studentSetup = '/student-setup';
  static const textbookGate = '/textbook-gate';

  static const appHome = '/app/home';
  static const appLearn = '/app/learn';
  static const dailySession = '/app/learn/daily-session';
  static const appChallenge = '/app/challenge';
  static const appSettings = '/app/settings';

  static const appHanjaPattern = '/app/learn/hanja/:hanjaId';
  static const writingModesPattern = '/app/learn/writing-modes/:hanjaId';
  static const guidedWritingPattern = '/app/learn/guided-writing/:hanjaId';
  static const freeWritingPattern = '/app/learn/free-writing/:hanjaId';

  static const quizModes = '/app/challenge/quiz';
  static const quizPlay = '/app/challenge/quiz/play';
  static const challengeSpeedGame = '/app/challenge/speed-game';
  static const flipBoard = '/app/challenge/flip-board';
  static const classRanking = '/app/challenge/ranking';

  static const hanjaPattern = '/hanja/:hanjaId';
  static const writingPattern = '/writing/:hanjaId';

  static String hanja(String hanjaId) => '/app/learn/hanja/$hanjaId';
  static String writingModes(String hanjaId) =>
      '/app/learn/writing-modes/$hanjaId';
  static String guidedWriting(String hanjaId, {String? mode}) {
    final path = '/app/learn/guided-writing/$hanjaId';
    if (mode == null) {
      return path;
    }
    return Uri(path: path, queryParameters: {'mode': mode}).toString();
  }

  static String freeWriting(String hanjaId) =>
      '/app/learn/free-writing/$hanjaId';
  static String dailySessionForChapter(String chapterKey) {
    return Uri(
      path: dailySession,
      queryParameters: {'chapter': chapterKey},
    ).toString();
  }

  static String writing(String hanjaId) => guidedWriting(hanjaId);
  static String quizPlayFor(String mode) {
    return Uri(path: quizPlay, queryParameters: {'mode': mode}).toString();
  }

  static String flipBoardFor(String mode) {
    return Uri(path: flipBoard, queryParameters: {'mode': mode}).toString();
  }

  static String studentLinksFor(String role) {
    return Uri(path: studentLinks, queryParameters: {'role': role}).toString();
  }

  static String resultForChallenge(String challengeResultId) {
    return Uri(
      path: result,
      queryParameters: {'challengeResultId': challengeResultId},
    ).toString();
  }

  static String resultFor({
    required String hanjaId,
    required int earnedXp,
    required int completedCount,
    required int totalCount,
    bool? writingPassed,
    int? writingScore,
    int? writingAccuracy,
    int? writingStars,
    int? writingTimeSec,
  }) {
    return Uri(
      path: result,
      queryParameters: {
        'hanjaId': hanjaId,
        'earnedXp': earnedXp.toString(),
        'completedCount': completedCount.toString(),
        'totalCount': totalCount.toString(),
        if (writingPassed != null) 'writingPassed': writingPassed.toString(),
        if (writingScore != null) 'writingScore': writingScore.toString(),
        if (writingAccuracy != null)
          'writingAccuracy': writingAccuracy.toString(),
        if (writingStars != null) 'writingStars': writingStars.toString(),
        if (writingTimeSec != null) 'writingTimeSec': writingTimeSec.toString(),
      },
    ).toString();
  }
}
