import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import '../shared/placeholder_shell.dart';

class WritingScreen extends StatelessWidget {
  const WritingScreen({super.key, required this.hanjaId});

  final String hanjaId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderShell(
      title: '따라쓰기',
      message: '한자 ID: $hanjaId',
      actions: [
        FilledButton(
          onPressed: () => context.go(RoutePaths.result),
          child: const Text('완료'),
        ),
      ],
    );
  }
}
