# LeadForge UI Redesign — Minimal Sharp + Cyan Frost

## Direction
Replace neo-brutalist design (hard borders, hard shadows, Sunset Gold) with a Minimal Sharp aesthetic using the Cyan Frost palette. The goal is a premium, interactive experience that feels unique — not a generic dark-mode app.

## Color Palette

### Primary
- `primary`: #00B4D8
- `primaryDark`: #0096B4
- `primaryLight`: #48CAE4

### Backgrounds
- `background`: #080810
- `surface`: #111118
- `surfaceLight`: #18181F

### Semantic
- `success`: #34D399
- `warning`: #FBBF24
- `danger`: #F87171

### Text
- `textPrimary`: #FFFFFF
- `textSecondary`: rgba(255,255,255,0.45)
- `textTertiary`: rgba(255,255,255,0.3)

### Borders
- `border`: rgba(255,255,255,0.06)
- `divider`: rgba(255,255,255,0.08)

## Design Principles

### 1. No Borders, No Hard Shadows
Depth through background contrast only. Cards are subtle surface containers. No visible borders except on focused inputs.

### 2. Tight Typography
- Headings: -0.5px letter-spacing, weight 700-800
- Numbers: weight 800, -1px letter-spacing, slightly larger
- Labels: weight 500, slightly translucent
- Body: weight 400, 1.5 line-height

### 3. Expressive Animations (Spring Physics)
- **List items**: Staggered fadeIn + slideUp, 50ms delay between items, spring damping 0.8
- **Numbers**: Animated count-up on load, 800ms duration
- **Buttons**: Scale 0.97 on press with spring bounce-back
- **Page transitions**: Shared axis (horizontal slide + fade, 350ms)
- **Cards**: Subtle scale on tap (1.0 → 0.98), 100ms
- **Score gauge**: Animated ring fill with easeOutCubic, 1200ms

### 4. Premium Interactive Details
- **Haptic feedback** on every interactive element
- **Pull-to-refresh** with custom spring animation
- **Swipe actions** with velocity-based physics
- **Long-press** reveals quick actions with scale animation

## Component Changes

### theme.dart
- Replace entire color palette
- Remove all brutal design tokens (brutalBorderWidth, brutalShadowOffset, etc.)
- Update border radius: 12px standard, 10px buttons, 14px cards
- Update input decoration: no border by default, 1px primary on focus
- Update card theme: no elevation, surface color, no border

### BrutalButton → AppButton
- Remove hard borders and hard shadows
- Press: scale 0.97 with spring (not 0.95 with linear)
- Disabled: 0.4 opacity
- Loading: inline spinner, no text change
- Variants: primary (filled cyan), secondary (surface bg), danger (red tint bg), ghost (transparent)
- Border radius: 10px
- No forced uppercase

### BrutalCard → AppCard
- Remove borders and shadows entirely
- Background: surface color
- Border radius: 14px
- Tap: scale 0.98 with spring, 100ms
- Padding: 16px default

### AppBottomNav
- Remove floating bar with border/shadow
- Flush bottom nav with surface background and top divider (1px border color)
- FAB: 48px, primary color, rounded 14px, no border, subtle scale on press
- Active item: primary color icon + label, inactive: textTertiary
- No labels on inactive items (icon only), label appears on active with fadeIn
- Height: auto (SafeArea handles bottom)

### LoginScreen
- Centered vertically with more breathing room
- Logo: Clean icon + text, no container
- Toggle: Pill with primary fill on active, sharp transition
- Inputs: No visible border, surface background, 1px primary on focus with animated transition
- CTA: Full-width primary button
- Error: Subtle red tint background, no border, fadeIn
- Apple button: Ghost style with icon

### DashboardScreen
- Greeting: Smaller, lighter "Good morning" + bold name
- Avatar: Rounded square (12px radius) with primary tint background + initials
- Stats: 2-column, surface cards, animated numbers, small trend indicator
- Quick actions: 3-column grid, primary bg for main CTA, surface for others
- Recent leads: Clean list with avatar, name, score badge, status

### ScoutScreen
- Search bar: Surface bg, no border, icon changes to primary on focus
- Chips: Primary fill on active (dark text), surface on inactive
- Results: Clean business cards with left avatar, right score
- Empty state: Centered icon + text, no container

### BusinessDetailScreen
- Header: Subtle gradient overlay (primary 6% → transparent)
- Contact buttons: Surface bg, no border, centered icon + label
- Score: Conic gradient ring (clean, no segments)
- AI Analysis: Surface card with body text
- CTAs: Primary + success tint buttons side by side

### PipelineScreen
- Stages: Collapsible surface cards
- Stage header: Name + colored count badge (tinted bg)
- Items: Minimal with dot indicator + name + score
- Swipe: Velocity-based with color background

### SettingsScreen
- Profile: Avatar with initials + name/business
- Subscription: Surface card with inline upgrade button
- Usage: Thin 4px progress bars, clean layout
- Sign out: Danger tint button at bottom

### AnimatedScoreGauge
- Replace segmented bar with conic gradient ring
- Clean number display in center
- Status label below
- Animated fill with easeOutCubic

## Animation Specifications

| Element | Type | Duration | Curve |
|---------|------|----------|-------|
| Button press | Scale 0.97 | 100ms | spring(damping: 0.6) |
| Card tap | Scale 0.98 | 100ms | spring(damping: 0.7) |
| List stagger | fadeIn + slideY(0.05) | 300ms | easeOut, 50ms delay |
| Number count | value animation | 800ms | easeOutCubic |
| Score ring | conic fill | 1200ms | easeOutCubic |
| Page transition | slideX + fade | 350ms | easeOut |
| Input focus | border color | 200ms | easeInOut |
| Nav label | fadeIn | 150ms | easeIn |

## Files to Modify
1. `lib/config/theme.dart` — Complete palette + token replacement
2. `lib/widgets/brutal_button.dart` → Rewrite as clean AppButton
3. `lib/widgets/brutal_card.dart` → Rewrite as clean AppCard
4. `lib/widgets/app_bottom_nav.dart` — Flush nav, animated labels
5. `lib/widgets/animated_score_gauge.dart` — Conic ring style
6. `lib/widgets/stat_card_animated.dart` — Clean stat card
7. `lib/widgets/business_card.dart` — Minimal card style
8. `lib/widgets/niche_chips.dart` — Updated chip styling
9. `lib/widgets/empty_state.dart` — Simplified
10. `lib/screens/auth/login_screen.dart` — Premium login
11. `lib/screens/dashboard/dashboard_screen.dart` — Clean dashboard
12. `lib/screens/scout/scout_screen.dart` — Minimal search
13. `lib/screens/audit/business_detail_screen.dart` — Detail redesign
14. `lib/screens/pipeline/pipeline_screen_enhanced.dart` — Clean pipeline
15. `lib/screens/settings/settings_screen.dart` — Settings refresh
16. `lib/screens/messages/messages_screen.dart` — Activity feed
17. `lib/screens/onboarding/onboarding_screen_enhanced.dart` — Onboarding
18. `lib/screens/build/build_demo_screen.dart` — Build demo
19. `lib/screens/outreach/outreach_screen.dart` — Outreach
