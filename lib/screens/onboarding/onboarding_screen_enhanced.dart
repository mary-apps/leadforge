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
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        context.go('/scout');
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
    final accentColor =
        CupertinoDynamicColor.resolve(AppColors.accent, context);
    final dividerColor =
        CupertinoDynamicColor.resolve(AppColors.divider, context);
    final tertiaryColor =
        CupertinoDynamicColor.resolve(AppColors.textTertiary, context);

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
                  _OnboardingPage(
                    title: 'Find Hidden Opportunities',
                    description:
                        'Search for businesses with poor or no web presence in any niche.',
                  ),
                  _OnboardingPage(
                    title: 'AI-Powered Analysis',
                    description:
                        'Get instant insights on website quality, SEO gaps, and online reputation.',
                  ),
                  _OnboardingPage(
                    title: 'Generate Demo Sites',
                    description:
                        'Create professional demo websites in seconds to showcase your work.',
                  ),
                  _OnboardingPage(
                    title: 'Personalized Outreach',
                    description:
                        'AI writes custom messages for email, WhatsApp, Instagram, or phone.',
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

            // Page indicator
            if (_currentPage < 4)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPage
                          ? accentColor
                          : dividerColor,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.pageHorizontal, 0, AppConstants.pageHorizontal, 24,
              ),
              child: _currentPage < 4
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _skipConfirmation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Text(
                              'Skip',
                              style: AppTypography.bodyMedium(context).copyWith(
                                color: tertiaryColor,
                              ),
                            ),
                          ),
                        ),
                        AppButton(
                          label: 'Next',
                          compact: true,
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          },
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

/// Text-only onboarding page — editorial minimalism
class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;

  const _OnboardingPage({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor =
        CupertinoDynamicColor.resolve(AppColors.textSecondary, context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.displayLarge(context),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.08, delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 12),

          Text(
            description,
            style: AppTypography.bodyLarge(context).copyWith(
              color: secondaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.08, delay: 400.ms, duration: 400.ms),
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
    final searchFieldColor =
        CupertinoDynamicColor.resolve(AppColors.searchField, context);
    final tertiaryColor =
        CupertinoDynamicColor.resolve(AppColors.textTertiary, context);
    final scoreGoodColor =
        CupertinoDynamicColor.resolve(AppColors.scoreGood, context);
    final secondaryColor =
        CupertinoDynamicColor.resolve(AppColors.textSecondary, context);

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
              .slideY(begin: -0.08, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize your experience',
            style: AppTypography.bodyLarge(context).copyWith(
              color: secondaryColor,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: -0.08, delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 32),

          // Name field
          CupertinoTextField(
            controller: nameController,
            placeholder: 'Your Name',
            placeholderStyle: TextStyle(color: tertiaryColor),
            prefix: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(CupertinoIcons.person,
                  color: tertiaryColor, size: 20),
            ),
            suffix: nameValid
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(CupertinoIcons.check_mark_circled_solid,
                        color: scoreGoodColor, size: 20),
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: searchFieldColor,
              borderRadius: BorderRadius.circular(AppColors.radiusM),
            ),
            onTap: () => Haptics.light(),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideX(begin: -0.05, delay: 300.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // Business field
          CupertinoTextField(
            controller: businessController,
            placeholder: 'Business / Agency Name',
            placeholderStyle: TextStyle(color: tertiaryColor),
            prefix: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(CupertinoIcons.building_2_fill,
                  color: tertiaryColor, size: 20),
            ),
            suffix: businessValid
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(CupertinoIcons.check_mark_circled_solid,
                        color: scoreGoodColor, size: 20),
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: searchFieldColor,
              borderRadius: BorderRadius.circular(AppColors.radiusM),
            ),
            onTap: () => Haptics.light(),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideX(begin: -0.05, delay: 400.ms, duration: 400.ms),
        ],
      ),
    );
  }
}
