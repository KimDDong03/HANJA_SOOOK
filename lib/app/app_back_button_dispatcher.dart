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
    return canHandlePop || _isTopLevelAppTab(_currentPath);
  }

  @override
  Future<bool> didPopRoute() => _handleBackPressed();

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    return _isTopLevelAppTab(_currentPath);
  }

  @override
  void handleCommitBackGesture() {
    unawaited(_handleBackPressed());
  }

  @override
  void handleCancelBackGesture() {}

  Future<bool> _handleBackPressed() async {
    final location = _currentPath;
    if (!_isAppShellRoute(location)) {
      return super.didPopRoute();
    }

    if (!_isTopLevelAppTab(location)) {
      final didPop = await router.routerDelegate.popRoute();
      if (didPop) {
        return true;
      }
      router.go(RoutePaths.appHome);
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

  String get _currentPath => router.routeInformationProvider.value.uri.path;

  bool _isAppShellRoute(String location) {
    return location == RoutePaths.appHome || location.startsWith('/app/');
  }

  bool _isTopLevelAppTab(String location) {
    return location == RoutePaths.appHome ||
        location == RoutePaths.appLearn ||
        location == RoutePaths.appChallenge ||
        location == RoutePaths.appSettings;
  }
}
