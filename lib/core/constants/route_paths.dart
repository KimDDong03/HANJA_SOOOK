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

  static const hanjaPattern = '/hanja/:hanjaId';
  static const writingPattern = '/writing/:hanjaId';

  static String hanja(String hanjaId) => '/hanja/$hanjaId';
  static String writing(String hanjaId) => '/writing/$hanjaId';

  static String resultFor({
    required String hanjaId,
    required int earnedXp,
    required int completedCount,
    required int totalCount,
  }) {
    return Uri(
      path: result,
      queryParameters: {
        'hanjaId': hanjaId,
        'earnedXp': earnedXp.toString(),
        'completedCount': completedCount.toString(),
        'totalCount': totalCount.toString(),
      },
    ).toString();
  }
}
