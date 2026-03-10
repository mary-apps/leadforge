import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

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
  
  /// Returns status color (kept for plain-text share formatting)
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

  /// Returns a Material icon for web-presence status
  IconData get webPresenceIcon {
    switch (webPresence) {
      case WebPresence.none:
        return Icons.cancel_rounded;
      case WebPresence.poor:
        return Icons.warning_amber_rounded;
      case WebPresence.decent:
        return Icons.check_circle_rounded;
    }
  }

  /// Returns a Material icon for pipeline status
  IconData get statusIcon {
    switch (status) {
      case BusinessStatus.found:
        return Icons.travel_explore_rounded;
      case BusinessStatus.audited:
        return Icons.query_stats_rounded;
      case BusinessStatus.demoCreated:
        return Icons.web_rounded;
      case BusinessStatus.contacted:
        return Icons.send_rounded;
      case BusinessStatus.interested:
        return Icons.thumb_up_rounded;
      case BusinessStatus.closed:
        return Icons.handshake_rounded;
      case BusinessStatus.lost:
        return Icons.block_rounded;
    }
  }

  /// Returns a color for pipeline status
  Color get statusColor {
    switch (status) {
      case BusinessStatus.found:
        return const Color(0x73FFFFFF); // textSecondary
      case BusinessStatus.audited:
        return const Color(0xFF48CAE4); // secondary
      case BusinessStatus.demoCreated:
        return const Color(0xFF00B4D8); // primary
      case BusinessStatus.contacted:
        return const Color(0xFF34D399); // success
      case BusinessStatus.interested:
        return const Color(0xFF48CAE4); // info
      case BusinessStatus.closed:
        return const Color(0xFF34D399); // success
      case BusinessStatus.lost:
        return const Color(0xFFF87171); // danger
    }
  }

  /// Returns a color for web-presence status
  Color get webPresenceColor {
    switch (webPresence) {
      case WebPresence.none:
        return const Color(0xFFF87171); // danger
      case WebPresence.poor:
        return const Color(0xFFFBBF24); // warning
      case WebPresence.decent:
        return const Color(0xFF34D399); // success
    }
  }
}
