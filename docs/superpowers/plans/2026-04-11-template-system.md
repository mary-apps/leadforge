# Template System v1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace AI-generated HTML with 6 handcrafted templates + AI copy/palette injection for consistently professional demo sites.

**Architecture:** Templates are stored as TypeScript string functions in `templates.ts`. A template engine in `template-engine.ts` merges AI-generated JSON (copy + color palette) with the selected template. The main `index.ts` is simplified to orchestrate the flow.

**Tech Stack:** Deno (Supabase Edge Functions), OpenAI gpt-4o-mini, TypeScript, HTML/CSS, Flutter/Dart

**Spec:** `docs/superpowers/specs/2026-04-11-template-system-design.md`

---

### Task 1: Create template-engine.ts

**Files:**
- Create: `supabase/functions/build-demo/template-engine.ts`

This module takes a template HTML string, AI-generated content JSON, and business data, then returns a complete HTML page with all placeholders replaced.

- [ ] **Step 1: Create the template engine file**

```typescript
// supabase/functions/build-demo/template-engine.ts

export interface AiContent {
  headline: string
  subheadline: string
  services: { name: string; desc: string }[]
  about: string
  why_us: string[]
  cta_text: string
  palette: {
    primary: string
    secondary: string
    accent: string
    bg: string
    surface: string
    text: string
    muted: string
  }
}

export interface BusinessData {
  name: string
  address: string | null
  phone: string | null
  website: string | null
  rating: number | null
  reviews_count: number
  categories: string[]
  opening_hours: any | null
  audit_score: number | null
  audit_diagnosis: string | null
}

/**
 * Build a services/menu HTML block from the AI-generated items.
 * Each template calls this and wraps the result in its own styled container.
 */
function buildServicesHtml(services: AiContent['services']): string {
  return services
    .slice(0, 6)
    .map(
      (s) => `<div class="service-card">
        <h3>${escapeHtml(s.name)}</h3>
        <p>${escapeHtml(s.desc)}</p>
      </div>`
    )
    .join('\n')
}

/**
 * Build "Why Choose Us" bullets OR opening hours grid.
 */
function buildWhyOrHoursHtml(whyUs: string[], hours: any | null): string {
  if (hours && Array.isArray(hours) && hours.length > 0) {
    const rows = hours
      .map((h: string) => {
        const parts = h.split(': ')
        return `<div class="hours-row"><span class="hours-day">${escapeHtml(parts[0] || '')}</span><span class="hours-time">${escapeHtml(parts[1] || '')}</span></div>`
      })
      .join('\n')
    return `<div class="hours-grid">${rows}</div>`
  }
  return whyUs
    .slice(0, 3)
    .map((item) => `<div class="why-item"><span class="why-icon">&#10003;</span><span>${escapeHtml(item)}</span></div>`)
    .join('\n')
}

/**
 * Build star rating HTML if rating >= 3.5
 */
function buildRatingHtml(rating: number | null, reviewsCount: number): string {
  if (!rating || rating < 3.5) return ''
  const fullStars = Math.floor(rating)
  const stars = '★'.repeat(fullStars) + (rating % 1 >= 0.5 ? '½' : '')
  return `<div class="rating">${stars} <span class="rating-text">${rating}/5 (${reviewsCount} reviews)</span></div>`
}

function escapeHtml(str: string): string {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
}

/**
 * Merge template HTML with AI content, business data, and images.
 */
export function renderTemplate(
  templateHtml: string,
  content: AiContent,
  business: BusinessData,
  images: string[]
): string {
  const servicesHtml = buildServicesHtml(content.services)
  const whyOrHoursHtml = buildWhyOrHoursHtml(content.why_us, business.opening_hours)
  const ratingHtml = buildRatingHtml(business.rating, business.reviews_count)
  const phoneLink = business.phone
    ? `<a href="tel:${business.phone}" class="phone-link">${escapeHtml(business.phone)}</a>`
    : ''

  let html = templateHtml
    // CSS custom properties (palette)
    .replace(/\{\{clr-primary\}\}/g, content.palette.primary)
    .replace(/\{\{clr-secondary\}\}/g, content.palette.secondary)
    .replace(/\{\{clr-accent\}\}/g, content.palette.accent)
    .replace(/\{\{clr-bg\}\}/g, content.palette.bg)
    .replace(/\{\{clr-surface\}\}/g, content.palette.surface)
    .replace(/\{\{clr-text\}\}/g, content.palette.text)
    .replace(/\{\{clr-muted\}\}/g, content.palette.muted)
    // AI-generated copy
    .replace(/\{\{headline\}\}/g, escapeHtml(content.headline))
    .replace(/\{\{subheadline\}\}/g, escapeHtml(content.subheadline))
    .replace(/\{\{services\}\}/g, servicesHtml)
    .replace(/\{\{about\}\}/g, escapeHtml(content.about))
    .replace(/\{\{why_or_hours\}\}/g, whyOrHoursHtml)
    .replace(/\{\{cta_text\}\}/g, escapeHtml(content.cta_text))
    // Business data
    .replace(/\{\{business_name\}\}/g, escapeHtml(business.name))
    .replace(/\{\{business_phone\}\}/g, phoneLink)
    .replace(/\{\{business_phone_raw\}\}/g, business.phone || '')
    .replace(/\{\{business_address\}\}/g, escapeHtml(business.address || ''))
    .replace(/\{\{business_website\}\}/g, escapeHtml(business.website || ''))
    .replace(/\{\{rating\}\}/g, ratingHtml)
    // Images
    .replace(/\{\{hero_image\}\}/g, images[0] || '')
    .replace(/\{\{section_image\}\}/g, images[1] || '')

  // Remove image sections if no images available
  if (!images[0]) {
    html = html.replace(/\{\{#has_hero_image\}\}[\s\S]*?\{\{\/has_hero_image\}\}/g, '')
  } else {
    html = html.replace(/\{\{#has_hero_image\}\}/g, '').replace(/\{\{\/has_hero_image\}\}/g, '')
  }

  return html
}

/**
 * Build fallback AiContent from raw business data when AI call fails.
 */
export function fallbackContent(business: BusinessData, language: string): AiContent {
  const isSpanish = language === 'Spanish'
  const cats = business.categories.slice(0, 4)
  return {
    headline: business.name,
    subheadline: business.address || (isSpanish ? 'Bienvenidos' : 'Welcome'),
    services: cats.map((c) => ({
      name: c,
      desc: isSpanish ? 'Servicio profesional de calidad' : 'Quality professional service',
    })),
    about: isSpanish
      ? `${business.name} ofrece servicios profesionales de la más alta calidad. Contáctanos para más información.`
      : `${business.name} offers top-quality professional services. Contact us to learn more.`,
    why_us: isSpanish
      ? ['Experiencia comprobada', 'Atención personalizada', 'Calidad garantizada']
      : ['Proven experience', 'Personalized attention', 'Quality guaranteed'],
    cta_text: isSpanish ? 'Contáctanos' : 'Contact Us',
    palette: {
      primary: '#1a1a2e',
      secondary: '#f8f8f8',
      accent: '#4a6cf7',
      bg: '#ffffff',
      surface: '#f4f4f5',
      text: '#1a1a2e',
      muted: '#71717a',
    },
  }
}
```

- [ ] **Step 2: Verify the file is valid TypeScript**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && head -5 supabase/functions/build-demo/template-engine.ts`
Expected: The file exists and starts with the export interface.

- [ ] **Step 3: Commit**

```bash
git add supabase/functions/build-demo/template-engine.ts
git commit -m "feat(build-demo): add template engine with placeholder replacement"
```

---

### Task 2: Create templates.ts — Warm Organic (Rustic Elegance)

**Files:**
- Create: `supabase/functions/build-demo/templates.ts`

Start the templates file with the first template. Each template is a function that returns an HTML string. Using functions (not raw strings) lets us keep the file readable.

- [ ] **Step 1: Create templates.ts with the Warm Organic template**

```typescript
// supabase/functions/build-demo/templates.ts

// ─────────────────────────────────────────────
// 1. WARM ORGANIC (Rustic Elegance)
// Target: Restaurants, cafes, bakeries, food
// Fonts: Fraunces + Josefin Sans
// ─────────────────────────────────────────────
export function warmOrganic(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{business_name}}</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Fraunces:wght@400;600;700;900&family=Josefin+Sans:wght@300;400;600;700&display=swap');
:root {
  --clr-primary: {{clr-primary}};
  --clr-secondary: {{clr-secondary}};
  --clr-accent: {{clr-accent}};
  --clr-bg: {{clr-bg}};
  --clr-surface: {{clr-surface}};
  --clr-text: {{clr-text}};
  --clr-muted: {{clr-muted}};
}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Josefin Sans',sans-serif;color:var(--clr-text);background:var(--clr-bg);line-height:1.6;-webkit-font-smoothing:antialiased}
a{color:inherit;text-decoration:none}

/* Hero */
.hero{position:relative;min-height:100vh;display:flex;align-items:flex-end;overflow:hidden}
.hero-bg{position:absolute;inset:0;background:var(--clr-primary)}
{{#has_hero_image}}.hero-bg{background:url('{{hero_image}}') center/cover no-repeat}{{/has_hero_image}}
.hero-overlay{position:absolute;inset:0;background:linear-gradient(to top,rgba(0,0,0,0.85) 0%,rgba(0,0,0,0.3) 50%,rgba(0,0,0,0.1) 100%)}
.hero-content{position:relative;z-index:1;padding:60px 24px;width:100%;max-width:900px;margin:0 auto;color:#f0e6d2}
.hero-overline{font-size:11px;letter-spacing:4px;text-transform:uppercase;color:var(--clr-accent);margin-bottom:16px}
.hero h1{font-family:'Fraunces',serif;font-size:clamp(2.2rem,6vw,4rem);font-weight:900;line-height:1.05;margin-bottom:12px}
.hero .subtitle{font-size:clamp(0.9rem,2vw,1.1rem);opacity:0.7;margin-bottom:24px;font-weight:300}
.hero .rating{margin-bottom:20px;font-size:14px;color:var(--clr-accent)}
.hero .rating .rating-text{opacity:0.6;margin-left:4px}
.hero .cta-btn{display:inline-block;padding:12px 32px;background:var(--clr-accent);color:var(--clr-bg);font-family:'Josefin Sans',sans-serif;font-size:13px;font-weight:600;letter-spacing:1.5px;text-transform:uppercase;border-radius:2px;transition:transform 0.3s,box-shadow 0.3s}
.hero .cta-btn:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(0,0,0,0.3)}

/* Sections */
.section{padding:80px 24px;max-width:900px;margin:0 auto}
.section-label{font-size:11px;letter-spacing:4px;text-transform:uppercase;color:var(--clr-accent);margin-bottom:12px}
.section h2{font-family:'Fraunces',serif;font-size:clamp(1.6rem,4vw,2.4rem);font-weight:700;margin-bottom:24px;color:var(--clr-primary)}

/* Services */
.services-bg{background:var(--clr-surface)}
.services-grid{display:grid;grid-template-columns:1fr;gap:16px}
@media(min-width:768px){.services-grid{grid-template-columns:1fr 1fr}}
.service-card{background:var(--clr-bg);border-radius:12px;padding:24px;border:1px solid color-mix(in srgb,var(--clr-primary) 10%,transparent);transition:transform 0.3s,box-shadow 0.3s}
.service-card:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(0,0,0,0.08)}
.service-card h3{font-family:'Fraunces',serif;font-size:1.1rem;font-weight:700;margin-bottom:6px;color:var(--clr-primary)}
.service-card p{font-size:0.85rem;color:var(--clr-muted);line-height:1.5}

/* About */
.about p{font-size:1.05rem;line-height:1.8;color:var(--clr-muted);max-width:680px}

/* Why / Hours */
.why-item{display:flex;align-items:flex-start;gap:12px;padding:12px 0;border-bottom:1px solid color-mix(in srgb,var(--clr-primary) 8%,transparent)}
.why-icon{color:var(--clr-accent);font-size:1.1rem;flex-shrink:0;margin-top:2px}
.hours-grid{display:grid;gap:8px;max-width:400px}
.hours-row{display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid color-mix(in srgb,var(--clr-primary) 8%,transparent);font-size:0.9rem}
.hours-day{font-weight:600}
.hours-time{color:var(--clr-muted)}

/* Contact */
.contact-bg{background:var(--clr-primary);color:var(--clr-secondary)}
.contact-bg .section-label{color:var(--clr-accent)}
.contact-bg h2{color:var(--clr-secondary)}
.contact-grid{display:grid;grid-template-columns:1fr;gap:20px;margin-bottom:32px}
@media(min-width:768px){.contact-grid{grid-template-columns:1fr 1fr 1fr}}
.contact-item{font-size:0.95rem}
.contact-item .label{font-size:11px;letter-spacing:2px;text-transform:uppercase;color:var(--clr-accent);margin-bottom:6px}
.phone-link{color:var(--clr-secondary);transition:color 0.3s}
.phone-link:hover{color:var(--clr-accent)}
.contact-bg .cta-btn{display:inline-block;padding:14px 40px;background:var(--clr-accent);color:var(--clr-bg);font-family:'Josefin Sans',sans-serif;font-size:13px;font-weight:600;letter-spacing:1.5px;text-transform:uppercase;border-radius:2px;transition:transform 0.3s,box-shadow 0.3s}
.contact-bg .cta-btn:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(0,0,0,0.3)}

/* Footer */
.footer{background:color-mix(in srgb,var(--clr-primary) 90%,black);padding:24px;text-align:center;color:var(--clr-muted);font-size:0.75rem}
</style>
</head>
<body>
  <section class="hero">
    <div class="hero-bg"></div>
    <div class="hero-overlay"></div>
    <div class="hero-content">
      <div class="hero-overline">{{business_address}}</div>
      <h1>{{headline}}</h1>
      <p class="subtitle">{{subheadline}}</p>
      {{rating}}
      <a href="tel:{{business_phone_raw}}" class="cta-btn">{{cta_text}}</a>
    </div>
  </section>

  <section class="services-bg">
    <div class="section">
      <div class="section-label">Menu</div>
      <h2>{{business_name}}</h2>
      <div class="services-grid">{{services}}</div>
    </div>
  </section>

  <section class="section about">
    <div class="section-label">About</div>
    <h2>Our Story</h2>
    <p>{{about}}</p>
  </section>

  <section class="services-bg">
    <div class="section">
      <div class="section-label">Info</div>
      <h2>Why Choose Us</h2>
      {{why_or_hours}}
    </div>
  </section>

  <section class="contact-bg">
    <div class="section">
      <div class="section-label">Contact</div>
      <h2>Get in Touch</h2>
      <div class="contact-grid">
        <div class="contact-item"><div class="label">Phone</div>{{business_phone}}</div>
        <div class="contact-item"><div class="label">Address</div>{{business_address}}</div>
        <div class="contact-item"><div class="label">Website</div>{{business_website}}</div>
      </div>
      <a href="tel:{{business_phone_raw}}" class="cta-btn">{{cta_text}}</a>
    </div>
  </section>

  <footer class="footer">
    <p>{{business_name}} &bull; Powered by LeadForge</p>
  </footer>
</body>
</html>`
}
```

- [ ] **Step 2: Commit**

```bash
git add supabase/functions/build-demo/templates.ts
git commit -m "feat(build-demo): add Warm Organic template"
```

---

### Task 3: Add remaining 5 templates to templates.ts

**Files:**
- Modify: `supabase/functions/build-demo/templates.ts`

Append 5 more exported functions to `templates.ts`. Each follows the same section structure (hero, services, about, why/hours, contact, footer) but with unique visual design, font stacks, and layout approaches.

- [ ] **Step 1: Add Soft Glassmorphism template**

Append to `templates.ts`:

```typescript
// ─────────────────────────────────────────────
// 2. SOFT GLASSMORPHISM
// Target: Salons, spas, clinics, wellness
// Fonts: DM Sans
// ─────────────────────────────────────────────
export function softGlass(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{business_name}}</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&display=swap');
:root{--clr-primary:{{clr-primary}};--clr-secondary:{{clr-secondary}};--clr-accent:{{clr-accent}};--clr-bg:{{clr-bg}};--clr-surface:{{clr-surface}};--clr-text:{{clr-text}};--clr-muted:{{clr-muted}}}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'DM Sans',sans-serif;color:var(--clr-text);background:var(--clr-bg);line-height:1.6;-webkit-font-smoothing:antialiased}
a{color:inherit;text-decoration:none}

.hero{min-height:100vh;background:linear-gradient(135deg,var(--clr-secondary),var(--clr-primary));display:flex;align-items:center;justify-content:center;text-align:center;padding:40px 24px}
.glass-card{background:rgba(255,255,255,0.2);backdrop-filter:blur(24px);-webkit-backdrop-filter:blur(24px);border:1px solid rgba(255,255,255,0.35);border-radius:28px;padding:48px 40px;max-width:560px;width:100%}
.hero h1{font-size:clamp(2rem,5vw,3.2rem);font-weight:700;margin-bottom:10px;color:var(--clr-text)}
.hero .subtitle{font-size:clamp(0.9rem,2vw,1.05rem);color:var(--clr-muted);margin-bottom:8px}
.hero .rating{font-size:14px;color:var(--clr-accent);margin-bottom:24px}
.hero .rating .rating-text{opacity:0.6;margin-left:4px}
.cta-btn{display:inline-block;padding:14px 36px;background:var(--clr-accent);color:#fff;font-weight:600;font-size:14px;border-radius:28px;transition:transform 0.3s,box-shadow 0.3s}
.cta-btn:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(0,0,0,0.15)}

.section{padding:80px 24px;max-width:900px;margin:0 auto}
.section-label{font-size:11px;letter-spacing:3px;text-transform:uppercase;color:var(--clr-accent);margin-bottom:12px;font-weight:500}
.section h2{font-size:clamp(1.5rem,4vw,2.2rem);font-weight:700;margin-bottom:24px}

.services-grid{display:grid;grid-template-columns:1fr;gap:16px}
@media(min-width:768px){.services-grid{grid-template-columns:1fr 1fr}}
.service-card{background:rgba(255,255,255,0.5);backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);border:1px solid rgba(255,255,255,0.4);border-radius:20px;padding:24px;transition:transform 0.3s,box-shadow 0.3s}
.service-card:hover{transform:translateY(-2px);box-shadow:0 12px 32px rgba(0,0,0,0.06)}
.service-card h3{font-size:1.05rem;font-weight:700;margin-bottom:6px}
.service-card p{font-size:0.85rem;color:var(--clr-muted)}

.about-bg{background:linear-gradient(135deg,color-mix(in srgb,var(--clr-secondary) 30%,white),var(--clr-bg))}
.about p{font-size:1.05rem;line-height:1.8;color:var(--clr-muted);max-width:680px}

.why-item{display:flex;align-items:flex-start;gap:12px;padding:14px 0;border-bottom:1px solid color-mix(in srgb,var(--clr-primary) 8%,transparent)}
.why-icon{color:var(--clr-accent);font-size:1.1rem;flex-shrink:0}
.hours-grid{display:grid;gap:8px;max-width:400px}
.hours-row{display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid color-mix(in srgb,var(--clr-primary) 8%,transparent);font-size:0.9rem}
.hours-day{font-weight:600}
.hours-time{color:var(--clr-muted)}

.contact-section{background:var(--clr-primary);color:white;border-radius:28px;max-width:900px;margin:0 auto 60px;padding:48px 32px;text-align:center}
.contact-section .section-label{color:var(--clr-accent)}
.contact-section h2{color:white}
.contact-grid{display:flex;flex-wrap:wrap;justify-content:center;gap:32px;margin-bottom:32px}
.contact-item .label{font-size:11px;letter-spacing:2px;text-transform:uppercase;color:var(--clr-accent);margin-bottom:4px}
.contact-item{font-size:0.95rem}
.phone-link{color:white;transition:color 0.3s}
.phone-link:hover{color:var(--clr-accent)}

.footer{padding:24px;text-align:center;color:var(--clr-muted);font-size:0.75rem}
</style>
</head>
<body>
  <section class="hero">
    <div class="glass-card">
      <h1>{{headline}}</h1>
      <p class="subtitle">{{subheadline}}</p>
      {{rating}}
      <a href="tel:{{business_phone_raw}}" class="cta-btn">{{cta_text}}</a>
    </div>
  </section>
  <section class="section">
    <div class="section-label">Services</div>
    <h2>What We Offer</h2>
    <div class="services-grid">{{services}}</div>
  </section>
  <section class="about-bg"><div class="section about">
    <div class="section-label">About</div>
    <h2>Our Story</h2>
    <p>{{about}}</p>
  </div></section>
  <section class="section">
    <div class="section-label">Info</div>
    <h2>Why Choose Us</h2>
    {{why_or_hours}}
  </section>
  <div class="contact-section">
    <div class="section-label">Contact</div>
    <h2>Let's Connect</h2>
    <div class="contact-grid">
      <div class="contact-item"><div class="label">Phone</div>{{business_phone}}</div>
      <div class="contact-item"><div class="label">Address</div>{{business_address}}</div>
      <div class="contact-item"><div class="label">Website</div>{{business_website}}</div>
    </div>
    <a href="tel:{{business_phone_raw}}" class="cta-btn">{{cta_text}}</a>
  </div>
  <footer class="footer"><p>{{business_name}} &bull; Powered by LeadForge</p></footer>
</body>
</html>`
}
```

- [ ] **Step 2: Add Editorial Luxury template**

Append to `templates.ts`:

```typescript
// ─────────────────────────────────────────────
// 3. EDITORIAL LUXURY
// Target: Law, finance, real estate, consulting
// Fonts: Playfair Display + Inter
// ─────────────────────────────────────────────
export function editorialLuxury(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{business_name}}</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=Inter:wght@300;400;500;600&display=swap');
:root{--clr-primary:{{clr-primary}};--clr-secondary:{{clr-secondary}};--clr-accent:{{clr-accent}};--clr-bg:{{clr-bg}};--clr-surface:{{clr-surface}};--clr-text:{{clr-text}};--clr-muted:{{clr-muted}}}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Inter',sans-serif;color:var(--clr-text);background:var(--clr-bg);line-height:1.6;-webkit-font-smoothing:antialiased}
a{color:inherit;text-decoration:none}

.hero{min-height:100vh;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:60px 24px;background:var(--clr-surface)}
.hero-overline{font-size:11px;letter-spacing:5px;text-transform:uppercase;color:var(--clr-muted);margin-bottom:20px}
.hero h1{font-family:'Playfair Display',serif;font-size:clamp(2.4rem,6vw,4.5rem);font-weight:900;line-height:1.05;letter-spacing:-1px;margin-bottom:12px}
.hero .divider{width:48px;height:1px;background:var(--clr-primary);opacity:0.3;margin:20px auto}
.hero .subtitle{font-size:clamp(0.85rem,1.5vw,1rem);color:var(--clr-muted);font-weight:300;letter-spacing:0.5px;margin-bottom:8px}
.hero .rating{font-size:13px;color:var(--clr-accent);margin-bottom:24px}
.hero .rating .rating-text{opacity:0.6;margin-left:4px}
.cta-btn{display:inline-block;padding:14px 40px;border:1.5px solid var(--clr-primary);color:var(--clr-primary);font-size:11px;font-weight:500;letter-spacing:3px;text-transform:uppercase;transition:all 0.3s}
.cta-btn:hover{background:var(--clr-primary);color:var(--clr-bg)}

.section{padding:80px 24px;max-width:900px;margin:0 auto}
.section-label{font-size:11px;letter-spacing:5px;text-transform:uppercase;color:var(--clr-muted);margin-bottom:12px}
.section h2{font-family:'Playfair Display',serif;font-size:clamp(1.6rem,4vw,2.4rem);font-weight:700;margin-bottom:24px;letter-spacing:-0.5px}
.section-divider{width:100%;height:1px;background:color-mix(in srgb,var(--clr-primary) 10%,transparent)}

.services-grid{display:grid;grid-template-columns:1fr;gap:0}
@media(min-width:768px){.services-grid{grid-template-columns:1fr 1fr}}
.service-card{padding:28px 0;border-bottom:1px solid color-mix(in srgb,var(--clr-primary) 8%,transparent)}
@media(min-width:768px){.service-card{padding:28px 24px}}
.service-card h3{font-family:'Playfair Display',serif;font-size:1.1rem;font-weight:700;margin-bottom:6px}
.service-card p{font-size:0.85rem;color:var(--clr-muted)}

.about p{font-size:1.05rem;line-height:2;color:var(--clr-muted);max-width:680px}

.why-item{display:flex;align-items:flex-start;gap:12px;padding:14px 0;border-bottom:1px solid color-mix(in srgb,var(--clr-primary) 8%,transparent)}
.why-icon{color:var(--clr-accent);font-size:1rem;flex-shrink:0}
.hours-grid{display:grid;gap:8px;max-width:400px}
.hours-row{display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid color-mix(in srgb,var(--clr-primary) 8%,transparent);font-size:0.9rem}
.hours-day{font-weight:500}
.hours-time{color:var(--clr-muted)}

.contact-bg{background:var(--clr-primary);color:var(--clr-secondary)}
.contact-bg .section-label{color:var(--clr-accent)}
.contact-bg h2{color:var(--clr-secondary)}
.contact-grid{display:grid;grid-template-columns:1fr;gap:20px;margin-bottom:32px}
@media(min-width:768px){.contact-grid{grid-template-columns:1fr 1fr 1fr}}
.contact-item .label{font-size:11px;letter-spacing:3px;text-transform:uppercase;color:var(--clr-accent);margin-bottom:6px}
.contact-item{font-size:0.95rem}
.phone-link{color:var(--clr-secondary);transition:color 0.3s}
.phone-link:hover{color:var(--clr-accent)}
.contact-bg .cta-btn{border-color:var(--clr-accent);color:var(--clr-accent)}
.contact-bg .cta-btn:hover{background:var(--clr-accent);color:var(--clr-primary)}

.footer{padding:32px 24px;text-align:center;color:var(--clr-muted);font-size:0.75rem;border-top:1px solid color-mix(in srgb,var(--clr-primary) 10%,transparent)}
</style>
</head>
<body>
  <section class="hero">
    <div class="hero-overline">{{business_address}}</div>
    <div class="divider"></div>
    <h1>{{business_name}}</h1>
    <p class="subtitle">{{subheadline}}</p>
    {{rating}}
    <a href="tel:{{business_phone_raw}}" class="cta-btn">{{cta_text}}</a>
  </section>
  <div class="section-divider"></div>
  <section class="section">
    <div class="section-label">Services</div>
    <h2>{{headline}}</h2>
    <div class="services-grid">{{services}}</div>
  </section>
  <div class="section-divider"></div>
  <section class="section about">
    <div class="section-label">About</div>
    <h2>Our Practice</h2>
    <p>{{about}}</p>
  </section>
  <div class="section-divider"></div>
  <section class="section">
    <div class="section-label">Info</div>
    <h2>Why Choose Us</h2>
    {{why_or_hours}}
  </section>
  <section class="contact-bg"><div class="section">
    <div class="section-label">Contact</div>
    <h2>Schedule a Consultation</h2>
    <div class="contact-grid">
      <div class="contact-item"><div class="label">Phone</div>{{business_phone}}</div>
      <div class="contact-item"><div class="label">Address</div>{{business_address}}</div>
      <div class="contact-item"><div class="label">Website</div>{{business_website}}</div>
    </div>
    <a href="tel:{{business_phone_raw}}" class="cta-btn">{{cta_text}}</a>
  </div></section>
  <footer class="footer"><p>{{business_name}} &bull; Powered by LeadForge</p></footer>
</body>
</html>`
}
```

- [ ] **Step 3: Add Bold Modern template**

Append to `templates.ts`:

```typescript
// ─────────────────────────────────────────────
// 4. BOLD MODERN
// Target: Auto, construction, plumbing, trades
// Fonts: Space Grotesk + Inter
// ─────────────────────────────────────────────
export function boldModern(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{business_name}}</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;600;700&family=Inter:wght@300;400;500;600&display=swap');
:root{--clr-primary:{{clr-primary}};--clr-secondary:{{clr-secondary}};--clr-accent:{{clr-accent}};--clr-bg:{{clr-bg}};--clr-surface:{{clr-surface}};--clr-text:{{clr-text}};--clr-muted:{{clr-muted}}}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Inter',sans-serif;color:var(--clr-text);background:var(--clr-bg);line-height:1.6;-webkit-font-smoothing:antialiased}
a{color:inherit;text-decoration:none}

.hero{min-height:100vh;background:var(--clr-primary);color:var(--clr-secondary);display:flex;align-items:flex-end;padding:60px 24px;position:relative}
.accent-bar{position:absolute;top:0;left:0;width:100%;height:5px;background:var(--clr-accent)}
.hero-content{max-width:900px;margin:0 auto;width:100%}
.hero h1{font-family:'Space Grotesk',sans-serif;font-size:clamp(2.8rem,8vw,5.5rem);font-weight:700;line-height:0.95;margin-bottom:16px}
.hero h1 .accent{color:var(--clr-accent)}
.hero .subtitle{font-size:clamp(0.85rem,1.5vw,1rem);opacity:0.5;margin-bottom:8px}
.hero .rating{font-size:14px;color:var(--clr-accent);margin-bottom:24px}
.hero .rating .rating-text{opacity:0.5;color:var(--clr-secondary);margin-left:4px}
.cta-btn{display:inline-block;padding:14px 36px;background:var(--clr-accent);color:var(--clr-bg);font-family:'Space Grotesk',sans-serif;font-size:14px;font-weight:700;transition:transform 0.3s,box-shadow 0.3s}
.cta-btn:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(0,0,0,0.3)}

.section{padding:80px 24px;max-width:900px;margin:0 auto}
.section-label{font-size:11px;letter-spacing:3px;text-transform:uppercase;color:var(--clr-accent);margin-bottom:12px;font-weight:600}
.section h2{font-family:'Space Grotesk',sans-serif;font-size:clamp(1.6rem,4vw,2.4rem);font-weight:700;margin-bottom:24px}

.services-grid{display:grid;grid-template-columns:1fr;gap:0}
@media(min-width:768px){.services-grid{grid-template-columns:1fr 1fr}}
.service-card{padding:24px;border:2px solid color-mix(in srgb,var(--clr-primary) 12%,transparent);transition:border-color 0.3s}
.service-card:hover{border-color:var(--clr-accent)}
.service-card h3{font-family:'Space Grotesk',sans-serif;font-size:1.1rem;font-weight:700;margin-bottom:6px}
.service-card p{font-size:0.85rem;color:var(--clr-muted)}

.about-bg{background:var(--clr-surface)}
.about p{font-size:1.05rem;line-height:1.8;color:var(--clr-muted);max-width:680px}

.why-item{display:flex;align-items:flex-start;gap:12px;padding:14px 0;border-bottom:2px solid color-mix(in srgb,var(--clr-primary) 10%,transparent)}
.why-icon{color:var(--clr-accent);font-size:1.1rem;flex-shrink:0;font-weight:700}
.hours-grid{display:grid;gap:8px;max-width:400px}
.hours-row{display:flex;justify-content:space-between;padding:8px 0;border-bottom:2px solid color-mix(in srgb,var(--clr-primary) 10%,transparent);font-size:0.9rem}
.hours-day{font-weight:600}
.hours-time{color:var(--clr-muted)}

.contact-bg{background:var(--clr-primary);color:var(--clr-secondary)}
.contact-bg .section-label{color:var(--clr-accent)}
.contact-bg h2{color:var(--clr-secondary)}
.contact-grid{display:grid;grid-template-columns:1fr;gap:20px;margin-bottom:32px}
@media(min-width:768px){.contact-grid{grid-template-columns:1fr 1fr 1fr}}
.contact-item .label{font-size:11px;letter-spacing:2px;text-transform:uppercase;color:var(--clr-accent);margin-bottom:6px}
.phone-link{color:var(--clr-secondary);transition:color 0.3s}
.phone-link:hover{color:var(--clr-accent)}

.footer{background:color-mix(in srgb,var(--clr-primary) 95%,black);padding:24px;text-align:center;color:var(--clr-muted);font-size:0.75rem}
</style>
</head>
<body>
  <section class="hero">
    <div class="accent-bar"></div>
    <div class="hero-content">
      <h1>{{headline}}<span class="accent">.</span></h1>
      <p class="subtitle">{{subheadline}}</p>
      {{rating}}
      <a href="tel:{{business_phone_raw}}" class="cta-btn">{{cta_text}}</a>
    </div>
  </section>
  <section class="section">
    <div class="section-label">Services</div>
    <h2>What We Do</h2>
    <div class="services-grid">{{services}}</div>
  </section>
  <section class="about-bg"><div class="section about">
    <div class="section-label">About</div>
    <h2>Who We Are</h2>
    <p>{{about}}</p>
  </div></section>
  <section class="section">
    <div class="section-label">Info</div>
    <h2>Why Choose Us</h2>
    {{why_or_hours}}
  </section>
  <section class="contact-bg"><div class="section">
    <div class="section-label">Contact</div>
    <h2>Get a Quote</h2>
    <div class="contact-grid">
      <div class="contact-item"><div class="label">Phone</div>{{business_phone}}</div>
      <div class="contact-item"><div class="label">Address</div>{{business_address}}</div>
      <div class="contact-item"><div class="label">Website</div>{{business_website}}</div>
    </div>
    <a href="tel:{{business_phone_raw}}" class="cta-btn">{{cta_text}}</a>
  </div></section>
  <footer class="footer"><p>{{business_name}} &bull; Powered by LeadForge</p></footer>
</body>
</html>`
}
```

- [ ] **Step 4: Add Fresh Startup template**

Append to `templates.ts`:

```typescript
// ─────────────────────────────────────────────
// 5. FRESH STARTUP
// Target: Tech, agencies, marketing, creative
// Fonts: Outfit
// ─────────────────────────────────────────────
export function freshStartup(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{business_name}}</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap');
:root{--clr-primary:{{clr-primary}};--clr-secondary:{{clr-secondary}};--clr-accent:{{clr-accent}};--clr-bg:{{clr-bg}};--clr-surface:{{clr-surface}};--clr-text:{{clr-text}};--clr-muted:{{clr-muted}}}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Outfit',sans-serif;color:var(--clr-text);background:var(--clr-bg);line-height:1.6;-webkit-font-smoothing:antialiased}
a{color:inherit;text-decoration:none}

.hero{min-height:100vh;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:60px 24px}
.hero-badge{display:inline-block;padding:6px 16px;background:var(--clr-surface);border-radius:20px;font-size:12px;color:var(--clr-muted);margin-bottom:24px}
.hero h1{font-size:clamp(2.2rem,6vw,4rem);font-weight:700;line-height:1.1;margin-bottom:16px;max-width:700px}
.hero h1 .gradient{background:linear-gradient(135deg,var(--clr-primary),var(--clr-accent));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
.hero .subtitle{font-size:clamp(0.9rem,2vw,1.1rem);color:var(--clr-muted);max-width:500px;margin-bottom:8px}
.hero .rating{font-size:14px;color:var(--clr-accent);margin-bottom:28px}
.hero .rating .rating-text{opacity:0.6;margin-left:4px;color:var(--clr-muted)}
.cta-btn{display:inline-block;padding:14px 36px;background:linear-gradient(135deg,var(--clr-primary),var(--clr-accent));color:#fff;font-weight:600;font-size:14px;border-radius:28px;transition:transform 0.3s,box-shadow 0.3s}
.cta-btn:hover{transform:translateY(-2px);box-shadow:0 12px 32px color-mix(in srgb,var(--clr-accent) 30%,transparent)}

.section{padding:80px 24px;max-width:900px;margin:0 auto}
.section-label{font-size:11px;letter-spacing:3px;text-transform:uppercase;color:var(--clr-accent);margin-bottom:12px;font-weight:600}
.section h2{font-size:clamp(1.5rem,4vw,2.2rem);font-weight:700;margin-bottom:24px}

.services-bg{background:var(--clr-surface)}
.services-grid{display:grid;grid-template-columns:1fr;gap:16px}
@media(min-width:768px){.services-grid{grid-template-columns:1fr 1fr}}
.service-card{background:var(--clr-bg);border-radius:16px;padding:24px;box-shadow:0 2px 12px rgba(0,0,0,0.04);transition:transform 0.3s,box-shadow 0.3s}
.service-card:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(0,0,0,0.08)}
.service-card h3{font-size:1.05rem;font-weight:700;margin-bottom:6px}
.service-card p{font-size:0.85rem;color:var(--clr-muted)}

.about p{font-size:1.05rem;line-height:1.8;color:var(--clr-muted);max-width:680px}

.why-item{display:flex;align-items:flex-start;gap:12px;padding:14px 0;border-bottom:1px solid var(--clr-surface)}
.why-icon{color:var(--clr-accent);font-size:1.1rem;flex-shrink:0}
.hours-grid{display:grid;gap:8px;max-width:400px}
.hours-row{display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid var(--clr-surface);font-size:0.9rem}
.hours-day{font-weight:600}
.hours-time{color:var(--clr-muted)}

.contact-section{background:linear-gradient(135deg,var(--clr-primary),var(--clr-accent));color:white;border-radius:24px;max-width:900px;margin:0 auto 60px;padding:48px 32px;text-align:center}
.contact-section .section-label{color:rgba(255,255,255,0.6)}
.contact-section h2{color:white}
.contact-grid{display:flex;flex-wrap:wrap;justify-content:center;gap:32px;margin-bottom:32px}
.contact-item .label{font-size:11px;letter-spacing:2px;text-transform:uppercase;color:rgba(255,255,255,0.5);margin-bottom:4px}
.phone-link{color:white;transition:opacity 0.3s}
.phone-link:hover{opacity:0.8}
.contact-section .cta-btn{background:white;color:var(--clr-primary)}
.contact-section .cta-btn:hover{box-shadow:0 12px 32px rgba(0,0,0,0.2)}

.footer{padding:24px;text-align:center;color:var(--clr-muted);font-size:0.75rem}
</style>
</head>
<body>
  <section class="hero">
    <div class="hero-badge">{{business_address}}</div>
    <h1><span class="gradient">{{headline}}</span></h1>
    <p class="subtitle">{{subheadline}}</p>
    {{rating}}
    <a href="tel:{{business_phone_raw}}" class="cta-btn">{{cta_text}}</a>
  </section>
  <section class="services-bg"><div class="section">
    <div class="section-label">Services</div>
    <h2>What We Do</h2>
    <div class="services-grid">{{services}}</div>
  </div></section>
  <section class="section about">
    <div class="section-label">About</div>
    <h2>Our Story</h2>
    <p>{{about}}</p>
  </section>
  <section class="services-bg"><div class="section">
    <div class="section-label">Info</div>
    <h2>Why Choose Us</h2>
    {{why_or_hours}}
  </div></section>
  <div class="contact-section">
    <div class="section-label">Contact</div>
    <h2>Let's Work Together</h2>
    <div class="contact-grid">
      <div class="contact-item"><div class="label">Phone</div>{{business_phone}}</div>
      <div class="contact-item"><div class="label">Address</div>{{business_address}}</div>
      <div class="contact-item"><div class="label">Website</div>{{business_website}}</div>
    </div>
    <a href="tel:{{business_phone_raw}}" class="cta-btn">{{cta_text}}</a>
  </div>
  <footer class="footer"><p>{{business_name}} &bull; Powered by LeadForge</p></footer>
</body>
</html>`
}
```

- [ ] **Step 5: Add Dark Premium template**

Append to `templates.ts`:

```typescript
// ─────────────────────────────────────────────
// 6. DARK PREMIUM
// Target: Fine dining, hotels, lounges, boutique
// Fonts: Cormorant Garamond + Inter
// ─────────────────────────────────────────────
export function darkPremium(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{business_name}}</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;600;700&family=Inter:wght@300;400;500&display=swap');
:root{--clr-primary:{{clr-primary}};--clr-secondary:{{clr-secondary}};--clr-accent:{{clr-accent}};--clr-bg:{{clr-bg}};--clr-surface:{{clr-surface}};--clr-text:{{clr-text}};--clr-muted:{{clr-muted}}}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Inter',sans-serif;color:var(--clr-text);background:var(--clr-bg);line-height:1.6;-webkit-font-smoothing:antialiased}
a{color:inherit;text-decoration:none}

.hero{min-height:100vh;background:var(--clr-bg);display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:60px 24px;position:relative}
.hero::before{content:'';position:absolute;top:20%;left:50%;transform:translateX(-50%);width:300px;height:300px;background:radial-gradient(circle,color-mix(in srgb,var(--clr-accent) 8%,transparent),transparent);border-radius:50%}
.hero-overline{font-size:11px;letter-spacing:5px;text-transform:uppercase;color:var(--clr-accent);margin-bottom:20px;position:relative;z-index:1}
.gold-line{width:50px;height:1px;background:linear-gradient(90deg,transparent,var(--clr-accent),transparent);margin:16px auto;position:relative;z-index:1}
.hero h1{font-family:'Cormorant Garamond',serif;font-size:clamp(2.4rem,6vw,4.5rem);font-weight:700;letter-spacing:2px;margin-bottom:12px;text-shadow:0 0 40px color-mix(in srgb,var(--clr-accent) 10%,transparent);position:relative;z-index:1}
.hero .subtitle{font-size:clamp(0.85rem,1.5vw,1rem);color:var(--clr-muted);font-weight:300;margin-bottom:8px;position:relative;z-index:1}
.hero .rating{font-size:13px;color:var(--clr-accent);margin-bottom:28px;position:relative;z-index:1}
.hero .rating .rating-text{opacity:0.5;color:var(--clr-muted);margin-left:4px}
.cta-btn{display:inline-block;padding:14px 40px;border:1px solid var(--clr-accent);color:var(--clr-accent);font-size:11px;font-weight:500;letter-spacing:3px;text-transform:uppercase;transition:all 0.3s;position:relative;z-index:1}
.cta-btn:hover{background:var(--clr-accent);color:var(--clr-bg)}

.section{padding:80px 24px;max-width:900px;margin:0 auto}
.section-label{font-size:11px;letter-spacing:5px;text-transform:uppercase;color:var(--clr-accent);margin-bottom:12px}
.section h2{font-family:'Cormorant Garamond',serif;font-size:clamp(1.6rem,4vw,2.4rem);font-weight:700;margin-bottom:24px;letter-spacing:1px}
.section-divider{width:100%;max-width:900px;margin:0 auto;height:1px;background:linear-gradient(90deg,transparent,color-mix(in srgb,var(--clr-accent) 20%,transparent),transparent)}

.services-grid{display:grid;grid-template-columns:1fr;gap:0}
@media(min-width:768px){.services-grid{grid-template-columns:1fr 1fr}}
.service-card{padding:24px;border:1px solid color-mix(in srgb,var(--clr-accent) 10%,transparent);transition:border-color 0.3s,background 0.3s}
.service-card:hover{border-color:color-mix(in srgb,var(--clr-accent) 25%,transparent);background:var(--clr-surface)}
.service-card h3{font-family:'Cormorant Garamond',serif;font-size:1.2rem;font-weight:700;margin-bottom:6px;letter-spacing:0.5px}
.service-card p{font-size:0.85rem;color:var(--clr-muted)}

.about p{font-size:1.05rem;line-height:2;color:var(--clr-muted);max-width:680px}

.why-item{display:flex;align-items:flex-start;gap:12px;padding:14px 0;border-bottom:1px solid color-mix(in srgb,var(--clr-accent) 10%,transparent)}
.why-icon{color:var(--clr-accent);font-size:1rem;flex-shrink:0}
.hours-grid{display:grid;gap:8px;max-width:400px}
.hours-row{display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid color-mix(in srgb,var(--clr-accent) 10%,transparent);font-size:0.9rem}
.hours-day{font-weight:500;color:var(--clr-text)}
.hours-time{color:var(--clr-muted)}

.contact-section{border:1px solid color-mix(in srgb,var(--clr-accent) 15%,transparent);max-width:900px;margin:0 auto 60px;padding:48px 32px;text-align:center}
.contact-section .section-label{color:var(--clr-accent)}
.contact-grid{display:flex;flex-wrap:wrap;justify-content:center;gap:32px;margin-bottom:32px}
.contact-item .label{font-size:11px;letter-spacing:3px;text-transform:uppercase;color:var(--clr-accent);margin-bottom:4px}
.contact-item{font-size:0.95rem}
.phone-link{color:var(--clr-text);transition:color 0.3s}
.phone-link:hover{color:var(--clr-accent)}

.footer{padding:32px 24px;text-align:center;color:var(--clr-muted);font-size:0.75rem}
</style>
</head>
<body>
  <section class="hero">
    <div class="hero-overline">{{business_address}}</div>
    <div class="gold-line"></div>
    <h1>{{business_name}}</h1>
    <p class="subtitle">{{subheadline}}</p>
    {{rating}}
    <a href="tel:{{business_phone_raw}}" class="cta-btn">{{cta_text}}</a>
  </section>
  <div class="section-divider"></div>
  <section class="section">
    <div class="section-label">Menu</div>
    <h2>{{headline}}</h2>
    <div class="services-grid">{{services}}</div>
  </section>
  <div class="section-divider"></div>
  <section class="section about">
    <div class="section-label">About</div>
    <h2>The Experience</h2>
    <p>{{about}}</p>
  </section>
  <div class="section-divider"></div>
  <section class="section">
    <div class="section-label">Info</div>
    <h2>Why Choose Us</h2>
    {{why_or_hours}}
  </section>
  <div class="contact-section">
    <div class="section-label">Reservations</div>
    <h2>{{headline}}</h2>
    <div class="contact-grid">
      <div class="contact-item"><div class="label">Phone</div>{{business_phone}}</div>
      <div class="contact-item"><div class="label">Address</div>{{business_address}}</div>
      <div class="contact-item"><div class="label">Website</div>{{business_website}}</div>
    </div>
    <a href="tel:{{business_phone_raw}}" class="cta-btn">{{cta_text}}</a>
  </div>
  <footer class="footer"><p>{{business_name}} &bull; Powered by LeadForge</p></footer>
</body>
</html>`
}
```

- [ ] **Step 6: Add the template selector function**

Append to `templates.ts`:

```typescript
// ─────────────────────────────────────────────
// Template selector map
// ─────────────────────────────────────────────
export type TemplateName = 'warm_organic' | 'soft_glass' | 'editorial_luxury' | 'bold_modern' | 'fresh_startup' | 'dark_premium'

const templateMap: Record<TemplateName, () => string> = {
  warm_organic: warmOrganic,
  soft_glass: softGlass,
  editorial_luxury: editorialLuxury,
  bold_modern: boldModern,
  fresh_startup: freshStartup,
  dark_premium: darkPremium,
}

export function getTemplate(name: TemplateName): string {
  const fn = templateMap[name]
  if (!fn) return warmOrganic() // fallback
  return fn()
}

/**
 * Pick a template name from business categories.
 * Replaces the old pickStyleForBusiness() + designStyles array.
 */
export function pickTemplateName(business: { categories?: string[]; name?: string }): TemplateName {
  const cats = (business.categories || []).join(' ').toLowerCase()
  const name = (business.name || '').toLowerCase()
  const all = `${cats} ${name}`

  if (/fine dining|upscale|luxury|hotel|boutique|wine|cocktail|lounge/i.test(all)) return 'dark_premium'
  if (/restaurant|cafe|coffee|bakery|pizz|sushi|taco|burger|bistro|grill|diner|bar |pub|brew|food|catering|panadería|taquería|carnicería/i.test(all)) return 'warm_organic'
  if (/salon|spa|beauty|hair|nail|skin|massage|wellness|yoga|fitness|gym|clinic|dental|medical|health|therapy|estética|peluquería/i.test(all)) return 'soft_glass'
  if (/tech|software|digital|marketing|agency|consult|startup|design|creative|web|app|saas/i.test(all)) return 'fresh_startup'
  if (/law|legal|attorney|accounti|financ|real estate|insurance|architect/i.test(all)) return 'editorial_luxury'
  if (/auto|car|mechanic|repair|construct|plumb|electric|roofing|hvac|landscap/i.test(all)) return 'bold_modern'

  // Default: editorial luxury as the most versatile
  const defaults: TemplateName[] = ['editorial_luxury', 'bold_modern', 'fresh_startup']
  return defaults[Math.floor(Math.random() * defaults.length)]
}
```

- [ ] **Step 7: Commit**

```bash
git add supabase/functions/build-demo/templates.ts
git commit -m "feat(build-demo): add all 6 HTML templates with selector"
```

---

### Task 4: Rewrite index.ts to use template system

**Files:**
- Modify: `supabase/functions/build-demo/index.ts`

Replace the massive `generateUniqueHTML()` function and prompt with a streamlined flow: AI generates JSON copy + palette, template engine merges it with the selected template.

- [ ] **Step 1: Rewrite the entire index.ts**

Replace the full contents of `supabase/functions/build-demo/index.ts` with:

```typescript
// Build Demo Edge Function — Template System v1
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { getTemplate, pickTemplateName } from './templates.ts'
import { renderTemplate, fallbackContent, type AiContent, type BusinessData } from './template-engine.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ── Reused helpers ──────────────────────────

function detectLanguage(business: any): { language: string; langCode: string } {
  const text = `${business.name || ''} ${business.address || ''} ${(business.categories || []).join(' ')}`.toLowerCase()
  if (/méxico|mexico|guadalajara|monterrey|cdmx|ciudad de|colonia|calle |avenida |paseo |blvd\.|c\.p\.|jalisco|puebla|oaxaca|cancún|mérida|querétaro|león|tijuana|hermosillo|chile|santiago|valparaíso|viña|concepción|colombia|bogotá|medellín|argentina|buenos aires|córdoba|perú|lima|ecuador|quito|venezuela|caracas|uruguay|montevideo|bolivia|la paz|paraguay|asunción|panamá|costa rica|san josé|guatemala|honduras|el salvador|nicaragua|dominicana|santo domingo|taquería|tacos |pozole|carnitas|birria|tortas |antojitos|mariscos|panadería|carnicería|estética|peluquería|empanadas|ceviche|arepa/i.test(text)) {
    return { language: 'Spanish', langCode: 'es' }
  }
  if (/brasil|brazil|são paulo|rio de janeiro|belo horizonte|rua |bairro |padaria|churrascaria/i.test(text)) return { language: 'Portuguese', langCode: 'pt' }
  if (/france|paris|lyon|marseille|rue |boulevard |boulangerie|pâtisserie/i.test(text)) return { language: 'French', langCode: 'fr' }
  return { language: 'English', langCode: 'en' }
}

async function scrapeBusinessWebsite(url: string): Promise<string | null> {
  if (!url) return null
  try {
    const cleanUrl = url.startsWith('http') ? url : `https://${url}`
    const controller = new AbortController()
    const timeout = setTimeout(() => controller.abort(), 5000)
    const response = await fetch(cleanUrl, {
      headers: { 'User-Agent': 'Mozilla/5.0 (compatible; LeadForge/1.0)' },
      redirect: 'follow',
      signal: controller.signal,
    })
    clearTimeout(timeout)
    if (!response.ok) return null
    const html = await response.text()

    const titleMatch = html.match(/<title[^>]*>(.*?)<\/title>/is)
    const metaDescMatch = html.match(/<meta[^>]*name=["']description["'][^>]*content=["'](.*?)["']/is)
    const h1Matches = [...html.matchAll(/<h1[^>]*>(.*?)<\/h1>/gis)].map(m => m[1].replace(/<[^>]+>/g, '').trim()).filter(Boolean)
    const h2Matches = [...html.matchAll(/<h2[^>]*>(.*?)<\/h2>/gis)].map(m => m[1].replace(/<[^>]+>/g, '').trim()).filter(Boolean)

    const bodyMatch = html.match(/<body[^>]*>([\s\S]*?)<\/body>/is)
    let bodyText = ''
    if (bodyMatch) {
      bodyText = bodyMatch[1]
        .replace(/<script[\s\S]*?<\/script>/gi, '')
        .replace(/<style[\s\S]*?<\/style>/gi, '')
        .replace(/<[^>]+>/g, ' ')
        .replace(/\s+/g, ' ')
        .trim()
        .slice(0, 1500)
    }

    const listItems = [...html.matchAll(/<li[^>]*>(.*?)<\/li>/gis)]
      .map(m => m[1].replace(/<[^>]+>/g, '').trim())
      .filter(t => t.length > 3 && t.length < 100)
      .slice(0, 15)

    const result = []
    if (titleMatch?.[1]) result.push(`Title: ${titleMatch[1].trim()}`)
    if (metaDescMatch?.[1]) result.push(`Description: ${metaDescMatch[1].trim()}`)
    if (h1Matches.length) result.push(`Headings: ${h1Matches.slice(0, 3).join(', ')}`)
    if (h2Matches.length) result.push(`Sections: ${h2Matches.slice(0, 5).join(', ')}`)
    if (listItems.length) result.push(`Items: ${listItems.join(', ')}`)
    if (bodyText) result.push(`Content: ${bodyText.slice(0, 800)}`)

    return result.length > 0 ? result.join('\n') : null
  } catch {
    return null
  }
}

async function fetchUnsplashImages(business: any): Promise<string[]> {
  const unsplashKey = Deno.env.get('UNSPLASH_ACCESS_KEY')
  if (!unsplashKey) return []
  const cats = (business.categories || []).slice(0, 2).join(' ')
  const query = cats || business.name || 'business'
  try {
    const controller = new AbortController()
    const timeout = setTimeout(() => controller.abort(), 8000)
    const response = await fetch(
      `https://api.unsplash.com/search/photos?query=${encodeURIComponent(query)}&per_page=2&orientation=landscape`,
      { headers: { Authorization: `Client-ID ${unsplashKey}` }, signal: controller.signal }
    )
    clearTimeout(timeout)
    if (!response.ok) return []
    const data = await response.json()
    return (data.results || []).map((img: any) => img.urls?.regular).filter(Boolean)
  } catch {
    return []
  }
}

// ── AI Content Generation ───────────────────

async function generateAiContent(
  business: any,
  scrapedContent: string | null,
  customNotes: string | null,
  language: string
): Promise<AiContent | null> {
  const openaiKey = Deno.env.get('OPENAI_API_KEY')
  if (!openaiKey) return null

  const categories = business.categories ? JSON.stringify(business.categories) : 'Unknown'
  const auditInfo = business.audit_score != null
    ? `Audit score: ${business.audit_score}/100. Diagnosis: ${business.audit_diagnosis || 'N/A'}.`
    : ''

  const prompt = `Generate website copy for this business. ALL text must be in ${language}.

BUSINESS:
- Name: ${business.name}
- Address: ${business.address || 'N/A'}
- Phone: ${business.phone || 'N/A'}
- Rating: ${business.rating ? `${business.rating}/5 (${business.reviews_count || 0} reviews)` : 'N/A'}
- Categories: ${categories}
${auditInfo}
${scrapedContent ? `\nREAL CONTENT FROM THEIR WEBSITE:\n${scrapedContent}\n\nUse their real services/menu items from above.` : ''}
${customNotes ? `\nCLIENT NOTES: ${customNotes}` : ''}

Return JSON with this exact structure:
{
  "headline": "powerful tagline, 3-8 words that capture what makes this business special",
  "subheadline": "supporting line, 10-20 words",
  "services": [
    {"name": "Service Name", "desc": "8-15 word description"}
  ],
  "about": "2-3 sentences about what makes this business unique. Mention location and specialties.",
  "why_us": ["reason 1", "reason 2", "reason 3"],
  "cta_text": "CTA button label, 2-4 words",
  "palette": {
    "primary": "#hex main brand color (pick based on business type and vibe)",
    "secondary": "#hex light background",
    "accent": "#hex for CTAs and highlights",
    "bg": "#hex page background",
    "surface": "#hex card/section background",
    "text": "#hex main text",
    "muted": "#hex secondary text"
  }
}

Include 4-6 services. Make the palette feel premium and appropriate for this business type. The headline should be creative, not generic.`

  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), 20000)
  try {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: `You are a conversion-focused copywriter. Write compelling website copy in ${language}. Return ONLY valid JSON.` },
          { role: 'user', content: prompt },
        ],
        temperature: 0.7,
        max_tokens: 1000,
        response_format: { type: 'json_object' },
      }),
      signal: controller.signal,
    })
    clearTimeout(timeout)

    if (!response.ok) {
      console.error('[build-demo] OpenAI error:', response.status)
      return null
    }

    const data = await response.json()
    if (data.error) {
      console.error('[build-demo] OpenAI API error:', JSON.stringify(data.error))
      return null
    }

    const content = data.choices?.[0]?.message?.content
    if (!content) return null

    const parsed = JSON.parse(content)
    // Validate required fields
    if (!parsed.headline || !parsed.services || !parsed.palette) return null

    return parsed as AiContent
  } catch (e) {
    clearTimeout(timeout)
    console.error('[build-demo] AI call failed:', e)
    return null
  }
}

// ── Main handler ────────────────────────────

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Env vars
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    if (!supabaseUrl || !supabaseKey || !serviceRoleKey) {
      return new Response(JSON.stringify({ error: 'Server misconfigured' }), {
        status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 2. Auth
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Missing Authorization header' }), {
        status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    const supabase = createClient(supabaseUrl, supabaseKey, {
      global: { headers: { Authorization: authHeader } }
    })
    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey)

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 3. Check limits
    const { data: profile } = await supabase
      .from('profiles')
      .select('subscription_tier, demos_this_month')
      .eq('id', user.id)
      .single()

    if (!profile) {
      return new Response(JSON.stringify({ error: 'Profile not found' }), {
        status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    if (profile.subscription_tier === 'free' && profile.demos_this_month >= 1) {
      return new Response(JSON.stringify({ error: 'Free tier demo limit reached' }), {
        status: 402, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 4. Get business
    const { business_id, custom_notes } = await req.json()
    if (!business_id || typeof business_id !== 'string') {
      return new Response(JSON.stringify({ error: 'business_id is required' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

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

    // 5. Pick template + detect language
    const templateName = pickTemplateName(business)
    const { language, langCode } = detectLanguage(business)
    console.log(`[build-demo] template=${templateName}, lang=${language}`)

    // 6. Parallel: scrape website + fetch images
    const [scrapedContent, unsplashImages] = await Promise.all([
      scrapeBusinessWebsite(business.website),
      fetchUnsplashImages(business),
    ])

    // 7. AI content generation (fallback if fails)
    let aiContent = await generateAiContent(business, scrapedContent, custom_notes || null, language)
    if (!aiContent) {
      console.warn('[build-demo] AI failed, using fallback content')
      aiContent = fallbackContent(business as BusinessData, language)
    }

    // 8. Render template
    const templateHtml = getTemplate(templateName)
    const html = renderTemplate(templateHtml, aiContent, business as BusinessData, unsplashImages)
    console.log(`[build-demo] rendered HTML: ${html.length} chars`)

    // 9. Upload to storage
    const slug = Array.from({ length: 8 }, () => 'abcdefghijklmnopqrstuvwxyz0123456789'[Math.floor(Math.random() * 36)]).join('')
    const storagePath = `demos/${user.id}/${slug}.html`

    const { error: uploadError } = await supabaseAdmin.storage
      .from('demos')
      .upload(storagePath, new Blob([html], { type: 'text/html' }), {
        contentType: 'text/html',
        upsert: true,
      })

    if (uploadError) throw new Error(`Storage upload failed: ${uploadError.message}`)

    // 10. Create demo record
    const { data: demo, error: insertError } = await supabase
      .from('demos')
      .insert({
        business_id,
        user_id: user.id,
        template: templateName,
        storage_path: storagePath,
        public_slug: slug,
        business_data: {
          name: business.name,
          address: business.address,
          phone: business.phone,
          website: business.website,
          rating: business.rating,
          reviews_count: business.reviews_count,
          categories: business.categories,
          audit_score: business.audit_score,
          audit_diagnosis: business.audit_diagnosis,
        },
      })
      .select()
      .single()

    if (insertError) throw new Error(`Demo insert failed: ${insertError.message}`)

    // 11. Update business status + increment usage
    await supabase
      .from('businesses')
      .update({ status: 'demo_created', updated_at: new Date().toISOString() })
      .eq('id', business_id)

    try {
      await supabase.rpc('increment_counter', { p_user_id: user.id, p_column: 'demos_this_month' })
    } catch {
      await supabase.from('profiles').update({ demos_this_month: profile.demos_this_month + 1 }).eq('id', user.id)
    }

    return new Response(JSON.stringify({ demo }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('[build-demo] FATAL:', error.message)
    return new Response(JSON.stringify({ error: 'Something went wrong. Please try again.' }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})
```

- [ ] **Step 2: Commit**

```bash
git add supabase/functions/build-demo/index.ts
git commit -m "feat(build-demo): rewrite to use template system instead of AI-generated HTML"
```

---

### Task 5: Update database constraint and Flutter model

**Files:**
- Modify: `lib/models/demo.dart`
- Create: `supabase/migrations/20260411_add_template_types.sql`

- [ ] **Step 1: Create migration to add new template values**

```sql
-- supabase/migrations/20260411_add_template_types.sql
-- Add new template types while keeping old ones for backward compatibility
ALTER TABLE demos DROP CONSTRAINT IF EXISTS demos_template_check;
ALTER TABLE demos ADD CONSTRAINT demos_template_check CHECK (
  template IN (
    'restaurant', 'professional', 'health_beauty',
    'warm_organic', 'soft_glass', 'editorial_luxury',
    'bold_modern', 'fresh_startup', 'dark_premium'
  )
);
```

- [ ] **Step 2: Run the migration against production**

Run: `supabase db push --project-ref dnedrbflhrpodymdjicp`

If `db push` doesn't work with migrations, run the SQL directly:

```bash
supabase db execute --project-ref dnedrbflhrpodymdjicp -f supabase/migrations/20260411_add_template_types.sql
```

Or paste the SQL into the Supabase Dashboard > SQL Editor and run it.

- [ ] **Step 3: Update the Flutter DemoTemplate enum**

In `lib/models/demo.dart`, replace the `DemoTemplate` enum:

```dart
enum DemoTemplate {
  @JsonValue('restaurant') restaurant,
  @JsonValue('professional') professional,
  @JsonValue('health_beauty') healthBeauty,
  @JsonValue('warm_organic') warmOrganic,
  @JsonValue('soft_glass') softGlass,
  @JsonValue('editorial_luxury') editorialLuxury,
  @JsonValue('bold_modern') boldModern,
  @JsonValue('fresh_startup') freshStartup,
  @JsonValue('dark_premium') darkPremium,
}
```

- [ ] **Step 4: Update the templateLabel extension**

In `lib/models/demo.dart`, replace the `templateLabel` getter in the `DemoX` extension:

```dart
extension DemoX on Demo {
  String get publicUrl => '${AppConstants.supabaseUrl}/functions/v1/demo/$publicSlug';

  String get templateLabel {
    switch (template) {
      case DemoTemplate.restaurant:
        return 'Restaurant / Café';
      case DemoTemplate.professional:
        return 'Professional Services';
      case DemoTemplate.healthBeauty:
        return 'Health & Beauty';
      case DemoTemplate.warmOrganic:
        return 'Warm Organic';
      case DemoTemplate.softGlass:
        return 'Soft Glassmorphism';
      case DemoTemplate.editorialLuxury:
        return 'Editorial Luxury';
      case DemoTemplate.boldModern:
        return 'Bold Modern';
      case DemoTemplate.freshStartup:
        return 'Fresh Startup';
      case DemoTemplate.darkPremium:
        return 'Dark Premium';
    }
  }
}
```

- [ ] **Step 5: Rebuild generated files**

Run: `cd /Users/benjamingonzalez/proyectosFlutter/leadforge && dart run build_runner build --delete-conflicting-outputs`

Expected: `demo.freezed.dart` and `demo.g.dart` regenerate with new enum values.

- [ ] **Step 6: Commit**

```bash
git add supabase/migrations/20260411_add_template_types.sql lib/models/demo.dart lib/models/demo.freezed.dart lib/models/demo.g.dart
git commit -m "feat: add new template types to DB constraint and Flutter model"
```

---

### Task 6: Deploy and test end-to-end

**Files:** None (deployment + testing)

- [ ] **Step 1: Deploy the build-demo function**

```bash
supabase functions deploy build-demo --project-ref dnedrbflhrpodymdjicp
```

Expected: Deploys successfully with the new `templates.ts` and `template-engine.ts` files.

- [ ] **Step 2: Run the Flutter app**

```bash
cd /Users/benjamingonzalez/proyectosFlutter/leadforge && flutter run --device-timeout 120
```

- [ ] **Step 3: Test a demo generation**

In the app:
1. Go to a business that has been audited
2. Tap "Build Demo Site"
3. Generate a demo
4. Verify the preview loads and looks professional
5. Verify the template matches the business category
6. Test the public URL in a desktop browser to check responsive design

- [ ] **Step 4: Test fallback behavior**

Temporarily set an invalid OpenAI key and generate a demo. Verify it still renders with fallback content (business name as headline, categories as services).

- [ ] **Step 5: Commit any fixes needed**

```bash
git add -A && git commit -m "fix(build-demo): post-deployment fixes"
```

Only commit this if fixes were needed.
