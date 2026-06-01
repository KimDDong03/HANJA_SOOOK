import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/app_button.dart';
import '../auth/current_profile_controller.dart';

class TextbookGateScreen extends ConsumerStatefulWidget {
  const TextbookGateScreen({super.key});

  @override
  ConsumerState<TextbookGateScreen> createState() => _TextbookGateScreenState();
}

class _TextbookGateScreenState extends ConsumerState<TextbookGateScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _buttonOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _buttonOffset =
        Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.42, 1, curve: Curves.easeOutCubic),
          ),
        );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final grade = profile?.grade ?? 3;
    final schoolName = profile?.schoolName;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 720;
            final coverHeight = constraints.maxHeight * (compact ? 0.52 : 0.58);

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
              child: Column(
                children: [
                  const Spacer(),
                  FadeTransition(
                    opacity: _fade,
                    child: Column(
                      children: [
                        Text(
                          '$grade학년 한자쏘옥',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        if (schoolName != null && schoolName.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            schoolName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? 18 : 28),
                  FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: _TextbookCover(
                        grade: grade,
                        maxHeight: coverHeight.clamp(330, 520).toDouble(),
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 22 : 32),
                  SlideTransition(
                    position: _buttonOffset,
                    child: FadeTransition(
                      opacity: _fade,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: AppButton(
                          label: '시작하기',
                          icon: Icons.play_arrow_rounded,
                          onPressed: () => context.go(RoutePaths.appHome),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TextbookCover extends StatelessWidget {
  const _TextbookCover({required this.grade, required this.maxHeight});

  final int grade;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 360, maxHeight: maxHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/textbook_covers/grade_$grade.jpg',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/textbook_covers/grade_3.jpg',
                fit: BoxFit.contain,
              );
            },
          ),
        ),
      ),
    );
  }
}
