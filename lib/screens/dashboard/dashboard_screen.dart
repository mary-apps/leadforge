import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../providers/businesses_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: businessesAsync.when(
        data: (businesses) {
          final stats = _calculateStats(businesses);
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Overview',
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: 16),
              
              // Stats cards
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(
                    label: 'Total Leads',
                    value: stats['total'].toString(),
                    icon: Icons.people,
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    label: 'Audited',
                    value: stats['audited'].toString(),
                    icon: Icons.analytics,
                    color: AppColors.info,
                  ),
                  _StatCard(
                    label: 'Demos Sent',
                    value: stats['demos'].toString(),
                    icon: Icons.web,
                    color: AppColors.warning,
                  ),
                  _StatCard(
                    label: 'Closed Deals',
                    value: stats['closed'].toString(),
                    icon: Icons.check_circle,
                    color: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Revenue tracker
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revenue Tracker',
                        style: AppTypography.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total MRR',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${stats['mrr'].toStringAsFixed(0)}',
                                  style: AppTypography.displayLarge.copyWith(
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
  
  Map<String, dynamic> _calculateStats(List businesses) {
    return {
      'total': businesses.length,
      'audited': businesses.where((b) => b.isAudited).length,
      'demos': businesses.where((b) => b.hasDemo).length,
      'closed': businesses.where((b) => b.status.toString() == 'BusinessStatus.closed').length,
      'mrr': businesses
          .where((b) => b.dealValue != null)
          .fold<double>(0, (sum, b) => sum + (b.dealValue ?? 0)),
    };
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 44) / 2;
    
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.headlineLarge.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
