import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/env.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/future_features_panel.dart';
import '../../core/widgets/playful_page.dart';
import '../../domain/models/app_user_profile.dart';
import '../../domain/models/notification_settings.dart';
import '../../domain/models/school.dart';
import '../auth/current_profile_controller.dart';
import '../student_links/student_link_controller.dart';
import 'learning_environment_controller.dart';
import 'notification_settings_controller.dart';
import 'profile_edit_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestedRole = _normalizeRole(role);
    final normalizedRole = AppEnv.showsPreviewFeatures
        ? requestedRole
        : requestedRole == 'change'
        ? 'change'
        : 'student';
    final profile = ref.watch(currentProfileProvider);

    if (normalizedRole == 'change') {
      return const _RoleChangeView();
    }

    final spec = _RoleSpec.fromRole(normalizedRole);
    return Scaffold(
      body: PlayfulPage(
        title: '설정',
        subtitle: '',
        children: [
          _ProfilePanel(role: normalizedRole, spec: spec, profile: profile),
          const SizedBox(height: 18),
          ..._sectionsForRole(context, normalizedRole),
          if (normalizedRole == 'teacher') ...[
            const SizedBox(height: 12),
            _PreviewNotice(),
          ],
        ],
      ),
    );
  }
}

String _normalizeRole(String value) {
  return switch (value) {
    'parent' => 'parent',
    'teacher' => 'teacher',
    'change' => 'change',
    _ => 'student',
  };
}

List<Widget> _sectionsForRole(BuildContext context, String role) {
  return switch (role) {
    'parent' => [
      _SettingsSection(
        title: '우리 아이 연결',
        children: [
          const _SettingsInfoBox(
            text: '학생 화면의 내 학생 연결 코드를 받아 입력하면 이 기기에서 연결 학생을 확인할 수 있어요.',
          ),
          const Divider(height: 1),
          _SettingsRow(
            icon: Icons.add_circle,
            title: '학생 연결하기',
            subtitle: '연결 코드 입력으로 추가',
            tint: AppColors.green,
            onTap: () => context.push(RoutePaths.studentLinksFor('parent')),
          ),
        ],
      ),
      const SizedBox(height: 18),
      _CommonSettingsSection(),
    ],
    'teacher' => [
      _SettingsSection(
        title: '미리보기 도구',
        children: [
          _SettingsRow(
            icon: Icons.visibility_outlined,
            title: '선생님 미리보기',
            subtitle: '학생 화면을 직접 체험해요',
            onTap: () => context.push(RoutePaths.teacherPreview),
          ),
          const Divider(height: 1),
          _SettingsRow(
            icon: Icons.groups_outlined,
            title: '샘플 반 관리',
            subtitle: '샘플 반과 학생을 관리해요',
            onTap: () => context.push(RoutePaths.teacherPreview),
          ),
          const Divider(height: 1),
          _SettingsRow(
            icon: Icons.person_outline,
            title: '샘플 학생 관리',
            subtitle: '샘플 학생으로 학습 확인',
            onTap: () => context.push(RoutePaths.teacherPreview),
          ),
          const Divider(height: 1),
          _SettingsRow(
            icon: Icons.menu_book_outlined,
            title: '수업/콘텐츠 체험',
            subtitle: '예시 콘텐츠를 둘러봐요',
            onTap: () => context.push(RoutePaths.appLearn),
          ),
        ],
      ),
      const SizedBox(height: 18),
      _SettingsSection(
        title: '계정 및 기타',
        children: [
          _RoleChangeRow(),
          const Divider(height: 1),
          _LogoutRow(),
          const Divider(height: 1),
          _AppInfoRow(),
        ],
      ),
    ],
    _ => [
      _SettingsSection(
        title: '학습 연결',
        children: [
          if (AppEnv.showsPreviewFeatures) ...[
            const _SettingsInfoBox(
              text:
                  '반 참여는 선생님이 알려준 반 코드를 입력해요. 처음 선택한 역할은 아래 역할 변경에서 바꿀 수 있어요.',
            ),
            const Divider(height: 1),
            _SettingsRow(
              icon: Icons.badge_outlined,
              title: '내 학생 연결 코드',
              subtitle: '보호자 연결용 코드 확인',
              tint: AppColors.blue,
              onTap: () => _showStudentCodeSheet(context),
            ),
            const Divider(height: 1),
            _SettingsRow(
              icon: Icons.meeting_room_outlined,
              title: '반 참여하기',
              subtitle: '반 코드로 참여해요',
              onTap: () => context.push(RoutePaths.studentLinksFor('student')),
            ),
            const Divider(height: 1),
          ] else ...[
            const _SettingsInfoBox(
              text:
                  '현재 버전은 학생 학습 기능을 먼저 제공합니다. 보호자 연결과 반 참여 기능은 향후 업데이트에서 제공될 예정입니다.',
            ),
            const Divider(height: 1),
          ],
          _SettingsRow(
            icon: Icons.tune,
            title: '학습 환경 설정',
            subtitle: '배경음, 효과음, 획 소리',
            onTap: () => _showLearningEnvironmentSheet(context),
          ),
          const Divider(height: 1),
          _SettingsRow(
            icon: Icons.notifications_none,
            title: '알림 설정',
            subtitle: '오늘 학습 리마인드',
            onTap: () => _showNotificationSettingsSheet(context),
          ),
        ],
      ),
      if (AppEnv.isProduction) ...[
        const SizedBox(height: 18),
        const FutureFeaturesPanel(),
      ],
      const SizedBox(height: 18),
      _SettingsSection(
        title: '계정 및 기타',
        children: [
          _RoleChangeRow(),
          const Divider(height: 1),
          _LogoutRow(),
          const Divider(height: 1),
          _AppInfoRow(),
        ],
      ),
    ],
  };
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({
    required this.role,
    required this.spec,
    required this.profile,
  });

  final String role;
  final _RoleSpec spec;
  final AppUserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final displayName = _displayName;
    final detail = _detailText;
    final avatar = _AvatarSpec.fromKey(profile?.avatarKey);

    return PlayfulPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: avatar.color,
            child: Icon(avatar.icon, color: AppColors.textPrimary, size: 36),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _RoleBadge(label: spec.label, color: spec.accent),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: '프로필 편집',
            onPressed: profile == null
                ? () => _showSnack(context, '프로필 정보를 불러온 뒤 다시 시도해주세요.')
                : () => _showProfileEditSheet(context, profile!),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

  String get _displayName {
    if (profile?.displayName.trim().isNotEmpty == true) {
      return profile!.displayName.trim();
    }
    return switch (role) {
      'parent' => '김학부모',
      'teacher' => '김선생님',
      _ => '김한자',
    };
  }

  String get _detailText {
    if (role == 'parent') {
      return '연결된 학생 2명';
    }
    if (role == 'teacher') {
      return '미리보기 모드\n전체 기능 체험 가능';
    }
    final grade = profile?.grade == null ? null : '${profile!.grade}학년';
    final className = profile?.className;
    final schoolName = profile?.schoolName ?? '한자초등학교';
    final gradeClass = [
      grade,
      className,
    ].whereType<String>().where((text) => text.isNotEmpty).join(' ');
    return [gradeClass.isEmpty ? '3학년 2반' : gradeClass, schoolName].join('\n');
  }
}

void _showProfileEditSheet(BuildContext context, AppUserProfile profile) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ProfileEditSheet(profile: profile),
  );
}

void _showStudentCodeSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const _StudentCodeSheet(),
  );
}

class _StudentCodeSheet extends ConsumerWidget {
  const _StudentCodeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studentLinkProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: state.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const Text('학생 연결 코드를 불러오지 못했어요.'),
          data: (data) {
            final code = data.currentStudentCode;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '내 학생 연결 코드',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '보호자에게 이 코드를 전달하면 보호자 기기에서 학생을 연결할 수 있어요.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                if (code == null)
                  const Text('학생 정보 입력 후 연결 코드를 만들 수 있습니다.')
                else ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SelectableText(code),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      _showSnack(context, '학생 연결 코드를 복사했어요.');
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('코드 복사'),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileEditSheet extends ConsumerStatefulWidget {
  const _ProfileEditSheet({required this.profile});

  final AppUserProfile profile;

  @override
  ConsumerState<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<_ProfileEditSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _schoolController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName);
    _schoolController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(profileEditControllerProvider.notifier)
          .loadFromProfile(widget.profile, force: true);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileEditControllerProvider);
    final controller = ref.read(profileEditControllerProvider.notifier);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '내 정보 바꾸기',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nameController,
                enabled: !state.isSaving,
                onChanged: controller.updateDisplayName,
                decoration: const InputDecoration(
                  labelText: '이름',
                  hintText: '이름을 입력해주세요',
                  prefixIcon: Icon(Icons.face),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '아바타',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              _AvatarOptions(
                selectedAvatarKey: state.avatarKey,
                onSelected: state.isSaving ? (_) {} : controller.selectAvatar,
              ),
              const SizedBox(height: 18),
              Text(
                '학년',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              _ProfileGradeOptions(
                selectedGrade: state.grade,
                onSelected: state.isSaving ? (_) {} : controller.selectGrade,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _schoolController,
                enabled: !state.isSaving,
                textInputAction: TextInputAction.search,
                onChanged: controller.updateKeyword,
                onSubmitted: state.isSaving
                    ? null
                    : (_) => controller.searchSchools(),
                decoration: InputDecoration(
                  labelText: '학교 변경',
                  hintText: state.selectedSchool?.schoolName ?? '학교명을 검색해주세요',
                  prefixIcon: const Icon(Icons.school),
                ),
              ),
              const SizedBox(height: 10),
              AppButton(
                label: '학교 검색',
                onPressed: state.isSaving ? null : controller.searchSchools,
                isLoading: state.isSearching,
                variant: AppButtonVariant.outlined,
                icon: Icons.search,
              ),
              if (state.selectedSchool != null) ...[
                const SizedBox(height: 10),
                _SelectedSchoolNotice(school: state.selectedSchool!),
              ],
              if (state.searchResults.isNotEmpty) ...[
                const SizedBox(height: 10),
                _ProfileSchoolResults(
                  schools: state.searchResults,
                  selectedSchool: state.selectedSchool,
                  onSelected: state.isSaving ? (_) {} : controller.selectSchool,
                ),
              ],
              if (state.errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              AppButton(
                label: '저장하기',
                onPressed: () async {
                  final didSave = await controller.save();
                  if (!context.mounted || !didSave) {
                    return;
                  }
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('내 정보가 저장됐어요.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                isLoading: state.isSaving,
                icon: Icons.check,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarOptions extends StatelessWidget {
  const _AvatarOptions({
    required this.selectedAvatarKey,
    required this.onSelected,
  });

  final String selectedAvatarKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final avatar in _AvatarSpec.options)
          _AvatarOption(
            avatar: avatar,
            selected: selectedAvatarKey == avatar.key,
            onTap: () => onSelected(avatar.key),
          ),
      ],
    );
  }
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.avatar,
    required this.selected,
    required this.onTap,
  });

  final _AvatarSpec avatar;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navSelected : AppColors.surface,
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
        child: SizedBox(
          width: 82,
          height: 82,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: avatar.color,
                child: Icon(avatar.icon, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                avatar.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileGradeOptions extends StatelessWidget {
  const _ProfileGradeOptions({
    required this.selectedGrade,
    required this.onSelected,
  });

  final int? selectedGrade;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final grade in AppConstants.supportedGrades)
          ChoiceChip(
            label: Text('$grade학년'),
            selected: selectedGrade == grade,
            onSelected: (_) => onSelected(grade),
          ),
      ],
    );
  }
}

class _SelectedSchoolNotice extends StatelessWidget {
  const _SelectedSchoolNotice({required this.school});

  final School school;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${school.schoolName} 선택됨\n학교를 바꾸면 반 연결이 달라질 수 있어요.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSchoolResults extends StatelessWidget {
  const _ProfileSchoolResults({
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
            child: _ProfileSchoolResultTile(
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

class _ProfileSchoolResultTile extends StatelessWidget {
  const _ProfileSchoolResultTile({
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
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [school.regionName, school.roadAddress]
                          .whereType<String>()
                          .where((text) => text.isNotEmpty)
                          .join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommonSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: '설정',
      children: [
        _SettingsRow(
          icon: Icons.notifications_none,
          title: '알림 설정',
          subtitle: '리포트, 안내 알림 설정',
          onTap: () => _showNotificationSettingsSheet(context),
        ),
        const Divider(height: 1),
        _RoleChangeRow(),
        const Divider(height: 1),
        _LogoutRow(),
        const Divider(height: 1),
        _AppInfoRow(),
      ],
    );
  }
}

class _RoleChangeView extends StatelessWidget {
  const _RoleChangeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlayfulPage(
        title: '역할 변경',
        subtitle: '사용할 역할을 선택해주세요.\n역할은 언제든지 변경할 수 있어요.',
        children: [
          _RoleChoiceCard(
            spec: _RoleSpec.student,
            title: '학생',
            subtitle: '한자를 배우고\n실력을 키워요',
            onTap: () => context.go('${RoutePaths.appSettings}?role=student'),
          ),
          if (AppEnv.showsPreviewFeatures) ...[
            const SizedBox(height: 14),
            _RoleChoiceCard(
              spec: _RoleSpec.parent,
              title: '학부모',
              subtitle: '우리 아이 학습 현황을\n확인하고 응원해요',
              onTap: () => context.go('${RoutePaths.appSettings}?role=parent'),
            ),
            const SizedBox(height: 14),
            _RoleChoiceCard(
              spec: _RoleSpec.teacher,
              title: '선생님',
              subtitle: '학생 화면을 체험하고\n수업을 미리 준비해요',
              onTap: () => context.go('${RoutePaths.appSettings}?role=teacher'),
            ),
          ] else ...[
            const SizedBox(height: 14),
            const FutureFeaturesPanel(),
          ],
          const SizedBox(height: 18),
          PlayfulPanel(
            color: AppColors.surfaceMuted,
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '선택한 역할에 따라 설정 화면과 메뉴 구성이 달라져요.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChoiceCard extends StatelessWidget {
  const _RoleChoiceCard({
    required this.spec,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final _RoleSpec spec;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: spec.tint.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: spec.accent.withValues(alpha: 0.55)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white.withValues(alpha: 0.84),
                child: Icon(spec.icon, color: AppColors.textPrimary, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: spec.accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: spec.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsInfoBox extends StatelessWidget {
  const _SettingsInfoBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        PlayfulPanel(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.tint,
    this.trailingText,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? tint;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: tint ?? AppColors.textPrimary, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (trailingText != null) ...[
                const SizedBox(width: 8),
                Text(
                  trailingText!,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleChangeRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      icon: Icons.settings_outlined,
      title: '역할 변경',
      subtitle: '다른 역할로 바꿔볼까요?',
      onTap: () => context.go('${RoutePaths.appSettings}?role=change'),
    );
  }
}

class _LogoutRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsRow(
      icon: Icons.logout,
      title: '로그아웃',
      subtitle: '현재 계정에서 나가기',
      tint: AppColors.primary,
      onTap: () => _confirmLogout(context, ref),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showAppConfirmDialog(
      context: context,
      title: '로그아웃할까요?',
      message: '로그아웃 시 현재 기기의 학습 기록, 랭킹, 반 연결 정보가 모두 초기화되어 없어져요. 계속할까요?',
      confirmLabel: '로그아웃',
      icon: Icons.logout,
      isDestructive: true,
    );
    if (!shouldLogout || !context.mounted) {
      return;
    }

    try {
      await ref.read(currentProfileProvider.notifier).signOut();
      if (!context.mounted) {
        return;
      }
      context.go(RoutePaths.roleSelect);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showSnack(context, '로그아웃에 실패했어요. 다시 시도해주세요.');
    }
  }
}

class _AppInfoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      icon: Icons.info_outline,
      title: '앱 정보',
      subtitle: '한자쏘옥 데모',
      trailingText: '버전 1.0.0',
      onTap: () => _showSnack(context, '한자쏘옥 데모 버전 1.0.0입니다.'),
    );
  }
}

void _showLearningEnvironmentSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return const _LearningEnvironmentSheet();
    },
  );
}

void _showNotificationSettingsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return const _NotificationSettingsSheet();
    },
  );
}

class _NotificationSettingsSheet extends ConsumerWidget {
  const _NotificationSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsControllerProvider);
    final notifier = ref.read(notificationSettingsControllerProvider.notifier);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: settings.when(
          data: (data) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '알림 설정',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: '오늘 학습 알림',
                  subtitle: '하루가 지나 새 학습이 열리면 알려줘요',
                  value: data.dailyReminderEnabled,
                  onChanged: (value) =>
                      _setDailyReminderEnabled(context, notifier, value),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.schedule,
                    color: AppColors.textPrimary,
                  ),
                  title: const Text(
                    '알림 시간',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    data.dailyReminderEnabled
                        ? '매일 ${data.displayTime}'
                        : '켜면 ${data.displayTime}에 알려줘요',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Text(
                    data.displayTime,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  onTap: () => _pickReminderTime(context, notifier, data),
                ),
                const SizedBox(height: 8),
                Text(
                  '알림을 켜면 Android 알림 권한을 요청해요. 권한을 허용해야 앱이 닫혀 있어도 받을 수 있어요.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [Text('알림 설정을 불러오지 못했어요.')],
          ),
        ),
      ),
    );
  }

  Future<void> _setDailyReminderEnabled(
    BuildContext context,
    NotificationSettingsController notifier,
    bool value,
  ) async {
    final scheduled = await notifier.setDailyReminderEnabled(value);
    if (!context.mounted) {
      return;
    }
    if (value && !scheduled) {
      _showSnack(context, '알림 권한이 필요해요. 기기 설정에서 알림을 허용해주세요.');
    }
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    NotificationSettingsController notifier,
    NotificationSettings data,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: data.reminderHour,
        minute: data.reminderMinute,
      ),
    );
    if (picked == null) {
      return;
    }
    final scheduled = await notifier.setReminderTime(
      hour: picked.hour,
      minute: picked.minute,
    );
    if (!context.mounted) {
      return;
    }
    if (!scheduled) {
      _showSnack(context, '알림 권한이 필요해요. 기기 설정에서 알림을 허용해주세요.');
    }
  }
}

class _LearningEnvironmentSheet extends ConsumerWidget {
  const _LearningEnvironmentSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(learningEnvironmentControllerProvider);
    final notifier = ref.read(learningEnvironmentControllerProvider.notifier);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: settings.when(
          data: (data) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '학습 환경 설정',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsSwitchTile(
                  icon: Icons.music_note,
                  title: '배경음',
                  subtitle: '홈과 학습 화면의 배경 음악',
                  value: data.backgroundMusicEnabled,
                  onChanged: notifier.setBackgroundMusicEnabled,
                ),
                const Divider(height: 1),
                _SettingsSwitchTile(
                  icon: Icons.volume_up_outlined,
                  title: '효과음',
                  subtitle: '정답, 완료, 버튼 반응음',
                  value: data.soundEffectsEnabled,
                  onChanged: notifier.setSoundEffectsEnabled,
                ),
                const Divider(height: 1),
                _SettingsSwitchTile(
                  icon: Icons.edit,
                  title: '획 쓰기 소리',
                  subtitle: '획을 그을 때 나는 사각거림',
                  value: data.soundEffectsEnabled && data.strokeSoundEnabled,
                  onChanged: data.soundEffectsEnabled
                      ? notifier.setStrokeSoundEnabled
                      : null,
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [Text('학습 환경 설정을 불러오지 못했어요.')],
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: AppColors.textPrimary),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _PreviewNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      color: AppColors.peach.withValues(alpha: 0.42),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '미리보기에서 만든 반 코드는 이 기기에 데모 데이터로 저장돼요. 실제 과제 배포나 알림은 실행되지 않아요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _RoleSpec {
  const _RoleSpec({
    required this.label,
    required this.icon,
    required this.tint,
    required this.accent,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final Color accent;

  static const student = _RoleSpec(
    label: '학생',
    icon: Icons.face,
    tint: AppColors.blue,
    accent: AppColors.primary,
  );

  static const parent = _RoleSpec(
    label: '학부모',
    icon: Icons.family_restroom,
    tint: AppColors.green,
    accent: Color(0xFF2F7D32),
  );

  static const teacher = _RoleSpec(
    label: '선생님',
    icon: Icons.school,
    tint: AppColors.peach,
    accent: Color(0xFFF97316),
  );

  static _RoleSpec fromRole(String role) {
    return switch (role) {
      'parent' => parent,
      'teacher' => teacher,
      _ => student,
    };
  }
}

class _AvatarSpec {
  const _AvatarSpec({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String key;
  final String label;
  final IconData icon;
  final Color color;

  static const options = [
    _AvatarSpec(
      key: 'explorer',
      label: '탐험',
      icon: Icons.explore,
      color: AppColors.blue,
    ),
    _AvatarSpec(
      key: 'scholar',
      label: '학자',
      icon: Icons.menu_book,
      color: AppColors.green,
    ),
    _AvatarSpec(
      key: 'star',
      label: '별',
      icon: Icons.auto_awesome,
      color: AppColors.yellow,
    ),
    _AvatarSpec(
      key: 'rocket',
      label: '로켓',
      icon: Icons.rocket_launch,
      color: AppColors.peach,
    ),
    _AvatarSpec(
      key: 'leaf',
      label: '새싹',
      icon: Icons.eco,
      color: AppColors.mint,
    ),
    _AvatarSpec(
      key: 'medal',
      label: '메달',
      icon: Icons.military_tech,
      color: AppColors.lavender,
    ),
  ];

  static _AvatarSpec fromKey(String? key) {
    for (final avatar in options) {
      if (avatar.key == key) {
        return avatar;
      }
    }
    return options.first;
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}
