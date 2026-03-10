import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Search suggestions with recent + trending
class SearchSuggestions extends StatelessWidget {
  final List<String> recentSearches;
  final List<String> trendingSearches;
  final Function(String) onSelected;
  
  const SearchSuggestions({
    super.key,
    required this.recentSearches,
    required this.trendingSearches,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasRecent = recentSearches.isNotEmpty;
    final hasTrending = trendingSearches.isNotEmpty;
    
    if (!hasRecent && !hasTrending) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasRecent) ...[
            Row(
              children: [
                const Icon(
                  Icons.history,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recentSearches.map((search) => _SuggestionTile(
                  icon: Icons.history,
                  text: search,
                  onTap: () => onSelected(search),
                )),
            if (hasTrending) const SizedBox(height: 16),
          ],
          if (hasTrending) ...[
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trending',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...trendingSearches.map((search) => _SuggestionTile(
                  icon: Icons.trending_up,
                  text: search,
                  onTap: () => onSelected(search),
                )),
          ],
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  
  const _SuggestionTile({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodyMedium,
              ),
            ),
            const Icon(
              Icons.north_west,
              size: 14,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
