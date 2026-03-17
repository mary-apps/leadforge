import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../models/demo.dart';
import '../../services/build_service.dart';
import '../../providers/businesses_provider.dart';
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/ios_toast.dart';
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
        IosToast.show(context, 'Demo created!');
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
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Demo Limit Reached'),
        content: const Text(
          'You\'ve used your free demo this month. Upgrade to Pro for unlimited demos.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              context.push('/settings');
            },
            child: const Text('Upgrade to Pro'),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(businessProvider(widget.businessId));
    final bg = CupertinoDynamicColor.resolve(AppColors.background, context);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      child: SafeArea(
        child: businessAsync.when(
          data: (business) {
            if (business == null) {
              return Center(
                child: Text(
                  'Business not found',
                  style: AppTypography.bodyMedium(context),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pageHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Back nav
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      '\u2190 ${business.name}',
                      style: AppTypography.bodyMedium(context).copyWith(
                        color: CupertinoDynamicColor.resolve(
                          AppColors.textSecondary,
                          context,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.sectionGap),

                  // Title
                  Text(
                    'Create Demo',
                    style: AppTypography.headlineLarge(context),
                  ),
                  const SizedBox(height: AppConstants.sectionGap),

                  // Business data summary
                  _BusinessDataSummary(business: business),
                  const SizedBox(height: AppConstants.sectionGap),

                  // Custom notes label
                  Text(
                    'CUSTOM INSTRUCTIONS',
                    style: AppTypography.labelSmall(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                        AppColors.textTertiary,
                        context,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.chipGap),

                  // Notes field — search field styling, multi-line
                  CupertinoTextField(
                    controller: _notesController,
                    maxLines: 3,
                    maxLength: 200,
                    style: AppTypography.bodyMedium(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                        AppColors.textPrimary,
                        context,
                      ),
                    ),
                    placeholder:
                        'e.g. "Highlight their new menu" or "Focus on premium services"',
                    placeholderStyle: AppTypography.bodyMedium(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                        AppColors.textTertiary,
                        context,
                      ),
                      fontSize: 13,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoDynamicColor.resolve(
                        AppColors.searchField,
                        context,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppColors.radiusM),
                    ),
                  ),
                  const SizedBox(height: AppConstants.sectionGap),

                  // Generate button
                  if (_generatedDemo == null && !_isBuilding)
                    AppButton(
                      label: 'Generate Demo',
                      onPressed: () => _buildDemo(business),
                    ),

                  if (_isBuilding) _BuildingAnimation(),

                  if (_generatedDemo != null)
                    _DemoResult(
                      demo: _generatedDemo!,
                      onCopyLink: _copyLink,
                      onShare: _shareDemo,
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, _) => Center(
            child: Text(
              'Error: $error',
              style: AppTypography.bodyMedium(context),
            ),
          ),
        ),
      ),
    );
  }
}

// Building animation
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
      padding: const EdgeInsets.all(AppConstants.pageHorizontal),
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
                      color: CupertinoDynamicColor.resolve(
                        isActive
                            ? AppColors.accent
                            : isDone
                                ? AppColors.scoreGood
                                : AppColors.textTertiary,
                        context,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _steps[index],
                      style: AppTypography.bodyMedium(context).copyWith(
                        color: CupertinoDynamicColor.resolve(
                          isActive
                              ? AppColors.textPrimary
                              : isDone
                                  ? AppColors.textSecondary
                                  : AppColors.textTertiary,
                          context,
                        ),
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
        .fadeIn(duration: 300.ms);
  }
}

// Demo result card
class _DemoResult extends StatelessWidget {
  final Demo demo;
  final Function(String) onCopyLink;
  final VoidCallback onShare;

  const _DemoResult({
    required this.demo,
    required this.onCopyLink,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.pageHorizontal),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(AppColors.surface, context),
        borderRadius: BorderRadius.circular(AppColors.radiusM),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoDynamicColor.resolve(
                AppColors.scoreGoodBg,
                context,
              ),
            ),
            child: Icon(
              CupertinoIcons.check_mark_circled_solid,
              color: CupertinoDynamicColor.resolve(
                AppColors.scoreGood,
                context,
              ),
              size: 32,
            ),
          )
              .animate()
              .scale(
                delay: 100.ms,
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 16),
          Text(
            'Demo Site Created!',
            style: AppTypography.titleMedium(context).copyWith(
              color: CupertinoDynamicColor.resolve(
                AppColors.scoreGood,
                context,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.contentGap),
          Text(
            'Share this link with your prospect',
            style: AppTypography.bodyMedium(context).copyWith(
              color: CupertinoDynamicColor.resolve(
                AppColors.textTertiary,
                context,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // URL display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                AppColors.background,
                context,
              ),
              borderRadius: BorderRadius.circular(AppColors.radiusM),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    demo.publicUrl,
                    style: AppTypography.mono(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                        AppColors.accent,
                        context,
                      ),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(24, 24),
                  onPressed: () => onCopyLink(demo.publicUrl),
                  child: const Icon(CupertinoIcons.doc_on_doc, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Analytics row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                AppColors.searchField,
                context,
              ),
              borderRadius: BorderRadius.circular(AppColors.radiusM),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.eye,
                  size: 16,
                  color: CupertinoDynamicColor.resolve(
                    AppColors.textTertiary,
                    context,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${demo.views} view${demo.views == 1 ? '' : 's'}',
                  style: AppTypography.bodyMedium(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                      AppColors.textSecondary,
                      context,
                    ),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (demo.lastViewedAt != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    CupertinoIcons.clock,
                    size: 16,
                    color: CupertinoDynamicColor.resolve(
                      AppColors.textTertiary,
                      context,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _timeAgo(demo.lastViewedAt!),
                    style: AppTypography.bodyMedium(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                        AppColors.textTertiary,
                        context,
                      ),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Share',
                  variant: AppButtonVariant.secondary,
                  onPressed: onShare,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Open',
                  onPressed: () {
                    launchUrl(Uri.parse(demo.publicUrl),
                        mode: LaunchMode.externalApplication);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(
          begin: AppConstants.entranceSlideDistance / 100,
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  static String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
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
      ));
    }

    if (business.rating != null) {
      items.add(_DataItem(
        icon: CupertinoIcons.star_fill,
        label: 'Rating',
        value: '${business.rating}/5 (${business.reviewsCount} reviews)',
      ));
    }

    if (business.auditScore != null) {
      items.add(_DataItem(
        icon: CupertinoIcons.chart_bar,
        label: 'Audit Score',
        value: '${business.auditScore}/100',
      ));
    }

    if (business.phone != null) {
      items.add(_DataItem(
        icon: CupertinoIcons.phone,
        label: 'Phone',
        value: business.phone!,
      ));
    }

    if (business.website != null) {
      items.add(_DataItem(
        icon: CupertinoIcons.globe,
        label: 'Website',
        value: business.website!.replaceAll(RegExp(r'^https?://'), ''),
      ));
    }

    if (business.openingHours != null) {
      items.add(const _DataItem(
        icon: CupertinoIcons.clock,
        label: 'Hours',
        value: 'Available',
      ));
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI WILL USE THIS DATA',
          style: AppTypography.labelSmall(context).copyWith(
            color: CupertinoDynamicColor.resolve(
              AppColors.textTertiary,
              context,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.chipGap),
        Wrap(
          spacing: AppConstants.chipGap,
          runSpacing: AppConstants.chipGap,
          children: items.map((item) => _DataChip(item: item)).toList(),
        ),
        if (business.auditDiagnosis != null) ...[
          const SizedBox(height: AppConstants.itemGap),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                AppColors.searchField,
                context,
              ),
              borderRadius: BorderRadius.circular(AppColors.radiusS),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.lightbulb,
                  size: 16,
                  color: CupertinoDynamicColor.resolve(
                    AppColors.scoreMid,
                    context,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    business.auditDiagnosis!,
                    style: AppTypography.bodyMedium(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                        AppColors.textSecondary,
                        context,
                      ),
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

  const _DataItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _DataChip extends StatelessWidget {
  final _DataItem item;

  const _DataChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(AppColors.chipInactive, context),
        borderRadius: BorderRadius.circular(AppColors.radiusXL),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            size: 14,
            color: CupertinoDynamicColor.resolve(
              AppColors.textSecondary,
              context,
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              '${item.label}: ${item.value}',
              style: AppTypography.chip(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
