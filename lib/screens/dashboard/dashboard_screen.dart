import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../providers/businesses_provider.dart';
import '../../widgets/stat_card_animated.dart';
import '../../widgets/weekly_activity_graph.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessesProvider);

    return Scaffold(
      body: businessesAsync.when(
        data: (businesses) {
          final stats = _calculateStats(businesses);
          final recentLeads = businesses.length > 5
              ? businesses.sublist(businesses.length - 5)
              : businesses;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
            children: [
              // 1. Greeting header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GOOD MORNING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'User',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          offset: const Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.background,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Stats row
              Row(
                children: [
                  Expanded(
                    child: StatCardAnimated(
                      label: 'Leads',
                      value: stats['total'] as int,
                      icon: Icons.people,
                      color: AppColors.primary,
                      isBrutal: true,
                      trend: _calculateTrend(businesses),
                      index: 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCardAnimated(
                      label: 'Audits',
                      value: stats['audited'] as int,
                      icon: Icons.analytics,
                      color: AppColors.secondary,
                      isBrutal: true,
                      index: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCardAnimated(
                      label: 'Revenue',
                      value: (stats['mrr'] as double).toInt(),
                      icon: Icons.attach_money,
                      color: AppColors.success,
                      isBrutal: false,
                      index: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 3. Quick Actions
              const Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go('/scout'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Text('🔍', style: TextStyle(fontSize: 20)),
                            SizedBox(height: 4),
                            Text(
                              'SCOUT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: AppColors.background,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideY(
                          begin: 0.2,
                          end: 0,
                          delay: 200.ms,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: const Column(
                        children: [
                          Text('📊', style: TextStyle(fontSize: 20)),
                          SizedBox(height: 4),
                          Text(
                            'PIPELINE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 300.ms).slideY(
                          begin: 0.2,
                          end: 0,
                          delay: 300.ms,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: const Column(
                        children: [
                          Text('📨', style: TextStyle(fontSize: 20)),
                          SizedBox(height: 4),
                          Text(
                            'OUTREACH',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 300.ms).slideY(
                          begin: 0.2,
                          end: 0,
                          delay: 400.ms,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 4. Recent Leads
              const Text(
                'RECENT LEADS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // 5. Recent leads list
              if (recentLeads.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No leads yet. Start scouting!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ...recentLeads.map((business) => GestureDetector(
                      onTap: () => context.push('/business/${business.id}'),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text('🏪',
                                    style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    business.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Score: ${business.auditScore ?? '-'} · ${business.status.name}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              '→',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              const SizedBox(height: 28),

              // 6. Weekly Activity
              const Text(
                'WEEKLY ACTIVITY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              WeeklyActivityGraph(
                data: _getWeeklyData(businesses),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
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
          .where(
              (b) => b.status.toString() == 'BusinessStatus.closed')
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
      // Count by creation day (searches)
      final diff = now.difference(b.createdAt).inDays;
      if (diff < 7) {
        final dayIndex = (b.createdAt.weekday - 1) % 7;
        result[days[dayIndex]]![0]++;
      }
      // Count audits by audited_at
      if (b.auditedAt != null) {
        final diff = now.difference(b.auditedAt!).inDays;
        if (diff < 7) {
          final dayIndex = (b.auditedAt!.weekday - 1) % 7;
          result[days[dayIndex]]![1]++;
        }
      }
      // Count contacted as outreach
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
