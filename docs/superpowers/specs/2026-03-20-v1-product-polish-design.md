# v1.0 Product Polish — Design Spec

**Date:** 2026-03-20
**Status:** Approved
**Scope:** 5 independent features that address first-time user experience, context gaps, paywall clarity, profile editing, and outreach tracking.

---

## Feature 1: Dashboard First-Use Guide

### Trigger
`businesses.isEmpty` — derived from existing `businessesProvider`, no new state needed.

### Behavior
- When 0 leads: replace stats + hero stat + digest + chart + recent section with `GettingStartedGuide` widget
- When 1+ leads: show normal dashboard (stats, digest, chart, recent)
- Transition is automatic — no dismiss, no SharedPreferences

### Layout
```
GET STARTED

  ○ Search for businesses
    Find leads in your niche → tap to scout
    [Start Scouting]

  ○ Analyze their website
    AI scores their online presence

  ○ Send your pitch
    Demo site + personalized outreach
```

- Step 1 has active CTA button navigating to `/scout`
- Steps 2-3 are informational (no CTA, they happen inside business detail)
- Each step: Cupertino icon + title (titleMedium) + subtitle (labelLarge, textSecondary)
- Entrance animation: staggered fadeIn + slideY per step

### Files
- Create: `lib/widgets/getting_started_guide.dart`
- Modify: `lib/screens/dashboard/dashboard_screen.dart` — conditional render based on `businesses.isEmpty`

---

## Feature 2: Audit Score Context

### Trigger
Business has been audited (`business.isAudited == true`)

### Data Source
`business.auditBreakdown` — already exists as `Map<String, dynamic>?` with keys like `seo`, `mobile`, `design`, `performance`, `content`. Each key maps to a score (0-100) or object with `score` and `details`.

### Layout (below InlineScore, above CTAs)
```
WHAT THIS MEANS

  ✓ Has website                      (from web_presence != none)
  ✓ Listed on Google                 (from rating != null)
  ✗ Poor mobile experience           (from breakdown.mobile < 50)
  ✗ Missing SEO basics               (from breakdown.seo < 50)

  💡 Low scores mean this business needs help —
     this is a strong lead for your services.
```

### Tip logic
| Score | Tip |
|-------|-----|
| < 40 | "This business has a weak online presence — they're likely to need your services. Strong lead." |
| 40-69 | "Room for improvement. A demo site could show them what's possible." |
| >= 70 | "Decent online presence. Focus your pitch on specific gaps." |

### Checklist derivation
| Check | Condition | Label |
|-------|-----------|-------|
| ✓/✗ | `business.website != null` | "Has website" |
| ✓/✗ | `business.rating != null` | "Listed on Google" |
| ✓/✗ | `breakdown['mobile'] >= 50` | "Mobile-friendly" or "Poor mobile experience" |
| ✓/✗ | `breakdown['seo'] >= 50` | "Good SEO" or "Missing SEO basics" |
| ✓/✗ | `breakdown['design'] >= 50` | "Modern design" or "Outdated design" |

If `auditBreakdown` is null or missing keys, skip those checks. Always show website + Google listing checks.

### Files
- Create: `lib/widgets/audit_context.dart`
- Modify: `lib/screens/audit/business_detail_screen.dart` — add widget below InlineScore

---

## Feature 3: Paywall with Visible Pricing

### Current
`paywall_dialog.dart` shows title + message + "Maybe Later" / "Upgrade" buttons. No price.

### New behavior
- Read price from `offeringsProvider` (RevenueCat)
- Show feature list + real price + purchase button
- Fallback: if offerings fail to load, show "Upgrade to Pro" without price (current behavior)
- "Restore Purchases" link at bottom

### Layout
```
Upgrade to Pro

  ✓ Unlimited searches
  ✓ Unlimited audits & demo sites
  ✓ AI outreach — all 4 channels
  ✓ English + Spanish

  ┌─────────────────────────┐
  │    $9.99 / month        │
  └─────────────────────────┘

  [Restore Purchases]
  [Maybe Later]
```

### Purchase flow
1. User taps price button → `subscriptionProvider.notifier.purchase(package)`
2. On success: dismiss dialog, show IosToast "Welcome to Pro!"
3. On failure: show error toast
4. On "Restore": call `subscriptionProvider.notifier.restore()`

### Files
- Modify: `lib/widgets/paywall_dialog.dart` — complete rewrite with offerings + purchase
- Needs access to `ref` — convert from function to ConsumerWidget or pass ref

---

## Feature 4: Editable Profile in Settings

### Trigger
User taps the profile card or a new "Edit" button on the profile card

### Layout (CupertinoModalPopup bottom sheet)
```
Edit Profile
─────────────
Display Name    [________________]
Business Name   [________________]

         [Save Changes]
```

### Behavior
- Pre-fill with current values from `profileNotifierProvider`
- Validate: name >= 2 chars, business name >= 2 chars
- Save: `SupabaseService.client.from('profiles').update({display_name, business_name}).eq('id', userId)`
- After save: `ref.read(profileNotifierProvider.notifier).reload()`
- Toast: "Profile updated"
- Dismiss sheet

### Files
- Modify: `lib/screens/settings/settings_screen.dart` — add edit tap + show bottom sheet
- Modify: `lib/providers/profile_provider.dart` — add `updateProfile(name, businessName)` method

---

## Feature 5: Outreach History in Business Detail

### Data Source
`OutreachService.fetchMessages(businessId)` — already exists, returns `List<Message>` ordered by created_at desc.

### New Provider
```dart
final messagesForBusinessProvider =
    FutureProvider.autoDispose.family<List<Message>, String>((ref, businessId) async {
  return await OutreachService.fetchMessages(businessId);
});
```

### Layout (in Business Detail, below outreach CTA/status card)
```
OUTREACH HISTORY

  ✉ Email · Professional · 2 days ago
    "Dear Restaurant, we noticed your website..."
    [Copy]

  💬 WhatsApp · Casual · 5 days ago
    "Hey! Quick question about..."
    [Copy]
```

Only shows if messages exist. Each item: channel icon (CupertinoIcons) + channel name + tone + time ago + content preview (2 lines, ellipsis) + copy button.

### Files
- Create: `lib/providers/messages_provider.dart`
- Create: `lib/widgets/outreach_history.dart`
- Modify: `lib/screens/audit/business_detail_screen.dart` — add OutreachHistory below outreach section

---

## Implementation Priority

All 5 are independent and can be done in parallel. Suggested order by impact:
1. Dashboard First-Use Guide (biggest retention impact)
2. Paywall with Pricing (biggest conversion impact)
3. Audit Score Context (biggest "aha moment" impact)
4. Outreach History (biggest power-user value)
5. Editable Profile (smallest but expected)
