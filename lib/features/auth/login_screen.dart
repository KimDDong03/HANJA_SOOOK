import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('시작하기')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '학교와 학생 정보를 입력해요',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: '학교명',
                      hintText: '학교명을 입력해주세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: () {}, child: const Text('학교 검색')),
                  const SizedBox(height: 20),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: '이름',
                      hintText: '이름을 입력해주세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: const [
                      ChoiceChip(label: Text('3학년'), selected: false),
                      ChoiceChip(label: Text('4학년'), selected: false),
                      ChoiceChip(label: Text('5학년'), selected: false),
                      ChoiceChip(label: Text('6학년'), selected: false),
                    ],
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () => context.go(RoutePaths.home),
                    child: const Text('임시로 홈으로 이동'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
