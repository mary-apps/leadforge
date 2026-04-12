import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../providers/businesses_provider.dart';
import '../../widgets/error_state.dart';
import '../../widgets/skeleton_loaders.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  // Memoization cache — recalculated only when the businesses list identity changes.
  List<Business>? _cachedBusinesses;
  List<Business>? _cachedSorted;
  List<Business>? _cachedToday;
  List<Business>? _cachedThisWeek;
  List<Business>? _cachedEarlier;

  void _refreshCache(List<Business> businesses) {
    _cachedBusinesses = businesses;

    final sorted = List<Business>.from(businesses)
      ..sort((a, b) {
        final aDate = a.updatedAt ?? a.createdAt ?? DateTime.now();
        final bDate = b.updatedAt ?? b.createdAt ?? DateTime.now();
        return bDate.compareTo(aDate);
      });
    _cachedSorted = sorted;

    final now = DateTime.now();
    DateTime eventDate(Business b) => b.updatedAt ?? b.createdAt ?? DateTime.now();

    _cachedToday = sorted
        .where((b) => now.difference(eventDate(b)).inHours < 24)
        .toList();
    _cachedThisWeek = sorted.where((b) {
      final d = now.difference(eventDate(b));
      return d.inHours >= 24 && d.inDays < 7;
    }).toList();
    _cachedEarlier = sorted
        .where((b) => now.difference(eventDate(b)).inDays >= 7)
        .toList();
  }

  void _ensureCache(List<Business> businesses) {
    if (!identical(businesses, _cachedBusinesses) ||
        _cachedSorted == null) {
      _refreshCache(businesses);
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(businessesProvider);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.resolve(AppColors.background, context),
      child: businessesAsync.when(
        data: (businesses) {
          if (businesses.isEmpty) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      size: 32,
                      color: CupertinoDynamicColor.resolve(
                          AppColors.textTertiary, context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No activity yet',
                      style: AppTypography.titleMedium(context),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your recent actions will appear here',
                      style: AppTypography.bodyMedium(context).copyWith(
                        color: CupertinoDynamicColor.resolve(
                            AppColors.textSecondary, context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => context.go('/scout'),
                      child: Text(
                        'Start Scouting',
                        style: AppTypography.labelLarge(context).copyWith(
                          color: CupertinoDynamicColor.resolve(
                              AppColors.accent, context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          _ensureCache(businesses);
          final today = _cachedToday!;
          final thisWeek = _cachedThisWeek!;
          final earlier = _cachedEarlier!;

          return SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    await ref.read(businessesProvider.notifier).load();
                  },
                ),
                const CupertinoSliverNavigationBar(
                  largeTitle: Text('Activity'),
                  border: null,
                ),

                // Summary text
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Text(
                      _summaryText(today.length, thisWeek.length),
                      style: AppTypography.bodyMedium(context).copyWith(
                        color: CupertinoDynamicColor.resolve(
                            AppColors.textSecondary, context),
                      ),
                    ),
                  ),
                ),

                // Today group
                if (today.isNotEmpty)
                  ..._buildGroup(
                    context,
                    label: 'TODAY',
                    items: today,
                    density: _Density.full,
                    animationOffset: 0,
                  ),

                // This week group
                if (thisWeek.isNotEmpty)
                  ..._buildGroup(
                    context,
                    label: 'THIS WEEK',
                    items: thisWeek,
                    density: _Density.medium,
                    animationOffset: today.length,
                  ),

                // Earlier group
                if (earlier.isNotEmpty)
                  ..._buildGroup(
                    context,
                    label: 'EARLIER',
                    items: earlier,
                    density: _Density.compact,
                    animationOffset: today.length + thisWeek.length,
                  ),

                // Bottom spacing
                const SliverToBoxAdapter(child: SizedBox(height: AppConstants.scrollBottomPadding)),
              ],
            ),
          );
        },
        loading: () => const ActivitySkeleton(),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.read(businessesProvider.notifier).load(),
        ),
      ),
    );
  }

  String _summaryText(int todayCount, int weekCount) {
    final parts = <String>[];
    if (todayCount > 0) parts.add('$todayCount today');
    if (weekCount > 0) parts.add('$weekCount this week');
    if (parts.isEmpty) return 'No recent activity';
    return parts.join(', ');
  }

  List<Widget> _buildGroup(
    BuildContext context, {
    required String label,
    required List<Business> items,
    required _Density density,
    required int animationOffset,
  }) {
    final featured = density == _Density.full && items.isNotEmpty;
    final featuredBusiness = featured ? items.first : null;
    final remainingItems = featured ? items.sublist(1) : items;

    return [
      // Section header
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            children: [
              Text(
                label,
                style: AppTypography.labelSmall(context).copyWith(
                  color: CupertinoDynamicColor.resolve(
                      AppColors.textSecondary, context),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: CupertinoDynamicColor.resolve(AppColors.accent, context).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  items.length.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: CupertinoDynamicColor.resolve(AppColors.accent, context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Featured first item (only for Today)
      if (featured && featuredBusiness != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: _FeaturedActivityCard(
              business: featuredBusiness,
              onTap: () => context.push('/business/${featuredBusiness.id}'),
            ),
          )
              .animate(delay: Duration(milliseconds: 50 * animationOffset))
              .fadeIn(duration: AppConstants.standardAnimation)
              .slideX(
                begin: -0.03,
                duration: AppConstants.standardAnimation + const Duration(milliseconds: 100),
                curve: Curves.easeOutCubic,
              ),
        ),

      // Remaining items in grouped card
      if (remainingItems.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(AppColors.surface, context),
                borderRadius: BorderRadius.circular(AppColors.radiusM),
                border: Border.all(
                  color: CupertinoDynamicColor.resolve(AppColors.border, context),
                  width: 0.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(remainingItems.length, (index) {
                  final business = remainingItems[index];
                  final isLast = index == remainingItems.length - 1;
                  final globalIndex =
                      animationOffset + (featured ? index + 1 : index);

                  return _ActivityTile(
                    business: business,
                    index: globalIndex,
                    showDivider: !isLast,
                    density: density,
                    onTap: () =>
                        context.push('/business/${business.id}'),
                  );
                }),
              ),
            ),
          ),
        ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Density levels for progressive information density
// ---------------------------------------------------------------------------

enum _Density { full, medium, compact }

// ---------------------------------------------------------------------------
// Featured activity card — promoted first item of "Today"
// ---------------------------------------------------------------------------

class _FeaturedActivityCard extends StatefulWidget {
  final Business business;
  final VoidCallback onTap;

  const _FeaturedActivityCard({
    required this.business,
    required this.onTap,
  });

  @override
  State<_FeaturedActivityCard> createState() => _FeaturedActivityCardState();
}

class _FeaturedActivityCardState extends State<_FeaturedActivityCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final business = widget.business;
    final timeAgo = _timeAgo(business.updatedAt ?? business.createdAt ?? DateTime.now());

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(AppColors.surface, context),
            borderRadius: BorderRadius.circular(AppColors.radiusM),
            border: Border.all(
              color: CupertinoDynamicColor.resolve(AppColors.border, context),
              width: 0.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: business.statusColor,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: business.statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(business.statusIcon,
                      color: business.statusColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.name,
                        style: AppTypography.titleMedium(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_statusDescription(business.status)} · $timeAgo',
                        style: AppTypography.labelLarge(context).copyWith(
                          color: business.statusColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: CupertinoDynamicColor.resolve(AppColors.textTertiary, context),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Activity tile — density-aware rendering
// ---------------------------------------------------------------------------

class _ActivityTile extends StatefulWidget {
  final Business business;
  final int index;
  final bool showDivider;
  final _Density density;
  final VoidCallback onTap;

  const _ActivityTile({
    required this.business,
    required this.index,
    required this.onTap,
    required this.density,
    this.showDivider = true,
  });

  @override
  State<_ActivityTile> createState() => _ActivityTileState();
}

class _ActivityTileState extends State<_ActivityTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final business = widget.business;
    final timeAgo = _timeAgo(business.updatedAt ?? business.createdAt ?? DateTime.now());
    final density = widget.density;

    // Progressive density: padding, icon size, content
    final hPad = switch (density) {
      _Density.full => 14.0,
      _Density.medium => 12.0,
      _Density.compact => 10.0,
    };
    final vPad = switch (density) {
      _Density.full => 12.0,
      _Density.medium => 10.0,
      _Density.compact => 8.0,
    };
    final iconSize = switch (density) {
      _Density.full => 36.0,
      _Density.medium => 36.0,
      _Density.compact => 28.0,
    };
    final iconInnerSize = switch (density) {
      _Density.full => 18.0,
      _Density.medium => 18.0,
      _Density.compact => 14.0,
    };

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        color: _pressed
            ? CupertinoDynamicColor.resolve(AppColors.divider, context)
            : const Color(0x00000000),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              child: Row(
                children: [
                  // Icon — smaller for compact
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: business.statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                          density == _Density.compact ? 6 : 8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(business.statusIcon,
                        color: business.statusColor, size: iconInnerSize),
                  ),
                  SizedBox(width: density == _Density.compact ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          business.name,
                          style: density == _Density.compact
                              ? AppTypography.bodyMedium(context).copyWith(
                                  fontWeight: FontWeight.w600,
                                )
                              : AppTypography.titleMedium(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (density != _Density.compact) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${_statusLabel(business.status)} · $timeAgo',
                            style: AppTypography.labelLarge(context).copyWith(
                              color: CupertinoDynamicColor.resolve(
                                  AppColors.textTertiary, context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Compact: just a colored dot instead of chevron
                  if (density == _Density.compact)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: business.statusColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: CupertinoDynamicColor.resolve(AppColors.textTertiary, context),
                      size: 18,
                    ),
                ],
              ),
            ),
            if (widget.showDivider)
              Container(
                margin: const EdgeInsets.only(left: 16),
                height: 0.5,
                color: CupertinoDynamicColor.resolve(AppColors.divider, context),
              ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 50 * widget.index))
        .fadeIn(duration: 300.ms)
        .slideX(
          begin: -0.03,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _statusLabel(BusinessStatus status) {
  switch (status) {
    case BusinessStatus.found:
      return 'Found';
    case BusinessStatus.audited:
      return 'Audited';
    case BusinessStatus.reportSent:
      return 'Report sent';
    case BusinessStatus.contacted:
      return 'Contacted';
    case BusinessStatus.interested:
      return 'Interested';
    case BusinessStatus.closed:
      return 'Closed';
    case BusinessStatus.lost:
      return 'Lost';
  }
}

String _statusDescription(BusinessStatus status) {
  switch (status) {
    case BusinessStatus.found:
      return 'New lead found';
    case BusinessStatus.audited:
      return 'Audit completed';
    case BusinessStatus.reportSent:
      return 'Report sent to lead';
    case BusinessStatus.contacted:
      return 'Outreach sent';
    case BusinessStatus.interested:
      return 'Marked interested';
    case BusinessStatus.closed:
      return 'Deal closed';
    case BusinessStatus.lost:
      return 'Marked as lost';
  }
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}
