import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message.dart';
import '../services/outreach_service.dart';

/// Fetches all outreach messages for a business. Auto-disposed.
final messagesForBusinessProvider =
    FutureProvider.autoDispose.family<List<Message>, String>((ref, businessId) async {
  return await OutreachService.fetchMessages(businessId);
});
