import 'package:freezed_annotation/freezed_annotation.dart';

import '../config/constants.dart';

part 'demo.freezed.dart';
part 'demo.g.dart';

enum DemoTemplate {
  @JsonValue('restaurant') restaurant,
  @JsonValue('professional') professional,
  @JsonValue('health_beauty') healthBeauty,
  @JsonValue('warm_organic') warmOrganic,
  @JsonValue('soft_glass') softGlass,
  @JsonValue('editorial_luxury') editorialLuxury,
  @JsonValue('bold_modern') boldModern,
  @JsonValue('fresh_startup') freshStartup,
  @JsonValue('dark_premium') darkPremium,
}

@freezed
class Demo with _$Demo {
  const factory Demo({
    required String id,
    required String businessId,
    required String userId,
    required DemoTemplate template,
    required String storagePath,
    required String publicSlug,
    required Map<String, dynamic> businessData,
    @Default(0) int views,
    DateTime? lastViewedAt,
    required DateTime createdAt,
  }) = _Demo;

  factory Demo.fromJson(Map<String, dynamic> json) =>
      _$DemoFromJson(json);
}

extension DemoX on Demo {
  String get publicUrl => '${AppConstants.supabaseUrl}/functions/v1/demo/$publicSlug';
  
  String get templateLabel {
    switch (template) {
      case DemoTemplate.restaurant:
        return 'Restaurant / Café';
      case DemoTemplate.professional:
        return 'Professional Services';
      case DemoTemplate.healthBeauty:
        return 'Health & Beauty';
      case DemoTemplate.warmOrganic:
        return 'Warm Organic';
      case DemoTemplate.softGlass:
        return 'Soft Glassmorphism';
      case DemoTemplate.editorialLuxury:
        return 'Editorial Luxury';
      case DemoTemplate.boldModern:
        return 'Bold Modern';
      case DemoTemplate.freshStartup:
        return 'Fresh Startup';
      case DemoTemplate.darkPremium:
        return 'Dark Premium';
    }
  }
}
