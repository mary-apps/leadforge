import 'dart:convert';
import 'package:flutter/foundation.dart';
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

    final response = await httpWithRetry(
      () => http.post(
        Uri.parse(AppConstants.buildDemoEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      ),
      timeout: const Duration(seconds: 90),
      maxRetries: 1,
    );

    try {
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['demo'] != null) {
        return Demo.fromJson(data['demo'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Build demo response parsing failed: $e, falling back to DB fetch');
    }

    final demo = await fetchDemo(businessId);
    if (demo == null) {
      throw Exception('Demo was created but could not be fetched');
    }

    return demo;
  }
  
  /// Fetch demo for a business (latest one if multiple exist)
  static Future<Demo?> fetchDemo(String businessId) async {
    final response = await SupabaseService.client
        .from('demos')
        .select()
        .eq('business_id', businessId)
        .order('created_at', ascending: false)
        .limit(1);

    if (response.isEmpty) return null;

    return Demo.fromJson(response.first);
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
