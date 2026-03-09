import 'package:freezed_annotation/freezed_annotation.dart';

part 'business.freezed.dart';
part 'business.g.dart';

enum WebPresence {
  @JsonValue('none') none,
  @JsonValue('poor') poor,
  @JsonValue('decent') decent,
}

enum BusinessStatus {
  @JsonValue('found') found,
  @JsonValue('audited') audited,
  @JsonValue('demo_created') demoCreated,
  @JsonValue('contacted') contacted,
  @JsonValue('interested') interested,
  @JsonValue('closed') closed,
  @JsonValue('lost') lost,
}

@freezed
class Business with _$Business {
  const factory Business({
    required String id,
    required String userId,
    String? searchId,
    required String placeId,
    required String name,
    String? address,
    String? phone,
    String? website,
    double? latitude,
    double? longitude,
    double? rating,
    @Default(0) int reviewsCount,
    @Default([]) List<String> photos,
    @Default([]) List<String> categories,
    Map<String, dynamic>? openingHours,
    @Default(WebPresence.none) WebPresence webPresence,
    int? auditScore,
    Map<String, dynamic>? auditBreakdown,
    String? auditDiagnosis,
    DateTime? auditedAt,
    @Default(BusinessStatus.found) BusinessStatus status,
    String? notes,
    double? dealValue,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Business;

  factory Business.fromJson(Map<String, dynamic> json) =>
      _$BusinessFromJson(json);
}

extension BusinessX on Business {
  /// Returns first photo reference or null
  String? get primaryPhoto => photos.isNotEmpty ? photos.first : null;
  
  /// Returns formatted address (first line only)
  String? get shortAddress {
    if (address == null) return null;
    return address!.split(',').first;
  }
  
  /// Returns true if business has been audited
  bool get isAudited => auditScore != null;
  
  /// Returns true if business has demo
  bool get hasDemo => status == BusinessStatus.demoCreated ||
      status == BusinessStatus.contacted ||
      status == BusinessStatus.interested ||
      status == BusinessStatus.closed;
  
  /// Returns status color
  String get statusBadge {
    switch (webPresence) {
      case WebPresence.none:
        return '🔴';
      case WebPresence.poor:
        return '🟡';
      case WebPresence.decent:
        return '🟢';
    }
  }
}
