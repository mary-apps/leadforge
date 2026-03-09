import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/animated_button.dart';
import '../../utils/haptics.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final isProAsync = ref.watch(subscriptionProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile section
          profileAsync.when(
            data: (profile) {
              if (profile == null) return const SizedBox();
              
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(profile.displayName ?? 'User'),
                subtitle: Text(profile.businessName ?? ''),
              );
            },
            loading: () => const ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Loading...'),
            ),
            error: (_, __) => const SizedBox(),
          ),
          
          const Divider(),
          
          // Subscription section
          ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: const Text('Subscription'),
            subtitle: isProAsync.when(
              data: (isPro) => Text(isPro ? 'Pro' : 'Free'),
              loading: () => const Text('Loading...'),
              error: (_, __) => const Text('Error'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show subscription management
            },
          ),
          
          // Usage section
          profileAsync.when(
            data: (profile) {
              if (profile == null) return const SizedBox();
              
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usage This Month',
                      style: AppTypography.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _UsageMeter(
                      label: 'Searches',
                      used: profile.searchesThisMonth,
                      limit: profile.isPro ? null : 5,
                      icon: Icons.search,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    _UsageMeter(
                      label: 'Audits',
                      used: profile.auditsThisMonth,
                      limit: profile.isPro ? null : 3,
                      icon: Icons.analytics,
                      color: AppColors.info,
                    ),
                    const SizedBox(height: 12),
                    _UsageMeter(
                      label: 'Demos',
                      used: profile.demosThisMonth,
                      limit: profile.isPro ? null : 1,
                      icon: Icons.web,
                      color: AppColors.warning,
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          
          const Divider(),
          
          // Language
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show language picker
            },
          ),
          
          const Divider(),
          
          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'LeadForge',
                applicationVersion: '1.0.0',
              );
            },
          ),
          
          // Sign out
          Padding(
            padding: const EdgeInsets.all(16),
            child: AnimatedButton(
              onPressed: () {
                Haptics.medium();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      AnimatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          Haptics.heavy();
                          await ref.read(authProvider.notifier).signOut();
                        },
                        backgroundColor: AppColors.danger,
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
              },
              backgroundColor: AppColors.danger.withOpacity(0.1),
              foregroundColor: AppColors.danger,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Sign Out'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar uso con barra de progreso
class _UsageMeter extends StatelessWidget {
  final String label;
  final int used;
  final int? limit; // null = unlimited (Pro)
  final IconData icon;
  final Color color;
  
  const _UsageMeter({
    required this.label,
    required this.used,
    required this.limit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlimited = limit == null;
    final progress = isUnlimited ? 1.0 : (used / limit!).clamp(0.0, 1.0);
    final isNearLimit = !isUnlimited && used >= (limit! * 0.8);
    final isAtLimit = !isUnlimited && used >= limit!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAtLimit ? AppColors.danger : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                isUnlimited ? '∞' : '$used/$limit',
                style: AppTypography.bodyLarge.copyWith(
                  color: isAtLimit ? AppColors.danger : color,
                  fontFamily: 'SF Mono',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isAtLimit
                    ? AppColors.danger
                    : isNearLimit
                        ? AppColors.warning
                        : color,
              ),
              minHeight: 6,
            ),
          ),
          if (isAtLimit) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.danger),
                const SizedBox(width: 4),
                Text(
                  'Limit reached. Upgrade to Pro for unlimited.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.danger,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
