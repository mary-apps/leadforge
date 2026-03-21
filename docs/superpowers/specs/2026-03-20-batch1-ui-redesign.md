# Batch 1: UI/UX Redesign — Login + Onboarding + Business Detail

**Date:** 2026-03-20
**Scope:** 3 screens — Login, Onboarding, Business Detail
**Approach:** UX redesign (structure/flow changes), not just visual polish
**Constraints:** Preserve existing design system (AppColors, AppTypography, AppConstants), dark mode support, all existing functionality

---

## 1. Login Screen Redesign

**File:** `lib/screens/auth/login_screen.dart`

### Problem
Generic auth template with no brand identity. Just "LeadForge" text + subtitle + form fields. No visual hook, no value proposition, no trust signals. First impression of the app fails to sell.

### Design: Editorial Dark Hero + Light Form Split

The screen splits into two visual zones:

#### Dark Hero Zone (top)
- Background: `AppColors.accent` (which is textPrimary — near-black in light mode, near-white in dark mode)
- Text color: inverted (white on dark in light mode, dark on light in dark mode)
- **Brand wordmark**: "LEADFORGE" in `AppTypography.labelSmall` style with 1.5px letter spacing, left-aligned
- **Editorial headline**: "Turn weak\nwebsites into\nyour clients." — last line in muted color (`textTertiary` equivalent on dark bg). Use `AppTypography.displayLarge` at 30px, weight 900, line height 1.1
- **Accent bar**: 40px wide, 3px tall, white at 0.3 opacity, below headline
- **Stats row**: 3 stats in a horizontal row, separated from headline by a subtle top border (white at 0.08 opacity)
  - "2.4K" / "Leads found"
  - "890" / "Demos built"
  - "94%" / "Response rate"
  - Numbers: 18px, weight 900. Labels: 10px, muted color
  - Note: These are illustrative/aspirational stats, not live data
- **Entrance animation**: fadeIn 400ms + slideY from -0.03, staggered (wordmark → headline → bar → stats)

#### Light Form Zone (bottom)
- Background: `AppColors.background` (standard app background)
- **Pill toggle**: Sign In / Sign Up — identical to current implementation
- **Email field**: identical to current
- **Password field**: identical to current (with eye toggle)
- **Forgot password link**: identical, right-aligned
- **Error message**: identical styling
- **Submit button**: `AppButton` — identical
- **Divider + Apple Sign In**: identical
- **Entrance animation**: form zone fades in 200ms after hero completes

#### Dark Mode Behavior
The hero zone inverts: dark background in light mode, light background in dark mode. The visual split/contrast is maintained in both modes. Use `CupertinoDynamicColor` for the hero background — light mode: `Color(0xFF18181B)` (dark), dark mode: `Color(0xFFFAFAFA)` (light). Hero text colors invert correspondingly: light mode: white, dark mode: near-black.

#### What Changes
- Added: Hero zone with headline, stats, brand wordmark
- Added: Dark/light split layout
- Preserved: All form logic, validation, Apple Sign In, error handling, loading states, forgot password flow
- Removed: Centered "LeadForge" title + "AI-powered lead generation" subtitle (replaced by hero)

#### Layout
```
SafeArea
└── SingleChildScrollView
    └── Column
        ├── _HeroSection (dark bg, headline, stats)
        └── Padding (horizontal: pageHorizontal)
            └── Column (form: toggle, fields, buttons)
```

---

## 2. Onboarding Screen Redesign

**File:** `lib/screens/onboarding/onboarding_screen_enhanced.dart`

### Problem
4 feature pages all look identical: icon in rounded square + title + description. No visual differentiation between pages. Dot indicators are tiny. Profile setup page feels disconnected from the tour.

### Design: Mini Mockup Previews + Progress Bar

#### Progress Indicator (replaces dot indicators)
- Top of each page (inside SafeArea): "STEP X OF 4" label + horizontal progress bar
- Label: `AppTypography.labelSmall` style, left-aligned
- Progress bar: height 3px, `AppColors.divider` background, `AppColors.accent` fill
- Fill width: 25% / 50% / 75% / 100% for pages 1-4
- Page 5 (profile setup): "FINAL STEP" label, 100% fill
- Animated fill with `TweenAnimationBuilder`, 300ms ease-out

#### Feature Pages (pages 1-4) — Mini Mockup Previews

Each page replaces the generic icon with a **mini mockup preview** that visually represents the feature. Layout changes from centered to top-aligned:

```
Column (top-aligned, not centered)
├── Progress bar
├── SizedBox(24)
├── Mini mockup preview (in a card)
├── SizedBox(20)
├── Title (left-aligned or centered)
└── Description
```

**Page 1 — Scout:**
- Card with `AppColors.chipInactive` background, `radiusL` corners
- Inside: search bar mockup (rounded rect with placeholder "restaurants in Miami...")
- Below search bar: 2 result card mockups side by side with fake business names + ratings
- Label: "Search preview" with search icon, `labelSmall` style

**Page 2 — Analyze:**
- Card showing audit score visualization
- Large "32" score number in `scoreBad` color + "/100" suffix
- Below: 2-3 short diagnosis lines (e.g., "No website found", "Few reviews", "No social media")
- Label: "Audit preview" with chart icon

**Page 3 — Build Demo:**
- Card showing mini browser chrome (address bar with URL)
- Below address bar: simplified website mockup (header + hero + sections as colored blocks)
- Label: "Demo preview" with globe icon

**Page 4 — Outreach:**
- Card showing message bubble with channel icons
- Fake message preview text (2-3 lines of outreach copy)
- Below: row of channel pills (Email, WhatsApp, Instagram)
- Label: "Message preview" with paperplane icon

**Title and description** remain the same text as current. Move below the preview card. Keep entrance animations (staggered fadeIn + slideY).

#### Profile Setup Page (page 5)
- Progress bar shows "FINAL STEP" with 100% fill
- Title: "Set Up Your Profile" — unchanged
- Subtitle: "This helps us personalize your experience" — unchanged
- Fields: identical (name + business name with validation checkmarks)
- Entrance animations: identical

#### Navigation (bottom area)
- "Next" button: `AppButton` — identical
- "Skip" link: identical, with confirmation dialog
- Page 5: "Get Started" button — identical
- PageView with BouncingScrollPhysics — identical

#### What Changes
- Added: Progress bar with step label replaces dot indicators
- Added: Mini mockup preview cards per feature page
- Changed: Layout from vertically centered to top-aligned (preview + text below)
- Removed: Generic icon in rounded square (96x96 container with 48px icon)
- Preserved: All text content, profile setup fields, validation, skip flow, navigation, animations

#### Layout per feature page
```
Padding(32)
└── Column (mainAxisAlignment: start, not center)
    ├── _ProgressBar(currentStep, totalSteps)
    ├── SizedBox(24)
    ├── _MockupPreview(pageIndex)  // different content per page
    ├── SizedBox(20)
    ├── Text(title)  // displayLarge
    ├── SizedBox(8)
    └── Text(description)  // bodyLarge, secondary color
```

---

## 3. Business Detail Screen Redesign

**File:** `lib/screens/audit/business_detail_screen.dart`

### Problem
Most important screen in the app but reads as a long vertical scroll of disconnected sections. Contact links (Call/Website/Maps) are flat text that's easy to miss. The flow Audit → Demo → Outreach has no visual journey. Audit result, AI Analysis, Demo status, and Outreach status use different UI patterns. No clear "what to do next" guidance.

### Design: Contact Cards + Vertical Workflow Stepper

#### Header Section (unchanged)
- `CupertinoNavigationBar` with business name + share icon — identical
- Business name as `headlineLarge` — identical
- Address text — identical
- Rating stars — identical
- Entrance animations — identical

#### Contact Actions — Icon Cards (replaces flat text links)

Replace the `Row` of `_ContactLink` widgets with a row of 4 tappable icon cards:

```
Row (4 equal cards, spacing: 8)
├── _ContactCard(icon: phone, label: "Call")
├── _ContactCard(icon: globe, label: "Website")
├── _ContactCard(icon: map, label: "Maps")
└── _ContactCard(icon: share, label: "Share")
```

Each `_ContactCard`:
- Container: `AppColors.chipInactive` background, `radiusM` corners
- Height: ~64px (icon 22px + label 10px + padding)
- Icon: Cupertino icon, `AppColors.accent` color, 22px
- Label: `AppTypography.chip` style, centered below icon
- Tap: same actions as current (launchUrl for phone/website/maps, ShareBusinessSheet for share)
- Only rendered if data exists (phone, website, address). Share always shown.
- Cards that don't exist collapse — remaining cards expand to fill

#### Workflow Stepper — The Core Change

Replace the current linear scroll of buttons/status cards with a **vertical stepper** that shows the Audit → Demo → Outreach pipeline.

Section label: "WORKFLOW" in `AppTypography.labelSmall`

The stepper has 3 steps. Each step has:
- **Left column** (24px wide): Circle indicator + connecting line to next step
- **Right column** (expanded): Step content card

##### Step States

**Completed step:**
- Circle: 22px, `AppColors.scoreGood` background, white checkmark icon (14px)
- Connector line: 2px wide, `AppColors.scoreGood` color, stretches to next step
- Card: `scoreGoodBg` background, `scoreGood` border at 0.3 opacity, `radiusM` corners

**Current/next step (the next action to take):**
- Circle: 22px, `AppColors.accent` background, white step number (weight 700)
- No connector line below (last visible step) or gray connector
- Card: `AppColors.accent` background, white text, `radiusM` corners, acts as CTA

**Future step (locked/not yet available):**
- Circle: 22px, `AppColors.chipInactive` background, `textTertiary` step number
- Gray connector line above
- Card: `AppColors.surface` background, `border` color border, muted text

##### Step 1: Audit

**Not started (no audit):**
- State: "current" — accent CTA card
- Card content: "Analyze Business" title + "AI will score their online presence" subtitle + arrow
- Tap: triggers `_runAudit(business)` — same as current button

**Loading (auditing in progress):**
- State: "current" with loading
- Card content: `_AnalyzingAnimation` widget (same as current) embedded inside the step card

**Completed:**
- State: "completed" — green card
- Card content:
  - "Audit Complete" title in `titleMedium`, bold
  - Score number: `scoreLarge` typography (44px), colored by score value (scoreGood/scoreMid/scoreBad)
  - "/100" suffix in `bodyMedium`, muted
  - Diagnosis text: 1-2 lines, `bodyMedium`, secondary color, `maxLines: 3` with ellipsis
  - Expandable: tap card to show full AI analysis text (the content currently in the "AI ANALYSIS" bordered section)

##### Step 2: Demo

**Not available (audit not done):**
- State: "future" — gray locked card
- Card content: "Generate Demo Site" title + "Complete audit first" subtitle, muted

**Available (audit done, no demo):**
- State: "current" — accent CTA card
- Card content: "Generate Demo Site" title + "Create a professional demo →" subtitle
- Tap: `context.push('/business/${business.id}/build-demo')`

**Completed:**
- State: "completed" — green card
- Card content:
  - "Demo Ready" title
  - URL text in `mono` style, secondary color
  - Action row: Preview (primary small button) | Share (secondary) | Redo (ghost)
  - Tap actions: same as current `_DemoStatusCard`

##### Step 3: Outreach

**Not available (audit not done):**
- State: "future" — gray locked card
- Card content: "Compose Outreach" + "Complete audit first", muted

**Available (audit done, no outreach):**
- State: "current" — accent CTA card
- Card content: "Compose Outreach" title + "Send a personalized pitch →" subtitle
- Tap: `context.push('/business/${business.id}/outreach')`
- If no demo exists, show hint: "Generate demo first for best results" in `chip` style below

**Completed:**
- State: "completed" — green card
- Card content:
  - "Outreach Sent" title + channel name badge
  - Message preview: 2 lines, secondary color
  - Action row: Copy (primary) | Regenerate (ghost)
  - Tap actions: same as current `_OutreachStatusCard`

#### Below the Stepper
- `AuditContext` widget — unchanged, shown when audit is complete
- `OutreachHistory` widget — unchanged, shown when messages exist
- Bottom padding: 120px — unchanged

#### What Changes
- Added: Contact icon cards (replacing flat text links)
- Added: Vertical workflow stepper with 3 steps and visual states
- Removed: Separate `AppButton` for "Analyze Business" (now inside stepper)
- Removed: Standalone "AI ANALYSIS" bordered section (now inside audit step card, expandable)
- Removed: Separate `_DemoStatusCard` widget (now inside stepper step 2)
- Removed: Separate `_OutreachStatusCard` widget (now inside stepper step 3)
- Removed: Separate `AppButton` for "Generate Demo Site" and "Compose Outreach" (now CTA cards in stepper)
- Preserved: All functionality, all tap actions, all navigation, analyzing animation, auto-audit support, share functionality, outreach history, audit context

#### Layout
```
CustomScrollView
└── SliverPadding
    └── SliverList
        ├── Business name (headlineLarge)
        ├── Address
        ├── Rating stars
        ├── SizedBox(sectionGap)
        ├── _ContactCardsRow  // NEW
        ├── SizedBox(sectionGap)
        ├── "WORKFLOW" label
        ├── SizedBox(itemGap)
        ├── _WorkflowStepper(business, audit, demo, outreach)  // NEW
        ├── SizedBox(sectionGap)
        ├── AuditContext (if audited)
        ├── SizedBox(sectionGap)
        ├── OutreachHistory (if messages exist)
        └── SizedBox(120)
```

---

## New Widgets to Create

### `_HeroSection` (login_screen.dart, private)
Dark/light hero with headline and stats. ~80 lines.

### `_ProgressBar` (onboarding_screen_enhanced.dart, private)
Step label + animated progress bar. ~30 lines.

### `_MockupPreview` (onboarding_screen_enhanced.dart, private)
Feature preview card with different content per page index. ~120 lines (4 variants).

### `_ContactCard` (business_detail_screen.dart, private)
Tappable icon + label card. ~40 lines.

### `_WorkflowStepper` (business_detail_screen.dart, private)
Vertical 3-step stepper with state management. ~200 lines.

### `_WorkflowStepCard` (business_detail_screen.dart, private)
Individual step card with completed/current/future states. ~80 lines.

---

## Design Principles

- **Same design system**: AppColors, AppTypography, AppConstants, CupertinoDynamicColor throughout
- **Dark mode**: All new elements properly invert. Hero section swaps light↔dark.
- **Animations**: Staggered fadeIn + slideY using flutter_animate, consistent timing with existing screens
- **Haptics**: Maintained on all tappable elements via `Haptics.light/medium/heavy`
- **No new dependencies**: Everything built with Flutter + existing packages
- **Files modified**: 3 existing files only (login_screen.dart, onboarding_screen_enhanced.dart, business_detail_screen.dart). No new files created.

---

## Out of Scope (Batch 2 & 3)

These screens will be addressed in future batches:
- **Batch 2**: Outreach, Build Demo, Pipeline (visual polish)
- **Batch 3**: Activity, Settings, Getting Started Guide (activity redesign + polish)
