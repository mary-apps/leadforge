import 'package:flutter/cupertino.dart';

import '../config/theme.dart';
import '../models/business.dart';

class AuditContext extends StatelessWidget {
  final Business business;

  const AuditContext({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final score = business.auditScore ?? 0;
    final breakdown = business.auditBreakdown;

    final checks = <(bool pass, String label)>[];

    // Always show these
    checks.add((business.website != null, business.website != null ? 'Has website' : 'No website'));
    checks.add((business.rating != null, business.rating != null ? 'Listed on Google' : 'Not on Google'));

    // From breakdown if available
    if (breakdown != null) {
      final mobile = _extractScore(breakdown, 'mobile');
      if (mobile != null) {
        checks.add((mobile >= 50, mobile >= 50 ? 'Mobile-friendly' : 'Poor mobile experience'));
      }
      final seo = _extractScore(breakdown, 'seo');
      if (seo != null) {
        checks.add((seo >= 50, seo >= 50 ? 'Good SEO' : 'Missing SEO basics'));
      }
      final design = _extractScore(breakdown, 'design');
      if (design != null) {
        checks.add((design >= 50, design >= 50 ? 'Modern design' : 'Outdated design'));
      }
    }

    final tip = score < 40
        ? 'This business has a weak online presence — they\'re likely to need your services. Strong lead.'
        : score < 70
            ? 'Room for improvement. An audit report could show them what needs improvement.'
            : 'Decent online presence. Focus your pitch on specific gaps.';

    final goodColor = CupertinoDynamicColor.resolve(AppColors.scoreGood, context);
    final badColor = CupertinoDynamicColor.resolve(AppColors.scoreBad, context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHAT THIS MEANS',
          style: AppTypography.labelSmall(context).copyWith(
            color: CupertinoDynamicColor.resolve(AppColors.textSecondary, context),
          ),
        ),
        const SizedBox(height: 10),
        ...checks.map((check) {
          final (pass, label) = check;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(
                  pass ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
                  size: 16,
                  color: pass ? goodColor : badColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodyMedium(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                          pass ? AppColors.textPrimary : AppColors.textSecondary, context),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(AppColors.accent, context)
                .withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppColors.radiusM),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                CupertinoIcons.lightbulb,
                size: 16,
                color: CupertinoDynamicColor.resolve(AppColors.scoreMid, context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip,
                  style: AppTypography.bodyMedium(context).copyWith(
                    color: CupertinoDynamicColor.resolve(AppColors.textSecondary, context),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int? _extractScore(Map<String, dynamic> breakdown, String key) {
    final value = breakdown[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is Map) {
      final score = value['score'];
      if (score is int) return score;
      if (score is num) return score.toInt();
    }
    return null;
  }
}
