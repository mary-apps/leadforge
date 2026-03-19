import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/theme.dart';
import '../../models/profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../utils/haptics.dart';
import '../../providers/auto_audit_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final isProAsync = ref.watch(subscriptionProvider);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Settings'),
            border: null,
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, AppConstants.scrollBottomPadding),
            sliver: SliverList.list(
              children: [
                // -- Profile card --
                profileAsync.when(
                  data: (profile) {
                    if (profile == null) return const SizedBox();

                    final initials = (profile.displayName ?? 'U')
                        .split(' ')
                        .take(2)
                        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                        .join();

                    return Container(
                      decoration: BoxDecoration(
                        color: CupertinoDynamicColor.resolve(
                            AppColors.surface, context),
                        borderRadius:
                            BorderRadius.circular(AppColors.radiusL),
                        border: Border.all(
                          color: CupertinoDynamicColor.resolve(
                              AppColors.border, context),
                          width: 0.5,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppColors.radiusL),
                          border: Border(
                            left: BorderSide(
                              color: CupertinoDynamicColor.resolve(
                                  AppColors.accent, context),
                              width: 3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CupertinoDynamicColor.resolve(
                                    AppColors.accent, context),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.displayName ?? 'User',
                                    style: AppTypography.titleMedium(context).copyWith(
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  if (profile.businessName != null &&
                                      profile.businessName!.isNotEmpty)
                                    Text(
                                      profile.businessName!,
                                      style: AppTypography.bodyMedium(context).copyWith(
                                        color: CupertinoDynamicColor.resolve(
                                            AppColors.textSecondary, context),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            isProAsync.when(
                              data: (isPro) => isPro
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: CupertinoDynamicColor.resolve(
                                            AppColors.accent, context),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'PRO',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                          color: CupertinoColors.white,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'FREE',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1,
                                          color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                                        ),
                                      ),
                                    ),
                              loading: () => const SizedBox(width: 40),
                              error: (_, __) => const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: AppConstants.standardAnimation)
                        .slideY(
                            begin: 0.03,
                            duration: AppConstants.standardAnimation + const Duration(milliseconds: 100),
                            curve: Curves.easeOutCubic);
                  },
                  loading: () => Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: CupertinoDynamicColor.resolve(
                          AppColors.surface, context),
                      borderRadius:
                          BorderRadius.circular(AppColors.radiusL),
                      border: Border.all(
                        color: CupertinoDynamicColor.resolve(
                            AppColors.border, context),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 120,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 80,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 20),

                // -- Usage section --
                profileAsync.when(
                  data: (profile) {
                    if (profile == null) return const SizedBox();
                    final isPro = profile.isPro;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 10),
                          child: Text(
                            'USAGE',
                            style: AppTypography.labelSmall(context).copyWith(
                              color: CupertinoDynamicColor.resolve(
                                  AppColors.textSecondary, context),
                            ),
                          ),
                        ),
                        _UsagePill(
                          label: 'Searches',
                          used: profile.searchesThisMonth,
                          limit: isPro ? null : 5,
                          color: CupertinoDynamicColor.resolve(
                              AppColors.accent, context),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _UsagePill(
                                label: 'Audits',
                                used: profile.auditsThisMonth,
                                limit: isPro ? null : 3,
                                color: CupertinoDynamicColor.resolve(
                                    AppColors.accent, context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _UsagePill(
                                label: 'Demos',
                                used: profile.demosThisMonth,
                                limit: isPro ? null : 1,
                                color: CupertinoDynamicColor.resolve(
                                    AppColors.scoreMid, context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                        .animate(delay: 80.ms)
                        .fadeIn(duration: AppConstants.standardAnimation)
                        .slideY(
                            begin: 0.03,
                            duration: AppConstants.standardAnimation + const Duration(milliseconds: 100),
                            curve: Curves.easeOutCubic);
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 24),

                // -- Upgrade CTA (free users only) --
                isProAsync.when(
                  data: (isPro) {
                    if (isPro) return const SizedBox();
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoDynamicColor.resolve(
                            AppColors.surface, context),
                        borderRadius:
                            BorderRadius.circular(AppColors.radiusL),
                        border: Border.all(
                          color: CupertinoDynamicColor.resolve(
                              AppColors.border, context),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: CupertinoDynamicColor.resolve(
                                  AppColors.accent, context),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              CupertinoIcons.bolt_fill,
                              color: CupertinoColors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upgrade to Pro',
                                  style: AppTypography.titleMedium(context),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Unlimited searches, audits & outreach',
                                  style: AppTypography.chip(context).copyWith(
                                    color: CupertinoDynamicColor.resolve(
                                        AppColors.textSecondary, context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_forward,
                            size: 14,
                            color: CupertinoDynamicColor.resolve(
                                AppColors.accent, context),
                          ),
                        ],
                      ),
                    )
                        .animate(delay: 140.ms)
                        .fadeIn(duration: AppConstants.standardAnimation)
                        .slideY(
                            begin: 0.03,
                            duration: AppConstants.standardAnimation + const Duration(milliseconds: 100),
                            curve: Curves.easeOutCubic);
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                isProAsync.when(
                  data: (isPro) =>
                      SizedBox(height: isPro ? 0 : 24),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),

                // -- Preferences --
                CupertinoListSection.insetGrouped(
                  header: Text(
                    'PREFERENCES',
                    style: AppTypography.labelSmall(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                          AppColors.textSecondary, context),
                    ),
                  ),
                  children: [
                    CupertinoListTile(
                      leading: const Icon(CupertinoIcons.bolt),
                      title: const Text('Auto-analyze'),
                      subtitle: const Text('Audit businesses when selected'),
                      trailing: CupertinoSwitch(
                        value: ref.watch(autoAuditProvider),
                        onChanged: (_) {
                          Haptics.light();
                          ref.read(autoAuditProvider.notifier).toggle();
                        },
                      ),
                    ),
                    CupertinoListTile(
                      leading: const Icon(CupertinoIcons.globe),
                      title: const Text('Language'),
                      additionalInfo: const Text('English'),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {},
                    ),
                    CupertinoListTile(
                      leading: const Icon(CupertinoIcons.info),
                      title: const Text('About'),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text('LeadForge'),
                            content: Text('Version ${AppConstants.appVersion}'),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(
                        begin: 0.03,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic),
                const SizedBox(height: 24),

                // -- Sign Out --
                CupertinoListSection.insetGrouped(
                  children: [
                    CupertinoListTile(
                      title: const Center(
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: CupertinoColors.destructiveRed,
                          ),
                        ),
                      ),
                      onTap: () {
                        Haptics.medium();
                        showCupertinoDialog(
                          context: context,
                          builder: (ctx) => CupertinoAlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text('Are you sure you want to sign out?'),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              CupertinoDialogAction(
                                isDestructiveAction: true,
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  Haptics.heavy();
                                  ref.read(authProvider.notifier).signOut();
                                },
                                child: const Text('Sign Out'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                )
                    .animate(delay: 260.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(
                        begin: 0.03,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Usage pill — compact stat with progress bar
// ---------------------------------------------------------------------------

class _UsagePill extends StatelessWidget {
  final String label;
  final int used;
  final int? limit;
  final Color color;

  const _UsagePill({
    required this.label,
    required this.used,
    required this.limit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlimited = limit == null;
    final progress = isUnlimited ? 1.0 : (used / limit!).clamp(0.0, 1.0);
    final isAtLimit = !isUnlimited && used >= limit!;

    final dangerColor =
        CupertinoDynamicColor.resolve(AppColors.scoreBad, context);
    final warningColor =
        CupertinoDynamicColor.resolve(AppColors.scoreMid, context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        border: Border.all(
          color: isAtLimit
              ? dangerColor.withValues(alpha: 0.3)
              : CupertinoColors.separator.resolveFrom(context),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
              Text(
                isUnlimited ? '\u221e' : '$used/$limit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isAtLimit ? dangerColor : color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 4,
                  child: Stack(
                    children: [
                      Container(
                        color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
                      ),
                      FractionallySizedBox(
                        widthFactor: animatedValue,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isAtLimit
                                  ? [dangerColor, warningColor]
                                  : [color, color.withValues(alpha: 0.5)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
