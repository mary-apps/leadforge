import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/businesses_provider.dart';
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/business_card.dart';
import '../../widgets/niche_chips.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../widgets/search_suggestions.dart';
import '../../widgets/animated_button.dart';
import '../../utils/haptics.dart';

class ScoutScreen extends ConsumerStatefulWidget {
  const ScoutScreen({super.key});

  @override
  ConsumerState<ScoutScreen> createState() => _ScoutScreenState();
}

class _ScoutScreenState extends ConsumerState<ScoutScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _showSuggestions = false;
  bool _isSearching = false;
  
  final List<String> _recentSearches = []; // TODO: Load from local storage
  final List<String> _trendingSearches = [
    'dentists Los Angeles',
    'restaurants Miami',
    'plumbers Austin',
    'real estate agents NYC',
  ];
  
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus && _searchController.text.isEmpty;
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    // Hide suggestions
    setState(() => _showSuggestions = false);
    _focusNode.unfocus();
    
    // Check limits
    final profileAsync = ref.read(profileNotifierProvider);
    final profile = profileAsync.value;
    
    if (profile != null && !profile.canSearch) {
      Haptics.heavy();
      _showPaywall();
      return;
    }
    
    // Show optimistic loading
    setState(() => _isSearching = true);
    Haptics.medium();
    
    try {
      // Perform search
      await ref.read(businessesProvider.notifier).search(query);
      
      // Add to recent searches
      if (!_recentSearches.contains(query)) {
        setState(() {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 5) _recentSearches.removeLast();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }
  
  void _showPaywall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(Icons.lock, color: AppColors.warning),
            const SizedBox(width: 8),
            const Text('Search Limit Reached'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You\'ve used all 5 free searches this month.'),
            const SizedBox(height: 16),
            Text(
              'Upgrade to Pro for:',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildBenefit('Unlimited searches'),
            _buildBenefit('Unlimited audits'),
            _buildBenefit('Unlimited demos'),
            _buildBenefit('AI outreach messages'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          AnimatedButton.primary(
            onPressed: () {
              Navigator.pop(context);
              context.push('/settings');
            },
            child: const Text('Upgrade to Pro'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Text(text, style: AppTypography.bodyMedium),
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
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search businesses (e.g., "dentists Austin")',
                    prefixIcon: Icon(
                      Icons.search,
                      color: _focusNode.hasFocus ? AppColors.primary : null,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () => _handleSearch(_searchController.text),
                          ),
                  ),
                  onSubmitted: _handleSearch,
                  onChanged: (value) {
                    setState(() {
                      _showSuggestions = _focusNode.hasFocus && value.isEmpty;
                    });
                  },
                ),
                
                // Search suggestions
                if (_showSuggestions) ...[
                  const SizedBox(height: 12),
                  SearchSuggestions(
                    recentSearches: _recentSearches,
                    trendingSearches: _trendingSearches,
                    onSelected: (query) {
                      _searchController.text = query;
                      _handleSearch(query);
                    },
                  ),
                ],
              ],
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
                  return EmptyState.noResults(
                    onRetry: () => _handleSearch(_searchController.text),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    Haptics.light();
                    await ref.read(businessesProvider.notifier).load();
                  },
                  color: AppColors.primary,
                  child: ListView.builder(
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
                  ),
                );
              },
              loading: () => const SearchSkeleton(),
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
                    AnimatedButton.primary(
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
