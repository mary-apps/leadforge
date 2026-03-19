import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message.dart';
import '../services/outreach_service.dart';

/// Fetches the latest outreach message for a business. Auto-disposed.
final outreachForBusinessProvider =
    FutureProvider.autoDispose.family<Message?, String>((ref, businessId) async {
  return await OutreachService.fetchLatestOutreach(businessId);
});
