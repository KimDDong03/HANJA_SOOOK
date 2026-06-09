import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/app_audio_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/playful_page.dart';
import '../../domain/models/school.dart';
import 'login_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _schoolController;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _schoolController = TextEditingController();
    _nameController = TextEditingController();
    unawaited(
      ref.read(appAudioControllerProvider).setMusicTrack(AppMusicTrack.home),
    );
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    final canStart = state.canStart && !state.isSigningIn;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: PlayfulPage(
          title: '학년 선택',
          subtitle: '학교와 이름, 학년을 선택하고 시작해요',
          leading: IconButton.filledTonal(
            onPressed: () => context.go(RoutePaths.roleSelect),
            icon: const Icon(Icons.arrow_back),
            tooltip: '뒤로가기',
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: PlayfulPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _schoolController,
                        textInputAction: TextInputAction.search,
                        onChanged: controller.updateKeyword,
                        onSubmitted: (_) => controller.searchSchools(),
                        decoration: const InputDecoration(
                          labelText: '학교명',
                          hintText: '학교명을 2글자 이상 입력해주세요',
                          prefixIcon: Icon(Icons.school),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: '학교 검색',
                        onPressed: controller.searchSchools,
                        isLoading: state.isSearching,
                        variant: AppButtonVariant.outlined,
                        icon: Icons.search,
                      ),
                      if (state.searchResults.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _SchoolResults(
                          schools: state.searchResults,
                          selectedSchool: state.selectedSchool,
                          onSelected: controller.selectSchool,
                        ),
                      ],
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        onChanged: controller.updateDisplayName,
                        decoration: const InputDecoration(
                          labelText: '이름',
                          hintText: '이름을 입력해주세요',
                          prefixIcon: Icon(Icons.face),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '학년을 선택해주세요',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),
                      _GradeOptions(
                        selectedGrade: state.grade,
                        onSelected: controller.selectGrade,
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          state.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      AppButton(
                        label: '시작하기',
                        onPressed: canStart
                            ? () async {
                                final profile = await controller.start();
                                if (!context.mounted || profile == null) {
                                  return;
                                }
                                context.go(RoutePaths.textbookGate);
                              }
                            : null,
                        isLoading: state.isSigningIn,
                        icon: Icons.rocket_launch,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchoolResults extends StatelessWidget {
  const _SchoolResults({
    required this.schools,
    required this.selectedSchool,
    required this.onSelected,
  });

  final List<School> schools;
  final School? selectedSchool;
  final ValueChanged<School> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final school in schools)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SchoolResultTile(
              school: school,
              selected:
                  selectedSchool?.standardSchoolCode ==
                  school.standardSchoolCode,
              onTap: () => onSelected(school),
            ),
          ),
      ],
    );
  }
}

class _GradeOptions extends StatelessWidget {
  const _GradeOptions({required this.selectedGrade, required this.onSelected});

  final int? selectedGrade;
  final ValueChanged<int> onSelected;

  static const _visibleGrades = [1, 2, ...AppConstants.supportedGrades];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final grade in _visibleGrades)
              SizedBox(
                width: itemWidth,
                child: _GradeTile(
                  grade: grade,
                  selected: selectedGrade == grade,
                  enabled: AppConstants.supportedGrades.contains(grade),
                  onTap: () => onSelected(grade),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GradeTile extends StatelessWidget {
  const _GradeTile({
    required this.grade,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final int grade;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _gradeColor(grade),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 78,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$grade학년',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (!enabled) ...[
                      const SizedBox(height: 4),
                      Text(
                        '준비 중',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected && enabled)
                const Positioned(
                  right: 12,
                  bottom: 10,
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _gradeColor(int grade) {
    if (!enabled) {
      return AppColors.surfaceMuted;
    }
    return switch (grade) {
      3 => AppColors.yellow,
      4 => AppColors.green,
      5 => AppColors.orange,
      6 => AppColors.blue,
      _ => AppColors.surfaceMuted,
    };
  }
}

class _SchoolResultTile extends StatelessWidget {
  const _SchoolResultTile({
    required this.school,
    required this.selected,
    required this.onTap,
  });

  final School school;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.yellow : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.textPrimary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      school.schoolName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [school.regionName, school.roadAddress]
                          .whereType<String>()
                          .where((text) => text.isNotEmpty)
                          .join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
