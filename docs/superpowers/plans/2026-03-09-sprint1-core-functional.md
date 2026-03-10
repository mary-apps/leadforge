# Sprint 1: Make Core Functional - Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the 3 missing Edge Functions operational so the app's core features (audit, build-demo, outreach) actually work, fix critical bugs, and implement stub functions.

**Architecture:** Each Edge Function follows the same pattern as the existing `scout` function: Deno/TypeScript, auth via Authorization header, usage limit check against profiles table, call external AI API (OpenAI), persist results to Supabase, return JSON. The Flutter services already have the correct HTTP contracts — we just need the server-side to respond.

**Tech Stack:** Deno (Supabase Edge Functions), OpenAI API, Supabase JS Client, Flutter/Dart

---

## Chunk 1: Edge Functions

### Task 1: Create `audit` Edge Function

**Files:**
- Create: `supabase/functions/audit/index.ts`

**Context:** The Flutter `AuditService` sends `POST { business_id }` and expects back `{ score, breakdown, diagnosis }` matching the `AuditResult` model. The function should: fetch the business from DB, analyze its web presence using OpenAI, save audit results to the `businesses` table, increment `audits_this_month`, and return the result.

- [ ] **Step 1: Create the audit edge function**

```typescript
// supabase/functions/audit/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Auth
    const authHeader = req.headers.get('Authorization')!
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 2. Check usage limits
    const { data: profile } = await supabase
      .from('profiles')
      .select('subscription_tier, audits_this_month')
      .eq('id', user.id)
      .single()

    if (profile.subscription_tier === 'free' && profile.audits_this_month >= 3) {
      return new Response(JSON.stringify({ error: 'Free tier audit limit reached' }), {
        status: 402, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 3. Get business
    const { business_id } = await req.json()
    const { data: business } = await supabase
      .from('businesses')
      .select('*')
      .eq('id', business_id)
      .eq('user_id', user.id)
      .single()

    if (!business) {
      return new Response(JSON.stringify({ error: 'Business not found' }), {
        status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 4. AI Audit via OpenAI
    const openaiKey = Deno.env.get('OPENAI_API_KEY')
    const prompt = `You are a digital marketing expert. Analyze this local business and score their web presence from 0-100.

Business: ${business.name}
Address: ${business.address || 'Unknown'}
Website: ${business.website || 'None'}
Rating: ${business.rating || 'N/A'} (${business.reviews_count} reviews)
Phone: ${business.phone || 'None'}
Categories: ${JSON.stringify(business.categories)}

Score these factors (each 0-20 points):
1. website_quality - Do they have a website? Is the URL professional?
2. online_reviews - Rating and review count quality
3. contact_info - Phone, address completeness
4. social_presence - Based on categories, likely social media presence
5. local_seo - Business listing completeness (photos, hours, categories)

Return ONLY valid JSON in this exact format:
{
  "score": <total 0-100>,
  "breakdown": {
    "website_quality": { "label": "Website Quality", "impact": <0-20>, "passed": <true/false> },
    "online_reviews": { "label": "Online Reviews", "impact": <0-20>, "passed": <true/false> },
    "contact_info": { "label": "Contact Info", "impact": <0-20>, "passed": <true/false> },
    "social_presence": { "label": "Social Presence", "impact": <0-20>, "passed": <true/false> },
    "local_seo": { "label": "Local SEO", "impact": <0-20>, "passed": <true/false> }
  },
  "diagnosis": "<2-3 sentence summary of main weaknesses and opportunity for a web agency to help>"
}`

    const aiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.3,
        response_format: { type: 'json_object' },
      }),
    })

    const aiData = await aiResponse.json()
    const auditResult = JSON.parse(aiData.choices[0].message.content)

    // 5. Save to database
    await supabase
      .from('businesses')
      .update({
        audit_score: auditResult.score,
        audit_breakdown: auditResult.breakdown,
        audit_diagnosis: auditResult.diagnosis,
        audited_at: new Date().toISOString(),
        status: 'audited',
        web_presence: auditResult.score >= 60 ? 'decent' : auditResult.score >= 30 ? 'poor' : 'none',
      })
      .eq('id', business_id)

    // 6. Increment usage
    await supabase
      .from('profiles')
      .update({ audits_this_month: profile.audits_this_month + 1 })
      .eq('id', user.id)

    // 7. Return result
    return new Response(JSON.stringify(auditResult), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})
```

- [ ] **Step 2: Verify the function file exists and is valid TypeScript**

Run: `cat supabase/functions/audit/index.ts | head -5`
Expected: Shows the import lines

- [ ] **Step 3: Commit**

```bash
git add supabase/functions/audit/index.ts
git commit -m "feat: add audit edge function with OpenAI integration"
```

---

### Task 2: Create `build-demo` Edge Function

**Files:**
- Create: `supabase/functions/build-demo/index.ts`

**Context:** The Flutter `BuildService` sends `POST { business_id, template }` and expects the function to generate a demo HTML page, store it in Supabase Storage, create a `demos` record with a `public_slug`, and return success. The Flutter app then fetches the demo from the `demos` table.

- [ ] **Step 1: Create the build-demo edge function**

```typescript
// supabase/functions/build-demo/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

function generateSlug(): string {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789'
  let slug = ''
  for (let i = 0; i < 8; i++) {
    slug += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return slug
}

function generateDemoHTML(business: any, template: string): string {
  const colors: Record<string, { primary: string; accent: string }> = {
    restaurant: { primary: '#E65100', accent: '#FF8F00' },
    professional: { primary: '#1565C0', accent: '#0277BD' },
    health_beauty: { primary: '#AD1457', accent: '#C2185B' },
  }
  const { primary, accent } = colors[template] || colors.professional

  const hours = business.opening_hours
    ? '<p>See our opening hours on Google Maps</p>'
    : ''

  const rating = business.rating
    ? `<div class="rating">⭐ ${business.rating}/5 (${business.reviews_count} reviews)</div>`
    : ''

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${business.name} - Demo Website</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; color: #333; }
    .hero { background: linear-gradient(135deg, ${primary}, ${accent}); color: white; padding: 80px 20px; text-align: center; }
    .hero h1 { font-size: 2.5rem; margin-bottom: 16px; }
    .hero p { font-size: 1.2rem; opacity: 0.9; max-width: 600px; margin: 0 auto; }
    .section { padding: 60px 20px; max-width: 800px; margin: 0 auto; }
    .section h2 { font-size: 1.8rem; margin-bottom: 24px; color: ${primary}; }
    .contact-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; }
    .contact-card { background: #f8f9fa; border-radius: 12px; padding: 24px; text-align: center; }
    .contact-card h3 { color: ${primary}; margin-bottom: 8px; }
    .rating { font-size: 1.3rem; margin-top: 16px; }
    .cta { background: ${primary}; color: white; border: none; padding: 16px 32px; font-size: 1.1rem; border-radius: 8px; cursor: pointer; margin-top: 24px; }
    .cta:hover { opacity: 0.9; }
    .footer { background: #1a1a2e; color: white; padding: 40px 20px; text-align: center; }
    .footer p { opacity: 0.7; font-size: 0.9rem; }
    .badge { background: rgba(255,255,255,0.15); display: inline-block; padding: 8px 16px; border-radius: 20px; margin-top: 16px; font-size: 0.85rem; }
  </style>
</head>
<body>
  <div class="hero">
    <h1>${business.name}</h1>
    <p>${business.address || ''}</p>
    ${rating}
    <span class="badge">Demo created by LeadForge</span>
  </div>
  <div class="section">
    <h2>Contact Us</h2>
    <div class="contact-grid">
      ${business.phone ? `<div class="contact-card"><h3>📞 Phone</h3><p>${business.phone}</p></div>` : ''}
      ${business.address ? `<div class="contact-card"><h3>📍 Address</h3><p>${business.address}</p></div>` : ''}
      ${business.website ? `<div class="contact-card"><h3>🌐 Website</h3><p>${business.website}</p></div>` : ''}
    </div>
    ${hours}
  </div>
  <div class="section">
    <h2>Why Choose Us?</h2>
    <p>We are a trusted local business dedicated to providing exceptional service to our community. With a strong reputation and years of experience, we look forward to serving you.</p>
    <button class="cta" onclick="alert('This is a demo website created by LeadForge')">Get in Touch</button>
  </div>
  <div class="footer">
    <p>Demo website — Created with LeadForge</p>
  </div>
</body>
</html>`
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Auth
    const authHeader = req.headers.get('Authorization')!
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 2. Check limits
    const { data: profile } = await supabase
      .from('profiles')
      .select('subscription_tier, demos_this_month')
      .eq('id', user.id)
      .single()

    if (profile.subscription_tier === 'free' && profile.demos_this_month >= 1) {
      return new Response(JSON.stringify({ error: 'Free tier demo limit reached' }), {
        status: 402, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 3. Get business and request data
    const { business_id, template } = await req.json()
    const { data: business } = await supabase
      .from('businesses')
      .select('*')
      .eq('id', business_id)
      .eq('user_id', user.id)
      .single()

    if (!business) {
      return new Response(JSON.stringify({ error: 'Business not found' }), {
        status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 4. Generate HTML
    const html = generateDemoHTML(business, template)
    const slug = generateSlug()
    const storagePath = `demos/${user.id}/${slug}.html`

    // 5. Upload to Storage
    const { error: uploadError } = await supabase.storage
      .from('demos')
      .upload(storagePath, new Blob([html], { type: 'text/html' }), {
        contentType: 'text/html',
        upsert: true,
      })

    if (uploadError) {
      throw new Error(`Storage upload failed: ${uploadError.message}`)
    }

    // 6. Create demo record
    const { data: demo, error: insertError } = await supabase
      .from('demos')
      .insert({
        business_id,
        user_id: user.id,
        template,
        storage_path: storagePath,
        public_slug: slug,
        business_data: {
          name: business.name,
          address: business.address,
          phone: business.phone,
          website: business.website,
          rating: business.rating,
          reviews_count: business.reviews_count,
        },
      })
      .select()
      .single()

    if (insertError) {
      throw new Error(`Demo insert failed: ${insertError.message}`)
    }

    // 7. Update business status
    await supabase
      .from('businesses')
      .update({ status: 'demo_created', updated_at: new Date().toISOString() })
      .eq('id', business_id)

    // 8. Increment usage
    await supabase
      .from('profiles')
      .update({ demos_this_month: profile.demos_this_month + 1 })
      .eq('id', user.id)

    return new Response(JSON.stringify({ demo }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})
```

- [ ] **Step 2: Commit**

```bash
git add supabase/functions/build-demo/index.ts
git commit -m "feat: add build-demo edge function with HTML generation and storage"
```

---

### Task 3: Create `outreach` Edge Function

**Files:**
- Create: `supabase/functions/outreach/index.ts`

**Context:** The Flutter `OutreachService` sends `POST { business_id, channel, tone, language, demo_url? }` and expects the function to generate an AI outreach message, save it to the `messages` table, and return success. This is a Pro-only feature.

- [ ] **Step 1: Create the outreach edge function**

```typescript
// supabase/functions/outreach/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const channelInstructions: Record<string, string> = {
  email: 'Write a professional email with subject line, greeting, body, and sign-off. Keep it under 200 words.',
  whatsapp: 'Write a concise WhatsApp message. Friendly but professional. Keep it under 100 words. No subject line needed.',
  instagram: 'Write a short Instagram DM. Casual and friendly. Keep it under 80 words. Use 1-2 relevant emojis.',
  phone: 'Write a phone call script with an opener, key talking points, and a closing. Keep it natural and conversational.',
  other: 'Write a brief professional outreach message. Keep it under 150 words.',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Auth
    const authHeader = req.headers.get('Authorization')!
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 2. Pro-only check
    const { data: profile } = await supabase
      .from('profiles')
      .select('subscription_tier, display_name, business_name')
      .eq('id', user.id)
      .single()

    if (profile.subscription_tier !== 'pro') {
      return new Response(JSON.stringify({ error: 'Outreach requires Pro subscription' }), {
        status: 402, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 3. Get request data and business
    const { business_id, channel, tone, language, demo_url } = await req.json()

    const { data: business } = await supabase
      .from('businesses')
      .select('*')
      .eq('id', business_id)
      .eq('user_id', user.id)
      .single()

    if (!business) {
      return new Response(JSON.stringify({ error: 'Business not found' }), {
        status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 4. Generate message via OpenAI
    const openaiKey = Deno.env.get('OPENAI_API_KEY')
    const channelGuide = channelInstructions[channel] || channelInstructions.other

    const prompt = `You are a sales outreach expert helping a web agency reach out to local businesses.

Agency: ${profile.business_name || 'Our Agency'}
Agent name: ${profile.display_name || 'Sales Representative'}

Target business: ${business.name}
Address: ${business.address || 'Unknown'}
Industry: ${(business.categories || []).join(', ') || 'Local Business'}
Current website: ${business.website || 'None'}
Rating: ${business.rating || 'N/A'}/5 (${business.reviews_count || 0} reviews)
${business.audit_score != null ? `Audit score: ${business.audit_score}/100 - ${business.audit_diagnosis || ''}` : ''}
${demo_url ? `Demo website we built for them: ${demo_url}` : ''}

Channel: ${channel}
Tone: ${tone}
Language: ${language === 'es' ? 'Spanish' : 'English'}

${channelGuide}

Write the outreach message now. Output ONLY the message text, nothing else.`

    const aiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.7,
      }),
    })

    const aiData = await aiResponse.json()
    const messageContent = aiData.choices[0].message.content.trim()

    // 5. Save message to database
    const { data: message, error: insertError } = await supabase
      .from('messages')
      .insert({
        business_id,
        user_id: user.id,
        channel,
        tone,
        language: language || 'en',
        content: messageContent,
      })
      .select()
      .single()

    if (insertError) {
      throw new Error(`Message insert failed: ${insertError.message}`)
    }

    // 6. Update business status if still at demo_created
    if (['found', 'audited', 'demo_created'].includes(business.status)) {
      await supabase
        .from('businesses')
        .update({ status: 'contacted', updated_at: new Date().toISOString() })
        .eq('id', business_id)
    }

    return new Response(JSON.stringify({ message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})
```

- [ ] **Step 2: Commit**

```bash
git add supabase/functions/outreach/index.ts
git commit -m "feat: add outreach edge function with AI message generation"
```

---

## Chunk 2: Flutter Fixes

### Task 4: Fix demo URL placeholder and implement stub functions

**Files:**
- Modify: `lib/models/demo.dart:32` — Fix hardcoded `YOUR_SUPABASE_URL`
- Modify: `lib/screens/build/build_demo_screen.dart:125-128` — Implement `_shareDemo()`
- Modify: `lib/screens/build/build_demo_screen.dart:516-518` — Implement "Open" button

- [ ] **Step 1: Fix demo URL to use AppConstants**

In `lib/models/demo.dart`, change line 32 from:
```dart
String get publicUrl => 'https://YOUR_SUPABASE_URL/functions/v1/demo/$publicSlug';
```
to:
```dart
String get publicUrl => '${AppConstants.supabaseUrl}/functions/v1/demo/$publicSlug';
```

Add import at top:
```dart
import '../config/constants.dart';
```

- [ ] **Step 2: Implement _shareDemo() in build_demo_screen.dart**

Replace the empty `_shareDemo()` method (line 125-128) with:
```dart
void _shareDemo() {
  if (_generatedDemo == null) return;
  Haptics.light();
  Share.share(
    'Check out this demo website I built for you: ${_generatedDemo!.publicUrl}',
    subject: 'Demo Website',
  );
}
```

Add import at top:
```dart
import 'package:share_plus/share_plus.dart';
```

- [ ] **Step 3: Implement "Open" button with url_launcher**

Replace the empty onPressed in the "Open" button (line 516-518):
```dart
onPressed: () {
  // Open in browser
},
```
with:
```dart
onPressed: () {
  launchUrl(Uri.parse(demo.publicUrl), mode: LaunchMode.externalApplication);
},
```

Add import at top:
```dart
import 'package:url_launcher/url_launcher.dart';
```

- [ ] **Step 4: Commit**

```bash
git add lib/models/demo.dart lib/screens/build/build_demo_screen.dart
git commit -m "fix: implement demo URL, share, and open browser functionality"
```

---

### Task 5: Fix memory leak in auth_provider.dart

**Files:**
- Modify: `lib/providers/auth_provider.dart:38-48` — Store and cancel stream subscription

- [ ] **Step 1: Add StreamSubscription field and cancel in dispose**

Add field to `AuthNotifier`:
```dart
import 'dart:async';
// ...
class AuthNotifier extends StateNotifier<AuthState> {
  StreamSubscription<AuthState>? _authSubscription;

  AuthNotifier() : super(AuthState(isLoading: true)) {
    _init();
  }
```

In `_init()`, store the subscription:
```dart
void _init() {
  _authSubscription = SupabaseService.authStateChanges.listen((data) {
    // ... existing code
  });
  // ... rest of init
}
```

Override dispose:
```dart
@override
void dispose() {
  _authSubscription?.cancel();
  super.dispose();
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/providers/auth_provider.dart
git commit -m "fix: cancel auth stream subscription to prevent memory leak"
```

---

### Task 6: Remove hardcoded API keys from source code

**Files:**
- Modify: `lib/config/constants.dart:4-12` — Remove hardcoded defaults

- [ ] **Step 1: Remove default values from constants**

Change the Supabase config to empty defaults (requiring `--dart-define` at build time):
```dart
static const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '',
);

static const supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: '',
);
```

- [ ] **Step 2: Create `.env.example` file with instructions**

Create `env.example`:
```
# Copy to .env and fill in your values
# Run with: flutter run --dart-define-from-file=.env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
REVENUECAT_API_KEY=your-revenuecat-key-here
GOOGLE_PLACES_API_KEY=your-google-places-key-here
OPENAI_API_KEY=your-openai-key-here
```

- [ ] **Step 3: Create `.env` with real values (gitignored)**

Create `.env` with the actual Supabase credentials (this file should be in .gitignore):
```
SUPABASE_URL=https://dnedrbflhrpodymdjicp.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRuZWRyYmZsaHJwb2R5bWRqaWNwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMxMDA5MTAsImV4cCI6MjA4ODY3NjkxMH0.9k6cNlpa3_xTZxW6kpmzeIAFlw7NxdmnTIBUrmuQ1m0
REVENUECAT_API_KEY=YOUR_REVENUECAT_KEY
```

- [ ] **Step 4: Add `.env` to .gitignore**

Append to `.gitignore`:
```
.env
```

- [ ] **Step 5: Commit**

```bash
git add lib/config/constants.dart env.example .gitignore
git commit -m "security: move API keys to environment variables, add env.example"
```

---

## Supabase Setup Requirements

Before deploying the edge functions, ensure these are configured in Supabase Dashboard → Settings → Edge Functions → Secrets:

| Secret | Purpose |
|--------|---------|
| `OPENAI_API_KEY` | OpenAI API key for audit and outreach AI |
| `GOOGLE_PLACES_API_KEY` | Already used by scout function |

Also create a Storage bucket named `demos` with public access for the demo HTML files.

## Deploy Commands

```bash
# Deploy all edge functions
supabase functions deploy audit
supabase functions deploy build-demo
supabase functions deploy outreach

# Or deploy all at once
supabase functions deploy
```
