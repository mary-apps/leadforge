import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../providers/businesses_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/lead_item.dart';
import '../../widgets/stat_cell.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../widgets/error_state.dart';
import '../../widgets/daily_digest.dart';
import '../../widgets/weekly_activity_graph.dart';
import '../../widgets/getting_started_guide.dart';
import '../../utils/breakpoints.dart';


String _timeAwareGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Memoization cache — recalculated only when the businesses list identity changes.
  List<Business>? _cachedBusinesses;
  Map<String, dynamic>? _cachedStats;
  Map<String, List<int>>? _cachedWeeklyData;
  String? _cachedTrend;
  bool _cachedTrendComputed = false;

  void _refreshCache(List<Business> businesses) {
    _cachedBusinesses = businesses;
    _cachedStats = _calculateStats(businesses);
    _cachedWeeklyData = _calculateWeeklyData(businesses);
    _cachedTrend = _calculateTrend(businesses);
    _cachedTrendComputed = true;
  }

  Map<String, dynamic> _getStats(List<Business> businesses) {
    if (!identical(businesses, _cachedBusinesses) || _cachedStats == null) {
      _refreshCache(businesses);
    }
    return _cachedStats!;
  }

  Map<String, List<int>> _getWeeklyData(List<Business> businesses) {
    if (!identical(businesses, _cachedBusinesses) || _cachedWeeklyData == null) {
      _refreshCache(businesses);
    }
    return _cachedWeeklyData!;
  }

  String? _getTrend(List<Business> businesses) {
    if (!identical(businesses, _cachedBusinesses) || !_cachedTrendComputed) {
      _refreshCache(businesses);
    }
    return _cachedTrend;
  }

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(businessesProvider);
    final displayName = ref.watch(
      profileNotifierProvider.select((s) => s.valueOrNull?.displayName),
    );

    return CupertinoPageScaffold(
      child: businessesAsync.when(
        data: (businesses) {
          final stats = _getStats(businesses);
          final recentLeads = businesses.length > 5
              ? businesses.sublist(businesses.length - 5)
              : businesses;

          final scrollView = CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  await ref.read(businessesProvider.notifier).load();
                  ref.read(profileNotifierProvider.notifier).reload();
                },
              ),

              // Title + greeting — always visible
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppConstants.pageHorizontal,
                    MediaQuery.of(context).padding.top + 20,
                    AppConstants.pageHorizontal,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LeadForge',
                        style: AppTypography.displayLarge(context),
                      ),
                      const SizedBox(height: AppConstants.contentGap),
                      Text(
                        displayName != null
                            ? '${_timeAwareGreeting()}, $displayName'
                            : _timeAwareGreeting(),
                        style: AppTypography.bodyLarge(context).copyWith(
                          color: CupertinoDynamicColor.resolve(
                            AppColors.textSecondary,
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (businesses.isEmpty) ...[
                // Getting started guide for new users
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pageHorizontal,
                      AppConstants.sectionGap,
                      AppConstants.pageHorizontal,
                      0,
                    ),
                    child: GettingStartedGuide(
                      onStartScouting: () => context.go('/scout'),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppConstants.scrollBottomPadding)),
              ] else ...[
                // Normal dashboard content (stats, digest, chart, recent leads)

                // Stat row — 3 cells
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pageHorizontal,
                      AppConstants.sectionGap,
                      AppConstants.pageHorizontal,
                      0,
                    ),
                    child: StatRow(
                      cells: [
                        StatCell(
                          value: (stats['audited'] as int).toString(),
                          label: 'AUDITED',
                        ),
                        StatCell(
                          value: (stats['reports'] as int).toString(),
                          label: 'REPORTS',
                        ),
                        StatCell(
                          value: (stats['closed'] as int).toString(),
                          label: 'CLOSED',
                        ),
                      ],
                    ),
                  ),
                ),

                // Hero stat — animated number
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pageHorizontal,
                      AppConstants.sectionGap,
                      AppConstants.pageHorizontal,
                      0,
                    ),
                    child: _HeroStat(
                      value: stats['total'] as int,
                      trend: _getTrend(businesses),
                    ),
                  ),
                ),

                // Daily Digest
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pageHorizontal,
                      AppConstants.sectionGap,
                      AppConstants.pageHorizontal,
                      0,
                    ),
                    child: DailyDigest(
                      businesses: businesses,
                      onNavigate: (route) {
                        final uri = Uri.parse(route);
                        final filter = uri.queryParameters['filter'];
                        if (uri.path == '/pipeline' && filter != null) {
                          final status = BusinessStatus.values.firstWhere(
                            (s) => s.name == filter,
                            orElse: () => BusinessStatus.found,
                          );
                          ref.read(pipelineFilterProvider.notifier).state = status;
                          context.go('/pipeline');
                        } else {
                          context.go(route);
                        }
                      },
                    ),
                  ),
                ),

                // Weekly Activity Graph
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pageHorizontal - 8,
                      AppConstants.itemGap,
                      AppConstants.pageHorizontal + 4,
                      0,
                    ),
                    child: WeeklyActivityGraph(
                      data: _getWeeklyData(businesses),
                      emptyState: _firstUnauditedLead(businesses) != null
                          ? _StartWithLeadCta(
                              business: _firstUnauditedLead(businesses)!,
                              onTap: (id) => context.push('/business/$id'),
                            )
                          : null,
                    ),
                  ),
                ),

                // Recent leads header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pageHorizontal,
                      AppConstants.sectionGap,
                      AppConstants.pageHorizontal,
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RECENT',
                          style: AppTypography.labelSmall(context).copyWith(
                            color: CupertinoDynamicColor.resolve(
                              AppColors.textSecondary,
                              context,
                            ),
                          ),
                        ),
                        if (recentLeads.isNotEmpty)
                          GestureDetector(
                            onTap: () => context.go('/pipeline'),
                            child: Text(
                              'See All',
                              style: AppTypography.labelLarge(context).copyWith(
                                color: CupertinoDynamicColor.resolve(
                                  AppColors.accent,
                                  context,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.pageHorizontal,
                    AppConstants.itemGap,
                    AppConstants.pageHorizontal,
                    AppConstants.scrollBottomPadding,
                  ),
                  sliver: SliverList.builder(
                    itemCount: recentLeads.length,
                    itemBuilder: (context, index) {
                      final business = recentLeads[index];

                      return RepaintBoundary(
                        child: LeadItem(
                          business: business,
                          showDivider: index < recentLeads.length - 1,
                          onTap: () =>
                              context.push('/business/${business.id}'),
                        )
                            .animate(
                              delay: Duration(
                                milliseconds:
                                    AppConstants.staggerDelay.inMilliseconds *
                                        index,
                              ),
                            )
                            .fadeIn(duration: AppConstants.standardAnimation)
                            .slideY(
                              begin: AppConstants.entranceSlideDistance / 100,
                              duration: AppConstants.standardAnimation + const Duration(milliseconds: 100),
                              curve: Curves.easeOutCubic,
                            ),
                      );
                    },
                  ),
                ),
              ],
            ],
          );
          if (!isCompact(context)) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: scrollView,
              ),
            );
          }
          return scrollView;
        },
        loading: () => const DashboardSkeleton(),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.read(businessesProvider.notifier).load(),
        ),
      ),
    );
  }

  String? _calculateTrend(List<Business> businesses) {
    if (businesses.isEmpty) return null;
    final now = DateTime.now();
    final thisWeek =
        businesses.where((b) => now.difference(b.createdAt ?? DateTime.now()).inDays < 7).length;
    final lastWeek = businesses
        .where((b) =>
            now.difference(b.createdAt ?? DateTime.now()).inDays >= 7 &&
            now.difference(b.createdAt ?? DateTime.now()).inDays < 14)
        .length;
    if (lastWeek == 0 && thisWeek > 0) return '+$thisWeek';
    if (lastWeek == 0) return null;
    final pct = (((thisWeek - lastWeek) / lastWeek) * 100).round();
    if (pct == 0) return null;
    return pct > 0 ? '+$pct%' : '$pct%';
  }

  Map<String, dynamic> _calculateStats(List<Business> businesses) {
    return {
      'total': businesses.length,
      'audited': businesses.where((b) => b.isAudited).length,
      'reports': businesses.where((b) => b.hasReport).length,
      'closed': businesses
          .where((b) => b.status == BusinessStatus.closed)
          .length,
    };
  }

  /// Most recent business in the "found" status that has not been audited
  /// yet. Used as a CTA when the weekly chart is empty.
  Business? _firstUnauditedLead(List<Business> businesses) {
    for (final b in businesses) {
      if (b.status == BusinessStatus.found && !b.isAudited) return b;
    }
    return null;
  }

  Map<String, List<int>> _calculateWeeklyData(List<Business> businesses) {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final result = <String, List<int>>{};

    for (final day in days) {
      result[day] = [0, 0, 0];
    }

    for (final b in businesses) {
      final diff = now.difference(b.createdAt ?? DateTime.now()).inDays;
      if (diff < 7) {
        final dayIndex = ((b.createdAt ?? DateTime.now()).weekday - 1) % 7;
        result[days[dayIndex]]![0]++;
      }
      if (b.auditedAt != null) {
        final auditDiff = now.difference(b.auditedAt!).inDays;
        if (auditDiff < 7) {
          final dayIndex = (b.auditedAt!.weekday - 1) % 7;
          result[days[dayIndex]]![1]++;
        }
      }
      if (b.status == BusinessStatus.contacted ||
          b.status == BusinessStatus.interested ||
          b.status == BusinessStatus.closed) {
        if (b.updatedAt != null) {
          final updateDiff = now.difference(b.updatedAt!).inDays;
          if (updateDiff < 7) {
            final dayIndex = (b.updatedAt!.weekday - 1) % 7;
            result[days[dayIndex]]![2]++;
          }
        }
      }
    }

    return result;
  }
}

// ---------------------------------------------------------------------------
// HERO STAT — animated number
// ---------------------------------------------------------------------------

class _HeroStat extends StatefulWidget {
  final int value;
  final String? trend;

  const _HeroStat({required this.value, this.trend});

  @override
  State<_HeroStat> createState() => _HeroStatState();
}

class _HeroStatState extends State<_HeroStat>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _counter;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.countUpAnimation,
      vsync: this,
    );
    _counter = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedBuilder(
              animation: _counter,
              builder: (context, _) {
                return Text(
                  _counter.value.toString(),
                  style: AppTypography.scoreLarge(context).copyWith(
                    fontSize: 52,
                    letterSpacing: -3,
                  ),
                );
              },
            ),
            if (widget.trend != null)
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CupertinoDynamicColor.resolve(
                      widget.trend!.startsWith('-')
                          ? AppColors.scoreBadBg
                          : AppColors.scoreGoodBg,
                      context,
                    ),
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                  ),
                  child: Text(
                    widget.trend!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: CupertinoDynamicColor.resolve(
                        widget.trend!.startsWith('-')
                            ? AppColors.scoreBad
                            : AppColors.scoreGood,
                        context,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        Text(
          'leads this month',
          style: AppTypography.labelLarge(context).copyWith(
            color: CupertinoDynamicColor.resolve(
              AppColors.textSecondary,
              context,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Start-with-lead CTA used when the weekly chart has no activity yet but
// there is at least one un-audited "found" lead to push the user toward.
// ---------------------------------------------------------------------------

class _StartWithLeadCta extends StatelessWidget {
  final Business business;
  final void Function(String businessId) onTap;

  const _StartWithLeadCta({
    required this.business,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = CupertinoDynamicColor.resolve(AppColors.accent, context);
    final surface = CupertinoDynamicColor.resolve(AppColors.surface, context);
    final border = CupertinoDynamicColor.resolve(AppColors.border, context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(business.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppColors.radiusL),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(CupertinoIcons.bolt_fill, color: accent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start with ${business.name}',
                    style: AppTypography.titleMedium(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Run an audit to kick off this week',
                    style: AppTypography.labelLarge(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                        AppColors.textSecondary,
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: CupertinoDynamicColor.resolve(
                AppColors.textTertiary,
                context,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
