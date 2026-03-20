import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/audit_result.dart';
import '../utils/network.dart';
import 'supabase_service.dart';

class AuditService {
  /// Run AI audit on a business
  static Future<AuditResult> auditBusiness(String businessId) async {
    final token = await SupabaseService.getAuthToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await httpWithRetry(() => http.post(
      Uri.parse(AppConstants.auditEndpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'business_id': businessId,
      }),
    ));

    final dynamic data;
    try {
      data = json.decode(response.body);
    } catch (e) {
      throw Exception('Invalid response from audit service');
    }
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected audit response format');
    }
    return AuditResult.fromJson(data);
  }
}
