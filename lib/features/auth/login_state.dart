import '../../domain/models/school.dart';

enum LoginSubmissionStatus { idle, searching, signingIn }

class LoginState {
  const LoginState({
    this.keyword = '',
    this.displayName = '',
    this.grade,
    this.selectedSchool,
    this.searchResults = const [],
    this.status = LoginSubmissionStatus.idle,
    this.errorMessage,
  });

  final String keyword;
  final String displayName;
  final int? grade;
  final School? selectedSchool;
  final List<School> searchResults;
  final LoginSubmissionStatus status;
  final String? errorMessage;

  bool get isSearching => status == LoginSubmissionStatus.searching;
  bool get isSigningIn => status == LoginSubmissionStatus.signingIn;

  LoginState copyWith({
    String? keyword,
    String? displayName,
    Object? grade = _sentinel,
    Object? selectedSchool = _sentinel,
    List<School>? searchResults,
    LoginSubmissionStatus? status,
    Object? errorMessage = _sentinel,
  }) {
    return LoginState(
      keyword: keyword ?? this.keyword,
      displayName: displayName ?? this.displayName,
      grade: grade == _sentinel ? this.grade : grade as int?,
      selectedSchool: selectedSchool == _sentinel
          ? this.selectedSchool
          : selectedSchool as School?,
      searchResults: searchResults ?? this.searchResults,
      status: status ?? this.status,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const _sentinel = Object();
