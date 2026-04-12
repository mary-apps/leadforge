import 'package:flutter/foundation.dart';

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
    bool? reportAvailable,
  }) async {
    final data = await invokeEdgeFunction(
      'outreach',
      body: {
        'business_id': businessId,
        'channel': channel.name,
        'tone': tone,
        'language': language,
        if (reportAvailable != null) 'has_report': reportAvailable,
      },
    );

    try {
      if (data['message'] != null) {
        return Message.fromJson(data['message'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Outreach response parsing failed: $e, falling back to DB fetch');
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

    final list = response as List?;
    if (list == null) return [];
    return list
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
