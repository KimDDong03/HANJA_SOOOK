import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../data/repositories/school_repository_provider.dart';
import '../../domain/models/app_user_profile.dart';
import '../../domain/models/school.dart';
import '../auth/current_profile_controller.dart';

final profileEditControllerProvider =
    NotifierProvider<ProfileEditController, ProfileEditState>(
      ProfileEditController.new,
    );

class ProfileEditController extends Notifier<ProfileEditState> {
  @override
  ProfileEditState build() => const ProfileEditState();

  void loadFromProfile(AppUserProfile profile, {bool force = false}) {
    if (!force && state.profileId == profile.id) {
      return;
    }
    state = ProfileEditState(
      profileId: profile.id,
      displayName: profile.displayName,
      grade: profile.grade,
      selectedSchool: _schoolFromProfile(profile),
      avatarKey: profile.avatarKey,
    );
  }

  void updateDisplayName(String displayName) {
    state = state.copyWith(displayName: displayName, errorMessage: null);
  }

  void updateKeyword(String keyword) {
    state = state.copyWith(
      keyword: keyword,
      clearSelectedSchool: true,
      errorMessage: null,
    );
  }

  void selectGrade(int grade) {
    state = state.copyWith(grade: grade, errorMessage: null);
  }

  void selectSchool(School school) {
    state = state.copyWith(selectedSchool: school, errorMessage: null);
  }

  void selectAvatar(String avatarKey) {
    state = state.copyWith(avatarKey: avatarKey, errorMessage: null);
  }

  Future<void> searchSchools() async {
    final keyword = state.keyword.trim();
    if (keyword.length < AppConstants.schoolSearchMinLength) {
      state = state.copyWith(errorMessage: '학교명을 2글자 이상 입력해주세요.');
      return;
    }

    state = state.copyWith(isSearching: true, errorMessage: null);

    try {
      final schools = await ref
          .read(schoolRepositoryProvider)
          .searchSchools(keyword: keyword);
      state = state.copyWith(
        isSearching: false,
        searchResults: schools,
        selectedSchool: null,
        errorMessage: schools.isEmpty ? '검색 결과가 없습니다. 학교명을 다시 확인해주세요.' : null,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        isSearching: false,
        errorMessage: error.userMessage,
      );
    }
  }

  Future<bool> save() async {
    if (state.isSaving) {
      return false;
    }
    final profileId = state.profileId;
    if (profileId == null) {
      state = state.copyWith(errorMessage: '프로필 정보를 불러오지 못했어요.');
      return false;
    }
    if (state.displayName.trim().isEmpty) {
      state = state.copyWith(errorMessage: '이름을 입력해주세요.');
      return false;
    }
    final grade = state.grade;
    if (grade == null) {
      state = state.copyWith(errorMessage: '학년을 선택해주세요.');
      return false;
    }
    final school = state.selectedSchool;
    if (school == null) {
      state = state.copyWith(errorMessage: '학교를 선택해주세요.');
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final profile = await ref
          .read(schoolRepositoryProvider)
          .updateStudentProfile(
            profileId: profileId,
            displayName: state.displayName.trim(),
            grade: grade,
            school: school,
            avatarKey: state.avatarKey,
          );
      ref.read(currentProfileProvider.notifier).updateProfile(profile);
      state = state.copyWith(
        displayName: profile.displayName,
        grade: profile.grade,
        selectedSchool: _schoolFromProfile(profile),
        avatarKey: profile.avatarKey,
        isSaving: false,
      );
      return true;
    } on AppException catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.userMessage);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: '프로필 저장에 실패했습니다.',
      );
      return false;
    }
  }
}

class ProfileEditState {
  const ProfileEditState({
    this.profileId,
    this.displayName = '',
    this.keyword = '',
    this.searchResults = const [],
    this.selectedSchool,
    this.grade,
    this.avatarKey = 'explorer',
    this.isSearching = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final String? profileId;
  final String displayName;
  final String keyword;
  final List<School> searchResults;
  final School? selectedSchool;
  final int? grade;
  final String avatarKey;
  final bool isSearching;
  final bool isSaving;
  final String? errorMessage;

  ProfileEditState copyWith({
    String? profileId,
    String? displayName,
    String? keyword,
    List<School>? searchResults,
    School? selectedSchool,
    bool clearSelectedSchool = false,
    int? grade,
    String? avatarKey,
    bool? isSearching,
    bool? isSaving,
    String? errorMessage,
  }) {
    return ProfileEditState(
      profileId: profileId ?? this.profileId,
      displayName: displayName ?? this.displayName,
      keyword: keyword ?? this.keyword,
      searchResults: searchResults ?? this.searchResults,
      selectedSchool: clearSelectedSchool
          ? null
          : selectedSchool ?? this.selectedSchool,
      grade: grade ?? this.grade,
      avatarKey: avatarKey ?? this.avatarKey,
      isSearching: isSearching ?? this.isSearching,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

School? _schoolFromProfile(AppUserProfile profile) {
  final code = profile.standardSchoolCode;
  final name = profile.schoolName;
  if (code == null || code.isEmpty || name == null || name.isEmpty) {
    return null;
  }
  return School(
    id: profile.schoolId,
    standardSchoolCode: code,
    schoolName: name,
    schoolKind: '초등학교',
  );
}
