import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../providers/businesses_provider.dart';
import '../../utils/haptics.dart';
import '../../widgets/skeleton_loaders.dart';

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

  BusinessStatus? _filterStatus;

  void _showFilterSheet() {
    Haptics.light();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filter by Status',
              style: AppTypography.titleMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive, size: 20),
              title: const Text('All Stages'),
              selected: _filterStatus == null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppColors.radiusM),
              ),
              onTap: () {
                setState(() => _filterStatus = null);
                Navigator.pop(context);
              },
            ),
            ...BusinessStatus.values.map((status) => ListTile(
                  leading: Icon(_getStatusIcon(status),
                      color: AppColors.textSecondary, size: 20),
                  title: Text(_getStatusTitle(status)),
                  selected: _filterStatus == status,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppColors.radiusM),
                  ),
                  onTap: () {
                    setState(() => _filterStatus = status);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _exportPipeline(Map<BusinessStatus, List<Business>> pipeline) {
    Haptics.medium();
    final buffer = StringBuffer();
    buffer.writeln('Name,Status,Address,Rating,Audit Score,Deal Value');

    for (final entry in pipeline.entries) {
      for (final b in entry.value) {
        final name = b.name.replaceAll(',', ' ');
        final address = (b.address ?? '').replaceAll(',', ' ');
        buffer.writeln(
            '$name,${_getStatusTitle(entry.key)},$address,${b.rating ?? ''},${b.auditScore ?? ''},${b.dealValue ?? ''}');
      }
    }

    final csv = buffer.toString();
    Share.share(csv, subject: 'LeadForge Pipeline Export');
  }

  IconData _getStatusIcon(BusinessStatus status) {
    switch (status) {
      case BusinessStatus.found:
        return Icons.travel_explore_rounded;
      case BusinessStatus.audited:
        return Icons.query_stats_rounded;
      case BusinessStatus.demoCreated:
        return Icons.web_rounded;
      case BusinessStatus.contacted:
        return Icons.send_rounded;
      case BusinessStatus.interested:
        return Icons.thumb_up_rounded;
      case BusinessStatus.closed:
        return Icons.handshake_rounded;
      case BusinessStatus.lost:
        return Icons.block_rounded;
    }
  }

  Future<void> _moveBusinessToStatus(
    Business business,
    BusinessStatus newStatus,
  ) async {
    Haptics.medium();
    try {
      await ref
          .read(businessesProvider.notifier)
          .updateStatus(business.id, newStatus);

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusXL),
        ),
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
        await ref
            .read(businessesProvider.notifier)
            .deleteBusiness(business.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Business removed'),
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
        centerTitle: true,
        title: Text(
          _filterStatus != null
              ? 'Pipeline — ${_getStatusTitle(_filterStatus!)}'
              : 'Pipeline',
          style: AppTypography.titleMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _showFilterSheet,
            child: Text(
              _filterStatus != null ? 'Filtered' : 'Filter',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share, size: 20, color: AppColors.textTertiary),
            onPressed: () {
              final data = ref.read(pipelineProvider).valueOrNull;
              if (data != null) _exportPipeline(data);
            },
            tooltip: 'Export CSV',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textTertiary),
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
              padding: const EdgeInsets.all(20),
              children: [
                if (_filterStatus == null ||
                    _filterStatus == BusinessStatus.found)
                  _buildSection(
                    'Found',
                    BusinessStatus.found,
                    pipeline[BusinessStatus.found] ?? [],
                    AppColors.textTertiary,
                  ),
                if (_filterStatus == null ||
                    _filterStatus == BusinessStatus.audited)
                  _buildSection(
                    'Audited',
                    BusinessStatus.audited,
                    pipeline[BusinessStatus.audited] ?? [],
                    AppColors.secondary,
                  ),
                if (_filterStatus == null ||
                    _filterStatus == BusinessStatus.demoCreated)
                  _buildSection(
                    'Demo Created',
                    BusinessStatus.demoCreated,
                    pipeline[BusinessStatus.demoCreated] ?? [],
                    AppColors.primary,
                  ),
                if (_filterStatus == null ||
                    _filterStatus == BusinessStatus.contacted)
                  _buildSection(
                    'Contacted',
                    BusinessStatus.contacted,
                    pipeline[BusinessStatus.contacted] ?? [],
                    AppColors.success,
                  ),
                if (_filterStatus == null ||
                    _filterStatus == BusinessStatus.interested)
                  _buildSection(
                    'Interested',
                    BusinessStatus.interested,
                    pipeline[BusinessStatus.interested] ?? [],
                    AppColors.info,
                  ),
                if (_filterStatus == null ||
                    _filterStatus == BusinessStatus.closed)
                  _buildSection(
                    'Closed',
                    BusinessStatus.closed,
                    pipeline[BusinessStatus.closed] ?? [],
                    AppColors.success,
                  ),
                if (_filterStatus == null ||
                    _filterStatus == BusinessStatus.lost)
                  _buildSection(
                    'Lost',
                    BusinessStatus.lost,
                    pipeline[BusinessStatus.lost] ?? [],
                    AppColors.danger,
                  ),
              ],
            ),
          );
        },
        loading: () => const PipelineSkeleton(),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppColors.radiusXL),
        ),
        clipBehavior: Clip.antiAlias,
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
                    Icon(
                      _getStatusIcon(status),
                      color: color,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(6),
                      ),
                      child: Text(
                        businesses.length.toString(),
                        style: AppTypography.mono.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.textTertiary,
                      size: 20,
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
                        size: 36,
                        color: AppColors.textTertiary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No businesses in this stage',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                ...businesses.map((business) => _DraggableBusinessCard(
                      business: business,
                      currentStatus: status,
                      onMoveToStatus: (newStatus) =>
                          _moveBusinessToStatus(business, newStatus),
                      onDelete: () => _deleteBusiness(business),
                      onTap: () =>
                          context.push('/business/${business.id}'),
                      stageColor: color,
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: Text(
                    'Swipe right to advance, left to remove',
                    textAlign: TextAlign.center,
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
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
  final Color stageColor;

  const _DraggableBusinessCard({
    required this.business,
    required this.currentStatus,
    required this.onMoveToStatus,
    required this.onDelete,
    required this.onTap,
    required this.stageColor,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Dot indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: stageColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (business.shortAddress != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        business.shortAddress!,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
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
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.scoreColor(business.auditScore!)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    business.auditScore.toString(),
                    style: AppTypography.mono.copyWith(
                      color:
                          AppColors.scoreColor(business.auditScore!),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],

              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
      IconData icon, Color color, Alignment alignment) {
    return Container(
      color: color.withValues(alpha: 0.08),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(icon, color: color, size: 28),
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
