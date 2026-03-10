# UI Overhaul Implementation Plan — Neo-Brutal Selectivo + Sunset Gold

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform LeadForge from generic dark theme to distinctive neo-brutalist aesthetic with Sunset Gold palette, new navigation with FAB, and polished micro-interactions.

**Architecture:** Bottom-up approach — update design system first (theme.dart), then build new reusable components (BrutalCard, BrutalButton, etc.), then update each screen. Each task produces a working app state.

**Tech Stack:** Flutter 3.x, Dart 3.x, Riverpod, GoRouter, flutter_animate, fl_chart

**Spec:** `docs/superpowers/specs/2026-03-09-ui-overhaul-design.md`

---

## File Structure

### Files to Modify:
- `lib/config/theme.dart` — Update color palette, add brutal design tokens
- `lib/config/routes.dart` — Update shell route for new nav structure
- `lib/widgets/app_bottom_nav.dart` — Replace with FAB nav bar
- `lib/widgets/animated_button.dart` — Replace with BrutalButton
- `lib/widgets/animated_score_gauge.dart` — Restyle to segmented brutal gauge
- `lib/widgets/stat_card_animated.dart` — Apply brutal styling
- `lib/widgets/business_card.dart` — Add hero animation support + restyle
- `lib/widgets/loading_shimmer.dart` — Replace with content-shaped skeletons
- `lib/widgets/niche_chips.dart` — Brutal style on selected
- `lib/widgets/search_suggestions.dart` — Restyle
- `lib/screens/dashboard/dashboard_screen.dart` — Full redesign
- `lib/screens/scout/scout_screen.dart` — Restyle search + results
- `lib/screens/audit/business_detail_screen.dart` — Redesign with brutal score
- `lib/screens/pipeline/pipeline_screen_enhanced.dart` — Restyle sections
- `lib/screens/auth/login_screen.dart` — Restyle with brutal accents
- `lib/screens/settings/settings_screen.dart` — Restyle
- `lib/screens/onboarding/onboarding_screen_enhanced.dart` — Color update
- `lib/screens/build/build_demo_screen.dart` — Restyle
- `lib/screens/outreach/outreach_screen.dart` — Restyle

### Files to Create:
- `lib/widgets/brutal_card.dart` — Reusable brutal card component
- `lib/widgets/brutal_button.dart` — Reusable brutal button component
- `lib/widgets/empty_state.dart` — Reusable empty state component
- `lib/widgets/skeleton_loaders.dart` — Content-shaped skeleton loaders

---

## Chunk 1: Design System + Core Components

### Task 1: Update Theme — Colors + Typography

**Files:**
- Modify: `lib/config/theme.dart`

- [ ] **Step 1: Read current theme.dart fully**

Read `lib/config/theme.dart` to understand all color and typography definitions.

- [ ] **Step 2: Update AppColors class**

Replace the color palette in `AppColors`:

```dart
class AppColors {
  // Backgrounds
  static const background = Color(0xFF0A0A0F);
  static const surface = Color(0xFF141420);
  static const surfaceLight = Color(0xFF1C1C2E);

  // Primary — Sunset Gold (was Purple)
  static const primary = Color(0xFFFF9F43);
  static const primaryDark = Color(0xFFE68A30);
  static const primaryLight = Color(0xFFFFB76B);

  // Secondary — Sky Blue
  static const secondary = Color(0xFF5DADE2);
  static const secondaryDark = Color(0xFF4A9BD0);
  static const secondaryLight = Color(0xFF7EC0E8);

  // Semantic
  static const success = Color(0xFF00D68F);
  static const warning = Color(0xFFFDCB6E);
  static const danger = Color(0xFFFF6B6B);
  static const info = Color(0xFF5DADE2);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0x80FFFFFF); // 50%
  static const textTertiary = Color(0x59FFFFFF); // 35%

  // Borders
  static const border = Color(0x0FFFFFFF); // 6%

  // Brutal Design Tokens
  static const brutalBorderWidth = 2.0;
  static const brutalShadowOffset = Offset(3, 3);
  static const brutalShadowOffsetPressed = Offset(1, 1);
  static const brutalRadius = 12.0;
  static const brutalButtonRadius = 10.0;
  static const brutalNavRadius = 16.0;
}
```

- [ ] **Step 3: Update AppTypography for brutal weights**

Update the typography class to include brutal-specific styles:

```dart
// Add these styles to AppTypography:
static const labelBrutal = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  fontFamily: 'SF Pro Text',
  letterSpacing: 1.0,
  color: AppColors.textSecondary,
);

static const numberBrutal = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w900,
  fontFamily: 'SF Pro Display',
  color: AppColors.textPrimary,
);

static const scoreLarge = TextStyle(
  fontSize: 56,
  fontWeight: FontWeight.w900,
  fontFamily: 'SF Pro Display',
  color: AppColors.primary,
);

static const buttonBrutal = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w800,
  fontFamily: 'SF Pro Text',
  letterSpacing: 0.5,
  color: Color(0xFF0A0A0F),
);
```

- [ ] **Step 4: Update ThemeData in AppTheme**

Update `AppTheme.darkTheme` to reflect new primary/secondary colors. Ensure `colorScheme`, `elevatedButtonTheme`, `inputDecorationTheme`, etc. all reference new `AppColors.primary`.

- [ ] **Step 5: Verify compilation**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze 2>&1 | head -20`
Expected: No new errors introduced.

- [ ] **Step 6: Commit**

```bash
git add lib/config/theme.dart
git commit -m "feat(theme): update to Sunset Gold palette + brutal design tokens"
```

---

### Task 2: Create BrutalCard Widget

**Files:**
- Create: `lib/widgets/brutal_card.dart`

- [ ] **Step 1: Create BrutalCard widget**

```dart
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../utils/haptics.dart';

class BrutalCard extends StatefulWidget {
  final Widget child;
  final Color borderColor;
  final double shadowOffsetX;
  final double shadowOffsetY;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const BrutalCard({
    super.key,
    required this.child,
    this.borderColor = AppColors.primary,
    this.shadowOffsetX = 3,
    this.shadowOffsetY = 3,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = AppColors.brutalRadius,
  });

  @override
  State<BrutalCard> createState() => _BrutalCardState();
}

class _BrutalCardState extends State<BrutalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _shadowAnimation = Tween<Offset>(
      begin: Offset(widget.shadowOffsetX, widget.shadowOffsetY),
      end: const Offset(1, 1),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _controller.reverse();
              Haptics.light();
              widget.onTap!();
            }
          : null,
      onTapCancel:
          widget.onTap != null ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: widget.borderColor,
                  width: AppColors.brutalBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.borderColor.withValues(alpha: 0.4),
                    offset: _shadowAnimation.value,
                    blurRadius: 0,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
```

**Note:** `AnimatedBuilder` should be `AnimatedBuilder` from Flutter. If the API is `AnimatedBuilder`, use that. Otherwise use `AnimatedWidget` pattern or wrap in `Builder` with animation listener.

- [ ] **Step 2: Fix AnimatedBuilder — use correct API**

The correct Flutter widget is `AnimatedBuilder`. Verify it compiles. If not, use this pattern instead:

```dart
child: ScaleTransition(
  scale: _scaleAnimation,
  child: Container(...)
)
```

And handle shadow separately with `addListener` + `setState`.

- [ ] **Step 3: Verify compilation**

Run: `flutter analyze 2>&1 | head -10`

- [ ] **Step 4: Commit**

```bash
git add lib/widgets/brutal_card.dart
git commit -m "feat(widgets): add BrutalCard component with press animation"
```

---

### Task 3: Create BrutalButton Widget

**Files:**
- Create: `lib/widgets/brutal_button.dart`

- [ ] **Step 1: Create BrutalButton widget**

```dart
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../utils/haptics.dart';

class BrutalButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool isLoading;
  final IconData? icon;

  const BrutalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = AppColors.primary,
    this.isLoading = false,
    this.icon,
  });

  const BrutalButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.color = AppColors.secondary,
    this.isLoading = false,
    this.icon,
  });

  const BrutalButton.success({
    super.key,
    required this.label,
    this.onPressed,
    this.color = AppColors.success,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<BrutalButton> createState() => _BrutalButtonState();
}

class _BrutalButtonState extends State<BrutalButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _shadowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _shadowAnim = Tween<Offset>(
      begin: const Offset(3, 3),
      end: const Offset(1, 1),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    _controller.reverse();
    if (widget.onPressed != null && !widget.isLoading) {
      Haptics.light();
      widget.onPressed!();
    }
  }

  void _handleTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: AnimatedOpacity(
              opacity: isDisabled ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(
                    AppColors.brutalButtonRadius,
                  ),
                  border: Border.all(
                    color: widget.color,
                    width: AppColors.brutalBorderWidth,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.4),
                      offset: _shadowAnim.value,
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading) ...[
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else if (widget.icon != null) ...[
                      Icon(widget.icon, size: 18, color: AppColors.background),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label.toUpperCase(),
                      style: AppTypography.buttonBrutal.copyWith(
                        color: AppColors.background,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Verify compilation**

Run: `flutter analyze 2>&1 | head -10`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/brutal_button.dart
git commit -m "feat(widgets): add BrutalButton component with brutal press animation"
```

---

### Task 4: Create EmptyState Widget

**Files:**
- Create: `lib/widgets/empty_state.dart`

- [ ] **Step 1: Create EmptyState widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import 'brutal_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor = AppColors.primary,
  });

  /// No search results found
  factory EmptyState.noResults({VoidCallback? onRetry}) => EmptyState(
    icon: Icons.search_off_rounded,
    title: 'No results found',
    subtitle: 'Try a different search term or location',
    actionLabel: onRetry != null ? 'Try Again' : null,
    onAction: onRetry,
    iconColor: AppColors.secondary,
  );

  /// Empty pipeline / no leads
  factory EmptyState.noLeads({VoidCallback? onScout}) => EmptyState(
    icon: Icons.people_outline_rounded,
    title: 'No leads yet',
    subtitle: 'Start scouting to find your first prospects',
    actionLabel: onScout != null ? 'Scout Now' : null,
    onAction: onScout,
    iconColor: AppColors.primary,
  );

  /// First time user
  factory EmptyState.firstTime({VoidCallback? onStart}) => EmptyState(
    icon: Icons.rocket_launch_rounded,
    title: 'Welcome to LeadForge',
    subtitle: 'Find local businesses and close deals faster',
    actionLabel: onStart != null ? 'Get Started' : null,
    onAction: onStart,
    iconColor: AppColors.primary,
  );

  /// No messages
  factory EmptyState.noMessages({VoidCallback? onCompose}) => EmptyState(
    icon: Icons.chat_bubble_outline_rounded,
    title: 'No messages yet',
    subtitle: 'Audit a business first, then craft your outreach',
    actionLabel: onCompose != null ? 'Find Leads' : null,
    onAction: onCompose,
    iconColor: AppColors.secondary,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon composition — layered icons
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: 80,
                  color: iconColor.withValues(alpha: 0.1),
                ),
                Icon(
                  icon,
                  size: 48,
                  color: iconColor.withValues(alpha: 0.6),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              BrutalButton(
                label: actionLabel!,
                onPressed: onAction,
              )
                  .animate()
                  .fadeIn(delay: 450.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify compilation**

Run: `flutter analyze 2>&1 | head -10`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/empty_state.dart
git commit -m "feat(widgets): add EmptyState component with animated entrance"
```

---

### Task 5: Create SkeletonLoader Widget

**Files:**
- Create: `lib/widgets/skeleton_loaders.dart`
- Modify: `lib/widgets/loading_shimmer.dart` (keep for backward compat, delegate to new)

- [ ] **Step 1: Create content-shaped skeleton loaders**

```dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/theme.dart';

/// Base shimmer box with configurable shape
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Wraps children in shimmer effect
class ShimmerWrap extends StatelessWidget {
  final Widget child;

  const ShimmerWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceLight,
      child: child,
    );
  }
}

/// Dashboard skeleton — matches dashboard layout
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            const _ShimmerBox(width: 200, height: 20),
            const SizedBox(height: 4),
            const _ShimmerBox(width: 140, height: 28),
            const SizedBox(height: 20),
            // Stat cards
            Row(
              children: [
                Expanded(child: _ShimmerBox(height: 90, borderRadius: 12)),
                const SizedBox(width: 8),
                Expanded(child: _ShimmerBox(height: 90, borderRadius: 12)),
                const SizedBox(width: 8),
                Expanded(child: _ShimmerBox(height: 90, borderRadius: 12)),
              ],
            ),
            const SizedBox(height: 16),
            // Quick actions
            const _ShimmerBox(width: 100, height: 14),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _ShimmerBox(height: 60, borderRadius: 12)),
                const SizedBox(width: 8),
                Expanded(child: _ShimmerBox(height: 60, borderRadius: 12)),
                const SizedBox(width: 8),
                Expanded(child: _ShimmerBox(height: 60, borderRadius: 12)),
              ],
            ),
            const SizedBox(height: 20),
            // Chart
            const _ShimmerBox(height: 200, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

/// Business detail skeleton
class BusinessDetailSkeleton extends StatelessWidget {
  const BusinessDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                _ShimmerBox(width: 48, height: 48, borderRadius: 14),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _ShimmerBox(width: 180, height: 18),
                      SizedBox(height: 4),
                      _ShimmerBox(width: 140, height: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Contact buttons
            Row(
              children: [
                Expanded(child: _ShimmerBox(height: 56, borderRadius: 12)),
                const SizedBox(width: 8),
                Expanded(child: _ShimmerBox(height: 56, borderRadius: 12)),
                const SizedBox(width: 8),
                Expanded(child: _ShimmerBox(height: 56, borderRadius: 12)),
              ],
            ),
            const SizedBox(height: 16),
            // Score
            const _ShimmerBox(height: 140, borderRadius: 16),
            const SizedBox(height: 16),
            // Breakdown
            const _ShimmerBox(height: 120, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

/// Search results skeleton
class SearchSkeleton extends StatelessWidget {
  const SearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: List.generate(
            4,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ShimmerBox(height: 100, borderRadius: 12),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pipeline skeleton
class PipelineSkeleton extends StatelessWidget {
  const PipelineSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 120, height: 16),
                  const SizedBox(height: 8),
                  const _ShimmerBox(height: 80, borderRadius: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Update loading_shimmer.dart to use new skeleton**

Read `lib/widgets/loading_shimmer.dart`, then replace its content to delegate to `SearchSkeleton`:

```dart
import 'package:flutter/material.dart';
import 'skeleton_loaders.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SearchSkeleton();
  }
}
```

- [ ] **Step 3: Verify compilation**

Run: `flutter analyze 2>&1 | head -10`

- [ ] **Step 4: Commit**

```bash
git add lib/widgets/skeleton_loaders.dart lib/widgets/loading_shimmer.dart
git commit -m "feat(widgets): add content-shaped skeleton loaders for all screens"
```

---

## Chunk 2: Navigation + Dashboard

### Task 6: Redesign Bottom Navigation with FAB

**Files:**
- Modify: `lib/widgets/app_bottom_nav.dart`
- Modify: `lib/config/routes.dart`

- [ ] **Step 1: Read current app_bottom_nav.dart and routes.dart**

Read both files to understand the current navigation setup.

- [ ] **Step 2: Rewrite app_bottom_nav.dart with FAB**

Replace the entire file with the new FAB navigation:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import '../utils/haptics.dart';

class AppBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNav({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      floatingActionButton: _ScoutFAB(
        onTap: () {
          Haptics.medium();
          navigationShell.goBranch(2); // Scout is index 2 (middle)
        },
        isSelected: navigationShell.currentIndex == 2,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          Haptics.light();
          navigationShell.goBranch(index);
        },
      ),
    );
  }
}

class _ScoutFAB extends StatefulWidget {
  final VoidCallback onTap;
  final bool isSelected;

  const _ScoutFAB({required this.onTap, required this.isSelected});

  @override
  State<_ScoutFAB> createState() => _ScoutFABState();
}

class _ScoutFABState extends State<_ScoutFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppColors.brutalNavRadius),
            border: Border.all(
              color: AppColors.primary,
              width: AppColors.brutalBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                offset: const Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: const Icon(
            Icons.search_rounded,
            color: AppColors.background,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SafeArea(
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'HOME',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.analytics_rounded,
                label: 'PIPELINE',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              const SizedBox(width: 64), // Space for FAB
              _NavItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'MESSAGES',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'SETTINGS',
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Update routes.dart for 5-branch navigation**

Read `lib/config/routes.dart` and update the `StatefulShellRoute` to have 5 branches: Dashboard (home), Pipeline, Scout (center), Messages (placeholder), Settings. The Messages screen can be a simple placeholder for now.

Update the route to use `StatefulShellRoute.indexedStack` with these branches:
1. `/dashboard` — DashboardScreen
2. `/pipeline` — PipelineScreenEnhanced
3. `/scout` — ScoutScreen
4. `/messages` — Placeholder (simple Scaffold with EmptyState.noMessages)
5. `/settings` — SettingsScreen

And update the shell builder to pass `navigationShell` to `AppBottomNav`.

- [ ] **Step 4: Create simple messages placeholder screen**

Create `lib/screens/messages/messages_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../../widgets/empty_state.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: EmptyState.noMessages(),
    );
  }
}
```

- [ ] **Step 5: Verify compilation and test navigation**

Run: `flutter analyze 2>&1 | head -20`

- [ ] **Step 6: Commit**

```bash
git add lib/widgets/app_bottom_nav.dart lib/config/routes.dart lib/screens/messages/messages_screen.dart
git commit -m "feat(nav): redesign bottom nav with FAB scout button + 5 tabs"
```

---

### Task 7: Redesign Dashboard Screen

**Files:**
- Modify: `lib/screens/dashboard/dashboard_screen.dart`
- Modify: `lib/widgets/stat_card_animated.dart`

- [ ] **Step 1: Read current dashboard_screen.dart and stat_card_animated.dart**

Read both files completely.

- [ ] **Step 2: Update StatCardAnimated with brutal styling**

Read then modify `lib/widgets/stat_card_animated.dart`. Update the card's Container decoration:
- Add `border: Border.all(color: accentColor, width: 2)` for cards where `isBrutal: true`
- Add `boxShadow: [BoxShadow(color: accentColor.withValues(alpha: 0.4), offset: Offset(3,3), blurRadius: 0)]` for brutal cards
- Add a `bool isBrutal` parameter, default `false`
- Update label text to use `AppTypography.labelBrutal` when brutal
- Update number text to use `AppTypography.numberBrutal`
- Add trend indicator: `String? trend` parameter (e.g., "+12%"), shown below the number in green/red

- [ ] **Step 3: Rewrite dashboard_screen.dart**

Replace the dashboard with the new layout:
1. **Greeting header** — "Good morning" + user display name (from profile provider) + notification bell in brutal orange container
2. **Stats row** — 3 `StatCardAnimated` in a Row (Leads brutal+orange, Audits brutal+blue, Revenue clean)
3. **Quick actions** — Row of 3 tappable containers. Scout (brutal orange, navigates to scout tab), Pipeline (clean), Outreach (clean)
4. **Section label** "RECENT LEADS" in `labelBrutal` style
5. **Recent leads list** — Last 5 businesses as ListTiles with category emoji, name, score, arrow. Tappable → business detail.
6. **Weekly chart** — Keep `WeeklyActivityGraph` but add section label above

Key code changes:
- Replace `Wrap` of 4 stat cards with `Row` of 3
- Add greeting section at top
- Add quick actions section
- Add recent leads list
- Keep chart but restyle

- [ ] **Step 4: Verify compilation**

Run: `flutter analyze 2>&1 | head -20`

- [ ] **Step 5: Commit**

```bash
git add lib/screens/dashboard/dashboard_screen.dart lib/widgets/stat_card_animated.dart
git commit -m "feat(dashboard): redesign with brutal stats, greeting, quick actions"
```

---

## Chunk 3: Business Detail + Score Gauge

### Task 8: Redesign Score Gauge — Segmented Brutal Style

**Files:**
- Modify: `lib/widgets/animated_score_gauge.dart`

- [ ] **Step 1: Read current animated_score_gauge.dart**

Read the full file.

- [ ] **Step 2: Rewrite to segmented brutal gauge**

Replace the circular arc gauge with a centered layout:
1. Label "DIGITAL SCORE" in `labelBrutal`
2. Large score number in `scoreLarge` style, colored by range (red <40, yellow 40-70, green >70)
3. Status text (e.g., "NEEDS WORK", "DECENT", "STRONG") in bold, colored
4. Segmented bar — 5 segments, each a small rounded rect, filled segments colored by range
5. Animate: segments fill sequentially (200ms each) with haptic on each, number counts up simultaneously

```dart
// Key structure of new gauge:
Column(
  children: [
    Text('DIGITAL SCORE', style: AppTypography.labelBrutal),
    SizedBox(height: 8),
    // Animated number
    Text('$_currentScore', style: AppTypography.scoreLarge.copyWith(color: _scoreColor)),
    SizedBox(height: 4),
    Text(_statusLabel, style: TextStyle(color: _scoreColor, fontWeight: FontWeight.w700, fontSize: 13)),
    SizedBox(height: 12),
    // Segmented bar
    Row(
      children: List.generate(5, (i) => Expanded(
        child: Container(
          height: 6,
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: i < _filledSegments ? _scoreColor : AppColors.border,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      )),
    ),
  ],
)
```

Wrap in a `BrutalCard` with primary color border.

- [ ] **Step 3: Verify compilation**

Run: `flutter analyze 2>&1 | head -10`

- [ ] **Step 4: Commit**

```bash
git add lib/widgets/animated_score_gauge.dart
git commit -m "feat(gauge): redesign score gauge to segmented brutal style"
```

---

### Task 9: Redesign Business Detail Screen

**Files:**
- Modify: `lib/screens/audit/business_detail_screen.dart`

- [ ] **Step 1: Read current business_detail_screen.dart**

Read the full file (374 lines).

- [ ] **Step 2: Update header section**

Replace the header Card with a cleaner layout:
- Business category emoji in a tinted container (48x48, border-radius 14, background `primary.withValues(alpha: 0.15)`)
- Business name in `titleLarge.copyWith(fontWeight: FontWeight.w800)`
- Address in `bodyMedium` with `textSecondary` color
- Remove the outer Card wrapper — use just padding

- [ ] **Step 3: Restyle contact buttons to brutal**

Update `_ContactButton` class:
- Add `Color borderColor` parameter
- Wrap in a Container with `border: Border.all(color: borderColor, width: 2)` and `boxShadow: [BoxShadow(color: borderColor.withValues(alpha: 0.4), offset: Offset(2, 2), blurRadius: 0)]`
- Label text: uppercase, weight 700, font-size 10

Apply colors:
- Call: `AppColors.secondary` (blue)
- Website: `AppColors.primary` (orange)
- Map: `AppColors.success` (green)

- [ ] **Step 4: Restyle audit section**

- Score gauge is already updated (Task 8)
- Wrap AI diagnosis in a clean Card (no brutal border — informational content)
- Add "BREAKDOWN" section label in `labelBrutal` before breakdown items
- Style breakdown items: name on left, score on right with color (red <4, yellow 4-7, green >7)

- [ ] **Step 5: Restyle CTA buttons**

Replace `AnimatedButton.primary` / `AnimatedButton` with `BrutalButton`:
- "BUILD DEMO" → `BrutalButton(label: 'Build Demo', color: AppColors.primary)`
- "OUTREACH" → `BrutalButton.success(label: 'Outreach')`

Update imports: add `brutal_button.dart`, remove `animated_button.dart` if no longer used here.

- [ ] **Step 6: Restyle analyzing animation**

Update `_AnalyzingAnimation`:
- Each step card: small Container with brutal border that fills with color when complete
- Use orange border for in-progress, green for complete, grey for pending

- [ ] **Step 7: Verify compilation**

Run: `flutter analyze 2>&1 | head -10`

- [ ] **Step 8: Commit**

```bash
git add lib/screens/audit/business_detail_screen.dart
git commit -m "feat(detail): redesign business detail with brutal contact buttons + score"
```

---

## Chunk 4: Scout + Pipeline + Remaining Screens

### Task 10: Restyle Scout/Search Screen

**Files:**
- Modify: `lib/screens/scout/scout_screen.dart`
- Modify: `lib/widgets/niche_chips.dart`
- Modify: `lib/widgets/business_card.dart`

- [ ] **Step 1: Read current scout_screen.dart, niche_chips.dart, business_card.dart**

- [ ] **Step 2: Update search bar focus color**

In `scout_screen.dart`, find the `TextField` decoration and change `focusedBorder` to use `AppColors.primary` (#FF9F43) instead of the old purple. The search icon should also use `AppColors.primary` when focused.

- [ ] **Step 3: Update NicheChips to brutal-when-selected**

In `niche_chips.dart`, update the `ActionChip` styling:
- Selected: `backgroundColor: AppColors.primary`, `side: BorderSide(color: AppColors.primary, width: 2)`, label in `AppColors.background` (dark text on orange)
- Unselected: `backgroundColor: AppColors.surface`, `side: BorderSide(color: AppColors.border)`, label in `AppColors.textSecondary`

- [ ] **Step 4: Update BusinessCard styling**

In `business_card.dart`:
- Add subtle left border colored by status (found=grey, audited=blue, contacted=orange, etc.)
- Add `Hero` widget wrapping the business name or icon for transition to detail screen
- Score badge: if score exists, show in a small brutal-styled pill (colored border + tiny shadow)

- [ ] **Step 5: Replace empty state with EmptyState widget**

In `scout_screen.dart`, find the empty state section and replace with:
```dart
EmptyState.noResults(onRetry: () => _performSearch())
```

- [ ] **Step 6: Replace loading with SearchSkeleton**

Replace `LoadingShimmer()` usage with `SearchSkeleton()` (import from skeleton_loaders.dart).

- [ ] **Step 7: Verify compilation**

Run: `flutter analyze 2>&1 | head -10`

- [ ] **Step 8: Commit**

```bash
git add lib/screens/scout/scout_screen.dart lib/widgets/niche_chips.dart lib/widgets/business_card.dart
git commit -m "feat(scout): restyle search with brutal chips, hero cards, empty states"
```

---

### Task 11: Restyle Pipeline Screen

**Files:**
- Modify: `lib/screens/pipeline/pipeline_screen_enhanced.dart`

- [ ] **Step 1: Read current pipeline_screen_enhanced.dart**

- [ ] **Step 2: Restyle section headers**

For each pipeline stage section:
- Label text: use `AppTypography.labelBrutal` (uppercase, letter-spacing)
- Count badge: brutal pill with colored border matching stage (found=grey, audited=blue, demo_created=orange, contacted=green, etc.)

```dart
// Count badge example:
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  decoration: BoxDecoration(
    border: Border.all(color: stageColor, width: 2),
    borderRadius: BorderRadius.circular(6),
    boxShadow: [BoxShadow(color: stageColor.withValues(alpha: 0.3), offset: Offset(2, 2), blurRadius: 0)],
  ),
  child: Text('$count', style: TextStyle(color: stageColor, fontWeight: FontWeight.w800, fontSize: 12)),
)
```

- [ ] **Step 3: Add colored left border to pipeline business cards**

When displaying businesses in each stage section, wrap each business card with a Container that adds a 3px left border in the stage color:

```dart
Container(
  decoration: BoxDecoration(
    border: Border(left: BorderSide(color: stageColor, width: 3)),
    borderRadius: BorderRadius.circular(12),
  ),
  child: existingBusinessCard,
)
```

- [ ] **Step 4: Replace empty stage text with EmptyState**

For empty pipeline stages, use a compact version:
```dart
EmptyState.noLeads(onScout: () => navigationShell.goBranch(2))
```

- [ ] **Step 5: Restyle filter chips to brutal-when-active**

In the filter bottom sheet, selected filter gets brutal style (border + shadow), unselected stays clean.

- [ ] **Step 6: Update AppBar actions to use new colors**

Filter icon, export icon, refresh icon should use `AppColors.primary` when active.

- [ ] **Step 7: Verify compilation**

Run: `flutter analyze 2>&1 | head -10`

- [ ] **Step 8: Commit**

```bash
git add lib/screens/pipeline/pipeline_screen_enhanced.dart
git commit -m "feat(pipeline): restyle with brutal count badges + colored stage borders"
```

---

### Task 12: Restyle Login Screen

**Files:**
- Modify: `lib/screens/auth/login_screen.dart`

- [ ] **Step 1: Read current login_screen.dart**

- [ ] **Step 2: Update logo area**

Add animated gradient behind the logo text using `flutter_animate`:
- Container with `BoxDecoration` gradient from `AppColors.primary.withValues(alpha: 0.2)` to `AppColors.secondary.withValues(alpha: 0.15)`
- Animate with slow rotation or shimmer effect

- [ ] **Step 3: Restyle Sign In / Sign Up toggle**

Replace the current toggle with a brutal pill selector:
- Two containers side by side
- Active: filled with `AppColors.primary`, text in `AppColors.background`, brutal border + shadow
- Inactive: transparent, text in `AppColors.textSecondary`

- [ ] **Step 4: Restyle submit button**

Replace `AnimatedButton.primary` with `BrutalButton`:
```dart
BrutalButton(
  label: _isLogin ? 'Sign In' : 'Sign Up',
  onPressed: _handleEmailAuth,
  isLoading: _isLoading,
)
```

- [ ] **Step 5: Verify compilation**

Run: `flutter analyze 2>&1 | head -10`

- [ ] **Step 6: Commit**

```bash
git add lib/screens/auth/login_screen.dart
git commit -m "feat(login): restyle with brutal pill toggle + sunset gold accents"
```

---

### Task 13: Restyle Settings, Onboarding, Build Demo, Outreach

**Files:**
- Modify: `lib/screens/settings/settings_screen.dart`
- Modify: `lib/screens/onboarding/onboarding_screen_enhanced.dart`
- Modify: `lib/screens/build/build_demo_screen.dart`
- Modify: `lib/screens/outreach/outreach_screen.dart`

- [ ] **Step 1: Read all four files**

- [ ] **Step 2: Restyle Settings**

- Usage meter progress bars: wrap container in brutal border when usage is high (>80%)
- Pro badge: if subscribed, show a BrutalCard with gold border saying "PRO"
- Subscription CTA: replace with `BrutalButton(label: 'Upgrade to Pro')` if free tier
- Section labels: uppercase + `labelBrutal` style

- [ ] **Step 3: Restyle Onboarding**

- Update feature icon tint colors from purple to `AppColors.primary` (orange)
- "Get Started" button: replace with `BrutalButton`
- Page indicator dots: color update to `AppColors.primary`
- Keep everything else (it's already 9/10)

- [ ] **Step 4: Restyle Build Demo Screen**

- Template selection cards: use `BrutalCard` for selected template (orange border), clean for unselected
- "Generate Demo" button: `BrutalButton`
- Success state: use `BrutalCard` with `AppColors.success` border for the URL display
- Share/Open buttons: `BrutalButton` and `BrutalButton.secondary`

- [ ] **Step 5: Restyle Outreach Screen**

- Channel selection chips: brutal when selected, clean when not
- "Generate Message" button: `BrutalButton`
- Copy/Share buttons: `BrutalButton.secondary`
- Upgrade CTA: `BrutalButton(label: 'Upgrade to Pro')`

- [ ] **Step 6: Verify compilation of all changes**

Run: `flutter analyze 2>&1 | head -30`

- [ ] **Step 7: Commit**

```bash
git add lib/screens/settings/settings_screen.dart lib/screens/onboarding/onboarding_screen_enhanced.dart lib/screens/build/build_demo_screen.dart lib/screens/outreach/outreach_screen.dart
git commit -m "feat(screens): restyle settings, onboarding, build-demo, outreach with brutal accents"
```

---

## Chunk 5: Page Transitions + Final Polish

### Task 14: Add Custom Page Transitions

**Files:**
- Modify: `lib/config/routes.dart`

- [ ] **Step 1: Read current routes.dart**

- [ ] **Step 2: Add custom page transition builder**

Create a reusable transition for GoRouter routes:

```dart
CustomTransitionPage<void> _buildPageTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
```

- [ ] **Step 3: Apply to all non-shell routes**

Update each `GoRoute` that is NOT inside the shell (business detail, build-demo, outreach) to use `pageBuilder` instead of `builder`:

```dart
GoRoute(
  path: '/business/:id',
  pageBuilder: (context, state) => _buildPageTransition(
    context: context,
    state: state,
    child: BusinessDetailScreen(businessId: state.pathParameters['id']!),
  ),
),
```

- [ ] **Step 4: Verify compilation**

Run: `flutter analyze 2>&1 | head -10`

- [ ] **Step 5: Commit**

```bash
git add lib/config/routes.dart
git commit -m "feat(nav): add slide+fade page transitions for detail routes"
```

---

### Task 15: Add Hero Animations for Business Cards

**Files:**
- Modify: `lib/widgets/business_card.dart`
- Modify: `lib/screens/audit/business_detail_screen.dart`

- [ ] **Step 1: Add Hero to BusinessCard**

In `business_card.dart`, wrap the business name Text widget in a Hero:

```dart
Hero(
  tag: 'business-name-${business.id}',
  child: Material(
    color: Colors.transparent,
    child: Text(
      business.name,
      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
    ),
  ),
),
```

- [ ] **Step 2: Add Hero to BusinessDetailScreen**

In `business_detail_screen.dart`, wrap the business name in the header with a matching Hero:

```dart
Hero(
  tag: 'business-name-${business.id}',
  child: Material(
    color: Colors.transparent,
    child: Text(
      business.name,
      style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
    ),
  ),
),
```

- [ ] **Step 3: Verify compilation**

Run: `flutter analyze 2>&1 | head -10`

- [ ] **Step 4: Commit**

```bash
git add lib/widgets/business_card.dart lib/screens/audit/business_detail_screen.dart
git commit -m "feat(animation): add hero transition on business card → detail"
```

---

### Task 16: Final Cleanup + Remove Old AnimatedButton References

**Files:**
- Modify: any files still importing `animated_button.dart`
- Keep: `lib/widgets/animated_button.dart` (for backward compat, mark deprecated)

- [ ] **Step 1: Search for AnimatedButton usages**

Run: `grep -r "AnimatedButton" lib/ --include="*.dart" -l`

For each file found, replace `AnimatedButton.primary(...)` with `BrutalButton(...)` and `AnimatedButton(...)` with `BrutalButton(...)`. Update imports accordingly.

- [ ] **Step 2: Add deprecation notice to animated_button.dart**

Add at top of `AnimatedButton` class:
```dart
@Deprecated('Use BrutalButton instead')
```

- [ ] **Step 3: Search for old purple color references**

Run: `grep -rn "6C5CE7\|5849C7\|8B7FE8" lib/ --include="*.dart"`

Replace any hardcoded purple color references with `AppColors.primary` or appropriate new color.

- [ ] **Step 4: Final compilation check**

Run: `flutter analyze 2>&1 | tail -5`
Expected: 0 errors. Warnings about deprecated `withOpacity` are OK.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat(cleanup): migrate all AnimatedButton to BrutalButton + remove purple refs"
```

---

### Task 17: Verify Full App Builds

- [ ] **Step 1: Run full analysis**

Run: `flutter analyze`
Expected: 0 errors

- [ ] **Step 2: Run tests if any exist**

Run: `flutter test`

- [ ] **Step 3: Final commit if any fixes needed**

```bash
git add -A
git commit -m "fix: resolve remaining compilation issues from UI overhaul"
```
