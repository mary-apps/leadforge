import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/organization.dart';
import '../services/organization_service.dart';

/// Current user's organization (null if not in one)
final organizationProvider =
    FutureProvider.autoDispose<Organization?>((ref) async {
  return OrganizationService.fetchMyOrganization();
});

/// Members of the current organization
final orgMembersProvider =
    FutureProvider.autoDispose.family<List<OrgMember>, String>(
        (ref, orgId) async {
  return OrganizationService.fetchMembers(orgId);
});
