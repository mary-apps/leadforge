import 'package:flutter/cupertino.dart';

import '../config/theme.dart';
import '../utils/haptics.dart';

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

    if (!hasRecent && !hasTrending) return const SizedBox.shrink();

    final resolvedDivider =
        CupertinoDynamicColor.resolve(AppColors.divider, context);
    final resolvedAccent =
        CupertinoDynamicColor.resolve(AppColors.accent, context);
    final resolvedSecondary =
        CupertinoDynamicColor.resolve(AppColors.textSecondary, context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasRecent) ...[
            Row(
              children: [
                Icon(CupertinoIcons.clock, size: 14, color: resolvedSecondary),
                const SizedBox(width: 8),
                Text(
                  'Recent',
                  style: AppTypography.labelLarge(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...recentSearches.map((search) => _SuggestionTile(
                  text: search,
                  onTap: () => onSelected(search),
                )),
            if (hasTrending) ...[
              const SizedBox(height: 8),
              Container(height: 0.5, color: resolvedDivider),
              const SizedBox(height: 8),
            ],
          ],
          if (hasTrending) ...[
            Row(
              children: [
                Icon(CupertinoIcons.flame, size: 14, color: resolvedAccent),
                const SizedBox(width: 8),
                Text(
                  'Trending',
                  style: AppTypography.labelLarge(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...trendingSearches.map((search) => _SuggestionTile(
                  text: search,
                  accentColor: resolvedAccent,
                  onTap: () => onSelected(search),
                )),
          ],
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color? accentColor;

  const _SuggestionTile({
    required this.text,
    required this.onTap,
    this.accentColor,
  });

  @override
  State<_SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<_SuggestionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Haptics.light();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: _pressed
              ? CupertinoDynamicColor.resolve(AppColors.divider, context)
              : const Color(0x00000000),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.text,
                style: AppTypography.bodyLarge(context),
              ),
            ),
            Icon(
              CupertinoIcons.arrow_up_left,
              size: 12,
              color: CupertinoDynamicColor.resolve(
                  AppColors.textTertiary, context),
            ),
          ],
        ),
      ),
    );
  }
}
