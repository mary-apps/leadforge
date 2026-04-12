import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../providers/businesses_provider.dart';
import '../../utils/haptics.dart';
import '../../widgets/error_state.dart';
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
  final Map<BusinessStatus, bool> _expandedSections = {};
  bool _needsActionExpanded = true;

  BusinessStatus? _filterStatus;
  bool _sectionsInitialized = false;

  // Memoization cache for _computeNeedsAction — recalculated only when
  // the pipeline map identity changes.
  Map<BusinessStatus, List<Business>>? _cachedPipeline;
  List<(Business, String)>? _cachedNeedsAction;

  List<(Business, String)> _getNeedsAction(
      Map<BusinessStatus, List<Business>> pipeline) {
    if (!identical(pipeline, _cachedPipeline) || _cachedNeedsAction == null) {
      _cachedPipeline = pipeline;
      _cachedNeedsAction = _computeNeedsAction(pipeline);
    }
    return _cachedNeedsAction!;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sharedFilter = ref.read(pipelineFilterProvider);
      if (sharedFilter != null) {
        setState(() => _filterStatus = sharedFilter);
        ref.read(pipelineFilterProvider.notifier).state = null;
      }
    });
  }

  void _initExpandedSections(Map<BusinessStatus, List<Business>> pipeline) {
    if (_sectionsInitialized) return;
    _sectionsInitialized = true;

    // Find the stage with the most leads
    BusinessStatus? busiestStage;
    int maxCount = 0;
    for (final status in BusinessStatus.values) {
      final count = (pipeline[status] ?? []).length;
      if (count > maxCount) {
        maxCount = count;
        busiestStage = status;
      }
    }

    // All collapsed except the busiest stage
    for (final status in BusinessStatus.values) {
      _expandedSections[status] = status == busiestStage;
    }
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
          _initExpandedSections(pipeline);
          final needsAction = _getNeedsAction(pipeline);
          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  await ref.read(businessesProvider.notifier).load();
                },
              ),
              // Title header (export only — filter & refresh removed)
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
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
                          onPressed: () {
                            final data =
                                ref.read(pipelineProvider).valueOrNull;
                            if (data != null) _exportPipeline(data);
                          }, minimumSize: const Size(0, 0),
                          child: Icon(
                            CupertinoIcons.share,
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

              // Funnel summary bar
              SliverToBoxAdapter(
                child: _PipelineFunnelBar(
                  pipeline: pipeline,
                  activeFilter: _filterStatus,
                  onTap: (status) {
                    Haptics.light();
                    setState(() {
                      _filterStatus =
                          _filterStatus == status ? null : status;
                    });
                  },
                  getTitle: _getStatusTitle,
                ),
              ),

              if (needsAction.isNotEmpty && _filterStatus == null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pageHorizontal,
                      AppConstants.itemGap,
                      AppConstants.pageHorizontal,
                      AppConstants.itemGap,
                    ),
                    child: _buildNeedsActionSection(needsAction),
                  ),
                ),

              // Pipeline sections
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.pageHorizontal,
                  0,
                  AppConstants.pageHorizontal,
                  AppConstants.sectionGap,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    for (final status in BusinessStatus.values)
                      if (_filterStatus == status ||
                          (_filterStatus == null &&
                              (pipeline[status] ?? []).isNotEmpty))
                        _buildSection(
                          _getStatusTitle(status),
                          status,
                          pipeline[status] ?? [],
                        ),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const PipelineSkeleton(),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.read(businessesProvider.notifier).load(),
        ),
      ),
    );
  }

  List<(Business, String)> _computeNeedsAction(
      Map<BusinessStatus, List<Business>> pipeline) {
    final now = DateTime.now();
    final result = <(Business, String)>[];

    for (final b in pipeline[BusinessStatus.found] ?? []) {
      if (now.difference(b.createdAt ?? now).inHours >= 24) {
        result.add((b, 'Audit this lead'));
      }
    }
    for (final b in pipeline[BusinessStatus.audited] ?? []) {
      final ts = b.auditedAt ?? b.updatedAt ?? b.createdAt ?? now;
      if (now.difference(ts).inHours >= 48) {
        result.add((b, 'Create demo'));
      }
    }
    for (final b in pipeline[BusinessStatus.demoCreated] ?? []) {
      final ts = b.updatedAt ?? b.createdAt ?? now;
      if (now.difference(ts).inHours >= 48) {
        result.add((b, 'Send outreach'));
      }
    }
    for (final b in pipeline[BusinessStatus.contacted] ?? []) {
      final ts = b.updatedAt ?? b.createdAt ?? now;
      if (now.difference(ts).inHours >= 72) {
        result.add((b, 'Follow up'));
      }
    }
    return result;
  }

  Widget _buildNeedsActionSection(List<(Business, String)> items) {
    final orangeColor =
        CupertinoDynamicColor.resolve(AppColors.scoreMid, context);
    final orangeBg =
        CupertinoDynamicColor.resolve(AppColors.scoreMidBg, context);
    final previewItems = items.take(2).toList();
    final remaining = items.length - previewItems.length;

    return Container(
      decoration: BoxDecoration(
        color: orangeBg,
        borderRadius: BorderRadius.circular(AppColors.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — tappable to collapse
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Haptics.light();
              setState(() => _needsActionExpanded = !_needsActionExpanded);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  Text(
                    '\u26A0 ',
                    style: TextStyle(fontSize: 14, color: orangeColor),
                  ),
                  Expanded(
                    child: Text(
                      '${items.length} lead${items.length == 1 ? '' : 's'} need action',
                      style: AppTypography.titleMedium(context).copyWith(
                        color: orangeColor,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _needsActionExpanded ? 0.5 : 0.0,
                    duration: AppConstants.standardAnimation,
                    child: Icon(
                      CupertinoIcons.chevron_down,
                      color: orangeColor,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_needsActionExpanded) ...[
            // Preview items (max 2)
            ...previewItems.map((item) {
              final (business, action) = item;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push('/business/${business.id}'),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${business.name} — $action',
                          style: AppTypography.labelLarge(context).copyWith(
                            color: orangeColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(CupertinoIcons.chevron_right,
                          size: 12, color: orangeColor),
                    ],
                  ),
                ),
              );
            }),
            // "+N more" and "See All"
            if (remaining > 0)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // Navigate to first stagnant lead
                  context.push('/business/${items.first.$1.id}');
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '+$remaining more',
                          style: AppTypography.labelLarge(context).copyWith(
                            color: orangeColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      Text(
                        'See All \u2192',
                        style: AppTypography.chip(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: orangeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ],
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
                          AppColors.textSecondary, context),
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
          ],
        ],

        // Bottom spacing between sections
        const SizedBox(height: AppConstants.itemGap),
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

/// Horizontal scrollable row of pill-shaped stage counts
class _PipelineFunnelBar extends StatelessWidget {
  final Map<BusinessStatus, List<Business>> pipeline;
  final BusinessStatus? activeFilter;
  final ValueChanged<BusinessStatus> onTap;
  final String Function(BusinessStatus) getTitle;

  const _PipelineFunnelBar({
    required this.pipeline,
    required this.activeFilter,
    required this.onTap,
    required this.getTitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppConstants.pageHorizontal),
        itemCount: BusinessStatus.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = BusinessStatus.values[index];
          final count = (pipeline[status] ?? []).length;
          final isActive = activeFilter == status;
          final isEmpty = count == 0;

          return GestureDetector(
            onTap: () => onTap(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  isActive ? AppColors.chipActive : AppColors.chipInactive,
                  context,
                ),
                borderRadius: BorderRadius.circular(AppColors.radiusXL),
              ),
              child: Text(
                '${getTitle(status)} $count',
                style: AppTypography.chip(context).copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: CupertinoDynamicColor.resolve(
                    isActive
                        ? AppColors.chipActiveFg
                        : isEmpty
                            ? AppColors.textTertiary
                            : AppColors.textSecondary,
                    context,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
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
