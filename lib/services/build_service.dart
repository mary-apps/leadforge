import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/demo.dart';
import '../utils/network.dart';
import 'supabase_service.dart';

class BuildService {
  /// Generate unique AI-powered demo site for a business
  static Future<Demo> generateDemo({
    required String businessId,
    String? customNotes,
  }) async {
    final token = await SupabaseService.getAuthToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final body = <String, dynamic>{
      'business_id': businessId,
    };
    if (customNotes != null && customNotes.trim().isNotEmpty) {
      body['custom_notes'] = customNotes.trim();
    }

    await httpWithRetry(() => http.post(
      Uri.parse(AppConstants.buildDemoEndpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    ));

    // Fetch the created demo from database
    final demo = await fetchDemo(businessId);
    if (demo == null) {
      throw Exception('Demo was created but could not be fetched');
    }

    return demo;
  }
  
  /// Fetch demo for a business
  static Future<Demo?> fetchDemo(String businessId) async {
    final response = await SupabaseService.client
        .from('demos')
        .select()
        .eq('business_id', businessId)
        .maybeSingle();
    
    if (response == null) return null;
    
    return Demo.fromJson(response);
  }
  
  /// Fetch all demos for current user
  static Future<List<Demo>> fetchMyDemos() async {
    final userId = SupabaseService.userId;
    if (userId == null) throw Exception('Not authenticated');
    
    final response = await SupabaseService.client
        .from('demos')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => Demo.fromJson(json as Map<String, dynamic>))
        .toList();
  }
  
  /// Delete demo
  static Future<void> deleteDemo(String demoId) async {
    await SupabaseService.client
        .from('demos')
        .delete()
        .eq('id', demoId);
  }
}

// LimitReachedException is in utils/network.dart
