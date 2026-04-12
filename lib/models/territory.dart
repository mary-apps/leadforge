import 'package:freezed_annotation/freezed_annotation.dart';

part 'territory.freezed.dart';
part 'territory.g.dart';

@freezed
class Territory with _$Territory {
  const factory Territory({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    required String query,
    required double latitude,
    required double longitude,
    @JsonKey(name: 'radius_km') @Default(2.0) double radiusKm,
    @JsonKey(name: 'business_count') @Default(0) int businessCount,
    @JsonKey(name: 'audited_count') @Default(0) int auditedCount,
    @JsonKey(name: 'last_scanned_at') DateTime? lastScannedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Territory;

  factory Territory.fromJson(Map<String, dynamic> json) =>
      _$TerritoryFromJson(json);
}
