import 'package:go_router/go_router.dart';

import '../core/constants/route_paths.dart';
import '../features/auth/login_screen.dart';
import '../features/challenge/challenge_screen.dart';
import '../features/class_ranking/class_ranking_screen.dart';
import '../features/daily_session/daily_session_screen.dart';
import '../features/flip_board/competitive_flip_board_lobby_screen.dart';
import '../features/flip_board/flip_board_controller.dart';
import '../features/flip_board/flip_board_screen.dart';
import '../features/game/typing_game_screen.dart';
import '../features/growth/growth_screen.dart';
import '../features/hanja_card/hanja_card_screen.dart';
import '../features/home/home_screen.dart';
import '../features/learn/learn_screen.dart';
import '../features/quiz/quiz_controller.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/quiz/quiz_modes_screen.dart';
import '../features/result/result_screen.dart';
import '../features/role_select/role_select_screen.dart';
import '../features/review_session/review_session_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shared/placeholder_shell.dart';
import '../features/shell/app_shell.dart';
import '../features/splash/splash_screen.dart';
import '../features/student_links/student_link_screen.dart';
import '../features/teacher_preview/teacher_preview_screen.dart';
import '../features/textbook_gate/textbook_gate_screen.dart';
import '../features/weakness_session/weakness_session_screen.dart';
import '../features/writing/free_writing_score_screen.dart';
import '../features/writing/writing_mode_select_screen.dart';
import '../features/writing/writing_screen.dart';

final appRouter = GoRouter(
  initialLocation: RoutePaths.splash,
  routes: [
    GoRoute(
      path: RoutePaths.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RoutePaths.roleSelect,
      builder: (context, state) => const RoleSelectScreen(),
    ),
    GoRoute(
      path: RoutePaths.studentSetup,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RoutePaths.textbookGate,
      builder: (context, state) => const TextbookGateScreen(),
    ),
    GoRoute(
      path: RoutePaths.login,
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: RoutePaths.appHome,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: RoutePaths.appLearn,
          builder: (context, state) => const LearnScreen(),
        ),
        GoRoute(
          path: RoutePaths.dailySession,
          builder: (context, state) => DailySessionScreen(
            chapterKey: state.uri.queryParameters['chapter'],
          ),
        ),
        GoRoute(
          path: RoutePaths.reviewSession,
          builder: (context, state) => ReviewSessionScreen(
            focusHanjaId: state.uri.queryParameters['hanja'],
          ),
        ),
        GoRoute(
          path: RoutePaths.weaknessSession,
          builder: (context, state) => WeaknessSessionScreen(
            focusHanjaId: state.uri.queryParameters['hanja'],
          ),
        ),
        GoRoute(
          path: RoutePaths.appChallenge,
          builder: (context, state) => const ChallengeScreen(),
        ),
        GoRoute(
          path: RoutePaths.appSettings,
          builder: (context, state) => SettingsScreen(
            role: state.uri.queryParameters['role'] ?? 'student',
          ),
        ),
        GoRoute(
          path: RoutePaths.appHanjaPattern,
          builder: (context, state) =>
              HanjaCardScreen(hanjaId: state.pathParameters['hanjaId'] ?? ''),
        ),
        GoRoute(
          path: RoutePaths.writingModesPattern,
          builder: (context, state) => WritingModeSelectScreen(
            hanjaId: state.pathParameters['hanjaId'] ?? '',
          ),
        ),
        GoRoute(
          path: RoutePaths.guidedWritingPattern,
          builder: (context, state) =>
              WritingScreen(hanjaId: state.pathParameters['hanjaId'] ?? ''),
        ),
        GoRoute(
          path: RoutePaths.freeWritingPattern,
          builder: (context, state) => FreeWritingScoreScreen(
            hanjaId: state.pathParameters['hanjaId'] ?? '',
          ),
        ),
        GoRoute(
          path: RoutePaths.quizModes,
          builder: (context, state) => const QuizModesScreen(),
        ),
        GoRoute(
          path: RoutePaths.quizPlay,
          builder: (context, state) => QuizScreen(
            mode: QuizPlayMode.fromRouteValue(
              state.uri.queryParameters['mode'],
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.challengeSpeedGame,
          builder: (context, state) => const TypingGameScreen(),
        ),
        GoRoute(
          path: RoutePaths.competitiveFlipBoardLobby,
          builder: (context, state) => const CompetitiveFlipBoardLobbyScreen(),
        ),
        GoRoute(
          path: RoutePaths.flipBoard,
          redirect: (context, state) {
            final mode = FlipBoardPlayMode.fromRouteValue(
              state.uri.queryParameters['mode'],
            );
            final roomCode = state.uri.queryParameters['room']?.trim();
            if (mode.isCompetitive && (roomCode == null || roomCode.isEmpty)) {
              return RoutePaths.competitiveFlipBoardLobby;
            }
            return null;
          },
          builder: (context, state) {
            final mode = FlipBoardPlayMode.fromRouteValue(
              state.uri.queryParameters['mode'],
            );
            return FlipBoardScreen(
              mode: mode,
              timeLimitSeconds: FlipBoardGameConfig.timeLimitFromRouteValue(
                state.uri.queryParameters['time'],
              ),
            );
          },
        ),
        GoRoute(
          path: RoutePaths.classRanking,
          builder: (context, state) => const ClassRankingScreen(),
        ),
      ],
    ),
    GoRoute(
      path: RoutePaths.home,
      redirect: (context, state) => RoutePaths.appHome,
    ),
    GoRoute(
      path: RoutePaths.hanjaPattern,
      redirect: (context, state) =>
          RoutePaths.hanja(state.pathParameters['hanjaId'] ?? ''),
    ),
    GoRoute(
      path: RoutePaths.writingPattern,
      redirect: (context, state) =>
          RoutePaths.guidedWriting(state.pathParameters['hanjaId'] ?? ''),
    ),
    GoRoute(
      path: RoutePaths.quiz,
      redirect: (context, state) => RoutePaths.quizModes,
    ),
    GoRoute(
      path: RoutePaths.game,
      redirect: (context, state) => RoutePaths.challengeSpeedGame,
    ),
    GoRoute(
      path: RoutePaths.result,
      builder: (context, state) => ResultScreen(
        hanjaId: state.uri.queryParameters['hanjaId'],
        challengeResultId: state.uri.queryParameters['challengeResultId'],
        earnedXp: int.tryParse(state.uri.queryParameters['earnedXp'] ?? ''),
        completedCount: int.tryParse(
          state.uri.queryParameters['completedCount'] ?? '',
        ),
        totalCount: int.tryParse(state.uri.queryParameters['totalCount'] ?? ''),
        writingPassed: switch (state.uri.queryParameters['writingPassed']) {
          'true' => true,
          'false' => false,
          _ => null,
        },
        writingScore: int.tryParse(
          state.uri.queryParameters['writingScore'] ?? '',
        ),
        writingAccuracy: int.tryParse(
          state.uri.queryParameters['writingAccuracy'] ?? '',
        ),
        writingStars: int.tryParse(
          state.uri.queryParameters['writingStars'] ?? '',
        ),
        writingTimeSec: int.tryParse(
          state.uri.queryParameters['writingTimeSec'] ?? '',
        ),
      ),
    ),
    GoRoute(
      path: RoutePaths.growth,
      builder: (context, state) => const GrowthScreen(),
    ),
    GoRoute(
      path: RoutePaths.studentLinks,
      builder: (context, state) => StudentLinkScreen(
        role: state.uri.queryParameters['role'] ?? 'student',
      ),
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
