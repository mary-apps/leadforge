import 'package:freezed_annotation/freezed_annotation.dart';

part 'report.freezed.dart';
part 'report.g.dart';

@freezed
class Report with _$Report {
  const factory Report({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'user_id') required String userId,
    required int score,
    required Map<String, dynamic> breakdown,
    required String diagnosis,
    @Default([]) List<String> recommendations,
    @JsonKey(name: 'pdf_storage_path') String? pdfStoragePath,
    @JsonKey(name: 'shared_at') DateTime? sharedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}
