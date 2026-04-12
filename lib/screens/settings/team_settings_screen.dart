import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../models/organization.dart';
import '../../providers/organization_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/organization_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/haptics.dart';
import '../../widgets/ios_toast.dart';

class TeamSettingsScreen extends ConsumerStatefulWidget {
  const TeamSettingsScreen({super.key});

  @override
  ConsumerState<TeamSettingsScreen> createState() => _TeamSettingsScreenState();
}

class _TeamSettingsScreenState extends ConsumerState<TeamSettingsScreen> {
  final _orgNameController = TextEditingController();
  final _inviteUserIdController = TextEditingController();
  int _selectedRole = 0; // 0 = member, 1 = admin
  bool _isCreating = false;
  bool _isInviting = false;

  @override
  void dispose() {
    _orgNameController.dispose();
    _inviteUserIdController.dispose();
    super.dispose();
  }

  Future<void> _createOrganization() async {
    final name = _orgNameController.text.trim();
    if (name.length < 2) {
      IosToast.show(context, 'Name must be at least 2 characters');
      return;
    }
    setState(() => _isCreating = true);
    Haptics.medium();
    try {
      await OrganizationService.createOrganization(name);
      ref.invalidate(organizationProvider);
      ref.invalidate(profileNotifierProvider);
      ref.read(profileNotifierProvider.notifier).reload();
      if (mounted) {
        IosToast.show(context, 'Organization created');
        _orgNameController.clear();
      }
    } catch (e) {
      if (mounted) {
        IosToast.show(context, 'Failed to create organization');
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _inviteMember(String orgId) async {
    final userId = _inviteUserIdController.text.trim();
    if (userId.isEmpty) {
      IosToast.show(context, 'Enter a user ID');
      return;
    }
    setState(() => _isInviting = true);
    Haptics.light();
    try {
      final role = _selectedRole == 1 ? 'admin' : 'member';
      await OrganizationService.inviteMember(orgId, userId, role: role);
      ref.invalidate(orgMembersProvider(orgId));
      if (mounted) {
        IosToast.show(context, 'Member invited');
        _inviteUserIdController.clear();
      }
    } catch (e) {
      if (mounted) {
        IosToast.show(context, 'Failed to invite member');
      }
    } finally {
      if (mounted) setState(() => _isInviting = false);
    }
  }

  Future<void> _removeMember(String orgId, OrgMember member) async {
    Haptics.medium();
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Remove Member'),
        content: Text(
          'Remove ${member.displayName ?? 'this member'} from the organization?',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await OrganizationService.removeMember(orgId, member.userId);
      ref.invalidate(orgMembersProvider(orgId));
      if (mounted) {
        IosToast.show(context, 'Member removed');
      }
    } catch (e) {
      if (mounted) {
        IosToast.show(context, 'Failed to remove member');
      }
    }
  }

  Future<void> _leaveOrganization(String orgId) async {
    Haptics.heavy();
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Leave Organization'),
        content: const Text(
          'Are you sure you want to leave this organization? You will lose access to shared territories and reports.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await OrganizationService.leaveOrganization(orgId);
      ref.invalidate(organizationProvider);
      ref.invalidate(profileNotifierProvider);
      ref.read(profileNotifierProvider.notifier).reload();
      if (mounted) {
        IosToast.show(context, 'You have left the organization');
      }
    } catch (e) {
      if (mounted) {
        IosToast.show(context, 'Failed to leave organization');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgAsync = ref.watch(organizationProvider);
    final accentColor =
        CupertinoDynamicColor.resolve(AppColors.accent, context);

    return CupertinoPageScaffold(
      backgroundColor:
          CupertinoDynamicColor.resolve(AppColors.background, context),
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Team'),
        backgroundColor:
            CupertinoDynamicColor.resolve(AppColors.background, context),
        border: null,
      ),
      child: orgAsync.when(
        data: (org) => org == null
            ? _buildCreateState(context, accentColor)
            : _buildOrgState(context, org, accentColor),
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (_, __) => Center(
          child: Text(
            'Failed to load team',
            style: AppTypography.bodyMedium(context),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // State A: No organization
  // ---------------------------------------------------------------------------

  Widget _buildCreateState(BuildContext context, Color accentColor) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(AppColors.radiusL),
                  ),
                  child: Icon(
                    CupertinoIcons.person_2_fill,
                    color: CupertinoDynamicColor.resolve(
                        AppColors.chipActiveFg, context),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Text(
                  'Create Your Team',
                  style: AppTypography.headlineLarge(context),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create an organization to share territories, businesses, and reports with your team.',
                  style: AppTypography.bodyMedium(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.textSecondary, context),
                  ),
                ),
                const SizedBox(height: 32),

                // Org name input
                CupertinoTextField(
                  controller: _orgNameController,
                  placeholder: 'Organization name',
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.searchField, context),
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                  ),
                  style: AppTypography.bodyMedium(context),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Create button
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                    onPressed: _isCreating ? null : _createOrganization,
                    child: _isCreating
                        ? CupertinoActivityIndicator(
                            color: CupertinoDynamicColor.resolve(
                                AppColors.chipActiveFg, context),
                          )
                        : Text(
                            'Create Organization',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: CupertinoDynamicColor.resolve(
                                  AppColors.chipActiveFg, context),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // State B: Has organization
  // ---------------------------------------------------------------------------

  Widget _buildOrgState(
      BuildContext context, Organization org, Color accentColor) {
    final currentUserId = SupabaseService.userId;
    final isOwner = org.ownerId == currentUserId;
    final membersAsync = ref.watch(orgMembersProvider(org.id));

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              20, 20, 20, AppConstants.scrollBottomPadding),
          sliver: SliverList.list(
            children: [
              // -- Org header card --
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      CupertinoDynamicColor.resolve(AppColors.surface, context),
                  borderRadius: BorderRadius.circular(AppColors.radiusL),
                  border: Border.all(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.border, context),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(AppColors.radiusM),
                      ),
                      child: Icon(
                        CupertinoIcons.person_2_fill,
                        color: CupertinoDynamicColor.resolve(
                            AppColors.chipActiveFg, context),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            org.name,
                            style: AppTypography.titleMedium(context).copyWith(
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isOwner ? 'Owner' : 'Member',
                            style: AppTypography.chip(context),
                          ),
                        ],
                      ),
                    ),
                    if (isOwner)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'OWNER',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: CupertinoDynamicColor.resolve(
                                AppColors.chipActiveFg, context),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // -- Members section --
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'MEMBERS',
                  style: AppTypography.labelSmall(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.textSecondary, context),
                  ),
                ),
              ),
              membersAsync.when(
                data: (members) => _buildMembersList(
                    context, org.id, members, isOwner, org.ownerId, accentColor),
                loading: () => Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.surface, context),
                    borderRadius: BorderRadius.circular(AppColors.radiusL),
                  ),
                  child: const Center(child: CupertinoActivityIndicator()),
                ),
                error: (_, __) => Text(
                  'Failed to load members',
                  style: AppTypography.bodyMedium(context),
                ),
              ),
              const SizedBox(height: 24),

              // -- Invite section (owner/admin only) --
              if (isOwner) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    'INVITE MEMBER',
                    style: AppTypography.labelSmall(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                          AppColors.textSecondary, context),
                    ),
                  ),
                ),
                _buildInviteSection(context, org.id, accentColor),
                const SizedBox(height: 24),
              ],

              // -- Leave organization --
              CupertinoListSection.insetGrouped(
                children: [
                  CupertinoListTile(
                    title: Center(
                      child: Text(
                        'Leave Organization',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: CupertinoDynamicColor.resolve(
                              AppColors.scoreBad, context),
                        ),
                      ),
                    ),
                    onTap: () => _leaveOrganization(org.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersList(
    BuildContext context,
    String orgId,
    List<OrgMember> members,
    bool isOwner,
    String ownerId,
    Color accentColor,
  ) {
    if (members.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(AppColors.surface, context),
          borderRadius: BorderRadius.circular(AppColors.radiusL),
          border: Border.all(
            color: CupertinoDynamicColor.resolve(AppColors.border, context),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            'No members yet',
            style: AppTypography.bodyMedium(context).copyWith(
              color: CupertinoDynamicColor.resolve(
                  AppColors.textSecondary, context),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(AppColors.surface, context),
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        border: Border.all(
          color: CupertinoDynamicColor.resolve(AppColors.border, context),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < members.length; i++) ...[
            _MemberCard(
              member: members[i],
              isOwnerMember: members[i].userId == ownerId,
              canRemove: isOwner && members[i].userId != ownerId,
              accentColor: accentColor,
              onRemove: () => _removeMember(orgId, members[i]),
            ),
            if (i < members.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 0.5,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.divider, context),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInviteSection(
      BuildContext context, String orgId, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(AppColors.surface, context),
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        border: Border.all(
          color: CupertinoDynamicColor.resolve(AppColors.border, context),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CupertinoTextField(
            controller: _inviteUserIdController,
            placeholder: 'User ID',
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                  AppColors.searchField, context),
              borderRadius: BorderRadius.circular(AppColors.radiusM),
            ),
            style: AppTypography.bodyMedium(context),
            autocorrect: false,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 12),

          // Role picker
          CupertinoSlidingSegmentedControl<int>(
            groupValue: _selectedRole,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Member'),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Admin'),
              ),
            },
            onValueChanged: (value) {
              if (value == null) return;
              Haptics.selection();
              setState(() => _selectedRole = value);
            },
          ),
          const SizedBox(height: 12),

          // Send invite button
          CupertinoButton(
            color: accentColor,
            borderRadius: BorderRadius.circular(AppColors.radiusM),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onPressed: _isInviting ? null : () => _inviteMember(orgId),
            child: _isInviting
                ? CupertinoActivityIndicator(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.chipActiveFg, context),
                  )
                : Text(
                    'Send Invite',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CupertinoDynamicColor.resolve(
                          AppColors.chipActiveFg, context),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Member card widget
// ---------------------------------------------------------------------------

class _MemberCard extends StatelessWidget {
  final OrgMember member;
  final bool isOwnerMember;
  final bool canRemove;
  final Color accentColor;
  final VoidCallback onRemove;

  const _MemberCard({
    required this.member,
    required this.isOwnerMember,
    required this.canRemove,
    required this.accentColor,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final name = member.displayName ?? 'Unknown';
    final initials = name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    final roleLabel = isOwnerMember
        ? 'Owner'
        : member.role == 'admin'
            ? 'Admin'
            : 'Member';

    final roleColor = isOwnerMember
        ? accentColor
        : member.role == 'admin'
            ? CupertinoDynamicColor.resolve(AppColors.scoreMid, context)
            : CupertinoDynamicColor.resolve(AppColors.textTertiary, context);

    Widget card = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoDynamicColor.resolve(
                  AppColors.chipInactive, context),
            ),
            alignment: Alignment.center,
            child: Text(
              initials.isNotEmpty ? initials : '?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: CupertinoDynamicColor.resolve(
                    AppColors.textPrimary, context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.titleMedium(context)),
                const SizedBox(height: 2),
                Text(
                  member.email ?? member.userId,
                  style: AppTypography.chip(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              roleLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: roleColor,
              ),
            ),
          ),
          if (canRemove) ...[
            const SizedBox(width: 8),
            CupertinoButton(
              padding: const EdgeInsets.all(4),
              onPressed: onRemove,
              child: Icon(
                CupertinoIcons.minus_circle,
                size: 20,
                color: CupertinoDynamicColor.resolve(
                    AppColors.scoreBad, context),
              ),
            ),
          ],
        ],
      ),
    );

    return card;
  }
}
