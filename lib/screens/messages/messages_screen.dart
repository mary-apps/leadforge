import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../providers/businesses_provider.dart';
import '../../widgets/skeleton_loaders.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessesProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Activity',
          style: AppTypography.titleMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: businessesAsync.when(
        data: (businesses) {
          if (businesses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 48,
                    color: AppColors.textTertiary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No activity yet',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your recent actions will appear here',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort by most recently updated
          final sorted = List<Business>.from(businesses)
            ..sort((a, b) {
              final aDate = a.updatedAt ?? a.createdAt;
              final bDate = b.updatedAt ?? b.createdAt;
              return bDate.compareTo(aDate);
            });

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final business = sorted[index];
              return _ActivityTile(
                business: business,
                index: index,
                onTap: () => context.push('/business/${business.id}'),
              );
            },
          );
        },
        loading: () => const ActivitySkeleton(),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Activity tile with press-scale feedback + staggered entrance
// ---------------------------------------------------------------------------

class _ActivityTile extends StatefulWidget {
  final Business business;
  final int index;
  final VoidCallback onTap;

  const _ActivityTile({
    required this.business,
    required this.index,
    required this.onTap,
  });

  @override
  State<_ActivityTile> createState() => _ActivityTileState();
}

class _ActivityTileState extends State<_ActivityTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final business = widget.business;
    final timeAgo = _timeAgo(business.updatedAt ?? business.createdAt);

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
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  color: business.statusColor.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppColors.radiusM),
                ),
                alignment: Alignment.center,
                child: Icon(business.statusIcon,
                    color: business.statusColor, size: 18),
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
                      '${_statusLabel(business.status)} · $timeAgo',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 18,
              ),
            ],
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
          begin: 0.03,
          delay: Duration(milliseconds: 50 * widget.index),
          duration: 200.ms,
          curve: Curves.easeOut,
        );
  }

  static String _statusLabel(BusinessStatus status) {
    switch (status) {
      case BusinessStatus.found:
        return 'Found';
      case BusinessStatus.audited:
        return 'Audited';
      case BusinessStatus.demoCreated:
        return 'Demo created';
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

  static String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
