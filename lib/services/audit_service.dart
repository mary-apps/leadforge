import '../models/audit_result.dart';
import '../utils/network.dart';

class AuditService {
  /// Run AI audit on a business
  static Future<AuditResult> auditBusiness(String businessId) async {
    final data = await invokeEdgeFunction(
      'audit',
      body: {'business_id': businessId},
      timeout: const Duration(seconds: 60),
    );

    // Edge function may return audit nested under a key or flat
    final auditJson = data['audit'] as Map<String, dynamic>? ??
        data['result'] as Map<String, dynamic>? ??
        data;

    return AuditResult.fromJson(auditJson);
  }
}
