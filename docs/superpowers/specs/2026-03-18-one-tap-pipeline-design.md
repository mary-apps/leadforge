# One-Tap Pipeline — Flow Optimization Design

**Date:** 2026-03-18
**Status:** Approved
**Target user:** Freelancer / small agency — wants speed and maximum automation

## Problem

The current flow requires 7+ navigations to move a lead from Found to Contacted. A freelancer managing 20+ leads/week will abandon the tool. Each step (Scout → Detail → Audit → Demo screen → generate → back → Outreach screen → generate) is a manual navigation that adds friction.

## Philosophy

**"One tap to advance, review before sending."**
Automate everything possible in background. Give pause points only before external actions (sharing a demo, sending outreach).

---

## Change 1: Auto-Audit on Scout Select

### What changes
When the user taps a search result in Scout, the audit runs automatically in background. The Scout Edge Function already persists businesses via upsert (scout/index.ts line 100-105), so businesses have IDs before the user taps. On tap, the audit fires for the already-saved business and the user navigates to Business Detail where the audit result appears in real-time.

### Behavior
- User taps Scout result → business already persisted in DB by search endpoint
- `AuditService.auditBusiness(business.id)` fires in background (no await)
- Navigation to Business Detail happens immediately (no blocking)
- Business Detail watches a new `auditStateProvider(businessId)` for real-time updates
- Shows audit skeleton/shimmer while `auditStateProvider` is loading
- When audit completes: provider invalidates `businessProvider(businessId)`, score/diagnosis/breakdown animate in
- Status updates to `audited` automatically (handled by audit Edge Function)
- If audit fails: show subtle error with manual "Retry Audit" button
- Remove the artificial `Future.delayed(2 seconds)` in `_runAudit` (business_detail_screen.dart line 41)

### Auto-audit preference
- Store in **SharedPreferences** (local device preference, not Supabase — avoids migration)
- Key: `auto_audit_enabled`, default: `true`
- Settings screen gets toggle: "Auto-analyze businesses"
- When off: Business Detail shows "Analyze Business" button (current behavior)
- Read via a simple `SharedPreferences`-backed Riverpod provider

### Provider architecture
```
auditStateProvider = StateProvider.family<AsyncValue<void>, String>
```
- Keyed by businessId
- Set to `AsyncLoading` when audit starts
- Set to `AsyncData(null)` when audit completes
- Set to `AsyncError(e)` on failure
- On completion: invalidate `businessProvider(businessId)` and `businessesProvider`

### Provider invalidation chain (on audit completion)
1. `businessProvider(businessId)` — Detail screen refreshes with new audit data
2. `businessesProvider` — Pipeline and Dashboard see updated status
3. `pipelineProvider` — Pipeline re-groups by status
4. `profileNotifierProvider` — `auditsThisMonth` increments (done server-side, needs refetch)

### Limit handling
- Auto-audit respects free tier limit (3/month)
- Check `profile.auditsThisMonth < 3` before firing
- When limit reached: skip auto-audit silently, show manual button with paywall in Detail

### Error handling
- If business creation fails in Scout: show error toast, stay on Scout
- If audit fails after navigation: show "Retry Audit" button in Detail, business stays as `found`

### Files affected
- `lib/screens/scout/scout_screen.dart` — fire audit on tap (before navigation)
- `lib/screens/audit/business_detail_screen.dart` — watch `auditStateProvider`, remove manual button when auto-audit on, remove artificial delay
- `lib/screens/settings/settings_screen.dart` — add auto-audit toggle
- `lib/providers/businesses_provider.dart` — add `auditStateProvider.family`, invalidation logic
- New: `lib/providers/auto_audit_provider.dart` — SharedPreferences-backed bool provider

---

## Change 2: Stacked Quick Actions in Business Detail

### What changes
After audit completes, Business Detail shows two stacked CTAs in linear order. When demo/outreach already exist, inline status cards replace the CTAs.

### Data fetching
New providers to fetch associated records:
- `demoForBusinessProvider(businessId)` — calls `BuildService.fetchDemo(businessId)`, returns `AsyncValue<Demo?>`
- `outreachForBusinessProvider(businessId)` — calls a new `OutreachService.fetchOutreach(businessId)`, returns `AsyncValue<Message?>`

Both are auto-disposed family providers. Business Detail watches them to decide CTA vs status card.

### Layout (post-audit section)
```
┌─────────────────────────────────┐
│ [Score: 42]  Needs improvement  │
│ Mobile-friendly, missing SEO... │
├─────────────────────────────────┤
│                                 │
│  CTA 1: "Generate Demo" (primary AppButton)
│  OR if demo exists:
│  Status card: demo URL + [Preview] [Share] [Regenerate]
│                                 │
│  CTA 2: "Compose Outreach" (secondary AppButton)
│  hint if no demo: "Generate demo first for best results"
│  OR if outreach exists:
│  Status card: channel + [Copy] [Regenerate]
│                                 │
└─────────────────────────────────┘
```

- Uses Cupertino icons, NOT emojis (consistent with editorial minimalism)
- "Generate Demo" navigates to `/business/{id}/build-demo`
- "Compose Outreach" navigates to `/business/{id}/outreach`
- Demo status card "Preview" opens the WebView preview (already implemented)
- Demo "Share" calls `Share.share(url)`
- Outreach "Copy" copies message content to clipboard
- Outreach "Regenerate" navigates to outreach screen

### Files affected
- `lib/screens/audit/business_detail_screen.dart` — restructure post-audit section
- New: `lib/providers/demo_provider.dart` — `demoForBusinessProvider`
- New: `lib/providers/outreach_provider.dart` — `outreachForBusinessProvider`
- `lib/services/outreach_service.dart` — add `fetchOutreach(businessId)` method (query `messages` table)

---

## Change 3: Dashboard Daily Digest

### What changes
Add an actionable daily digest section between stats and weekly chart. Tells the user what to do next.

### Layout
```
TO DO TODAY                     (section header, labelSmall)

  search icon   3 leads need audit
                Tap to review →

  globe icon    2 demos ready to share
                Tap to send outreach →

  clock icon    1 follow-up overdue
                Contacted 5 days ago →

OR: "All caught up! Search for new leads →"
```

Uses Cupertino icons (CupertinoIcons.search, .globe, .clock), NOT emojis.

### Digest rules
| Condition | Message | Tap action |
|-----------|---------|------------|
| status=`found`, not audited | "X leads need audit" | Navigate to `/pipeline` with query param `?filter=found` |
| status=`audited`, no demo | "X demos ready to create" | Navigate to `/business/{firstId}/build-demo` (oldest first by `createdAt`) |
| status=`demo_created`, no outreach sent | "X demos ready to share" | Navigate to `/business/{firstId}/outreach` (oldest first) |
| status=`contacted`, `updatedAt` (or `createdAt` if null) > 72 hours ago | "X follow-ups overdue" | Navigate to `/business/{firstId}` (oldest first) |
| No actionable items | "All caught up!" | Navigate to `/scout` |

### Navigation for pipeline filter
Pass filter as query parameter on the route: `context.go('/pipeline?filter=found')`. Pipeline screen reads the query param and sets `_filterStatus` on init.

### Data source
Dashboard already watches `businessesProvider`. The digest widget receives the business list and computes digest items — no new data fetching needed. Digest computation happens once in the build method (list is small, no performance concern).

### Files affected
- `lib/screens/dashboard/dashboard_screen.dart` — add digest section
- New widget: `lib/widgets/daily_digest.dart` — receives `List<Business>`, computes and renders digest
- `lib/config/routes.dart` — pipeline route accepts optional `filter` query param
- `lib/screens/pipeline/pipeline_screen_enhanced.dart` — read `filter` query param on init

---

## Change 4: (Merged into Change 1)

Change 4 was a duplicate of Change 1 describing the same Scout → Detail flow optimization. The behaviors and files are identical. All details are covered in Change 1.

---

## Change 5: Pipeline — Needs Action Section

### What changes
Pipeline screen gets a collapsible "Needs Action" section at the top showing leads that are stagnant and need attention.

### Stagnation rules
| Status | Stagnant after | Suggested action | Reference timestamp |
|--------|---------------|-----------------|---------------------|
| `found` | 24 hours | "Audit this lead" | `createdAt` |
| `audited` | 48 hours | "Create demo" | `auditedAt` (fallback: `updatedAt`, then `createdAt`) |
| `demo_created` | 48 hours | "Send outreach" | `updatedAt` (fallback: `createdAt`) |
| `contacted` | 72 hours | "Follow up" | `updatedAt` (fallback: `createdAt`) |

When `updatedAt` is null, use `createdAt` as fallback (never null in the schema).

### Layout
```
NEEDS ACTION (2)                    ▼
├── "Guangzhou" — Audit this lead     →
└── "Bocari GDL" — Send outreach      →
───────────────────────────────────
FOUND (3)                           ▼
...
```

### Behavior
- Section only shows when stagnant leads exist (hidden otherwise)
- Expanded by default
- Items are ALSO shown in their normal status sections (not removed, just highlighted here)
- Tapping navigates to `/business/{id}`
- Stagnation computed as a derived list from the pipeline data — calculate once, pass to widget

### Stagnation computation
Compute in `_PipelineScreenEnhancedState.build()` from the already-loaded pipeline data. No new provider needed — pipeline data is already grouped by status.

```dart
List<(Business, String)> _computeNeedsAction(Map<BusinessStatus, List<Business>> pipeline) {
  final now = DateTime.now();
  final result = <(Business, String)>[];
  for (final b in pipeline[BusinessStatus.found] ?? []) {
    if (now.difference(b.createdAt ?? now).inHours >= 24) {
      result.add((b, 'Audit this lead'));
    }
  }
  // ... same for audited (48h), demoCreated (48h), contacted (72h)
  return result;
}
```

### Files affected
- `lib/screens/pipeline/pipeline_screen_enhanced.dart` — add needs-action section at top

---

## Implementation Priority

1. **Auto-Audit on Scout** (Change 1) — biggest friction reduction, eliminates 2 manual steps
2. **Stacked Quick Actions** (Change 2) — makes Business Detail the command center
3. **Daily Digest** (Change 3) — makes Dashboard actionable instead of decorative
4. **Pipeline Needs Action** (Change 5) — proactive guidance

## Out of Scope

- Batch operations (audit/demo/outreach multiple leads at once) — future iteration
- AI-suggested follow-up messages — future iteration
- Notification/push for stagnant leads — future iteration
- Inline demo/outreach generation without navigation — keep separate screens for now, they have enough complexity to warrant their own space
