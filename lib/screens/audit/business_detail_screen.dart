import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../models/audit_result.dart';
import '../../services/audit_service.dart';
import '../../providers/businesses_provider.dart';
import '../../widgets/animated_score_gauge.dart';
import '../../widgets/brutal_button.dart';
import '../../widgets/share_business_sheet.dart';
import '../../utils/haptics.dart';

class BusinessDetailScreen extends ConsumerStatefulWidget {
  final String businessId;

  const BusinessDetailScreen({
    super.key,
    required this.businessId,
  });

  @override
  ConsumerState<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends ConsumerState<BusinessDetailScreen> {
  bool _isAuditing = false;
  AuditResult? _auditResult;

  Future<void> _runAudit(Business business) async {
    setState(() => _isAuditing = true);

    try {
      await Future.delayed(const Duration(seconds: 2)); // Build suspense
      final result = await AuditService.auditBusiness(business.id);

      if (mounted) {
        setState(() {
          _auditResult = result;
          _isAuditing = false;
        });

        // Refresh business data
        ref.refresh(businessProvider(widget.businessId));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAuditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(businessProvider(widget.businessId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Detail'),
        actions: [
          if (businessAsync.value != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                ShareBusinessSheet.show(context, businessAsync.value!);
              },
            ),
        ],
      ),
      body: businessAsync.when(
        data: (business) {
          if (business == null) {
            return const Center(child: Text('Business not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header — no Card wrapper, just padding
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(business.statusBadge, style: const TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Hero(
                              tag: 'business-name-${business.id}',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  business.name,
                                  style: AppTypography.titleLarge.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (business.address != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          business.address!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (business.rating != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${business.rating} (${business.reviewsCount} reviews)',
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Quick contact actions
                Row(
                  children: [
                    if (business.phone != null)
                      Expanded(
                        child: _ContactButton(
                          icon: Icons.phone,
                          label: 'Call',
                          borderColor: AppColors.secondary,
                          onTap: () => launchUrl(Uri.parse('tel:${business.phone}')),
                        ),
                      ),
                    if (business.website != null) ...[
                      if (business.phone != null) const SizedBox(width: 8),
                      Expanded(
                        child: _ContactButton(
                          icon: Icons.language,
                          label: 'Website',
                          borderColor: AppColors.primary,
                          onTap: () => launchUrl(Uri.parse(business.website!), mode: LaunchMode.externalApplication),
                        ),
                      ),
                    ],
                    if (business.address != null) ...[
                      if (business.phone != null || business.website != null) const SizedBox(width: 8),
                      Expanded(
                        child: _ContactButton(
                          icon: Icons.map,
                          label: 'Maps',
                          borderColor: AppColors.success,
                          onTap: () => launchUrl(
                            Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(business.address!)}'),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Audit section
                if (!business.isAudited && !_isAuditing)
                  Center(
                    child: BrutalButton(
                      label: 'Analyze Business',
                      icon: Icons.analytics,
                      onPressed: () => _runAudit(business),
                    ),
                  ),

                if (_isAuditing)
                  _AnalyzingAnimation(),

                if (business.isAudited || _auditResult != null) ...[
                  // Score gauge (animated)
                  AnimatedScoreGauge(
                    score: _auditResult?.score ?? business.auditScore ?? 0,
                    onComplete: () => Haptics.medium(),
                  ),
                  const SizedBox(height: 24),

                  // Diagnosis
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Analysis',
                            style: AppTypography.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _auditResult?.diagnosis ?? business.auditDiagnosis ?? '',
                            style: AppTypography.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CTAs
                  Row(
                    children: [
                      Expanded(
                        child: BrutalButton(
                          label: 'Build Demo',
                          onPressed: () {
                            context.push('/business/${business.id}/build-demo');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BrutalButton.success(
                          label: 'Outreach',
                          onPressed: () {
                            context.push('/business/${business.id}/outreach');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

/// Widget que muestra animación de análisis paso a paso
class _AnalyzingAnimation extends StatefulWidget {
  @override
  State<_AnalyzingAnimation> createState() => _AnalyzingAnimationState();
}

class _AnalyzingAnimationState extends State<_AnalyzingAnimation> {
  int _currentStep = 0;

  final List<String> _steps = [
    'Checking website...',
    'Analyzing reviews...',
    'Calculating score...',
  ];

  @override
  void initState() {
    super.initState();
    _animateSteps();
  }

  Future<void> _animateSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        setState(() => _currentStep = i);
        Haptics.light();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          ...List.generate(_steps.length, (index) {
            final isActive = index == _currentStep;
            final isDone = index < _currentStep;

            final Color borderColor = isActive
                ? AppColors.primary
                : isDone
                    ? AppColors.success
                    : AppColors.border;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: borderColor.withValues(alpha: 0.4),
                            offset: const Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDone ? Icons.check_circle : Icons.circle_outlined,
                      size: 16,
                      color: isActive
                          ? AppColors.primary
                          : isDone
                              ? AppColors.success
                              : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _steps[index],
                      style: AppTypography.bodyMedium.copyWith(
                        color: isActive
                            ? AppColors.textPrimary
                            : isDone
                                ? AppColors.textSecondary
                                : AppColors.textTertiary,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color borderColor;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.4),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            Haptics.light();
            onTap();
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, color: borderColor, size: 22),
                const SizedBox(height: 4),
                Text(
                  label.toUpperCase(),
                  style: AppTypography.labelLarge.copyWith(
                    color: borderColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
