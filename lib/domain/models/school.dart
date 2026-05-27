import 'package:freezed_annotation/freezed_annotation.dart';

part 'school.freezed.dart';
part 'school.g.dart';

@freezed
abstract class School with _$School {
  const factory School({
    String? id,
    @JsonKey(name: 'standard_school_code')
    required String standardSchoolCode,
    @JsonKey(name: 'office_code') String? officeCode,
    @JsonKey(name: 'office_name') String? officeName,
    @JsonKey(name: 'school_name') required String schoolName,
    @JsonKey(name: 'school_name_eng') String? schoolNameEng,
    @JsonKey(name: 'school_kind') String? schoolKind,
    @JsonKey(name: 'region_name') String? regionName,
    @JsonKey(name: 'jurisdiction_name') String? jurisdictionName,
    @JsonKey(name: 'establishment_type') String? establishmentType,
    @JsonKey(name: 'road_zip_code') String? roadZipCode,
    @JsonKey(name: 'road_address') String? roadAddress,
    @JsonKey(name: 'road_detail_address') String? roadDetailAddress,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'homepage_url') String? homepageUrl,
    @JsonKey(name: 'coeducation_type') String? coeducationType,
    @JsonKey(name: 'fax_number') String? faxNumber,
    @JsonKey(name: 'founded_at') String? foundedAt,
    @JsonKey(name: 'anniversary_at') String? anniversaryAt,
    @JsonKey(name: 'source_updated_at') String? sourceUpdatedAt,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_demo') @Default(false) bool isDemo,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _School;

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);
}
