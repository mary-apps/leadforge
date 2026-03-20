import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../providers/businesses_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/lead_item.dart';
import '../../widgets/stat_cell.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../widgets/error_state.dart';
import '../../widgets/daily_digest.dart';
import '../../widgets/weekly_activity_graph.dart';
import '../../widgets/getting_started_guide.dart';


String _timeAwareGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessesProvider);
    final profileAsync = ref.watch(profileNotifierProvider);

    final displayName = profileAsync.when(
      data: (p) => p?.displayName,
      loading: () => null,
      error: (_, __) => null,
    );

    return CupertinoPageScaffold(
      child: businessesAsync.when(
        data: (businesses) {
          final stats = _calculateStats(businesses);
          final recentLeads = businesses.length > 5
              ? businesses.sublist(businesses.length - 5)
              : businesses;

          return CustomScrollView(
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
                          value: (stats['demos'] as int).toString(),
                          label: 'DEMOS',
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
                      trend: _calculateTrend(businesses),
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

                      return LeadItem(
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
                          );
                    },
                  ),
                ),
              ],
            ],
          );
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
      'demos': businesses.where((b) => b.hasDemo).length,
      'closed': businesses
          .where((b) => b.status == BusinessStatus.closed)
          .length,
    };
  }

  Map<String, List<int>> _getWeeklyData(List<Business> businesses) {
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
        final diff = now.difference(b.auditedAt!).inDays;
        if (diff < 7) {
          final dayIndex = (b.auditedAt!.weekday - 1) % 7;
          result[days[dayIndex]]![1]++;
        }
      }
      if (b.status == BusinessStatus.contacted ||
          b.status == BusinessStatus.interested ||
          b.status == BusinessStatus.closed) {
        if (b.updatedAt != null) {
          final diff = now.difference(b.updatedAt!).inDays;
          if (diff < 7) {
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
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accentColor =
        CupertinoDynamicColor.resolve(AppColors.accent, context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 48,
        horizontal: AppConstants.pageHorizontal,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withValues(alpha: 0.12),
                  accentColor.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: Icon(
              CupertinoIcons.rocket,
              size: 28,
              color: accentColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No leads yet',
            style: AppTypography.titleMedium(context).copyWith(
              color: CupertinoDynamicColor.resolve(
                AppColors.textSecondary,
                context,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start scouting to find businesses',
            style: AppTypography.bodyLarge(context).copyWith(
              color: CupertinoDynamicColor.resolve(
                AppColors.textTertiary,
                context,
              ),
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Start Scouting',
            compact: true,
            onPressed: () => context.go('/scout'),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        );
  }
}
