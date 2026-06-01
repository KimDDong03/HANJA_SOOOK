import '../models/app_user_profile.dart';
import '../models/school.dart';

abstract class SchoolRepository {
  Future<List<School>> searchSchools({
    required String keyword,
    String? regionName,
    int limit = 20,
  });

  Future<School?> getSchoolByStandardCode(String standardSchoolCode);

  Future<AppUserProfile?> getCurrentProfile();

  Future<AppUserProfile> signInStudentWithSchool({
    required School school,
    required String displayName,
    required int grade,
  });

  Future<AppUserProfile> updateStudentProfile({
    required String profileId,
    required String displayName,
    required int grade,
    required School school,
    required String avatarKey,
  });

  Future<void> signOut();
}
