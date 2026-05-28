import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../data/repositories/school_repository_provider.dart';
import '../../domain/models/app_user_profile.dart';
import '../../domain/models/school.dart';
import 'current_profile_controller.dart';
import 'login_state.dart';

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void updateKeyword(String keyword) {
    state = state.copyWith(
      keyword: keyword,
      selectedSchool: null,
      errorMessage: null,
    );
  }

  void updateDisplayName(String displayName) {
    state = state.copyWith(displayName: displayName, errorMessage: null);
  }

  void selectGrade(int grade) {
    state = state.copyWith(grade: grade, errorMessage: null);
  }

  void selectSchool(School school) {
    state = state.copyWith(selectedSchool: school, errorMessage: null);
  }

  Future<void> searchSchools() async {
    final keyword = state.keyword.trim();
    if (keyword.length < AppConstants.schoolSearchMinLength) {
      state = state.copyWith(errorMessage: '학교명을 2글자 이상 입력해주세요.');
      return;
    }

    state = state.copyWith(
      status: LoginSubmissionStatus.searching,
      errorMessage: null,
    );

    try {
      final schools = await ref
          .read(schoolRepositoryProvider)
          .searchSchools(keyword: keyword);
      state = state.copyWith(
        searchResults: schools,
        selectedSchool: null,
        status: LoginSubmissionStatus.idle,
        errorMessage: schools.isEmpty ? '검색 결과가 없습니다. 학교명을 다시 확인해주세요.' : null,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        status: LoginSubmissionStatus.idle,
        errorMessage: error.userMessage,
      );
    }
  }

  Future<AppUserProfile?> start() async {
    final selectedSchool = state.selectedSchool;
    if (selectedSchool == null) {
      state = state.copyWith(errorMessage: '학교를 선택해주세요.');
      return null;
    }
    if (state.displayName.trim().isEmpty) {
      state = state.copyWith(errorMessage: '이름을 입력해주세요.');
      return null;
    }
    final grade = state.grade;
    if (grade == null) {
      state = state.copyWith(errorMessage: '학년을 선택해주세요.');
      return null;
    }

    state = state.copyWith(
      status: LoginSubmissionStatus.signingIn,
      errorMessage: null,
    );

    try {
      final profile = await ref
          .read(schoolRepositoryProvider)
          .signInStudentWithSchool(
            school: selectedSchool,
            displayName: state.displayName,
            grade: grade,
          );
      ref.read(currentProfileProvider.notifier).setProfile(profile);
      state = state.copyWith(status: LoginSubmissionStatus.idle);
      return profile;
    } on AppException catch (error) {
      state = state.copyWith(
        status: LoginSubmissionStatus.idle,
        errorMessage: error.userMessage,
      );
      return null;
    }
  }
}
