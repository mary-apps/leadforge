# Batch 1 UI/UX Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign Login, Onboarding, and Business Detail screens for stronger brand identity, clearer feature previews, and a guided workflow experience.

**Architecture:** Each screen is modified in-place (no new files). Login gets a dark hero zone + light form split. Onboarding replaces generic icons with mini mockup previews and a progress bar. Business Detail replaces disconnected sections with contact icon cards and a vertical workflow stepper.

**Tech Stack:** Flutter, Cupertino widgets, flutter_animate, flutter_riverpod, go_router, url_launcher, share_plus

---

### Task 1: Login — Build Hero Section

**Files:**
- Modify: `lib/screens/auth/login_screen.dart`

**Context:** The login screen currently shows centered "LeadForge" text + "AI-powered lead generation" subtitle + form. We're adding a dark hero zone at the top with editorial headline and stats. Read the existing file first — the form logic (lines 20-165) stays untouched. You're only changing the `build` method (starts line 249) and adding a new private widget.

- [ ] **Step 1: Add `_HeroSection` widget**

Add this private widget at the bottom of `login_screen.dart` (after the closing `}` of `_LoginScreenState`):

```dart
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    // Hero bg: dark in light mode, light in dark mode
    const heroBg = CupertinoDynamicColor.withBrightness(
      color: Color(0xFF18181B),
      darkColor: Color(0xFFFAFAFA),
    );
    // Hero text: white in light mode, dark in dark mode
    const heroText = CupertinoDynamicColor.withBrightness(
      color: Color(0xFFFFFFFF),
      darkColor: Color(0xFF18181B),
    );
    // Muted text on hero
    const heroMuted = CupertinoDynamicColor.withBrightness(
      color: Color(0xFF666666),
      darkColor: Color(0xFF999999),
    );
    // Subtle line color on hero
    const heroLine = CupertinoDynamicColor.withBrightness(
      color: Color(0x14FFFFFF), // white at 0.08
      darkColor: Color(0x1418181B), // dark at 0.08
    );

    final resolvedBg = CupertinoDynamicColor.resolve(heroBg, context);
    final resolvedText = CupertinoDynamicColor.resolve(heroText, context);
    final resolvedMuted = CupertinoDynamicColor.resolve(heroMuted, context);
    final resolvedLine = CupertinoDynamicColor.resolve(heroLine, context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.pageHorizontal,
        32,
        AppConstants.pageHorizontal,
        24,
      ),
      color: resolvedBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wordmark
          Text(
            'LEADFORGE',
            style: AppTypography.labelSmall(context).copyWith(
              color: resolvedMuted,
              letterSpacing: 1.5,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.03, duration: 400.ms, curve: Curves.easeOut),
          const SizedBox(height: 16),

          // Editorial headline
          RichText(
            text: TextSpan(
              style: AppTypography.displayLarge(context).copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1.1,
                color: resolvedText,
              ),
              children: [
                const TextSpan(text: 'Turn weak\nwebsites into\n'),
                TextSpan(
                  text: 'your clients.',
                  style: TextStyle(color: resolvedMuted),
                ),
              ],
            ),
          )
              .animate(delay: 100.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.03, duration: 400.ms, curve: Curves.easeOut),
          const SizedBox(height: 12),

          // Accent bar
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: resolvedText.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 300.ms),
          const SizedBox(height: 16),

          // Stats row
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: resolvedLine, width: 1),
              ),
            ),
            child: Row(
              children: [
                _HeroStat(value: '2.4K', label: 'Leads found', color: resolvedText, mutedColor: resolvedMuted),
                const SizedBox(width: 20),
                _HeroStat(value: '890', label: 'Demos built', color: resolvedText, mutedColor: resolvedMuted),
                const SizedBox(width: 20),
                _HeroStat(value: '94%', label: 'Response rate', color: resolvedText, mutedColor: resolvedMuted),
              ],
            ),
          )
              .animate(delay: 300.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.03, duration: 400.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color mutedColor;

  const _HeroStat({
    required this.value,
    required this.label,
    required this.color,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: mutedColor,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Restructure the `build` method**

Replace the current `build` method of `_LoginScreenState` (the part inside `CupertinoPageScaffold`) — remove the `Center` wrapper, remove the old title/subtitle Column, and add `_HeroSection` at the top. The form content stays identical.

Replace the body of `build` from `return CupertinoPageScaffold(` through the end with:

```dart
return CupertinoPageScaffold(
  child: SafeArea(
    top: false, // hero goes under status bar area
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero section with safe area padding at top
          SafeArea(
            bottom: false,
            child: const _HeroSection(),
          ),
          const SizedBox(height: 24),

          // Form section
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pageHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Pill toggle
                _buildPillToggle(context),
                const SizedBox(height: 24),

                // Email field
                // ... (everything from CupertinoTextField email through
                //      the Apple Sign In button stays exactly as-is)
```

Keep everything from the email `CupertinoTextField` (line 308) through the Apple Sign In button (line 495) unchanged. Just remove the old title Column (lines 278-301) and the `const SizedBox(height: 36)` after it.

The closing brackets change from `Center > SingleChildScrollView > Column` to just `SingleChildScrollView > Column`.

- [ ] **Step 3: Verify visually**

Run: `flutter run` or hot restart
Expected: Dark hero zone at top with headline + stats, light form below. Dark mode: colors invert properly.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/auth/login_screen.dart
git commit -m "feat(login): add editorial dark hero zone with headline and stats"
```

---

### Task 2: Onboarding — Add Progress Bar

**Files:**
- Modify: `lib/screens/onboarding/onboarding_screen_enhanced.dart`

**Context:** The onboarding has 5 pages in a PageView. Pages 1-4 show features, page 5 is profile setup. Currently uses dot indicators (lines 175-196). We're replacing dots with a labeled progress bar. Read the file first — `_currentPage` (line 26) tracks which page is active.

- [ ] **Step 1: Add `_ProgressBar` widget**

Add at the bottom of the file:

```dart
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
            color: CupertinoDynamicColor.resolve(
                AppColors.textSecondary, context),
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
                  Container(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.divider, context),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    builder: (context, value, _) {
                      return FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          color: CupertinoDynamicColor.resolve(
                              AppColors.accent, context),
                        ),
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
```

- [ ] **Step 2: Replace dot indicators in the main build method**

In the `build` method of `_OnboardingScreenEnhancedState`, find the dot indicators section (the `if (_currentPage < 4) Row(...)` block, approximately lines 175-196). Replace it with:

```dart
Padding(
  padding: const EdgeInsets.symmetric(
      horizontal: AppConstants.pageHorizontal),
  child: _ProgressBar(
    currentStep: _currentPage,
    totalSteps: 4,
  ),
),
```

Remove the `if (_currentPage < 4)` condition — the progress bar shows on all pages including page 5 (as "FINAL STEP").

- [ ] **Step 3: Verify visually**

Hot restart. Swipe through onboarding pages.
Expected: Progress bar with "STEP 1 OF 4" ... "STEP 4 OF 4" on feature pages, "FINAL STEP" on profile page. Bar fills animated.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/onboarding/onboarding_screen_enhanced.dart
git commit -m "feat(onboarding): replace dot indicators with labeled progress bar"
```

---

### Task 3: Onboarding — Add Mockup Previews

**Files:**
- Modify: `lib/screens/onboarding/onboarding_screen_enhanced.dart`

**Context:** Each of the 4 feature pages currently shows a 96x96 icon in a rounded square. We're replacing this with mini mockup preview cards that show what the feature actually looks like. The `_OnboardingPage` widget (starts around line 249) needs to be rewritten.

- [ ] **Step 1: Add `_MockupPreview` widget**

Add at the bottom of the file. This widget renders a different mockup card depending on `pageIndex`:

```dart
class _MockupPreview extends StatelessWidget {
  final int pageIndex;

  const _MockupPreview({required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    final bgColor = CupertinoDynamicColor.resolve(
        AppColors.chipInactive, context);
    final surfaceColor = CupertinoDynamicColor.resolve(
        AppColors.surface, context);
    final borderColor = CupertinoDynamicColor.resolve(
        AppColors.border, context);
    final accentColor = CupertinoDynamicColor.resolve(
        AppColors.accent, context);
    final secondaryColor = CupertinoDynamicColor.resolve(
        AppColors.textSecondary, context);
    final tertiaryColor = CupertinoDynamicColor.resolve(
        AppColors.textTertiary, context);

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
          // Label
          Row(
            children: [
              Icon(_labelIcon, size: 12, color: tertiaryColor),
              const SizedBox(width: 4),
              Text(
                _labelText,
                style: AppTypography.labelSmall(context).copyWith(
                  color: tertiaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Content
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

  IconData get _labelIcon => switch (pageIndex) {
    0 => CupertinoIcons.search,
    1 => CupertinoIcons.chart_bar,
    2 => CupertinoIcons.globe,
    _ => CupertinoIcons.paperplane,
  };

  String get _labelText => switch (pageIndex) {
    0 => 'SEARCH PREVIEW',
    1 => 'AUDIT PREVIEW',
    2 => 'DEMO PREVIEW',
    _ => 'MESSAGE PREVIEW',
  };

  // Page 1: Scout — search bar + result cards
  Widget _buildScoutPreview(BuildContext context, Color surface, Color border, Color accent, Color secondary, Color tertiary) {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppColors.radiusM),
            border: Border.all(color: border, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(CupertinoIcons.search, size: 14, color: tertiary),
              const SizedBox(width: 8),
              Text('restaurants in Miami...', style: TextStyle(fontSize: 12, color: tertiary)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Result cards
        Row(
          children: [
            Expanded(child: _miniResultCard(context, 'Casa Luna', 'No website · 3.2★', surface, border, secondary, tertiary)),
            const SizedBox(width: 6),
            Expanded(child: _miniResultCard(context, 'El Patio', 'Poor SEO · 2.8★', surface, border, secondary, tertiary)),
          ],
        ),
      ],
    );
  }

  Widget _miniResultCard(BuildContext context, String name, String detail, Color surface, Color border, Color secondary, Color tertiary) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppColors.radiusS + 2),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondary)),
          const SizedBox(height: 2),
          Text(detail, style: TextStyle(fontSize: 10, color: tertiary)),
        ],
      ),
    );
  }

  // Page 2: Audit — score + diagnosis
  Widget _buildAuditPreview(BuildContext context, Color surface, Color border, Color accent, Color secondary, Color tertiary) {
    final scoreBadColor = CupertinoDynamicColor.resolve(AppColors.scoreBad, context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppColors.radiusM),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Row(
        children: [
          Text('32', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: scoreBadColor)),
          Text('/100', style: TextStyle(fontSize: 14, color: tertiary)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No website found', style: TextStyle(fontSize: 11, color: secondary)),
                Text('Few reviews', style: TextStyle(fontSize: 11, color: secondary)),
                Text('No social media', style: TextStyle(fontSize: 11, color: secondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Page 3: Demo — mini browser
  Widget _buildDemoPreview(BuildContext context, Color surface, Color border, Color accent, Color secondary, Color tertiary) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppColors.radiusM),
        border: Border.all(color: border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Browser chrome
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border, width: 0.5)),
            ),
            child: Row(
              children: [
                Row(children: [
                  _dot(const Color(0xFFFF5F56)),
                  const SizedBox(width: 4),
                  _dot(const Color(0xFFFFBD2E)),
                  const SizedBox(width: 4),
                  _dot(const Color(0xFF27C93F)),
                ]),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CupertinoDynamicColor.resolve(AppColors.chipInactive, context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('casaluna.leadforge.site', style: TextStyle(fontSize: 10, color: tertiary)),
                  ),
                ),
              ],
            ),
          ),
          // Page content blocks
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Container(height: 8, decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 6),
                Container(height: 32, decoration: BoxDecoration(color: accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: Container(height: 20, decoration: BoxDecoration(color: accent.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(3)))),
                  const SizedBox(width: 6),
                  Expanded(child: Container(height: 20, decoration: BoxDecoration(color: accent.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(3)))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color));

  // Page 4: Outreach — message + channel pills
  Widget _buildOutreachPreview(BuildContext context, Color surface, Color border, Color accent, Color secondary, Color tertiary) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppColors.radiusM),
            border: Border.all(color: border, width: 0.5),
          ),
          child: Text(
            'Hi! I noticed your restaurant could benefit from a stronger online presence. I\'ve prepared a demo website...',
            style: TextStyle(fontSize: 12, color: secondary, height: 1.5),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _channelPill(context, 'Email', accent),
            const SizedBox(width: 6),
            _channelPill(context, 'WhatsApp', accent),
            const SizedBox(width: 6),
            _channelPill(context, 'Instagram', accent),
          ],
        ),
      ],
    );
  }

  Widget _channelPill(BuildContext context, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: accent.withValues(alpha: 0.2), width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: accent)),
    );
  }
}
```

- [ ] **Step 2: Rewrite `_OnboardingPage` widget**

Replace the existing `_OnboardingPage` and `_OnboardingPageState` classes with a simpler StatelessWidget that uses `_MockupPreview` instead of the icon:

```dart
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
          // Mockup preview
          _MockupPreview(pageIndex: pageIndex)
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(
                begin: const Offset(0.95, 0.95),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 24),

          // Title
          Text(
            title,
            style: AppTypography.displayLarge(context),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.15, delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: AppTypography.bodyLarge(context).copyWith(
              color: CupertinoDynamicColor.resolve(
                  AppColors.textSecondary, context),
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
```

- [ ] **Step 3: Update `_OnboardingPage` references in the PageView**

In the `build` method of `_OnboardingScreenEnhancedState`, update the PageView children to remove the `icon` parameter (no longer used):

```dart
_OnboardingPage(
  title: 'Find Hidden Opportunities',
  description: 'Search for businesses with poor or no web presence in any niche.',
  pageIndex: 0,
),
_OnboardingPage(
  title: 'AI-Powered Analysis',
  description: 'Get instant insights on website quality, SEO gaps, and online reputation.',
  pageIndex: 1,
),
_OnboardingPage(
  title: 'Generate Demo Sites',
  description: 'Create professional demo websites in seconds to showcase your work.',
  pageIndex: 2,
),
_OnboardingPage(
  title: 'Personalized Outreach',
  description: 'AI writes custom messages for email, WhatsApp, Instagram, or phone.',
  pageIndex: 3,
),
```

- [ ] **Step 4: Update `_ProfileSetupPage` to use top alignment**

In the `_ProfileSetupPage`, change `mainAxisAlignment: MainAxisAlignment.center` to `mainAxisAlignment: MainAxisAlignment.start` and add a `_ProgressBar` at the top:

```dart
@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // (progress bar is in the parent, not here)
        Text(
          'Set Up Your Profile',
          // ... rest unchanged
```

Change `mainAxisAlignment: MainAxisAlignment.center` to `mainAxisAlignment: MainAxisAlignment.start` in the Column.

- [ ] **Step 5: Verify visually**

Hot restart. Swipe through all 5 onboarding pages.
Expected: Each page shows a unique mockup preview card above the title/description. Page 5 shows "FINAL STEP" in progress bar.

- [ ] **Step 6: Commit**

```bash
git add lib/screens/onboarding/onboarding_screen_enhanced.dart
git commit -m "feat(onboarding): replace generic icons with mini mockup previews"
```

---

### Task 4: Business Detail — Contact Icon Cards

**Files:**
- Modify: `lib/screens/audit/business_detail_screen.dart`

**Context:** The business detail screen has flat text links for Call/Website/Maps (lines 180-222). We're replacing them with 4 tappable icon cards in a row. The `_ContactLink` widget (lines 417-451) will be replaced. Read the file first.

- [ ] **Step 1: Add `_ContactCard` widget**

Replace the existing `_ContactLink` class with:

```dart
class _ContactCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Haptics.light();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: AppConstants.quickAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
                AppColors.chipInactive, context),
            borderRadius: BorderRadius.circular(AppColors.radiusM),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 22,
                color: CupertinoDynamicColor.resolve(
                    AppColors.accent, context),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: AppTypography.chip(context).copyWith(
                  color: CupertinoDynamicColor.resolve(
                      AppColors.textSecondary, context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Replace the contact Row in the build method**

Find the `Row` that contains `_ContactLink` widgets (around lines 180-214). Replace the entire Row and its `.animate()` with:

```dart
// Contact cards
Builder(builder: (context) {
  final cards = <Widget>[];
  if (business.phone != null) {
    cards.add(Expanded(
      child: _ContactCard(
        icon: CupertinoIcons.phone,
        label: 'Call',
        onTap: () => launchUrl(Uri.parse('tel:${business.phone}')),
      ),
    ));
  }
  if (business.website != null) {
    if (cards.isNotEmpty) cards.add(const SizedBox(width: 8));
    cards.add(Expanded(
      child: _ContactCard(
        icon: CupertinoIcons.globe,
        label: 'Website',
        onTap: () => launchUrl(Uri.parse(business.website!),
            mode: LaunchMode.externalApplication),
      ),
    ));
  }
  if (business.address != null) {
    if (cards.isNotEmpty) cards.add(const SizedBox(width: 8));
    cards.add(Expanded(
      child: _ContactCard(
        icon: CupertinoIcons.map,
        label: 'Maps',
        onTap: () => launchUrl(
          Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(business.address!)}'),
          mode: LaunchMode.externalApplication,
        ),
      ),
    ));
  }
  // Share is always shown
  if (cards.isNotEmpty) cards.add(const SizedBox(width: 8));
  cards.add(Expanded(
    child: _ContactCard(
      icon: CupertinoIcons.share,
      label: 'Share',
      onTap: () => ShareBusinessSheet.show(context, business),
    ),
  ));
  return Row(children: cards);
})
    .animate(delay: 200.ms)
    .fadeIn(duration: 300.ms)
    .slideX(begin: -0.03, duration: 350.ms, curve: Curves.easeOutCubic),
```

- [ ] **Step 3: Verify visually**

Hot restart. Navigate to any business detail screen.
Expected: 4 icon cards in a row (Call, Website, Maps, Share) replacing flat text links.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/audit/business_detail_screen.dart
git commit -m "feat(business-detail): replace flat contact links with icon cards"
```

---

### Task 5: Business Detail — Workflow Stepper

**Files:**
- Modify: `lib/screens/audit/business_detail_screen.dart`

**Context:** This is the biggest change. The current screen has separate buttons and status cards for audit, demo, and outreach spread vertically. We're replacing all of them with a unified vertical stepper. This task removes `_DemoStatusCard`, `_OutreachStatusCard`, and the standalone buttons, replacing them with `_WorkflowStepper`.

- [ ] **Step 1: Add step state enum and stepper widgets**

Add these at the bottom of the file (you can remove `_DemoStatusCard` and `_OutreachStatusCard` classes as they'll be replaced):

```dart
enum _StepState { completed, current, future }

class _WorkflowStepper extends StatelessWidget {
  final Business business;
  final bool isAudited;
  final bool isAuditing;
  final bool isAuditError;
  final bool autoAuditEnabled;
  final AuditResult? auditResult;
  final Demo? demo;
  final Message? outreach;
  final VoidCallback onAudit;
  final VoidCallback onRetryAudit;
  final VoidCallback onBuildDemo;
  final VoidCallback onCompose;
  final VoidCallback? onPreviewDemo;
  final VoidCallback? onShareDemo;
  final VoidCallback? onRedoDemo;
  final VoidCallback? onCopyOutreach;
  final VoidCallback? onRedoOutreach;

  const _WorkflowStepper({
    required this.business,
    required this.isAudited,
    required this.isAuditing,
    required this.isAuditError,
    required this.autoAuditEnabled,
    required this.auditResult,
    required this.demo,
    required this.outreach,
    required this.onAudit,
    required this.onRetryAudit,
    required this.onBuildDemo,
    required this.onCompose,
    this.onPreviewDemo,
    this.onShareDemo,
    this.onRedoDemo,
    this.onCopyOutreach,
    this.onRedoOutreach,
  });

  @override
  Widget build(BuildContext context) {
    // Determine step states
    final auditState = isAuditing
        ? _StepState.current
        : isAudited
            ? _StepState.completed
            : _StepState.current;

    final demoState = !isAudited
        ? _StepState.future
        : demo != null
            ? _StepState.completed
            : _StepState.current;

    // Outreach is available whenever audit is done, regardless of demo
    final outreachState = !isAudited
        ? _StepState.future
        : outreach != null
            ? _StepState.completed
            : _StepState.current;

    return Column(
      children: [
        // Step 1: Audit
        _WorkflowStep(
          stepNumber: 1,
          state: auditState,
          showConnector: true,
          connectorColor: auditState == _StepState.completed
              ? CupertinoDynamicColor.resolve(AppColors.scoreGood, context)
              : CupertinoDynamicColor.resolve(AppColors.divider, context),
          child: _buildAuditCard(context, auditState),
        ),
        // Step 2: Demo
        _WorkflowStep(
          stepNumber: 2,
          state: demoState,
          showConnector: true,
          connectorColor: demoState == _StepState.completed
              ? CupertinoDynamicColor.resolve(AppColors.scoreGood, context)
              : CupertinoDynamicColor.resolve(AppColors.divider, context),
          child: _buildDemoCard(context, demoState),
        ),
        // Step 3: Outreach
        _WorkflowStep(
          stepNumber: 3,
          state: outreachState,
          showConnector: false,
          child: _buildOutreachCard(context, outreachState),
        ),
      ],
    );
  }

  Widget _buildAuditCard(BuildContext context, _StepState state) {
    if (isAuditing) {
      return _AnalyzingAnimation();
    }

    if (state == _StepState.completed) {
      final score = auditResult?.score ?? business.auditScore ?? 0;
      final diagnosis = auditResult?.diagnosis ?? business.auditDiagnosis ?? '';

      return _CompletedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Audit Complete', style: AppTypography.titleMedium(context).copyWith(
              color: CupertinoDynamicColor.resolve(AppColors.scoreGood, context),
            )),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  score.toString(),
                  style: AppTypography.scoreLarge(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.scoreColor(score), context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('/100', style: AppTypography.bodyMedium(context).copyWith(
                    color: CupertinoDynamicColor.resolve(AppColors.textTertiary, context),
                  )),
                ),
              ],
            ),
            if (diagnosis.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                diagnosis,
                style: AppTypography.bodyMedium(context).copyWith(
                  color: CupertinoDynamicColor.resolve(AppColors.textSecondary, context),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      );
    }

    // Error state — retry button
    if (isAuditError) {
      return _CtaCard(
        title: 'Retry Analysis',
        subtitle: 'Auto-analysis failed — tap to retry',
        onTap: onRetryAudit,
      );
    }

    // Auto-audit enabled — don't show manual CTA, show waiting state
    if (autoAuditEnabled) {
      return _FutureCard(
        title: 'Analyze Business',
        subtitle: 'Auto-analysis will run automatically',
      );
    }

    // Current — manual CTA
    return _CtaCard(
      title: 'Analyze Business',
      subtitle: 'AI will score their online presence',
      onTap: onAudit,
    );
  }

  Widget _buildDemoCard(BuildContext context, _StepState state) {
    if (state == _StepState.completed && demo != null) {
      return _CompletedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Demo Ready', style: AppTypography.titleMedium(context).copyWith(
              color: CupertinoDynamicColor.resolve(AppColors.scoreGood, context),
            )),
            const SizedBox(height: 4),
            Text(
              demo!.publicUrl,
              style: AppTypography.mono(context).copyWith(
                color: CupertinoDynamicColor.resolve(AppColors.textSecondary, context),
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: AppButton(label: 'Preview', compact: true, onPressed: onPreviewDemo)),
                const SizedBox(width: 8),
                Expanded(child: AppButton(label: 'Share', compact: true, variant: AppButtonVariant.secondary, onPressed: onShareDemo)),
                const SizedBox(width: 8),
                Expanded(child: AppButton(label: 'Redo', compact: true, variant: AppButtonVariant.ghost, onPressed: onRedoDemo)),
              ],
            ),
          ],
        ),
      );
    }

    if (state == _StepState.future) {
      return _FutureCard(title: 'Generate Demo Site', subtitle: 'Complete audit first');
    }

    return _CtaCard(
      title: 'Generate Demo Site',
      subtitle: 'Create a professional demo',
      onTap: onBuildDemo,
    );
  }

  Widget _buildOutreachCard(BuildContext context, _StepState state) {
    if (state == _StepState.completed && outreach != null) {
      return _CompletedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Outreach Sent', style: AppTypography.titleMedium(context).copyWith(
                    color: CupertinoDynamicColor.resolve(AppColors.scoreGood, context),
                  )),
                ),
                Text(outreach!.channel.name, style: AppTypography.chip(context)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              outreach!.content,
              style: AppTypography.bodyMedium(context).copyWith(
                color: CupertinoDynamicColor.resolve(AppColors.textSecondary, context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: AppButton(label: 'Copy', compact: true, onPressed: onCopyOutreach)),
                const SizedBox(width: 8),
                Expanded(child: AppButton(label: 'Regenerate', compact: true, variant: AppButtonVariant.ghost, onPressed: onRedoOutreach)),
              ],
            ),
          ],
        ),
      );
    }

    if (state == _StepState.future) {
      return _FutureCard(title: 'Compose Outreach', subtitle: 'Complete audit first');
    }

    return _CtaCard(
      title: 'Compose Outreach',
      subtitle: demo == null ? 'Generate demo first for best results' : 'Send a personalized pitch',
      onTap: onCompose,
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  final int stepNumber;
  final _StepState state;
  final bool showConnector;
  final Color? connectorColor;
  final Widget child;

  const _WorkflowStep({
    required this.stepNumber,
    required this.state,
    required this.child,
    this.showConnector = false,
    this.connectorColor,
  });

  @override
  Widget build(BuildContext context) {
    final goodColor = CupertinoDynamicColor.resolve(AppColors.scoreGood, context);
    final accentColor = CupertinoDynamicColor.resolve(AppColors.accent, context);
    final inactiveColor = CupertinoDynamicColor.resolve(AppColors.chipInactive, context);
    final tertiaryColor = CupertinoDynamicColor.resolve(AppColors.textTertiary, context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: circle + connector
          SizedBox(
            width: 24,
            child: Column(
              children: [
                // Circle
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: switch (state) {
                      _StepState.completed => goodColor,
                      _StepState.current => accentColor,
                      _StepState.future => inactiveColor,
                    },
                  ),
                  alignment: Alignment.center,
                  child: state == _StepState.completed
                      ? Icon(CupertinoIcons.checkmark, size: 12, color: CupertinoDynamicColor.resolve(AppColors.chipActiveFg, context))
                      : Text(
                          '$stepNumber',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: state == _StepState.current
                                ? CupertinoDynamicColor.resolve(AppColors.chipActiveFg, context)
                                : tertiaryColor,
                          ),
                        ),
                ),
                // Connector line
                if (showConnector)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: connectorColor ?? CupertinoDynamicColor.resolve(AppColors.divider, context),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Right column: card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  final Widget child;
  const _CompletedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(AppColors.scoreGoodBg, context),
        borderRadius: BorderRadius.circular(AppColors.radiusM),
        border: Border.all(
          color: CupertinoDynamicColor.resolve(AppColors.scoreGood, context).withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}

class _CtaCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _CtaCard({required this.title, required this.subtitle, required this.onTap});

  @override
  State<_CtaCard> createState() => _CtaCardState();
}

class _CtaCardState extends State<_CtaCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Haptics.medium();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppConstants.quickAnimation,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(AppColors.accent, context),
            borderRadius: BorderRadius.circular(AppColors.radiusM),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: AppTypography.titleMedium(context).copyWith(
                      color: CupertinoDynamicColor.resolve(AppColors.chipActiveFg, context),
                    )),
                    const SizedBox(height: 2),
                    Text(widget.subtitle, style: AppTypography.chip(context).copyWith(
                      color: CupertinoDynamicColor.resolve(AppColors.chipActiveFg, context).withValues(alpha: 0.7),
                    )),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_forward, size: 16,
                  color: CupertinoDynamicColor.resolve(AppColors.chipActiveFg, context).withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FutureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _FutureCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(AppColors.surface, context),
        borderRadius: BorderRadius.circular(AppColors.radiusM),
        border: Border.all(
          color: CupertinoDynamicColor.resolve(AppColors.border, context),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium(context).copyWith(
            color: CupertinoDynamicColor.resolve(AppColors.textTertiary, context),
          )),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTypography.chip(context).copyWith(
            color: CupertinoDynamicColor.resolve(AppColors.textTertiary, context),
          )),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Replace the audit/demo/outreach section in the build method**

In the build method, find the section from `// Audit section` (around line 226) through the outreach history builder (around line 391). Replace it all with:

```dart
// Workflow label
Text(
  'WORKFLOW',
  style: AppTypography.labelSmall(context),
),
const SizedBox(height: AppConstants.itemGap),

// Workflow stepper
_WorkflowStepper(
  business: business,
  isAudited: business.isAudited || _auditResult != null,
  isAuditing: _isAuditing || isAutoAuditing,
  isAuditError: auditState is AsyncError && !business.isAudited,
  autoAuditEnabled: autoAuditEnabled,
  auditResult: _auditResult,
  demo: demo,
  outreach: outreach,
  onAudit: () => _runAudit(business),
  onRetryAudit: () => triggerAutoAudit(ref, business.id),
  onBuildDemo: () async {
    await context.push('/business/${business.id}/build-demo');
    ref.invalidate(demoForBusinessProvider(business.id));
  },
  onCompose: () async {
    await context.push('/business/${business.id}/outreach');
    ref.invalidate(outreachForBusinessProvider(business.id));
  },
  onPreviewDemo: demo != null
      ? () => launchUrl(Uri.parse(demo.publicUrl),
          mode: LaunchMode.externalApplication)
      : null,
  onShareDemo: demo != null
      ? () => Share.share(
          'Check out this demo: ${demo.publicUrl}',
          subject: 'Demo Website')
      : null,
  onRedoDemo: () async {
    await context.push('/business/${business.id}/build-demo');
    ref.invalidate(demoForBusinessProvider(business.id));
  },
  onCopyOutreach: outreach != null
      ? () {
          Clipboard.setData(ClipboardData(text: outreach.content));
          HapticFeedback.mediumImpact();
        }
      : null,
  onRedoOutreach: () async {
    await context.push('/business/${business.id}/outreach');
    ref.invalidate(outreachForBusinessProvider(business.id));
  },
)
    .animate(delay: 300.ms)
    .fadeIn(duration: 400.ms)
    .slideY(
      begin: AppConstants.entranceSlideDistance / 100,
      duration: 500.ms,
      curve: Curves.easeOutCubic,
    ),

const SizedBox(height: AppConstants.sectionGap),

// Audit context (if audited) — unchanged
if (business.isAudited || _auditResult != null)
  AuditContext(business: business),

// Outreach history — unchanged
const SizedBox(height: AppConstants.sectionGap),
Builder(builder: (context) {
  final messagesAsync =
      ref.watch(messagesForBusinessProvider(business.id));
  return messagesAsync.when(
    data: (messages) =>
        OutreachHistory(messages: messages),
    loading: () => const SizedBox.shrink(),
    error: (_, __) => const SizedBox.shrink(),
  );
}),
```

Also remove the `if (demo == null) ... else Padding(...)` hint text "Generate demo first for best results" that was below the old outreach button — that logic is now inside the stepper.

- [ ] **Step 3: Clean up — remove old widgets**

Delete the `_ContactLink`, `_DemoStatusCard`, and `_OutreachStatusCard` classes from the file. They are fully replaced by the new widgets.

- [ ] **Step 4: Verify visually**

Hot restart. Navigate to business detail screens in different states:
- Business with no audit → shows Audit as CTA, Demo and Outreach as future/locked
- Business with audit → shows Audit as completed with score, Demo as CTA
- Business with audit + demo → shows Demo as completed, Outreach as CTA
- Business with all three → all steps green with checkmarks

- [ ] **Step 5: Commit**

```bash
git add lib/screens/audit/business_detail_screen.dart
git commit -m "feat(business-detail): add vertical workflow stepper replacing disconnected sections"
```

---

### Task 6: Final Verification & Cleanup

**Files:**
- All 3 modified files

- [ ] **Step 1: Full visual walkthrough**

Hot restart the app. Walk through the complete flow:
1. Login screen — hero zone + form, check dark mode toggle
2. Sign in → Onboarding — progress bar + mockup previews on all 4 feature pages, profile setup on page 5
3. Dashboard → tap a business → Business Detail — contact cards + workflow stepper
4. Test audit flow, demo generation, outreach composition through the stepper

- [ ] **Step 2: Check for unused imports**

Review each file for any imports that are no longer needed after removing old widgets. Remove unused imports.

- [ ] **Step 3: Dark mode verification**

Toggle device to dark mode. Verify:
- Login hero zone inverts to light background
- Onboarding previews have proper dark mode colors
- Business detail stepper cards use proper dark mode colors

- [ ] **Step 4: Final commit**

If any cleanup was needed:
```bash
git add -A
git commit -m "chore: clean up unused imports and verify dark mode for Batch 1 redesign"
```
