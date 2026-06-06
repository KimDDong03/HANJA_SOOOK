import 'package:flutter/material.dart';

import '../core/audio/button_tap_sound_layer.dart';
import 'router.dart';
import 'theme.dart';

class HanjaSoookApp extends StatelessWidget {
  const HanjaSoookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '한자쏘옥',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
      builder: (context, child) {
        return AppButtonTapSoundLayer(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
