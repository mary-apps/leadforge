import '../models/business.dart';
import '../models/territory.dart';
import 'supabase_service.dart';

class TerritoryService {
  /// Create a new territory
  static Future<Territory> createTerritory({
    required String name,
    required String query,
    required double latitude,
    required double longitude,
    double radiusKm = 2.0,
  }) async {
    final userId = SupabaseService.userId;
    if (userId == null) throw Exception('Not authenticated');

    final response = await SupabaseService.client
        .from('territories')
        .insert({
          'user_id': userId,
          'name': name,
          'query': query,
          'latitude': latitude,
          'longitude': longitude,
          'radius_km': radiusKm,
        })
        .select()
        .single();

    return Territory.fromJson(response);
  }

  /// Fetch all territories.
  /// If [orgId] is provided, fetches all territories belonging to the org;
  /// otherwise fetches only the current user's territories.
  static Future<List<Territory>> fetchTerritories({String? orgId}) async {
    final userId = SupabaseService.userId;
    if (userId == null) throw Exception('Not authenticated');

    var query = SupabaseService.client.from('territories').select();

    if (orgId != null) {
      query = query.eq('org_id', orgId);
    } else {
      query = query.eq('user_id', userId);
    }

    final response = await query.order('created_at', ascending: false);

    final list = response as List?;
    if (list == null) return [];
    return list
        .map((json) => Territory.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Delete a territory
  static Future<void> deleteTerritory(String territoryId) async {
    await SupabaseService.client
        .from('territories')
        .delete()
        .eq('id', territoryId);
  }

  /// Fetch businesses in a territory
  static Future<List<Business>> fetchBusinessesInTerritory(
      String territoryId) async {
    final response = await SupabaseService.client
        .from('businesses')
        .select()
        .eq('territory_id', territoryId)
        .order('audit_score', ascending: true);

    final list = response as List?;
    if (list == null) return [];
    return list
        .map((json) => Business.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
