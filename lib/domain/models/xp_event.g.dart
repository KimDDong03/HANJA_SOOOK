// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_XpEvent _$XpEventFromJson(Map<String, dynamic> json) => _XpEvent(
  id: json['id'] as String?,
  userId: json['user_id'] as String,
  source: json['source'] as String,
  amount: (json['amount'] as num).toInt(),
  refTable: json['ref_table'] as String?,
  refId: json['ref_id'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$XpEventToJson(_XpEvent instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'source': instance.source,
  'amount': instance.amount,
  'ref_table': instance.refTable,
  'ref_id': instance.refId,
  'created_at': instance.createdAt?.toIso8601String(),
};
