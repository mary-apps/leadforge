import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/businesses_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/business_card.dart';
import '../../widgets/niche_chips.dart';
import '../../widgets/loading_shimmer.dart';

class ScoutScreen extends ConsumerStatefulWidget {
  const ScoutScreen({super.key});

  @override
  ConsumerState<ScoutScreen> createState() => _ScoutScreenState();
}

class _ScoutScreenState extends ConsumerState<ScoutScreen> {
  final _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    // Check limits
    final profileAsync = ref.read(profileNotifierProvider);
    final profile = profileAsync.value;
    
    if (profile != null && !profile.canSearch) {
      _showPaywall();
      return;
    }
    
    // Perform search
    await ref.read(businessesProvider.notifier).search(query);
  }
  
  void _showPaywall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Limit Reached'),
        content: const Text('Upgrade to Pro for unlimited searches'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/settings'); // Navigate to subscription
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(businessesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(businessesProvider.notifier).load(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search businesses (e.g., "dentists Austin")',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _handleSearch(_searchController.text),
                ),
              ),
              onSubmitted: _handleSearch,
            ),
          ),
          
          // Niche chips
          NicheChips(
            onSelected: (niche) {
              _searchController.text = niche;
              _handleSearch(niche);
            },
          ),
          
          const SizedBox(height: 8),
          
          // Results
          Expanded(
            child: businessesAsync.when(
              data: (businesses) {
                if (businesses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No businesses found',
                          style: AppTypography.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching for a different niche or location',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: businesses.length,
                  itemBuilder: (context, index) {
                    final business = businesses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BusinessCard(
                        business: business,
                        onTap: () => context.push('/business/${business.id}'),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingShimmer(),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: AppColors.danger,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading businesses',
                      style: AppTypography.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => ref.read(businessesProvider.notifier).load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
