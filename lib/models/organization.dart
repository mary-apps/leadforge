import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization.freezed.dart';
part 'organization.g.dart';

@freezed
class Organization with _$Organization {
  const factory Organization({
    required String id,
    required String name,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Organization;

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);
}

@freezed
class OrgMember with _$OrgMember {
  const factory OrgMember({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'user_id') required String userId,
    required String role,
    @JsonKey(name: 'joined_at') required DateTime joinedAt,
    // Joined from profiles table
    String? displayName,
    String? email,
  }) = _OrgMember;

  factory OrgMember.fromJson(Map<String, dynamic> json) =>
      _$OrgMemberFromJson(json);
}
