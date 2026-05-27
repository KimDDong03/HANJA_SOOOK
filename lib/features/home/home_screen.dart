import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('학생 홈')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              '오늘의 한자를 시작해요',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _RouteButton(
              label: '한자 카드',
              onPressed: () => context.go(RoutePaths.hanja('demo-hanja')),
            ),
            _RouteButton(
              label: '따라쓰기',
              onPressed: () => context.go(RoutePaths.writing('demo-hanja')),
            ),
            _RouteButton(
              label: '퀴즈',
              onPressed: () => context.go(RoutePaths.quiz),
            ),
            _RouteButton(
              label: '게임',
              onPressed: () => context.go(RoutePaths.game),
            ),
            _RouteButton(
              label: '결과',
              onPressed: () => context.go(RoutePaths.result),
            ),
            _RouteButton(
              label: '성장',
              onPressed: () => context.go(RoutePaths.growth),
            ),
            _RouteButton(
              label: '교사 미리보기',
              onPressed: () => context.go(RoutePaths.teacherPreview),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteButton extends StatelessWidget {
  const _RouteButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FilledButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
