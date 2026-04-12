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
                    title: 'Find Hidden Opportunities',
                    description:
                        'Search for businesses with poor or no web presence in any niche.',
                    pageIndex: 0,
                  ),
                  const _OnboardingPage(
                    title: 'AI-Powered Analysis',
                    description:
                        'Get instant insights on website quality, SEO gaps, and online reputation.',
                    pageIndex: 1,
                  ),
                  const _OnboardingPage(
                    title: 'Generate Demo Sites',
                    description:
                        'Create professional demo websites in seconds to showcase your work.',
                    pageIndex: 2,
                  ),
                  const _OnboardingPage(
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

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.pageHorizontal),
              child: _ProgressBar(
                currentStep: _currentPage,
                totalSteps: 4,
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

/// Onboarding page with mockup preview
class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final int pageIndex;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MockupPreview(pageIndex: pageIndex)
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.95, 0.95), duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(title, style: AppTypography.displayLarge(context))
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.15, delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTypography.bodyLarge(context).copyWith(
              color: CupertinoDynamicColor.resolve(AppColors.textSecondary, context),
              height: 1.5,
            ),
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
        mainAxisAlignment: MainAxisAlignment.start,
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

class _ProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _ProgressBar({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final isFinalStep = currentStep >= totalSteps;
    final label = isFinalStep ? 'FINAL STEP' : 'STEP ${currentStep + 1} OF $totalSteps';
    final progress = isFinalStep ? 1.0 : (currentStep + 1) / totalSteps;

    return Row(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall(context).copyWith(
            color: CupertinoDynamicColor.resolve(AppColors.textSecondary, context),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Stack(
                children: [
                  Container(color: CupertinoDynamicColor.resolve(AppColors.divider, context)),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    builder: (context, value, _) {
                      return FractionallySizedBox(
                        widthFactor: value,
                        child: Container(color: CupertinoDynamicColor.resolve(AppColors.accent, context)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MockupPreview extends StatelessWidget {
  final int pageIndex;
  const _MockupPreview({required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    final bgColor = CupertinoDynamicColor.resolve(AppColors.chipInactive, context);
    final surfaceColor = CupertinoDynamicColor.resolve(AppColors.surface, context);
    final borderColor = CupertinoDynamicColor.resolve(AppColors.border, context);
    final accentColor = CupertinoDynamicColor.resolve(AppColors.accent, context);
    final secondaryColor = CupertinoDynamicColor.resolve(AppColors.textSecondary, context);
    final tertiaryColor = CupertinoDynamicColor.resolve(AppColors.textTertiary, context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_labelIcon, size: 12, color: tertiaryColor),
              const SizedBox(width: 4),
              Text(_labelText, style: AppTypography.labelSmall(context).copyWith(color: tertiaryColor)),
            ],
          ),
          const SizedBox(height: 12),
          switch (pageIndex) {
            0 => _buildScoutPreview(context, surfaceColor, borderColor, accentColor, secondaryColor, tertiaryColor),
            1 => _buildAuditPreview(context, surfaceColor, borderColor, accentColor, secondaryColor, tertiaryColor),
            2 => _buildDemoPreview(context, surfaceColor, borderColor, accentColor, secondaryColor, tertiaryColor),
            _ => _buildOutreachPreview(context, surfaceColor, borderColor, accentColor, secondaryColor, tertiaryColor),
          },
        ],
      ),
    );
  }

  IconData get _labelIcon => switch (pageIndex) { 0 => CupertinoIcons.search, 1 => CupertinoIcons.chart_bar, 2 => CupertinoIcons.globe, _ => CupertinoIcons.paperplane };
  String get _labelText => switch (pageIndex) { 0 => 'SEARCH PREVIEW', 1 => 'AUDIT PREVIEW', 2 => 'DEMO PREVIEW', _ => 'MESSAGE PREVIEW' };

  Widget _buildScoutPreview(BuildContext context, Color surface, Color border, Color accent, Color secondary, Color tertiary) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(AppColors.radiusM), border: Border.all(color: border, width: 0.5)),
        child: Row(children: [Icon(CupertinoIcons.search, size: 14, color: tertiary), const SizedBox(width: 8), Text('restaurants in Miami...', style: AppTypography.chip(context).copyWith(color: tertiary))]),
      ),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _miniResultCard(context, 'Casa Luna', 'No website · 3.2★', surface, border, secondary, tertiary)),
        const SizedBox(width: 6),
        Expanded(child: _miniResultCard(context, 'El Patio', 'Poor SEO · 2.8★', surface, border, secondary, tertiary)),
      ]),
    ]);
  }

  Widget _miniResultCard(BuildContext context, String name, String detail, Color surface, Color border, Color secondary, Color tertiary) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(AppColors.radiusS + 2), border: Border.all(color: border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: AppTypography.chip(context).copyWith(fontWeight: FontWeight.w600, color: secondary)),
        const SizedBox(height: 2),
        Text(detail, style: AppTypography.chip(context).copyWith(fontSize: 10, color: tertiary)),
      ]),
    );
  }

  Widget _buildAuditPreview(BuildContext context, Color surface, Color border, Color accent, Color secondary, Color tertiary) {
    final scoreBadColor = CupertinoDynamicColor.resolve(AppColors.scoreBad, context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(AppColors.radiusM), border: Border.all(color: border, width: 0.5)),
      child: Row(children: [
        Text('32', style: AppTypography.headlineLarge(context).copyWith(fontSize: 36, fontWeight: FontWeight.w900, color: scoreBadColor)),
        Text('/100', style: AppTypography.bodyMedium(context).copyWith(color: tertiary)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('No website found', style: AppTypography.labelSmall(context).copyWith(letterSpacing: 0, color: secondary)),
          Text('Few reviews', style: AppTypography.labelSmall(context).copyWith(letterSpacing: 0, color: secondary)),
          Text('No social media', style: AppTypography.labelSmall(context).copyWith(letterSpacing: 0, color: secondary)),
        ])),
      ]),
    );
  }

  Widget _buildDemoPreview(BuildContext context, Color surface, Color border, Color accent, Color secondary, Color tertiary) {
    return Container(
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(AppColors.radiusM), border: Border.all(color: border, width: 0.5)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border, width: 0.5))),
          child: Row(children: [
            Row(children: [_dot(const Color(0xFFFF5F56)), const SizedBox(width: 4), _dot(const Color(0xFFFFBD2E)), const SizedBox(width: 4), _dot(const Color(0xFF27C93F))]),
            const SizedBox(width: 10),
            Expanded(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: CupertinoDynamicColor.resolve(AppColors.chipInactive, context), borderRadius: BorderRadius.circular(4)),
              child: Text('casaluna.leadforge.site', style: AppTypography.chip(context).copyWith(fontSize: 10, color: tertiary)),
            )),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(10), child: Column(children: [
          Container(height: 8, decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 6),
          Container(height: 32, decoration: BoxDecoration(color: accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: Container(height: 20, decoration: BoxDecoration(color: accent.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(3)))),
            const SizedBox(width: 6),
            Expanded(child: Container(height: 20, decoration: BoxDecoration(color: accent.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(3)))),
          ]),
        ])),
      ]),
    );
  }

  Widget _dot(Color color) => Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color));

  Widget _buildOutreachPreview(BuildContext context, Color surface, Color border, Color accent, Color secondary, Color tertiary) {
    return Column(children: [
      Container(
        width: double.infinity, padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(AppColors.radiusM), border: Border.all(color: border, width: 0.5)),
        child: Text("Hi! I noticed your restaurant could benefit from a stronger online presence. I've prepared a demo website...", style: AppTypography.chip(context).copyWith(color: secondary, height: 1.5)),
      ),
      const SizedBox(height: 8),
      Row(children: [
        _channelPill(context, 'Email', accent), const SizedBox(width: 6),
        _channelPill(context, 'WhatsApp', accent), const SizedBox(width: 6),
        _channelPill(context, 'Instagram', accent),
      ]),
    ]);
  }

  Widget _channelPill(BuildContext context, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(border: Border.all(color: accent.withValues(alpha: 0.2), width: 0.5), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: AppTypography.chip(context).copyWith(fontSize: 10, color: accent)),
    );
  }
}
