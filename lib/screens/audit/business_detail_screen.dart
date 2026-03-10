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
  ConsumerState<BusinessDetailScreen> createState() =>
      _BusinessDetailScreenState();
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
      body: businessAsync.when(
        data: (business) {
          if (business == null) {
            return const Center(child: Text('Business not found'));
          }

          return CustomScrollView(
            slivers: [
              // Custom app bar with gradient overlay
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back,
                                size: 18, color: AppColors.primary),
                            label: Text(
                              'Back',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share,
                                color: AppColors.textSecondary),
                            onPressed: () {
                              ShareBusinessSheet.show(context, business);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),

                    // Business info header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppColors.radiusL),
                          ),
                          alignment: Alignment.center,
                          child: Icon(business.webPresenceIcon,
                              color: business.webPresenceColor, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Hero(
                            tag: 'business-name-${business.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                business.name,
                                style: AppTypography.headlineLarge.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
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
                          const Icon(Icons.star,
                              color: AppColors.warning, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${business.rating} (${business.reviewsCount} reviews)',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Contact buttons
                    Row(
                      children: [
                        if (business.phone != null)
                          Expanded(
                            child: _ContactButton(
                              icon: Icons.phone,
                              label: 'Call',
                              onTap: () => launchUrl(
                                  Uri.parse('tel:${business.phone}')),
                            ),
                          ),
                        if (business.website != null) ...[
                          if (business.phone != null)
                            const SizedBox(width: 10),
                          Expanded(
                            child: _ContactButton(
                              icon: Icons.language,
                              label: 'Website',
                              onTap: () => launchUrl(
                                  Uri.parse(business.website!),
                                  mode:
                                      LaunchMode.externalApplication),
                            ),
                          ),
                        ],
                        if (business.address != null) ...[
                          if (business.phone != null ||
                              business.website != null)
                            const SizedBox(width: 10),
                          Expanded(
                            child: _ContactButton(
                              icon: Icons.map,
                              label: 'Maps',
                              onTap: () => launchUrl(
                                Uri.parse(
                                    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(business.address!)}'),
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Audit section
                    if (!business.isAudited && !_isAuditing)
                      Center(
                        child: BrutalButton(
                          label: 'Analyze Business',
                          icon: Icons.analytics,
                          onPressed: () => _runAudit(business),
                        ),
                      ),

                    if (_isAuditing) _AnalyzingAnimation(),

                    if (business.isAudited || _auditResult != null) ...[
                      // Score gauge
                      AnimatedScoreGauge(
                        score: _auditResult?.score ??
                            business.auditScore ??
                            0,
                        onComplete: () => Haptics.medium(),
                      ),
                      const SizedBox(height: 24),

                      // AI Analysis
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppColors.radiusXL),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Analysis',
                              style: AppTypography.labelLarge.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _auditResult?.diagnosis ??
                                  business.auditDiagnosis ??
                                  '',
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],
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
                                context.push(
                                    '/business/${business.id}/build-demo');
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: BrutalButton.success(
                              label: 'Outreach',
                              onPressed: () {
                                context.push(
                                    '/business/${business.id}/outreach');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

/// Widget que muestra animacion de analisis paso a paso
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
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() => _currentStep = i);
        Haptics.light();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppColors.radiusXL),
        ),
        child: Column(
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(height: 24),
            ...List.generate(_steps.length, (index) {
              final isActive = index == _currentStep;
              final isDone = index < _currentStep;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.06)
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppColors.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDone
                            ? Icons.check_circle
                            : Icons.circle_outlined,
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
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppColors.radiusL),
      child: InkWell(
        onTap: () {
          Haptics.light();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
