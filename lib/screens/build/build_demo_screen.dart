import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import '../../widgets/brutal_button.dart';
import '../../widgets/ios_toast.dart';
import '../../widgets/forge_loader.dart';
import '../../widgets/glow_card.dart';
import '../../widgets/shimmer_text.dart';
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
  late ConfettiController _confettiController;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
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
    _confettiController.dispose();
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
        _confettiController.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBuilding = false);
        Haptics.heavy();
        IosToast.show(context, 'Error: $e', icon: CupertinoIcons.exclamationmark_triangle);
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
    IosToast.show(context, 'Link copied to clipboard', icon: CupertinoIcons.check_mark);
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const GradientText(
          text: 'Build Demo Site',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      body: Stack(
        children: [
          businessAsync.when(
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
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      business.name,
                      style: AppTypography.headlineLarge.copyWith(
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Business data summary — what AI will use
                    _BusinessDataSummary(business: business),
                    const SizedBox(height: 20),

                    // Custom notes for AI
                    Text(
                      'CUSTOM INSTRUCTIONS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      maxLength: 200,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'e.g. "Highlight their new menu" or "Focus on premium services"',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppColors.radiusM),
                          borderSide: BorderSide(
                            color: AppColors.border,
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppColors.radiusM),
                          borderSide: BorderSide(
                            color: AppColors.border,
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppColors.radiusM),
                          borderSide: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                        counterStyle: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_generatedDemo == null && !_isBuilding)
                      _GradientCTA(
                        label: 'Generate Demo Site',
                        icon: Icons.auto_awesome_rounded,
                        onPressed: () => _buildDemo(business),
                      ),

                    if (_isBuilding) _BuildingAnimation(),

                    if (_generatedDemo != null)
                      _DemoResult(
                        demo: _generatedDemo!,
                        onCopyLink: _copyLink,
                        onShare: _shareDemo,
                      ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: ForgeLoader(size: 40)),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 25,
              maxBlastForce: 12,
              minBlastForce: 4,
              gravity: 0.15,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.primaryLight,
                AppColors.success,
                AppColors.secondary,
              ],
            ),
          ),
        ],
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
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppColors.radiusM),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 20, color: AppColors.background),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: AppTypography.button
                    .copyWith(color: AppColors.background, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Building animation with glow card
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
    return GlowCard(
      glowColor: AppColors.primary,
      animateBorder: true,
      glowIntensity: 0.5,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const ForgeLoader(),
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
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      key: ValueKey('step-$index-$isDone'),
                      size: 18,
                      color: isActive
                          ? AppColors.primary
                          : isDone
                              ? AppColors.success
                              : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
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

// Demo result with glow
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
    return GlowCard(
      glowColor: AppColors.success,
      glowIntensity: 0.5,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.2),
                  AppColors.success.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
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
          const GradientText(
            text: 'Demo Site Created!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            colors: [AppColors.success, Color(0xFF6EE7B7)],
          ),
          const SizedBox(height: 4),
          Text(
            'Share this link with your prospect',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),

          // URL display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppColors.radiusM),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    demo.publicUrl,
                    style: AppTypography.mono.copyWith(
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () => onCopyLink(demo.publicUrl),
                  color: AppColors.primary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Analytics row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppColors.radiusM),
            ),
            child: Row(
              children: [
                const Icon(Icons.visibility_rounded, size: 16,
                    color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Text(
                  '${demo.views} view${demo.views == 1 ? '' : 's'}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (demo.lastViewedAt != null) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.schedule_rounded, size: 16,
                      color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    _timeAgo(demo.lastViewedAt!),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
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
                child: BrutalButton.secondary(
                  label: 'Share',
                  icon: Icons.share,
                  onPressed: onShare,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BrutalButton(
                  label: 'Open',
                  icon: Icons.open_in_new,
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
        .slideY(begin: 0.08, duration: 400.ms, curve: Curves.easeOut);
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

// Business data summary — shows what AI will use to personalize the demo
class _BusinessDataSummary extends StatelessWidget {
  final Business business;

  const _BusinessDataSummary({required this.business});

  @override
  Widget build(BuildContext context) {
    final items = <_DataItem>[];

    if (business.categories.isNotEmpty) {
      items.add(_DataItem(
        icon: Icons.category_rounded,
        label: 'Categories',
        value: business.categories.take(3).join(', '),
        color: AppColors.primary,
      ));
    }

    if (business.rating != null) {
      items.add(_DataItem(
        icon: Icons.star_rounded,
        label: 'Rating',
        value:
            '${business.rating}/5 (${business.reviewsCount} reviews)',
        color: AppColors.warning,
      ));
    }

    if (business.auditScore != null) {
      items.add(_DataItem(
        icon: Icons.query_stats_rounded,
        label: 'Audit Score',
        value: '${business.auditScore}/100',
        color: business.auditScore! >= 60
            ? AppColors.success
            : business.auditScore! >= 30
                ? AppColors.warning
                : AppColors.danger,
      ));
    }

    if (business.phone != null) {
      items.add(_DataItem(
        icon: Icons.phone_rounded,
        label: 'Phone',
        value: business.phone!,
        color: AppColors.success,
      ));
    }

    if (business.website != null) {
      items.add(_DataItem(
        icon: Icons.language_rounded,
        label: 'Website',
        value: business.website!.replaceAll(RegExp(r'^https?://'), ''),
        color: AppColors.info,
      ));
    }

    if (business.openingHours != null) {
      items.add(_DataItem(
        icon: Icons.schedule_rounded,
        label: 'Hours',
        value: 'Available',
        color: AppColors.secondary,
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
              Icons.auto_awesome_rounded,
              size: 14,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'AI WILL USE THIS DATA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radiusM),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map((item) => _DataChip(item: item))
                .toList(),
          ),
        ),
        if (business.auditDiagnosis != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppColors.radiusS),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    business.auditDiagnosis!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
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
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
