import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/playful_page.dart';

class QuizModesScreen extends StatelessWidget {
  const QuizModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlayfulPage(
        title: '퀴즈 선택',
        subtitle: '오늘은 어떤 방식으로 맞혀볼까요?',
        children: [
          PlayfulActionTile(
            icon: Icons.translate,
            title: '한자 보고 음',
            subtitle: '한자를 보고 소리를 맞혀요',
            color: AppColors.surface,
            onTap: () => context.push(RoutePaths.quizPlayFor('hanja-to-sound')),
          ),
          const SizedBox(height: 12),
          PlayfulActionTile(
            icon: Icons.menu_book,
            title: '한자 보고 뜻',
            subtitle: '한자를 보고 뜻을 맞혀요',
            color: AppColors.surface,
            onTap: () =>
                context.push(RoutePaths.quizPlayFor('hanja-to-meaning')),
          ),
          const SizedBox(height: 12),
          PlayfulActionTile(
            icon: Icons.text_fields,
            title: '뜻 보고 한자',
            subtitle: '뜻에 맞는 한자를 골라요',
            color: AppColors.surface,
            onTap: () =>
                context.push(RoutePaths.quizPlayFor('meaning-to-hanja')),
          ),
          const SizedBox(height: 12),
          PlayfulActionTile(
            icon: Icons.shuffle,
            title: '혼합 퀴즈',
            subtitle: '여러 유형을 섞어 도전해요',
            color: AppColors.surface,
            onTap: () => context.push(RoutePaths.quizPlayFor('mixed')),
          ),
        ],
      ),
    );
  }
}
