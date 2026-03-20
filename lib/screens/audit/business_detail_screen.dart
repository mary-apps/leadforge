import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../models/audit_result.dart';
import '../../models/demo.dart';
import '../../models/message.dart';
import '../../services/audit_service.dart';
import '../../providers/auto_audit_provider.dart';
import '../../providers/audit_state_provider.dart';
import '../../providers/businesses_provider.dart';
import '../../providers/demo_provider.dart';
import '../../providers/outreach_provider.dart';
import '../../providers/messages_provider.dart';
import '../../widgets/audit_context.dart';
import '../../widgets/outreach_history.dart';
import '../../widgets/inline_score.dart';
import '../../widgets/app_button.dart';
import '../../widgets/ios_toast.dart';
import '../../widgets/share_business_sheet.dart';
import '../../widgets/error_state.dart';
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
        IosToast.show(context, 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(businessProvider(widget.businessId));

    return businessAsync.when(
      data: (business) {
        if (business == null) {
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('Business'),
            ),
            child: const Center(child: Text('Business not found')),
          );
        }

        final auditState = ref.watch(auditStateProvider(widget.businessId));
        final autoAuditEnabled = ref.watch(autoAuditProvider);
        final isAutoAuditing = auditState is AsyncLoading;
        final demoAsync = ref.watch(demoForBusinessProvider(business.id));
        final outreachAsync = ref.watch(outreachForBusinessProvider(business.id));
        final demo = demoAsync.valueOrNull;
        final outreach = outreachAsync.valueOrNull;

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              business.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: GestureDetector(
              onTap: () => ShareBusinessSheet.show(context, business),
              child: Icon(
                CupertinoIcons.share,
                size: 20,
                color: CupertinoDynamicColor.resolve(
                    AppColors.accent, context),
              ),
            ),
          ),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pageHorizontal),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),

                    // Business name
                    Text(
                      business.name,
                      style: AppTypography.headlineLarge(context),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(
                          begin: AppConstants.entranceSlideDistance / 100,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: AppConstants.contentGap),

                    // Address
                    if (business.address != null)
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppConstants.contentGap),
                        child: Text(
                          business.address!,
                          style: AppTypography.bodyMedium(context).copyWith(
                            color: CupertinoDynamicColor.resolve(
                                AppColors.textSecondary, context),
                          ),
                        ),
                      ),

                    // Rating stars
                    if (business.rating != null)
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            final fill = (business.rating ?? 0) - i;
                            return Icon(
                              fill >= 1
                                  ? CupertinoIcons.star_fill
                                  : fill >= 0.5
                                      ? CupertinoIcons.star_lefthalf_fill
                                      : CupertinoIcons.star,
                              color: CupertinoDynamicColor.resolve(
                                  AppColors.scoreMid, context),
                              size: 14,
                            );
                          }),
                          const SizedBox(width: 6),
                          Text(
                            '${business.rating} (${business.reviewsCount})',
                            style: AppTypography.bodyMedium(context).copyWith(
                              color: CupertinoDynamicColor.resolve(
                                  AppColors.textSecondary, context),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppConstants.sectionGap),

                    // Contact buttons — flat text links
                    Row(
                      children: [
                        if (business.phone != null)
                          _ContactLink(
                            icon: CupertinoIcons.phone,
                            label: 'Call',
                            onTap: () => launchUrl(
                                Uri.parse('tel:${business.phone}')),
                          ),
                        if (business.website != null) ...[
                          if (business.phone != null)
                            const SizedBox(width: AppConstants.pageHorizontal),
                          _ContactLink(
                            icon: CupertinoIcons.globe,
                            label: 'Website',
                            onTap: () => launchUrl(
                                Uri.parse(business.website!),
                                mode: LaunchMode.externalApplication),
                          ),
                        ],
                        if (business.address != null) ...[
                          if (business.phone != null ||
                              business.website != null)
                            const SizedBox(width: AppConstants.pageHorizontal),
                          _ContactLink(
                            icon: CupertinoIcons.map,
                            label: 'Maps',
                            onTap: () => launchUrl(
                              Uri.parse(
                                  'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(business.address!)}'),
                              mode: LaunchMode.externalApplication,
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
                    const SizedBox(height: AppConstants.sectionGap),

                    // Audit section
                    if (!business.isAudited && !_isAuditing && !isAutoAuditing)
                      autoAuditEnabled
                          ? const SizedBox.shrink()
                          : AppButton(
                              label: 'Analyze Business',
                              onPressed: () => _runAudit(business),
                            )
                                .animate(delay: 300.ms)
                                .fadeIn(duration: 400.ms)
                                .slideY(
                                  begin: AppConstants.entranceSlideDistance / 100,
                                  duration: 400.ms,
                                  curve: Curves.easeOutQuart,
                                ),

                    // Show shimmer while auto-auditing
                    if (isAutoAuditing) _AnalyzingAnimation(),

                    // Show retry if auto-audit failed
                    if (auditState is AsyncError && !business.isAudited)
                      AppButton(
                        label: 'Retry Analysis',
                        onPressed: () => triggerAutoAudit(ref, business.id),
                      ),

                    if (_isAuditing) _AnalyzingAnimation(),

                    if (business.isAudited || _auditResult != null) ...[
                      // Inline score
                      InlineScore(
                        score: _auditResult?.score ??
                            business.auditScore ??
                            0,
                        description: _auditResult?.diagnosis ??
                            business.auditDiagnosis,
                      )
                          .animate(delay: 100.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(
                            begin: AppConstants.entranceSlideDistance / 100,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: AppConstants.itemGap),
                      AuditContext(business: business),
                      const SizedBox(height: AppConstants.sectionGap),

                      // AI Analysis — flat layout with divider borders
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: CupertinoDynamicColor.resolve(
                                  AppColors.divider, context),
                              width: 1,
                            ),
                            bottom: BorderSide(
                              color: CupertinoDynamicColor.resolve(
                                  AppColors.divider, context),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI ANALYSIS',
                              style: AppTypography.labelSmall(context),
                            ),
                            const SizedBox(height: AppConstants.itemGap),
                            Text(
                              _auditResult?.diagnosis ??
                                  business.auditDiagnosis ??
                                  '',
                              style:
                                  AppTypography.bodyMedium(context).copyWith(
                                color: CupertinoDynamicColor.resolve(
                                    AppColors.textSecondary, context),
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
                      const SizedBox(height: AppConstants.sectionGap),

                      // Demo action
                      if (demo == null)
                        AppButton(
                          label: 'Generate Demo Site',
                          onPressed: () async {
                            await context.push('/business/${business.id}/build-demo');
                            ref.invalidate(demoForBusinessProvider(business.id));
                          },
                        )
                      else
                        _DemoStatusCard(
                          demo: demo,
                          onPreview: () => launchUrl(Uri.parse(demo.publicUrl),
                              mode: LaunchMode.externalApplication),
                          onShare: () => Share.share(
                              'Check out this demo: ${demo.publicUrl}',
                              subject: 'Demo Website'),
                          onRegenerate: () async {
                            await context.push('/business/${business.id}/build-demo');
                            ref.invalidate(demoForBusinessProvider(business.id));
                          },
                        ),
                      const SizedBox(height: 12),

                      // Outreach action
                      if (outreach == null) ...[
                        AppButton(
                          label: 'Compose Outreach',
                          variant: AppButtonVariant.secondary,
                          onPressed: () async {
                            await context.push('/business/${business.id}/outreach');
                            ref.invalidate(outreachForBusinessProvider(business.id));
                          },
                        ),
                        if (demo == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Generate demo first for best results',
                              style: AppTypography.chip(context).copyWith(
                                color: CupertinoDynamicColor.resolve(
                                    AppColors.textTertiary, context),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ] else
                        _OutreachStatusCard(
                          message: outreach,
                          onCopy: () {
                            Clipboard.setData(ClipboardData(text: outreach.content));
                            HapticFeedback.mediumImpact();
                          },
                          onRegenerate: () async {
                            await context.push('/business/${business.id}/outreach');
                            ref.invalidate(outreachForBusinessProvider(business.id));
                          },
                        ),

                      // Outreach history
                      const SizedBox(height: AppConstants.sectionGap),
                      Builder(builder: (context) {
                        final messagesAsync =
                            ref.watch(messagesForBusinessProvider(business.id));
                        return messagesAsync.when(
                          data: (messages) =>
                              OutreachHistory(messages: messages),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      }),
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
      error: (error, _) => CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Error')),
        child: ErrorState(
          error: error,
          onRetry: () => ref.invalidate(businessProvider(widget.businessId)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Contact link — flat icon + label pair
// ---------------------------------------------------------------------------

class _ContactLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentCol =
        CupertinoDynamicColor.resolve(AppColors.accent, context);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accentCol),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelLarge(context).copyWith(
              color: accentCol,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
    final accentCol =
        CupertinoDynamicColor.resolve(AppColors.accent, context);
    final scoreGoodCol =
        CupertinoDynamicColor.resolve(AppColors.scoreGood, context);
    final dividerCol =
        CupertinoDynamicColor.resolve(AppColors.divider, context);
    final textPrimaryCol =
        CupertinoDynamicColor.resolve(AppColors.textPrimary, context);
    final textSecondaryCol =
        CupertinoDynamicColor.resolve(AppColors.textSecondary, context);
    final textTertiaryCol =
        CupertinoDynamicColor.resolve(AppColors.textTertiary, context);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: dividerCol, width: 1),
          borderRadius: BorderRadius.circular(AppColors.radiusM),
        ),
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
                  color: accentCol.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppColors.radiusL),
                ),
                child: Icon(
                  CupertinoIcons.chart_bar,
                  color: accentCol,
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
                      ? accentCol.withValues(alpha: 0.04)
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
                            ? accentCol
                            : isDone
                                ? scoreGoodCol
                                : textTertiaryCol,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _steps[index].label,
                      style: TextStyle(
                        fontSize: 15,
                        color: isActive
                            ? textPrimaryCol
                            : isDone
                                ? textSecondaryCol
                                : textTertiaryCol,
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

// ---------------------------------------------------------------------------
// Demo Status Card
// ---------------------------------------------------------------------------

class _DemoStatusCard extends StatelessWidget {
  final Demo demo;
  final VoidCallback onPreview;
  final VoidCallback onShare;
  final VoidCallback onRegenerate;

  const _DemoStatusCard({
    required this.demo,
    required this.onPreview,
    required this.onShare,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CupertinoDynamicColor.resolve(AppColors.divider, context),
            width: 1,
          ),
          bottom: BorderSide(
            color: CupertinoDynamicColor.resolve(AppColors.divider, context),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.checkmark_circle_fill,
                  size: 16,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.scoreGood, context)),
              const SizedBox(width: 6),
              Text('Demo ready',
                  style: AppTypography.labelLarge(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.scoreGood, context),
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppButton(
                    label: 'Preview',
                    compact: true,
                    onPressed: onPreview),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                    label: 'Share',
                    compact: true,
                    variant: AppButtonVariant.secondary,
                    onPressed: onShare),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                    label: 'Redo',
                    compact: true,
                    variant: AppButtonVariant.ghost,
                    onPressed: onRegenerate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Outreach Status Card
// ---------------------------------------------------------------------------

class _OutreachStatusCard extends StatelessWidget {
  final Message message;
  final VoidCallback onCopy;
  final VoidCallback onRegenerate;

  const _OutreachStatusCard({
    required this.message,
    required this.onCopy,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CupertinoDynamicColor.resolve(AppColors.divider, context),
            width: 1,
          ),
          bottom: BorderSide(
            color: CupertinoDynamicColor.resolve(AppColors.divider, context),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.checkmark_circle_fill,
                  size: 16,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.scoreGood, context)),
              const SizedBox(width: 6),
              Text('Outreach ready',
                  style: AppTypography.labelLarge(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.scoreGood, context),
                    fontWeight: FontWeight.w600,
                  )),
              const Spacer(),
              Text(message.channel.name,
                  style: AppTypography.chip(context)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message.content,
            style: AppTypography.bodyMedium(context).copyWith(
              color: CupertinoDynamicColor.resolve(
                  AppColors.textSecondary, context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppButton(
                    label: 'Copy',
                    compact: true,
                    onPressed: onCopy),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                    label: 'Regenerate',
                    compact: true,
                    variant: AppButtonVariant.ghost,
                    onPressed: onRegenerate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
