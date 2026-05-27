// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUserProfile _$AppUserProfileFromJson(Map<String, dynamic> json) =>
    _AppUserProfile(
      id: json['id'] as String,
      role:
          $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ??
          UserRole.student,
      displayName: json['display_name'] as String,
      schoolId: json['school_id'] as String?,
      standardSchoolCode: json['standard_school_code'] as String?,
      schoolName: json['school_name'] as String?,
      grade: (json['grade'] as num?)?.toInt(),
      className: json['class_name'] as String?,
      level: (json['level'] as num?)?.toInt() ?? 1,
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      isDemo: json['is_demo'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AppUserProfileToJson(_AppUserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$UserRoleEnumMap[instance.role]!,
      'display_name': instance.displayName,
      'school_id': instance.schoolId,
      'standard_school_code': instance.standardSchoolCode,
      'school_name': instance.schoolName,
      'grade': instance.grade,
      'class_name': instance.className,
      'level': instance.level,
      'total_xp': instance.totalXp,
      'coins': instance.coins,
      'is_demo': instance.isDemo,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.student: 'student',
  UserRole.teacher: 'teacher',
  UserRole.admin: 'admin',
};
