import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/business.dart';
import '../services/scout_service.dart';
import 'audit_state_provider.dart';
import '../services/audit_service.dart';
import 'profile_provider.dart';

/// Businesses list provider — user's saved businesses from DB
class BusinessesNotifier extends StateNotifier<AsyncValue<List<Business>>> {
  BusinessesNotifier() : super(const AsyncValue.loading()) {
    load();
  }

  /// Reload from DB. Preserves previous data while loading to avoid flicker.
  Future<void> load({BusinessStatus? status}) async {
    final previous = state.valueOrNull;
    if (previous == null) {
      state = const AsyncValue.loading();
    }

    try {
      final businesses = await ScoutService.fetchMyBusinesses(status: status);
      state = AsyncValue.data(businesses);
    } catch (e, st) {
      state = previous != null
          ? AsyncValue.data(previous)
          : AsyncValue.error(e, st);
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

/// Scout search results — separate from saved businesses, cached between navigations
class ScoutResultsNotifier extends StateNotifier<AsyncValue<List<Business>>> {
  ScoutResultsNotifier() : super(const AsyncValue.data([]));

  String? _lastQuery;
  String? get lastQuery => _lastQuery;

  Future<void> search(String query) async {
    _lastQuery = query;
    state = const AsyncValue.loading();

    try {
      final businesses = await ScoutService.searchBusinesses(query);
      state = AsyncValue.data(businesses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  void clear() {
    _lastQuery = null;
    state = const AsyncValue.data([]);
  }
}

final businessesProvider =
    StateNotifierProvider<BusinessesNotifier, AsyncValue<List<Business>>>((ref) {
  return BusinessesNotifier();
});

/// Scout search results provider — cached, separate from saved businesses
final scoutResultsProvider =
    StateNotifierProvider<ScoutResultsNotifier, AsyncValue<List<Business>>>((ref) {
  return ScoutResultsNotifier();
});

/// Single business provider — cached per ID
final businessProvider = FutureProvider.family<Business?, String>((ref, id) async {
  ref.keepAlive();
  return await ScoutService.fetchBusiness(id);
});

/// Pipeline businesses grouped by status — cached, invalidated via ref.invalidate
final pipelineProvider = FutureProvider<Map<BusinessStatus, List<Business>>>((ref) async {
  ref.keepAlive();
  final businesses = await ScoutService.fetchMyBusinesses(limit: 200);

  final grouped = <BusinessStatus, List<Business>>{};

  for (final status in BusinessStatus.values) {
    grouped[status] = businesses.where((b) => b.status == status).toList();
  }

  return grouped;
});

/// Fire audit in background and manage provider invalidation chain.
Future<void> triggerAutoAudit(WidgetRef ref, String businessId) async {
  // Mark as loading
  ref.read(auditStateProvider(businessId).notifier).state =
      const AsyncValue.loading();

  try {
    await AuditService.auditBusiness(businessId);

    // Mark as complete
    ref.read(auditStateProvider(businessId).notifier).state =
        const AsyncValue.data(null);

    // Invalidation chain
    ref.invalidate(businessProvider(businessId));
    ref.invalidate(pipelineProvider);
    await ref.read(businessesProvider.notifier).load();
    ref.read(profileNotifierProvider.notifier).reload();
  } catch (e, st) {
    ref.read(auditStateProvider(businessId).notifier).state =
        AsyncValue.error(e, st);
  }
}
