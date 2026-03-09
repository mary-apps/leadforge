import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../models/demo.dart';
import '../../services/build_service.dart';
import '../../providers/businesses_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/animated_button.dart';
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
    if (profile != null && !profile.canBuildDemo) {
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
      final demo = await BuildService.buildDemo(
        business.id,
        _selectedTemplate,
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
        title: Row(
          children: [
            Icon(Icons.lock, color: AppColors.warning),
            const SizedBox(width: 8),
            const Text('Demo Limit Reached'),
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
          AnimatedButton.primary(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to settings
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Link copied to clipboard'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _shareDemo() {
    // TODO: Implement native share sheet
    Haptics.light();
  }
  
  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(businessProvider(widget.businessId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Demo Site'),
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
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  business.name,
                  style: AppTypography.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Template selector
                Text(
                  'Choose Template',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 16),
                
                _TemplateCard(
                  template: DemoTemplate.restaurant,
                  isSelected: _selectedTemplate == DemoTemplate.restaurant,
                  onTap: () {
                    setState(() => _selectedTemplate = DemoTemplate.restaurant);
                    Haptics.light();
                  },
                ),
                const SizedBox(height: 12),
                
                _TemplateCard(
                  template: DemoTemplate.professional,
                  isSelected: _selectedTemplate == DemoTemplate.professional,
                  onTap: () {
                    setState(() => _selectedTemplate = DemoTemplate.professional);
                    Haptics.light();
                  },
                ),
                const SizedBox(height: 12),
                
                _TemplateCard(
                  template: DemoTemplate.healthBeauty,
                  isSelected: _selectedTemplate == DemoTemplate.healthBeauty,
                  onTap: () {
                    setState(() => _selectedTemplate = DemoTemplate.healthBeauty);
                    Haptics.light();
                  },
                ),
                const SizedBox(height: 32),
                
                // Build button or demo result
                if (_generatedDemo == null && !_isBuilding)
                  AnimatedButton.primary(
                    onPressed: () => _buildDemo(business),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.web, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Generate Demo Site'),
                      ],
                    ),
                  ),
                
                if (_isBuilding)
                  _BuildingAnimation(),
                
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
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              info['icon'] as IconData,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 32,
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
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info['description'] as String,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
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
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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
        .scale(begin: const Offset(0.95, 0.95), duration: 300.ms);
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 64,
          )
              .animate()
              .scale(
                delay: 100.ms,
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 16),
          Text(
            'Demo Site Created!',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share this link with your prospect',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          // URL display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    demo.publicUrl,
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'SF Mono',
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () => onCopyLink(demo.publicUrl),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: AnimatedButton(
                  onPressed: onShare,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Share'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedButton.primary(
                  onPressed: () {
                    // Open in browser
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.open_in_new, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Open'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOut);
  }
}
