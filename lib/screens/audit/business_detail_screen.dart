import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import '../../widgets/aurora_background.dart';
import '../../widgets/glow_card.dart';
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
            child: AuroraBackground(
            intensity: 0.5,
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

                      // Business info header with gradient icon
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      business.webPresenceColor
                                          .withValues(alpha: 0.2),
                                      business.webPresenceColor
                                          .withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      AppColors.radiusL),
                                  border: Border.all(
                                    color: business.webPresenceColor
                                        .withValues(alpha: 0.15),
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(business.webPresenceIcon,
                                    color: business.webPresenceColor,
                                    size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Hero(
                                  tag: 'business-name-${business.id}',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      business.name,
                                      style:
                                          AppTypography.headlineLarge.copyWith(
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
                                // Star rating with gradient
                                ...List.generate(5, (i) {
                                  final fill = (business.rating ?? 0) - i;
                                  return Icon(
                                    fill >= 1
                                        ? Icons.star_rounded
                                        : fill >= 0.5
                                            ? Icons.star_half_rounded
                                            : Icons.star_outline_rounded,
                                    color: AppColors.warning,
                                    size: 16,
                                  );
                                }),
                                const SizedBox(width: 6),
                                Text(
                                  '${business.rating} (${business.reviewsCount})',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
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

                      // Contact buttons with glow
                      Row(
                        children: [
                          if (business.phone != null)
                            Expanded(
                              child: _GlowContactButton(
                                icon: Icons.phone_rounded,
                                label: 'Call',
                                color: AppColors.success,
                                onTap: () => launchUrl(
                                    Uri.parse('tel:${business.phone}')),
                              ),
                            ),
                          if (business.website != null) ...[
                            if (business.phone != null)
                              const SizedBox(width: 10),
                            Expanded(
                              child: _GlowContactButton(
                                icon: Icons.language_rounded,
                                label: 'Website',
                                color: AppColors.info,
                                onTap: () => launchUrl(
                                    Uri.parse(business.website!),
                                    mode: LaunchMode.externalApplication),
                              ),
                            ),
                          ],
                          if (business.address != null) ...[
                            if (business.phone != null ||
                                business.website != null)
                              const SizedBox(width: 10),
                            Expanded(
                              child: _GlowContactButton(
                                icon: Icons.map_rounded,
                                label: 'Maps',
                                color: AppColors.primary,
                                onTap: () => launchUrl(
                                  Uri.parse(
                                      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(business.address!)}'),
                                  mode: LaunchMode.externalApplication,
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
                          child: _GlowCTAButton(
                            label: 'Analyze Business',
                            icon: Icons.analytics_rounded,
                            onPressed: () => _runAudit(business),
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

                        // AI Analysis in glow card
                        GlowCard(
                          glowColor: AppColors.info,
                          glowIntensity: 0.3,
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
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.info
                                              .withValues(alpha: 0.2),
                                          AppColors.info
                                              .withValues(alpha: 0.05),
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 14,
                                      color: AppColors.info,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'AI Analysis',
                                    style:
                                        AppTypography.labelLarge.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
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
                        )
                            .animate(delay: 200.ms)
                            .fadeIn(duration: 300.ms)
                            .slideX(
                              begin: -0.03,
                              duration: 350.ms,
                              curve: Curves.easeOutCubic,
                            ),
                        const SizedBox(height: 20),

                        // CTAs with gradient
                        Row(
                          children: [
                            Expanded(
                              child: _GlowCTAButton(
                                label: 'Build Demo',
                                icon: Icons.web_rounded,
                                color: AppColors.secondary,
                                onPressed: () {
                                  context.push(
                                      '/business/${business.id}/build-demo');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _GlowCTAButton(
                                label: 'Outreach',
                                icon: Icons.send_rounded,
                                color: AppColors.success,
                                onPressed: () {
                                  context.push(
                                      '/business/${business.id}/outreach');
                                },
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
          ),
          );
        },
        loading: () => const SafeArea(child: BusinessDetailSkeleton()),
        error: (error, _) => Center(child: Text('Error: $error')),
      );
  }
}

// ---------------------------------------------------------------------------
// Glow Contact Button
// ---------------------------------------------------------------------------

class _GlowContactButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GlowContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_GlowContactButton> createState() => _GlowContactButtonState();
}

class _GlowContactButtonState extends State<_GlowContactButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Haptics.light();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radiusL),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.15),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.06),
                blurRadius: 12,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(widget.icon, color: widget.color, size: 20),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Glow CTA Button — gradient background with glow shadow
// ---------------------------------------------------------------------------

class _GlowCTAButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback onPressed;

  const _GlowCTAButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  State<_GlowCTAButton> createState() => _GlowCTAButtonState();
}

class _GlowCTAButtonState extends State<_GlowCTAButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Haptics.light();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppColors.radiusM),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: AppTypography.button.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Analyzing Animation — premium version with gradient pulse
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
    _AnalysisStep(Icons.language_rounded, 'Checking website...'),
    _AnalysisStep(Icons.reviews_rounded, 'Analyzing reviews...'),
    _AnalysisStep(Icons.calculate_rounded, 'Calculating score...'),
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
      child: GlowCard(
        glowColor: AppColors.primary,
        animateBorder: true,
        glowIntensity: 0.6,
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
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppColors.radiusL),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
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
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppColors.radiusS),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isDone
                            ? Icons.check_circle_rounded
                            : isActive
                                ? _steps[index].icon
                                : Icons.circle_outlined,
                        key: ValueKey('$index-$isDone-$isActive'),
                        size: 16,
                        color: isActive
                            ? AppColors.primary
                            : isDone
                                ? AppColors.success
                                : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _steps[index].label,
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
