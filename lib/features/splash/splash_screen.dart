import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _moveToLogin();
  }

  Future<void> _moveToLogin() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }
    context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '한자쏘옥',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('배울 준비를 하고 있어요'),
            ],
          ),
        ),
      ),
    );
  }
}
