import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/ios_toast.dart';

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
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
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
                    icon: CupertinoIcons.search,
                    title: 'Find Hidden Opportunities',
                    description:
                        'Search for businesses with poor or no web presence in any niche.',
                    color: AppColors.primary,
                  ),
                  _buildPage(
                    icon: CupertinoIcons.chart_bar,
                    title: 'AI-Powered Analysis',
                    description:
                        'Get instant insights on website quality, SEO gaps, and online reputation.',
                    color: AppColors.info,
                  ),
                  _buildPage(
                    icon: CupertinoIcons.globe,
                    title: 'Generate Demo Sites',
                    description:
                        'Create professional demo websites in seconds to showcase your work.',
                    color: CupertinoColors.systemPurple,
                  ),
                  _buildPage(
                    icon: CupertinoIcons.bubble_left_bubble_right,
                    title: 'Personalized Outreach',
                    description:
                        'AI writes custom messages for email, WhatsApp, Instagram, or phone.',
                    color: AppColors.success,
                  ),
                  _buildProfileSetup(),
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
                          : CupertinoColors.tertiaryLabel.resolveFrom(context),
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
                        CupertinoButton(
                          onPressed: () {
                            _pageController.jumpToPage(4);
                          },
                          child: const Text('Skip'),
                        ),
                        CupertinoButton.filled(
                          onPressed: () {
                            if (_currentPage < 4) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: const Text('Next'),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        onPressed: _isLoading ? null : _complete,
                        child: _isLoading
                            ? const CupertinoActivityIndicator(
                                color: CupertinoColors.white,
                              )
                            : const Text('Get Started'),
                      ),
                    ),
            ),
          ],
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
          // Icon with subtle background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.08),
            ),
            child: Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: color,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, duration: 400.ms),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
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
          const Text(
            'Set Up Your Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 32),
          CupertinoTextField(
            controller: _nameController,
            placeholder: 'Your Name',
            prefix: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(
                CupertinoIcons.person,
                size: 20,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(AppColors.radiusM),
              border: Border.all(
                color: CupertinoColors.separator.resolveFrom(context),
                width: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _businessController,
            placeholder: 'Business / Agency Name',
            prefix: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(
                CupertinoIcons.building_2_fill,
                size: 20,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(AppColors.radiusM),
              border: Border.all(
                color: CupertinoColors.separator.resolveFrom(context),
                width: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
