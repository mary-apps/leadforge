import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/brutal_button.dart';
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
  final _confettiController = ConfettiController();

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
    _confettiController.dispose();
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

      // Show celebration
      _confettiController.play();
      Haptics.heavy();

      await Future.delayed(const Duration(milliseconds: 2000));

      if (mounted) {
        context.go('/scout');
      }
    } catch (e) {
      Haptics.heavy();
      if (mounted) {
        IosToast.show(context, 'Error: $e', icon: CupertinoIcons.exclamationmark_triangle);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
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
                        icon: Icons.search,
                        iconColor: AppColors.primary,
                        title: 'Find Hidden Opportunities',
                        description:
                            'Search for businesses with poor or no web presence in any niche.',
                        pageIndex: 0,
                      ),
                      const _OnboardingPage(
                        icon: Icons.analytics,
                        iconColor: AppColors.primary,
                        title: 'AI-Powered Analysis',
                        description:
                            'Get instant insights on website quality, SEO gaps, and online reputation.',
                        pageIndex: 1,
                      ),
                      const _OnboardingPage(
                        icon: Icons.web,
                        iconColor: AppColors.primary,
                        title: 'Generate Demo Sites',
                        description:
                            'Create professional demo websites in seconds to showcase your work.',
                        pageIndex: 2,
                      ),
                      const _OnboardingPage(
                        icon: Icons.message,
                        iconColor: AppColors.primary,
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

                // Page indicator
                if (_currentPage < 4)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: index == _currentPage ? 28 : 8,
                        height: 5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.5),
                          color: index == _currentPage
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: _currentPage < 4
                      ? Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _skipConfirmation,
                              child: Text(
                                'Skip',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                            BrutalButton(
                              label: 'Next',
                              icon: Icons.arrow_forward,
                              onPressed: () {
                                _pageController.nextPage(
                                  duration:
                                      const Duration(milliseconds: 400),
                                  curve: Curves.easeInOutCubic,
                                );
                              },
                            ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: BrutalButton(
                            label: 'Get Started',
                            icon: Icons.rocket_launch,
                            isLoading: _isLoading,
                            onPressed:
                                (_nameValid && _businessValid && !_isLoading)
                                    ? _complete
                                    : null,
                          ),
                        ),
                ),
              ],
            ),
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.primaryLight,
                AppColors.success,
                Color(0xFF818CF8),
                Color(0xFFF0ABFC),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated onboarding page
class _OnboardingPage extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final int pageIndex;

  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
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
              color: widget.iconColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Icon(
              widget.icon,
              size: 48,
              color: widget.iconColor,
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
            style: AppTypography.headlineLarge.copyWith(
              fontSize: 24,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.15, delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 12),

          // Description
          Text(
            widget.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
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
            style: AppTypography.headlineLarge.copyWith(
              fontSize: 24,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.15, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize your experience',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: -0.15, delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 32),

          // Name field
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Your Name',
              prefixIcon: const Icon(Icons.person_outline),
              suffixIcon: nameValid
                  ? const Icon(Icons.check_circle,
                      color: AppColors.success, size: 20)
                  : null,
            ),
            onTap: () => Haptics.light(),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideX(begin: -0.1, delay: 300.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // Business field
          TextField(
            controller: businessController,
            decoration: InputDecoration(
              labelText: 'Business / Agency Name',
              prefixIcon: const Icon(Icons.business_outlined),
              suffixIcon: businessValid
                  ? const Icon(Icons.check_circle,
                      color: AppColors.success, size: 20)
                  : null,
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
