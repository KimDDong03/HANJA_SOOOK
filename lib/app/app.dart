import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_back_button_dispatcher.dart';
import '../core/audio/button_tap_sound_layer.dart';
import 'router.dart';
import 'theme.dart';

final appBackButtonDispatcher = AppBackButtonDispatcher(router: appRouter);

class HanjaSoookApp extends StatelessWidget {
  const HanjaSoookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '한자쏘옥',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routeInformationProvider: appRouter.routeInformationProvider,
      routeInformationParser: appRouter.routeInformationParser,
      routerDelegate: appRouter.routerDelegate,
      backButtonDispatcher: appBackButtonDispatcher,
      onNavigationNotification: (notification) {
        unawaited(
          SystemNavigator.setFrameworkHandlesBack(
            appBackButtonDispatcher.shouldFrameworkHandleBack(
              notification.canHandlePop,
            ),
          ),
        );
        return true;
      },
      builder: (context, child) {
        return AppButtonTapSoundLayer(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
