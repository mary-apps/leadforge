import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../providers/businesses_provider.dart';
import '../../utils/haptics.dart';
import '../../widgets/ios_toast.dart';
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
        IosToast.show(context, 'Moved to ${_getStatusTitle(newStatus)}');
      }
    } catch (e) {
      Haptics.heavy();
      if (mounted) {
        IosToast.show(context, 'Error: $e');
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
          IosToast.show(context, 'Business removed');
        }
      } catch (e) {
        if (mounted) {
          IosToast.show(context, 'Error: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pipelineAsync = ref.watch(pipelineProvider);

    return CupertinoPageScaffold(
      backgroundColor:
          CupertinoDynamicColor.resolve(AppColors.background, context),
      child: pipelineAsync.when(
        data: (pipeline) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Custom title header
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppConstants.pageHorizontal,
                      16,
                      AppConstants.pageHorizontal,
                      AppConstants.itemGap,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Pipeline',
                            style: AppTypography.displayLarge(context),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 0,
                          onPressed: _showFilterSheet,
                          child: Text(
                            _filterStatus != null ? 'Filtered' : 'Filter',
                            style:
                                AppTypography.titleMedium(context).copyWith(
                              color: CupertinoDynamicColor.resolve(
                                _filterStatus != null
                                    ? AppColors.accent
                                    : AppColors.textSecondary,
                                context,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 0,
                          onPressed: () {
                            final data =
                                ref.read(pipelineProvider).valueOrNull;
                            if (data != null) _exportPipeline(data);
                          },
                          child: Icon(
                            CupertinoIcons.share,
                            size: 20,
                            color: CupertinoDynamicColor.resolve(
                                AppColors.textSecondary, context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 0,
                          onPressed: () {
                            Haptics.light();
                            ref.read(businessesProvider.notifier).load();
                          },
                          child: Icon(
                            CupertinoIcons.refresh,
                            size: 20,
                            color: CupertinoDynamicColor.resolve(
                                AppColors.textSecondary, context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_filterStatus != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppConstants.pageHorizontal,
                      0,
                      AppConstants.pageHorizontal,
                      AppConstants.itemGap,
                    ),
                    child: Text(
                      'SHOWING: ${_getStatusTitle(_filterStatus!).toUpperCase()}',
                      style: AppTypography.labelSmall(context).copyWith(
                        color: CupertinoDynamicColor.resolve(
                            AppColors.textSecondary, context),
                      ),
                    ),
                  ),
                ),

              // Pipeline sections
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppConstants.pageHorizontal,
                  0,
                  AppConstants.pageHorizontal,
                  AppConstants.sectionGap,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (_filterStatus == null ||
                        _filterStatus == BusinessStatus.found)
                      _buildSection(
                        'Found',
                        BusinessStatus.found,
                        pipeline[BusinessStatus.found] ?? [],
                      ),
                    if (_filterStatus == null ||
                        _filterStatus == BusinessStatus.audited)
                      _buildSection(
                        'Audited',
                        BusinessStatus.audited,
                        pipeline[BusinessStatus.audited] ?? [],
                      ),
                    if (_filterStatus == null ||
                        _filterStatus == BusinessStatus.demoCreated)
                      _buildSection(
                        'Demo Created',
                        BusinessStatus.demoCreated,
                        pipeline[BusinessStatus.demoCreated] ?? [],
                      ),
                    if (_filterStatus == null ||
                        _filterStatus == BusinessStatus.contacted)
                      _buildSection(
                        'Contacted',
                        BusinessStatus.contacted,
                        pipeline[BusinessStatus.contacted] ?? [],
                      ),
                    if (_filterStatus == null ||
                        _filterStatus == BusinessStatus.interested)
                      _buildSection(
                        'Interested',
                        BusinessStatus.interested,
                        pipeline[BusinessStatus.interested] ?? [],
                      ),
                    if (_filterStatus == null ||
                        _filterStatus == BusinessStatus.closed)
                      _buildSection(
                        'Closed',
                        BusinessStatus.closed,
                        pipeline[BusinessStatus.closed] ?? [],
                      ),
                    if (_filterStatus == null ||
                        _filterStatus == BusinessStatus.lost)
                      _buildSection(
                        'Lost',
                        BusinessStatus.lost,
                        pipeline[BusinessStatus.lost] ?? [],
                      ),
                  ]),
                ),
              ),
            ],
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
  ) {
    final isExpanded = _expandedSections[status] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        GestureDetector(
          onTap: () {
            setState(() {
              _expandedSections[status] = !isExpanded;
            });
            Haptics.light();
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: AppTypography.labelSmall(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                          AppColors.textTertiary, context),
                    ),
                  ),
                ),
                Text(
                  businesses.length.toString(),
                  style: AppTypography.labelLarge(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.textTertiary, context),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: AppConstants.standardAnimation,
                  child: Icon(
                    CupertinoIcons.chevron_down,
                    color: CupertinoDynamicColor.resolve(
                        AppColors.textTertiary, context),
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Divider below header
        Container(
          height: 0.5,
          color: CupertinoDynamicColor.resolve(AppColors.divider, context),
        ),

        if (isExpanded) ...[
          if (businesses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No businesses in this stage',
                  style: AppTypography.labelLarge(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.textTertiary, context),
                  ),
                ),
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
                    onTap: () => context.push('/business/${business.id}'),
                  ),
                  if (index < businesses.length - 1)
                    Container(
                      height: 0.5,
                      color: CupertinoDynamicColor.resolve(
                          AppColors.divider, context),
                    ),
                ],
              );
            }),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Center(
                child: Text(
                  'Swipe right to advance, left to remove',
                  style: AppTypography.chip(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.textTertiary, context),
                  ),
                ),
              ),
            ),
          ],
        ],

        // Bottom spacing between sections
        SizedBox(height: AppConstants.itemGap),
      ],
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

  const _DraggableBusinessCard({
    required this.business,
    required this.currentStatus,
    required this.onMoveToStatus,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<_DraggableBusinessCard> createState() =>
      _DraggableBusinessCardState();
}

class _DraggableBusinessCardState extends State<_DraggableBusinessCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final resolvedScoreGood =
        CupertinoDynamicColor.resolve(AppColors.scoreGood, context);
    final resolvedScoreBad =
        CupertinoDynamicColor.resolve(AppColors.scoreBad, context);

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
      background: Container(
        color: resolvedScoreGood.withValues(alpha: 0.08),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Icon(CupertinoIcons.arrow_right,
            color: resolvedScoreGood, size: 28),
      ),
      secondaryBackground: Container(
        color: resolvedScoreBad.withValues(alpha: 0.08),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child:
            Icon(CupertinoIcons.delete, color: resolvedScoreBad, size: 28),
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
          duration: AppConstants.quickAnimation,
          color: _isPressed
              ? CupertinoDynamicColor.resolve(AppColors.divider, context)
                  .withValues(alpha: 0.5)
              : const Color(0x00000000),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          child: Row(
            children: [
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.business.name,
                      style: AppTypography.titleMedium(context),
                    ),
                    if (widget.business.shortAddress != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.business.shortAddress!,
                        style: AppTypography.labelLarge(context),
                      ),
                    ],
                  ],
                ),
              ),

              if (widget.business.auditScore != null) ...[
                const SizedBox(width: 8),
                Text(
                  widget.business.auditScore.toString(),
                  style: AppTypography.titleMedium(context).copyWith(
                    fontWeight: FontWeight.w800,
                    color: CupertinoDynamicColor.resolve(
                      AppColors.scoreColor(widget.business.auditScore!),
                      context,
                    ),
                  ),
                ),
              ],

              const SizedBox(width: 6),
              Icon(
                CupertinoIcons.chevron_forward,
                color: CupertinoDynamicColor.resolve(
                    AppColors.textTertiary, context),
                size: 18,
              ),
            ],
          ),
        ),
      ),
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
