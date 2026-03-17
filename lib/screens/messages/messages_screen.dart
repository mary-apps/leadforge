import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../providers/businesses_provider.dart';
import '../../widgets/error_state.dart';
import '../../widgets/skeleton_loaders.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessesProvider);

    return CupertinoPageScaffold(
      backgroundColor:
          CupertinoDynamicColor.resolve(AppColors.background, context),
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
                      size: 48,
                      color: CupertinoDynamicColor.resolve(
                          AppColors.textTertiary, context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No activity yet',
                      style: AppTypography.titleMedium(context),
                    ),
                    const SizedBox(height: AppConstants.contentGap),
                    Text(
                      'Your recent actions will appear here',
                      style: AppTypography.labelLarge(context).copyWith(
                        color: CupertinoDynamicColor.resolve(
                            AppColors.textTertiary, context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Sort by most recently updated
          final sorted = List<Business>.from(businesses)
            ..sort((a, b) {
              final aDate = a.updatedAt ?? a.createdAt ?? DateTime.now();
              final bDate = b.updatedAt ?? b.createdAt ?? DateTime.now();
              return bDate.compareTo(aDate);
            });

          // Group by time period
          final now = DateTime.now();
          DateTime eventDate(Business b) =>
              b.updatedAt ?? b.createdAt ?? DateTime.now();

          final today = sorted
              .where((b) => now.difference(eventDate(b)).inHours < 24)
              .toList();
          final thisWeek = sorted.where((b) {
            final d = now.difference(eventDate(b));
            return d.inHours >= 24 && d.inDays < 7;
          }).toList();
          final earlier = sorted
              .where((b) => now.difference(eventDate(b)).inDays >= 7)
              .toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Custom title header
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pageHorizontal,
                      16,
                      AppConstants.pageHorizontal,
                      0,
                    ),
                    child: Text(
                      'Activity',
                      style: AppTypography.displayLarge(context),
                    ),
                  ),
                ),
              ),

              // Summary text
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.pageHorizontal,
                    AppConstants.contentGap,
                    AppConstants.pageHorizontal,
                    AppConstants.itemGap,
                  ),
                  child: Text(
                    _summaryText(today.length, thisWeek.length),
                    style: AppTypography.labelLarge(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                          AppColors.textTertiary, context),
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
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
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
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pageHorizontal,
            AppConstants.sectionGap,
            AppConstants.pageHorizontal,
            AppConstants.contentGap,
          ),
          child: Text(
            label,
            style: AppTypography.labelSmall(context),
          ),
        ),
      ),

      // Divider under section header
      SliverToBoxAdapter(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.pageHorizontal),
          child: Container(
            height: 0.5,
            color:
                CupertinoDynamicColor.resolve(AppColors.divider, context),
          ),
        ),
      ),

      // Featured first item (only for Today)
      if (featured && featuredBusiness != null)
        SliverToBoxAdapter(
          child: _FeaturedActivityRow(
            business: featuredBusiness,
            onTap: () => context.push('/business/${featuredBusiness.id}'),
          )
              .animate(
                  delay: AppConstants.staggerDelay * animationOffset)
              .fadeIn(duration: AppConstants.standardAnimation)
              .slideY(
                begin: AppConstants.entranceSlideDistance / 100,
                duration: AppConstants.standardAnimation,
                curve: Curves.easeOut,
              ),
        ),

      // Remaining items as flat rows with dividers
      if (remainingItems.isNotEmpty)
        SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(remainingItems.length, (index) {
              final business = remainingItems[index];
              final isLast = index == remainingItems.length - 1;
              final globalIndex =
                  animationOffset + (featured ? index + 1 : index);

              return _ActivityRow(
                business: business,
                index: globalIndex,
                showDivider: !isLast,
                density: density,
                onTap: () => context.push('/business/${business.id}'),
              );
            }),
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
// Featured activity row -- promoted first item of "Today"
// ---------------------------------------------------------------------------

class _FeaturedActivityRow extends StatefulWidget {
  final Business business;
  final VoidCallback onTap;

  const _FeaturedActivityRow({
    required this.business,
    required this.onTap,
  });

  @override
  State<_FeaturedActivityRow> createState() => _FeaturedActivityRowState();
}

class _FeaturedActivityRowState extends State<_FeaturedActivityRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final business = widget.business;
    final timeAgo =
        _timeAgo(business.updatedAt ?? business.createdAt ?? DateTime.now());

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppConstants.quickAnimation,
        color: _pressed
            ? CupertinoColors.systemFill.resolveFrom(context)
            : const Color(0x00000000),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.pageHorizontal,
          vertical: 14,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: business.statusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppColors.radiusM),
              ),
              alignment: Alignment.center,
              child: Icon(business.statusIcon,
                  color: business.statusColor, size: 20),
            ),
            const SizedBox(width: AppConstants.itemGap),
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
                  const SizedBox(height: 2),
                  Text(
                    '${_statusDescription(business.status)} · $timeAgo',
                    style: AppTypography.labelLarge(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                          AppColors.textSecondary, context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoDynamicColor.resolve(
                  AppColors.textTertiary, context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Activity row -- density-aware rendering
// ---------------------------------------------------------------------------

class _ActivityRow extends StatefulWidget {
  final Business business;
  final int index;
  final bool showDivider;
  final _Density density;
  final VoidCallback onTap;

  const _ActivityRow({
    required this.business,
    required this.index,
    required this.onTap,
    required this.density,
    this.showDivider = true,
  });

  @override
  State<_ActivityRow> createState() => _ActivityRowState();
}

class _ActivityRowState extends State<_ActivityRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final business = widget.business;
    final timeAgo =
        _timeAgo(business.updatedAt ?? business.createdAt ?? DateTime.now());
    final density = widget.density;

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
    final vPad = switch (density) {
      _Density.full => 12.0,
      _Density.medium => 10.0,
      _Density.compact => 8.0,
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
        duration: AppConstants.quickAnimation,
        color: _pressed
            ? CupertinoColors.systemFill.resolveFrom(context)
            : const Color(0x00000000),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.pageHorizontal,
                vertical: vPad,
              ),
              child: Row(
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: business.statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(
                          density == _Density.compact
                              ? AppColors.radiusS
                              : AppColors.radiusM),
                    ),
                    alignment: Alignment.center,
                    child: Icon(business.statusIcon,
                        color: business.statusColor, size: iconInnerSize),
                  ),
                  SizedBox(
                      width: density == _Density.compact ? 8 : AppConstants.itemGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          business.name,
                          style: density == _Density.compact
                              ? AppTypography.bodyMedium(context)
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
                      color: CupertinoDynamicColor.resolve(
                          AppColors.textTertiary, context),
                      size: 16,
                    ),
                ],
              ),
            ),
            if (widget.showDivider)
              Padding(
                padding: const EdgeInsets.only(
                  left: AppConstants.pageHorizontal,
                  right: AppConstants.pageHorizontal,
                ),
                child: Container(
                  height: 0.5,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.divider, context),
                ),
              ),
          ],
        ),
      ),
    )
        .animate(delay: AppConstants.staggerDelay * widget.index)
        .fadeIn(duration: AppConstants.standardAnimation)
        .slideY(
          begin: AppConstants.entranceSlideDistance / 100,
          duration: AppConstants.standardAnimation,
          curve: Curves.easeOut,
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
    case BusinessStatus.demoCreated:
      return 'Demo created';
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
    case BusinessStatus.demoCreated:
      return 'Demo site built';
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
