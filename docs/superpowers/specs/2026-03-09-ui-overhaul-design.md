# LeadForge UI Overhaul — Neo-Brutal Selectivo + Sunset Gold

**Goal:** Transform the app's visual identity from generic dark theme to a distinctive neo-brutalist aesthetic with warm Sunset Gold palette, applied selectively to action elements while keeping content areas clean.

**Style:** Neo-Brutalism Selective — action elements (CTAs, score cards, contact buttons) get bold borders (2px) + offset shadows (3px), while informational content stays clean with subtle borders. Uppercase + weight 800 on labels/headers.

**Palette:** Primary #FF9F43 (Sunset Gold), Secondary #5DADE2 (Sky Blue), Success #00D68F, Danger #FF6B6B, Warning #FDCB6E. Background #0A0A0F, Surface #141420.

---

## 1. Design System Foundation

### Colors
- **Primary:** #FF9F43 (replaces #6C5CE7)
- **Secondary:** #5DADE2 (replaces implicit secondary)
- **Success:** #00D68F (keep)
- **Danger:** #FF6B6B (keep)
- **Warning:** #FDCB6E (keep)
- **Background:** #0A0A0F (keep)
- **Surface:** #141420 (keep)
- **Text Primary:** #FFFFFF (keep)
- **Text Secondary:** rgba(255,255,255,0.5)
- **Text Tertiary:** rgba(255,255,255,0.35)
- **Border:** rgba(255,255,255,0.06)

### Typography
- Keep SF Pro family
- Headers: weight 800, uppercase where appropriate
- Body: weight 400
- Labels: weight 700, uppercase, letter-spacing 0.5-1px, font-size 11px
- Numbers/scores: weight 900

### Brutal Design Tokens
- `brutalBorder`: 2px solid [color]
- `brutalShadow`: Offset(3, 3) with color at 40% opacity
- `brutalRadius`: 12px (cards), 10px (buttons), 16px (nav)
- `brutalPressFactor`: 0.95 scale + shadow reduces to Offset(1, 1)

### Where Brutal vs Clean
- **Brutal:** CTA buttons, score cards, stat cards with key metrics, contact action buttons, FAB, template selection cards
- **Clean:** Info cards (AI diagnosis, breakdown lists), navigation items (except FAB), text content areas, form fields, list items

---

## 2. Navigation — FAB + Bottom Nav

### Structure
- 5 destinations: Home, Pipeline, [FAB Scout], Messages, Settings
- FAB: 56x56, border-radius 16px, #FF9F43, brutal border + shadow
- Bottom bar: #141420, border-radius 20px, floats above safe area
- Active tab: icon + label colored #FF9F43
- Inactive: rgba(255,255,255,0.35)
- Tab transitions: fade + horizontal slide (300ms)

### Messages Tab (new)
- Shows list of sent/draft outreach messages
- Badge count for unsent drafts

---

## 3. Dashboard Redesign

### Layout (top to bottom)
1. **Greeting header:** "Good morning" + user name + notification bell (brutal style)
2. **Stat cards row:** 3 cards (Leads, Audits, Revenue). First two brutal-styled, third clean. Each shows count + trend arrow + percentage.
3. **Quick actions row:** 3 shortcut buttons (Scout brutal-primary, Pipeline clean, Outreach clean)
4. **Weekly chart:** Keep fl_chart but restyle axis labels with new typography. Add touch tooltips.
5. **Recent leads list:** Business cards with icon, name, score preview, arrow indicator. Tappable → business detail.

### Animations
- Stat numbers: animated counter on load (staggered 100ms)
- Cards: fade-up entrance (staggered)
- Trend arrows: slide-in after number animation completes

---

## 4. Business Detail Redesign

### Layout (top to bottom)
1. **Header:** Business icon (category emoji in tinted container) + name + address
2. **Contact actions row:** Call (blue brutal), Web (orange brutal), Map (green brutal) — each with 2px border + 2px shadow offset
3. **Score card (brutal, centered):** Large score number (56px, weight 900), label "DIGITAL SCORE", status text color-coded, segmented progress bar (5 segments)
4. **Breakdown card (clean):** List of factors with score out of 10, color-coded values
5. **AI Diagnosis card (clean):** Analysis text
6. **CTA row (brutal):** "BUILD DEMO" (orange) + "OUTREACH" (green), both uppercase

### Score Gauge Redesign
- Replace circular gauge with large centered number + segmented bar
- 5 segments representing score ranges (0-20, 20-40, 40-60, 60-80, 80-100)
- Filled segments colored by range: red (<40), yellow (40-60), green (>60)
- Animated fill: segments light up sequentially with haptic

### Analyzing Animation
- Keep step-by-step but restyle with brutal cards
- Each step gets its own mini brutal card that fills with color on complete

---

## 5. Scout/Search Screen

### Changes
- Search bar: clean style (no brutal) but with #FF9F43 focus border
- Niche chips: brutal style on selected (border + shadow), clean on unselected
- Business result cards: clean cards with subtle hover/press glow
- Add Hero animation: card transitions to business detail header
- Empty state: custom illustration-style with icon composition + CTA

---

## 6. Pipeline Screen

### Changes
- Section headers: uppercase labels with count badge (brutal pill)
- Business cards in pipeline: add colored left border indicating stage
- Swipe actions: visual feedback — card tilts slightly in swipe direction
- Filter chips: brutal when active, clean when inactive
- Empty stage: themed message with CTA to scout

---

## 7. Login Screen

### Changes
- Logo area: add subtle animated gradient behind logo (#FF9F43 → #5DADE2, slow rotation)
- "Sign In" / "Sign Up" toggle: brutal pill selector
- Submit button: brutal style (orange, uppercase, shadow)
- Apple Sign In: keep native styling
- Error messages: keep shake animation, add red brutal border flash

---

## 8. Settings Screen

### Changes
- Usage meters: brutal border on the progress bar container
- Pro badge: brutal gold card if subscribed
- Section headers: uppercase labels
- List items: clean with subtle dividers
- Subscription CTA: brutal button if free tier

---

## 9. Onboarding

### Changes
- Keep current flow (it's already 9/10)
- Update colors: feature icons get #FF9F43 tint
- "Get Started" button: brutal style
- Page dots: keep but color update to #FF9F43

---

## 10. New Components

### BrutalCard
- Reusable card with configurable border color, shadow offset, border radius
- Props: color, shadowOffset, child, onTap, isPressed
- Press animation: scale 0.95 + shadow reduces

### BrutalButton
- Replaces AnimatedButton for CTAs
- Props: label, color, onPressed, isLoading
- Uppercase text, weight 800, letter-spacing 0.5px
- Press: scale 0.95 + shadow Offset(1,1)
- Loading: pulsing opacity animation

### SkeletonLoader
- Content-shaped shimmer (not generic rectangles)
- Variants: DashboardSkeleton, BusinessDetailSkeleton, PipelineSkeleton, SearchSkeleton

### EmptyState
- Icon composition (2-3 layered icons with opacity/scale variation)
- Title + subtitle + optional CTA button
- Fade-up entrance animation
- Variants: noResults, noLeads, firstTime, noMessages

### FABNavBar
- Custom bottom navigation with central FAB notch
- Badge support on any tab (especially Messages)
- Animated tab transitions

---

## 11. Page Transitions

- **Default:** SlideTransition + FadeTransition (300ms, easeOut)
- **Business card → Detail:** Hero animation on business icon/name
- **Tab switches:** FadeTransition (200ms)
- **Modal sheets:** SlideTransition from bottom (standard)

---

## 12. Out of Scope

- Light mode / theme toggle
- Tablet/desktop responsive layouts
- Sound effects
- Accessibility audit (separate effort)
- Custom illustrations (using icon compositions instead)
