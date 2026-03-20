import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/ios_toast.dart';
import '../../utils/haptics.dart';

class OnboardingScreenEnhanced extends ConsumerStatefulWidget {
  const OnboardingScreenEnhanced({super.key});

  @override
  ConsumerState<OnboardingScreenEnhanced> createState() =>
      _OnboardingScreenEnhancedState();
}

class _OnboardingScreenEnhancedState
    extends ConsumerState<OnboardingScreenEnhanced> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();

  int _currentPage = 0;
  bool _isLoading = false;
  bool _nameValid = false;
  bool _businessValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
    _businessController.addListener(_validateBusiness);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  void _validateName() {
    setState(() {
      _nameValid = _nameController.text.trim().length >= 2;
    });
  }

  void _validateBusiness() {
    setState(() {
      _businessValid = _businessController.text.trim().length >= 2;
    });
  }

  Future<void> _skipConfirmation() async {
    Haptics.light();
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Skip Tutorial?'),
        content: const Text(
          'This quick tour helps you understand LeadForge\'s features. Are you sure you want to skip?',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Skip'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Haptics.medium();
      _pageController.animateToPage(
        4,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _complete() async {
    if (!_nameValid || !_businessValid) return;

    setState(() => _isLoading = true);
    Haptics.medium();

    try {
      await ref.read(authProvider.notifier).completeOnboarding(
            displayName: _nameController.text.trim(),
            businessName: _businessController.text.trim(),
          );

      Haptics.heavy();

      // Navigate to dashboard after onboarding
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      Haptics.heavy();
      if (mounted) {
        IosToast.show(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                  Haptics.light();
                },
                children: [
                  const _OnboardingPage(
                    icon: CupertinoIcons.search,
                    title: 'Find Hidden Opportunities',
                    description:
                        'Search for businesses with poor or no web presence in any niche.',
                    pageIndex: 0,
                  ),
                  const _OnboardingPage(
                    icon: CupertinoIcons.chart_bar,
                    title: 'AI-Powered Analysis',
                    description:
                        'Get instant insights on website quality, SEO gaps, and online reputation.',
                    pageIndex: 1,
                  ),
                  const _OnboardingPage(
                    icon: CupertinoIcons.globe,
                    title: 'Generate Demo Sites',
                    description:
                        'Create professional demo websites in seconds to showcase your work.',
                    pageIndex: 2,
                  ),
                  const _OnboardingPage(
                    icon: CupertinoIcons.bubble_left_bubble_right,
                    title: 'Personalized Outreach',
                    description:
                        'AI writes custom messages for email, WhatsApp, Instagram, or phone.',
                    pageIndex: 3,
                  ),
                  _ProfileSetupPage(
                    nameController: _nameController,
                    businessController: _businessController,
                    nameValid: _nameValid,
                    businessValid: _businessValid,
                  ),
                ],
              ),
            ),

            // Page indicator dots
            if (_currentPage < 4)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => AnimatedContainer(
                    duration: AppConstants.standardAnimation,
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPage
                          ? CupertinoDynamicColor.resolve(
                              AppColors.accent, context)
                          : CupertinoDynamicColor.resolve(
                              AppColors.divider, context),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppConstants.sectionGap),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.pageHorizontal,
                0,
                AppConstants.pageHorizontal,
                AppConstants.pageHorizontal,
              ),
              child: _currentPage < 4
                  ? Column(
                      children: [
                        AppButton(
                          label: 'Next',
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          },
                        ),
                        const SizedBox(height: AppConstants.itemGap),
                        GestureDetector(
                          onTap: _skipConfirmation,
                          child: Text(
                            'Skip',
                            style: AppTypography.bodyMedium(context).copyWith(
                              color: CupertinoDynamicColor.resolve(
                                  AppColors.textTertiary, context),
                            ),
                          ),
                        ),
                      ],
                    )
                  : AppButton(
                      label: 'Get Started',
                      isLoading: _isLoading,
                      onPressed:
                          (_nameValid && _businessValid && !_isLoading)
                              ? _complete
                              : null,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated onboarding page
class _OnboardingPage extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final int pageIndex;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.pageIndex,
  });

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor =
        CupertinoDynamicColor.resolve(AppColors.accent, context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with subtle background
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                  AppColors.chipInactive, context),
              borderRadius: BorderRadius.circular(AppColors.radiusXL),
            ),
            alignment: Alignment.center,
            child: Icon(
              widget.icon,
              size: 48,
              color: accentColor,
            ),
          )
              .animate(controller: _controller)
              .scale(
                begin: const Offset(0.7, 0.7),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 36),

          // Title
          Text(
            widget.title,
            style: AppTypography.displayLarge(context),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.15, delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 12),

          // Description
          Text(
            widget.description,
            style: AppTypography.bodyLarge(context).copyWith(
              color: CupertinoDynamicColor.resolve(
                  AppColors.textSecondary, context),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.15, delay: 400.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

/// Profile setup page with validation
class _ProfileSetupPage extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController businessController;
  final bool nameValid;
  final bool businessValid;

  const _ProfileSetupPage({
    required this.nameController,
    required this.businessController,
    required this.nameValid,
    required this.businessValid,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Set Up Your Profile',
            style: AppTypography.displayLarge(context),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.15, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize your experience',
            style: AppTypography.bodyMedium(context).copyWith(
              color: CupertinoDynamicColor.resolve(
                  AppColors.textTertiary, context),
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: -0.15, delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 32),

          // Name field
          CupertinoTextField(
            controller: nameController,
            placeholder: 'Your Name',
            prefix: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(CupertinoIcons.person,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.textTertiary, context),
                  size: 20),
            ),
            suffix: nameValid
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(CupertinoIcons.check_mark_circled_solid,
                        color: CupertinoDynamicColor.resolve(
                            AppColors.scoreGood, context),
                        size: 20),
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                  AppColors.searchField, context),
              borderRadius: BorderRadius.circular(AppColors.radiusM),
            ),
            onTap: () => Haptics.light(),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideX(begin: -0.1, delay: 300.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // Business field
          CupertinoTextField(
            controller: businessController,
            placeholder: 'Business / Agency Name',
            prefix: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(CupertinoIcons.building_2_fill,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.textTertiary, context),
                  size: 20),
            ),
            suffix: businessValid
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(CupertinoIcons.check_mark_circled_solid,
                        color: CupertinoDynamicColor.resolve(
                            AppColors.scoreGood, context),
                        size: 20),
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                  AppColors.searchField, context),
              borderRadius: BorderRadius.circular(AppColors.radiusM),
            ),
            onTap: () => Haptics.light(),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideX(begin: -0.1, delay: 400.ms, duration: 400.ms),
        ],
      ),
    );
  }
}
