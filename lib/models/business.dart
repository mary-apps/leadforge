import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/cupertino.dart';

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
  const Business._();
  const factory Business({
    required String id,
    String? userId,
    String? searchId,
    String? placeId,
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
    DateTime? createdAt,
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

  /// Returns a Cupertino icon for web-presence status
  IconData get webPresenceIcon {
    switch (webPresence) {
      case WebPresence.none:
        return CupertinoIcons.xmark_circle_fill;
      case WebPresence.poor:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case WebPresence.decent:
        return CupertinoIcons.check_mark_circled_solid;
    }
  }

  /// Returns a Cupertino icon for pipeline status
  IconData get statusIcon {
    switch (status) {
      case BusinessStatus.found:
        return CupertinoIcons.search;
      case BusinessStatus.audited:
        return CupertinoIcons.chart_bar;
      case BusinessStatus.demoCreated:
        return CupertinoIcons.globe;
      case BusinessStatus.contacted:
        return CupertinoIcons.paperplane;
      case BusinessStatus.interested:
        return CupertinoIcons.hand_thumbsup;
      case BusinessStatus.closed:
        return CupertinoIcons.checkmark_seal;
      case BusinessStatus.lost:
        return CupertinoIcons.nosign;
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

  /// Returns a human-readable label for the pipeline status
  String get statusLabel {
    switch (status) {
      case BusinessStatus.found:
        return 'Found';
      case BusinessStatus.audited:
        return 'Audited';
      case BusinessStatus.demoCreated:
        return 'Demo Created';
      case BusinessStatus.contacted:
        return 'Contacted';
      case BusinessStatus.interested:
        return 'Interested';
      case BusinessStatus.closed:
        return 'Closed';
      case BusinessStatus.lost:
        return 'Lost';
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
