import 'package:flutter/material.dart';

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
    );
  }
}
