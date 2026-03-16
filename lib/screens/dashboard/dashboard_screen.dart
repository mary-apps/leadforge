import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../providers/businesses_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/brutal_card.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../widgets/brutal_button.dart';
import '../../widgets/error_state.dart';
import '../../widgets/weekly_activity_graph.dart';
import '../../utils/haptics.dart';

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
      data: (p) => p?.displayName ?? 'there',
      loading: () => '...',
      error: (_, __) => 'there',
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
              const CupertinoSliverNavigationBar(
                largeTitle: Text('LeadForge'),
              ),

              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  await ref.read(businessesProvider.notifier).load();
                  ref.read(profileNotifierProvider.notifier).reload();
                },
              ),

              // Greeting + hero stat
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_timeAwareGreeting()}, $displayName',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      _HeroStat(
                        value: stats['total'] as int,
                        trend: _calculateTrend(businesses),
                      ),
                    ],
                  ),
                ),
              ),

              // Inline stat pills — 3 columns, compact
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatPill(
                          value: stats['audited'] as int,
                          label: 'Audited',
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatPill(
                          value: stats['demos'] as int,
                          label: 'Demos',
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatPill(
                          value: stats['closed'] as int,
                          label: 'Closed',
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(
                        begin: 0.08,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ),
              ),

              // Weekly Activity Graph — asymmetric padding
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 28, 0),
                  child: WeeklyActivityGraph(
                    data: _getWeeklyData(businesses),
                  ),
                ),
              ),

              // Recent leads header — shifted left
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RECENT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      if (recentLeads.isNotEmpty)
                        GestureDetector(
                          onTap: () => context.go('/pipeline'),
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              if (recentLeads.isEmpty)
                SliverToBoxAdapter(child: _EmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
                  sliver: SliverList.builder(
                    itemCount: recentLeads.length,
                    itemBuilder: (context, index) {
                      final business = recentLeads[index];

                      // First card is featured — larger, accent border
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _FeaturedLeadCard(
                            business: business,
                            onTap: () =>
                                context.push('/business/${business.id}'),
                          ),
                        )
                            .animate(delay: 400.ms)
                            .fadeIn(duration: 300.ms)
                            .slideX(
                              begin: -0.04,
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _LeadCard(
                          business: business,
                          onTap: () =>
                              context.push('/business/${business.id}'),
                        ),
                      )
                          .animate(
                              delay: Duration(
                                  milliseconds: 400 + (index * 60)))
                          .fadeIn(duration: 300.ms)
                          .slideX(
                            begin: -0.04,
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          );
                    },
                  ),
                ),

              if (recentLeads.isEmpty)
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
      duration: const Duration(milliseconds: 800),
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
                  style: TextStyle(
                    fontFamily: AppTypography.displayLarge.fontFamily,
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                    letterSpacing: -3,
                    color: AppColors.primary,
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
                    color: (widget.trend!.startsWith('-')
                            ? AppColors.danger
                            : AppColors.success)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                    border: Border.all(
                      color: (widget.trend!.startsWith('-')
                              ? AppColors.danger
                              : AppColors.success)
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    widget.trend!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: widget.trend!.startsWith('-')
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const Text(
          'leads this month',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Stat Pill — compact stat in BrutalCard
// ---------------------------------------------------------------------------

class _StatPill extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _StatPill({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value.toString(),
            style: TextStyle(
              fontFamily: AppTypography.numberLarge.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Featured lead card — first item, larger with accent border
// ---------------------------------------------------------------------------

class _FeaturedLeadCard extends StatefulWidget {
  final Business business;
  final VoidCallback onTap;

  const _FeaturedLeadCard({
    required this.business,
    required this.onTap,
  });

  @override
  State<_FeaturedLeadCard> createState() => _FeaturedLeadCardState();
}

class _FeaturedLeadCardState extends State<_FeaturedLeadCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final business = widget.business;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Haptics.light();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: BrutalCard(
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.all(18),
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
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        business.statusColor.withValues(alpha: 0.15),
                        business.statusColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    business.statusIcon,
                    color: business.statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      if (business.address != null)
                        Text(
                          business.shortAddress ?? business.address!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          business.status.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: business.statusColor.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                if (business.auditScore != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            AppColors.scoreGradient(business.auditScore!),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.scoreColor(business.auditScore!)
                              .withValues(alpha: 0.25),
                          blurRadius: 8,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: Text(
                      business.auditScore.toString(),
                      style: TextStyle(
                        fontFamily: AppTypography.numberLarge.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.background,
                      ),
                    ),
                  )
                else
                  const Icon(
                    CupertinoIcons.chevron_forward,
                    size: 14,
                    color: AppColors.textTertiary,
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
// Lead card — compact for non-featured items
// ---------------------------------------------------------------------------

class _LeadCard extends StatefulWidget {
  final Business business;
  final VoidCallback onTap;

  const _LeadCard({
    required this.business,
    required this.onTap,
  });

  @override
  State<_LeadCard> createState() => _LeadCardState();
}

class _LeadCardState extends State<_LeadCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final business = widget.business;
    final hasHighScore =
        business.auditScore != null && business.auditScore! >= 70;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Haptics.light();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _pressed ? AppColors.surfaceLight : AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radiusL),
            border: Border.all(
              color: hasHighScore
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.border,
              width: hasHighScore ? 1 : 0.5,
            ),
            boxShadow: hasHighScore
                ? [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.06),
                      blurRadius: 16,
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      business.statusColor.withValues(alpha: 0.15),
                      business.statusColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppColors.radiusS),
                ),
                alignment: Alignment.center,
                child: Icon(
                  business.statusIcon,
                  color: business.statusColor,
                  size: 14,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  business.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (business.auditScore != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.scoreGradient(business.auditScore!),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    business.auditScore.toString(),
                    style: TextStyle(
                      fontFamily: AppTypography.numberLarge.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.background,
                    ),
                  ),
                )
              else
                const Icon(
                  CupertinoIcons.chevron_forward,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: Icon(
              CupertinoIcons.rocket,
              size: 28,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No leads yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Start scouting to find businesses',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          BrutalButton(
            label: 'Start Scouting',
            icon: CupertinoIcons.search,
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
