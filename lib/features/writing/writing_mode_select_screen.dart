import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';

class WritingModeSelectScreen extends StatelessWidget {
  const WritingModeSelectScreen({super.key, required this.hanjaId});

  final String hanjaId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlayfulPage(
        title: '쓰기',
        subtitle: '연습과 채점을 바로 고를 수 있어요',
        children: [
          PlayfulActionTile(
            icon: Icons.brush,
            title: '직접 써보기',
            subtitle: '회색 글자 가이드 위에 쓰고 필요할 때만 획순을 봐요',
            color: AppColors.surface,
            onTap: () => context.push(RoutePaths.guidedWriting(hanjaId)),
          ),
          const SizedBox(height: 12),
          PlayfulActionTile(
            icon: Icons.fact_check,
            title: '자유쓰기 채점',
            subtitle: '아무 안내 없이 써보고 점수를 받아요',
            color: AppColors.surface,
            onTap: () => context.push(RoutePaths.freeWriting(hanjaId)),
          ),
        ],
      ),
    );
  }
}
