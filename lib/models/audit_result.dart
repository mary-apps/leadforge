import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_result.freezed.dart';
part 'audit_result.g.dart';

@freezed
class AuditResult with _$AuditResult {
  const factory AuditResult({
    required int score,
    required Map<String, AuditFactor> breakdown,
    required String diagnosis,
  }) = _AuditResult;

  factory AuditResult.fromJson(Map<String, dynamic> json) =>
      _$AuditResultFromJson(json);
}

@freezed
class AuditFactor with _$AuditFactor {
  const factory AuditFactor({
    required String label,
    required int impact,
    required bool passed,
    @Default('medium') String severity,
    @Default([]) List<String> recommendations,
    String? details,
  }) = _AuditFactor;

  factory AuditFactor.fromJson(Map<String, dynamic> json) =>
      _$AuditFactorFromJson(json);
}
