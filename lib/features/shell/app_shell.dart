import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/app_audio_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/app_confirm_dialog.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final musicTrack = _musicTrackFor(location);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(appAudioControllerProvider).setMusicTrack(musicTrack));
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        await _handleBackPressed(context, location);
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex(location),
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go(RoutePaths.appHome);
                  return;
                case 1:
                  context.go(RoutePaths.appLearn);
                  return;
                case 2:
                  context.go(RoutePaths.appChallenge);
                  return;
                case 3:
                  context.go(RoutePaths.appSettings);
                  return;
              }
            },
            destinations: const [
              NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: '홈',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.menu_book),
                icon: Icon(Icons.menu_book_outlined),
                label: '학습',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.emoji_events),
                icon: Icon(Icons.emoji_events_outlined),
                label: '도전',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.settings),
                icon: Icon(Icons.settings_outlined),
                label: '설정',
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _selectedIndex(String location) {
    if (location.startsWith(RoutePaths.appLearn)) {
      return 1;
    }
    if (location.startsWith(RoutePaths.appChallenge)) {
      return 2;
    }
    if (location.startsWith(RoutePaths.appSettings)) {
      return 3;
    }
    return 0;
  }

  AppMusicTrack _musicTrackFor(String location) {
    if (location == RoutePaths.dailySession ||
        location.startsWith('/app/learn/hanja') ||
        location.startsWith('/app/learn/writing-modes') ||
        location.startsWith('/app/learn/guided-writing') ||
        location.startsWith('/app/learn/free-writing') ||
        location == RoutePaths.quizPlay ||
        location == RoutePaths.challengeSpeedGame ||
        location == RoutePaths.flipBoard) {
      return AppMusicTrack.activity;
    }
    return AppMusicTrack.home;
  }

  Future<void> _handleBackPressed(BuildContext context, String location) async {
    if (!_isTopLevelAppTab(location)) {
      if (context.canPop()) {
        context.pop();
        return;
      }
      context.go(RoutePaths.appHome);
      return;
    }

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
  }

  bool _isTopLevelAppTab(String location) {
    return location == RoutePaths.appHome ||
        location == RoutePaths.appLearn ||
        location == RoutePaths.appChallenge ||
        location == RoutePaths.appSettings;
  }
}
