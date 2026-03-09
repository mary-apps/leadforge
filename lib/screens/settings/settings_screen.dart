import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/subscription_provider.dart';

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
              
              return Column(
                children: [
                  ListTile(
                    title: const Text('Usage This Month'),
                    subtitle: Text(
                      'Searches: ${profile.searchesThisMonth}/${profile.isPro ? '∞' : '5'}\n'
                      'Audits: ${profile.auditsThisMonth}/${profile.isPro ? '∞' : '3'}\n'
                      'Demos: ${profile.demosThisMonth}/${profile.isPro ? '∞' : '1'}',
                    ),
                  ),
                ];
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
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.danger),
            title: Text('Sign Out', style: TextStyle(color: AppColors.danger)),
            onTap: () async {
              await ref.read(authProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }
}
