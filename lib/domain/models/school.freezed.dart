// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'school.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$School {

 String? get id;@JsonKey(name: 'standard_school_code') String get standardSchoolCode;@JsonKey(name: 'office_code') String? get officeCode;@JsonKey(name: 'office_name') String? get officeName;@JsonKey(name: 'school_name') String get schoolName;@JsonKey(name: 'school_name_eng') String? get schoolNameEng;@JsonKey(name: 'school_kind') String? get schoolKind;@JsonKey(name: 'region_name') String? get regionName;@JsonKey(name: 'jurisdiction_name') String? get jurisdictionName;@JsonKey(name: 'establishment_type') String? get establishmentType;@JsonKey(name: 'road_zip_code') String? get roadZipCode;@JsonKey(name: 'road_address') String? get roadAddress;@JsonKey(name: 'road_detail_address') String? get roadDetailAddress;@JsonKey(name: 'phone_number') String? get phoneNumber;@JsonKey(name: 'homepage_url') String? get homepageUrl;@JsonKey(name: 'coeducation_type') String? get coeducationType;@JsonKey(name: 'fax_number') String? get faxNumber;@JsonKey(name: 'founded_at') String? get foundedAt;@JsonKey(name: 'anniversary_at') String? get anniversaryAt;@JsonKey(name: 'source_updated_at') String? get sourceUpdatedAt;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'is_demo') bool get isDemo;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchoolCopyWith<School> get copyWith => _$SchoolCopyWithImpl<School>(this as School, _$identity);

  /// Serializes this School to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is School&&(identical(other.id, id) || other.id == id)&&(identical(other.standardSchoolCode, standardSchoolCode) || other.standardSchoolCode == standardSchoolCode)&&(identical(other.officeCode, officeCode) || other.officeCode == officeCode)&&(identical(other.officeName, officeName) || other.officeName == officeName)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.schoolNameEng, schoolNameEng) || other.schoolNameEng == schoolNameEng)&&(identical(other.schoolKind, schoolKind) || other.schoolKind == schoolKind)&&(identical(other.regionName, regionName) || other.regionName == regionName)&&(identical(other.jurisdictionName, jurisdictionName) || other.jurisdictionName == jurisdictionName)&&(identical(other.establishmentType, establishmentType) || other.establishmentType == establishmentType)&&(identical(other.roadZipCode, roadZipCode) || other.roadZipCode == roadZipCode)&&(identical(other.roadAddress, roadAddress) || other.roadAddress == roadAddress)&&(identical(other.roadDetailAddress, roadDetailAddress) || other.roadDetailAddress == roadDetailAddress)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.homepageUrl, homepageUrl) || other.homepageUrl == homepageUrl)&&(identical(other.coeducationType, coeducationType) || other.coeducationType == coeducationType)&&(identical(other.faxNumber, faxNumber) || other.faxNumber == faxNumber)&&(identical(other.foundedAt, foundedAt) || other.foundedAt == foundedAt)&&(identical(other.anniversaryAt, anniversaryAt) || other.anniversaryAt == anniversaryAt)&&(identical(other.sourceUpdatedAt, sourceUpdatedAt) || other.sourceUpdatedAt == sourceUpdatedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isDemo, isDemo) || other.isDemo == isDemo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,standardSchoolCode,officeCode,officeName,schoolName,schoolNameEng,schoolKind,regionName,jurisdictionName,establishmentType,roadZipCode,roadAddress,roadDetailAddress,phoneNumber,homepageUrl,coeducationType,faxNumber,foundedAt,anniversaryAt,sourceUpdatedAt,isActive,isDemo,createdAt,updatedAt]);

@override
String toString() {
  return 'School(id: $id, standardSchoolCode: $standardSchoolCode, officeCode: $officeCode, officeName: $officeName, schoolName: $schoolName, schoolNameEng: $schoolNameEng, schoolKind: $schoolKind, regionName: $regionName, jurisdictionName: $jurisdictionName, establishmentType: $establishmentType, roadZipCode: $roadZipCode, roadAddress: $roadAddress, roadDetailAddress: $roadDetailAddress, phoneNumber: $phoneNumber, homepageUrl: $homepageUrl, coeducationType: $coeducationType, faxNumber: $faxNumber, foundedAt: $foundedAt, anniversaryAt: $anniversaryAt, sourceUpdatedAt: $sourceUpdatedAt, isActive: $isActive, isDemo: $isDemo, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SchoolCopyWith<$Res>  {
  factory $SchoolCopyWith(School value, $Res Function(School) _then) = _$SchoolCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'standard_school_code') String standardSchoolCode,@JsonKey(name: 'office_code') String? officeCode,@JsonKey(name: 'office_name') String? officeName,@JsonKey(name: 'school_name') String schoolName,@JsonKey(name: 'school_name_eng') String? schoolNameEng,@JsonKey(name: 'school_kind') String? schoolKind,@JsonKey(name: 'region_name') String? regionName,@JsonKey(name: 'jurisdiction_name') String? jurisdictionName,@JsonKey(name: 'establishment_type') String? establishmentType,@JsonKey(name: 'road_zip_code') String? roadZipCode,@JsonKey(name: 'road_address') String? roadAddress,@JsonKey(name: 'road_detail_address') String? roadDetailAddress,@JsonKey(name: 'phone_number') String? phoneNumber,@JsonKey(name: 'homepage_url') String? homepageUrl,@JsonKey(name: 'coeducation_type') String? coeducationType,@JsonKey(name: 'fax_number') String? faxNumber,@JsonKey(name: 'founded_at') String? foundedAt,@JsonKey(name: 'anniversary_at') String? anniversaryAt,@JsonKey(name: 'source_updated_at') String? sourceUpdatedAt,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_demo') bool isDemo,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$SchoolCopyWithImpl<$Res>
    implements $SchoolCopyWith<$Res> {
  _$SchoolCopyWithImpl(this._self, this._then);

  final School _self;
  final $Res Function(School) _then;

/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? standardSchoolCode = null,Object? officeCode = freezed,Object? officeName = freezed,Object? schoolName = null,Object? schoolNameEng = freezed,Object? schoolKind = freezed,Object? regionName = freezed,Object? jurisdictionName = freezed,Object? establishmentType = freezed,Object? roadZipCode = freezed,Object? roadAddress = freezed,Object? roadDetailAddress = freezed,Object? phoneNumber = freezed,Object? homepageUrl = freezed,Object? coeducationType = freezed,Object? faxNumber = freezed,Object? foundedAt = freezed,Object? anniversaryAt = freezed,Object? sourceUpdatedAt = freezed,Object? isActive = null,Object? isDemo = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,standardSchoolCode: null == standardSchoolCode ? _self.standardSchoolCode : standardSchoolCode // ignore: cast_nullable_to_non_nullable
as String,officeCode: freezed == officeCode ? _self.officeCode : officeCode // ignore: cast_nullable_to_non_nullable
as String?,officeName: freezed == officeName ? _self.officeName : officeName // ignore: cast_nullable_to_non_nullable
as String?,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,schoolNameEng: freezed == schoolNameEng ? _self.schoolNameEng : schoolNameEng // ignore: cast_nullable_to_non_nullable
as String?,schoolKind: freezed == schoolKind ? _self.schoolKind : schoolKind // ignore: cast_nullable_to_non_nullable
as String?,regionName: freezed == regionName ? _self.regionName : regionName // ignore: cast_nullable_to_non_nullable
as String?,jurisdictionName: freezed == jurisdictionName ? _self.jurisdictionName : jurisdictionName // ignore: cast_nullable_to_non_nullable
as String?,establishmentType: freezed == establishmentType ? _self.establishmentType : establishmentType // ignore: cast_nullable_to_non_nullable
as String?,roadZipCode: freezed == roadZipCode ? _self.roadZipCode : roadZipCode // ignore: cast_nullable_to_non_nullable
as String?,roadAddress: freezed == roadAddress ? _self.roadAddress : roadAddress // ignore: cast_nullable_to_non_nullable
as String?,roadDetailAddress: freezed == roadDetailAddress ? _self.roadDetailAddress : roadDetailAddress // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,homepageUrl: freezed == homepageUrl ? _self.homepageUrl : homepageUrl // ignore: cast_nullable_to_non_nullable
as String?,coeducationType: freezed == coeducationType ? _self.coeducationType : coeducationType // ignore: cast_nullable_to_non_nullable
as String?,faxNumber: freezed == faxNumber ? _self.faxNumber : faxNumber // ignore: cast_nullable_to_non_nullable
as String?,foundedAt: freezed == foundedAt ? _self.foundedAt : foundedAt // ignore: cast_nullable_to_non_nullable
as String?,anniversaryAt: freezed == anniversaryAt ? _self.anniversaryAt : anniversaryAt // ignore: cast_nullable_to_non_nullable
as String?,sourceUpdatedAt: freezed == sourceUpdatedAt ? _self.sourceUpdatedAt : sourceUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isDemo: null == isDemo ? _self.isDemo : isDemo // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [School].
extension SchoolPatterns on School {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _School value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _School() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _School value)  $default,){
final _that = this;
switch (_that) {
case _School():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _School value)?  $default,){
final _that = this;
switch (_that) {
case _School() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'standard_school_code')  String standardSchoolCode, @JsonKey(name: 'office_code')  String? officeCode, @JsonKey(name: 'office_name')  String? officeName, @JsonKey(name: 'school_name')  String schoolName, @JsonKey(name: 'school_name_eng')  String? schoolNameEng, @JsonKey(name: 'school_kind')  String? schoolKind, @JsonKey(name: 'region_name')  String? regionName, @JsonKey(name: 'jurisdiction_name')  String? jurisdictionName, @JsonKey(name: 'establishment_type')  String? establishmentType, @JsonKey(name: 'road_zip_code')  String? roadZipCode, @JsonKey(name: 'road_address')  String? roadAddress, @JsonKey(name: 'road_detail_address')  String? roadDetailAddress, @JsonKey(name: 'phone_number')  String? phoneNumber, @JsonKey(name: 'homepage_url')  String? homepageUrl, @JsonKey(name: 'coeducation_type')  String? coeducationType, @JsonKey(name: 'fax_number')  String? faxNumber, @JsonKey(name: 'founded_at')  String? foundedAt, @JsonKey(name: 'anniversary_at')  String? anniversaryAt, @JsonKey(name: 'source_updated_at')  String? sourceUpdatedAt, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_demo')  bool isDemo, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _School() when $default != null:
return $default(_that.id,_that.standardSchoolCode,_that.officeCode,_that.officeName,_that.schoolName,_that.schoolNameEng,_that.schoolKind,_that.regionName,_that.jurisdictionName,_that.establishmentType,_that.roadZipCode,_that.roadAddress,_that.roadDetailAddress,_that.phoneNumber,_that.homepageUrl,_that.coeducationType,_that.faxNumber,_that.foundedAt,_that.anniversaryAt,_that.sourceUpdatedAt,_that.isActive,_that.isDemo,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'standard_school_code')  String standardSchoolCode, @JsonKey(name: 'office_code')  String? officeCode, @JsonKey(name: 'office_name')  String? officeName, @JsonKey(name: 'school_name')  String schoolName, @JsonKey(name: 'school_name_eng')  String? schoolNameEng, @JsonKey(name: 'school_kind')  String? schoolKind, @JsonKey(name: 'region_name')  String? regionName, @JsonKey(name: 'jurisdiction_name')  String? jurisdictionName, @JsonKey(name: 'establishment_type')  String? establishmentType, @JsonKey(name: 'road_zip_code')  String? roadZipCode, @JsonKey(name: 'road_address')  String? roadAddress, @JsonKey(name: 'road_detail_address')  String? roadDetailAddress, @JsonKey(name: 'phone_number')  String? phoneNumber, @JsonKey(name: 'homepage_url')  String? homepageUrl, @JsonKey(name: 'coeducation_type')  String? coeducationType, @JsonKey(name: 'fax_number')  String? faxNumber, @JsonKey(name: 'founded_at')  String? foundedAt, @JsonKey(name: 'anniversary_at')  String? anniversaryAt, @JsonKey(name: 'source_updated_at')  String? sourceUpdatedAt, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_demo')  bool isDemo, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _School():
return $default(_that.id,_that.standardSchoolCode,_that.officeCode,_that.officeName,_that.schoolName,_that.schoolNameEng,_that.schoolKind,_that.regionName,_that.jurisdictionName,_that.establishmentType,_that.roadZipCode,_that.roadAddress,_that.roadDetailAddress,_that.phoneNumber,_that.homepageUrl,_that.coeducationType,_that.faxNumber,_that.foundedAt,_that.anniversaryAt,_that.sourceUpdatedAt,_that.isActive,_that.isDemo,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'standard_school_code')  String standardSchoolCode, @JsonKey(name: 'office_code')  String? officeCode, @JsonKey(name: 'office_name')  String? officeName, @JsonKey(name: 'school_name')  String schoolName, @JsonKey(name: 'school_name_eng')  String? schoolNameEng, @JsonKey(name: 'school_kind')  String? schoolKind, @JsonKey(name: 'region_name')  String? regionName, @JsonKey(name: 'jurisdiction_name')  String? jurisdictionName, @JsonKey(name: 'establishment_type')  String? establishmentType, @JsonKey(name: 'road_zip_code')  String? roadZipCode, @JsonKey(name: 'road_address')  String? roadAddress, @JsonKey(name: 'road_detail_address')  String? roadDetailAddress, @JsonKey(name: 'phone_number')  String? phoneNumber, @JsonKey(name: 'homepage_url')  String? homepageUrl, @JsonKey(name: 'coeducation_type')  String? coeducationType, @JsonKey(name: 'fax_number')  String? faxNumber, @JsonKey(name: 'founded_at')  String? foundedAt, @JsonKey(name: 'anniversary_at')  String? anniversaryAt, @JsonKey(name: 'source_updated_at')  String? sourceUpdatedAt, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_demo')  bool isDemo, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _School() when $default != null:
return $default(_that.id,_that.standardSchoolCode,_that.officeCode,_that.officeName,_that.schoolName,_that.schoolNameEng,_that.schoolKind,_that.regionName,_that.jurisdictionName,_that.establishmentType,_that.roadZipCode,_that.roadAddress,_that.roadDetailAddress,_that.phoneNumber,_that.homepageUrl,_that.coeducationType,_that.faxNumber,_that.foundedAt,_that.anniversaryAt,_that.sourceUpdatedAt,_that.isActive,_that.isDemo,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _School implements School {
  const _School({this.id, @JsonKey(name: 'standard_school_code') required this.standardSchoolCode, @JsonKey(name: 'office_code') this.officeCode, @JsonKey(name: 'office_name') this.officeName, @JsonKey(name: 'school_name') required this.schoolName, @JsonKey(name: 'school_name_eng') this.schoolNameEng, @JsonKey(name: 'school_kind') this.schoolKind, @JsonKey(name: 'region_name') this.regionName, @JsonKey(name: 'jurisdiction_name') this.jurisdictionName, @JsonKey(name: 'establishment_type') this.establishmentType, @JsonKey(name: 'road_zip_code') this.roadZipCode, @JsonKey(name: 'road_address') this.roadAddress, @JsonKey(name: 'road_detail_address') this.roadDetailAddress, @JsonKey(name: 'phone_number') this.phoneNumber, @JsonKey(name: 'homepage_url') this.homepageUrl, @JsonKey(name: 'coeducation_type') this.coeducationType, @JsonKey(name: 'fax_number') this.faxNumber, @JsonKey(name: 'founded_at') this.foundedAt, @JsonKey(name: 'anniversary_at') this.anniversaryAt, @JsonKey(name: 'source_updated_at') this.sourceUpdatedAt, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'is_demo') this.isDemo = false, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'standard_school_code') final  String standardSchoolCode;
@override@JsonKey(name: 'office_code') final  String? officeCode;
@override@JsonKey(name: 'office_name') final  String? officeName;
@override@JsonKey(name: 'school_name') final  String schoolName;
@override@JsonKey(name: 'school_name_eng') final  String? schoolNameEng;
@override@JsonKey(name: 'school_kind') final  String? schoolKind;
@override@JsonKey(name: 'region_name') final  String? regionName;
@override@JsonKey(name: 'jurisdiction_name') final  String? jurisdictionName;
@override@JsonKey(name: 'establishment_type') final  String? establishmentType;
@override@JsonKey(name: 'road_zip_code') final  String? roadZipCode;
@override@JsonKey(name: 'road_address') final  String? roadAddress;
@override@JsonKey(name: 'road_detail_address') final  String? roadDetailAddress;
@override@JsonKey(name: 'phone_number') final  String? phoneNumber;
@override@JsonKey(name: 'homepage_url') final  String? homepageUrl;
@override@JsonKey(name: 'coeducation_type') final  String? coeducationType;
@override@JsonKey(name: 'fax_number') final  String? faxNumber;
@override@JsonKey(name: 'founded_at') final  String? foundedAt;
@override@JsonKey(name: 'anniversary_at') final  String? anniversaryAt;
@override@JsonKey(name: 'source_updated_at') final  String? sourceUpdatedAt;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'is_demo') final  bool isDemo;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchoolCopyWith<_School> get copyWith => __$SchoolCopyWithImpl<_School>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchoolToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _School&&(identical(other.id, id) || other.id == id)&&(identical(other.standardSchoolCode, standardSchoolCode) || other.standardSchoolCode == standardSchoolCode)&&(identical(other.officeCode, officeCode) || other.officeCode == officeCode)&&(identical(other.officeName, officeName) || other.officeName == officeName)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.schoolNameEng, schoolNameEng) || other.schoolNameEng == schoolNameEng)&&(identical(other.schoolKind, schoolKind) || other.schoolKind == schoolKind)&&(identical(other.regionName, regionName) || other.regionName == regionName)&&(identical(other.jurisdictionName, jurisdictionName) || other.jurisdictionName == jurisdictionName)&&(identical(other.establishmentType, establishmentType) || other.establishmentType == establishmentType)&&(identical(other.roadZipCode, roadZipCode) || other.roadZipCode == roadZipCode)&&(identical(other.roadAddress, roadAddress) || other.roadAddress == roadAddress)&&(identical(other.roadDetailAddress, roadDetailAddress) || other.roadDetailAddress == roadDetailAddress)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.homepageUrl, homepageUrl) || other.homepageUrl == homepageUrl)&&(identical(other.coeducationType, coeducationType) || other.coeducationType == coeducationType)&&(identical(other.faxNumber, faxNumber) || other.faxNumber == faxNumber)&&(identical(other.foundedAt, foundedAt) || other.foundedAt == foundedAt)&&(identical(other.anniversaryAt, anniversaryAt) || other.anniversaryAt == anniversaryAt)&&(identical(other.sourceUpdatedAt, sourceUpdatedAt) || other.sourceUpdatedAt == sourceUpdatedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isDemo, isDemo) || other.isDemo == isDemo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,standardSchoolCode,officeCode,officeName,schoolName,schoolNameEng,schoolKind,regionName,jurisdictionName,establishmentType,roadZipCode,roadAddress,roadDetailAddress,phoneNumber,homepageUrl,coeducationType,faxNumber,foundedAt,anniversaryAt,sourceUpdatedAt,isActive,isDemo,createdAt,updatedAt]);

@override
String toString() {
  return 'School(id: $id, standardSchoolCode: $standardSchoolCode, officeCode: $officeCode, officeName: $officeName, schoolName: $schoolName, schoolNameEng: $schoolNameEng, schoolKind: $schoolKind, regionName: $regionName, jurisdictionName: $jurisdictionName, establishmentType: $establishmentType, roadZipCode: $roadZipCode, roadAddress: $roadAddress, roadDetailAddress: $roadDetailAddress, phoneNumber: $phoneNumber, homepageUrl: $homepageUrl, coeducationType: $coeducationType, faxNumber: $faxNumber, foundedAt: $foundedAt, anniversaryAt: $anniversaryAt, sourceUpdatedAt: $sourceUpdatedAt, isActive: $isActive, isDemo: $isDemo, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SchoolCopyWith<$Res> implements $SchoolCopyWith<$Res> {
  factory _$SchoolCopyWith(_School value, $Res Function(_School) _then) = __$SchoolCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'standard_school_code') String standardSchoolCode,@JsonKey(name: 'office_code') String? officeCode,@JsonKey(name: 'office_name') String? officeName,@JsonKey(name: 'school_name') String schoolName,@JsonKey(name: 'school_name_eng') String? schoolNameEng,@JsonKey(name: 'school_kind') String? schoolKind,@JsonKey(name: 'region_name') String? regionName,@JsonKey(name: 'jurisdiction_name') String? jurisdictionName,@JsonKey(name: 'establishment_type') String? establishmentType,@JsonKey(name: 'road_zip_code') String? roadZipCode,@JsonKey(name: 'road_address') String? roadAddress,@JsonKey(name: 'road_detail_address') String? roadDetailAddress,@JsonKey(name: 'phone_number') String? phoneNumber,@JsonKey(name: 'homepage_url') String? homepageUrl,@JsonKey(name: 'coeducation_type') String? coeducationType,@JsonKey(name: 'fax_number') String? faxNumber,@JsonKey(name: 'founded_at') String? foundedAt,@JsonKey(name: 'anniversary_at') String? anniversaryAt,@JsonKey(name: 'source_updated_at') String? sourceUpdatedAt,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_demo') bool isDemo,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$SchoolCopyWithImpl<$Res>
    implements _$SchoolCopyWith<$Res> {
  __$SchoolCopyWithImpl(this._self, this._then);

  final _School _self;
  final $Res Function(_School) _then;

/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? standardSchoolCode = null,Object? officeCode = freezed,Object? officeName = freezed,Object? schoolName = null,Object? schoolNameEng = freezed,Object? schoolKind = freezed,Object? regionName = freezed,Object? jurisdictionName = freezed,Object? establishmentType = freezed,Object? roadZipCode = freezed,Object? roadAddress = freezed,Object? roadDetailAddress = freezed,Object? phoneNumber = freezed,Object? homepageUrl = freezed,Object? coeducationType = freezed,Object? faxNumber = freezed,Object? foundedAt = freezed,Object? anniversaryAt = freezed,Object? sourceUpdatedAt = freezed,Object? isActive = null,Object? isDemo = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_School(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,standardSchoolCode: null == standardSchoolCode ? _self.standardSchoolCode : standardSchoolCode // ignore: cast_nullable_to_non_nullable
as String,officeCode: freezed == officeCode ? _self.officeCode : officeCode // ignore: cast_nullable_to_non_nullable
as String?,officeName: freezed == officeName ? _self.officeName : officeName // ignore: cast_nullable_to_non_nullable
as String?,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,schoolNameEng: freezed == schoolNameEng ? _self.schoolNameEng : schoolNameEng // ignore: cast_nullable_to_non_nullable
as String?,schoolKind: freezed == schoolKind ? _self.schoolKind : schoolKind // ignore: cast_nullable_to_non_nullable
as String?,regionName: freezed == regionName ? _self.regionName : regionName // ignore: cast_nullable_to_non_nullable
as String?,jurisdictionName: freezed == jurisdictionName ? _self.jurisdictionName : jurisdictionName // ignore: cast_nullable_to_non_nullable
as String?,establishmentType: freezed == establishmentType ? _self.establishmentType : establishmentType // ignore: cast_nullable_to_non_nullable
as String?,roadZipCode: freezed == roadZipCode ? _self.roadZipCode : roadZipCode // ignore: cast_nullable_to_non_nullable
as String?,roadAddress: freezed == roadAddress ? _self.roadAddress : roadAddress // ignore: cast_nullable_to_non_nullable
as String?,roadDetailAddress: freezed == roadDetailAddress ? _self.roadDetailAddress : roadDetailAddress // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,homepageUrl: freezed == homepageUrl ? _self.homepageUrl : homepageUrl // ignore: cast_nullable_to_non_nullable
as String?,coeducationType: freezed == coeducationType ? _self.coeducationType : coeducationType // ignore: cast_nullable_to_non_nullable
as String?,faxNumber: freezed == faxNumber ? _self.faxNumber : faxNumber // ignore: cast_nullable_to_non_nullable
as String?,foundedAt: freezed == foundedAt ? _self.foundedAt : foundedAt // ignore: cast_nullable_to_non_nullable
as String?,anniversaryAt: freezed == anniversaryAt ? _self.anniversaryAt : anniversaryAt // ignore: cast_nullable_to_non_nullable
as String?,sourceUpdatedAt: freezed == sourceUpdatedAt ? _self.sourceUpdatedAt : sourceUpdatedAt // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isDemo: null == isDemo ? _self.isDemo : isDemo // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
