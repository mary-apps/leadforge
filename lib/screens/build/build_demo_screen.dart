import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../models/demo.dart';
import '../../services/build_service.dart';
import '../../providers/businesses_provider.dart';
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/error_state.dart';
import '../../widgets/ios_toast.dart';
import '../../widgets/paywall_dialog.dart';
import '../../utils/haptics.dart';

class BuildDemoScreen extends ConsumerStatefulWidget {
  final String businessId;

  const BuildDemoScreen({
    super.key,
    required this.businessId,
  });

  @override
  ConsumerState<BuildDemoScreen> createState() => _BuildDemoScreenState();
}

class _BuildDemoScreenState extends ConsumerState<BuildDemoScreen> {
  bool _isBuilding = false;
  Demo? _generatedDemo;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingDemo();
  }

  Future<void> _loadExistingDemo() async {
    final demo = await BuildService.fetchDemo(widget.businessId);
    if (demo != null && mounted) {
      setState(() => _generatedDemo = demo);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _buildDemo(Business business) async {
    final profile = ref.read(profileNotifierProvider).value;
    if (profile != null && !profile.canCreateDemo) {
      Haptics.heavy();
      _showPaywall();
      return;
    }

    setState(() {
      _isBuilding = true;
      _generatedDemo = null;
    });
    Haptics.medium();

    try {
      final demo = await BuildService.generateDemo(
        businessId: business.id,
        customNotes: _notesController.text,
      );

      if (mounted) {
        setState(() {
          _generatedDemo = demo;
          _isBuilding = false;
        });
        Haptics.medium();
        _openPreview(demo);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBuilding = false);
        Haptics.heavy();
        IosToast.show(context, 'Error: $e');
      }
    }
  }

  void _showPaywall() {
    showPaywallDialog(
      context,
      title: 'Demo Limit Reached',
      message: 'You\'ve used your free demo this month. Upgrade to Pro for unlimited demos.',
    );
  }

  void _copyLink(String url) {
    Clipboard.setData(ClipboardData(text: url));
    Haptics.medium();
    IosToast.show(context, 'Link copied to clipboard');
  }

  void _shareDemo() {
    if (_generatedDemo == null) return;
    Haptics.light();
    Share.share(
      'Check out this demo website I built for you: ${_generatedDemo!.publicUrl}',
      subject: 'Demo Website',
    );
  }

  void _openPreview(Demo demo) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => _DemoPreviewScreen(
          demo: demo,
          onRegenerate: () {
            Navigator.of(context).pop();
            final businessAsync = ref.read(businessProvider(widget.businessId));
            final business = businessAsync.value;
            if (business != null) _buildDemo(business);
          },
          onShare: _shareDemo,
          onCopyLink: _copyLink,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(businessProvider(widget.businessId));

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Build Demo Site'),
      ),
      child: SafeArea(
        child: businessAsync.when(
          data: (business) {
            if (business == null) {
              return const Center(child: Text('Business not found'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create a demo website for',
                    style: AppTypography.bodyMedium(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                          AppColors.textTertiary, context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    business.name,
                    style: AppTypography.headlineLarge(context).copyWith(
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Business data summary
                  _BusinessDataSummary(business: business),
                  const SizedBox(height: 20),

                  // Custom notes for AI
                  Text(
                    'CUSTOM INSTRUCTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: CupertinoDynamicColor.resolve(
                          AppColors.textTertiary, context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _notesController,
                    maxLines: 3,
                    maxLength: 200,
                    style: AppTypography.bodyMedium(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                          AppColors.textPrimary, context),
                    ),
                    placeholder:
                        'e.g. "Highlight their new menu" or "Focus on premium services"',
                    placeholderStyle:
                        AppTypography.bodyMedium(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                          AppColors.textTertiary, context),
                      fontSize: 13,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: CupertinoDynamicColor.resolve(
                          AppColors.surface, context),
                      borderRadius:
                          BorderRadius.circular(AppColors.radiusM),
                      border: Border.all(
                        color: CupertinoDynamicColor.resolve(
                            AppColors.border, context),
                        width: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_generatedDemo == null && !_isBuilding)
                    _GradientCTA(
                      label: 'Generate Demo Site',
                      icon: CupertinoIcons.sparkles,
                      onPressed: () => _buildDemo(business),
                    ),

                  if (_isBuilding) _BuildingAnimation(),

                  if (_generatedDemo != null) ...[
                    _DemoReadyCard(
                      demo: _generatedDemo!,
                      onPreview: () => _openPreview(_generatedDemo!),
                      onShare: _shareDemo,
                      onCopyLink: _copyLink,
                      onRegenerate: () => _buildDemo(business),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, _) => ErrorState(
            error: error,
            onRetry: () => ref.invalidate(businessProvider(widget.businessId)),
          ),
        ),
      ),
    );
  }
}

// Gradient CTA button
class _GradientCTA extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _GradientCTA({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_GradientCTA> createState() => _GradientCTAState();
}

class _GradientCTAState extends State<_GradientCTA> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accentColor =
        CupertinoDynamicColor.resolve(AppColors.accent, context);
    final bgColor =
        CupertinoDynamicColor.resolve(AppColors.background, context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Haptics.medium();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(AppColors.radiusM),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.3),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 20, color: bgColor),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: AppTypography.button(context)
                    .copyWith(color: bgColor, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Building animation card
class _BuildingAnimation extends StatefulWidget {
  @override
  State<_BuildingAnimation> createState() => _BuildingAnimationState();
}

class _BuildingAnimationState extends State<_BuildingAnimation> {
  int _currentStep = 0;

  final List<String> _steps = [
    'Analyzing business profile...',
    'AI generating personalized content...',
    'Building responsive layout...',
    'Publishing demo site...',
  ];

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(AppColors.surface, context),
        borderRadius: BorderRadius.circular(AppColors.radiusM),
      ),
      child: Column(
        children: [
          const CupertinoActivityIndicator(radius: 16),
          const SizedBox(height: 24),
          ...List.generate(_steps.length, (index) {
            final isActive = index == _currentStep;
            final isDone = index < _currentStep;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isDone
                          ? CupertinoIcons.check_mark_circled_solid
                          : CupertinoIcons.circle,
                      key: ValueKey('step-$index-$isDone'),
                      size: 18,
                      color: isActive
                          ? CupertinoDynamicColor.resolve(
                              AppColors.accent, context)
                          : isDone
                              ? CupertinoDynamicColor.resolve(
                                  AppColors.scoreGood, context)
                              : CupertinoDynamicColor.resolve(
                                  AppColors.textTertiary, context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _steps[index],
                      style: AppTypography.bodyMedium(context).copyWith(
                        color: isActive
                            ? CupertinoDynamicColor.resolve(
                                AppColors.textPrimary, context)
                            : isDone
                                ? CupertinoDynamicColor.resolve(
                                    AppColors.textSecondary, context)
                                : CupertinoDynamicColor.resolve(
                                    AppColors.textTertiary, context),
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.97, 0.97), duration: 300.ms);
  }
}

// Compact card shown when demo exists — primary action is Preview
class _DemoReadyCard extends StatelessWidget {
  final Demo demo;
  final VoidCallback onPreview;
  final VoidCallback onShare;
  final Function(String) onCopyLink;
  final VoidCallback onRegenerate;

  const _DemoReadyCard({
    required this.demo,
    required this.onPreview,
    required this.onShare,
    required this.onCopyLink,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Preview CTA — the hero action
        _GradientCTA(
          label: 'Preview Demo Site',
          icon: CupertinoIcons.eye,
          onPressed: onPreview,
        ),
        const SizedBox(height: 16),

        // URL + copy
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(AppColors.surface, context),
            borderRadius: BorderRadius.circular(AppColors.radiusM),
            border: Border.all(
              color: CupertinoDynamicColor.resolve(AppColors.border, context),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  demo.publicUrl,
                  style: AppTypography.mono(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.textSecondary, context),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(24, 24),
                onPressed: () => onCopyLink(demo.publicUrl),
                child: Icon(
                  CupertinoIcons.doc_on_doc,
                  size: 16,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.accent, context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Secondary actions
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Share',
                onPressed: onShare,
                variant: AppButtonVariant.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Regenerate',
                onPressed: onRegenerate,
                variant: AppButtonVariant.ghost,
              ),
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.08, duration: 400.ms, curve: Curves.easeOut);
  }
}

// Full-screen preview with WebView + action bar
class _DemoPreviewScreen extends StatefulWidget {
  final Demo demo;
  final VoidCallback onRegenerate;
  final VoidCallback onShare;
  final Function(String) onCopyLink;

  const _DemoPreviewScreen({
    required this.demo,
    required this.onRegenerate,
    required this.onShare,
    required this.onCopyLink,
  });

  @override
  State<_DemoPreviewScreen> createState() => _DemoPreviewScreenState();
}

class _DemoPreviewScreenState extends State<_DemoPreviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      );
    _fetchAndLoadHtml();
  }

  Future<void> _fetchAndLoadHtml() async {
    try {
      final response = await http.get(Uri.parse(widget.demo.publicUrl));
      if (response.statusCode == 200) {
        await _controller.loadHtmlString(response.body);
      } else {
        if (mounted) setState(() => _error = 'Could not load demo');
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Connection error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor =
        CupertinoDynamicColor.resolve(AppColors.accent, context);
    final bgColor =
        CupertinoDynamicColor.resolve(AppColors.background, context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Demo Preview'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            launchUrl(Uri.parse(widget.demo.publicUrl),
                mode: LaunchMode.externalApplication);
          },
          child: Icon(
            CupertinoIcons.arrow_up_right_square,
            size: 20,
            color: accentColor,
          ),
        ),
      ),
      child: Column(
        children: [
          // WebView
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading && _error == null)
                  const Center(child: CupertinoActivityIndicator(radius: 14)),
                if (_error != null)
                  Center(
                    child: Text(
                      _error!,
                      style: AppTypography.bodyLarge(context).copyWith(
                        color: CupertinoDynamicColor.resolve(
                            AppColors.textSecondary, context),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom action bar
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border(
                top: BorderSide(
                  color: CupertinoDynamicColor.resolve(
                      AppColors.divider, context),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Regenerate',
                    onPressed: () {
                      Haptics.medium();
                      widget.onRegenerate();
                    },
                    variant: AppButtonVariant.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Share',
                    onPressed: () {
                      Haptics.light();
                      widget.onShare();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Business data summary
class _BusinessDataSummary extends StatelessWidget {
  final Business business;

  const _BusinessDataSummary({required this.business});

  @override
  Widget build(BuildContext context) {
    final items = <_DataItem>[];

    if (business.categories.isNotEmpty) {
      items.add(_DataItem(
        icon: CupertinoIcons.tag,
        label: 'Categories',
        value: business.categories.take(3).join(', '),
        color: CupertinoDynamicColor.resolve(AppColors.accent, context),
      ));
    }

    if (business.rating != null) {
      items.add(_DataItem(
        icon: CupertinoIcons.star_fill,
        label: 'Rating',
        value: '${business.rating}/5 (${business.reviewsCount} reviews)',
        color: CupertinoDynamicColor.resolve(AppColors.scoreMid, context),
      ));
    }

    if (business.auditScore != null) {
      items.add(_DataItem(
        icon: CupertinoIcons.chart_bar,
        label: 'Audit Score',
        value: '${business.auditScore}/100',
        color: business.auditScore! >= 60
            ? CupertinoDynamicColor.resolve(AppColors.scoreGood, context)
            : business.auditScore! >= 30
                ? CupertinoDynamicColor.resolve(AppColors.scoreMid, context)
                : CupertinoDynamicColor.resolve(
                    AppColors.scoreBad, context),
      ));
    }

    if (business.phone != null) {
      items.add(_DataItem(
        icon: CupertinoIcons.phone,
        label: 'Phone',
        value: business.phone!,
        color: CupertinoDynamicColor.resolve(AppColors.scoreGood, context),
      ));
    }

    if (business.website != null) {
      items.add(_DataItem(
        icon: CupertinoIcons.globe,
        label: 'Website',
        value: business.website!.replaceAll(RegExp(r'^https?://'), ''),
        color: CupertinoDynamicColor.resolve(AppColors.accent, context),
      ));
    }

    if (business.openingHours != null) {
      items.add(_DataItem(
        icon: CupertinoIcons.clock,
        label: 'Hours',
        value: 'Available',
        color: CupertinoDynamicColor.resolve(
            AppColors.textSecondary, context),
      ));
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              CupertinoIcons.sparkles,
              size: 14,
              color: CupertinoDynamicColor.resolve(
                  AppColors.accent, context),
            ),
            const SizedBox(width: 6),
            Text(
              'AI WILL USE THIS DATA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: CupertinoDynamicColor.resolve(
                    AppColors.textTertiary, context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
                AppColors.surface, context),
            borderRadius: BorderRadius.circular(AppColors.radiusM),
            border: Border.all(
              color: CupertinoDynamicColor.resolve(
                      AppColors.accent, context)
                  .withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) => _DataChip(item: item)).toList(),
          ),
        ),
        if (business.auditDiagnosis != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                  AppColors.surface, context),
              borderRadius: BorderRadius.circular(AppColors.radiusS),
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
                    business.auditDiagnosis!,
                    style: AppTypography.bodyMedium(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                          AppColors.textSecondary, context),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DataItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DataItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _DataChip extends StatelessWidget {
  final _DataItem item;

  const _DataChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.color.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 14, color: item.color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              '${item.label}: ${item.value}',
              style: AppTypography.bodyMedium(context).copyWith(
                fontSize: 12,
                color: CupertinoDynamicColor.resolve(
                    AppColors.textSecondary, context),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
