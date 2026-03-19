# Editorial Minimalism Redesign — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the stock Cupertino UI with an editorial minimalism design system — DM Sans headings, near-black accent, borderless surfaces, inline scores.

**Architecture:** Update the design token foundation first (theme.dart), then build new replacement widgets, update existing widgets to match, migrate all 10 screens, and finally delete old components and remove packages. Package removal (shimmer, confetti) is deferred until all files that import them have been updated, ensuring the app compiles at every step.

**Tech Stack:** Flutter/Dart, google_fonts (DM Sans), CupertinoDynamicColor, flutter_animate

**Spec:** `docs/superpowers/specs/2026-03-16-editorial-minimalism-redesign.md`

---

## Chunk 1: Foundation

### Task 1: Update pubspec.yaml dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add google_fonts**

In `pubspec.yaml`, add `google_fonts` to dependencies:

```yaml
# ADD under dependencies:
  google_fonts: ^6.1.0
```

**Do NOT remove `shimmer` or `confetti` yet** — files still import them. They will be removed in Task 18 after all references are updated.

- [ ] **Step 2: Run flutter pub get**

Run: `flutter pub get`
Expected: Resolves successfully, no compile errors.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add google_fonts package for DM Sans headings"
```

---

### Task 2: Rewrite AppColors with new design tokens

**Files:**
- Modify: `lib/config/theme.dart`

- [ ] **Step 1: Replace AppColors class**

Replace the entire `AppColors` class with new editorial minimalism tokens. Every color uses `CupertinoDynamicColor.withBrightness()` for automatic light/dark switching:

```dart
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Backgrounds
  static const background = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFAFAF9),
    darkColor: Color(0xFF0A0A0A),
  );
  static const surface = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF),
    darkColor: Color(0xFF141414),
  );

  // Borders & Dividers
  static const divider = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF0F0EE),
    darkColor: Color(0xFF1A1A1A),
  );
  static const border = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFE5E5E3),
    darkColor: Color(0xFF2A2A2A),
  );

  // Text
  static const textPrimary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF18181B),
    darkColor: Color(0xFFFAFAFA),
  );
  static const textSecondary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF999999),
    darkColor: Color(0xFF666666),
  );
  static const textTertiary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFBBBBBB),
    darkColor: Color(0xFF444444),
  );

  // Accent (near-black / near-white)
  static const accent = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF18181B),
    darkColor: Color(0xFFFAFAFA),
  );

  // Semantic score colors
  static const scoreGood = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF166534),
    darkColor: Color(0xFF4ADE80),
  );
  static const scoreMid = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF92400E),
    darkColor: Color(0xFFFB923C),
  );
  static const scoreBad = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF991B1B),
    darkColor: Color(0xFFF87171),
  );

  // Score badge backgrounds
  static const scoreGoodBg = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF0FAF0),
    darkColor: Color(0xFF0F2A1A),
  );
  static const scoreMidBg = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFEF6ED),
    darkColor: Color(0xFF2A1A0A),
  );
  static const scoreBadBg = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFEF2F2),
    darkColor: Color(0xFF2A0F0F),
  );

  // Chips
  static const chipActive = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF18181B),
    darkColor: Color(0xFFFAFAFA),
  );
  static const chipActiveFg = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFAFAF9),
    darkColor: Color(0xFF0A0A0A),
  );
  static const chipInactive = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF5F5F3),
    darkColor: Color(0xFF1A1A1A),
  );

  // Chart
  static const chartActive = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF18181B),
    darkColor: Color(0xFFFAFAFA),
  );
  static const chartInactive = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFE5E5E3),
    darkColor: Color(0xFF1A1A1A),
  );

  // Search field bg
  static const searchField = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF0F0EE),
    darkColor: Color(0xFF141414),
  );

  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 10.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 20.0;

  // Score color helper — NEW thresholds
  static CupertinoDynamicColor scoreColor(int score) {
    if (score >= 70) return scoreGood;
    if (score >= 40) return scoreMid;
    return scoreBad;
  }

  static CupertinoDynamicColor scoreBgColor(int score) {
    if (score >= 70) return scoreGoodBg;
    if (score >= 40) return scoreMidBg;
    return scoreBadBg;
  }
}
```

- [ ] **Step 2: Replace AppTypography class**

Replace the entire `AppTypography` class. DM Sans for headings, system font for body:

```dart
class AppTypography {
  static TextStyle displayLarge(BuildContext context) => GoogleFonts.dmSans(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle headlineLarge(BuildContext context) => GoogleFonts.dmSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle titleMedium(BuildContext context) => GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle labelLarge(BuildContext context) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: CupertinoDynamicColor.resolve(AppColors.textSecondary, context),
  );

  static TextStyle labelSmall(BuildContext context) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    color: CupertinoDynamicColor.resolve(AppColors.textTertiary, context),
  );

  static TextStyle numberLarge(BuildContext context) => GoogleFonts.dmSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle scoreLarge(BuildContext context) => GoogleFonts.dmSans(
    fontSize: 44,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle button(BuildContext context) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );

  static TextStyle chip(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: CupertinoDynamicColor.resolve(AppColors.textSecondary, context),
  );

  static TextStyle mono(BuildContext context) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFamily: 'Menlo',
    color: CupertinoDynamicColor.resolve(AppColors.textPrimary, context),
  );
}
```

- [ ] **Step 3: Update AppTheme (keep getter name `theme`) and add new AppConstants class**

Keep the getter named `theme` (not `themeData()`) so `lib/app.dart` continues to work without changes:

```dart
class AppTheme {
  static CupertinoThemeData get theme => const CupertinoThemeData(
    primaryColor: AppColors.accent,
    scaffoldBackgroundColor: AppColors.background,
    barBackgroundColor: AppColors.background,
  );
}
```

Add a **new** `AppConstants` class (this does not exist yet — it's additive). All subsequent tasks reference these constants:

```dart
class AppConstants {
  static const Duration quickAnimation = Duration(milliseconds: 150);
  static const Duration standardAnimation = Duration(milliseconds: 200);
  static const Duration countUpAnimation = Duration(milliseconds: 600);
  static const double entranceSlideDistance = 8.0;
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const double pageHorizontal = 24.0;
  static const double sectionGap = 28.0;
  static const double itemGap = 14.0;
  static const double contentGap = 4.0;
  static const double chipGap = 8.0;
  static const double statGap = 16.0;
}
```

- [ ] **Step 4: Verify theme.dart compiles**

Run: `dart analyze lib/config/theme.dart`
Expected: No errors (warnings about unused items are fine at this stage).

- [ ] **Step 5: Commit**

```bash
git add lib/config/theme.dart
git commit -m "feat: rewrite design tokens for editorial minimalism"
```

---

## Chunk 2: New Widgets

### Task 3: Create AppButton widget

**Files:**
- Create: `lib/widgets/app_button.dart`

- [ ] **Step 1: Write AppButton widget**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool compact;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : () {
        HapticFeedback.lightImpact();
        onPressed?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: compact ? null : double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: compact ? 10 : 14,
          horizontal: compact ? 20 : 0,
        ),
        decoration: BoxDecoration(
          color: _backgroundColor(context),
          border: variant == AppButtonVariant.secondary
              ? Border.all(color: CupertinoDynamicColor.resolve(AppColors.border, context))
              : null,
          borderRadius: BorderRadius.circular(AppColors.radiusL),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CupertinoActivityIndicator(
                    color: _textColor(context),
                  ),
                )
              : Text(
                  label,
                  style: AppTypography.button(context).copyWith(
                    color: _textColor(context),
                  ),
                ),
        ),
      ),
    );
  }

  Color _backgroundColor(BuildContext context) {
    switch (variant) {
      case AppButtonVariant.primary:
        return CupertinoDynamicColor.resolve(AppColors.accent, context);
      case AppButtonVariant.secondary:
      case AppButtonVariant.ghost:
        return const Color(0x00000000);
    }
  }

  Color _textColor(BuildContext context) {
    switch (variant) {
      case AppButtonVariant.primary:
        return CupertinoDynamicColor.resolve(AppColors.chipActiveFg, context);
      case AppButtonVariant.secondary:
      case AppButtonVariant.ghost:
        return CupertinoDynamicColor.resolve(AppColors.accent, context);
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/widgets/app_button.dart
git commit -m "feat: add AppButton widget (primary, secondary, ghost)"
```

---

### Task 4: Create LeadItem widget

**Files:**
- Create: `lib/widgets/lead_item.dart`

- [ ] **Step 1: Add `statusLabel` getter to Business model**

In `lib/models/business.dart`, add a getter to the `BusinessX` extension (or wherever extensions are defined) so LeadItem can display the status:

```dart
String get statusLabel {
  switch (status) {
    case BusinessStatus.found: return 'Found';
    case BusinessStatus.audited: return 'Audited';
    case BusinessStatus.demoCreated: return 'Demo sent';
    case BusinessStatus.contacted: return 'Contacted';
    case BusinessStatus.interested: return 'Interested';
    case BusinessStatus.closed: return 'Closed';
    case BusinessStatus.lost: return 'Lost';
  }
}
```

If this getter already exists under a different name, reuse it.

- [ ] **Step 2: Write LeadItem widget**

```dart
import 'package:flutter/cupertino.dart';
import '../config/theme.dart';
import '../models/business.dart';

class LeadItem extends StatelessWidget {
  final Business business;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool showDivider;

  const LeadItem({
    super.key,
    required this.business,
    this.onTap,
    this.showChevron = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppConstants.itemGap),
        decoration: showDivider
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoDynamicColor.resolve(AppColors.divider, context),
                    width: 1,
                  ),
                ),
              )
            : null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: AppTypography.titleMedium(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppConstants.contentGap),
                  Text(
                    business.shortAddress ?? '',
                    style: AppTypography.labelLarge(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildTag(context, business.statusLabel),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (business.auditScore != null)
              Text(
                '${business.auditScore}',
                style: AppTypography.labelLarge(context).copyWith(
                  fontWeight: FontWeight.w700,
                  color: CupertinoDynamicColor.resolve(
                    AppColors.scoreColor(business.auditScore!),
                    context,
                  ),
                ),
              ),
            if (showChevron) ...[
              const SizedBox(width: 8),
              Text(
                '→',
                style: TextStyle(
                  fontSize: 18,
                  color: CupertinoDynamicColor.resolve(AppColors.textTertiary, context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(AppColors.chipInactive, context),
        borderRadius: BorderRadius.circular(AppColors.radiusS),
      ),
      child: Text(
        label,
        style: AppTypography.chip(context).copyWith(fontSize: 10),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/lead_item.dart lib/models/business.dart
git commit -m "feat: add LeadItem widget and statusLabel getter"
```

---

### Task 5: Create StatCell widget

**Files:**
- Create: `lib/widgets/stat_cell.dart`

- [ ] **Step 1: Write StatCell and StatRow widgets**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';

class StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const StatCell({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.numberLarge(context).copyWith(
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.labelSmall(context),
        ),
      ],
    );
  }
}

class StatRow extends StatelessWidget {
  final List<StatCell> cells;

  const StatRow({super.key, required this.cells});

  @override
  Widget build(BuildContext context) {
    final dividerColor = CupertinoDynamicColor.resolve(AppColors.divider, context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: dividerColor, width: 1),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (int i = 0; i < cells.length; i++) ...[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: cells[i],
                )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: i * 50),
                      duration: AppConstants.standardAnimation,
                    )
                    .slideY(
                      begin: AppConstants.entranceSlideDistance / 100,
                      end: 0,
                      delay: Duration(milliseconds: i * 50),
                      duration: AppConstants.standardAnimation,
                    ),
              ),
              if (i < cells.length - 1)
                VerticalDivider(
                  color: dividerColor,
                  width: 1,
                  thickness: 1,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/widgets/stat_cell.dart
git commit -m "feat: add StatCell and StatRow widgets for dashboard stats"
```

---

### Task 6: Create InlineScore widget

**Files:**
- Create: `lib/widgets/inline_score.dart`

- [ ] **Step 1: Write InlineScore widget**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';

class InlineScore extends StatelessWidget {
  final int score;
  final String? statusText;
  final String? description;

  const InlineScore({
    super.key,
    required this.score,
    this.statusText,
    this.description,
  });

  String get _defaultStatusText {
    if (score >= 70) return 'Good web presence';
    if (score >= 40) return 'Needs improvement';
    return 'Poor web presence';
  }

  @override
  Widget build(BuildContext context) {
    final scoreCol = CupertinoDynamicColor.resolve(
      AppColors.scoreColor(score),
      context,
    );
    final dividerCol = CupertinoDynamicColor.resolve(AppColors.divider, context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: dividerCol, width: 1),
          bottom: BorderSide(color: dividerCol, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            '$score',
            style: AppTypography.scoreLarge(context),
          )
              .animate()
              .fadeIn(duration: AppConstants.countUpAnimation),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText ?? _defaultStatusText,
                  style: AppTypography.labelLarge(context).copyWith(
                    fontWeight: FontWeight.w500,
                    color: scoreCol,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: AppTypography.labelLarge(context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/widgets/inline_score.dart
git commit -m "feat: add InlineScore widget for editorial score display"
```

---

## Chunk 3: Update Existing Widgets

### Task 7: Update remaining widgets to new design system

**Files:**
- Modify: `lib/widgets/app_bottom_nav.dart`
- Modify: `lib/widgets/niche_chips.dart`
- Modify: `lib/widgets/empty_state.dart`
- Modify: `lib/widgets/error_state.dart`
- Modify: `lib/widgets/ios_toast.dart`
- Modify: `lib/widgets/search_suggestions.dart`
- Modify: `lib/widgets/weekly_activity_graph.dart`
- Modify: `lib/widgets/skeleton_loaders.dart`

- [ ] **Step 1: Update app_bottom_nav.dart**

Replace the current CupertinoTabBar color scheme to use new tokens:
- Active icon/text: `AppColors.accent`
- Inactive icon/text: `AppColors.textTertiary`
- Background: `AppColors.background` with blur
- Border top: `AppColors.divider`

Read the file first, then update the `CupertinoTabBar` colors and border.

- [ ] **Step 2: Update niche_chips.dart**

Update chip colors:
- Active bg: `AppColors.chipActive`, text: `AppColors.chipActiveFg`
- Inactive bg: `AppColors.chipInactive`, text: `AppColors.textSecondary`
- Border radius: `AppColors.radiusXL` (20px pill)
- Font: `AppTypography.chip(context)`
- Keep 200ms animated transition

- [ ] **Step 3: Update empty_state.dart**

- Replace `BrutalButton` import with `AppButton` import
- Replace `BrutalButton` usage with `AppButton(variant: AppButtonVariant.ghost)`
- Icon size: 32px (down from 48px)
- Icon color: `AppColors.textTertiary`
- Title: `AppTypography.titleMedium(context)`
- Subtitle: `AppTypography.bodyMedium(context)` with `AppColors.textSecondary`

- [ ] **Step 4: Update error_state.dart**

- Replace `BrutalButton.secondary()` with `AppButton(variant: AppButtonVariant.ghost)`
- Drop the `icon:` parameter (AppButton is text-only by design — no icons on buttons in this design system)
- Update text styles to new typography tokens

- [ ] **Step 5: Update ios_toast.dart**

- Background: `AppColors.textPrimary` (dark on light, light on dark)
- Text color: inverse — `AppColors.background`
- Border radius: `AppColors.radiusL` (12px)
- Remove icon — text only
- Keep slide-down animation

- [ ] **Step 6: Update search_suggestions.dart**

- Remove box shadows and bordered containers
- Use borderless divider-separated rows
- Replace `CupertinoColors.systemBlue` with `AppColors.accent`
- Text: `AppTypography.bodyLarge(context)` for suggestion text

- [ ] **Step 7: Update weekly_activity_graph.dart**

- Active bar color: `AppColors.chartActive`
- Inactive bar color: `AppColors.chartInactive`
- Bar border radius: 3px
- Day labels: `AppTypography.labelSmall(context)`, `AppColors.textTertiary`
- Remove grid lines, axes, all chrome
- Keep animated entrance

- [ ] **Step 8: Update skeleton_loaders.dart**

- Replace shimmer package usage with `flutter_animate` shimmer effect
- Replace card-shaped skeletons with simple horizontal line placeholders
- Use `AppColors.divider` for shimmer base, `AppColors.border` for highlight
- Match new spacing: 24px page padding, 14px item gap
- Update radius values to new tokens

- [ ] **Step 9: Commit**

```bash
git add lib/widgets/app_bottom_nav.dart lib/widgets/niche_chips.dart lib/widgets/empty_state.dart lib/widgets/error_state.dart lib/widgets/ios_toast.dart lib/widgets/search_suggestions.dart lib/widgets/weekly_activity_graph.dart lib/widgets/skeleton_loaders.dart
git commit -m "feat: restyle all existing widgets for editorial minimalism"
```

---

## Chunk 4: Screen Updates — Part 1 (Dashboard, Scout, Pipeline)

### Task 8: Redesign Dashboard screen

**Files:**
- Modify: `lib/screens/dashboard/dashboard_screen.dart` (819 lines)

- [ ] **Step 1: Read the current dashboard_screen.dart**

Read the entire file to understand current structure, imports, and state management.

- [ ] **Step 2: Replace layout**

Key changes:
- Remove `CupertinoSliverNavigationBar` — use custom title in `SliverToBoxAdapter`
- Title: `AppTypography.displayLarge(context)` — "LeadForge"
- Subtitle: `AppTypography.bodyLarge(context)` with `AppColors.textSecondary` — "Good [time], [Name]"
- Replace the inline stat display (currently built with `BrutalCard` wrappers) with `StatRow` containing 3 `StatCell`s
- Section labels: `AppTypography.labelSmall(context)`, uppercase
- Replace `BusinessCard` widgets with `LeadItem` widgets
- Replace `BrutalCard` containers with plain content (remove wrapping)
- Replace `BrutalButton` with `AppButton`
- Update all `AppColors` references to new tokens
- Set page padding to `AppConstants.pageHorizontal` (24px)
- Reduce entrance animation slideY to `AppConstants.entranceSlideDistance` (8px)
- Reduce stagger delay to `AppConstants.staggerDelay` (50ms)
- Keep `CupertinoSliverRefreshControl`

- [ ] **Step 3: Verify it compiles**

Run: `dart analyze lib/screens/dashboard/dashboard_screen.dart`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/screens/dashboard/dashboard_screen.dart
git commit -m "feat: redesign Dashboard with editorial minimalism layout"
```

---

### Task 9: Redesign Scout screen

**Files:**
- Modify: `lib/screens/scout/scout_screen.dart` (1217 lines)

- [ ] **Step 1: Read the current scout_screen.dart**

Read the entire file to understand structure.

- [ ] **Step 2: Replace layout**

Key changes:
- Title: `AppTypography.displayLarge(context)` — "Scout"
- Subtitle: `AppTypography.bodyLarge(context)` with `AppColors.textSecondary`
- Replace `CupertinoSearchTextField` with custom search field:
  - Background: `AppColors.searchField`
  - No border, radius: `AppColors.radiusM`
  - Placeholder: `AppColors.textTertiary`
  - Padding: 12px 16px
- Replace `BusinessCard` with `LeadItem(showChevron: true)`
- Replace `BrutalCard` containers with plain content
- Replace `BrutalButton` with `AppButton`
- Results count: `AppTypography.labelSmall(context)`, `AppColors.textTertiary`
- Update all color references to new tokens
- Reduce animation distances and delays

- [ ] **Step 3: Verify it compiles**

Run: `dart analyze lib/screens/scout/scout_screen.dart`

- [ ] **Step 4: Commit**

```bash
git add lib/screens/scout/scout_screen.dart
git commit -m "feat: redesign Scout with editorial minimalism layout"
```

---

### Task 10: Redesign Pipeline screen

**Files:**
- Modify: `lib/screens/pipeline/pipeline_screen_enhanced.dart` (658 lines)

- [ ] **Step 1: Read the current pipeline_screen_enhanced.dart**

Read the entire file.

- [ ] **Step 2: Replace layout**

Key changes:
- Title: `AppTypography.displayLarge(context)` — "Pipeline"
- Stage headers: `AppTypography.labelSmall(context)`, uppercase, `AppColors.textTertiary`
- Replace `BusinessCard` with `LeadItem`
- Refactor `_DraggableBusinessCard` (private widget in this file) to wrap `LeadItem` instead of `BusinessCard` while preserving `Dismissible` swipe-to-move functionality
- Remove card containers — dividers only
- Keep collapsible sections with simple chevron rotation
- Keep swipe-to-move gestures, update feedback colors to new tokens
- Update all `AppColors` references

- [ ] **Step 3: Verify it compiles**

Run: `dart analyze lib/screens/pipeline/pipeline_screen_enhanced.dart`

- [ ] **Step 4: Commit**

```bash
git add lib/screens/pipeline/pipeline_screen_enhanced.dart
git commit -m "feat: redesign Pipeline with editorial minimalism layout"
```

---

## Chunk 5: Screen Updates — Part 2 (All Remaining Screens)

### Task 11: Redesign Business Detail screen

**Files:**
- Modify: `lib/screens/audit/business_detail_screen.dart` (598 lines)

- [ ] **Step 1: Read and replace layout**

Key changes:
- Remove `CupertinoNavigationBar` — use custom back link: "← Pipeline" in `AppTypography.labelLarge(context)`
- Business name: `AppTypography.headlineLarge(context)`
- Address + rating: `AppTypography.bodyMedium(context)`, `AppColors.textSecondary`
- Replace `AnimatedScoreGauge` with `InlineScore` widget
- Breakdown section: simple key-value rows with dividers (`AppTypography.bodyMedium`)
- AI Diagnosis: `AppTypography.bodyMedium(context)`, `AppColors.textSecondary`
- Replace `BrutalButton` with `AppButton` (primary: "Create Demo", secondary: "Compose Outreach")
- Replace `BrutalCard` containers with plain content + dividers
- Remove `CupertinoListSection.insetGrouped` — use flat layout

- [ ] **Step 2: Commit**

```bash
git add lib/screens/audit/business_detail_screen.dart
git commit -m "feat: redesign Business Detail with inline score and editorial layout"
```

---

### Task 12: Redesign Settings screen

**Files:**
- Modify: `lib/screens/settings/settings_screen.dart` (539 lines)

- [ ] **Step 1: Read and replace layout**

Key changes:
- Title: `AppTypography.displayLarge(context)` — "Settings"
- Profile: name in `AppTypography.headlineLarge(context)`, initials circle (accent bg, inverse text)
- Subscription: inline text, not badge
- Settings rows: label + value/chevron, separated by dividers
- Sign out: `AppButton(variant: AppButtonVariant.ghost)` with `AppColors.scoreBad` color
- Replace all `BrutalCard` containers
- Remove `CupertinoListSection` usage

- [ ] **Step 2: Commit**

```bash
git add lib/screens/settings/settings_screen.dart
git commit -m "feat: redesign Settings with editorial minimalism layout"
```

---

### Task 13: Redesign Login screen

**Files:**
- Modify: `lib/screens/auth/login_screen.dart` (525 lines)

- [ ] **Step 1: Read and replace layout**

Key changes:
- "LeadForge" title: `AppTypography.displayLarge(context)`, centered
- Input fields: `AppColors.searchField` bg, no border, `AppColors.radiusM`, padding 12px 16px
- Sign In button: `AppButton` primary (near-black, full width)
- Apple Sign In: `AppButton` secondary
- Toggle text (Sign Up/Log In): `AppButton` ghost
- Generous vertical spacing between elements
- Replace any `CupertinoTextField` with custom styled fields

- [ ] **Step 2: Commit**

```bash
git add lib/screens/auth/login_screen.dart
git commit -m "feat: redesign Login with editorial minimalism layout"
```

---

### Task 14: Redesign Messages/Activity screen

**Files:**
- Modify: `lib/screens/messages/messages_screen.dart` (575 lines)

- [ ] **Step 1: Read and replace layout**

Key changes:
- Title: `AppTypography.displayLarge(context)` — "Activity"
- Time groups: `AppTypography.labelSmall(context)`, uppercase — "TODAY", "THIS WEEK"
- Activity items: LeadItem-style rows with action description
- Replace `BrutalCard` with dividers
- Dividers between items

- [ ] **Step 2: Commit**

```bash
git add lib/screens/messages/messages_screen.dart
git commit -m "feat: redesign Activity screen with editorial minimalism layout"
```

---

### Task 15: Redesign Onboarding screen

**Files:**
- Modify: `lib/screens/onboarding/onboarding_screen_enhanced.dart` (490 lines)

- [ ] **Step 1: Read and replace layout**

Key changes:
- Each slide: `AppTypography.displayLarge(context)`, centered
- Supporting text: `AppTypography.bodyLarge(context)`, `AppColors.textSecondary`, centered
- No illustrations — text-only
- Advance button: `AppButton` primary at bottom
- Progress dots: 6px circles, `AppColors.accent` active, `AppColors.divider` inactive
- Profile fields: same search field styling as Login
- **Remove confetti**: delete ConfettiController, ConfettiWidget, and related imports
- Replace celebration with simple slide to Dashboard

- [ ] **Step 2: Commit**

```bash
git add lib/screens/onboarding/onboarding_screen_enhanced.dart
git commit -m "feat: redesign Onboarding with editorial minimalism, remove confetti"
```

---

### Task 16: Redesign Build Demo screen

**Files:**
- Modify: `lib/screens/build/build_demo_screen.dart` (788 lines)

- [ ] **Step 1: Read and replace layout**

Key changes:
- Back nav: "← [Business Name]" text link
- Title: `AppTypography.headlineLarge(context)` — "Create Demo"
- Template selection: chip row (NicheChips pattern)
- Notes field: search field styling, multi-line
- Labels: `AppTypography.labelSmall(context)`, uppercase, `AppColors.textTertiary`
- Submit: `AppButton` primary — "Generate Demo"
- **Remove confetti**: delete ConfettiController, ConfettiWidget, replace with IosToast on success
- Replace `BrutalCard` / `BrutalButton`
- Replace `CupertinoFormSection` with flat layout

- [ ] **Step 2: Commit**

```bash
git add lib/screens/build/build_demo_screen.dart
git commit -m "feat: redesign Build Demo with editorial minimalism, remove confetti"
```

---

### Task 17: Redesign Outreach screen

**Files:**
- Modify: `lib/screens/outreach/outreach_screen.dart` (710 lines)

- [ ] **Step 1: Read and replace layout**

Key changes:
- Back nav: "← [Business Name]" text link
- Title: `AppTypography.headlineLarge(context)` — "Compose Outreach"
- Channel selection: chip row (Email, WhatsApp, Instagram, Phone, Other)
- Tone selection: chip row (Professional, Friendly, Direct)
- Generated message: `AppTypography.bodyMedium(context)` with divider borders
- Copy button: `AppButton` primary — "Copy Message"
- Mark as sent: `AppButton` ghost
- **Remove confetti**: replace with IosToast confirmation
- Replace `BrutalCard` / `BrutalButton`

- [ ] **Step 2: Commit**

```bash
git add lib/screens/outreach/outreach_screen.dart
git commit -m "feat: redesign Outreach with editorial minimalism, remove confetti"
```

---

## Chunk 6: Cleanup & Verification

### Task 18: Delete old widgets and remove packages

**Files:**
- Delete: `lib/widgets/brutal_button.dart`
- Delete: `lib/widgets/brutal_card.dart`
- Delete: `lib/widgets/business_card.dart`
- Delete: `lib/widgets/stat_card_animated.dart`
- Delete: `lib/widgets/animated_score_gauge.dart`
- Modify: `pubspec.yaml`

- [ ] **Step 1: Verify no remaining imports of old widgets**

Run: `grep -r "brutal_button\|brutal_card\|business_card\|stat_card_animated\|animated_score_gauge" lib/`
Expected: No matches (all references already updated in prior tasks)

- [ ] **Step 2: Verify no remaining confetti/shimmer imports**

Run: `grep -r "package:confetti\|package:shimmer" lib/`
Expected: No matches (all references removed in Tasks 7, 15, 16, 17)

- [ ] **Step 3: Verify no remaining radiusXXL references**

Run: `grep -r "radiusXXL" lib/`
Expected: No matches. If found, replace with `AppColors.radiusXL`.

- [ ] **Step 4: Verify no remaining old typography call sites**

Run: `grep -r "AppTypography\.\(displayLarge\|headlineLarge\|titleMedium\|bodyLarge\|bodyMedium\|labelLarge\|labelSmall\|numberLarge\|scoreLarge\|button\)[^(]" lib/`
Expected: No matches. The new API requires `(context)` — any match without parentheses is a stale call site using the old `static const` API. Fix any found.

- [ ] **Step 5: Delete old widget files**

```bash
rm lib/widgets/brutal_button.dart
rm lib/widgets/brutal_card.dart
rm lib/widgets/business_card.dart
rm lib/widgets/stat_card_animated.dart
rm lib/widgets/animated_score_gauge.dart
```

- [ ] **Step 6: Remove shimmer and confetti from pubspec.yaml**

In `pubspec.yaml`, remove:
```yaml
  shimmer: ^3.0.0
  confetti: ^0.7.0
```

Run: `flutter pub get`

- [ ] **Step 7: Commit**

```bash
git add -u lib/widgets/ pubspec.yaml pubspec.lock
git commit -m "chore: delete obsolete widgets, remove shimmer and confetti packages"
```

---

### Task 19: Final verification

**Note:** `ShareBusinessSheet` (`lib/widgets/share_business_sheet.dart`) uses `CupertinoActionSheet` and requires no changes — it is intentionally unchanged.

- [ ] **Step 1: Run full analysis**

Run: `dart analyze lib/`
Expected: No errors. Fix any remaining issues.

- [ ] **Step 2: Run flutter build**

Run: `flutter build ios --no-codesign`
Expected: Builds successfully

- [ ] **Step 3: Verify no remaining old widget or package references**

Run: `grep -r "BrutalButton\|BrutalCard\|StatCardAnimated\|AnimatedScoreGauge\|package:confetti\|package:shimmer\|radiusXXL" lib/`
Expected: No matches

- [ ] **Step 4: Run the app in iOS Simulator**

Run: `flutter run`
Verify:
- Dashboard renders with DM Sans headings, stat row, divider-separated leads
- Scout search field has gray bg, no border
- Pipeline shows collapsible sections with dividers
- Business detail shows inline score, not ring gauge
- Settings shows flat layout, no grouped sections
- Dark mode works (toggle in Simulator → Settings → Display)

- [ ] **Step 5: Final commit (specific files only)**

```bash
git add -u lib/ pubspec.yaml pubspec.lock
git commit -m "feat: complete editorial minimalism redesign"
```
