# Template System v1 — Design Spec

## Problem

The current `build-demo` edge function asks `gpt-4o-mini` to generate entire HTML pages (~14K chars, ~10K tokens). The results are visually inconsistent, slow (15-20s), expensive, and often ugly — a dealbreaker for an app whose value proposition is showing prospects what a professional website looks like.

## Solution

Replace AI-generated HTML with 6 handcrafted HTML/CSS templates. The AI's role shrinks to generating a small JSON payload (~300 tokens) containing copy and a color palette. The template engine merges the two into a polished, consistent demo site.

## Templates

Six templates, each mapped to business categories via the existing `pickStyleForBusiness()` function:

| # | Name | Font Stack | Target Categories |
|---|------|-----------|-------------------|
| 1 | Warm Organic (Rustic Elegance) | Fraunces + Josefin Sans | Restaurants, cafes, bakeries, food |
| 2 | Soft Glassmorphism | DM Sans | Salons, spas, clinics, wellness |
| 3 | Editorial Luxury | Playfair Display + Inter | Law, finance, real estate, consulting |
| 4 | Bold Modern | Space Grotesk + Inter | Auto, construction, plumbing, trades |
| 5 | Fresh Startup | Outfit | Tech, agencies, marketing, creative |
| 6 | Dark Premium | Cormorant Garamond + Inter | Fine dining, hotels, lounges, boutique |

### Template Structure (same for all 6)

Each template is a complete HTML document with 6 sections:

1. **Hero** — Full viewport or near-full. Business name as headline, AI tagline as subheadline, primary CTA button. Unsplash hero image where applicable.
2. **Services/Menu** — Card grid (4-6 items). Each card: service/menu item name + short description.
3. **About** — 2-3 sentence paragraph about the business, what makes them unique.
4. **Why Choose Us / Hours** — 3 bullet points (why us) OR opening hours grid if hours data is available.
5. **Contact + CTA** — Phone (clickable tel: link), address, prominent CTA button.
6. **Footer** — Business name + "Powered by LeadForge".

### Template Technical Requirements

- Standalone HTML document, all CSS inline in `<style>` tag
- Google Fonts loaded via `@import`
- CSS custom properties for palette injection: `--clr-primary`, `--clr-secondary`, `--clr-accent`, `--clr-bg`, `--clr-surface`, `--clr-text`, `--clr-muted`
- Mobile-first responsive: base mobile, `@media (min-width: 768px)` tablet, `@media (min-width: 1024px)` desktop
- Smooth transitions on interactive elements (0.3s ease)
- Phone as clickable `<a href="tel:...">`
- Max ~8KB per template before content injection
- Placeholder tokens: `{{headline}}`, `{{subheadline}}`, `{{services}}`, `{{about}}`, `{{why_us}}`, `{{hours}}`, `{{cta_text}}`, `{{business_name}}`, `{{business_phone}}`, `{{business_address}}`, `{{business_website}}`, `{{hero_image}}`, `{{section_image}}`

## AI Content Generation

### Model

`gpt-4o-mini` — sufficient for copywriting, fast, cheap.

### Prompt

The AI receives business data (name, categories, address, phone, website, rating, reviews, scraped website content, audit diagnosis) and returns a single JSON object.

### AI Output Schema

```json
{
  "headline": "string — powerful tagline, 3-8 words",
  "subheadline": "string — supporting line, 10-20 words",
  "services": [
    { "name": "string", "desc": "string — 8-15 words" }
  ],
  "about": "string — 2-3 sentences about the business",
  "why_us": ["string", "string", "string"],
  "cta_text": "string — CTA button label, 2-4 words",
  "palette": {
    "primary": "#hex — main brand color",
    "secondary": "#hex — background/surface",
    "accent": "#hex — CTA/highlight color",
    "bg": "#hex — page background",
    "surface": "#hex — card/section background",
    "text": "#hex — main text color",
    "muted": "#hex — secondary text color"
  }
}
```

The AI must respond with `response_format: { type: "json_object" }`. Expected token usage: ~200 input, ~300 output.

### Language Detection

Reuse existing `detectLanguage()` function. The AI prompt instructs it to write all copy in the detected language.

### Website Scraping

Reuse existing `scrapeBusinessWebsite()` function. Scraped content (real menu items, services, descriptions) is passed to the AI so it generates authentic copy rather than generic placeholder text.

## Image Strategy

### Unsplash Integration

Reuse existing `fetchUnsplashImages()` function. Images are injected into template placeholders:

- `{{hero_image}}` — first Unsplash result, used as hero background
- `{{section_image}}` — second result, used in about/services section

If Unsplash is unavailable or returns no results, templates fall back to CSS-only hero (gradient/solid color). Templates must look good with AND without images.

## Edge Function Flow

Updated flow for `build-demo/index.ts`:

1. Auth + limit checks (unchanged)
2. Fetch business data (unchanged)
3. `pickStyleForBusiness()` selects template name (updated to match new 6 templates)
4. `detectLanguage()` determines output language
5. Parallel: `scrapeBusinessWebsite()` + `fetchUnsplashImages()`
6. AI call: send business data + scraped content, receive JSON copy + palette (~3-5s)
7. Select template HTML string by template name
8. Replace placeholder tokens with AI content, palette CSS vars, business data, images
9. Upload to storage, create demo record (unchanged)
10. Return demo (unchanged)

### Template Storage

Templates are stored as string constants in a separate file imported by the edge function:

```
supabase/functions/build-demo/
  index.ts           — main handler (simplified)
  templates.ts       — exports 6 template HTML strings
  template-engine.ts — placeholder replacement logic
```

### Fallback

If the AI call fails, use business data directly for placeholders (business name as headline, categories as services, address as contact) with a default neutral palette. The template still renders — just with less polished copy.

## Files Changed

### Modified
- `supabase/functions/build-demo/index.ts` — simplified: remove `generateUniqueHTML()`, use template engine instead
- `supabase/functions/build-demo/templates.ts` — NEW: 6 template HTML strings
- `supabase/functions/build-demo/template-engine.ts` — NEW: placeholder replacement + palette injection

### Unchanged
- `lib/services/build_service.dart` — no changes needed
- `lib/screens/build/build_demo_screen.dart` — no changes needed
- `supabase/functions/demo/index.ts` — no changes needed
- `lib/models/demo.dart` — no changes needed

### Database
- The `template` column CHECK constraint in `demos` table currently allows: `'restaurant', 'professional', 'health_beauty'`. This needs updating to match the 6 new template names: `'warm_organic', 'soft_glass', 'editorial_luxury', 'bold_modern', 'fresh_startup', 'dark_premium'`.
- Migration: `ALTER TABLE demos DROP CONSTRAINT demos_template_check; ALTER TABLE demos ADD CONSTRAINT demos_template_check CHECK (template IN ('restaurant', 'professional', 'health_beauty', 'warm_organic', 'soft_glass', 'editorial_luxury', 'bold_modern', 'fresh_startup', 'dark_premium'));`
- Keep old values in the CHECK for backward compatibility with existing demos.

### Flutter Model
- Add new enum values to `DemoTemplate` in `lib/models/demo.dart` for the 6 new templates. Keep old values for backward compatibility.

## Performance Comparison

| Metric | Current | Template System |
|--------|---------|----------------|
| AI tokens (output) | ~10,000 | ~300 |
| AI tokens (input) | ~2,000 | ~500 |
| Response time | 15-20s | 3-5s |
| Cost per demo | ~$0.015 | ~$0.001 |
| Visual quality | Inconsistent | Consistently professional |
| Failure mode | Ugly/broken HTML | Good template with generic copy |

## Out of Scope (v1)

- Custom template uploads by users
- Template preview/selection in the app UI (auto-selected by category)
- A/B testing of templates
- Analytics on which templates convert better
- Template editing in a dashboard
