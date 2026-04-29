import 'package:freezed_annotation/freezed_annotation.dart';

import '../config/constants.dart';

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

  bool get canSearch =>
      isPro || searchesThisMonth < AppConstants.freeSearchesPerMonth;
  bool get canAudit =>
      isPro || auditsThisMonth < AppConstants.freeAuditsPerMonth;
  bool get canGenerateReport =>
      isPro || reportsThisMonth < AppConstants.freeReportsPerMonth;
  bool get canUseOutreach => isPro; // Pro only
  bool get canCreateTerritory => isPro;

  int get searchesRemaining => isPro
      ? 999
      : (AppConstants.freeSearchesPerMonth - searchesThisMonth)
          .clamp(0, AppConstants.freeSearchesPerMonth);
  int get auditsRemaining => isPro
      ? 999
      : (AppConstants.freeAuditsPerMonth - auditsThisMonth)
          .clamp(0, AppConstants.freeAuditsPerMonth);
  int get reportsRemaining => isPro
      ? 999
      : (AppConstants.freeReportsPerMonth - reportsThisMonth)
          .clamp(0, AppConstants.freeReportsPerMonth);
}
