import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/business.dart';
import 'supabase_service.dart';

class ScoutService {
  /// Search for businesses using Google Places API via Edge Function
  static Future<List<Business>> searchBusinesses(String query) async {
    final token = await SupabaseService.getAuthToken();
    
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final response = await http.post(
      Uri.parse(AppConstants.scoutEndpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'query': query,
      }),
    );
    
    if (response.statusCode == 402) {
      throw LimitReachedException('Free tier search limit reached');
    }
    
    if (response.statusCode != 200) {
      throw Exception('Search failed: ${response.body}');
    }
    
    final data = json.decode(response.body);
    final businessesJson = data['businesses'] as List;
    
    return businessesJson
        .map((json) => Business.fromJson(json as Map<String, dynamic>))
        .toList();
  }
  
  /// Fetch businesses from local database
  static Future<List<Business>> fetchMyBusinesses({
    BusinessStatus? status,
    int limit = 50,
  }) async {
    final userId = SupabaseService.userId;
    if (userId == null) throw Exception('Not authenticated');
    
    var query = SupabaseService.client
        .from('businesses')
        .select()
        .eq('user_id', userId);

    if (status != null) {
      query = query.eq('status', status.toString().split('.').last);
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);
    
    return (response as List)
        .map((json) => Business.fromJson(json as Map<String, dynamic>))
        .toList();
  }
  
  /// Fetch single business by ID
  static Future<Business?> fetchBusiness(String businessId) async {
    final response = await SupabaseService.client
        .from('businesses')
        .select()
        .eq('id', businessId)
        .maybeSingle();
    
    if (response == null) return null;
    
    return Business.fromJson(response);
  }
  
  /// Update business notes
  static Future<void> updateNotes(String businessId, String notes) async {
    await SupabaseService.client
        .from('businesses')
        .update({'notes': notes})
        .eq('id', businessId);
  }
  
  /// Update business status
  static Future<void> updateStatus(String businessId, BusinessStatus status) async {
    await SupabaseService.client
        .from('businesses')
        .update({
          'status': status.toString().split('.').last,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', businessId);
  }
  
  /// Update deal value
  static Future<void> updateDealValue(String businessId, double? value) async {
    await SupabaseService.client
        .from('businesses')
        .update({'deal_value': value})
        .eq('id', businessId);
  }
  
  /// Delete business
  static Future<void> deleteBusiness(String businessId) async {
    await SupabaseService.client
        .from('businesses')
        .delete()
        .eq('id', businessId);
  }
}

class LimitReachedException implements Exception {
  final String message;
  LimitReachedException(this.message);
  
  @override
  String toString() => message;
}
