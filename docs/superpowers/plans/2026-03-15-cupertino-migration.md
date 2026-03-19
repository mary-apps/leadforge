# Cupertino Migration Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate LeadForge from Material Design to native Cupertino widgets with Light + Dark mode support.

**Architecture:** Replace MaterialApp with CupertinoApp.router, swap all Material widgets for Cupertino equivalents, use CupertinoTabBar (as direct widget within GoRouter shell, not CupertinoTabScaffold), and CupertinoNavigationBar for detail screens. Preserve Riverpod state management and GoRouter navigation unchanged.

**Tech Stack:** Flutter 3+, Cupertino widgets, CupertinoDynamicColor, GoRouter, Riverpod

**Spec:** `docs/superpowers/specs/2026-03-15-cupertino-migration-design.md`

---

## Chunk 1: Theme + CupertinoApp Base (Phase 1)

### Task 1: Rewrite theme.dart with CupertinoThemeData

**Files:**
- Modify: `lib/config/theme.dart`

- [ ] **Step 1: Rewrite AppColors with CupertinoDynamicColor**

Replace the entire `AppColors` class with dynamic colors that adapt to Light/Dark mode:

```dart
import 'package:flutter/cupertino.dart';

class AppColors {
  // Backgrounds
  static const background = CupertinoColors.systemGroupedBackground;
  static const surface = CupertinoColors.secondarySystemGroupedBackground;
  static const surfaceLight = CupertinoColors.tertiarySystemGroupedBackground;

  // Primary
  static const primary = CupertinoColors.systemBlue;

  // Semantic
  static const success = CupertinoColors.systemGreen;
  static const warning = CupertinoColors.systemOrange;
  static const danger = CupertinoColors.systemRed;
  static const info = CupertinoColors.systemIndigo;

  // Text
  static const textPrimary = CupertinoColors.label;
  static const textSecondary = CupertinoColors.secondaryLabel;
  static const textTertiary = CupertinoColors.tertiaryLabel;

  // Borders
  static const border = CupertinoColors.separator;
  static const divider = CupertinoColors.opaqueSeparator;

  // Border radius tokens (keep existing values)
  static const double radiusS = 6.0;
  static const double radiusM = 10.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 28.0;
}
```

- [ ] **Step 2: Rewrite AppTypography to use system font**

Replace the entire `AppTypography` class — remove all google_fonts references:

```dart
class AppTypography {
  // Omit fontFamily to use system default (SF Pro on iOS, Roboto on Android)

  static const displayLarge = TextStyle(

    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
  );

  static const headlineLarge = TextStyle(

    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.36,
  );

  static const titleLarge = TextStyle(

    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.35,
  );

  static const titleMedium = TextStyle(

    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
  );

  static const bodyLarge = TextStyle(

    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    height: 1.3,
  );

  static const bodyMedium = TextStyle(

    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
  );

  static const labelLarge = TextStyle(

    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.08,
  );

  static const labelSmall = TextStyle(

    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.07,
  );

  static const numberLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.36,
  );

  static const scoreLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.37,
  );

  static const button = TextStyle(

    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
  );
}
```

- [ ] **Step 3: Replace darkTheme with CupertinoThemeData**

Remove the `AppTheme` class with its `darkTheme` getter. Replace with:

```dart
class AppTheme {
  static CupertinoThemeData get theme => const CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        barBackgroundColor: CupertinoColors.systemBackground,
        textTheme: CupertinoTextThemeData(
          primaryColor: CupertinoColors.systemBlue,
          textStyle: AppTypography.bodyMedium,
          navTitleTextStyle: AppTypography.titleMedium,
          navLargeTitleTextStyle: AppTypography.displayLarge,
          tabLabelTextStyle: AppTypography.labelSmall,
        ),
      );
}
```

- [ ] **Step 4: Remove unused imports and gradient/glass constants**

Delete `AppColors.primaryGradient`, `accentGradient`, `surfaceGradient`, `glassBackground`, `glassBorder`, and any `scoreGradient` helper. These are no longer needed in Cupertino style.

- [ ] **Step 5: Verify file compiles**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/config/theme.dart`

---

### Task 2: Switch to CupertinoApp.router

**Files:**
- Modify: `lib/app.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Rewrite app.dart with CupertinoApp.router**

Replace the full content of `lib/app.dart`:

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/routes.dart';

class LeadForgeApp extends ConsumerWidget {
  const LeadForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return CupertinoApp.router(
      title: 'LeadForge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate, // Keep temporarily
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
```

- [ ] **Step 2: Update main.dart system overlay to be dynamic**

In `lib/main.dart`, replace the hardcoded `SystemChrome.setSystemUIOverlayStyle()` call (lines 18-25) with:

```dart
SystemChrome.setSystemUIOverlayStyle(
  const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
  ),
);
```

Note: CupertinoApp handles status bar styling automatically based on the theme, so this is just a fallback. The hardcoded dark-only values must be removed.

- [ ] **Step 3: Replace material.dart import in main.dart**

Change `import 'package:flutter/material.dart';` to `import 'package:flutter/cupertino.dart';` in main.dart. Keep `package:flutter/services.dart` for SystemChrome.

- [ ] **Step 4: Verify app launches**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/app.dart lib/main.dart`

---

### Task 3: Update GoRouter for Cupertino transitions

**Files:**
- Modify: `lib/config/routes.dart`

- [ ] **Step 1: Replace custom page transition with CupertinoPage**

Remove the `_buildPageTransition()` function (lines 18-39). Replace all usages with `CupertinoPage`:

Where routes currently use `_buildPageTransition(child: SomeScreen())`, replace with:

```dart
GoRoute(
  path: '/login',
  pageBuilder: (context, state) => CupertinoPage(
    child: LoginScreen(),
  ),
),
```

Do this for all non-shell routes: `/login`, `/onboarding`, `/business/:id`, `/business/:id/build-demo`, `/business/:id/outreach`.

- [ ] **Step 2: Update import**

Change `import 'package:flutter/material.dart';` to `import 'package:flutter/cupertino.dart';` in routes.dart. Keep `package:go_router/go_router.dart`.

- [ ] **Step 3: Verify routes compile**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/config/routes.dart`

---

### Task 4: Remove google_fonts dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Remove google_fonts and add cupertino_icons in pubspec.yaml**

Remove the `google_fonts: ^x.x.x` line from dependencies. Add `cupertino_icons: ^1.0.8` if not already present (required for all `CupertinoIcons.*` references).

- [ ] **Step 2: Remove any remaining google_fonts imports**

Search for and remove any `import 'package:google_fonts/google_fonts.dart';` across the codebase.

Run: `grep -r "google_fonts" lib/`

- [ ] **Step 3: Run flutter pub get**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter pub get`

- [ ] **Step 4: Commit Phase 1**

```bash
git add lib/config/theme.dart lib/app.dart lib/main.dart lib/config/routes.dart pubspec.yaml pubspec.lock
git commit -m "feat: Phase 1 — CupertinoApp base with dynamic Light/Dark theme"
```

---

## Chunk 2: Navigation (Phase 2)

### Task 5: Rewrite bottom navigation as CupertinoTabBar

**Files:**
- Modify: `lib/widgets/app_bottom_nav.dart`

- [ ] **Step 1: Rewrite app_bottom_nav.dart**

Replace the entire file. The new version uses `CupertinoTabBar` as a direct widget inside GoRouter's shell, without `CupertinoTabScaffold`:

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppBottomNav extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNav({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(child: navigationShell),
          CupertinoTabBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.house_fill),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chart_bar_fill),
                label: 'Pipeline',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.search),
                label: 'Scout',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.bubble_left_fill),
                label: 'Activity',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.gear),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

This removes: floating glass nav, scout orb FAB, breathing animation, glow indicator, badge dots, ~430 lines of code.

- [ ] **Step 2: Verify bottom nav compiles**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/widgets/app_bottom_nav.dart`

---

### Task 6: Add CupertinoNavigationBar to detail screens

**Files:**
- Modify: `lib/screens/audit/business_detail_screen.dart`
- Modify: `lib/screens/build/build_demo_screen.dart`
- Modify: `lib/screens/outreach/outreach_screen.dart`

- [ ] **Step 1: Update business_detail_screen.dart**

Replace the Scaffold and custom back button header. Wrap in `CupertinoPageScaffold` with `CupertinoNavigationBar`:

```dart
@override
Widget build(BuildContext context) {
  return CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      previousPageTitle: 'Pipeline',
      middle: Text(business.name),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Icon(CupertinoIcons.share),
        onPressed: () => ShareBusinessSheet.show(context, business),
      ),
    ),
    child: SafeArea(
      top: false,
      child: CustomScrollView(
        // ... existing sliver content, minus the old header SliverToBoxAdapter
      ),
    ),
  );
}
```

Remove: AuroraBackground wrapper, custom back button SliverToBoxAdapter, gradient text header.

- [ ] **Step 2: Update build_demo_screen.dart**

Replace Scaffold + AppBar with CupertinoPageScaffold + CupertinoNavigationBar:

```dart
return CupertinoPageScaffold(
  navigationBar: const CupertinoNavigationBar(
    previousPageTitle: 'Detail',
    middle: Text('Build Demo'),
  ),
  child: SafeArea(
    top: false,
    child: // existing content without confetti Stack
  ),
);
```

Remove: Material AppBar, GradientText title, confetti overlay.

- [ ] **Step 3: Update outreach_screen.dart**

Same pattern as build_demo_screen:

```dart
return CupertinoPageScaffold(
  navigationBar: const CupertinoNavigationBar(
    previousPageTitle: 'Detail',
    middle: Text('Outreach'),
  ),
  child: SafeArea(
    top: false,
    child: // existing content without confetti Stack
  ),
);
```

Remove: Material AppBar, GradientText title, confetti overlay.

- [ ] **Step 4: Verify detail screens compile**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/screens/audit/ lib/screens/build/ lib/screens/outreach/`

- [ ] **Step 5: Commit Phase 2**

```bash
git add lib/widgets/app_bottom_nav.dart lib/screens/audit/ lib/screens/build/ lib/screens/outreach/ lib/config/routes.dart
git commit -m "feat: Phase 2 — CupertinoTabBar navigation + CupertinoNavigationBar on detail screens"
```

---

## Chunk 3: Common Widgets (Phase 3)

### Task 7: Migrate BrutalButton to CupertinoButton

**Files:**
- Modify: `lib/widgets/brutal_button.dart`

- [ ] **Step 1: Rewrite brutal_button.dart**

Replace entirely with a thin wrapper around CupertinoButton that preserves the existing API:

```dart
import 'package:flutter/cupertino.dart';
import '../config/theme.dart';

class BrutalButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool compact;
  final _ButtonVariant _variant;

  const BrutalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.compact = false,
  }) : _variant = _ButtonVariant.primary;

  const BrutalButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.compact = false,
  }) : _variant = _ButtonVariant.secondary;

  const BrutalButton.success({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.compact = false,
  }) : _variant = _ButtonVariant.success;

  const BrutalButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.compact = false,
  }) : _variant = _ButtonVariant.danger;

  const BrutalButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.compact = false,
  }) : _variant = _ButtonVariant.ghost;

  Color _color(BuildContext context) {
    return switch (_variant) {
      _ButtonVariant.primary => CupertinoColors.systemBlue.resolveFrom(context),
      _ButtonVariant.secondary => CupertinoColors.secondaryLabel.resolveFrom(context),
      _ButtonVariant.success => CupertinoColors.systemGreen.resolveFrom(context),
      _ButtonVariant.danger => CupertinoColors.systemRed.resolveFrom(context),
      _ButtonVariant.ghost => CupertinoColors.systemBlue.resolveFrom(context),
    };
  }

  bool get _isFilled =>
      _variant == _ButtonVariant.primary ||
      _variant == _ButtonVariant.success ||
      _variant == _ButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    final child = isLoading
        ? const CupertinoActivityIndicator()
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    if (_isFilled) {
      return SizedBox(
        width: compact ? null : double.infinity,
        child: CupertinoButton(
          color: color,
          padding: EdgeInsets.symmetric(
            vertical: compact ? 8 : 14,
            horizontal: compact ? 16 : 24,
          ),
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: compact ? null : double.infinity,
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(
          vertical: compact ? 8 : 14,
          horizontal: compact ? 16 : 24,
        ),
        onPressed: isLoading ? null : onPressed,
        child: DefaultTextStyle(
          style: TextStyle(color: color),
          child: IconTheme(
            data: IconThemeData(color: color),
            child: child,
          ),
        ),
      ),
    );
  }
}

enum _ButtonVariant { primary, secondary, success, danger, ghost }
```

- [ ] **Step 2: Verify button compiles and is used correctly**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/widgets/brutal_button.dart`

---

### Task 8: Migrate BrutalCard to iOS-style container

**Files:**
- Modify: `lib/widgets/brutal_card.dart`

- [ ] **Step 1: Rewrite brutal_card.dart**

Replace with a clean iOS-style container:

```dart
import 'package:flutter/cupertino.dart';

class BrutalCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const BrutalCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground
            .resolveFrom(context),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}
```

- [ ] **Step 2: Verify card compiles**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/widgets/brutal_card.dart`

---

### Task 9: Migrate BusinessCard to CupertinoListTile style

**Files:**
- Modify: `lib/widgets/business_card.dart`

- [ ] **Step 1: Rewrite business_card.dart**

Replace with a Cupertino-style list tile with avatar and chevron:

```dart
import 'package:flutter/cupertino.dart';
import '../models/business.dart';

class BusinessCard extends StatelessWidget {
  final Business business;
  final VoidCallback? onTap;

  const BusinessCard({
    super.key,
    required this.business,
    this.onTap,
  });

  Color _scoreColor(BuildContext context) {
    final score = business.auditScore ?? 0;
    if (score >= 70) return CupertinoColors.systemGreen.resolveFrom(context);
    if (score >= 40) return CupertinoColors.systemOrange.resolveFrom(context);
    return CupertinoColors.systemRed.resolveFrom(context);
  }

  @override
  Widget build(BuildContext context) {
    final biz = business;
    final scoreColor = _scoreColor(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemGroupedBackground
              .resolveFrom(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5.resolveFrom(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                biz.website != null
                    ? CupertinoIcons.globe
                    : CupertinoIcons.building_2_fill,
                size: 20,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
            const SizedBox(width: 12),
            // Name + address
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    biz.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (biz.address != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      biz.address!,
                      style: TextStyle(
                        fontSize: 15,
                        color: CupertinoColors.secondaryLabel
                            .resolveFrom(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Score badge
            if (biz.auditScore != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${biz.auditScore}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            // Chevron
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: CupertinoColors.tertiaryLabel.resolveFrom(context),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify business card compiles**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/widgets/business_card.dart`

---

### Task 10: Migrate remaining widgets

**Files:**
- Modify: `lib/widgets/niche_chips.dart`
- Modify: `lib/widgets/empty_state.dart`
- Modify: `lib/widgets/error_state.dart`
- Modify: `lib/widgets/share_business_sheet.dart`

- [ ] **Step 1: Rewrite niche_chips.dart with Cupertino pills**

Replace with CupertinoButton-based toggle pills:

```dart
import 'package:flutter/cupertino.dart';
import '../config/constants.dart';

class NicheChips extends StatelessWidget {
  final Function(String) onSelected;
  final String? selectedNiche;

  const NicheChips({
    super.key,
    required this.onSelected,
    this.selectedNiche,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.suggestedNiches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final niche = AppConstants.suggestedNiches[index];
          final isSelected = selectedNiche == niche;
          return GestureDetector(
            onTap: () => onSelected(niche),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? CupertinoColors.systemBlue.resolveFrom(context)
                    : CupertinoColors.tertiarySystemFill.resolveFrom(context),
                borderRadius: BorderRadius.circular(19),
              ),
              child: Text(
                niche,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? CupertinoColors.white
                      : CupertinoColors.label.resolveFrom(context),
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

- [ ] **Step 2: Rewrite empty_state.dart with CupertinoIcons**

Replace custom painters with CupertinoIcons. Simplify:

```dart
import 'package:flutter/cupertino.dart';
import 'brutal_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  factory EmptyState.noResults({VoidCallback? onAction}) => EmptyState(
        icon: CupertinoIcons.search,
        title: 'No results found',
        subtitle: 'Try adjusting your search or filters',
        actionLabel: onAction != null ? 'Clear Filters' : null,
        onAction: onAction,
      );

  factory EmptyState.noLeads({VoidCallback? onAction}) => EmptyState(
        icon: CupertinoIcons.square_stack_3d_up,
        title: 'No leads yet',
        subtitle: 'Start scouting to find your first leads',
        actionLabel: onAction != null ? 'Start Scouting' : null,
        onAction: onAction,
      );

  factory EmptyState.firstTime({VoidCallback? onAction}) => EmptyState(
        icon: CupertinoIcons.sparkles,
        title: 'Welcome to LeadForge',
        subtitle: 'Search for businesses to get started',
        actionLabel: onAction != null ? 'Get Started' : null,
        onAction: onAction,
      );

  factory EmptyState.noMessages({VoidCallback? onAction}) => EmptyState(
        icon: CupertinoIcons.bubble_left,
        title: 'No messages yet',
        subtitle: 'Activity will appear here as you engage with leads',
        actionLabel: null,
        onAction: null,
      );

  factory EmptyState.error({required VoidCallback onAction}) => EmptyState(
        icon: CupertinoIcons.exclamationmark_triangle,
        title: 'Something went wrong',
        subtitle: 'Please try again',
        actionLabel: 'Retry',
        onAction: onAction,
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              BrutalButton(
                label: actionLabel!,
                onPressed: onAction,
                compact: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Rewrite error_state.dart with Cupertino**

```dart
import 'package:flutter/cupertino.dart';
import '../utils/network.dart';
import 'brutal_button.dart';

class ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final String title;
    final String subtitle;

    if (error is NoConnectionException) {
      icon = CupertinoIcons.wifi_slash;
      title = 'No connection';
      subtitle = 'Check your internet and try again';
    } else if (error is ServerException) {
      icon = CupertinoIcons.cloud_slash;
      title = 'Server error';
      subtitle = 'Something went wrong on our end';
    } else {
      icon = CupertinoIcons.exclamationmark_circle;
      title = 'Something went wrong';
      subtitle = 'Please try again';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            BrutalButton.secondary(
              label: 'Try Again',
              icon: CupertinoIcons.refresh,
              onPressed: onRetry,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Rewrite share_business_sheet.dart with CupertinoActionSheet**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/business.dart';

class ShareBusinessSheet extends StatelessWidget {
  final Business business;

  const ShareBusinessSheet({super.key, required this.business});

  static Future<void> show(BuildContext context, Business business) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => ShareBusinessSheet(business: business),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text('Share ${business.name}'),
      message: const Text('Choose how to share this lead'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _copyBusinessText(context);
          },
          child: const Text('Copy Business Info'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _shareViaSystem(context);
          },
          child: const Text('Share via...'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    );
  }

  void _copyBusinessText(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _formatBusinessText()));
    // TODO: Replace with iOS-style toast in Task 11
  }

  void _shareViaSystem(BuildContext context) {
    final text = _formatBusinessText();
    Share.share(text, subject: business.name);
  }

  String _formatBusinessText() {
    final buf = StringBuffer();
    buf.writeln(business.name);
    if (business.address != null) buf.writeln(business.address);
    if (business.phone != null) buf.writeln(business.phone);
    if (business.website != null) buf.writeln(business.website);
    if (business.auditScore != null) buf.writeln('Score: ${business.auditScore}');
    return buf.toString();
  }
}
```

- [ ] **Step 5: Verify all widgets compile**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/widgets/`

---

### Task 10b: Migrate remaining widgets (color adaptation)

**Files:**
- Modify: `lib/widgets/stat_card_animated.dart`
- Modify: `lib/widgets/weekly_activity_graph.dart`
- Modify: `lib/widgets/skeleton_loaders.dart`
- Modify: `lib/widgets/search_suggestions.dart`
- Modify: `lib/widgets/animated_score_gauge.dart`

- [ ] **Step 1: Adapt StatCardAnimated colors to CupertinoColors**

Replace all `AppColors.primary`, `AppColors.surface`, etc. references with `CupertinoColors` equivalents. Update imports from `material.dart` to `cupertino.dart`.

- [ ] **Step 2: Adapt WeeklyActivityGraph colors to CupertinoColors**

Update fl_chart color references to use `CupertinoColors`. Keep fl_chart widget structure unchanged.

- [ ] **Step 3: Adapt SkeletonLoaders colors to CupertinoColors**

Update skeleton placeholder colors. If `loading_shimmer.dart` depends on the `shimmer` package, rewrite it to use a simple `AnimatedOpacity` pulse instead.

- [ ] **Step 4: Migrate SearchSuggestions to use CupertinoSearchTextField pattern**

Update styling and colors to match Cupertino. Replace Material icons with CupertinoIcons.

- [ ] **Step 5: Adapt AnimatedScoreGauge colors to CupertinoColors**

Update the ring gradient and score text colors to use `CupertinoColors.systemGreen/Orange/Red` based on score value.

- [ ] **Step 6: Audit flutter_animate usages — remove .shimmer() effects**

Run: `grep -rn "\.shimmer\b" lib/ --include="*.dart"`

Remove all `.shimmer()` calls from `flutter_animate` chains. Keep `.fadeIn()`, `.slideX()`, `.slideY()` for staggered list animations.

- [ ] **Step 7: Verify all adapted widgets compile**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/widgets/`

---

### Task 11: Create iOS-style toast utility and replace SnackBars

**Files:**
- Create: `lib/widgets/ios_toast.dart`
- Modify: files that use `ScaffoldMessenger.showSnackBar`

- [ ] **Step 1: Create ios_toast.dart**

A lightweight overlay notification for iOS-style feedback:

```dart
import 'package:flutter/cupertino.dart';

class IosToast {
  static void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Navigator.of(context).overlay;
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        icon: icon,
        duration: duration,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    this.icon,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: CupertinoColors.secondarySystemGroupedBackground
                  .resolveFrom(context),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 20,
                    color: CupertinoColors.systemBlue.resolveFrom(context),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Replace all ScaffoldMessenger.showSnackBar calls**

Search for all SnackBar usages and replace with `IosToast.show()`:

Run: `grep -rn "ScaffoldMessenger\|showSnackBar" lib/`

For each occurrence, replace:
```dart
// Before:
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Done')));

// After:
IosToast.show(context, 'Done', icon: CupertinoIcons.check_mark);
```

- [ ] **Step 3: Verify toast and usages compile**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/`

---

### Task 12: Replace dialogs and bottom sheets

**Files:**
- Modify: `lib/screens/pipeline/pipeline_screen_enhanced.dart` (showModalBottomSheet + showDialog)
- Modify: `lib/screens/settings/settings_screen.dart` (showDialog)
- Modify: `lib/screens/build/build_demo_screen.dart` (showDialog)
- Modify: `lib/screens/outreach/outreach_screen.dart` (showDialog)
- Modify: `lib/screens/auth/login_screen.dart` (showDialog)
- Modify: `lib/screens/scout/scout_screen.dart` (showDialog if present)

- [ ] **Step 1: Replace showDialog calls with showCupertinoDialog**

For each file, find `showDialog` and replace with `showCupertinoDialog` using `CupertinoAlertDialog`:

```dart
// Before:
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Delete?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
      TextButton(onPressed: onDelete, child: Text('Delete')),
    ],
  ),
);

// After:
showCupertinoDialog(
  context: context,
  builder: (context) => CupertinoAlertDialog(
    title: const Text('Delete?'),
    actions: [
      CupertinoDialogAction(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      CupertinoDialogAction(
        isDestructiveAction: true,
        onPressed: onDelete,
        child: const Text('Delete'),
      ),
    ],
  ),
);
```

Apply to: Pipeline (delete confirmation), Settings (sign out), BuildDemo (paywall), Outreach (paywall), Login (password reset).

- [ ] **Step 2: Replace showModalBottomSheet with showCupertinoModalPopup**

In pipeline_screen_enhanced.dart, replace the filter bottom sheet:

```dart
// Before:
showModalBottomSheet(context: context, builder: ...);

// After:
showCupertinoModalPopup(
  context: context,
  builder: (context) => CupertinoActionSheet(
    title: const Text('Filter Pipeline'),
    actions: [/* filter options as CupertinoActionSheetAction */],
    cancelButton: CupertinoActionSheetAction(
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancel'),
    ),
  ),
);
```

- [ ] **Step 3: Verify all dialog replacements compile**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/screens/`

- [ ] **Step 4: Commit Phase 3**

```bash
git add lib/widgets/ lib/screens/
git commit -m "feat: Phase 3 — migrate all widgets to Cupertino (buttons, cards, dialogs, toasts)"
```

---

## Chunk 4: Screens (Phase 4)

### Task 13: Migrate Dashboard screen

**Files:**
- Modify: `lib/screens/dashboard/dashboard_screen.dart`

- [ ] **Step 1: Replace Scaffold with CupertinoPageScaffold**

Replace the Scaffold wrapper with CupertinoPageScaffold. Remove AuroraBackground.

- [ ] **Step 2: Replace SliverAppBar with CupertinoSliverNavigationBar**

```dart
CupertinoSliverNavigationBar(
  largeTitle: const Text('LeadForge'),
),
```

Remove: FlexibleSpaceBar, gradient text, ShimmerText.

- [ ] **Step 3: Replace RefreshIndicator with CupertinoSliverRefreshControl**

```dart
CustomScrollView(
  slivers: [
    CupertinoSliverNavigationBar(largeTitle: const Text('LeadForge')),
    CupertinoSliverRefreshControl(
      onRefresh: () async { /* existing refresh logic */ },
    ),
    // ... rest of slivers
  ],
)
```

- [ ] **Step 4: Replace GlowCard usages with BrutalCard (now iOS-styled)**

Replace all `GlowCard` widgets with `BrutalCard` (which is now an iOS-style container from Task 8).

- [ ] **Step 5: Remove ShimmerText, PulseDot usages**

Replace `ShimmerText` with plain `Text`. Remove `PulseDot` indicators.

- [ ] **Step 6: Update Material imports to Cupertino**

Change `import 'package:flutter/material.dart'` to `import 'package:flutter/cupertino.dart'`.

- [ ] **Step 7: Verify dashboard compiles**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/screens/dashboard/`

---

### Task 14: Migrate Pipeline screen

**Files:**
- Modify: `lib/screens/pipeline/pipeline_screen_enhanced.dart`

- [ ] **Step 1: Replace Scaffold with CupertinoPageScaffold**

- [ ] **Step 2: Replace section headers with CupertinoListSection style**

Use `CupertinoListSection.insetGrouped` for pipeline stages.

- [ ] **Step 3: Remove PulseDot, ShimmerText usages**

- [ ] **Step 4: Update imports to Cupertino**

- [ ] **Step 5: Verify pipeline compiles**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/screens/pipeline/`

---

### Task 15: Migrate Scout screen

**Files:**
- Modify: `lib/screens/scout/scout_screen.dart`

- [ ] **Step 1: Replace Scaffold with CupertinoPageScaffold**

- [ ] **Step 2: Replace TextField with CupertinoSearchTextField**

```dart
CupertinoSearchTextField(
  controller: _searchController,
  placeholder: 'Search businesses...',
  onSubmitted: (value) => _search(value),
  onChanged: (value) => _onSearchChanged(value),
)
```

- [ ] **Step 3: Remove AuroraBackground, GlowCard, ForgeLoader, ShimmerText, PulseDot**

Replace GlowCard with BrutalCard, ForgeLoader with `CupertinoActivityIndicator`.

- [ ] **Step 4: Update imports to Cupertino**

- [ ] **Step 5: Verify scout compiles**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/screens/scout/`

---

### Task 16: Migrate Messages screen

**Files:**
- Modify: `lib/screens/messages/messages_screen.dart`

- [ ] **Step 1: Replace Scaffold with CupertinoPageScaffold**

- [ ] **Step 2: Replace SliverAppBar with CupertinoSliverNavigationBar**

```dart
CupertinoSliverNavigationBar(
  largeTitle: const Text('Activity'),
),
```

- [ ] **Step 3: Remove GlowCard, ShimmerText usages**

- [ ] **Step 4: Update imports to Cupertino**

- [ ] **Step 5: Verify messages compiles**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/screens/messages/`

---

### Task 17: Migrate Settings screen

**Files:**
- Modify: `lib/screens/settings/settings_screen.dart`

- [ ] **Step 1: Replace Scaffold with CupertinoPageScaffold**

- [ ] **Step 2: Use CupertinoListSection.insetGrouped for settings groups**

```dart
CupertinoListSection.insetGrouped(
  header: const Text('Account'),
  children: [
    CupertinoListTile(
      title: const Text('Profile'),
      leading: const Icon(CupertinoIcons.person),
      trailing: const CupertinoListTileChevron(),
      onTap: () { /* ... */ },
    ),
    // ...
  ],
)
```

- [ ] **Step 3: Remove AuroraBackground, GlowCard, ShimmerText**

- [ ] **Step 4: Update imports to Cupertino**

- [ ] **Step 5: Verify settings compiles**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/screens/settings/`

---

### Task 18: Migrate Login and Onboarding screens

**Files:**
- Modify: `lib/screens/auth/login_screen.dart`
- Modify: `lib/screens/onboarding/onboarding_screen_enhanced.dart` (this is the file used by the router, not `onboarding_screen.dart`)

- [ ] **Step 1: Login — Replace Scaffold with CupertinoPageScaffold**

- [ ] **Step 2: Login — Replace TextFormField with CupertinoTextField**

```dart
CupertinoTextField(
  controller: _emailController,
  placeholder: 'Email',
  keyboardType: TextInputType.emailAddress,
  prefix: const Padding(
    padding: EdgeInsets.only(left: 12),
    child: Icon(CupertinoIcons.mail, size: 20),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  decoration: BoxDecoration(
    color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
    borderRadius: BorderRadius.circular(10),
  ),
)
```

Add custom validation display below fields (since CupertinoTextField has no errorText).

- [ ] **Step 3: Login — Remove AuroraBackground, gradient buttons**

Replace custom `_GradientSubmitButton` with `BrutalButton`.

- [ ] **Step 4: Onboarding (onboarding_screen_enhanced.dart) — Replace Scaffold with CupertinoPageScaffold**

- [ ] **Step 5: Onboarding — Remove AuroraBackground, gradient elements, replace SnackBars with IosToast**

Replace `_GlowButton` with `CupertinoButton.filled`. Replace gradient text with plain styled text.

- [ ] **Step 6: Update imports to Cupertino in both files**

- [ ] **Step 7: Verify auth screens compile**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/screens/auth/ lib/screens/onboarding/`

---

### Task 19: Migrate BusinessDetail screen content

**Files:**
- Modify: `lib/screens/audit/business_detail_screen.dart`

- [ ] **Step 1: Adapt content sections to CupertinoListSection**

Wrap business info sections in `CupertinoListSection.insetGrouped`:

```dart
CupertinoListSection.insetGrouped(
  header: const Text('Contact'),
  children: [
    CupertinoListTile(
      title: const Text('Phone'),
      subtitle: Text(business.phone ?? 'N/A'),
      leading: const Icon(CupertinoIcons.phone),
      onTap: () => _callPhone(business.phone),
    ),
    CupertinoListTile(
      title: const Text('Website'),
      subtitle: Text(business.website ?? 'N/A'),
      leading: const Icon(CupertinoIcons.globe),
      onTap: () => _openWebsite(business.website),
    ),
  ],
)
```

- [ ] **Step 2: Keep AnimatedScoreGauge, adapt its colors**

Update the score gauge to use `CupertinoColors` instead of `AppColors.primary/success/danger`.

- [ ] **Step 3: Remove AuroraBackground, GlowCard, custom glow buttons**

Replace `_GlowContactButton` and `_GlowCTAButton` with `CupertinoButton`.

- [ ] **Step 4: Verify business detail compiles**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/screens/audit/`

- [ ] **Step 5: Commit Phase 4**

```bash
git add lib/screens/
git commit -m "feat: Phase 4 — migrate all screens to CupertinoPageScaffold"
```

---

## Chunk 5: Cleanup (Phase 5)

### Task 20: Delete obsolete widget files

**Files:**
- Delete: `lib/widgets/aurora_background.dart`
- Delete: `lib/widgets/glow_card.dart`
- Delete: `lib/widgets/shimmer_text.dart`
- Delete: `lib/widgets/pulse_dot.dart`
- Delete: `lib/widgets/forge_loader.dart`
- Delete: `lib/widgets/glass_container.dart`
- Delete: `lib/widgets/animated_button.dart`
- Delete: `lib/widgets/score_gauge.dart`
- Delete: `lib/widgets/loading_shimmer.dart` (if it depends on `shimmer` package)
- Delete: `lib/screens/onboarding/onboarding_screen.dart` (non-enhanced version, not used by router)

- [ ] **Step 1: Verify no remaining imports of deleted files**

Run: `grep -rn "aurora_background\|glow_card\|shimmer_text\|pulse_dot\|forge_loader\|glass_container\|animated_button\|score_gauge\|loading_shimmer" lib/ --include="*.dart"`

Fix any remaining imports before deleting.

- [ ] **Step 2: Delete the files**

```bash
cd /Users/benjamingonzalez/proyectosFlutter/leadforge
rm lib/widgets/aurora_background.dart
rm lib/widgets/glow_card.dart
rm lib/widgets/shimmer_text.dart
rm lib/widgets/pulse_dot.dart
rm lib/widgets/forge_loader.dart
rm lib/widgets/glass_container.dart
rm lib/widgets/animated_button.dart
rm lib/widgets/score_gauge.dart
```

- [ ] **Step 3: Verify no compilation errors**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze lib/`

---

### Task 21: Remove obsolete dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Remove dependencies**

Remove from pubspec.yaml:
- `confetti` (no longer used after removing from build/outreach screens)
- `shimmer` (no longer used)
- `google_fonts` (already removed in Phase 1, verify)

- [ ] **Step 2: Verify cupertino_icons is present**

Ensure `cupertino_icons: ^1.0.2` (or similar) is in pubspec.yaml dependencies.

- [ ] **Step 3: Run flutter pub get**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter pub get`

- [ ] **Step 4: Remove unused pipeline_screen.dart if exists**

If `lib/screens/pipeline/pipeline_screen.dart` exists and is not referenced, delete it.

Run: `grep -rn "pipeline_screen.dart" lib/ --include="*.dart"` (check it's not imported anywhere except routes pointing to enhanced version).

- [ ] **Step 5: Final full analysis**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter analyze`

Ensure 0 errors, 0 warnings.

- [ ] **Step 6: Commit Phase 5**

```bash
git add -A
git commit -m "feat: Phase 5 — cleanup obsolete widgets and dependencies"
```

---

### Task 22: Final verification

- [ ] **Step 1: Run flutter build ios (or flutter build for available target)**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter build ios --no-codesign`

Verify build succeeds.

- [ ] **Step 2: Verify Light and Dark mode**

Launch app on simulator, toggle between Light and Dark mode in Settings. Verify all screens adapt correctly.

- [ ] **Step 3: Smoke test navigation**

Test: Login → Dashboard → tap each tab → tap a business card → detail screen → back → settings → sign out.

- [ ] **Step 4: Final commit**

```bash
git commit --allow-empty -m "chore: Cupertino migration complete — all phases verified"
```
