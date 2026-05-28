import 'package:go_router/go_router.dart';

import '../core/constants/route_paths.dart';
import '../features/auth/login_screen.dart';
import '../features/game/typing_game_screen.dart';
import '../features/growth/growth_screen.dart';
import '../features/hanja_card/hanja_card_screen.dart';
import '../features/home/home_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/result/result_screen.dart';
import '../features/shared/placeholder_shell.dart';
import '../features/splash/splash_screen.dart';
import '../features/student_links/student_link_screen.dart';
import '../features/teacher_preview/teacher_preview_screen.dart';
import '../features/writing/writing_screen.dart';

final appRouter = GoRouter(
  initialLocation: RoutePaths.splash,
  routes: [
    GoRoute(
      path: RoutePaths.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RoutePaths.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RoutePaths.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: RoutePaths.hanjaPattern,
      builder: (context, state) =>
          HanjaCardScreen(hanjaId: state.pathParameters['hanjaId'] ?? ''),
    ),
    GoRoute(
      path: RoutePaths.writingPattern,
      builder: (context, state) =>
          WritingScreen(hanjaId: state.pathParameters['hanjaId'] ?? ''),
    ),
    GoRoute(
      path: RoutePaths.quiz,
      builder: (context, state) => const QuizScreen(),
    ),
    GoRoute(
      path: RoutePaths.game,
      builder: (context, state) => const TypingGameScreen(),
    ),
    GoRoute(
      path: RoutePaths.result,
      builder: (context, state) => ResultScreen(
        hanjaId: state.uri.queryParameters['hanjaId'],
        earnedXp: int.tryParse(state.uri.queryParameters['earnedXp'] ?? ''),
        completedCount: int.tryParse(
          state.uri.queryParameters['completedCount'] ?? '',
        ),
        totalCount: int.tryParse(state.uri.queryParameters['totalCount'] ?? ''),
      ),
    ),
    GoRoute(
      path: RoutePaths.growth,
      builder: (context, state) => const GrowthScreen(),
    ),
    GoRoute(
      path: RoutePaths.studentLinks,
      builder: (context, state) => const StudentLinkScreen(),
    ),
    GoRoute(
      path: RoutePaths.teacherPreview,
      builder: (context, state) => const TeacherPreviewScreen(),
    ),
  ],
  errorBuilder: (context, state) => const PlaceholderShell(
    title: '페이지를 찾을 수 없어요',
    message: '요청한 화면이 아직 준비되지 않았습니다.',
  ),
);
