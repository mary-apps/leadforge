import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';
import '../models/business.dart';

class DigestItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DigestItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class DailyDigest extends StatelessWidget {
  final List<Business> businesses;
  final void Function(String route) onNavigate;

  const DailyDigest({
    super.key,
    required this.businesses,
    required this.onNavigate,
  });

  List<DigestItem> _computeDigest() {
    final now = DateTime.now();
    final items = <DigestItem>[];

    final needsAudit = businesses
        .where((b) => b.status == BusinessStatus.found && !b.isAudited)
        .toList();
    if (needsAudit.isNotEmpty) {
      items.add(DigestItem(
        icon: CupertinoIcons.search,
        title: '${needsAudit.length} lead${needsAudit.length == 1 ? '' : 's'} need audit',
        subtitle: 'Tap to review',
        onTap: () => onNavigate('/pipeline?filter=found'),
      ));
    }

    final needsDemo = businesses
        .where((b) => b.status == BusinessStatus.audited)
        .toList();
    if (needsDemo.isNotEmpty) {
      final first = needsDemo.last;
      items.add(DigestItem(
        icon: CupertinoIcons.globe,
        title: '${needsDemo.length} demo${needsDemo.length == 1 ? '' : 's'} ready to create',
        subtitle: 'Start with ${first.name}',
        onTap: () => onNavigate('/business/${first.id}/build-demo'),
      ));
    }

    final needsOutreach = businesses
        .where((b) => b.status == BusinessStatus.demoCreated)
        .toList();
    if (needsOutreach.isNotEmpty) {
      final first = needsOutreach.last;
      items.add(DigestItem(
        icon: CupertinoIcons.paperplane,
        title: '${needsOutreach.length} demo${needsOutreach.length == 1 ? '' : 's'} ready to share',
        subtitle: 'Send outreach for ${first.name}',
        onTap: () => onNavigate('/business/${first.id}/outreach'),
      ));
    }

    final staleContacted = businesses.where((b) {
      if (b.status != BusinessStatus.contacted) return false;
      final ref = b.updatedAt ?? b.createdAt ?? now;
      return now.difference(ref).inHours >= 72;
    }).toList();
    if (staleContacted.isNotEmpty) {
      final first = staleContacted.last;
      items.add(DigestItem(
        icon: CupertinoIcons.clock,
        title: '${staleContacted.length} follow-up${staleContacted.length == 1 ? '' : 's'} overdue',
        subtitle: 'Contacted ${_daysAgo(first.updatedAt ?? first.createdAt ?? now)}',
        onTap: () => onNavigate('/business/${first.id}'),
      ));
    }

    return items;
  }

  static String _daysAgo(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'today';
    if (days == 1) return 'yesterday';
    return '$days days ago';
  }

  @override
  Widget build(BuildContext context) {
    final items = _computeDigest();

    if (items.isEmpty) {
      return GestureDetector(
        onTap: () => onNavigate('/scout'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: CupertinoDynamicColor.resolve(AppColors.divider, context),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(CupertinoIcons.checkmark_seal,
                  size: 18,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.scoreGood, context)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'All caught up! Search for new leads',
                  style: AppTypography.bodyLarge(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.textSecondary, context),
                  ),
                ),
              ),
              Icon(CupertinoIcons.chevron_right,
                  size: 14,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.textTertiary, context)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TO DO TODAY',
          style: AppTypography.labelSmall(context).copyWith(
            color: CupertinoDynamicColor.resolve(
                AppColors.textSecondary, context),
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(items.length, (i) {
          final item = items[i];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: item.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: i < items.length - 1
                  ? BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoDynamicColor.resolve(
                              AppColors.divider, context),
                          width: 0.5,
                        ),
                      ),
                    )
                  : null,
              child: Row(
                children: [
                  Icon(item.icon,
                      size: 18,
                      color: CupertinoDynamicColor.resolve(
                          AppColors.accent, context)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: AppTypography.titleMedium(context)),
                        const SizedBox(height: 2),
                        Text(item.subtitle,
                            style: AppTypography.labelLarge(context)),
                      ],
                    ),
                  ),
                  Icon(CupertinoIcons.chevron_right,
                      size: 14,
                      color: CupertinoDynamicColor.resolve(
                          AppColors.textTertiary, context)),
                ],
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: 50 * i))
              .fadeIn(duration: AppConstants.standardAnimation)
              .slideX(
                  begin: -0.03,
                  duration: AppConstants.standardAnimation +
                      const Duration(milliseconds: 100),
                  curve: Curves.easeOutCubic);
        }),
      ],
    );
  }
}
