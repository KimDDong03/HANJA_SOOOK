import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/app_button.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('시작하기')),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '학교와 학생 정보를 입력해요',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _schoolController,
                    textInputAction: TextInputAction.search,
                    onChanged: controller.updateKeyword,
                    onSubmitted: (_) => controller.searchSchools(),
                    decoration: const InputDecoration(
                      labelText: '학교명',
                      hintText: '학교명을 2글자 이상 입력해주세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: '학교 검색',
                    onPressed: controller.searchSchools,
                    isLoading: state.isSearching,
                    variant: AppButtonVariant.outlined,
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
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final grade in AppConstants.supportedGrades)
                        ChoiceChip(
                          label: Text('$grade학년'),
                          selected: state.grade == grade,
                          onSelected: (_) => controller.selectGrade(grade),
                        ),
                    ],
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  AppButton(
                    label: '시작하기',
                    onPressed: () async {
                      final profile = await controller.start();
                      if (!context.mounted || profile == null) {
                        return;
                      }
                      context.go(RoutePaths.home);
                    },
                    isLoading: state.isSigningIn,
                  ),
                ],
              ),
            ),
          ),
        ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? colorScheme.primaryContainer : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                school.schoolName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                [school.regionName, school.roadAddress]
                    .whereType<String>()
                    .where((text) => text.isNotEmpty)
                    .join(' · '),
              ),
              const SizedBox(height: 4),
              Text(
                '표준학교코드: ${school.standardSchoolCode}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
