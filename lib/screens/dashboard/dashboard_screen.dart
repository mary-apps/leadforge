import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../providers/businesses_provider.dart';
import '../../widgets/stat_card_animated.dart';
import '../../widgets/weekly_activity_graph.dart';

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
              
              // Stats cards (animated)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  StatCardAnimated(
                    label: 'Total Leads',
                    value: stats['total'] as int,
                    icon: Icons.people,
                    color: AppColors.primary,
                    index: 0,
                  ),
                  StatCardAnimated(
                    label: 'Audited',
                    value: stats['audited'] as int,
                    icon: Icons.analytics,
                    color: AppColors.info,
                    index: 1,
                  ),
                  StatCardAnimated(
                    label: 'Demos Sent',
                    value: stats['demos'] as int,
                    icon: Icons.web,
                    color: AppColors.warning,
                    index: 2,
                  ),
                  StatCardAnimated(
                    label: 'Closed Deals',
                    value: stats['closed'] as int,
                    icon: Icons.check_circle,
                    color: AppColors.success,
                    index: 3,
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
                                _AnimatedMRR(mrr: stats['mrr'] as double),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Weekly activity graph
              WeeklyActivityGraph(
                data: _getMockWeeklyData(), // TODO: Real data from provider
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
  
  Map<String, List<int>> _getMockWeeklyData() {
    // TODO: Replace with real data from analytics provider
    return {
      'Mon': [3, 2, 1],
      'Tue': [5, 3, 2],
      'Wed': [4, 4, 3],
      'Thu': [6, 2, 1],
      'Fri': [8, 5, 4],
      'Sat': [2, 1, 0],
      'Sun': [1, 0, 0],
    };
  }
}

/// Widget para revenue con contador animado
class _AnimatedMRR extends StatefulWidget {
  final double mrr;
  
  const _AnimatedMRR({required this.mrr});

  @override
  State<_AnimatedMRR> createState() => _AnimatedMRRState();
}

class _AnimatedMRRState extends State<_AnimatedMRR>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _mrrAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _mrrAnimation = Tween<double>(
      begin: 0,
      end: widget.mrr,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _controller.forward();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mrrAnimation,
      builder: (context, child) {
        return Text(
          '\$${_mrrAnimation.value.toStringAsFixed(0)}',
          style: AppTypography.displayLarge.copyWith(
            color: AppColors.success,
          ),
        );
      },
    );
  }
}
