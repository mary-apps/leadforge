import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
      body: SafeArea(
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
                    description: 'Search for businesses with poor or no web presence in any niche.',
                  ),
                  _buildPage(
                    icon: Icons.analytics,
                    title: 'AI-Powered Analysis',
                    description: 'Get instant insights on website quality, SEO gaps, and online reputation.',
                  ),
                  _buildPage(
                    icon: Icons.web,
                    title: 'Generate Demo Sites',
                    description: 'Create professional demo websites in seconds to showcase your work.',
                  ),
                  _buildPage(
                    icon: Icons.message,
                    title: 'Personalized Outreach',
                    description: 'AI writes custom messages for email, WhatsApp, Instagram, or phone.',
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
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
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
                          onPressed: () {
                            _pageController.jumpToPage(4);
                          },
                          child: const Text('Skip'),
                        ),
                        ElevatedButton(
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
                  : ElevatedButton(
                      onPressed: _isLoading ? null : _complete,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Get Started'),
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
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: AppColors.primary,
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
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
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
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
