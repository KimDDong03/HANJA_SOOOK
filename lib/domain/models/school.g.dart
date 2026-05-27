// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_School _$SchoolFromJson(Map<String, dynamic> json) => _School(
  id: json['id'] as String?,
  standardSchoolCode: json['standard_school_code'] as String,
  officeCode: json['office_code'] as String?,
  officeName: json['office_name'] as String?,
  schoolName: json['school_name'] as String,
  schoolNameEng: json['school_name_eng'] as String?,
  schoolKind: json['school_kind'] as String?,
  regionName: json['region_name'] as String?,
  jurisdictionName: json['jurisdiction_name'] as String?,
  establishmentType: json['establishment_type'] as String?,
  roadZipCode: json['road_zip_code'] as String?,
  roadAddress: json['road_address'] as String?,
  roadDetailAddress: json['road_detail_address'] as String?,
  phoneNumber: json['phone_number'] as String?,
  homepageUrl: json['homepage_url'] as String?,
  coeducationType: json['coeducation_type'] as String?,
  faxNumber: json['fax_number'] as String?,
  foundedAt: json['founded_at'] as String?,
  anniversaryAt: json['anniversary_at'] as String?,
  sourceUpdatedAt: json['source_updated_at'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  isDemo: json['is_demo'] as bool? ?? false,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SchoolToJson(_School instance) => <String, dynamic>{
  'id': instance.id,
  'standard_school_code': instance.standardSchoolCode,
  'office_code': instance.officeCode,
  'office_name': instance.officeName,
  'school_name': instance.schoolName,
  'school_name_eng': instance.schoolNameEng,
  'school_kind': instance.schoolKind,
  'region_name': instance.regionName,
  'jurisdiction_name': instance.jurisdictionName,
  'establishment_type': instance.establishmentType,
  'road_zip_code': instance.roadZipCode,
  'road_address': instance.roadAddress,
  'road_detail_address': instance.roadDetailAddress,
  'phone_number': instance.phoneNumber,
  'homepage_url': instance.homepageUrl,
  'coeducation_type': instance.coeducationType,
  'fax_number': instance.faxNumber,
  'founded_at': instance.foundedAt,
  'anniversary_at': instance.anniversaryAt,
  'source_updated_at': instance.sourceUpdatedAt,
  'is_active': instance.isActive,
  'is_demo': instance.isDemo,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
