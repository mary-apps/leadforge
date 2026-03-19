import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/demo.dart';
import '../services/build_service.dart';

/// Fetches the latest demo for a business. Auto-disposed.
final demoForBusinessProvider =
    FutureProvider.autoDispose.family<Demo?, String>((ref, businessId) async {
  return await BuildService.fetchDemo(businessId);
});
