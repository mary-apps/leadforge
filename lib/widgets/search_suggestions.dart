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

    final resolvedSurface = CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final resolvedBorder = CupertinoColors.separator.resolveFrom(context);
    final resolvedSecondaryLabel = CupertinoColors.secondaryLabel.resolveFrom(context);
    final resolvedPrimary = CupertinoColors.systemBlue.resolveFrom(context);
    final resolvedSuccess = CupertinoColors.systemGreen.resolveFrom(context);
    final resolvedDivider = CupertinoColors.opaqueSeparator.resolveFrom(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: resolvedSurface,
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        border: Border.all(color: resolvedBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0x00000000).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasRecent) ...[
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: resolvedPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(CupertinoIcons.clock, size: 14, color: resolvedPrimary),
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent',
                  style: AppTypography.labelLarge.copyWith(
                    color: resolvedSecondaryLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...recentSearches.map((search) => _SuggestionTile(
                  icon: CupertinoIcons.clock,
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
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: resolvedSuccess.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(CupertinoIcons.flame, size: 14, color: resolvedSuccess),
                ),
                const SizedBox(width: 8),
                Text(
                  'Trending',
                  style: AppTypography.labelLarge.copyWith(
                    color: resolvedSecondaryLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...trendingSearches.map((search) => _SuggestionTile(
                  icon: CupertinoIcons.flame,
                  text: search,
                  color: resolvedSuccess,
                  onTap: () => onSelected(search),
                )),
          ],
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color? color;

  const _SuggestionTile({
    required this.icon,
    required this.text,
    required this.onTap,
    this.color,
  });

  @override
  State<_SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<_SuggestionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final resolvedTertiary = CupertinoColors.tertiaryLabel.resolveFrom(context);

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
              ? CupertinoColors.label.resolveFrom(context).withValues(alpha: 0.04)
              : const Color(0x00000000),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              size: 16,
              color: widget.color ?? resolvedTertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.text,
                style: AppTypography.bodyMedium,
              ),
            ),
            Icon(
              CupertinoIcons.arrow_up_left,
              size: 12,
              color: resolvedTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
