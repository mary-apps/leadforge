import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animated_button.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Skip Tutorial?'),
        content: const Text(
          'This quick tour helps you understand LeadForge\'s features. Are you sure you want to skip?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warning,
            ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
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
                      _OnboardingPage(
                        icon: Icons.search,
                        iconColor: AppColors.primary,
                        title: 'Find Hidden Opportunities',
                        description:
                            'Search for businesses with poor or no web presence in any niche.',
                        pageIndex: 0,
                      ),
                      _OnboardingPage(
                        icon: Icons.analytics,
                        iconColor: AppColors.info,
                        title: 'AI-Powered Analysis',
                        description:
                            'Get instant insights on website quality, SEO gaps, and online reputation.',
                        pageIndex: 1,
                      ),
                      _OnboardingPage(
                        icon: Icons.web,
                        iconColor: AppColors.warning,
                        title: 'Generate Demo Sites',
                        description:
                            'Create professional demo websites in seconds to showcase your work.',
                        pageIndex: 2,
                      ),
                      _OnboardingPage(
                        icon: Icons.message,
                        iconColor: AppColors.success,
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
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: index == _currentPage
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _currentPage < 4
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _skipConfirmation,
                              child: const Text('Skip'),
                            ),
                            AnimatedButton.primary(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOutCubic,
                                );
                              },
                              child: const Text('Next'),
                            ),
                          ],
                        )
                      : AnimatedButton.primary(
                          onPressed: (_nameValid && _businessValid && !_isLoading)
                              ? _complete
                              : null,
                          enabled: _nameValid && _businessValid && !_isLoading,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text('Get Started'),
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
                Color(0xFF6C5CE7),
                Color(0xFF00D68F),
                Color(0xFFFDCB6E),
                Color(0xFFFF6B6B),
                Color(0xFF5DADE2),
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
          // Animated icon
          Icon(
            widget.icon,
            size: 100,
            color: widget.iconColor,
          )
              .animate(controller: _controller)
              .scale(
                begin: const Offset(0.5, 0.5),
                duration: 600.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 400.ms)
              .then(delay: 200.ms)
              .shimmer(
                duration: 1500.ms,
                color: widget.iconColor.withOpacity(0.3),
              ),
          const SizedBox(height: 32),

          // Title
          Text(
            widget.title,
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // Description
          Text(
            widget.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.2, delay: 400.ms, duration: 400.ms),
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
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.2, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize your experience',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: -0.2, delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 32),

          // Name field
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Your Name',
              prefixIcon: const Icon(Icons.person_outline),
              suffixIcon: nameValid
                  ? Icon(Icons.check_circle, color: AppColors.success)
                  : null,
            ),
            onTap: () => Haptics.light(),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideX(begin: -0.2, delay: 300.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // Business field
          TextField(
            controller: businessController,
            decoration: InputDecoration(
              labelText: 'Business / Agency Name',
              prefixIcon: const Icon(Icons.business_outlined),
              suffixIcon: businessValid
                  ? Icon(Icons.check_circle, color: AppColors.success)
                  : null,
            ),
            onTap: () => Haptics.light(),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideX(begin: -0.2, delay: 400.ms, duration: 400.ms),
        ],
      ),
    );
  }
}
