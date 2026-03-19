import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/message.dart';
import '../utils/network.dart';
import 'supabase_service.dart';

class OutreachService {
  /// Generate outreach message (Pro only)
  static Future<Message> generateMessage({
    required String businessId,
    required OutreachChannel channel,
    required String tone,
    required String language,
    String? demoUrl,
  }) async {
    final token = await SupabaseService.getAuthToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await httpWithRetry(() => http.post(
      Uri.parse(AppConstants.outreachEndpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'business_id': businessId,
        'channel': channel.name,
        'tone': tone,
        'language': language,
        if (demoUrl != null) 'demo_url': demoUrl,
      }),
    ));

    try {
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['message'] != null) {
        return Message.fromJson(data['message'] as Map<String, dynamic>);
      }
    } catch (_) {
      // Fallback: fetch from database if response parsing fails
    }

    final messages = await fetchMessages(businessId);
    if (messages.isEmpty) {
      throw Exception('Message was created but could not be fetched');
    }

    return messages.first;
  }

  /// Fetch messages for a business
  static Future<List<Message>> fetchMessages(String businessId) async {
    final response = await SupabaseService.client
        .from('messages')
        .select()
        .eq('business_id', businessId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Message.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch the most recent outreach message for a business
  static Future<Message?> fetchLatestOutreach(String businessId) async {
    final response = await SupabaseService.client
        .from('messages')
        .select()
        .eq('business_id', businessId)
        .order('created_at', ascending: false)
        .limit(1);

    if (response.isEmpty) return null;
    return Message.fromJson(response.first);
  }

  /// Mark message as copied
  static Future<void> markCopied(String messageId) async {
    await SupabaseService.client
        .from('messages')
        .update({'copied_at': DateTime.now().toIso8601String()})
        .eq('id', messageId);
  }

  /// Mark message as sent
  static Future<void> markSent(String messageId) async {
    await SupabaseService.client
        .from('messages')
        .update({'marked_sent_at': DateTime.now().toIso8601String()})
        .eq('id', messageId);
  }
}

// ProRequiredException is in utils/network.dart
