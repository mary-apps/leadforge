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
  DemoTemplate _selectedTemplate = DemoTemplate.restaurant;
  bool _isBuilding = false;
  Demo? _generatedDemo;

  Future<void> _buildDemo(Business business) async {
    // Check limit
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
        template: _selectedTemplate,
      );

      if (mounted) {
        setState(() {
          _generatedDemo = demo;
          _isBuilding = false;
        });
        Haptics.medium();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBuilding = false);
        Haptics.heavy();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showPaywall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusXL),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Demo Limit Reached'),
          ],
        ),
        content: const Text(
          'You\'ve used your free demo this month. Upgrade to Pro for unlimited demos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          BrutalButton(
            label: 'Upgrade to Pro',
            icon: Icons.workspace_premium,
            compact: true,
            onPressed: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
        ],
      ),
    );
  }

  void _copyLink(String url) {
    Clipboard.setData(ClipboardData(text: url));
    Haptics.medium();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Link copied to clipboard'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
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
        title: Text(
          'Build Demo Site',
          style: AppTypography.titleMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: businessAsync.when(
        data: (business) {
          if (business == null) {
            return const Center(child: Text('Business not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
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
                const SizedBox(height: 32),

                // Template selector
                Text(
                  'TEMPLATE',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 12),

                _TemplateCard(
                  template: DemoTemplate.restaurant,
                  isSelected: _selectedTemplate == DemoTemplate.restaurant,
                  onTap: () {
                    setState(
                        () => _selectedTemplate = DemoTemplate.restaurant);
                    Haptics.light();
                  },
                ),
                const SizedBox(height: 8),

                _TemplateCard(
                  template: DemoTemplate.professional,
                  isSelected:
                      _selectedTemplate == DemoTemplate.professional,
                  onTap: () {
                    setState(() =>
                        _selectedTemplate = DemoTemplate.professional);
                    Haptics.light();
                  },
                ),
                const SizedBox(height: 8),

                _TemplateCard(
                  template: DemoTemplate.healthBeauty,
                  isSelected:
                      _selectedTemplate == DemoTemplate.healthBeauty,
                  onTap: () {
                    setState(() =>
                        _selectedTemplate = DemoTemplate.healthBeauty);
                    Haptics.light();
                  },
                ),
                const SizedBox(height: 32),

                // Build button or demo result
                if (_generatedDemo == null && !_isBuilding)
                  BrutalButton(
                    label: 'Generate Demo Site',
                    icon: Icons.web,
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

/// Template selection card
class _TemplateCard extends StatelessWidget {
  final DemoTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final info = _getTemplateInfo(template);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppColors.radiusXL),
        ),
        child: Row(
          children: [
            Icon(
              info['icon'] as IconData,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textTertiary,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info['name'] as String,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info['description'] as String,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getTemplateInfo(DemoTemplate template) {
    switch (template) {
      case DemoTemplate.restaurant:
        return {
          'name': 'Restaurant',
          'description': 'Perfect for cafes, bars, and eateries',
          'icon': Icons.restaurant_menu,
        };
      case DemoTemplate.professional:
        return {
          'name': 'Professional Services',
          'description': 'Lawyers, accountants, consultants',
          'icon': Icons.business_center,
        };
      case DemoTemplate.healthBeauty:
        return {
          'name': 'Health & Beauty',
          'description': 'Salons, spas, clinics',
          'icon': Icons.spa,
        };
    }
  }
}

/// Building animation widget
class _BuildingAnimation extends StatefulWidget {
  @override
  State<_BuildingAnimation> createState() => _BuildingAnimationState();
}

class _BuildingAnimationState extends State<_BuildingAnimation> {
  int _currentStep = 0;

  final List<String> _steps = [
    'Creating HTML structure...',
    'Applying styles...',
    'Adding business info...',
    'Generating unique URL...',
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
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    isDone ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                    color: isActive
                        ? AppColors.primary
                        : isDone
                            ? AppColors.success
                            : AppColors.textTertiary,
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

/// Demo result widget
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusXL),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 48,
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
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.success,
            ),
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
          const SizedBox(height: 16),

          // Action buttons
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
}
