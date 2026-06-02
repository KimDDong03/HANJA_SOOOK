import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/app_audio_controller.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';

class RoleSelectScreen extends ConsumerWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref.read(appAudioControllerProvider).setMusicTrack(AppMusicTrack.home),
      );
    });

    return Scaffold(
      body: PlayfulPage(
        title: '한자쏘옥',
        subtitle: '어떤 모드로 시작할까요?',
        showMascot: true,
        children: [
          _RoleCard(
            icon: Icons.face,
            title: '학생',
            subtitle: '한자를 재미있게 배워요',
            color: const Color(0xFFFFD166),
            isPrimary: true,
            onTap: () => context.go(RoutePaths.studentSetup),
          ),
          const SizedBox(height: 14),
          _RoleCard(
            icon: Icons.family_restroom,
            title: '학부모',
            subtitle: '우리 아이 학습 현황을 확인해요',
            color: const Color(0xFFA7F3D0),
            onTap: () => context.go('${RoutePaths.appSettings}?role=parent'),
          ),
          const SizedBox(height: 14),
          _RoleCard(
            icon: Icons.school,
            title: '선생님',
            subtitle: '학생들의 학습을 관리해요',
            color: const Color(0xFFBDE0FE),
            onTap: () => context.go('${RoutePaths.appSettings}?role=teacher'),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.all(isPrimary ? 22 : 18),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Icon(icon, size: isPrimary ? 38 : 32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 34),
            ],
          ),
        ),
      ),
    );
  }
}
