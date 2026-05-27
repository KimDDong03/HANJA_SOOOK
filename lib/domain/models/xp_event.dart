import 'package:freezed_annotation/freezed_annotation.dart';

part 'xp_event.freezed.dart';
part 'xp_event.g.dart';

@freezed
abstract class XpEvent with _$XpEvent {
  const factory XpEvent({
    String? id,
    @JsonKey(name: 'user_id') required String userId,
    required String source,
    required int amount,
    @JsonKey(name: 'ref_table') String? refTable,
    @JsonKey(name: 'ref_id') String? refId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _XpEvent;

  factory XpEvent.fromJson(Map<String, dynamic> json) =>
      _$XpEventFromJson(json);
}
