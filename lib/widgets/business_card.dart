import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/business.dart';

class BusinessCard extends StatelessWidget {
  final Business business;
  final VoidCallback? onTap;

  const BusinessCard({
    super.key,
    required this.business,
    this.onTap,
  });

  Color _statusColor() {
    switch (business.status) {
      case BusinessStatus.found:
        return AppColors.textTertiary;
      case BusinessStatus.audited:
        return AppColors.secondary;
      case BusinessStatus.demoCreated:
        return AppColors.primary;
      case BusinessStatus.contacted:
      case BusinessStatus.interested:
        return AppColors.success;
      case BusinessStatus.closed:
        return AppColors.success;
      case BusinessStatus.lost:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: _statusColor(), width: 4),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(business.statusBadge, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Hero(
                      tag: 'business-name-${business.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          business.name,
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  if (business.auditScore != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.scoreColor(business.auditScore!)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.scoreColor(business.auditScore!),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        business.auditScore.toString(),
                        style: AppTypography.mono.copyWith(
                          color: AppColors.scoreColor(business.auditScore!),
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
              
              if (business.address != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        business.shortAddress ?? business.address!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              if (business.rating != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${business.rating} (${business.reviewsCount} reviews)',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ],
              
              if (business.website != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.language,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        business.website!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
