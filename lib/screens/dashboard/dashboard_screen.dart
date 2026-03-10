import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../providers/businesses_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../widgets/stat_card_animated.dart';
import '../../widgets/weekly_activity_graph.dart';

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

    return Scaffold(
      body: businessesAsync.when(
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
              // Collapsing app bar with greeting
              SliverAppBar(
                expandedHeight: 100,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.background,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                  title: Text(
                    displayName,
                    style: AppTypography.titleMedium.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 44),
                        child: Text(
                          _timeAwareGreeting(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppColors.radiusM),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList.list(
                  children: [
                    // Stats with gradient border
                    Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppColors.radiusXL + 1),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.3),
                            AppColors.primary.withValues(alpha: 0.0),
                            AppColors.primary.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppColors.radiusXL),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: StatCardAnimated(
                                label: 'Leads',
                                value: stats['total'] as int,
                                icon: Icons.people,
                                color: AppColors.primary,
                                trend: _calculateTrend(businesses),
                                index: 0,
                              ),
                            ),
                            SizedBox(
                              width: 1,
                              height: 48,
                              child: Container(color: AppColors.divider),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCardAnimated(
                                label: 'Audits',
                                value: stats['audited'] as int,
                                icon: Icons.analytics,
                                color: AppColors.secondary,
                                index: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Quick Actions
                    Text(
                      'QUICK ACTIONS',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Scout - dominant action
                        Expanded(
                          flex: 2,
                          child: _QuickAction(
                            label: 'SCOUT',
                            subtitle: 'Find new leads',
                            icon: Icons.radar_rounded,
                            iconSize: 28,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                            ),
                            foreground: AppColors.background,
                            subtitleColor: const Color(0x99080810),
                            verticalPadding: 28,
                            onTap: () => context.go('/scout'),
                          )
                              .animate()
                              .fadeIn(delay: 100.ms, duration: 300.ms)
                              .slideY(
                                begin: 0.15,
                                delay: 100.ms,
                                duration: 250.ms,
                                curve: Curves.easeOutCubic,
                              ),
                        ),
                        const SizedBox(width: 10),
                        // Pipeline + Outreach stacked
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _QuickAction(
                                label: 'PIPELINE',
                                icon: Icons.view_kanban_rounded,
                                onTap: () => context.go('/pipeline'),
                              )
                                  .animate()
                                  .fadeIn(delay: 150.ms, duration: 300.ms)
                                  .slideY(
                                    begin: 0.15,
                                    delay: 150.ms,
                                    duration: 250.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                              const SizedBox(height: 10),
                              _QuickAction(
                                label: 'OUTREACH',
                                icon: Icons.campaign_rounded,
                                onTap: () {},
                              )
                                  .animate()
                                  .fadeIn(delay: 200.ms, duration: 300.ms)
                                  .slideY(
                                    begin: 0.15,
                                    delay: 200.ms,
                                    duration: 250.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Recent Leads
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RECENT LEADS',
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/pipeline'),
                          child: Text(
                            'See All',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (recentLeads.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No leads yet. Start scouting!',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      ...recentLeads.asMap().entries.map((entry) {
                        final index = entry.key;
                        final business = entry.value;
                        return _RecentLeadTile(
                          business: business,
                          index: index,
                          onTap: () =>
                              context.push('/business/${business.id}'),
                        );
                      }),
                    const SizedBox(height: 28),

                    // Weekly Activity
                    Text(
                      'WEEKLY ACTIVITY',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppColors.radiusXL + 1),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.2),
                            AppColors.primary.withValues(alpha: 0.0),
                            AppColors.primary.withValues(alpha: 0.08),
                          ],
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppColors.radiusXL),
                        ),
                        child: WeeklyActivityGraph(
                          data: _getWeeklyData(businesses),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const DashboardSkeleton(),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String? _calculateTrend(List businesses) {
    if (businesses.isEmpty) return null;
    final now = DateTime.now();
    final thisWeek =
        businesses.where((b) => now.difference(b.createdAt).inDays < 7).length;
    final lastWeek = businesses
        .where((b) =>
            now.difference(b.createdAt).inDays >= 7 &&
            now.difference(b.createdAt).inDays < 14)
        .length;
    if (lastWeek == 0 && thisWeek > 0) return '+$thisWeek';
    if (lastWeek == 0) return null;
    final pct = (((thisWeek - lastWeek) / lastWeek) * 100).round();
    if (pct == 0) return null;
    return pct > 0 ? '+$pct%' : '$pct%';
  }

  Map<String, dynamic> _calculateStats(List businesses) {
    return {
      'total': businesses.length,
      'audited': businesses.where((b) => b.isAudited).length,
      'demos': businesses.where((b) => b.hasDemo).length,
      'closed': businesses
          .where((b) => b.status.toString() == 'BusinessStatus.closed')
          .length,
      'mrr': businesses
          .where((b) => b.dealValue != null)
          .fold<double>(0, (sum, b) => sum + (b.dealValue ?? 0)),
    };
  }

  Map<String, List<int>> _getWeeklyData(List businesses) {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final result = <String, List<int>>{};

    for (final day in days) {
      result[day] = [0, 0, 0]; // [searches, audits, outreach]
    }

    for (final b in businesses) {
      final diff = now.difference(b.createdAt).inDays;
      if (diff < 7) {
        final dayIndex = (b.createdAt.weekday - 1) % 7;
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
// Quick Action button with press-scale feedback
// ---------------------------------------------------------------------------

class _QuickAction extends StatefulWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final double iconSize;
  final Gradient? gradient;
  final Color? foreground;
  final Color? subtitleColor;
  final double verticalPadding;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    this.subtitle,
    required this.icon,
    this.iconSize = 22,
    this.gradient,
    this.foreground,
    this.subtitleColor,
    this.verticalPadding = 14,
    required this.onTap,
  });

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final fg = widget.foreground ?? AppColors.textSecondary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: widget.verticalPadding),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color: widget.gradient == null ? AppColors.surface : null,
            borderRadius: BorderRadius.circular(AppColors.radiusL),
          ),
          child: Column(
            children: [
              Icon(widget.icon, color: fg, size: widget.iconSize),
              SizedBox(height: widget.subtitle != null ? 6 : 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.subtitle != null ? 13 : 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: fg,
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: widget.subtitleColor ?? AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent lead tile with press feedback + staggered entrance
// ---------------------------------------------------------------------------

class _RecentLeadTile extends StatefulWidget {
  final Business business;
  final int index;
  final VoidCallback onTap;

  const _RecentLeadTile({
    required this.business,
    required this.index,
    required this.onTap,
  });

  @override
  State<_RecentLeadTile> createState() => _RecentLeadTileState();
}

class _RecentLeadTileState extends State<_RecentLeadTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final business = widget.business;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppColors.radiusL),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppColors.radiusM),
                  ),
                  child: Center(
                    child: Icon(business.webPresenceIcon,
                        color: business.webPresenceColor, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.name,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Score: ${business.auditScore ?? '-'} · ${business.status.name}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 50 * widget.index),
          duration: 300.ms,
        )
        .slideX(
          begin: 0.05,
          delay: Duration(milliseconds: 50 * widget.index),
          duration: 250.ms,
          curve: Curves.easeOut,
        );
  }
}
