import 'package:flutter/cupertino.dart';

import '../config/theme.dart';
import '../models/audit_result.dart';
import '../models/business.dart';

class AuditContext extends StatelessWidget {
  final Business business;

  const AuditContext({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final score = business.auditScore ?? 0;
    final breakdown = business.auditBreakdown;

    final checks = <(bool pass, String label, AuditFactor? factor)>[];

    // Always show these
    checks.add((
      business.website != null,
      business.website != null ? 'Has website' : 'No website',
      null,
    ));
    checks.add((
      business.rating != null,
      business.rating != null ? 'Listed on Google' : 'Not on Google',
      null,
    ));

    // From breakdown if available — parse into AuditFactor objects
    if (breakdown != null) {
      for (final entry in breakdown.entries) {
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          try {
            final factor = AuditFactor.fromJson(value);
            checks.add((factor.passed, factor.label, factor));
          } catch (_) {
            // Legacy format: just extract score
            final impactVal = value['impact'] ?? value['score'];
            final impact = impactVal is num ? impactVal.toInt() : 0;
            final passed = impact >= 10;
            final label = value['label'] as String? ?? entry.key;
            checks.add((passed, label, null));
          }
        }
      }
    }

    final tip = score < 40
        ? 'This business has a weak online presence — they\'re likely to need your services. Strong lead.'
        : score < 70
            ? 'Room for improvement. An audit report could show them what needs improvement.'
            : 'Decent online presence. Focus your pitch on specific gaps.';

    final goodColor =
        CupertinoDynamicColor.resolve(AppColors.scoreGood, context);
    final badColor =
        CupertinoDynamicColor.resolve(AppColors.scoreBad, context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHAT THIS MEANS',
          style: AppTypography.labelSmall(context).copyWith(
            color: CupertinoDynamicColor.resolve(
                AppColors.textSecondary, context),
          ),
        ),
        const SizedBox(height: 10),
        ...checks.map((check) {
          final (pass, label, factor) = check;
          return _FactorRow(
            pass: pass,
            label: label,
            factor: factor,
            goodColor: goodColor,
            badColor: badColor,
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
                color: CupertinoDynamicColor.resolve(
                    AppColors.scoreMid, context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip,
                  style: AppTypography.bodyMedium(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.textSecondary, context),
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
}

// ---------------------------------------------------------------------------
// Factor row with severity badge, details, and recommendations
// ---------------------------------------------------------------------------

class _FactorRow extends StatelessWidget {
  final bool pass;
  final String label;
  final AuditFactor? factor;
  final Color goodColor;
  final Color badColor;

  const _FactorRow({
    required this.pass,
    required this.label,
    required this.factor,
    required this.goodColor,
    required this.badColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main check row
          Row(
            children: [
              Icon(
                pass
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.xmark_circle_fill,
                size: 16,
                color: pass ? goodColor : badColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                      pass
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      context,
                    ),
                  ),
                ),
              ),
              if (factor != null) _SeverityBadge(severity: factor!.severity),
            ],
          ),

          // Details text
          if (factor?.details != null && factor!.details!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 4),
              child: Text(
                factor!.details!,
                style: AppTypography.chip(context).copyWith(
                  color: CupertinoDynamicColor.resolve(
                      AppColors.textTertiary, context),
                  height: 1.3,
                ),
              ),
            ),

          // Recommendations list
          if (factor != null && factor!.recommendations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: factor!.recommendations.map((rec) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(
                            CupertinoIcons.arrow_turn_down_right,
                            size: 10,
                            color: CupertinoDynamicColor.resolve(
                                AppColors.textTertiary, context),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            rec,
                            style: AppTypography.chip(context).copyWith(
                              color: CupertinoDynamicColor.resolve(
                                  AppColors.textSecondary, context),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Severity badge — color-coded pill
// ---------------------------------------------------------------------------

class _SeverityBadge extends StatelessWidget {
  final String severity;

  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final (Color textColor, Color bgColor) = _severityColors(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppColors.radiusS),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: textColor,
        ),
      ),
    );
  }

  (Color, Color) _severityColors(BuildContext context) {
    switch (severity.toLowerCase()) {
      case 'low':
        final c =
            CupertinoDynamicColor.resolve(AppColors.scoreGood, context);
        return (c, c.withValues(alpha: 0.12));
      case 'medium':
        final c =
            CupertinoDynamicColor.resolve(AppColors.scoreMid, context);
        return (c, c.withValues(alpha: 0.12));
      case 'high':
        return (
          const Color(0xFFEA580C),
          const Color(0xFFEA580C).withValues(alpha: 0.12),
        );
      case 'critical':
        final c =
            CupertinoDynamicColor.resolve(AppColors.scoreBad, context);
        return (c, c.withValues(alpha: 0.12));
      default:
        final c =
            CupertinoDynamicColor.resolve(AppColors.textTertiary, context);
        return (c, c.withValues(alpha: 0.12));
    }
  }
}
