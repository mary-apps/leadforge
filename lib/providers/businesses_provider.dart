import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/business.dart';
import '../services/scout_service.dart';

/// Businesses list provider
class BusinessesNotifier extends StateNotifier<AsyncValue<List<Business>>> {
  BusinessesNotifier() : super(const AsyncValue.loading()) {
    load();
  }
  
  Future<void> load({BusinessStatus? status}) async {
    state = const AsyncValue.loading();
    
    try {
      final businesses = await ScoutService.fetchMyBusinesses(status: status);
      state = AsyncValue.data(businesses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    
    try {
      final businesses = await ScoutService.searchBusinesses(query);
      state = AsyncValue.data(businesses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> updateStatus(String businessId, BusinessStatus status) async {
    await ScoutService.updateStatus(businessId, status);
    await load();
  }
  
  Future<void> deleteBusiness(String businessId) async {
    await ScoutService.deleteBusiness(businessId);
    await load();
  }
}

final businessesProvider = 
    StateNotifierProvider<BusinessesNotifier, AsyncValue<List<Business>>>((ref) {
  return BusinessesNotifier();
});

/// Single business provider
final businessProvider = FutureProvider.family<Business?, String>((ref, id) async {
  return await ScoutService.fetchBusiness(id);
});

/// Pipeline businesses grouped by status
final pipelineProvider = FutureProvider<Map<BusinessStatus, List<Business>>>((ref) async {
  final businesses = await ScoutService.fetchMyBusinesses(limit: 200);
  
  final grouped = <BusinessStatus, List<Business>>{};
  
  for (final status in BusinessStatus.values) {
    grouped[status] = businesses.where((b) => b.status == status).toList();
  }
  
  return grouped;
});
