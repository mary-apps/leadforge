# LeadForge - Setup Guide

Complete step-by-step setup instructions.

## Prerequisites

- [ ] Flutter 3.0+ installed
- [ ] Xcode installed (macOS)
- [ ] Supabase account
- [ ] Google Cloud account
- [ ] OpenAI account
- [ ] RevenueCat account
- [ ] Apple Developer account

---

## Step 1: Clone & Dependencies (5 min)

```bash
cd /data/.openclaw/workspace/apps/leadforge
flutter pub get
```

---

## Step 2: Generate Code (2 min)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates `*.g.dart` and `*.freezed.dart` files.

---

## Step 3: Supabase Setup (30 min)

### 3.1 Create Project

1. Go to https://supabase.com/dashboard
2. Click "New Project"
3. Name: `leadforge`
4. Generate strong password
5. Select region closest to users

### 3.2 Run SQL Schema

1. Go to SQL Editor
2. Paste the complete schema from blueprint
3. Click "Run"
4. Verify tables created in Table Editor

### 3.3 Deploy Edge Functions

```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link project
supabase link --project-ref YOUR_PROJECT_REF

# Deploy functions
supabase functions deploy scout
supabase functions deploy audit
supabase functions deploy build-demo
supabase functions deploy outreach
supabase functions deploy demo
supabase functions deploy demo-view
```

### 3.4 Set Environment Variables

```bash
supabase secrets set GOOGLE_PLACES_API_KEY=your_key_here
supabase secrets set OPENAI_API_KEY=your_key_here
```

### 3.5 Update Flutter Config

In `lib/config/constants.dart`:
```dart
static const supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
static const supabaseAnonKey = 'YOUR_ANON_KEY';
```

---

## Step 4: Google Places API (10 min)

### 4.1 Enable API

1. Go to https://console.cloud.google.com
2. Create new project or select existing
3. Go to "APIs & Services" → "Library"
4. Search "Places API"
5. Click "Enable"

### 4.2 Create API Key

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "API Key"
3. Copy the key
4. Click "Restrict Key"
5. Under "API restrictions", select "Places API"
6. Save

### 4.3 Set Billing Limit

1. Go to "Billing" → "Budgets & alerts"
2. Create budget: $200/month
3. Set alert at 50%, 90%, 100%

---

## Step 5: OpenAI API (5 min)

1. Go to https://platform.openai.com/api-keys
2. Click "Create new secret key"
3. Name: `LeadForge`
4. Copy the key (save it, won't show again)
5. Add to Supabase secrets (done in Step 3.4)

---

## Step 6: RevenueCat Setup (15 min)

### 6.1 Create Account

1. Go to https://www.revenuecat.com
2. Sign up for free account

### 6.2 Create App

1. Click "Add App"
2. Name: `LeadForge`
3. Platform: iOS
4. Bundle ID: `io.leadforge.app`

### 6.3 Create Products

1. Go to "Products"
2. Create "Pro Monthly":
   - Identifier: `pro_monthly`
   - Type: Auto-renewable subscription
   - Duration: 1 month
3. Create "Pro Annual":
   - Identifier: `pro_annual`
   - Type: Auto-renewable subscription
   - Duration: 1 year

### 6.4 Create Entitlement

1. Go to "Entitlements"
2. Create "Pro" entitlement
3. Attach both products

### 6.5 Get API Key

1. Go to "API Keys"
2. Copy "Public App-specific API key"
3. Update in `lib/config/constants.dart`:

```dart
static const revenueCatApiKey = 'YOUR_KEY_HERE';
```

---

## Step 7: iOS Configuration (20 min)

### 7.1 Open in Xcode

```bash
open ios/Runner.xcworkspace
```

### 7.2 Configure Bundle ID

1. Select "Runner" in Project Navigator
2. Under "General" → "Identity"
3. Bundle Identifier: `io.leadforge.app`

### 7.3 Enable Apple Sign In

1. Go to "Signing & Capabilities"
2. Click "+ Capability"
3. Select "Sign in with Apple"

### 7.4 Configure App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Click "My Apps" → "+"
3. Create new app:
   - Platform: iOS
   - Name: LeadForge
   - Bundle ID: io.leadforge.app
   - SKU: leadforge-ios
   - Access: Full Access

### 7.5 Configure In-App Purchases

1. In App Store Connect → Your App
2. Go to "In-App Purchases"
3. Create subscription group: "Pro"
4. Add subscriptions:
   - Pro Monthly: $29.99
   - Pro Annual: $199.99
5. Submit for review

---

## Step 8: Add Assets (10 min)

### 8.1 Download SF Pro Fonts

1. Go to https://developer.apple.com/fonts/
2. Download "SF Pro" family
3. Extract and copy to `assets/fonts/`:
   - SFProDisplay-Bold.otf
   - SFProDisplay-Semibold.otf
   - SFProText-Regular.otf
   - SFProText-Semibold.otf
   - SFMono-Medium.otf

### 8.2 App Icon (Optional)

1. Create 1024x1024 icon
2. Use https://appicon.co to generate iOS assets
3. Replace `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

---

## Step 9: Test on Simulator (10 min)

```bash
# List simulators
flutter devices

# Run on simulator
flutter run
```

### Test Flow:
1. ✓ Sign up with email
2. ✓ Complete onboarding
3. ✓ Search for businesses
4. ✓ View business detail
5. ✓ Run audit (check API limits)
6. ✓ Navigate between tabs
7. ✓ Settings screen

---

## Step 10: TestFlight (30 min)

### 10.1 Build

```bash
flutter build ios --release
```

### 10.2 Archive in Xcode

1. Open `ios/Runner.xcworkspace`
2. Select "Any iOS Device (arm64)"
3. Product → Archive
4. Wait for build to complete

### 10.3 Upload to App Store Connect

1. Click "Distribute App"
2. Select "App Store Connect"
3. Upload
4. Wait for processing (~10 min)

### 10.4 Configure TestFlight

1. Go to App Store Connect → TestFlight
2. Add internal testers
3. Accept export compliance
4. Send invites

---

## Troubleshooting

### Build Runner Issues

```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Supabase Connection Issues

- Verify URLs in constants.dart
- Check RLS policies are enabled
- Verify auth token is being sent

### RevenueCat Issues

- Verify API key
- Check bundle ID matches
- Test on real device (not simulator for IAP)

### Google Places API Issues

- Verify API is enabled
- Check billing is set up
- Verify API key restrictions

---

## Security Checklist

- [ ] API keys in environment variables (not hardcoded)
- [ ] RLS policies enabled on all tables
- [ ] Supabase anon key is safe to expose (RLS protects data)
- [ ] Google Places API key restricted to Places API only
- [ ] Billing limits set on Google Cloud

---

## Cost Estimates

**Free Tier:**
- Supabase: Free (up to 500MB, 2GB transfer)
- Google Places: $200 free credit/month
- OpenAI: Pay as you go (~$1/month for MVP testing)
- RevenueCat: Free (up to $10K MRR)

**Expected Monthly Costs (100 active users):**
- Google Places: ~$50
- OpenAI: ~$5
- Supabase: $0 (free tier sufficient)
- RevenueCat: $0
- **Total: ~$55/month**

---

## Next Steps

After setup complete:
1. Internal testing (1 week)
2. Fix bugs
3. Submit for App Review
4. Prepare marketing materials
5. Launch! 🚀

---

**Questions?** Check README.md or create an issue.
