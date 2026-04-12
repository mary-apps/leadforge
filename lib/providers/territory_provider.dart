import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/business.dart';
import '../models/territory.dart';
import '../services/supabase_service.dart';
import '../services/territory_service.dart';

/// All territories for current user
final territoriesProvider =
    StateNotifierProvider<TerritoriesNotifier, AsyncValue<List<Territory>>>(
        (ref) {
  return TerritoriesNotifier();
});

class TerritoriesNotifier extends StateNotifier<AsyncValue<List<Territory>>> {
  TerritoriesNotifier() : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    final previous = state.valueOrNull;
    if (previous == null) {
      state = const AsyncValue.loading();
    }

    try {
      final userId = SupabaseService.userId;
      String? orgId;
      if (userId != null) {
        final profile = await SupabaseService.client
            .from('profiles')
            .select('org_id')
            .eq('id', userId)
            .single();
        orgId = profile['org_id'] as String?;
      }

      final territories = await TerritoryService.fetchTerritories(orgId: orgId);
      if (mounted) state = AsyncValue.data(territories);
    } catch (e, st) {
      if (mounted) {
        state = previous != null
            ? AsyncValue.data(previous)
            : AsyncValue.error(e, st);
      }
    }
  }

  Future<Territory> create({
    required String name,
    required String query,
    required double latitude,
    required double longitude,
    double radiusKm = 2.0,
  }) async {
    final territory = await TerritoryService.createTerritory(
      name: name,
      query: query,
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
    // Add to current list
    final current = state.valueOrNull ?? [];
    if (mounted) state = AsyncValue.data([territory, ...current]);
    return territory;
  }

  Future<void> delete(String territoryId) async {
    await TerritoryService.deleteTerritory(territoryId);
    final current = state.valueOrNull ?? [];
    if (mounted) {
      state = AsyncValue.data(
          current.where((t) => t.id != territoryId).toList());
    }
  }
}

/// Businesses in a specific territory
final businessesInTerritoryProvider =
    FutureProvider.autoDispose.family<List<Business>, String>(
        (ref, territoryId) async {
  return TerritoryService.fetchBusinessesInTerritory(territoryId);
});
