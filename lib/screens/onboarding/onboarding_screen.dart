import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/ios_toast.dart';
import '../../widgets/shimmer_text.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final name = _nameController.text.trim();
    final business = _businessController.text.trim();

    if (name.isEmpty || business.isEmpty) {
      IosToast.show(context, 'Please fill in all fields', icon: CupertinoIcons.exclamationmark_circle);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).completeOnboarding(
            displayName: name,
            businessName: business,
          );

      if (mounted) {
        context.go('/scout');
      }
    } catch (e) {
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
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                  children: [
                    _buildPage(
                      icon: Icons.search,
                      title: 'Find Hidden Opportunities',
                      description:
                          'Search for businesses with poor or no web presence in any niche.',
                      color: AppColors.primary,
                    ),
                    _buildPage(
                      icon: Icons.analytics,
                      title: 'AI-Powered Analysis',
                      description:
                          'Get instant insights on website quality, SEO gaps, and online reputation.',
                      color: AppColors.info,
                    ),
                    _buildPage(
                      icon: Icons.web,
                      title: 'Generate Demo Sites',
                      description:
                          'Create professional demo websites in seconds to showcase your work.',
                      color: AppColors.secondary,
                    ),
                    _buildPage(
                      icon: Icons.message,
                      title: 'Personalized Outreach',
                      description:
                          'AI writes custom messages for email, WhatsApp, Instagram, or phone.',
                      color: AppColors.success,
                    ),
                    _buildProfileSetup(),
                  ],
                ),
              ),

              // Page indicator with glow
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
                        gradient: index == _currentPage
                            ? AppColors.primaryGradient
                            : null,
                        color: index == _currentPage
                            ? null
                            : AppColors.textTertiary.withValues(alpha: 0.3),
                        boxShadow: index == _currentPage
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
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
                            onPressed: () {
                              _pageController.jumpToPage(4);
                            },
                            child: const Text('Skip'),
                          ),
                          _GlowButton(
                            label: 'Next',
                            onPressed: () {
                              if (_currentPage < 4) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          ),
                        ],
                      )
                    : _GlowButton(
                        label: 'Get Started',
                        isLoading: _isLoading,
                        expand: true,
                        onPressed: _isLoading ? null : _complete,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required String title,
    required String description,
    Color color = AppColors.primary,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient glow orb
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: color.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 32),
          GradientText(
            text: title,
            style: AppTypography.headlineLarge,
            colors: [color, color.withValues(alpha: 0.7)],
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, duration: 400.ms),
          const SizedBox(height: 16),
          Text(
            description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: 350.ms)
              .fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildProfileSetup() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const GradientText(
            text: 'Set Up Your Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _businessController,
            decoration: const InputDecoration(
              labelText: 'Business / Agency Name',
              prefixIcon: Icon(Icons.business_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

/// CTA button with gradient background and glow shadow.
class _GlowButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expand;

  const _GlowButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          gradient: onPressed != null ? AppColors.primaryGradient : null,
          color: onPressed == null
              ? AppColors.textTertiary.withValues(alpha: 0.3)
              : null,
          borderRadius: BorderRadius.circular(AppColors.radiusM),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: -2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.background,
                ),
              )
            : Text(
                label,
                style: AppTypography.button.copyWith(
                  color: AppColors.background,
                ),
              ),
      ),
    );

    if (expand) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    return button;
  }
}
