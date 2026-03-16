import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../models/audit_result.dart';
import '../../services/audit_service.dart';
import '../../providers/businesses_provider.dart';
import '../../widgets/animated_score_gauge.dart';
import '../../widgets/brutal_card.dart';
import '../../widgets/ios_toast.dart';
import '../../widgets/share_business_sheet.dart';
import '../../widgets/skeleton_loaders.dart';
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
      await Future.delayed(const Duration(seconds: 2));
      final result = await AuditService.auditBusiness(business.id);

      if (mounted) {
        setState(() {
          _auditResult = result;
          _isAuditing = false;
        });

        ref.refresh(businessProvider(widget.businessId));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAuditing = false);
        IosToast.show(context, 'Error: $e', icon: CupertinoIcons.exclamationmark_triangle);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(businessProvider(widget.businessId));

    return businessAsync.when(
        data: (business) {
          if (business == null) {
            return const CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                previousPageTitle: 'Pipeline',
                middle: Text('Not Found'),
              ),
              child: Center(child: Text('Business not found')),
            );
          }

          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              previousPageTitle: 'Pipeline',
              middle: Text(business.name),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.share),
                onPressed: () {
                  ShareBusinessSheet.show(context, business);
                },
              ),
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),

                      // Business info header
                      CupertinoListSection.insetGrouped(
                        margin: EdgeInsets.zero,
                        children: [
                          CupertinoListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: business.webPresenceColor
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Icon(business.webPresenceIcon,
                                  color: business.webPresenceColor,
                                  size: 22),
                            ),
                            title: Text(
                              business.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: business.address != null
                                ? Text(business.address!)
                                : null,
                          ),
                          if (business.rating != null)
                            CupertinoListTile(
                              leading: const Icon(
                                CupertinoIcons.star_fill,
                                color: AppColors.warning,
                                size: 20,
                              ),
                              title: Row(
                                children: [
                                  ...List.generate(5, (i) {
                                    final fill = (business.rating ?? 0) - i;
                                    return Icon(
                                      fill >= 1
                                          ? CupertinoIcons.star_fill
                                          : fill >= 0.5
                                              ? CupertinoIcons.star_lefthalf_fill
                                              : CupertinoIcons.star,
                                      color: AppColors.warning,
                                      size: 14,
                                    );
                                  }),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${business.rating} (${business.reviewsCount})',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: CupertinoColors.secondaryLabel
                                          .resolveFrom(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(
                            begin: 0.04,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 20),

                      // Contact buttons
                      Row(
                        children: [
                          if (business.phone != null)
                            Expanded(
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                color: AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppColors.radiusL),
                                onPressed: () => launchUrl(
                                    Uri.parse('tel:${business.phone}')),
                                child: Column(
                                  children: [
                                    Icon(CupertinoIcons.phone,
                                        color: AppColors.success, size: 20),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Call',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (business.website != null) ...[
                            if (business.phone != null)
                              const SizedBox(width: 10),
                            Expanded(
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                color: AppColors.info.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppColors.radiusL),
                                onPressed: () => launchUrl(
                                    Uri.parse(business.website!),
                                    mode: LaunchMode.externalApplication),
                                child: Column(
                                  children: [
                                    Icon(CupertinoIcons.globe,
                                        color: AppColors.info, size: 20),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Website',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.info,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (business.address != null) ...[
                            if (business.phone != null ||
                                business.website != null)
                              const SizedBox(width: 10),
                            Expanded(
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppColors.radiusL),
                                onPressed: () => launchUrl(
                                  Uri.parse(
                                      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(business.address!)}'),
                                  mode: LaunchMode.externalApplication,
                                ),
                                child: Column(
                                  children: [
                                    Icon(CupertinoIcons.map,
                                        color: AppColors.primary, size: 20),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Maps',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      )
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 300.ms)
                          .slideX(
                            begin: -0.03,
                            duration: 350.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 28),

                      // Audit section
                      if (!business.isAudited && !_isAuditing)
                        Center(
                          child: CupertinoButton.filled(
                            onPressed: () => _runAudit(business),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.chart_bar, size: 18),
                                SizedBox(width: 8),
                                Text('Analyze Business'),
                              ],
                            ),
                          ),
                        )
                            .animate(delay: 300.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(
                              begin: 0.02,
                              duration: 400.ms,
                              curve: Curves.easeOutQuart,
                            ),

                      if (_isAuditing) _AnalyzingAnimation(),

                      if (business.isAudited || _auditResult != null) ...[
                        // Score gauge
                        Center(
                          child: AnimatedScoreGauge(
                            score: _auditResult?.score ??
                                business.auditScore ??
                                0,
                            onComplete: () => Haptics.medium(),
                          ),
                        )
                            .animate(delay: 100.ms)
                            .fadeIn(duration: 400.ms)
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              duration: 500.ms,
                              curve: Curves.easeOutBack,
                            ),
                        const SizedBox(height: 28),

                        // AI Analysis
                        BrutalCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.info
                                          .withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.sparkles,
                                      size: 14,
                                      color: AppColors.info,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'AI Analysis',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: CupertinoColors.label
                                          .resolveFrom(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _auditResult?.diagnosis ??
                                    business.auditDiagnosis ??
                                    '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: CupertinoColors.secondaryLabel
                                      .resolveFrom(context),
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate(delay: 200.ms)
                            .fadeIn(duration: 300.ms)
                            .slideX(
                              begin: -0.03,
                              duration: 350.ms,
                              curve: Curves.easeOutCubic,
                            ),
                        const SizedBox(height: 20),

                        // CTAs
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoButton.filled(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                onPressed: () {
                                  context.push(
                                      '/business/${business.id}/build-demo');
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.globe, size: 18),
                                    SizedBox(width: 8),
                                    Text('Build Demo'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(8),
                                onPressed: () {
                                  context.push(
                                      '/business/${business.id}/outreach');
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.paperplane,
                                        size: 18,
                                        color: CupertinoColors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Outreach',
                                      style: TextStyle(
                                          color: CupertinoColors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                            .animate(delay: 300.ms)
                            .slideY(
                              begin: 0.02,
                              duration: 400.ms,
                              curve: Curves.easeOutQuart,
                            ),
                      ],
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const SafeArea(child: BusinessDetailSkeleton()),
        error: (error, _) => Center(child: Text('Error: $error')),
      );
  }
}

// ---------------------------------------------------------------------------
// Analyzing Animation
// ---------------------------------------------------------------------------

class _AnalyzingAnimation extends StatefulWidget {
  @override
  State<_AnalyzingAnimation> createState() => _AnalyzingAnimationState();
}

class _AnalyzingAnimationState extends State<_AnalyzingAnimation>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _pulseController;

  final List<_AnalysisStep> _steps = const [
    _AnalysisStep(CupertinoIcons.globe, 'Checking website...'),
    _AnalysisStep(CupertinoIcons.text_bubble, 'Analyzing reviews...'),
    _AnalysisStep(CupertinoIcons.chart_bar, 'Calculating score...'),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animateSteps();
  }

  Future<void> _animateSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() => _currentStep = i);
        Haptics.light();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BrutalCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.4 + (_pulseController.value * 0.6),
                  child: Transform.scale(
                    scale: 0.9 + (_pulseController.value * 0.1),
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppColors.radiusL),
                ),
                child: const Icon(
                  CupertinoIcons.chart_bar,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(_steps.length, (index) {
              final isActive = index == _currentStep;
              final isDone = index < _currentStep;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : const Color(0x00000000),
                  borderRadius: BorderRadius.circular(AppColors.radiusS),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isDone
                            ? CupertinoIcons.checkmark_circle_fill
                            : isActive
                                ? _steps[index].icon
                                : CupertinoIcons.circle,
                        key: ValueKey('$index-$isDone-$isActive'),
                        size: 16,
                        color: isActive
                            ? AppColors.primary
                            : isDone
                                ? AppColors.success
                                : CupertinoColors.tertiaryLabel
                                    .resolveFrom(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _steps[index].label,
                      style: TextStyle(
                        fontSize: 15,
                        color: isActive
                            ? CupertinoColors.label.resolveFrom(context)
                            : isDone
                                ? CupertinoColors.secondaryLabel
                                    .resolveFrom(context)
                                : CupertinoColors.tertiaryLabel
                                    .resolveFrom(context),
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
            begin: const Offset(0.95, 0.95),
            duration: 350.ms,
            curve: Curves.easeOutCubic);
  }
}

class _AnalysisStep {
  final IconData icon;
  final String label;
  const _AnalysisStep(this.icon, this.label);
}
