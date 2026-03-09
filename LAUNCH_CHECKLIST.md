# 🚀 LeadForge - Launch Checklist

**Use this as your step-by-step guide from code → App Store**

---

## PHASE 1: LOCAL SETUP (Day 1)

### ✅ Environment Setup

- [ ] Flutter 3.0+ installed
- [ ] Xcode 15+ installed
- [ ] Homebrew installed (macOS)
- [ ] Git configured

### ✅ Project Setup

```bash
cd /data/.openclaw/workspace/apps/leadforge
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Expected:** `*.g.dart` and `*.freezed.dart` files generated, no errors

### ✅ Assets

- [ ] Download SF Pro fonts from https://developer.apple.com/fonts/
- [ ] Copy 5 font files to `assets/fonts/`
- [ ] Verify `pubspec.yaml` fonts section matches file names

### ✅ First Run

```bash
flutter run
```

**Expected:** App launches on simulator (will error on auth, that's ok)

---

## PHASE 2: BACKEND SETUP (Day 1-2)

### ✅ Supabase Project

- [ ] Go to https://supabase.com/dashboard
- [ ] Create new project: "leadforge"
- [ ] Save project URL + anon key
- [ ] Wait for project initialization (~2 min)

### ✅ Database Schema

- [ ] Go to SQL Editor in Supabase dashboard
- [ ] Copy SQL schema from blueprint (SETUP_GUIDE.md or original spec)
- [ ] Run SQL
- [ ] Verify tables created in Table Editor:
  - [ ] profiles
  - [ ] searches
  - [ ] businesses
  - [ ] demos
  - [ ] messages

### ✅ Row Level Security

- [ ] In Table Editor, click each table
- [ ] Verify "RLS enabled" badge is ON
- [ ] Check policies exist (should be auto-created by SQL)

### ✅ Supabase CLI

```bash
npm install -g supabase
supabase login
supabase link --project-ref YOUR_PROJECT_REF
```

### ✅ Edge Functions

```bash
cd supabase/functions
supabase functions deploy scout
# TODO: Create and deploy other 5 functions
# (audit, build-demo, outreach, demo, demo-view)
```

**Note:** Only `scout` function is complete. Others need implementation.

### ✅ Environment Secrets

```bash
supabase secrets set GOOGLE_PLACES_API_KEY=your_key
supabase secrets set OPENAI_API_KEY=your_key
```

### ✅ Update Flutter Config

In `lib/config/constants.dart`:
```dart
static const supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
static const supabaseAnonKey = 'YOUR_ANON_KEY';
```

---

## PHASE 3: EXTERNAL APIS (Day 2)

### ✅ Google Cloud Console

- [ ] Go to https://console.cloud.google.com
- [ ] Create project: "LeadForge"
- [ ] Enable "Places API"
- [ ] Create API key
- [ ] Restrict key to Places API only
- [ ] Set billing alert: $200/month
- [ ] Copy key to Supabase secrets

### ✅ OpenAI

- [ ] Go to https://platform.openai.com/api-keys
- [ ] Create new key: "LeadForge"
- [ ] Copy key (won't show again!)
- [ ] Copy to Supabase secrets

### ✅ RevenueCat

- [ ] Sign up at https://www.revenuecat.com
- [ ] Create app: "LeadForge" (iOS)
- [ ] Bundle ID: `io.leadforge.app`
- [ ] Create products:
  - [ ] `pro_monthly` ($29.99/month)
  - [ ] `pro_annual` ($199.99/year)
- [ ] Create entitlement: "pro"
- [ ] Attach both products to entitlement
- [ ] Copy public API key
- [ ] Update `lib/config/constants.dart`

---

## PHASE 4: IOS CONFIGURATION (Day 2)

### ✅ Xcode Setup

```bash
open ios/Runner.xcworkspace
```

- [ ] Select "Runner" in navigator
- [ ] General → Identity → Bundle Identifier: `io.leadforge.app`
- [ ] Signing & Capabilities → Team: Select your Apple Developer team
- [ ] Signing & Capabilities → Add "Sign in with Apple" capability

### ✅ App Store Connect

- [ ] Go to https://appstoreconnect.apple.com
- [ ] My Apps → "+" → New App
- [ ] Name: "LeadForge"
- [ ] Bundle ID: `io.leadforge.app`
- [ ] SKU: `leadforge-ios`
- [ ] Save

### ✅ In-App Purchases

- [ ] In App Store Connect → Your App → In-App Purchases
- [ ] Create Subscription Group: "Pro"
- [ ] Add subscription: "Pro Monthly"
  - [ ] Product ID: `pro_monthly`
  - [ ] Price: $29.99
- [ ] Add subscription: "Pro Annual"
  - [ ] Product ID: `pro_annual`
  - [ ] Price: $199.99
- [ ] Submit for review

---

## PHASE 5: TESTING (Day 3)

### ✅ Simulator Testing

```bash
flutter run
```

**Test Flow:**
1. - [ ] Launch app
2. - [ ] Sign up with email
3. - [ ] Complete onboarding
4. - [ ] Search for "dentists Austin" (will hit real API)
5. - [ ] View business detail
6. - [ ] Run audit (check score animation)
7. - [ ] Navigate to Pipeline
8. - [ ] Navigate to Dashboard (check animated stats)
9. - [ ] Navigate to Settings
10. - [ ] Sign out

### ✅ Error Testing

- [ ] Try search with no internet → should show error
- [ ] Try audit 4 times as free user → should show paywall
- [ ] Try invalid email on login → should show error
- [ ] Navigate while loading → should handle gracefully

### ✅ Real Device Testing

```bash
flutter run -d <your-device-id>
```

**Test Flow:**
- [ ] All above tests
- [ ] Test Apple Sign In (only works on device)
- [ ] Test haptic feedback (simulator doesn't have this)
- [ ] Test IAP flow (simulator shows sandbox dialog)

---

## PHASE 6: POLISH (Day 3-4)

### ✅ Integrate Premium Widgets

**Replace in `business_detail_screen.dart`:**
```dart
// Old:
ScoreGauge(score: score)

// New:
AnimatedScoreGauge(score: score)
```

**Replace in `dashboard_screen.dart`:**
```dart
// Old:
_StatCard(...)

// New:
StatCardAnimated(...)
```

**Add to `scout_screen.dart`:**
```dart
// Show SearchSuggestions when search field is focused
```

**Replace all `ElevatedButton` with:**
```dart
AnimatedButton.primary(...)
```

### ✅ UX Improvements (Priority)

From UX_ANALYSIS.md, implement:
- [ ] C11: Animated score gauge ← Already created
- [ ] C10: Optimistic UI (show shimmer immediately on search)
- [ ] C7: Search suggestions ← Already created
- [ ] C18: Animated stats ← Already created
- [ ] Cross-cutting: Button animations ← Already created
- [ ] Cross-cutting: Haptic feedback ← Utils created, add to buttons

### ✅ Final Polish

- [ ] App icon (1024x1024) → generate with appicon.co
- [ ] Launch screen (use Xcode storyboard)
- [ ] Test on multiple screen sizes:
  - [ ] iPhone SE (small)
  - [ ] iPhone 14 Pro (notch)
  - [ ] iPhone 16 Pro Max (large)

---

## PHASE 7: BUILD & TESTFLIGHT (Day 4)

### ✅ Build for Release

```bash
flutter build ios --release
```

**Expected:** Build succeeds, no errors

### ✅ Archive in Xcode

1. - [ ] Open `ios/Runner.xcworkspace`
2. - [ ] Select "Any iOS Device (arm64)"
3. - [ ] Product → Archive
4. - [ ] Wait (~5-10 min)
5. - [ ] Window → Organizer → Archives
6. - [ ] Click "Distribute App"

### ✅ Upload to App Store Connect

- [ ] Select "App Store Connect"
- [ ] Next → Next → Upload
- [ ] Wait for processing (~10-15 min)

### ✅ TestFlight Configuration

- [ ] Go to App Store Connect → TestFlight
- [ ] Add internal testers (yourself + team)
- [ ] Accept export compliance (No encryption beyond standard)
- [ ] Add "What to Test" notes
- [ ] Send invites

### ✅ TestFlight Testing

- [ ] Install TestFlight app on iPhone
- [ ] Accept invitation
- [ ] Install LeadForge beta
- [ ] Test all features on real device
- [ ] Check for crashes
- [ ] Note any bugs

---

## PHASE 8: APP STORE SUBMISSION (Day 5)

### ✅ Marketing Materials

- [ ] App icon (1024x1024, no alpha)
- [ ] Screenshots (6.7", 6.5", 5.5" required)
  - [ ] Use blueprint screenshots guide
  - [ ] Add text overlays showing value
- [ ] App preview video (optional, 30s max)

### ✅ Metadata

- [ ] App name: "LeadForge - AI Lead Generator"
- [ ] Subtitle: "Find & close local clients fast"
- [ ] Description: Copy from blueprint (4000 chars)
- [ ] Keywords: Copy from blueprint (100 chars)
- [ ] Category: Business → Productivity
- [ ] Content rating: 4+

### ✅ App Review Information

- [ ] Contact info (your email + phone)
- [ ] Demo account:
  - Email: demo@leadforge.app
  - Password: TestPassword123!
- [ ] Notes for reviewer: Copy from blueprint

### ✅ Pricing

- [ ] Free with In-App Purchases
- [ ] Available in all territories
- [ ] No pre-order

### ✅ Submit for Review

- [ ] Click "Add for Review"
- [ ] Submit
- [ ] Wait 24-48 hours for review

---

## PHASE 9: POST-LAUNCH (Week 1)

### ✅ Monitoring

- [ ] Check crash reports daily (Xcode Organizer)
- [ ] Monitor App Store reviews
- [ ] Track RevenueCat dashboard (installs, conversions)
- [ ] Check Supabase logs for errors

### ✅ Marketing

- [ ] Tweet launch announcement
- [ ] Post on Product Hunt
- [ ] Share on LinkedIn
- [ ] Post in relevant Reddit/Discord communities
- [ ] Email beta testers for reviews

### ✅ Iterate

- [ ] Read user reviews
- [ ] Fix critical bugs
- [ ] Implement UX improvements from analysis
- [ ] Prepare v1.1 update

---

## TROUBLESHOOTING

### "Undefined name" errors
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### "Connection refused" / "Unauthorized"
- Check Supabase URL in constants.dart
- Check anon key is correct
- Verify RLS policies allow read

### "API limit exceeded"
- Check Google Cloud billing
- Verify API key restrictions
- Check Supabase secrets are set

### "Payment failed" in IAP
- IAP only works on real devices
- Must be signed in with Sandbox tester account
- Check RevenueCat dashboard for status

### Build fails in Xcode
- Clean build folder (Cmd+Shift+K)
- Update pods: `cd ios && pod install`
- Check signing certificates

---

## SUPPORT RESOURCES

- **Flutter Issues:** https://github.com/flutter/flutter/issues
- **Supabase Docs:** https://supabase.com/docs
- **RevenueCat Docs:** https://www.revenuecat.com/docs
- **Apple Developer:** https://developer.apple.com/support

---

## ESTIMATED TIMELINE

- Phase 1 (Setup): 2 hours
- Phase 2 (Backend): 4 hours
- Phase 3 (APIs): 2 hours
- Phase 4 (iOS): 2 hours
- Phase 5 (Testing): 3 hours
- Phase 6 (Polish): 6 hours
- Phase 7 (TestFlight): 2 hours
- Phase 8 (App Store): 2 hours

**Total:** ~23 hours (3-4 days full-time)

---

## SUCCESS CRITERIA

✅ App launches without crashes  
✅ All 7 screens navigable  
✅ Auth flow works (signup, login, logout)  
✅ Search returns real businesses  
✅ Audit generates scores  
✅ Payment flow works (on real device)  
✅ App feels premium (animations, haptics)

---

**When all checkboxes are checked, you're ready to launch! 🚀**

Good luck, Ben. Let's make this a success story.

— Marty Supreme
