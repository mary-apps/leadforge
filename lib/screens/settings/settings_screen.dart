import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/theme.dart';
import '../../models/profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/app_button.dart';
import '../../utils/haptics.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final isProAsync = ref.watch(subscriptionProvider);
    final bg = CupertinoDynamicColor.resolve(AppColors.background, context);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // -- Title --
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppConstants.pageHorizontal,
                MediaQuery.of(context).padding.top + 20,
                AppConstants.pageHorizontal,
                0,
              ),
              child: Text(
                'Settings',
                style: AppTypography.displayLarge(context),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.pageHorizontal,
              AppConstants.sectionGap,
              AppConstants.pageHorizontal,
              100,
            ),
            sliver: SliverList.list(
              children: [
                // -- Profile --
                profileAsync.when(
                  data: (profile) {
                    if (profile == null) return const SizedBox();

                    final initials = (profile.displayName ?? 'U')
                        .split(' ')
                        .take(2)
                        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                        .join();

                    return Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoDynamicColor.resolve(
                              AppColors.accent,
                              context,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: CupertinoDynamicColor.resolve(
                                AppColors.chipActiveFg,
                                context,
                              ),
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
                                style: AppTypography.headlineLarge(context),
                              ),
                              if (profile.businessName != null &&
                                  profile.businessName!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  profile.businessName!,
                                  style: AppTypography.labelLarge(context),
                                ),
                              ],
                            ],
                          ),
                        ),
                        isProAsync.when(
                          data: (isPro) => Text(
                            isPro ? 'Pro' : 'Free',
                            style: AppTypography.labelLarge(context).copyWith(
                              color: CupertinoDynamicColor.resolve(
                                AppColors.textSecondary,
                                context,
                              ),
                            ),
                          ),
                          loading: () => const SizedBox(width: 40),
                          error: (_, __) => const SizedBox(),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(
                          begin: AppConstants.entranceSlideDistance / 100,
                          duration: 350.ms,
                          curve: Curves.easeOutCubic,
                        );
                  },
                  loading: () => _ProfileSkeleton(context: context),
                  error: (_, __) => const SizedBox(),
                ),

                const SizedBox(height: AppConstants.sectionGap),

                // -- Usage section --
                profileAsync.when(
                  data: (profile) {
                    if (profile == null) return const SizedBox();
                    final isPro = profile.isPro;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'USAGE',
                          style: AppTypography.labelSmall(context),
                        ),
                        const SizedBox(height: AppConstants.itemGap),
                        _UsageRow(
                          label: 'Searches',
                          used: profile.searchesThisMonth,
                          limit: isPro ? null : 5,
                        ),
                        _divider(context),
                        _UsageRow(
                          label: 'Audits',
                          used: profile.auditsThisMonth,
                          limit: isPro ? null : 3,
                        ),
                        _divider(context),
                        _UsageRow(
                          label: 'Demos',
                          used: profile.demosThisMonth,
                          limit: isPro ? null : 1,
                        ),
                      ],
                    )
                        .animate(
                          delay: Duration(
                            milliseconds:
                                AppConstants.staggerDelay.inMilliseconds,
                          ),
                        )
                        .fadeIn(duration: 300.ms)
                        .slideY(
                          begin: AppConstants.entranceSlideDistance / 100,
                          duration: 350.ms,
                          curve: Curves.easeOutCubic,
                        );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),

                const SizedBox(height: AppConstants.sectionGap),

                // -- Upgrade CTA (free users only) --
                isProAsync.when(
                  data: (isPro) {
                    if (isPro) return const SizedBox();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SettingsRow(
                          label: 'Upgrade to Pro',
                          value: 'Unlimited searches, audits & outreach',
                          showChevron: true,
                          onTap: () {},
                        ),
                        const SizedBox(height: AppConstants.sectionGap),
                      ],
                    )
                        .animate(
                          delay: Duration(
                            milliseconds:
                                AppConstants.staggerDelay.inMilliseconds * 2,
                          ),
                        )
                        .fadeIn(duration: 300.ms)
                        .slideY(
                          begin: AppConstants.entranceSlideDistance / 100,
                          duration: 350.ms,
                          curve: Curves.easeOutCubic,
                        );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),

                // -- Preferences --
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREFERENCES',
                      style: AppTypography.labelSmall(context),
                    ),
                    const SizedBox(height: AppConstants.itemGap),
                    _SettingsRow(
                      label: 'Language',
                      value: 'English',
                      showChevron: true,
                      onTap: () {},
                    ),
                    _divider(context),
                    _SettingsRow(
                      label: 'About',
                      value: 'v1.0.0',
                      showChevron: true,
                      onTap: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text('LeadForge'),
                            content: const Text('Version 1.0.0'),
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
                    .animate(
                      delay: Duration(
                        milliseconds:
                            AppConstants.staggerDelay.inMilliseconds * 3,
                      ),
                    )
                    .fadeIn(duration: 300.ms)
                    .slideY(
                      begin: AppConstants.entranceSlideDistance / 100,
                      duration: 350.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: AppConstants.sectionGap),

                // -- Sign Out --
                AppButton(
                  variant: AppButtonVariant.ghost,
                  label: 'Sign Out',
                  onPressed: () {
                    Haptics.medium();
                    showCupertinoDialog(
                      context: context,
                      builder: (ctx) => CupertinoAlertDialog(
                        title: const Text('Sign Out'),
                        content:
                            const Text('Are you sure you want to sign out?'),
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
                )
                    .animate(
                      delay: Duration(
                        milliseconds:
                            AppConstants.staggerDelay.inMilliseconds * 4,
                      ),
                    )
                    .fadeIn(duration: 300.ms)
                    .slideY(
                      begin: AppConstants.entranceSlideDistance / 100,
                      duration: 350.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _divider(BuildContext context) {
    return Container(
      height: 0.5,
      color: CupertinoDynamicColor.resolve(AppColors.divider, context),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile skeleton loader
// ---------------------------------------------------------------------------

class _ProfileSkeleton extends StatelessWidget {
  final BuildContext context;
  const _ProfileSkeleton({required this.context});

  @override
  Widget build(BuildContext _) {
    final fill = CupertinoDynamicColor.resolve(AppColors.divider, context);
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
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
                  color: fill,
                  borderRadius: BorderRadius.circular(AppColors.radiusS),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(AppColors.radiusS),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Settings row — label + value / chevron
// ---------------------------------------------------------------------------

class _SettingsRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool showChevron;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.label,
    this.value,
    this.showChevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge(context),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: AppTypography.labelLarge(context),
              ),
            if (showChevron) ...[
              const SizedBox(width: 6),
              Icon(
                CupertinoIcons.chevron_forward,
                size: 14,
                color: CupertinoDynamicColor.resolve(
                  AppColors.textTertiary,
                  context,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Usage row — label + value inline
// ---------------------------------------------------------------------------

class _UsageRow extends StatelessWidget {
  final String label;
  final int used;
  final int? limit;

  const _UsageRow({
    required this.label,
    required this.used,
    this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlimited = limit == null;
    final isAtLimit = !isUnlimited && used >= limit!;
    final valueText = isUnlimited ? '$used / \u221e' : '$used / $limit';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyLarge(context),
          ),
          Text(
            valueText,
            style: AppTypography.titleMedium(context).copyWith(
              color: CupertinoDynamicColor.resolve(
                isAtLimit ? AppColors.scoreBad : AppColors.textSecondary,
                context,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
