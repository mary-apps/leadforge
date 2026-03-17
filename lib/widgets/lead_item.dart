import 'package:flutter/cupertino.dart';
import '../config/theme.dart';
import '../models/business.dart';

class LeadItem extends StatelessWidget {
  final Business business;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool showDivider;

  const LeadItem({
    super.key,
    required this.business,
    this.onTap,
    this.showChevron = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.itemGap),
        decoration: showDivider
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoDynamicColor.resolve(AppColors.divider, context),
                    width: 1,
                  ),
                ),
              )
            : null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: AppTypography.titleMedium(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.contentGap),
                  Text(
                    business.shortAddress ?? '',
                    style: AppTypography.labelLarge(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildTag(context, business.statusLabel),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (business.auditScore != null)
              Text(
                '${business.auditScore}',
                style: AppTypography.labelLarge(context).copyWith(
                  fontWeight: FontWeight.w700,
                  color: CupertinoDynamicColor.resolve(
                    AppColors.scoreColor(business.auditScore!),
                    context,
                  ),
                ),
              ),
            if (showChevron) ...[
              const SizedBox(width: 8),
              Text(
                '\u2192',
                style: TextStyle(
                  fontSize: 18,
                  color: CupertinoDynamicColor.resolve(AppColors.textTertiary, context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(AppColors.chipInactive, context),
        borderRadius: BorderRadius.circular(AppColors.radiusS),
      ),
      child: Text(
        label,
        style: AppTypography.chip(context).copyWith(fontSize: 10),
      ),
    );
  }
}
