import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'playful_page.dart';

class FutureFeaturesPanel extends StatelessWidget {
  const FutureFeaturesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return PlayfulPanel(
      color: AppColors.surfaceMuted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '앞으로 추가될 기능',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '한자쏘옥은 학생 학습 기능부터 먼저 제공하고 있어요.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const _FutureFeatureRow(
            icon: Icons.family_restroom,
            title: '보호자 학습 리포트',
            subtitle: '아이의 학습 흐름과 성장을 한눈에 확인',
          ),
          const SizedBox(height: 10),
          const _FutureFeatureRow(
            icon: Icons.school,
            title: '선생님 반 관리',
            subtitle: '반 코드, 학생 현황, 수업 활용 도구 제공',
          ),
          const SizedBox(height: 10),
          const _FutureFeatureRow(
            icon: Icons.leaderboard,
            title: '친구들과 함께하는 랭킹',
            subtitle: '반 친구들과 학습 기록을 비교하는 도전 기능',
          ),
          const SizedBox(height: 14),
          Text(
            '현재 버전에서는 오늘 학습, 따라쓰기, 퀴즈, 복습 기능을 사용할 수 있습니다.',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class FutureFeaturesPage extends StatelessWidget {
  const FutureFeaturesPage({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return PlayfulPage(
      title: title,
      subtitle: subtitle,
      children: const [FutureFeaturesPanel()],
    );
  }
}

class _FutureFeatureRow extends StatelessWidget {
  const _FutureFeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
