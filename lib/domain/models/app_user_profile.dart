import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user_profile.freezed.dart';
part 'app_user_profile.g.dart';

@JsonEnum()
enum UserRole {
  @JsonValue('student')
  student,
  @JsonValue('teacher')
  teacher,
  @JsonValue('admin')
  admin,
}

@freezed
abstract class AppUserProfile with _$AppUserProfile {
  const factory AppUserProfile({
    required String id,
    @Default(UserRole.student) UserRole role,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'school_id') String? schoolId,
    @JsonKey(name: 'standard_school_code') String? standardSchoolCode,
    @JsonKey(name: 'school_name') String? schoolName,
    int? grade,
    @JsonKey(name: 'class_name') String? className,
    @Default(1) int level,
    @JsonKey(name: 'total_xp') @Default(0) int totalXp,
    @Default(0) int coins,
    @JsonKey(name: 'is_demo') @Default(false) bool isDemo,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _AppUserProfile;

  factory AppUserProfile.fromJson(Map<String, dynamic> json) =>
      _$AppUserProfileFromJson(json);
}
