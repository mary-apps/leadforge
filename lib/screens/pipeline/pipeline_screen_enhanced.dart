import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../providers/businesses_provider.dart';
import '../../utils/haptics.dart';

class PipelineScreenEnhanced extends ConsumerStatefulWidget {
  const PipelineScreenEnhanced({super.key});

  @override
  ConsumerState<PipelineScreenEnhanced> createState() =>
      _PipelineScreenEnhancedState();
}

class _PipelineScreenEnhancedState
    extends ConsumerState<PipelineScreenEnhanced> {
  final Map<BusinessStatus, bool> _expandedSections = {
    BusinessStatus.found: true,
    BusinessStatus.audited: true,
    BusinessStatus.demoCreated: true,
    BusinessStatus.contacted: true,
    BusinessStatus.interested: true,
    BusinessStatus.closed: false,
    BusinessStatus.lost: false,
  };

  Future<void> _moveBusinessToStatus(
    Business business,
    BusinessStatus newStatus,
  ) async {
    Haptics.medium();
    try {
      await ref
          .read(businessesProvider.notifier)
          .updateBusinessStatus(business.id, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Moved to ${_getStatusTitle(newStatus)}',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      Haptics.heavy();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _deleteBusiness(Business business) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Business'),
        content: Text('Remove ${business.name} from pipeline?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Haptics.heavy();
      try {
        await ref.read(businessesProvider.notifier).deleteBusiness(business.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Business removed'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pipelineAsync = ref.watch(pipelineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pipeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Haptics.light();
              ref.read(businessesProvider.notifier).load();
            },
          ),
        ],
      ),
      body: pipelineAsync.when(
        data: (pipeline) {
          return RefreshIndicator(
            onRefresh: () async {
              Haptics.light();
              await ref.read(businessesProvider.notifier).load();
            },
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection(
                  '🔍 Found',
                  BusinessStatus.found,
                  pipeline[BusinessStatus.found] ?? [],
                  AppColors.primary,
                ),
                _buildSection(
                  '📊 Audited',
                  BusinessStatus.audited,
                  pipeline[BusinessStatus.audited] ?? [],
                  AppColors.info,
                ),
                _buildSection(
                  '🌐 Demo Created',
                  BusinessStatus.demoCreated,
                  pipeline[BusinessStatus.demoCreated] ?? [],
                  AppColors.warning,
                ),
                _buildSection(
                  '📧 Contacted',
                  BusinessStatus.contacted,
                  pipeline[BusinessStatus.contacted] ?? [],
                  AppColors.primary,
                ),
                _buildSection(
                  '⭐ Interested',
                  BusinessStatus.interested,
                  pipeline[BusinessStatus.interested] ?? [],
                  AppColors.warning,
                ),
                _buildSection(
                  '✅ Closed',
                  BusinessStatus.closed,
                  pipeline[BusinessStatus.closed] ?? [],
                  AppColors.success,
                ),
                _buildSection(
                  '❌ Lost',
                  BusinessStatus.lost,
                  pipeline[BusinessStatus.lost] ?? [],
                  AppColors.danger,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSection(
    String title,
    BusinessStatus status,
    List<Business> businesses,
    Color color,
  ) {
    final isExpanded = _expandedSections[status] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[status] = !isExpanded;
              });
              Haptics.light();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(title, style: AppTypography.titleLarge),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            businesses.length.toString(),
                            style: AppTypography.labelLarge.copyWith(
                              color: color,
                              fontFamily: 'SF Mono',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            if (businesses.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No businesses in this stage',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...businesses.map((business) => _DraggableBusinessCard(
                    business: business,
                    currentStatus: status,
                    onMoveToStatus: (newStatus) =>
                        _moveBusinessToStatus(business, newStatus),
                    onDelete: () => _deleteBusiness(business),
                    onTap: () => context.push('/business/${business.id}'),
                  )),
          ],
        ],
      ),
    );
  }

  String _getStatusTitle(BusinessStatus status) {
    switch (status) {
      case BusinessStatus.found:
        return 'Found';
      case BusinessStatus.audited:
        return 'Audited';
      case BusinessStatus.demoCreated:
        return 'Demo Created';
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
}

/// Draggable and swipeable business card
class _DraggableBusinessCard extends StatelessWidget {
  final Business business;
  final BusinessStatus currentStatus;
  final Function(BusinessStatus) onMoveToStatus;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _DraggableBusinessCard({
    required this.business,
    required this.currentStatus,
    required this.onMoveToStatus,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(business.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        Haptics.light();

        if (direction == DismissDirection.startToEnd) {
          // Swipe right: Move to next stage
          final nextStatus = _getNextStatus(currentStatus);
          if (nextStatus != null) {
            onMoveToStatus(nextStatus);
          }
          return false; // Don't actually dismiss
        } else {
          // Swipe left: Delete
          Haptics.heavy();
          onDelete();
          return true;
        }
      },
      background: _buildSwipeBackground(
        Icons.arrow_forward,
        AppColors.success,
        Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        Icons.delete_outline,
        AppColors.danger,
        Alignment.centerRight,
      ),
      child: InkWell(
        onTap: () {
          Haptics.light();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Badge
              Text(
                business.statusBadge,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (business.shortAddress != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        business.shortAddress!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Score badge
              if (business.auditScore != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.scoreColor(business.auditScore!)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    business.auditScore.toString(),
                    style: AppTypography.mono.copyWith(
                      color: AppColors.scoreColor(business.auditScore!),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(IconData icon, Color color, Alignment alignment) {
    return Container(
      color: color.withOpacity(0.1),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(icon, color: color, size: 32),
    );
  }

  BusinessStatus? _getNextStatus(BusinessStatus current) {
    final statuses = [
      BusinessStatus.found,
      BusinessStatus.audited,
      BusinessStatus.demoCreated,
      BusinessStatus.contacted,
      BusinessStatus.interested,
      BusinessStatus.closed,
    ];

    final currentIndex = statuses.indexOf(current);
    if (currentIndex == -1 || currentIndex == statuses.length - 1) {
      return null;
    }

    return statuses[currentIndex + 1];
  }
}
