# One-Tap Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce the Scout-to-Contacted flow from 7+ navigations to 3 taps by automating audit on scout select, stacking quick actions in business detail, adding a daily digest to dashboard, and surfacing stagnant leads in pipeline.

**Architecture:** Riverpod StateNotifier + FutureProvider.family pattern. New providers for audit state, demo lookup, and outreach lookup. SharedPreferences for local auto-audit toggle. GoRouter query params for pipeline filtering.

**Tech Stack:** Flutter 3+, Riverpod, GoRouter, Supabase, SharedPreferences, flutter_animate

**Spec:** `docs/superpowers/specs/2026-03-18-one-tap-pipeline-design.md`

---

## Task 0: Prerequisites

- [ ] **Step 1: Add shared_preferences dependency**

```bash
flutter pub add shared_preferences
```

- [ ] **Step 2: Verify**

Run: `flutter pub get`
Expected: No errors

---

## File Structure

### New files
| File | Responsibility |
|------|---------------|
| `lib/providers/auto_audit_provider.dart` | SharedPreferences-backed bool provider for auto-audit toggle |
| `lib/providers/audit_state_provider.dart` | `StateProvider.family<AsyncValue<void>, String>` tracking per-business audit progress |
| `lib/providers/demo_provider.dart` | `FutureProvider.family<Demo?, String>` fetching demo for a business |
| `lib/providers/outreach_provider.dart` | `FutureProvider.family<Message?, String>` fetching latest outreach for a business |
| `lib/widgets/daily_digest.dart` | Stateless widget computing and rendering actionable digest items |

### Modified files
| File | Changes |
|------|---------|
| `lib/screens/scout/scout_screen.dart` | Fire auto-audit on result tap |
| `lib/screens/audit/business_detail_screen.dart` | Watch audit state provider, stacked quick actions with demo/outreach status cards |
| `lib/screens/dashboard/dashboard_screen.dart` | Add daily digest section between stats and weekly chart |
| `lib/screens/pipeline/pipeline_screen_enhanced.dart` | Add "Needs Action" section, accept filter query param |
| `lib/screens/settings/settings_screen.dart` | Add auto-audit toggle |
| `lib/services/outreach_service.dart` | Add `fetchLatestOutreach(businessId)` method |
| `lib/providers/businesses_provider.dart` | Add audit trigger helper + invalidation logic |
| `lib/config/routes.dart` | Pipeline route accepts `filter` query param |

---

## Task 1: Auto-Audit Providers

**Files:**
- Create: `lib/providers/auto_audit_provider.dart`
- Create: `lib/providers/audit_state_provider.dart`
- Modify: `lib/providers/businesses_provider.dart`

- [ ] **Step 1: Create auto-audit preference provider**

```dart
// lib/providers/auto_audit_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'auto_audit_enabled';

final autoAuditProvider = StateNotifierProvider<AutoAuditNotifier, bool>((ref) {
  return AutoAuditNotifier();
});

class AutoAuditNotifier extends StateNotifier<bool> {
  AutoAuditNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? true;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }
}
```

- [ ] **Step 2: Create audit state provider**

```dart
// lib/providers/audit_state_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks per-business audit progress. Keyed by businessId.
/// - null = not started
/// - AsyncLoading = in progress
/// - AsyncData = completed
/// - AsyncError = failed
final auditStateProvider =
    StateProvider.family<AsyncValue<void>?, String>((ref, businessId) => null);
```

- [ ] **Step 3: Add audit trigger helper to businesses_provider.dart**

Add this function at the bottom of `lib/providers/businesses_provider.dart`:

```dart
/// Fire audit in background and manage provider invalidation chain.
Future<void> triggerAutoAudit(WidgetRef ref, String businessId) async {
  // Mark as loading
  ref.read(auditStateProvider(businessId).notifier).state =
      const AsyncValue.loading();

  try {
    await AuditService.auditBusiness(businessId);

    // Mark as complete
    ref.read(auditStateProvider(businessId).notifier).state =
        const AsyncValue.data(null);

    // Invalidation chain
    ref.invalidate(businessProvider(businessId));
    ref.invalidate(pipelineProvider);
    await ref.read(businessesProvider.notifier).load();
    ref.read(profileNotifierProvider.notifier).reload();
  } catch (e, st) {
    ref.read(auditStateProvider(businessId).notifier).state =
        AsyncValue.error(e, st);
  }
}
```

Add required imports at top of file:
```dart
import 'audit_state_provider.dart';
import '../services/audit_service.dart';
```

- [ ] **Step 4: Verify compilation**

Run: `flutter analyze lib/providers/`
Expected: No new errors

- [ ] **Step 5: Commit**

```bash
git add lib/providers/auto_audit_provider.dart lib/providers/audit_state_provider.dart lib/providers/businesses_provider.dart
git commit -m "feat: add auto-audit and audit-state providers"
```

---

## Task 2: Demo & Outreach Providers

**Files:**
- Create: `lib/providers/demo_provider.dart`
- Create: `lib/providers/outreach_provider.dart`
- Modify: `lib/services/outreach_service.dart`

- [ ] **Step 1: Create demo provider**

```dart
// lib/providers/demo_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/demo.dart';
import '../services/build_service.dart';

/// Fetches the latest demo for a business. Auto-disposed.
final demoForBusinessProvider =
    FutureProvider.autoDispose.family<Demo?, String>((ref, businessId) async {
  return await BuildService.fetchDemo(businessId);
});
```

- [ ] **Step 2: Add fetchLatestOutreach to outreach service**

Add to `lib/services/outreach_service.dart`:

```dart
/// Fetch the most recent outreach message for a business
static Future<Message?> fetchLatestOutreach(String businessId) async {
  final response = await SupabaseService.client
      .from('messages')
      .select()
      .eq('business_id', businessId)
      .order('created_at', ascending: false)
      .limit(1);

  if ((response as List).isEmpty) return null;
  return Message.fromJson(response.first as Map<String, dynamic>);
}
```

- [ ] **Step 3: Create outreach provider**

```dart
// lib/providers/outreach_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message.dart';
import '../services/outreach_service.dart';

/// Fetches the latest outreach message for a business. Auto-disposed.
final outreachForBusinessProvider =
    FutureProvider.autoDispose.family<Message?, String>((ref, businessId) async {
  return await OutreachService.fetchLatestOutreach(businessId);
});
```

- [ ] **Step 4: Verify compilation**

Run: `flutter analyze lib/providers/demo_provider.dart lib/providers/outreach_provider.dart lib/services/outreach_service.dart`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add lib/providers/demo_provider.dart lib/providers/outreach_provider.dart lib/services/outreach_service.dart
git commit -m "feat: add demo and outreach lookup providers"
```

---

## Task 3: Auto-Audit on Scout Select

**Files:**
- Modify: `lib/screens/scout/scout_screen.dart`

- [ ] **Step 1: Add auto-audit import and trigger on tap**

At the top of `lib/screens/scout/scout_screen.dart`, add imports:

```dart
import '../../providers/auto_audit_provider.dart';
import '../../providers/audit_state_provider.dart';
import '../../providers/businesses_provider.dart';
```

- [ ] **Step 2: Modify the LeadItem onTap handler**

Find the `onTap` in the results list builder (around line 309). Replace:

```dart
onTap: () => context.push('/business/${business.id}'),
```

With:

```dart
onTap: () {
  // Fire auto-audit in background if enabled and business not yet audited
  final autoAudit = ref.read(autoAuditProvider);
  if (autoAudit && !business.isAudited) {
    final profile = ref.read(profileNotifierProvider).value;
    final canAudit = profile == null ||
        profile.isPro ||
        profile.auditsThisMonth < 3;
    if (canAudit) {
      triggerAutoAudit(ref, business.id);
    }
  }
  context.push('/business/${business.id}');
},
```

- [ ] **Step 3: Add missing import for profileNotifierProvider if needed**

Check if `profile_provider.dart` is already imported. If not, add:
```dart
import '../../providers/profile_provider.dart';
```

- [ ] **Step 4: Verify compilation**

Run: `flutter analyze lib/screens/scout/scout_screen.dart`
Expected: No new errors

- [ ] **Step 5: Commit**

```bash
git add lib/screens/scout/scout_screen.dart
git commit -m "feat: fire auto-audit when selecting scout result"
```

---

## Task 4: Business Detail — Watch Audit State + Remove Manual Button

**Files:**
- Modify: `lib/screens/audit/business_detail_screen.dart`

- [ ] **Step 1: Add imports**

Add at top of file:
```dart
import '../../providers/auto_audit_provider.dart';
import '../../providers/audit_state_provider.dart';
import '../../providers/businesses_provider.dart';
```

- [ ] **Step 2: Watch audit state in build method**

Inside the `build` method, after `final businessAsync = ref.watch(businessProvider(widget.businessId));`, add inside the `data:` callback (after getting `business`):

```dart
final auditState = ref.watch(auditStateProvider(widget.businessId));
final autoAuditEnabled = ref.watch(autoAuditProvider);
final isAutoAuditing = auditState is AsyncLoading;
```

- [ ] **Step 3: Replace the manual audit button section**

Find the section `if (!business.isAudited && !_isAuditing)` (around line 236). Replace it with:

```dart
if (!business.isAudited && !_isAuditing && !isAutoAuditing)
  autoAuditEnabled
      ? const SizedBox.shrink() // Auto-audit will handle it; if it failed, show retry below
      : AppButton(
          label: 'Analyze Business',
          onPressed: () => _runAudit(business),
        )
            .animate(delay: 300.ms)
            .fadeIn(duration: 400.ms)
            .slideY(
              begin: AppConstants.entranceSlideDistance / 100,
              duration: 400.ms,
              curve: Curves.easeOutQuart,
            ),

// Show shimmer while auto-auditing
if (isAutoAuditing) _AnalyzingAnimation(),

// Show retry if auto-audit failed
if (auditState is AsyncError && !business.isAudited)
  AppButton(
    label: 'Retry Analysis',
    onPressed: () => triggerAutoAudit(ref, business.id),
  ),

if (_isAuditing) _AnalyzingAnimation(),
```

- [ ] **Step 4: Remove the artificial delay in _runAudit**

Find `await Future.delayed(const Duration(seconds: 2));` in `_runAudit` method and remove it.

- [ ] **Step 5: Verify compilation**

Run: `flutter analyze lib/screens/audit/business_detail_screen.dart`
Expected: No new errors

- [ ] **Step 6: Commit**

```bash
git add lib/screens/audit/business_detail_screen.dart
git commit -m "feat: business detail watches auto-audit state, removes artificial delay"
```

---

## Task 5: Business Detail — Stacked Quick Actions with Status Cards

**Files:**
- Modify: `lib/screens/audit/business_detail_screen.dart`

- [ ] **Step 1: Add demo/outreach provider imports**

```dart
import '../../providers/demo_provider.dart';
import '../../providers/outreach_provider.dart';
import '../../models/demo.dart';
import '../../models/message.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
```

- [ ] **Step 2: Watch demo and outreach providers in the audited section**

Inside the `if (business.isAudited || _auditResult != null)` block, add at the top:

```dart
final demoAsync = ref.watch(demoForBusinessProvider(business.id));
final outreachAsync = ref.watch(outreachForBusinessProvider(business.id));
final demo = demoAsync.valueOrNull;
final outreach = outreachAsync.valueOrNull;
```

- [ ] **Step 3: Replace the CTA buttons section**

Find the existing "Create Demo" and "Compose Outreach" AppButtons (around line 318-332). Replace with:

```dart
// Demo action
if (demo == null)
  AppButton(
    label: 'Generate Demo Site',
    onPressed: () async {
      await context.push('/business/${business.id}/build-demo');
      ref.invalidate(demoForBusinessProvider(business.id));
    },
  )
else
  _DemoStatusCard(
    demo: demo,
    onPreview: () => launchUrl(Uri.parse(demo.publicUrl),
        mode: LaunchMode.externalApplication),
    onShare: () => Share.share(
        'Check out this demo: ${demo.publicUrl}',
        subject: 'Demo Website'),
    onRegenerate: () async {
      await context.push('/business/${business.id}/build-demo');
      ref.invalidate(demoForBusinessProvider(business.id));
    },
  ),
const SizedBox(height: 12),

// Outreach action
if (outreach == null) ...[
  AppButton(
    label: 'Compose Outreach',
    variant: AppButtonVariant.secondary,
    onPressed: () async {
      await context.push('/business/${business.id}/outreach');
      ref.invalidate(outreachForBusinessProvider(business.id));
    },
  ),
  if (demo == null)
    Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        'Generate demo first for best results',
        style: AppTypography.chip(context).copyWith(
          color: CupertinoDynamicColor.resolve(
              AppColors.textTertiary, context),
        ),
        textAlign: TextAlign.center,
      ),
    ),
] else
  _OutreachStatusCard(
    message: outreach,
    onCopy: () {
      Clipboard.setData(ClipboardData(text: outreach.content));
      HapticFeedback.mediumImpact();
    },
    onRegenerate: () async {
      await context.push('/business/${business.id}/outreach');
      ref.invalidate(outreachForBusinessProvider(business.id));
    },
  ),
```

- [ ] **Step 4: Add the _DemoStatusCard widget**

Add at the bottom of the file (before the closing of the file):

```dart
class _DemoStatusCard extends StatelessWidget {
  final Demo demo;
  final VoidCallback onPreview;
  final VoidCallback onShare;
  final VoidCallback onRegenerate;

  const _DemoStatusCard({
    required this.demo,
    required this.onPreview,
    required this.onShare,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CupertinoDynamicColor.resolve(AppColors.divider, context),
            width: 1,
          ),
          bottom: BorderSide(
            color: CupertinoDynamicColor.resolve(AppColors.divider, context),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.checkmark_circle_fill,
                  size: 16,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.scoreGood, context)),
              const SizedBox(width: 6),
              Text('Demo ready',
                  style: AppTypography.labelLarge(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.scoreGood, context),
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppButton(
                    label: 'Preview',
                    compact: true,
                    onPressed: onPreview),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                    label: 'Share',
                    compact: true,
                    variant: AppButtonVariant.secondary,
                    onPressed: onShare),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                    label: 'Redo',
                    compact: true,
                    variant: AppButtonVariant.ghost,
                    onPressed: onRegenerate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Add the _OutreachStatusCard widget**

```dart
class _OutreachStatusCard extends StatelessWidget {
  final Message message;
  final VoidCallback onCopy;
  final VoidCallback onRegenerate;

  const _OutreachStatusCard({
    required this.message,
    required this.onCopy,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CupertinoDynamicColor.resolve(AppColors.divider, context),
            width: 1,
          ),
          bottom: BorderSide(
            color: CupertinoDynamicColor.resolve(AppColors.divider, context),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.checkmark_circle_fill,
                  size: 16,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.scoreGood, context)),
              const SizedBox(width: 6),
              Text('Outreach ready',
                  style: AppTypography.labelLarge(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.scoreGood, context),
                    fontWeight: FontWeight.w600,
                  )),
              const Spacer(),
              Text(message.channel.name,
                  style: AppTypography.chip(context)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message.content,
            style: AppTypography.bodyMedium(context).copyWith(
              color: CupertinoDynamicColor.resolve(
                  AppColors.textSecondary, context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppButton(
                    label: 'Copy',
                    compact: true,
                    onPressed: onCopy),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                    label: 'Regenerate',
                    compact: true,
                    variant: AppButtonVariant.ghost,
                    onPressed: onRegenerate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Verify compilation**

Run: `flutter analyze lib/screens/audit/business_detail_screen.dart`
Expected: No new errors

- [ ] **Step 7: Commit**

```bash
git add lib/screens/audit/business_detail_screen.dart
git commit -m "feat: stacked quick actions with demo/outreach status cards"
```

---

## Task 6: Dashboard Daily Digest

**Files:**
- Create: `lib/widgets/daily_digest.dart`
- Modify: `lib/screens/dashboard/dashboard_screen.dart`

- [ ] **Step 1: Create daily digest widget**

```dart
// lib/widgets/daily_digest.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';
import '../models/business.dart';

class DigestItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DigestItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class DailyDigest extends StatelessWidget {
  final List<Business> businesses;
  final void Function(String route) onNavigate;

  const DailyDigest({
    super.key,
    required this.businesses,
    required this.onNavigate,
  });

  List<DigestItem> _computeDigest() {
    final now = DateTime.now();
    final items = <DigestItem>[];

    // Leads needing audit
    final needsAudit = businesses
        .where((b) => b.status == BusinessStatus.found && !b.isAudited)
        .toList();
    if (needsAudit.isNotEmpty) {
      items.add(DigestItem(
        icon: CupertinoIcons.search,
        title: '${needsAudit.length} lead${needsAudit.length == 1 ? '' : 's'} need audit',
        subtitle: 'Tap to review',
        onTap: () => onNavigate('/pipeline?filter=found'),
      ));
    }

    // Demos ready to create
    final needsDemo = businesses
        .where((b) => b.status == BusinessStatus.audited)
        .toList();
    if (needsDemo.isNotEmpty) {
      final first = needsDemo.last; // oldest by createdAt (list is desc)
      items.add(DigestItem(
        icon: CupertinoIcons.globe,
        title: '${needsDemo.length} demo${needsDemo.length == 1 ? '' : 's'} ready to create',
        subtitle: 'Start with ${first.name}',
        onTap: () => onNavigate('/business/${first.id}/build-demo'),
      ));
    }

    // Demos ready to share (outreach needed)
    final needsOutreach = businesses
        .where((b) => b.status == BusinessStatus.demoCreated)
        .toList();
    if (needsOutreach.isNotEmpty) {
      final first = needsOutreach.last;
      items.add(DigestItem(
        icon: CupertinoIcons.paperplane,
        title: '${needsOutreach.length} demo${needsOutreach.length == 1 ? '' : 's'} ready to share',
        subtitle: 'Send outreach for ${first.name}',
        onTap: () => onNavigate('/business/${first.id}/outreach'),
      ));
    }

    // Follow-ups overdue
    final staleContacted = businesses.where((b) {
      if (b.status != BusinessStatus.contacted) return false;
      final ref = b.updatedAt ?? b.createdAt ?? now;
      return now.difference(ref).inHours >= 72;
    }).toList();
    if (staleContacted.isNotEmpty) {
      final first = staleContacted.last;
      items.add(DigestItem(
        icon: CupertinoIcons.clock,
        title: '${staleContacted.length} follow-up${staleContacted.length == 1 ? '' : 's'} overdue',
        subtitle: 'Contacted ${_daysAgo(first.updatedAt ?? first.createdAt ?? now)}',
        onTap: () => onNavigate('/business/${first.id}'),
      ));
    }

    return items;
  }

  static String _daysAgo(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'today';
    if (days == 1) return 'yesterday';
    return '$days days ago';
  }

  @override
  Widget build(BuildContext context) {
    final items = _computeDigest();

    if (items.isEmpty) {
      return GestureDetector(
        onTap: () => onNavigate('/scout'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: CupertinoDynamicColor.resolve(AppColors.divider, context),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(CupertinoIcons.checkmark_seal,
                  size: 18,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.scoreGood, context)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'All caught up! Search for new leads',
                  style: AppTypography.bodyLarge(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.textSecondary, context),
                  ),
                ),
              ),
              Icon(CupertinoIcons.chevron_right,
                  size: 14,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.textTertiary, context)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TO DO TODAY',
          style: AppTypography.labelSmall(context).copyWith(
            color: CupertinoDynamicColor.resolve(
                AppColors.textSecondary, context),
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(items.length, (i) {
          final item = items[i];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: item.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: i < items.length - 1
                  ? BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoDynamicColor.resolve(
                              AppColors.divider, context),
                          width: 0.5,
                        ),
                      ),
                    )
                  : null,
              child: Row(
                children: [
                  Icon(item.icon,
                      size: 18,
                      color: CupertinoDynamicColor.resolve(
                          AppColors.accent, context)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: AppTypography.titleMedium(context)),
                        const SizedBox(height: 2),
                        Text(item.subtitle,
                            style: AppTypography.labelLarge(context)),
                      ],
                    ),
                  ),
                  Icon(CupertinoIcons.chevron_right,
                      size: 14,
                      color: CupertinoDynamicColor.resolve(
                          AppColors.textTertiary, context)),
                ],
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: 50 * i))
              .fadeIn(duration: AppConstants.standardAnimation)
              .slideX(
                  begin: -0.03,
                  duration: AppConstants.standardAnimation +
                      const Duration(milliseconds: 100),
                  curve: Curves.easeOutCubic);
        }),
      ],
    );
  }
}
```

- [ ] **Step 2: Add digest to dashboard screen**

In `lib/screens/dashboard/dashboard_screen.dart`, add import:
```dart
import '../../widgets/daily_digest.dart';
```

Find the `// Weekly Activity Graph` SliverToBoxAdapter section. Insert BEFORE it:

```dart
// Daily Digest
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(
      AppConstants.pageHorizontal,
      AppConstants.sectionGap,
      AppConstants.pageHorizontal,
      0,
    ),
    child: DailyDigest(
      businesses: businesses,
      onNavigate: (route) => context.go(route),
    ),
  ),
),
```

- [ ] **Step 3: Verify compilation**

Run: `flutter analyze lib/widgets/daily_digest.dart lib/screens/dashboard/dashboard_screen.dart`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/widgets/daily_digest.dart lib/screens/dashboard/dashboard_screen.dart
git commit -m "feat: add daily digest to dashboard with actionable items"
```

---

## Task 7: Pipeline — Filter Query Param + Needs Action Section

**Files:**
- Modify: `lib/config/routes.dart`
- Modify: `lib/screens/pipeline/pipeline_screen_enhanced.dart`

- [ ] **Step 1: Update pipeline route to accept query param**

In `lib/config/routes.dart`, find the pipeline GoRoute inside the StatefulShellRoute branches. Update it to pass query params to the screen. The pipeline is a branch in the StatefulShellRoute — GoRoute branches don't easily pass query params. Instead, use a shared provider.

Create a simple filter provider. Add to `lib/providers/businesses_provider.dart`:

```dart
/// Shared filter state for pipeline, settable from dashboard digest
final pipelineFilterProvider = StateProvider<BusinessStatus?>((ref) => null);
```

- [ ] **Step 2: Update DailyDigest to set filter**

In `lib/widgets/daily_digest.dart`, change the "needs audit" digest item's onTap. Instead of navigating with query param, set the filter provider and navigate:

The `onNavigate` callback already navigates. The caller in dashboard needs to set the provider before navigating. Update the digest item for "needs audit":

```dart
onTap: () => onNavigate('/pipeline?filter=found'),
```

In dashboard_screen.dart, modify the `onNavigate` callback:

```dart
onNavigate: (route) {
  final uri = Uri.parse(route);
  final filter = uri.queryParameters['filter'];
  if (uri.path == '/pipeline' && filter != null) {
    final status = BusinessStatus.values.firstWhere(
      (s) => s.name == filter,
      orElse: () => BusinessStatus.found,
    );
    ref.read(pipelineFilterProvider.notifier).state = status;
    context.go('/pipeline');
  } else {
    context.go(route);
  }
},
```

Add import in dashboard:
```dart
import '../../providers/businesses_provider.dart';
```

- [ ] **Step 3: Pipeline reads filter provider**

In `lib/screens/pipeline/pipeline_screen_enhanced.dart`, replace the local `_filterStatus` with the shared provider.

In `initState`, read the provider:
```dart
@override
void initState() {
  super.initState();
  // Read initial filter from shared provider (set by dashboard digest)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final sharedFilter = ref.read(pipelineFilterProvider);
    if (sharedFilter != null) {
      setState(() => _filterStatus = sharedFilter);
      ref.read(pipelineFilterProvider.notifier).state = null; // Clear after reading
    }
  });
}
```

- [ ] **Step 4: Add Needs Action section**

In `_PipelineScreenEnhancedState`, add the stagnation computation method:

```dart
List<(Business, String)> _computeNeedsAction(
    Map<BusinessStatus, List<Business>> pipeline) {
  final now = DateTime.now();
  final result = <(Business, String)>[];

  for (final b in pipeline[BusinessStatus.found] ?? []) {
    if (now.difference(b.createdAt ?? now).inHours >= 24) {
      result.add((b, 'Audit this lead'));
    }
  }
  for (final b in pipeline[BusinessStatus.audited] ?? []) {
    final ref = b.auditedAt ?? b.updatedAt ?? b.createdAt ?? now;
    if (now.difference(ref).inHours >= 48) {
      result.add((b, 'Create demo'));
    }
  }
  for (final b in pipeline[BusinessStatus.demoCreated] ?? []) {
    final ref = b.updatedAt ?? b.createdAt ?? now;
    if (now.difference(ref).inHours >= 48) {
      result.add((b, 'Send outreach'));
    }
  }
  for (final b in pipeline[BusinessStatus.contacted] ?? []) {
    final ref = b.updatedAt ?? b.createdAt ?? now;
    if (now.difference(ref).inHours >= 72) {
      result.add((b, 'Follow up'));
    }
  }
  return result;
}
```

In the `build` method, inside `pipelineAsync.when(data: (pipeline) { ... })`, compute and render the section:

```dart
final needsAction = _computeNeedsAction(pipeline);
```

Insert before the existing pipeline sections SliverPadding, a new section:

```dart
if (needsAction.isNotEmpty && _filterStatus == null)
  SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.pageHorizontal,
        0,
        AppConstants.pageHorizontal,
        AppConstants.itemGap,
      ),
      child: _buildNeedsActionSection(needsAction),
    ),
  ),
```

Add the builder method:

```dart
Widget _buildNeedsActionSection(List<(Business, String)> items) {
  final isExpanded = _expandedSections[BusinessStatus.found] ?? true;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Reuse found's expanded state for simplicity
          setState(() {
            _expandedSections[BusinessStatus.found] =
                !(_expandedSections[BusinessStatus.found] ?? true);
          });
          Haptics.light();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'NEEDS ACTION',
                  style: AppTypography.labelSmall(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.scoreMid, context),
                  ),
                ),
              ),
              Text(
                items.length.toString(),
                style: AppTypography.labelLarge(context).copyWith(
                  color: CupertinoDynamicColor.resolve(
                      AppColors.scoreMid, context),
                ),
              ),
            ],
          ),
        ),
      ),
      Container(
        height: 0.5,
        color: CupertinoDynamicColor.resolve(AppColors.divider, context),
      ),
      if (isExpanded) ...items.map((item) {
        final (business, action) = item;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push('/business/${business.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(business.name,
                          style: AppTypography.titleMedium(context)),
                      const SizedBox(height: 2),
                      Text(action,
                          style: AppTypography.labelLarge(context).copyWith(
                            color: CupertinoDynamicColor.resolve(
                                AppColors.scoreMid, context),
                          )),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.chevron_right,
                    size: 14,
                    color: CupertinoDynamicColor.resolve(
                        AppColors.textTertiary, context)),
              ],
            ),
          ),
        );
      }),
      SizedBox(height: AppConstants.itemGap),
    ],
  );
}
```

- [ ] **Step 5: Verify compilation**

Run: `flutter analyze lib/screens/pipeline/pipeline_screen_enhanced.dart lib/screens/dashboard/dashboard_screen.dart lib/config/routes.dart`
Expected: No new errors

- [ ] **Step 6: Commit**

```bash
git add lib/screens/pipeline/pipeline_screen_enhanced.dart lib/screens/dashboard/dashboard_screen.dart lib/providers/businesses_provider.dart lib/widgets/daily_digest.dart
git commit -m "feat: pipeline needs-action section + dashboard filter navigation"
```

---

## Task 8: Settings — Auto-Audit Toggle

**Files:**
- Modify: `lib/screens/settings/settings_screen.dart`

- [ ] **Step 1: Add import**

```dart
import '../../providers/auto_audit_provider.dart';
```

- [ ] **Step 2: Add toggle to PREFERENCES section**

Find the `CupertinoListSection.insetGrouped` for PREFERENCES. Add a new tile at the top of the `children` list:

```dart
CupertinoListTile(
  leading: const Icon(CupertinoIcons.bolt),
  title: const Text('Auto-analyze'),
  subtitle: const Text('Audit businesses when selected'),
  trailing: CupertinoSwitch(
    value: ref.watch(autoAuditProvider),
    onChanged: (_) {
      Haptics.light();
      ref.read(autoAuditProvider.notifier).toggle();
    },
  ),
),
```

Note: `SettingsScreen` is currently a `ConsumerWidget`. `ref` is available in the `build` method.

- [ ] **Step 3: Verify compilation**

Run: `flutter analyze lib/screens/settings/settings_screen.dart`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/screens/settings/settings_screen.dart
git commit -m "feat: add auto-audit toggle to settings"
```

---

## Task 9: End-to-End Verification

- [ ] **Step 1: Full analysis**

Run: `flutter analyze lib/`
Expected: No new errors (only pre-existing info/warnings)

- [ ] **Step 2: Manual test — auto-audit flow**

1. Open app → go to Scout tab
2. Search for any business
3. Tap a result → should navigate to Business Detail
4. Business Detail should show audit shimmer/animation
5. After a few seconds, audit score should appear
6. "Generate Demo" and "Compose Outreach" CTAs should be visible

- [ ] **Step 3: Manual test — daily digest**

1. Go to Dashboard tab
2. If you have un-audited leads, "TO DO TODAY" section should appear
3. Tap a digest item → should navigate to the correct screen
4. If no actionable items → "All caught up!" should show

- [ ] **Step 4: Manual test — pipeline needs action**

1. Go to Pipeline tab
2. If you have stale leads (>24h found, >48h audited, etc), "NEEDS ACTION" section shows at top
3. Tap a needs-action item → navigates to business detail

- [ ] **Step 5: Manual test — settings toggle**

1. Go to Settings tab
2. Find "Auto-analyze" toggle
3. Turn it off
4. Go to Scout, search, tap result
5. Business Detail should show manual "Analyze Business" button (no auto-audit)

- [ ] **Step 6: Final commit**

```bash
git add -A
git commit -m "feat: one-tap pipeline — auto-audit, stacked actions, daily digest, needs-action"
```
