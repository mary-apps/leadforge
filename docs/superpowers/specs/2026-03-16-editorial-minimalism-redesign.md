# LeadForge — Editorial Minimalism Redesign

## Problem

The Cupertino migration (Phase 1-5) successfully removed Material Design and adopted iOS-native widgets, but the result is visually generic — it looks like iOS Settings. Every screen uses `CupertinoListSection.insetGrouped`, `systemGroupedBackground`, system colors, and SF Pro. The app has zero brand identity. Any app could look like this.

The user wanted Apple's *philosophy* — restraint, clarity, breathing room — not Apple's widget library copied verbatim.

## Direction

**Crisp & Clean** — white/off-white canvas, editorial typography, near-black accent, borderless surfaces, content-first. Inspired by Apple.com, Stripe, Things 3 — but with its own identity through DM Sans headings, typographic hierarchy, and restrained color use.

**Core principle**: typography and whitespace do the heavy lifting. No visual chrome unless it carries meaning.

---

## Design Tokens

### Colors

**Light mode (primary):**

| Token | Value | Usage |
|-------|-------|-------|
| `background` | `#FAFAF9` | Page/scaffold background |
| `surface` | `#FFFFFF` | Elevated surfaces (if needed) |
| `divider` | `#F0F0EE` | 1px dividers between items |
| `border` | `#E5E5E3` | Thin borders (search fields, chips) |
| `textPrimary` | `#18181B` | Headings, body text, primary UI |
| `textSecondary` | `#999999` | Subtitles, metadata, labels |
| `textTertiary` | `#BBBBBB` | Section labels, placeholders |
| `accent` | `#18181B` | Buttons, active states, links |
| `scoreGood` | `#166534` | Score >= 70 (changed from >= 60) |
| `scoreMid` | `#92400E` | Score 40-69 (changed from 30-59) |
| `scoreBad` | `#991B1B` | Score < 40 (changed from < 30) |
| `scoreGoodBg` | `#F0FAF0` | Score badge background (good) |
| `scoreMidBg` | `#FEF6ED` | Score badge background (mid) |
| `scoreBadBg` | `#FEF2F2` | Score badge background (bad) |
| `chipActive` | `#18181B` | Active chip background |
| `chipActiveFg` | `#FAFAF9` | Active chip text |
| `chipInactive` | `#F5F5F3` | Inactive chip background |
| `chartActive` | `#18181B` | Active bar in charts |
| `chartInactive` | `#E5E5E3` | Inactive bars |

**Dark mode:**

| Token | Light | Dark |
|-------|-------|------|
| `background` | `#FAFAF9` | `#0A0A0A` |
| `surface` | `#FFFFFF` | `#141414` |
| `divider` | `#F0F0EE` | `#1A1A1A` |
| `border` | `#E5E5E3` | `#2A2A2A` |
| `textPrimary` | `#18181B` | `#FAFAFA` |
| `textSecondary` | `#999999` | `#666666` |
| `textTertiary` | `#BBBBBB` | `#444444` |
| `accent` | `#18181B` | `#FAFAFA` |
| `scoreGood` | `#166534` | `#4ADE80` |
| `scoreMid` | `#92400E` | `#FB923C` |
| `scoreBad` | `#991B1B` | `#F87171` |
| `scoreGoodBg` | `#F0FAF0` | `#0F2A1A` |
| `scoreMidBg` | `#FEF6ED` | `#2A1A0A` |
| `scoreBadBg` | `#FEF2F2` | `#2A0F0F` |
| `chipActive` | `#18181B` | `#FAFAFA` |
| `chipActiveFg` | `#FAFAF9` | `#0A0A0A` |
| `chipInactive` | `#F5F5F3` | `#1A1A1A` |
| `chartActive` | `#18181B` | `#FAFAFA` |
| `chartInactive` | `#E5E5E3` | `#1A1A1A` |

**Implementation note**: Use `CupertinoDynamicColor.withBrightness()` for each token so they auto-switch with system appearance. Store all tokens in `AppColors` class in `lib/config/theme.dart`.

### Typography

**Font stack**:
- Headings: **DM Sans** (Google Fonts, variable weight 400-800)
- Body/UI: System font (SF Pro on iOS, Roboto on Android)
- Monospace: Menlo (unchanged)

**Scale**:

| Token | Font | Size | Weight | Letter-spacing | Usage |
|-------|------|------|--------|----------------|-------|
| `displayLarge` | DM Sans | 32px | 800 | -0.8px | Screen titles ("LeadForge", "Scout") |
| `headlineLarge` | DM Sans | 24px | 700 | -0.3px | Detail page titles, section headings |
| `titleMedium` | DM Sans | 15px | 600 | 0 | List item names, card titles |
| `bodyLarge` | System | 15px | 400 | 0 | Body text, descriptions |
| `bodyMedium` | System | 14px | 400 | 0 | Secondary body, AI diagnosis |
| `labelLarge` | System | 13px | 500 | 0 | Metadata, scores, subtitles |
| `labelSmall` | System | 11px | 500 | 1.5px | Section labels (uppercase) |
| `numberLarge` | DM Sans | 28px | 800 | -0.5px | Dashboard stat numbers |
| `scoreLarge` | DM Sans | 44px | 800 | -1.5px | Inline audit score |
| `button` | System | 15px | 600 | 0 | Button labels |
| `chip` | System | 12px | 400 | 0 | Chip/tag text |

**Implementation**: Add `google_fonts` package back, but ONLY for DM Sans. Use `GoogleFonts.dmSans()` for heading styles. System font for everything else via default `TextStyle`.

### Spacing

| Token | Value | Usage |
|-------|-------|-------|
| `pageHorizontal` | 24px | Screen-level horizontal padding |
| `sectionGap` | 28px | Between sections |
| `itemGap` | 14px | Between list items (padding above/below divider) |
| `contentGap` | 4px | Between title and subtitle |
| `chipGap` | 8px | Between chips |
| `statGap` | 16px | Padding inside stat cells |

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radiusS` | 4px | Tags, small badges |
| `radiusM` | 10px | Search fields, chips |
| `radiusL` | 12px | Buttons, cards (rare) |
| `radiusXL` | 20px | Chip pills |

**Removed**: `radiusXXL` (28px) — no longer needed. Update any references to use `radiusXL` (20px) instead.

---

## Component Redesign

### BrutalButton → AppButton

Rename and redesign:

- **Primary**: `background: accent (#18181B)`, `text: #FAFAF9`, `borderRadius: 12px`, `padding: 14px vertical`, full width
- **Secondary**: `background: transparent`, `border: 1px solid border`, `text: accent`, same dimensions
- **Ghost**: no background, no border, text only (for inline actions)
- **Loading state**: replace text with small circular indicator, same size
- Keep haptic feedback on press
- Remove: success/danger variants (use semantic color on text only where needed)

### BrutalCard → Remove

No card containers in the new design. Content sits directly on the background separated by dividers. Delete `BrutalCard` widget entirely.

Where grouped content is needed (detail page sections), use padding + dividers.

### BusinessCard → LeadItem

Redesign as a simple divider-separated row:

```
[Lead name]                    [Score]
[Location] · [tag] [tag]
─────────────────────────────────────
```

- Name: `titleMedium` (DM Sans, 15px, 600)
- Location: `labelLarge` (system, 13px, 500, secondary color)
- Score: `labelLarge` (system, 13px, 700, semantic color)
- Tags: `chip` style (12px, `chipInactive` bg, radiusS)
- Divider: 1px `divider` color, full width
- Tap: subtle background highlight (not ink splash)

### AnimatedScoreGauge → Remove

Replace with inline score display on the business detail screen:

```
┌─────────────────────────────────┐
│ 82    Good web presence         │ (no actual border — just dividers above/below)
│       Mobile-friendly, has SEO  │
└─────────────────────────────────┘
```

- Score number: `scoreLarge` (DM Sans, 44px, 800)
- Status text: `labelLarge` (13px, 500, semantic color)
- Description: `labelLarge` (13px, secondary color)
- Separated from content by top/bottom dividers
- Keep animated count-up on the number (subtle, 600ms ease-out)

### StatCardAnimated → StatCell

Simplify to plain typographic cells in a row:

```
24          8          $2.4k
Scouted     Demos      Revenue
```

- Number: `numberLarge` (DM Sans, 28px, 800)
- Label: `labelSmall` (system, 11px, secondary)
- Cells separated by vertical 1px dividers
- Bottom divider under the row
- Keep animated count-up (600ms, easeOutCubic)
- Revenue number can use `scoreGood` color

### NicheChips

Update styling:
- Active: `chipActive` bg (#18181B), `chipActiveFg` text
- Inactive: `chipInactive` bg (#F5F5F3), `textSecondary` text
- Radius: `radiusXL` (20px, pill shape)
- Font: `chip` (12px)
- Animated transition: 200ms background color change (keep existing)

### AppBottomNav

Restyle:
- Background: `background` with blur (keep current backdrop filter)
- Border top: 1px `divider`
- Active icon/text: `accent` (#18181B / #FAFAFA in dark)
- Inactive icon/text: `textTertiary`
- Keep existing CupertinoTabBar structure but override colors

### EmptyState

Simplify:
- Icon: 32px, `textTertiary` color (reduce from 48px)
- Title: `titleMedium` (DM Sans)
- Subtitle: `bodyMedium`, `textSecondary`
- Action button: ghost style (text only)
- More vertical space above/below

### IosToast

Update:
- Background: `textPrimary` (#18181B / #FAFAFA in dark)
- Text: inverse of background
- Border radius: `radiusL` (12px)
- No icon — text only
- Slide down animation (keep)

### WeeklyActivityGraph

Simplify:
- Bar chart only (no line variant)
- Active bar: `chartActive`, border-radius 3px
- Inactive bars: `chartInactive`
- Day labels: `labelSmall`, `textTertiary`
- No grid lines, no axes, no decorations
- Keep animated entrance

### Search Field

- Background: `#F0F0EE` light / `#141414` dark (slightly darker than page bg for contrast)
- No border
- Radius: `radiusM` (10px)
- Placeholder: `textTertiary`
- Text: `textPrimary`
- Padding: 12px 16px

### SkeletonLoaders → Update

Keep but restyle to match new layouts:
- Replace card-shaped skeletons with simple horizontal line placeholders
- Use `divider` color for shimmer base, `border` color for shimmer highlight
- Match new spacing tokens (24px page padding, 14px item gap)
- Remove shimmer package dependency — use `flutter_animate` shimmer effect instead

### ErrorState → Update

- Replace `BrutalButton.secondary()` usage with `AppButton` ghost variant
- Update text styles to new typography tokens
- Keep retry callback pattern

### SearchSuggestions → Update

- Remove box shadows and bordered container styling
- Use borderless divider-separated rows matching LeadItem pattern
- Replace `CupertinoColors.systemBlue` with `accent` token
- Suggestion text: `bodyLarge`, `textPrimary`

### ShareBusinessSheet → Keep

- Keep `CupertinoActionSheet` as-is — it follows iOS native patterns and does not conflict with the new design

---

## Screen-by-Screen Changes

### Dashboard

**Current**: `CupertinoSliverNavigationBar` with "LeadForge" large title, hero stat widget, 3-column stat pills, weekly graph, recent leads in BusinessCards.

**New**:
- Remove `CupertinoSliverNavigationBar` — use custom layout instead
- Large title "LeadForge" in `displayLarge` (DM Sans, 32px, 800)
- Subtitle "Good [time], [Name]" in `bodyLarge`, `textSecondary`
- Stat row: 3 StatCells in a horizontal row with vertical dividers
- Section label "THIS WEEK" in `labelSmall`, uppercase, `textTertiary`
- Minimal bar chart (no chrome)
- Section label "RECENT LEADS"
- Lead items with dividers (LeadItem widget)
- Pull-to-refresh: keep `CupertinoSliverRefreshControl`

### Scout

**Current**: `CupertinoSearchTextField`, niche chips, business cards.

**New**:
- Title "Scout" in `displayLarge`
- Subtitle "Find businesses to help" in `bodyLarge`, `textSecondary`
- Custom search field (see Search Field above)
- Niche chips (updated styling)
- Results count: "12 results" in `labelSmall`, `textTertiary`
- Results: LeadItem rows with trailing `→` chevron
- Empty state: simplified

### Pipeline

**Current**: Kanban-style columns with collapsible stages.

**New**:
- Title "Pipeline" in `displayLarge`
- Stage sections: each stage is a collapsible section with `labelSmall` header
- LeadItem rows within each section
- Swipe-to-move: keep existing gesture, update visual feedback
- Collapse/expand: simple chevron rotation
- No card containers — dividers only

### Business Detail

**Current**: `CupertinoNavigationBar`, `CupertinoListSection.insetGrouped`, animated score gauge, BrutalCard for audit.

**New**:
- Back button: "← Pipeline" text link style in `labelLarge`
- Business name: `headlineLarge` (DM Sans, 24px)
- Address + rating: `bodyMedium`, `textSecondary`
- Inline score block (see Component Redesign above)
- Section "BREAKDOWN": simple key-value rows with dividers
- Section "AI DIAGNOSIS": body text paragraph
- Buttons: primary "Create Demo" + secondary "Compose Outreach"

### Settings

**Current**: `CupertinoListSection` groups with profile card, subscription badge, settings rows.

**New**:
- Title "Settings" in `displayLarge`
- Profile section: name in `headlineLarge`, initials circle (near-black bg, white text)
- Subscription status: inline text, not a badge
- Settings rows: simple label + value/chevron, dividers
- Sign out: ghost button at bottom, `scoreBad` color

### Login

**Current**: CupertinoTextField inputs, Apple Sign In button.

**New**:
- "LeadForge" in `displayLarge`, centered
- Email/password fields: custom search field style
- Sign In button: primary (near-black, full width)
- Apple Sign In: secondary style
- Toggle text: ghost style
- Generous vertical spacing between elements

### Messages/Activity

**Current**: Timeline grouped by time period with business interactions.

**New**:
- Title "Activity" in `displayLarge`
- Time groups: `labelSmall` headers ("TODAY", "THIS WEEK")
- Activity items: LeadItem-style rows with action description
- Dividers between items

### Onboarding

**Current**: Slide-based with profile setup.

**New**:
- Each slide: `displayLarge` centered headline (DM Sans, 32px, 800)
- Supporting text: `bodyLarge`, `textSecondary`, centered, max 2 lines
- No illustrations — text-only slides (the typography IS the visual)
- Advance button: primary `AppButton` at bottom ("Continue" / "Get Started")
- Progress: dot indicators using 6px circles, `accent` for active, `divider` for inactive
- Profile setup fields: same search field styling as Login
- Remove confetti celebration on completion — replace with simple slide to Dashboard
- Generous vertical spacing: content vertically centered in available space

### Build Demo

**Current**: `CupertinoFormSection` with validation.

**New**:
- Back nav: "← [Business Name]" text link
- Title: `headlineLarge` ("Create Demo")
- Template selection: horizontal chip row (same NicheChips pattern), one active at a time
- Notes field: search field styling, multi-line
- Labels above fields: `labelSmall`, uppercase, `textTertiary`
- Submit: primary `AppButton` ("Generate Demo")
- Loading state: button shows loading indicator
- Success: navigate back to business detail (no confetti)
- Validation: inline error text in `scoreBad` color below fields

### Outreach

**Current**: `CupertinoFormSection` with validation.

**New**:
- Back nav: "← [Business Name]" text link
- Title: `headlineLarge` ("Compose Outreach")
- Channel selection: horizontal chip row (Email, WhatsApp, Instagram, Phone, Other)
- Tone selection: horizontal chip row (Professional, Friendly, Direct)
- Generated message: `bodyMedium` text in a padded area with `divider` top/bottom borders
- Copy button: primary `AppButton` ("Copy Message")
- Mark as sent: ghost `AppButton`
- Success: no confetti — show `IosToast` confirmation
- Validation: inline error text in `scoreBad` color

---

## Animation Philosophy

Keep animations but simplify:

- **Entrance**: `fadeIn` + `slideY` (keep, reduce distance to 8px from current ~20px)
- **Stagger**: 50ms delay between items (reduce from 100-200ms for snappier feel)
- **Count-up**: 600ms easeOutCubic for numbers (reduce from 800ms)
- **Transitions**: keep Cupertino push/pop (slide from right)
- **Button press**: keep spring physics with haptics
- **Remove**: confetti, shimmer effects, glassmorphism

---

## What Gets Deleted

**Widgets:**
- `AnimatedScoreGauge` widget (replaced by `InlineScore`)
- `BrutalCard` widget (no card containers needed)
- `BrutalButton` widget (replaced by `AppButton`)
- `StatCardAnimated` widget (replaced by `StatCell`)
- `BusinessCard` widget (replaced by `LeadItem`)
- Legacy brutal design tokens from theme (gradients: `scoreGradient()`, `primaryGradient`)

**Confetti removal** — remove confetti trigger code from:
- `onboarding_screen_enhanced.dart` (success celebration)
- `build_demo_screen.dart` (demo generation success)
- `outreach_screen.dart` (outreach generation success)
- `animated_score_gauge.dart` (score reveal — file itself is deleted)

**Note**: Files like `aurora_background.dart`, `glow_card.dart`, `shimmer_text.dart`, `pulse_dot.dart`, `forge_loader.dart`, `glass_container.dart` were already deleted in Phase 5. Do not attempt to delete them again.

**Packages to remove from pubspec.yaml:**
- `confetti` (no longer used)
- `shimmer` (replaced by `flutter_animate` shimmer effect in skeleton loaders)

## What Gets Added

**Packages:**
- `google_fonts` (for DM Sans only)

**Widgets:**
- `AppButton` widget (replaces BrutalButton)
- `LeadItem` widget (replaces BusinessCard)
- `StatCell` widget (replaces StatCardAnimated)
- `InlineScore` widget (replaces AnimatedScoreGauge)

**Theme updates:**
- Updated `AppColors` with new token values and `CupertinoDynamicColor` mappings
- Updated `AppTypography` with DM Sans heading styles

**Score threshold change:**
- Current: good >= 60, mid >= 30, bad < 30
- New: good >= 70, mid >= 40, bad < 40
- Update `AppColors.scoreColor()` and all references

## What Stays

- `CupertinoPageScaffold` for all screens
- `CupertinoTabBar` for bottom nav (restyled)
- `GoRouter` navigation
- `CupertinoSliverRefreshControl` for pull-to-refresh
- `flutter_animate` for entrance animations
- Haptic feedback throughout
- `fl_chart` for weekly activity graph (restyled)
- All providers, services, models — backend untouched
- `CupertinoAlertDialog` / `CupertinoActionSheet` for dialogs
- `SkeletonLoaders` (restyled)
- `EmptyState` (restyled)
- `ErrorState` (updated to use `AppButton`)
- `SearchSuggestions` (restyled)
- `ShareBusinessSheet` (unchanged)
- `NicheChips` (restyled)
- `IosToast` (restyled)
- `WeeklyActivityGraph` (restyled)

---

## Verification

1. **Visual check**: Run the app in iOS Simulator, compare against mockups at `.superpowers/brainstorm/82329-1773701077/full-design.html`
2. **Dark mode**: Toggle system appearance in Simulator Settings, verify all tokens switch correctly
3. **Typography**: Verify DM Sans loads for headings, system font renders for body text
4. **Score display**: Navigate to a business detail, verify inline score renders with semantic colors
5. **Animations**: Verify entrance animations are snappier (shorter delays, smaller distances)
6. **No regressions**: All screens load, navigation works, pull-to-refresh works, data displays correctly
7. **Haptics**: Confirm button taps still trigger haptic feedback
