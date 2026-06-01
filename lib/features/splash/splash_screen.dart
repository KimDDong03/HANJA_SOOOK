import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import '../auth/current_profile_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _logoAsset = 'assets/images/app_icon_source.png';

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
    final hasProfile = await ref
        .read(currentProfileProvider.notifier)
        .restoreFromCurrentSession();
    if (!mounted) {
      return;
    }
    context.go(hasProfile ? RoutePaths.appHome : RoutePaths.roleSelect);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  _logoAsset,
                  width: 236,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const _SplashLogoFallback();
                  },
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: Theme.of(context).colorScheme.primary,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashLogoFallback extends StatelessWidget {
  const _SplashLogoFallback();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 236,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Text(
            '한자쏘옥',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
