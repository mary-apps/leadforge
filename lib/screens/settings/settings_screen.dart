import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/brutal_button.dart';
import '../../utils/haptics.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final isProAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Settings',
          style: AppTypography.titleMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // Profile section
          profileAsync.when(
            data: (profile) {
              if (profile == null) return const SizedBox();

              final initials = (profile.displayName ?? 'U')
                  .split(' ')
                  .take(2)
                  .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                  .join();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppColors.radiusXL + 2),
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                      ),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppColors.radiusXL),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
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
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (profile.businessName != null &&
                              profile.businessName!.isNotEmpty)
                            Text(
                              profile.businessName!,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 8),

          // Subscription card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppColors.radiusXL),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PLAN',
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      isProAsync.when(
                        data: (isPro) => Text(
                          isPro ? 'Pro' : 'Free',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        loading: () => Text(
                          'Loading...',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        error: (_, __) => Text(
                          'Error',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                isProAsync.when(
                  data: (isPro) {
                    if (isPro) return const SizedBox();
                    return BrutalButton(
                      label: 'Upgrade',
                      compact: true,
                      onPressed: () {
                        // TODO: Show subscription management
                      },
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Usage section
          profileAsync.when(
            data: (profile) {
              if (profile == null) return const SizedBox();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppColors.radiusXL),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'USAGE',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _UsageMeter(
                      label: 'Searches',
                      used: profile.searchesThisMonth,
                      limit: profile.isPro ? null : 5,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 14),
                    _UsageMeter(
                      label: 'Audits',
                      used: profile.auditsThisMonth,
                      limit: profile.isPro ? null : 3,
                      color: AppColors.info,
                    ),
                    const SizedBox(height: 14),
                    _UsageMeter(
                      label: 'Demos',
                      used: profile.demosThisMonth,
                      limit: profile.isPro ? null : 1,
                      color: AppColors.warning,
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 16),

          // Settings items
          _SettingsItem(
            label: 'Language',
            value: 'English',
            icon: Icons.language_rounded,
            onTap: () {
              // TODO: Show language picker
            },
          ),
          _SettingsItem(
            label: 'About',
            icon: Icons.info_outline_rounded,
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'LeadForge',
                applicationVersion: '1.0.0',
              );
            },
          ),
          const SizedBox(height: 24),

          // Sign out
          GestureDetector(
            onTap: () {
              Haptics.medium();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppColors.radiusXL),
                  ),
                  title: const Text('Sign Out'),
                  content:
                      const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        Haptics.heavy();
                        await ref
                            .read(authProvider.notifier)
                            .signOut();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppColors.radiusL),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.logout_rounded,
                        size: 18, color: AppColors.danger),
                    const SizedBox(width: 8),
                    Text(
                      'Sign Out',
                      style: AppTypography.button.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.label,
    this.value,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppColors.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (value != null)
                  Text(
                    value!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar uso con barra de progreso
class _UsageMeter extends StatelessWidget {
  final String label;
  final int used;
  final int? limit; // null = unlimited (Pro)
  final Color color;

  const _UsageMeter({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              isUnlimited ? '\u221e' : '$used/$limit',
              style: AppTypography.mono.copyWith(
                color: isAtLimit ? AppColors.danger : color,
                fontSize: 13,
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
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: animatedValue,
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isAtLimit ? AppColors.danger : color,
                ),
                minHeight: 4,
              ),
            );
          },
        ),
        if (isAtLimit) ...[
          const SizedBox(height: 6),
          Text(
            'Limit reached. Upgrade to Pro for unlimited.',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.danger,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}
