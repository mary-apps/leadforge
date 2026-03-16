import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../providers/businesses_provider.dart';
import '../../utils/haptics.dart';
import '../../widgets/ios_toast.dart';
import '../../widgets/pulse_dot.dart';
import '../../widgets/shimmer_text.dart';
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
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Filter by Status'),
        actions: [
          CupertinoActionSheetAction(
            isDefaultAction: _filterStatus == null,
            onPressed: () {
              setState(() => _filterStatus = null);
              Navigator.pop(context);
            },
            child: const Text('All Stages'),
          ),
          ...BusinessStatus.values.map((status) => CupertinoActionSheetAction(
                isDefaultAction: _filterStatus == status,
                onPressed: () {
                  setState(() => _filterStatus = status);
                  Navigator.pop(context);
                },
                child: Text(_getStatusTitle(status)),
              )),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
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
        IosToast.show(context, 'Moved to ${_getStatusTitle(newStatus)}', icon: CupertinoIcons.check_mark);
      }
    } catch (e) {
      Haptics.heavy();
      if (mounted) {
        IosToast.show(context, 'Error: $e', icon: CupertinoIcons.exclamationmark_triangle);
      }
    }
  }

  Future<void> _deleteBusiness(Business business) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Business'),
        content: Text('Remove ${business.name} from pipeline?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
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
          IosToast.show(context, 'Business removed', icon: CupertinoIcons.check_mark);
        }
      } catch (e) {
        if (mounted) {
          IosToast.show(context, 'Error: $e', icon: CupertinoIcons.exclamationmark_triangle);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pipelineAsync = ref.watch(pipelineProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: pipelineAsync.when(
        data: (pipeline) {
          return SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // iOS large title header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: GradientText(
                                text: 'Pipeline',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.37,
                                  height: 1.2,
                                ),
                                colors: [AppColors.primary, AppColors.primaryLight],
                              ),
                            ),
                            GestureDetector(
                              onTap: _showFilterSheet,
                              child: Text(
                                _filterStatus != null ? 'Filtered' : 'Filter',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                final data =
                                    ref.read(pipelineProvider).valueOrNull;
                                if (data != null) _exportPipeline(data);
                              },
                              child: const Icon(
                                Icons.ios_share,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                Haptics.light();
                                ref.read(businessesProvider.notifier).load();
                              },
                              child: const Icon(
                                Icons.refresh,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        if (_filterStatus != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _getStatusTitle(_filterStatus!),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Pull-to-refresh + pipeline sections
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
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
                    ]),
                  ),
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
          borderRadius: BorderRadius.circular(AppColors.radiusL),
          border: businesses.isNotEmpty
              ? Border.all(
                  color: color.withValues(alpha: 0.1),
                  width: 0.5,
                )
              : null,
          boxShadow: businesses.isNotEmpty
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.04),
                    blurRadius: 12,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedSections[status] = !isExpanded;
                });
                Haptics.light();
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    PulseDot(
                      color: color,
                      size: 8,
                      pulse: businesses.isNotEmpty,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        businesses.length.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              Container(
                height: 0.5,
                color: AppColors.divider,
              ),
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
                      const Text(
                        'No businesses in this stage',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                ...List.generate(businesses.length, (index) {
                  final business = businesses[index];
                  return Column(
                    children: [
                      _DraggableBusinessCard(
                        business: business,
                        currentStatus: status,
                        onMoveToStatus: (newStatus) =>
                            _moveBusinessToStatus(business, newStatus),
                        onDelete: () => _deleteBusiness(business),
                        onTap: () =>
                            context.push('/business/${business.id}'),
                        stageColor: color,
                      ),
                      if (index < businesses.length - 1)
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 0.5,
                            color: AppColors.divider,
                          ),
                        ),
                    ],
                  );
                }),
                const Padding(
                  padding: EdgeInsets.only(top: 4, bottom: 12),
                  child: Text(
                    'Swipe right to advance, left to remove',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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

/// Draggable and swipeable business card with tap highlight
class _DraggableBusinessCard extends StatefulWidget {
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
  State<_DraggableBusinessCard> createState() =>
      _DraggableBusinessCardState();
}

class _DraggableBusinessCardState extends State<_DraggableBusinessCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.business.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        Haptics.light();

        if (direction == DismissDirection.startToEnd) {
          // Swipe right: Move to next stage
          final nextStatus = _getNextStatus(widget.currentStatus);
          if (nextStatus != null) {
            widget.onMoveToStatus(nextStatus);
          }
          return false; // Don't actually dismiss
        } else {
          // Swipe left: Delete
          Haptics.heavy();
          widget.onDelete();
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
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          Haptics.light();
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: _isPressed
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Dot indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.stageColor,
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
                      widget.business.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (widget.business.shortAddress != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.business.shortAddress!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (widget.business.auditScore != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.scoreGradient(widget.business.auditScore!),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.scoreColor(widget.business.auditScore!)
                            .withValues(alpha: 0.2),
                        blurRadius: 6,
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.business.auditScore.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.background,
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
