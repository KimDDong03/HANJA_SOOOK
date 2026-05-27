import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import '../shared/placeholder_shell.dart';

class HanjaCardScreen extends StatelessWidget {
  const HanjaCardScreen({super.key, required this.hanjaId});

  final String hanjaId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderShell(
      title: '한자 카드',
      message: '한자 ID: $hanjaId',
      actions: [
        FilledButton(
          onPressed: () => context.go(RoutePaths.writing(hanjaId)),
          child: const Text('따라쓰기'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => context.go(RoutePaths.quiz),
          child: const Text('퀴즈 시작'),
        ),
      ],
    );
  }
}
