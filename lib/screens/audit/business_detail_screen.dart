import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../models/audit_result.dart';
import '../../models/message.dart';
import '../../models/report.dart';
import '../../services/audit_service.dart';
import '../../services/report_service.dart';
import '../../services/scout_service.dart';
import '../../services/supabase_service.dart';
import '../../providers/auto_audit_provider.dart';
import '../../providers/audit_state_provider.dart';
import '../../providers/businesses_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/outreach_provider.dart';
import '../../providers/messages_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/audit_context.dart';
import '../../widgets/outreach_history.dart';
import '../../widgets/app_button.dart';
import '../../widgets/ios_toast.dart';
import '../../widgets/paywall_dialog.dart';
import '../../widgets/share_business_sheet.dart';
import '../../widgets/error_state.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../utils/haptics.dart';
import '../../utils/network.dart';

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
  bool _isGenerating = false;
  AuditResult? _auditResult;
  bool _autoAuditTriggered = false;

  void _maybeAutoAudit(Business business) {
    if (_autoAuditTriggered) return;
    if (business.isAudited || _auditResult != null) return;
    if (_isAuditing) return;

    final autoAuditEnabled = ref.read(autoAuditProvider);
    if (!autoAuditEnabled) return;

    _autoAuditTriggered = true;
    _runAudit(business);
  }

  Future<void> _runAudit(Business business) async {
    setState(() => _isAuditing = true);

    try {
      final result = await AuditService.auditBusiness(business.id);

      if (mounted) {
        setState(() {
          _auditResult = result;
          _isAuditing = false;
        });

        ref.invalidate(businessProvider(widget.businessId));
      }
    } on AuthExpiredException {
      if (mounted) {
        setState(() => _isAuditing = false);
        IosToast.show(context, 'Session expired. Please sign in again.');
      }
    } on LimitReachedException {
      if (mounted) {
        setState(() => _isAuditing = false);
        showPaywallDialog(context, title: 'Audit Limit Reached', message: 'Upgrade to Pro for unlimited audits.');
      }
    } catch (e) {
      debugPrint('Audit error: $e');
      if (mounted) {
        setState(() => _isAuditing = false);
        IosToast.show(context, 'Audit failed: $e');
      }
    }
  }

  Future<void> _generateReport(Business business) async {
    setState(() => _isGenerating = true);
    try {
      final profile = ref.read(profileNotifierProvider).valueOrNull;
      final agencyName = profile?.businessName;

      // Generate PDF
      final pdfBytes =
          await ReportService.generatePdfReport(business, agencyName);

      // Upload to storage
      final userId = SupabaseService.userId!;
      final storagePath =
          await ReportService.uploadPdf(pdfBytes, userId, business.id);

      // Save report record
      await ReportService.saveReport(
        businessId: business.id,
        score: business.auditScore ?? 0,
        breakdown: business.auditBreakdown ?? {},
        diagnosis: business.auditDiagnosis ?? '',
        recommendations: [],
        pdfStoragePath: storagePath,
      );

      // Update business status
      await ScoutService.updateStatus(business.id, BusinessStatus.reportSent);

      // Refresh providers
      ref.invalidate(reportForBusinessProvider(business.id));
      ref.invalidate(businessProvider(business.id));

      if (mounted) {
        setState(() => _isGenerating = false);
        Haptics.medium();
        IosToast.show(context, 'Report generated successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        Haptics.heavy();
        IosToast.show(context, 'Error: $e');
      }
    }
  }

  Future<void> _shareReport(Report report) async {
    if (report.pdfStoragePath == null) return;
    try {
      // Download PDF from Supabase storage
      final bytes = await SupabaseService.client.storage
          .from('reports')
          .download(report.pdfStoragePath!);
      // Save to temp file and share
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/audit-report.pdf');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)],
          text: 'Web Presence Audit Report');
    } catch (e) {
      if (mounted) {
        IosToast.show(context, 'Share failed: $e');
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
              middle: Text('Business'),
            ),
            child: Center(child: Text('Business not found')),
          );
        }

        final isAutoAuditing = ref.watch(
          auditStateProvider(widget.businessId).select((s) => s is AsyncLoading),
        );
        final isAuditStateError = ref.watch(
          auditStateProvider(widget.businessId).select((s) => s is AsyncError),
        );
        final autoAuditEnabled = ref.watch(autoAuditProvider);
        final reportAsync = ref.watch(reportForBusinessProvider(business.id));
        final outreachAsync = ref.watch(outreachForBusinessProvider(business.id));
        final report = reportAsync.valueOrNull;
        final outreach = outreachAsync.valueOrNull;

        // Auto-trigger audit if enabled and not yet audited
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _maybeAutoAudit(business);
        });

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

                    // Contact icon cards
                    Builder(builder: (context) {
                      final cards = <Widget>[];
                      if (business.phone != null) {
                        cards.add(Expanded(child: _ContactCard(icon: CupertinoIcons.phone, label: 'Call', onTap: () => launchUrl(Uri.parse('tel:${business.phone}')))));
                      }
                      if (business.website != null) {
                        if (cards.isNotEmpty) cards.add(const SizedBox(width: 8));
                        cards.add(Expanded(child: _ContactCard(icon: CupertinoIcons.globe, label: 'Website', onTap: () => launchUrl(Uri.parse(business.website!), mode: LaunchMode.externalApplication))));
                      }
                      if (business.address != null) {
                        if (cards.isNotEmpty) cards.add(const SizedBox(width: 8));
                        cards.add(Expanded(child: _ContactCard(icon: CupertinoIcons.map, label: 'Maps', onTap: () => launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(business.address!)}'), mode: LaunchMode.externalApplication))));
                      }
                      if (cards.isNotEmpty) cards.add(const SizedBox(width: 8));
                      cards.add(Expanded(child: _ContactCard(icon: CupertinoIcons.share, label: 'Share', onTap: () => ShareBusinessSheet.show(context, business))));
                      return Row(children: cards);
                    })
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: -0.03, duration: 350.ms, curve: Curves.easeOutCubic),
                    const SizedBox(height: AppConstants.sectionGap),

                    // Workflow label
                    Text('WORKFLOW', style: AppTypography.labelSmall(context)),
                    const SizedBox(height: AppConstants.itemGap),

                    // Workflow stepper
                    _WorkflowStepper(
                      business: business,
                      isAudited: business.isAudited || _auditResult != null,
                      isAuditing: _isAuditing || isAutoAuditing,
                      isAuditError: isAuditStateError && !business.isAudited,
                      autoAuditEnabled: autoAuditEnabled,
                      auditResult: _auditResult,
                      report: report,
                      isGenerating: _isGenerating,
                      outreach: outreach,
                      onAudit: () => _runAudit(business),
                      onRetryAudit: () => triggerAutoAudit(ref, business.id),
                      onGenerateReport: () => _generateReport(business),
                      onCompose: () async {
                        await context.push('/business/${business.id}/outreach');
                        ref.invalidate(outreachForBusinessProvider(business.id));
                      },
                      onShareReport: report != null ? () => _shareReport(report) : null,
                      onRegenerateReport: () => _generateReport(business),
                      onCopyOutreach: outreach != null ? () { Clipboard.setData(ClipboardData(text: outreach.content)); HapticFeedback.mediumImpact(); } : null,
                      onRedoOutreach: () async {
                        await context.push('/business/${business.id}/outreach');
                        ref.invalidate(outreachForBusinessProvider(business.id));
                      },
                    )
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: AppConstants.entranceSlideDistance / 100, duration: 500.ms, curve: Curves.easeOutCubic),

                    const SizedBox(height: AppConstants.sectionGap),

                    // Audit context (if audited)
                    if (business.isAudited || _auditResult != null)
                      AuditContext(business: business),

                    // Outreach history
                    const SizedBox(height: AppConstants.sectionGap),
                    _OutreachHistorySection(businessId: business.id),
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
// Contact icon card — tappable card with icon + label
// ---------------------------------------------------------------------------

class _ContactCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
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
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: AppConstants.quickAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(AppColors.chipInactive, context),
            borderRadius: BorderRadius.circular(AppColors.radiusM),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 22, color: CupertinoDynamicColor.resolve(AppColors.accent, context)),
              const SizedBox(height: 4),
              Text(widget.label, style: AppTypography.chip(context).copyWith(
                color: CupertinoDynamicColor.resolve(AppColors.textSecondary, context),
              )),
            ],
          ),
        ),
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
// Generating Report Animation
// ---------------------------------------------------------------------------

class _GeneratingReportAnimation extends StatefulWidget {
  @override
  State<_GeneratingReportAnimation> createState() =>
      _GeneratingReportAnimationState();
}

class _GeneratingReportAnimationState extends State<_GeneratingReportAnimation>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _pulseController;

  final List<_AnalysisStep> _steps = const [
    _AnalysisStep(CupertinoIcons.doc_chart_fill, 'Building PDF...'),
    _AnalysisStep(CupertinoIcons.cloud_upload, 'Uploading report...'),
    _AnalysisStep(CupertinoIcons.checkmark_seal, 'Saving record...'),
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
      await Future.delayed(const Duration(milliseconds: 800));
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
                  CupertinoIcons.doc_richtext,
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
                        key: ValueKey('report-$index-$isDone-$isActive'),
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

// ---------------------------------------------------------------------------
// Workflow Stepper
// ---------------------------------------------------------------------------

enum _StepState { completed, current, future }

class _WorkflowStepper extends StatelessWidget {
  final Business business;
  final bool isAudited;
  final bool isAuditing;
  final bool isAuditError;
  final bool autoAuditEnabled;
  final AuditResult? auditResult;
  final Report? report;
  final bool isGenerating;
  final Message? outreach;
  final VoidCallback onAudit;
  final VoidCallback onRetryAudit;
  final VoidCallback onGenerateReport;
  final VoidCallback onCompose;
  final VoidCallback? onShareReport;
  final VoidCallback? onRegenerateReport;
  final VoidCallback? onCopyOutreach;
  final VoidCallback? onRedoOutreach;

  const _WorkflowStepper({
    required this.business, required this.isAudited, required this.isAuditing,
    required this.isAuditError, required this.autoAuditEnabled,
    required this.auditResult, required this.report, required this.isGenerating,
    required this.outreach,
    required this.onAudit, required this.onRetryAudit,
    required this.onGenerateReport, required this.onCompose,
    this.onShareReport, this.onRegenerateReport,
    this.onCopyOutreach, this.onRedoOutreach,
  });

  @override
  Widget build(BuildContext context) {
    final auditState = isAuditing ? _StepState.current : isAudited ? _StepState.completed : _StepState.current;
    final reportState = !isAudited ? _StepState.future : isGenerating ? _StepState.current : report != null ? _StepState.completed : _StepState.current;
    final outreachState = !isAudited ? _StepState.future : outreach != null ? _StepState.completed : _StepState.current;

    return Column(children: [
      _WorkflowStep(stepNumber: 1, state: auditState, showConnector: true,
        connectorColor: auditState == _StepState.completed ? CupertinoDynamicColor.resolve(AppColors.scoreGood, context) : CupertinoDynamicColor.resolve(AppColors.divider, context),
        child: _buildAuditCard(context, auditState)),
      _WorkflowStep(stepNumber: 2, state: reportState, showConnector: true,
        connectorColor: reportState == _StepState.completed ? CupertinoDynamicColor.resolve(AppColors.scoreGood, context) : CupertinoDynamicColor.resolve(AppColors.divider, context),
        child: _buildReportCard(context, reportState)),
      _WorkflowStep(stepNumber: 3, state: outreachState, showConnector: false,
        child: _buildOutreachCard(context, outreachState)),
    ]);
  }

  Widget _buildAuditCard(BuildContext context, _StepState state) {
    if (isAuditing) return _AnalyzingAnimation();
    if (state == _StepState.completed) {
      final score = auditResult?.score ?? business.auditScore ?? 0;
      final diagnosis = auditResult?.diagnosis ?? business.auditDiagnosis ?? '';
      return _CompletedCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Audit Complete', style: AppTypography.titleMedium(context).copyWith(color: CupertinoDynamicColor.resolve(AppColors.scoreGood, context))),
        const SizedBox(height: 4),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(score.toString(), style: AppTypography.scoreLarge(context).copyWith(color: CupertinoDynamicColor.resolve(AppColors.scoreColor(score), context))),
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('/100', style: AppTypography.bodyMedium(context).copyWith(color: CupertinoDynamicColor.resolve(AppColors.textTertiary, context)))),
        ]),
        if (diagnosis.isNotEmpty) ...[const SizedBox(height: 6), Text(diagnosis, style: AppTypography.bodyMedium(context).copyWith(color: CupertinoDynamicColor.resolve(AppColors.textSecondary, context), height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis)],
      ]));
    }
    if (isAuditError) return _CtaCard(title: 'Retry Analysis', subtitle: 'Auto-analysis failed — tap to retry', onTap: onRetryAudit);
    return _CtaCard(title: 'Analyze Site', subtitle: 'AI will score their online presence', onTap: onAudit);
  }

  Widget _buildReportCard(BuildContext context, _StepState state) {
    if (isGenerating) {
      return _GeneratingReportAnimation();
    }
    if (state == _StepState.completed && report != null) {
      return _CompletedCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Audit Report', style: AppTypography.titleMedium(context).copyWith(color: CupertinoDynamicColor.resolve(AppColors.scoreGood, context))),
        const SizedBox(height: 4),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(report!.score.toString(), style: AppTypography.scoreLarge(context).copyWith(color: CupertinoDynamicColor.resolve(AppColors.scoreColor(report!.score), context))),
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('/100', style: AppTypography.bodyMedium(context).copyWith(color: CupertinoDynamicColor.resolve(AppColors.textTertiary, context)))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: AppButton(label: 'Share PDF', compact: true, onPressed: onShareReport)),
          const SizedBox(width: 8),
          Expanded(child: AppButton(label: 'Regenerate', compact: true, variant: AppButtonVariant.ghost, onPressed: onRegenerateReport)),
        ]),
      ]));
    }
    if (state == _StepState.future) return const _FutureCard(title: 'Generate Audit Report', subtitle: 'Complete audit first');
    return _CtaCard(title: 'Generate Audit Report', subtitle: 'Create a PDF report to share', onTap: onGenerateReport);
  }

  Widget _buildOutreachCard(BuildContext context, _StepState state) {
    if (state == _StepState.completed && outreach != null) {
      return _CompletedCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('Outreach Sent', style: AppTypography.titleMedium(context).copyWith(color: CupertinoDynamicColor.resolve(AppColors.scoreGood, context)))),
          Text(outreach!.channel.name, style: AppTypography.chip(context)),
        ]),
        const SizedBox(height: 6),
        Text(outreach!.content, style: AppTypography.bodyMedium(context).copyWith(color: CupertinoDynamicColor.resolve(AppColors.textSecondary, context)), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: AppButton(label: 'Copy', compact: true, onPressed: onCopyOutreach)),
          const SizedBox(width: 8),
          Expanded(child: AppButton(label: 'Regenerate', compact: true, variant: AppButtonVariant.ghost, onPressed: onRedoOutreach)),
        ]),
      ]));
    }
    if (state == _StepState.future) return const _FutureCard(title: 'Compose Outreach', subtitle: 'Complete audit first');
    return _CtaCard(title: 'Compose Outreach', subtitle: report == null ? 'Generate report first for best results' : 'Send a personalized pitch', onTap: onCompose);
  }
}

class _WorkflowStep extends StatelessWidget {
  final int stepNumber;
  final _StepState state;
  final bool showConnector;
  final Color? connectorColor;
  final Widget child;

  const _WorkflowStep({required this.stepNumber, required this.state, required this.child, this.showConnector = false, this.connectorColor});

  @override
  Widget build(BuildContext context) {
    final goodColor = CupertinoDynamicColor.resolve(AppColors.scoreGood, context);
    final accentColor = CupertinoDynamicColor.resolve(AppColors.accent, context);
    final inactiveColor = CupertinoDynamicColor.resolve(AppColors.chipInactive, context);
    final tertiaryColor = CupertinoDynamicColor.resolve(AppColors.textTertiary, context);

    return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 24, child: Column(children: [
        Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, color: switch (state) {
          _StepState.completed => goodColor, _StepState.current => accentColor, _StepState.future => inactiveColor,
        }), alignment: Alignment.center, child: state == _StepState.completed
            ? Icon(CupertinoIcons.checkmark, size: 12, color: CupertinoDynamicColor.resolve(AppColors.chipActiveFg, context))
            : Text('$stepNumber', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: state == _StepState.current ? CupertinoDynamicColor.resolve(AppColors.chipActiveFg, context) : tertiaryColor))),
        if (showConnector) Expanded(child: Container(width: 2, color: connectorColor ?? CupertinoDynamicColor.resolve(AppColors.divider, context))),
      ])),
      const SizedBox(width: 10),
      Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 8), child: child)),
    ]));
  }
}

class _CompletedCard extends StatelessWidget {
  final Widget child;
  const _CompletedCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(
      color: CupertinoDynamicColor.resolve(AppColors.scoreGoodBg, context),
      borderRadius: BorderRadius.circular(AppColors.radiusM),
      border: Border.all(color: CupertinoDynamicColor.resolve(AppColors.scoreGood, context).withValues(alpha: 0.3), width: 0.5),
    ), child: child);
  }
}

class _CtaCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _CtaCard({required this.title, required this.subtitle, required this.onTap});
  @override
  State<_CtaCard> createState() => _CtaCardState();
}

class _CtaCardState extends State<_CtaCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); Haptics.medium(); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(scale: _pressed ? 0.97 : 1.0, duration: AppConstants.quickAnimation,
        child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(AppColors.accent, context),
          borderRadius: BorderRadius.circular(AppColors.radiusM),
        ), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.title, style: AppTypography.titleMedium(context).copyWith(color: CupertinoDynamicColor.resolve(AppColors.chipActiveFg, context))),
            const SizedBox(height: 2),
            Text(widget.subtitle, style: AppTypography.chip(context).copyWith(color: CupertinoDynamicColor.resolve(AppColors.chipActiveFg, context).withValues(alpha: 0.7))),
          ])),
          Icon(CupertinoIcons.chevron_forward, size: 16, color: CupertinoDynamicColor.resolve(AppColors.chipActiveFg, context).withValues(alpha: 0.5)),
        ]))),
    );
  }
}

class _FutureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _FutureCard({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(
      color: CupertinoDynamicColor.resolve(AppColors.surface, context),
      borderRadius: BorderRadius.circular(AppColors.radiusM),
      border: Border.all(color: CupertinoDynamicColor.resolve(AppColors.border, context), width: 0.5),
    ), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppTypography.titleMedium(context).copyWith(color: CupertinoDynamicColor.resolve(AppColors.textTertiary, context))),
      const SizedBox(height: 2),
      Text(subtitle, style: AppTypography.chip(context).copyWith(color: CupertinoDynamicColor.resolve(AppColors.textTertiary, context))),
    ]));
  }
}

// ---------------------------------------------------------------------------
// Outreach history section — isolated ConsumerWidget so only this subtree
// rebuilds when messagesForBusinessProvider changes
// ---------------------------------------------------------------------------

class _OutreachHistorySection extends ConsumerWidget {
  final String businessId;

  const _OutreachHistorySection({required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesForBusinessProvider(businessId));
    return messagesAsync.when(
      data: (messages) => OutreachHistory(messages: messages),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
