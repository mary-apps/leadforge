# LeadForge - AI Lead Generation App

**Status:** MVP Code Complete (Needs Configuration)

## 🎯 What is LeadForge?

AI-powered lead generation tool for freelancers and agencies. Find local businesses with poor online presence, analyze them with AI, generate demo websites, and create personalized outreach messages — all from your iPhone.

## 📁 Project Structure

```
lib/
├── config/         # App configuration (theme, constants, routes)
├── models/         # Data models (freezed)
├── services/       # API & backend services
├── providers/      # Riverpod state management
├── screens/        # UI screens
├── widgets/        # Reusable components
└── utils/          # Helpers & utilities
```

## 🛠️ Setup Required

### 1. Supabase Configuration

1. Create Supabase project at https://supabase.com
2. Run the SQL schema from the blueprint in your Supabase SQL editor
3. Set up Edge Functions:
   - `/scout` - Business search
   - `/audit` - AI analysis
   - `/build-demo` - Demo generation
   - `/outreach` - Message generation
   - `/demo/:slug` - Serve demos (public)
   - `/demo-view/:slug` - Track views (public)

4. Update environment variables:
```dart
// In lib/config/constants.dart
static const supabaseUrl = 'YOUR_SUPABASE_URL';
static const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 2. Google Places API

1. Enable Google Places API in Google Cloud Console
2. Get API key
3. Add to Edge Function environment variables:
```
GOOGLE_PLACES_API_KEY=your_key_here
```

### 3. OpenAI API

1. Get OpenAI API key from https://platform.openai.com
2. Add to Edge Function environment variables:
```
OPENAI_API_KEY=your_key_here
```

### 4. RevenueCat

1. Create RevenueCat account at https://www.revenuecat.com
2. Create iOS app
3. Set up products (Pro Monthly, Pro Annual)
4. Update:
```dart
// In lib/config/constants.dart
static const revenueCatApiKey = 'YOUR_REVENUECAT_KEY';
```

### 5. Apple Developer Setup

1. Configure Apple Sign In capability
2. Set up App Store Connect
3. Configure iOS bundle identifier

## 🚀 Running the App

```bash
# Install dependencies
flutter pub get

# Generate freezed/json_serializable code
flutter pub run build_runner build --delete-conflicting-outputs

# Run on iOS simulator/device
flutter run
```

## 📝 TODO Before Launch

- [ ] Configure Supabase project
- [ ] Deploy Edge Functions
- [ ] Set up Google Places API
- [ ] Set up OpenAI API
- [ ] Configure RevenueCat
- [ ] Add SF Pro fonts to assets/fonts/
- [ ] Test on real device
- [ ] Set up TestFlight
- [ ] Create App Store listing

## 🎨 Design System

**Colors:**
- Background: #0A0A0F (dark)
- Primary: #6C5CE7 (purple)
- Success: #00D68F (green)
- Warning: #FDCB6E (amber)
- Danger: #FF6B6B (red)

**Typography:**
- Display: SF Pro Display Bold
- Body: SF Pro Text Regular
- Mono: SF Mono Medium

## 📦 Key Dependencies

- flutter_riverpod: State management
- supabase_flutter: Backend & auth
- go_router: Navigation
- freezed: Immutable models
- purchases_flutter: RevenueCat monetization
- flutter_animate: Animations
- shimmer: Loading states

## 🔐 Security

- RLS policies enabled on all Supabase tables
- Secure storage for auth tokens (flutter_secure_storage)
- API keys in environment variables (not hardcoded)
- Certificate pinning ready (needs implementation)

## 📊 Monetization

**Free Tier:**
- 5 searches/month
- 3 audits/month
- 1 demo/month

**Pro Tier ($29.99/mo or $199.99/year):**
- Unlimited everything
- Outreach messages
- Export pipeline
- Priority support

## 📱 Screens

1. **Login** - Email/password + Apple Sign In
2. **Onboarding** - 4 slides + profile setup
3. **Scout** - Search businesses
4. **Business Detail** - View + audit
5. **Pipeline** - Kanban-style CRM
6. **Dashboard** - Stats + revenue tracker
7. **Settings** - Profile + subscription

## 🧪 Testing

```bash
# Run tests (when added)
flutter test

# Analyze code
flutter analyze
```

## 📄 License

Private project - All rights reserved

---

**Built by:** Marty Supreme
**For:** Benjamin (LeadForge MVP)
**Date:** March 2026
