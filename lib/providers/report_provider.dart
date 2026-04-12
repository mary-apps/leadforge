import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report.dart';
import '../services/report_service.dart';

final reportForBusinessProvider =
    FutureProvider.autoDispose.family<Report?, String>((ref, businessId) async {
  return ReportService.fetchReport(businessId);
});
