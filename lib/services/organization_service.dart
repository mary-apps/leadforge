import '../models/organization.dart';
import 'supabase_service.dart';

class OrganizationService {
  /// Create org (uses RPC to also add owner as member)
  static Future<Organization> createOrganization(String name) async {
    final orgId = await SupabaseService.client
        .rpc('create_organization', params: {'p_name': name});
    // Fetch the created org
    final response = await SupabaseService.client
        .from('organizations')
        .select()
        .eq('id', '$orgId')
        .single();
    return Organization.fromJson(response);
  }

  /// Fetch current user's organization
  static Future<Organization?> fetchMyOrganization() async {
    final userId = SupabaseService.userId;
    if (userId == null) return null;

    // Get org_id from profile
    final profile = await SupabaseService.client
        .from('profiles')
        .select('org_id')
        .eq('id', userId)
        .single();

    final orgId = profile['org_id'];
    if (orgId == null) return null;

    final response = await SupabaseService.client
        .from('organizations')
        .select()
        .eq('id', '$orgId')
        .single();
    return Organization.fromJson(response);
  }

  /// Fetch members of an organization
  static Future<List<OrgMember>> fetchMembers(String orgId) async {
    final response = await SupabaseService.client
        .from('org_members')
        .select('*, profiles(display_name)')
        .eq('org_id', orgId)
        .order('joined_at');

    return (response as List).map((json) {
      // Flatten the joined profiles data
      final member = Map<String, dynamic>.from(json as Map);
      if (member['profiles'] is Map) {
        member['display_name'] =
            (member['profiles'] as Map)['display_name'];
      }
      member.remove('profiles');
      return OrgMember.fromJson(member);
    }).toList();
  }

  /// Invite a member by user_id (caller passes user_id directly)
  static Future<void> inviteMember(
    String orgId,
    String userId, {
    String role = 'member',
  }) async {
    await SupabaseService.client.rpc('invite_org_member', params: {
      'p_org_id': orgId,
      'p_user_id': userId,
      'p_role': role,
    });
  }

  /// Remove a member
  static Future<void> removeMember(String orgId, String userId) async {
    await SupabaseService.client
        .from('org_members')
        .delete()
        .eq('org_id', orgId)
        .eq('user_id', userId);

    // Clear their org_id in profile
    await SupabaseService.client
        .from('profiles')
        .update({'org_id': null}).eq('id', userId);
  }

  /// Leave an organization
  static Future<void> leaveOrganization(String orgId) async {
    final userId = SupabaseService.userId;
    if (userId == null) return;
    await removeMember(orgId, userId);
  }
}
