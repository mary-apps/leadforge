import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/demo.dart';
import 'supabase_service.dart';

class BuildService {
  /// Generate demo site for a business
  static Future<Demo> generateDemo({
    required String businessId,
    required DemoTemplate template,
  }) async {
    final token = await SupabaseService.getAuthToken();
    
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final response = await http.post(
      Uri.parse(AppConstants.buildDemoEndpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'business_id': businessId,
        'template': template.toString().split('.').last,
      }),
    );
    
    if (response.statusCode == 402) {
      throw LimitReachedException('Free tier demo limit reached');
    }
    
    if (response.statusCode != 200) {
      throw Exception('Demo generation failed: ${response.body}');
    }
    
    final data = json.decode(response.body);
    
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

class LimitReachedException implements Exception {
  final String message;
  LimitReachedException(this.message);
  
  @override
  String toString() => message;
}
