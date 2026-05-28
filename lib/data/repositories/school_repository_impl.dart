import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/models/app_user_profile.dart';
import '../../domain/models/school.dart';
import '../../domain/repositories/school_repository.dart';

class SchoolRepositoryImpl implements SchoolRepository {
  const SchoolRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<School>> searchSchools({
    required String keyword,
    String? regionName,
    int limit = AppConstants.schoolSearchLimit,
  }) async {
    final normalizedKeyword = keyword.trim();
    if (normalizedKeyword.length < AppConstants.schoolSearchMinLength) {
      throw const AppException(
        code: AppExceptionCode.validation,
        message: '학교명을 2글자 이상 입력해주세요.',
      );
    }

    try {
      var query = _client
          .from('schools')
          .select()
          .eq('school_kind', '초등학교')
          .eq('is_active', true)
          .ilike('school_name', '%$normalizedKeyword%');

      if (regionName != null && regionName.trim().isNotEmpty) {
        query = query.eq('region_name', regionName.trim());
      }

      final rows = await query.order('school_name').limit(limit);
      final schools = rows
          .map((row) => School.fromJson(Map<String, dynamic>.from(row)))
          .toList();

      schools.sort((a, b) {
        final aStarts = a.schoolName.startsWith(normalizedKeyword);
        final bStarts = b.schoolName.startsWith(normalizedKeyword);
        if (aStarts != bStarts) {
          return aStarts ? -1 : 1;
        }
        return a.schoolName.compareTo(b.schoolName);
      });

      return schools;
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      throw AppException(
        code: AppExceptionCode.network,
        message: '학교 검색에 실패했습니다.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<School?> getSchoolByStandardCode(String standardSchoolCode) async {
    final code = standardSchoolCode.trim();
    if (code.isEmpty) {
      return null;
    }

    try {
      final row = await _client
          .from('schools')
          .select()
          .eq('standard_school_code', code)
          .eq('school_kind', '초등학교')
          .eq('is_active', true)
          .maybeSingle();
      if (row == null) {
        return null;
      }
      return School.fromJson(Map<String, dynamic>.from(row));
    } catch (error, stackTrace) {
      throw AppException(
        code: AppExceptionCode.network,
        message: '학교 정보를 불러오지 못했습니다.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<AppUserProfile?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final row = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (row == null) {
        return null;
      }
      return AppUserProfile.fromJson(Map<String, dynamic>.from(row));
    } catch (error, stackTrace) {
      throw AppException(
        code: AppExceptionCode.network,
        message: '학생 정보를 불러오지 못했습니다.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<AppUserProfile> signInStudentWithSchool({
    required School school,
    required String displayName,
    required int grade,
  }) async {
    final name = displayName.trim();
    if (name.isEmpty) {
      throw const AppException(
        code: AppExceptionCode.validation,
        message: '이름을 입력해주세요.',
      );
    }
    if (!AppConstants.supportedGrades.contains(grade)) {
      throw const AppException(
        code: AppExceptionCode.validation,
        message: '학년을 선택해주세요.',
      );
    }

    try {
      final authResponse = await _client.auth.signInAnonymously();
      final user = authResponse.user ?? _client.auth.currentUser;
      if (user == null) {
        throw const AppException(
          code: AppExceptionCode.unauthorized,
          message: '로그인에 실패했습니다.',
        );
      }

      final profileRow = await _client
          .from('profiles')
          .upsert({
            'id': user.id,
            'role': 'student',
            'display_name': name,
            'school_id': school.id,
            'standard_school_code': school.standardSchoolCode,
            'school_name': school.schoolName,
            'grade': grade,
            'is_demo': true,
          })
          .select()
          .single();

      return AppUserProfile.fromJson(Map<String, dynamic>.from(profileRow));
    } on AppException {
      rethrow;
    } on AuthException catch (error, stackTrace) {
      final isAnonymousDisabled = error.code == 'anonymous_provider_disabled';
      throw AppException(
        code: isAnonymousDisabled
            ? AppExceptionCode.unknown
            : AppExceptionCode.network,
        message: isAnonymousDisabled
            ? 'Supabase Anonymous sign-in 설정을 켜주세요.'
            : '인터넷 연결을 확인한 뒤 다시 시도해주세요.',
        cause: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      throw AppException(
        code: AppExceptionCode.network,
        message: '인터넷 연결을 확인한 뒤 다시 시도해주세요.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
