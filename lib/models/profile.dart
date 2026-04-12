import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    String? displayName,
    String? businessName,
    @Default('en') String preferredLanguage,
    @Default('free') String subscriptionTier,
    @Default(0) int searchesThisMonth,
    @Default(0) int auditsThisMonth,
    @Default(0) int reportsThisMonth,
    DateTime? monthResetAt,
    DateTime? createdAt,
    @JsonKey(name: 'org_id') String? orgId,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

extension ProfileX on Profile {
  bool get isPro => subscriptionTier == 'pro';
  bool get isFree => subscriptionTier == 'free';
  
  bool get canSearch => isPro || searchesThisMonth < 5;
  bool get canAudit => isPro || auditsThisMonth < 3;
  bool get canGenerateReport => isPro || reportsThisMonth < 5;
  bool get canUseOutreach => isPro; // Pro only

  int get searchesRemaining => isPro ? 999 : (5 - searchesThisMonth).clamp(0, 5);
  int get auditsRemaining => isPro ? 999 : (3 - auditsThisMonth).clamp(0, 3);
  int get reportsRemaining => isPro ? 999 : (5 - reportsThisMonth).clamp(0, 5);
}
