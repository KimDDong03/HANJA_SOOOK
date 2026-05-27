class RoutePaths {
  const RoutePaths._();

  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const quiz = '/quiz';
  static const game = '/game';
  static const result = '/result';
  static const growth = '/growth';
  static const teacherPreview = '/teacher-preview';

  static const hanjaPattern = '/hanja/:hanjaId';
  static const writingPattern = '/writing/:hanjaId';

  static String hanja(String hanjaId) => '/hanja/$hanjaId';
  static String writing(String hanjaId) => '/writing/$hanjaId';
}
