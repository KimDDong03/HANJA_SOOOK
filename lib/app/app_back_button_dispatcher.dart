import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/route_paths.dart';
import '../core/widgets/app_confirm_dialog.dart';

class AppBackButtonDispatcher extends RootBackButtonDispatcher {
  AppBackButtonDispatcher({required this.router});

  final GoRouter router;

  bool _isShowingExitDialog = false;

  bool shouldFrameworkHandleBack(bool canHandlePop) {
    return canHandlePop || _isHandledByDispatcher(_currentUri);
  }

  @override
  Future<bool> didPopRoute() => _handleBackPressed();

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    return _isHandledByDispatcher(_currentUri);
  }

  @override
  void handleCommitBackGesture() {
    unawaited(_handleBackPressed());
  }

  @override
  void handleCancelBackGesture() {}

  Future<bool> _handleBackPressed() async {
    final uri = _currentUri;
    final location = uri.path;
    if (!_isAppShellRoute(location)) {
      final fallbackRoute = _fallbackRouteFor(uri);
      if (fallbackRoute != null) {
        router.go(fallbackRoute);
        return true;
      }
      return super.didPopRoute();
    }

    if (!_isTopLevelAppTab(location)) {
      final didPop = await router.routerDelegate.popRoute();
      if (didPop) {
        return true;
      }
      router.go(_fallbackRouteFor(uri) ?? RoutePaths.appHome);
      return true;
    }

    final rootNavigator = router.routerDelegate.navigatorKey.currentState;
    if (rootNavigator?.canPop() ?? false) {
      final didPop = await router.routerDelegate.popRoute();
      if (didPop) {
        return true;
      }
    }

    unawaited(_confirmExit());
    return true;
  }

  Future<void> _confirmExit() async {
    if (_isShowingExitDialog) {
      return;
    }

    final context = router.routerDelegate.navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      return;
    }

    _isShowingExitDialog = true;
    try {
      final shouldExit = await showAppConfirmDialog(
        context: context,
        title: '종료하시겠습니까?',
        message: '한자쏘옥을 종료할까요?',
        confirmLabel: '종료',
        icon: Icons.logout,
        isDestructive: true,
      );

      if (shouldExit && context.mounted) {
        unawaited(SystemNavigator.pop());
      }
    } finally {
      _isShowingExitDialog = false;
    }
  }

  Uri get _currentUri => router.routeInformationProvider.value.uri;

  bool _isAppShellRoute(String location) {
    return location == RoutePaths.appHome || location.startsWith('/app/');
  }

  bool _isTopLevelAppTab(String location) {
    return location == RoutePaths.appHome ||
        location == RoutePaths.appLearn ||
        location == RoutePaths.appChallenge ||
        location == RoutePaths.appSettings;
  }

  bool _isHandledByDispatcher(Uri uri) {
    return _isTopLevelAppTab(uri.path) || _fallbackRouteFor(uri) != null;
  }

  String? _fallbackRouteFor(Uri uri) {
    final location = uri.path;
    if (location == RoutePaths.quizModes ||
        location == RoutePaths.challengeSpeedGame ||
        location == RoutePaths.competitiveFlipBoardLobby ||
        location == RoutePaths.flipBoard ||
        location == RoutePaths.classRanking) {
      return RoutePaths.appChallenge;
    }
    if (location == RoutePaths.quizPlay) {
      return RoutePaths.quizModes;
    }
    if (location == RoutePaths.dailySession ||
        location == RoutePaths.reviewSession ||
        location == RoutePaths.weaknessSession ||
        location.startsWith('/app/learn/hanja') ||
        location.startsWith('/app/learn/writing-modes') ||
        location.startsWith('/app/learn/guided-writing') ||
        location.startsWith('/app/learn/free-writing')) {
      return RoutePaths.appLearn;
    }
    if (location == RoutePaths.growth) {
      return RoutePaths.appHome;
    }
    if (location == RoutePaths.studentLinks ||
        location == RoutePaths.teacherPreview) {
      return RoutePaths.appSettings;
    }
    if (location == RoutePaths.result) {
      final isChallengeResult =
          uri.queryParameters['challengeResultId']?.trim().isNotEmpty ?? false;
      return isChallengeResult ? RoutePaths.appChallenge : RoutePaths.appHome;
    }
    return null;
  }
}
