// templates.ts — 6 handcrafted HTML templates for demo sites
// Each uses {{placeholder}} tokens replaced by template-engine.ts
//
// Engine-generated HTML classes to style:
//   .service-card h3 + p    — service/menu items
//   .why-list .why-item      — bullet points (li)
//   .hours-grid .hours-row   — .hours-day + .hours-time
//   .rating .stars + .rating-value

// ═══════════════════════════════════════════════════════════════
// 1. WARM ORGANIC (Rustic Elegance)
//    Restaurants, cafes, bakeries, food
//    Fonts: Fraunces + Josefin Sans
// ═══════════════════════════════════════════════════════════════
export function warmOrganic(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{business_name}}</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Fraunces:wght@400;600;700;900&family=Josefin+Sans:wght@300;400;600&display=swap');
:root{--primary:{{clr-primary}};--secondary:{{clr-secondary}};--accent:{{clr-accent}};--bg:{{clr-bg}};--surface:{{clr-surface}};--text:{{clr-text}};--muted:{{clr-muted}}}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Josefin Sans',sans-serif;color:var(--text);background:var(--bg);-webkit-font-smoothing:antialiased}
a{color:inherit;text-decoration:none}
.container{max-width:900px;margin:0 auto;padding:0 24px}

/* Hero */
.hero{position:relative;min-height:100vh;display:flex;align-items:flex-end;background:var(--primary);overflow:hidden}
{{#has_hero_image}}.hero{background:url('{{hero_image}}') center/cover}{{/has_hero_image}}
.hero::after{content:'';position:absolute;inset:0;background:linear-gradient(to top,rgba(0,0,0,.85) 0%,rgba(0,0,0,.3) 50%,rgba(0,0,0,.1) 100%)}
.hero-inner{position:relative;z-index:1;padding:60px 24px;width:100%;max-width:900px;margin:0 auto;color:#f0e6d2}
.hero-overline{font-size:11px;letter-spacing:4px;text-transform:uppercase;color:var(--accent);margin-bottom:16px}
.hero h1{font-family:'Fraunces',serif;font-size:clamp(2.4rem,6vw,4rem);font-weight:900;line-height:1.05;margin-bottom:12px}
.hero p{font-size:clamp(.9rem,2vw,1.1rem);opacity:.7;font-weight:300;margin-bottom:20px}
.hero .rating{font-size:14px;color:var(--accent);margin-bottom:20px}
.hero .rating .rating-value{opacity:.6;margin-left:6px;font-size:13px}
.btn{display:inline-block;padding:12px 32px;background:var(--accent);color:var(--bg);font-family:'Josefin Sans',sans-serif;font-size:13px;font-weight:600;letter-spacing:1.5px;text-transform:uppercase;border-radius:2px;transition:transform .3s,box-shadow .3s}
.btn:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(0,0,0,.3)}

/* Sections */
.section{padding:72px 24px;max-width:900px;margin:0 auto}
.section-label{font-size:11px;letter-spacing:4px;text-transform:uppercase;color:var(--accent);margin-bottom:10px}
.section h2{font-family:'Fraunces',serif;font-size:clamp(1.5rem,4vw,2.2rem);font-weight:700;margin-bottom:24px}
.alt-bg{background:var(--surface)}

/* Services */
.services-grid{display:grid;grid-template-columns:1fr;gap:14px}
@media(min-width:768px){.services-grid{grid-template-columns:1fr 1fr}}
.service-card{background:var(--bg);border-radius:12px;padding:22px;border:1px solid color-mix(in srgb,var(--primary) 10%,transparent);transition:transform .3s,box-shadow .3s}
.service-card:hover{transform:translateY(-2px);box-shadow:0 8px 20px rgba(0,0,0,.06)}
.service-card h3{font-family:'Fraunces',serif;font-size:1.05rem;font-weight:700;margin-bottom:4px;color:var(--primary)}
.service-card p{font-size:.85rem;color:var(--muted);line-height:1.5}

/* About */
.about-text{font-size:1.05rem;line-height:1.9;color:var(--muted);max-width:680px}

/* Why / Hours */
.why-list{list-style:none;padding:0}
.why-item{display:flex;align-items:center;gap:10px;padding:14px 0;border-bottom:1px solid color-mix(in srgb,var(--primary) 8%,transparent);font-size:.95rem}
.hours-grid{display:grid;gap:6px;max-width:420px}
.hours-row{display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid color-mix(in srgb,var(--primary) 8%,transparent);font-size:.9rem}
.hours-day{font-weight:600}
.hours-time{color:var(--muted)}

/* Contact */
.contact-bg{background:var(--primary);color:var(--secondary)}
.contact-bg .section-label,.contact-bg .rating{color:var(--accent)}
.contact-bg h2{color:var(--secondary)}
.contact-grid{display:grid;grid-template-columns:1fr;gap:20px;margin-bottom:28px}
@media(min-width:768px){.contact-grid{grid-template-columns:1fr 1fr 1fr}}
.contact-item .label{font-size:10px;letter-spacing:2px;text-transform:uppercase;color:var(--accent);margin-bottom:4px}
.contact-item{font-size:.95rem}
.phone-link{color:var(--secondary)}
.phone-link:hover{color:var(--accent)}
.contact-bg .btn{background:var(--accent);color:var(--bg)}

/* Footer */
.footer{padding:24px;text-align:center;font-size:.75rem;color:var(--muted);background:color-mix(in srgb,var(--primary) 92%,black)}
</style>
</head>
<body>
<section class="hero">
  <div class="hero-inner">
    <div class="hero-overline">{{business_address}}</div>
    <h1>{{headline}}</h1>
    <p>{{subheadline}}</p>
    {{rating}}
    <a href="tel:{{business_phone_raw}}" class="btn">{{cta_text}}</a>
  </div>
</section>
<section class="alt-bg"><div class="section">
  <div class="section-label">Menu</div>
  <h2>{{business_name}}</h2>
  <div class="services-grid">{{services}}</div>
</div></section>
<section class="section">
  <div class="section-label">About</div>
  <h2>Our Story</h2>
  <p class="about-text">{{about}}</p>
</section>
<section class="alt-bg"><div class="section">
  <div class="section-label">Info</div>
  <h2>Why Choose Us</h2>
  {{why_or_hours}}
</div></section>
<section class="contact-bg"><div class="section">
  <div class="section-label">Contact</div>
  <h2>Get in Touch</h2>
  <div class="contact-grid">
    <div class="contact-item"><div class="label">Phone</div>{{business_phone}}</div>
    <div class="contact-item"><div class="label">Address</div>{{business_address}}</div>
    <div class="contact-item"><div class="label">Website</div>{{business_website}}</div>
  </div>
  <a href="tel:{{business_phone_raw}}" class="btn">{{cta_text}}</a>
</div></section>
<footer class="footer">{{business_name}} &bull; Powered by LeadForge</footer>
</body>
</html>`
}

// ═══════════════════════════════════════════════════════════════
// 2. SOFT GLASSMORPHISM
//    Salons, spas, clinics, wellness
//    Font: DM Sans
// ═══════════════════════════════════════════════════════════════
export function softGlass(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{business_name}}</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&display=swap');
:root{--primary:{{clr-primary}};--secondary:{{clr-secondary}};--accent:{{clr-accent}};--bg:{{clr-bg}};--surface:{{clr-surface}};--text:{{clr-text}};--muted:{{clr-muted}}}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'DM Sans',sans-serif;color:var(--text);background:var(--bg);-webkit-font-smoothing:antialiased}
a{color:inherit;text-decoration:none}

.hero{min-height:100vh;background:linear-gradient(135deg,var(--secondary),var(--primary));display:flex;align-items:center;justify-content:center;text-align:center;padding:40px 24px}
.glass{background:rgba(255,255,255,.22);backdrop-filter:blur(24px);-webkit-backdrop-filter:blur(24px);border:1px solid rgba(255,255,255,.35);border-radius:28px;padding:48px 36px;max-width:520px;width:100%}
.hero h1{font-size:clamp(2rem,5vw,3rem);font-weight:700;margin-bottom:10px}
.hero p{font-size:clamp(.9rem,2vw,1.05rem);color:var(--muted);margin-bottom:8px}
.hero .rating{font-size:14px;color:var(--accent);margin-bottom:24px}
.hero .rating .rating-value{opacity:.6;margin-left:4px}
.btn{display:inline-block;padding:14px 36px;background:var(--accent);color:#fff;font-weight:600;font-size:14px;border-radius:28px;transition:transform .3s,box-shadow .3s}
.btn:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(0,0,0,.15)}

.section{padding:72px 24px;max-width:900px;margin:0 auto}
.section-label{font-size:11px;letter-spacing:3px;text-transform:uppercase;color:var(--accent);margin-bottom:10px;font-weight:500}
.section h2{font-size:clamp(1.5rem,4vw,2.2rem);font-weight:700;margin-bottom:24px}

.services-grid{display:grid;grid-template-columns:1fr;gap:14px}
@media(min-width:768px){.services-grid{grid-template-columns:1fr 1fr}}
.service-card{background:rgba(255,255,255,.45);backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);border:1px solid rgba(255,255,255,.35);border-radius:20px;padding:22px;transition:transform .3s,box-shadow .3s}
.service-card:hover{transform:translateY(-2px);box-shadow:0 10px 28px rgba(0,0,0,.05)}
.service-card h3{font-size:1.05rem;font-weight:700;margin-bottom:4px}
.service-card p{font-size:.85rem;color:var(--muted)}

.about-bg{background:linear-gradient(135deg,color-mix(in srgb,var(--secondary) 30%,white),var(--bg))}
.about-text{font-size:1.05rem;line-height:1.9;color:var(--muted);max-width:680px}

.why-list{list-style:none;padding:0}
.why-item{padding:14px 0;border-bottom:1px solid color-mix(in srgb,var(--primary) 8%,transparent);font-size:.95rem}
.hours-grid{display:grid;gap:6px;max-width:420px}
.hours-row{display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid color-mix(in srgb,var(--primary) 8%,transparent);font-size:.9rem}
.hours-day{font-weight:600}
.hours-time{color:var(--muted)}

.contact-card{background:var(--primary);color:#fff;border-radius:28px;max-width:900px;margin:0 auto 48px;padding:48px 32px;text-align:center}
.contact-card .section-label{color:var(--accent)}
.contact-card h2{color:#fff}
.contact-grid{display:flex;flex-wrap:wrap;justify-content:center;gap:32px;margin-bottom:28px}
.contact-item .label{font-size:10px;letter-spacing:2px;text-transform:uppercase;color:var(--accent);margin-bottom:4px}
.contact-item{font-size:.95rem}
.phone-link{color:#fff}
.phone-link:hover{color:var(--accent)}
.contact-card .btn{background:#fff;color:var(--primary)}
.contact-card .btn:hover{box-shadow:0 8px 24px rgba(0,0,0,.2)}

.footer{padding:24px;text-align:center;font-size:.75rem;color:var(--muted)}
</style>
</head>
<body>
<section class="hero">
  <div class="glass">
    <h1>{{headline}}</h1>
    <p>{{subheadline}}</p>
    {{rating}}
    <a href="tel:{{business_phone_raw}}" class="btn">{{cta_text}}</a>
  </div>
</section>
<section class="section">
  <div class="section-label">Services</div>
  <h2>What We Offer</h2>
  <div class="services-grid">{{services}}</div>
</section>
<section class="about-bg"><div class="section">
  <div class="section-label">About</div>
  <h2>Our Story</h2>
  <p class="about-text">{{about}}</p>
</div></section>
<section class="section">
  <div class="section-label">Info</div>
  <h2>Why Choose Us</h2>
  {{why_or_hours}}
</section>
<div class="contact-card">
  <div class="section-label">Contact</div>
  <h2>Let's Connect</h2>
  <div class="contact-grid">
    <div class="contact-item"><div class="label">Phone</div>{{business_phone}}</div>
    <div class="contact-item"><div class="label">Address</div>{{business_address}}</div>
    <div class="contact-item"><div class="label">Website</div>{{business_website}}</div>
  </div>
  <a href="tel:{{business_phone_raw}}" class="btn">{{cta_text}}</a>
</div>
<footer class="footer">{{business_name}} &bull; Powered by LeadForge</footer>
</body>
</html>`
}

// ═══════════════════════════════════════════════════════════════
// 3. EDITORIAL LUXURY
//    Law, finance, real estate, consulting
//    Fonts: Playfair Display + Inter
// ═══════════════════════════════════════════════════════════════
export function editorialLuxury(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{business_name}}</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=Inter:wght@300;400;500;600&display=swap');
:root{--primary:{{clr-primary}};--secondary:{{clr-secondary}};--accent:{{clr-accent}};--bg:{{clr-bg}};--surface:{{clr-surface}};--text:{{clr-text}};--muted:{{clr-muted}}}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Inter',sans-serif;color:var(--text);background:var(--bg);-webkit-font-smoothing:antialiased}
a{color:inherit;text-decoration:none}

.hero{min-height:100vh;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:60px 24px;background:var(--surface)}
.hero-overline{font-size:11px;letter-spacing:5px;text-transform:uppercase;color:var(--muted);margin-bottom:20px}
.divider{width:48px;height:1px;background:var(--primary);opacity:.3;margin:18px auto}
.hero h1{font-family:'Playfair Display',serif;font-size:clamp(2.4rem,6vw,4.5rem);font-weight:900;line-height:1.05;letter-spacing:-1px;margin-bottom:12px}
.hero p{font-size:clamp(.85rem,1.5vw,1rem);color:var(--muted);font-weight:300;margin-bottom:8px}
.hero .rating{font-size:13px;color:var(--accent);margin-bottom:24px}
.hero .rating .rating-value{opacity:.6;margin-left:4px}
.btn{display:inline-block;padding:14px 40px;border:1.5px solid var(--primary);color:var(--primary);font-size:11px;font-weight:500;letter-spacing:3px;text-transform:uppercase;transition:all .3s}
.btn:hover{background:var(--primary);color:var(--bg)}

.section{padding:72px 24px;max-width:900px;margin:0 auto}
.section-label{font-size:11px;letter-spacing:5px;text-transform:uppercase;color:var(--muted);margin-bottom:10px}
.section h2{font-family:'Playfair Display',serif;font-size:clamp(1.5rem,4vw,2.2rem);font-weight:700;margin-bottom:24px;letter-spacing:-.5px}
.sep{width:100%;height:1px;background:color-mix(in srgb,var(--primary) 10%,transparent)}

.services-grid{display:grid;grid-template-columns:1fr;gap:0}
@media(min-width:768px){.services-grid{grid-template-columns:1fr 1fr}}
.service-card{padding:24px 0;border-bottom:1px solid color-mix(in srgb,var(--primary) 8%,transparent)}
@media(min-width:768px){.service-card{padding:24px}}
.service-card h3{font-family:'Playfair Display',serif;font-size:1.05rem;font-weight:700;margin-bottom:4px}
.service-card p{font-size:.85rem;color:var(--muted);line-height:1.5}

.about-text{font-size:1.05rem;line-height:2;color:var(--muted);max-width:680px}

.why-list{list-style:none;padding:0}
.why-item{padding:14px 0;border-bottom:1px solid color-mix(in srgb,var(--primary) 8%,transparent);font-size:.95rem}
.hours-grid{display:grid;gap:6px;max-width:420px}
.hours-row{display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid color-mix(in srgb,var(--primary) 8%,transparent);font-size:.9rem}
.hours-day{font-weight:500}
.hours-time{color:var(--muted)}

.contact-bg{background:var(--primary);color:var(--secondary)}
.contact-bg .section-label{color:var(--accent)}
.contact-bg h2{color:var(--secondary)}
.contact-grid{display:grid;grid-template-columns:1fr;gap:20px;margin-bottom:28px}
@media(min-width:768px){.contact-grid{grid-template-columns:1fr 1fr 1fr}}
.contact-item .label{font-size:10px;letter-spacing:3px;text-transform:uppercase;color:var(--accent);margin-bottom:4px}
.contact-item{font-size:.95rem}
.phone-link{color:var(--secondary)}
.phone-link:hover{color:var(--accent)}
.contact-bg .btn{border-color:var(--accent);color:var(--accent)}
.contact-bg .btn:hover{background:var(--accent);color:var(--primary)}

.footer{padding:28px 24px;text-align:center;font-size:.75rem;color:var(--muted);border-top:1px solid color-mix(in srgb,var(--primary) 10%,transparent)}
</style>
</head>
<body>
<section class="hero">
  <div class="hero-overline">{{business_address}}</div>
  <div class="divider"></div>
  <h1>{{business_name}}</h1>
  <p>{{subheadline}}</p>
  {{rating}}
  <a href="tel:{{business_phone_raw}}" class="btn">{{cta_text}}</a>
</section>
<div class="sep"></div>
<section class="section">
  <div class="section-label">Services</div>
  <h2>{{headline}}</h2>
  <div class="services-grid">{{services}}</div>
</section>
<div class="sep"></div>
<section class="section">
  <div class="section-label">About</div>
  <h2>Our Practice</h2>
  <p class="about-text">{{about}}</p>
</section>
<div class="sep"></div>
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
  <a href="tel:{{business_phone_raw}}" class="btn">{{cta_text}}</a>
</div></section>
<footer class="footer">{{business_name}} &bull; Powered by LeadForge</footer>
</body>
</html>`
}

// ═══════════════════════════════════════════════════════════════
// 4. BOLD MODERN
//    Auto, construction, plumbing, trades
//    Fonts: Space Grotesk + Inter
// ═══════════════════════════════════════════════════════════════
export function boldModern(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{business_name}}</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;600;700&family=Inter:wght@300;400;500;600&display=swap');
:root{--primary:{{clr-primary}};--secondary:{{clr-secondary}};--accent:{{clr-accent}};--bg:{{clr-bg}};--surface:{{clr-surface}};--text:{{clr-text}};--muted:{{clr-muted}}}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Inter',sans-serif;color:var(--text);background:var(--bg);-webkit-font-smoothing:antialiased}
a{color:inherit;text-decoration:none}

.hero{min-height:100vh;background:var(--primary);color:var(--secondary);display:flex;align-items:flex-end;padding:60px 24px;position:relative}
.accent-bar{position:absolute;top:0;left:0;width:100%;height:5px;background:var(--accent)}
.hero-inner{max-width:900px;margin:0 auto;width:100%}
.hero h1{font-family:'Space Grotesk',sans-serif;font-size:clamp(2.8rem,8vw,5.5rem);font-weight:700;line-height:.95;margin-bottom:16px}
.hero h1 .dot{color:var(--accent)}
.hero p{font-size:clamp(.85rem,1.5vw,1rem);opacity:.5;margin-bottom:8px}
.hero .rating{font-size:14px;color:var(--accent);margin-bottom:24px}
.hero .rating .rating-value{opacity:.5;color:var(--secondary);margin-left:4px}
.btn{display:inline-block;padding:14px 36px;background:var(--accent);color:var(--bg);font-family:'Space Grotesk',sans-serif;font-size:14px;font-weight:700;transition:transform .3s,box-shadow .3s}
.btn:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(0,0,0,.3)}

.section{padding:72px 24px;max-width:900px;margin:0 auto}
.section-label{font-size:11px;letter-spacing:3px;text-transform:uppercase;color:var(--accent);margin-bottom:10px;font-weight:600}
.section h2{font-family:'Space Grotesk',sans-serif;font-size:clamp(1.5rem,4vw,2.2rem);font-weight:700;margin-bottom:24px}
.alt-bg{background:var(--surface)}

.services-grid{display:grid;grid-template-columns:1fr;gap:0}
@media(min-width:768px){.services-grid{grid-template-columns:1fr 1fr}}
.service-card{padding:22px;border:2px solid color-mix(in srgb,var(--primary) 12%,transparent);transition:border-color .3s}
.service-card:hover{border-color:var(--accent)}
.service-card h3{font-family:'Space Grotesk',sans-serif;font-size:1.05rem;font-weight:700;margin-bottom:4px}
.service-card p{font-size:.85rem;color:var(--muted)}

.about-text{font-size:1.05rem;line-height:1.8;color:var(--muted);max-width:680px}

.why-list{list-style:none;padding:0}
.why-item{padding:14px 0;border-bottom:2px solid color-mix(in srgb,var(--primary) 10%,transparent);font-size:.95rem}
.hours-grid{display:grid;gap:6px;max-width:420px}
.hours-row{display:flex;justify-content:space-between;padding:10px 0;border-bottom:2px solid color-mix(in srgb,var(--primary) 10%,transparent);font-size:.9rem}
.hours-day{font-weight:600}
.hours-time{color:var(--muted)}

.contact-bg{background:var(--primary);color:var(--secondary)}
.contact-bg .section-label{color:var(--accent)}
.contact-bg h2{color:var(--secondary)}
.contact-grid{display:grid;grid-template-columns:1fr;gap:20px;margin-bottom:28px}
@media(min-width:768px){.contact-grid{grid-template-columns:1fr 1fr 1fr}}
.contact-item .label{font-size:10px;letter-spacing:2px;text-transform:uppercase;color:var(--accent);margin-bottom:4px}
.phone-link{color:var(--secondary)}
.phone-link:hover{color:var(--accent)}

.footer{background:color-mix(in srgb,var(--primary) 95%,black);padding:24px;text-align:center;font-size:.75rem;color:var(--muted)}
</style>
</head>
<body>
<section class="hero">
  <div class="accent-bar"></div>
  <div class="hero-inner">
    <h1>{{headline}}<span class="dot">.</span></h1>
    <p>{{subheadline}}</p>
    {{rating}}
    <a href="tel:{{business_phone_raw}}" class="btn">{{cta_text}}</a>
  </div>
</section>
<section class="section">
  <div class="section-label">Services</div>
  <h2>What We Do</h2>
  <div class="services-grid">{{services}}</div>
</section>
<section class="alt-bg"><div class="section">
  <div class="section-label">About</div>
  <h2>Who We Are</h2>
  <p class="about-text">{{about}}</p>
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
  <a href="tel:{{business_phone_raw}}" class="btn">{{cta_text}}</a>
</div></section>
<footer class="footer">{{business_name}} &bull; Powered by LeadForge</footer>
</body>
</html>`
}

// ═══════════════════════════════════════════════════════════════
// 5. FRESH STARTUP
//    Tech, agencies, marketing, creative
//    Font: Outfit
// ═══════════════════════════════════════════════════════════════
export function freshStartup(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{business_name}}</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap');
:root{--primary:{{clr-primary}};--secondary:{{clr-secondary}};--accent:{{clr-accent}};--bg:{{clr-bg}};--surface:{{clr-surface}};--text:{{clr-text}};--muted:{{clr-muted}}}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Outfit',sans-serif;color:var(--text);background:var(--bg);-webkit-font-smoothing:antialiased}
a{color:inherit;text-decoration:none}

.hero{min-height:100vh;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:60px 24px}
.hero-badge{display:inline-block;padding:6px 16px;background:var(--surface);border-radius:20px;font-size:12px;color:var(--muted);margin-bottom:24px}
.hero h1{font-size:clamp(2.2rem,6vw,4rem);font-weight:700;line-height:1.1;margin-bottom:16px;max-width:700px}
.hero h1 .grad{background:linear-gradient(135deg,var(--primary),var(--accent));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
.hero p{font-size:clamp(.9rem,2vw,1.1rem);color:var(--muted);max-width:500px;margin-bottom:8px}
.hero .rating{font-size:14px;color:var(--accent);margin-bottom:28px}
.hero .rating .rating-value{opacity:.6;margin-left:4px;color:var(--muted)}
.btn{display:inline-block;padding:14px 36px;background:linear-gradient(135deg,var(--primary),var(--accent));color:#fff;font-weight:600;font-size:14px;border-radius:28px;transition:transform .3s,box-shadow .3s}
.btn:hover{transform:translateY(-2px);box-shadow:0 12px 32px color-mix(in srgb,var(--accent) 30%,transparent)}

.section{padding:72px 24px;max-width:900px;margin:0 auto}
.section-label{font-size:11px;letter-spacing:3px;text-transform:uppercase;color:var(--accent);margin-bottom:10px;font-weight:600}
.section h2{font-size:clamp(1.5rem,4vw,2.2rem);font-weight:700;margin-bottom:24px}
.alt-bg{background:var(--surface)}

.services-grid{display:grid;grid-template-columns:1fr;gap:14px}
@media(min-width:768px){.services-grid{grid-template-columns:1fr 1fr}}
.service-card{background:var(--bg);border-radius:16px;padding:22px;box-shadow:0 2px 12px rgba(0,0,0,.04);transition:transform .3s,box-shadow .3s}
.service-card:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(0,0,0,.08)}
.service-card h3{font-size:1.05rem;font-weight:700;margin-bottom:4px}
.service-card p{font-size:.85rem;color:var(--muted)}

.about-text{font-size:1.05rem;line-height:1.9;color:var(--muted);max-width:680px}

.why-list{list-style:none;padding:0}
.why-item{padding:14px 0;border-bottom:1px solid var(--surface);font-size:.95rem}
.hours-grid{display:grid;gap:6px;max-width:420px}
.hours-row{display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid var(--surface);font-size:.9rem}
.hours-day{font-weight:600}
.hours-time{color:var(--muted)}

.contact-card{background:linear-gradient(135deg,var(--primary),var(--accent));color:#fff;border-radius:24px;max-width:900px;margin:0 auto 48px;padding:48px 32px;text-align:center}
.contact-card .section-label{color:rgba(255,255,255,.6)}
.contact-card h2{color:#fff}
.contact-grid{display:flex;flex-wrap:wrap;justify-content:center;gap:32px;margin-bottom:28px}
.contact-item .label{font-size:10px;letter-spacing:2px;text-transform:uppercase;color:rgba(255,255,255,.5);margin-bottom:4px}
.phone-link{color:#fff}
.phone-link:hover{opacity:.8}
.contact-card .btn{background:#fff;color:var(--primary)}
.contact-card .btn:hover{box-shadow:0 12px 32px rgba(0,0,0,.2)}

.footer{padding:24px;text-align:center;font-size:.75rem;color:var(--muted)}
</style>
</head>
<body>
<section class="hero">
  <div class="hero-badge">{{business_address}}</div>
  <h1><span class="grad">{{headline}}</span></h1>
  <p>{{subheadline}}</p>
  {{rating}}
  <a href="tel:{{business_phone_raw}}" class="btn">{{cta_text}}</a>
</section>
<section class="alt-bg"><div class="section">
  <div class="section-label">Services</div>
  <h2>What We Do</h2>
  <div class="services-grid">{{services}}</div>
</div></section>
<section class="section">
  <div class="section-label">About</div>
  <h2>Our Story</h2>
  <p class="about-text">{{about}}</p>
</section>
<section class="alt-bg"><div class="section">
  <div class="section-label">Info</div>
  <h2>Why Choose Us</h2>
  {{why_or_hours}}
</div></section>
<div class="contact-card">
  <div class="section-label">Contact</div>
  <h2>Let's Work Together</h2>
  <div class="contact-grid">
    <div class="contact-item"><div class="label">Phone</div>{{business_phone}}</div>
    <div class="contact-item"><div class="label">Address</div>{{business_address}}</div>
    <div class="contact-item"><div class="label">Website</div>{{business_website}}</div>
  </div>
  <a href="tel:{{business_phone_raw}}" class="btn">{{cta_text}}</a>
</div>
<footer class="footer">{{business_name}} &bull; Powered by LeadForge</footer>
</body>
</html>`
}

// ═══════════════════════════════════════════════════════════════
// 6. DARK PREMIUM
//    Fine dining, hotels, lounges, boutique
//    Fonts: Cormorant Garamond + Inter
// ═══════════════════════════════════════════════════════════════
export function darkPremium(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{business_name}}</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;600;700&family=Inter:wght@300;400;500&display=swap');
:root{--primary:{{clr-primary}};--secondary:{{clr-secondary}};--accent:{{clr-accent}};--bg:{{clr-bg}};--surface:{{clr-surface}};--text:{{clr-text}};--muted:{{clr-muted}}}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Inter',sans-serif;color:var(--text);background:var(--bg);-webkit-font-smoothing:antialiased}
a{color:inherit;text-decoration:none}

.hero{min-height:100vh;background:var(--bg);display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:60px 24px;position:relative}
.hero::before{content:'';position:absolute;top:20%;left:50%;transform:translateX(-50%);width:300px;height:300px;background:radial-gradient(circle,color-mix(in srgb,var(--accent) 8%,transparent),transparent);border-radius:50%}
.hero-overline{font-size:11px;letter-spacing:5px;text-transform:uppercase;color:var(--accent);margin-bottom:20px;position:relative;z-index:1}
.gold-line{width:50px;height:1px;background:linear-gradient(90deg,transparent,var(--accent),transparent);margin:16px auto;position:relative;z-index:1}
.hero h1{font-family:'Cormorant Garamond',serif;font-size:clamp(2.4rem,6vw,4.5rem);font-weight:700;letter-spacing:2px;margin-bottom:12px;text-shadow:0 0 40px color-mix(in srgb,var(--accent) 10%,transparent);position:relative;z-index:1}
.hero p{font-size:clamp(.85rem,1.5vw,1rem);color:var(--muted);font-weight:300;margin-bottom:8px;position:relative;z-index:1}
.hero .rating{font-size:13px;color:var(--accent);margin-bottom:28px;position:relative;z-index:1}
.hero .rating .rating-value{opacity:.5;color:var(--muted);margin-left:4px}
.btn{display:inline-block;padding:14px 40px;border:1px solid var(--accent);color:var(--accent);font-size:11px;font-weight:500;letter-spacing:3px;text-transform:uppercase;transition:all .3s;position:relative;z-index:1}
.btn:hover{background:var(--accent);color:var(--bg)}

.section{padding:72px 24px;max-width:900px;margin:0 auto}
.section-label{font-size:11px;letter-spacing:5px;text-transform:uppercase;color:var(--accent);margin-bottom:10px}
.section h2{font-family:'Cormorant Garamond',serif;font-size:clamp(1.5rem,4vw,2.2rem);font-weight:700;margin-bottom:24px;letter-spacing:1px}
.sep{width:100%;max-width:900px;margin:0 auto;height:1px;background:linear-gradient(90deg,transparent,color-mix(in srgb,var(--accent) 20%,transparent),transparent)}

.services-grid{display:grid;grid-template-columns:1fr;gap:0}
@media(min-width:768px){.services-grid{grid-template-columns:1fr 1fr}}
.service-card{padding:22px;border:1px solid color-mix(in srgb,var(--accent) 10%,transparent);transition:border-color .3s,background .3s}
.service-card:hover{border-color:color-mix(in srgb,var(--accent) 25%,transparent);background:var(--surface)}
.service-card h3{font-family:'Cormorant Garamond',serif;font-size:1.15rem;font-weight:700;margin-bottom:4px;letter-spacing:.5px}
.service-card p{font-size:.85rem;color:var(--muted)}

.about-text{font-size:1.05rem;line-height:2;color:var(--muted);max-width:680px}

.why-list{list-style:none;padding:0}
.why-item{padding:14px 0;border-bottom:1px solid color-mix(in srgb,var(--accent) 10%,transparent);font-size:.95rem}
.hours-grid{display:grid;gap:6px;max-width:420px}
.hours-row{display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid color-mix(in srgb,var(--accent) 10%,transparent);font-size:.9rem}
.hours-day{font-weight:500}
.hours-time{color:var(--muted)}

.contact-section{border:1px solid color-mix(in srgb,var(--accent) 15%,transparent);max-width:900px;margin:0 auto 48px;padding:48px 32px;text-align:center}
.contact-section .section-label{color:var(--accent)}
.contact-grid{display:flex;flex-wrap:wrap;justify-content:center;gap:32px;margin-bottom:28px}
.contact-item .label{font-size:10px;letter-spacing:3px;text-transform:uppercase;color:var(--accent);margin-bottom:4px}
.contact-item{font-size:.95rem}
.phone-link{color:var(--text)}
.phone-link:hover{color:var(--accent)}

.footer{padding:28px 24px;text-align:center;font-size:.75rem;color:var(--muted)}
</style>
</head>
<body>
<section class="hero">
  <div class="hero-overline">{{business_address}}</div>
  <div class="gold-line"></div>
  <h1>{{business_name}}</h1>
  <p>{{subheadline}}</p>
  {{rating}}
  <a href="tel:{{business_phone_raw}}" class="btn">{{cta_text}}</a>
</section>
<div class="sep"></div>
<section class="section">
  <div class="section-label">Menu</div>
  <h2>{{headline}}</h2>
  <div class="services-grid">{{services}}</div>
</section>
<div class="sep"></div>
<section class="section">
  <div class="section-label">About</div>
  <h2>The Experience</h2>
  <p class="about-text">{{about}}</p>
</section>
<div class="sep"></div>
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
  <a href="tel:{{business_phone_raw}}" class="btn">{{cta_text}}</a>
</div>
<footer class="footer">{{business_name}} &bull; Powered by LeadForge</footer>
</body>
</html>`
}

// ═══════════════════════════════════════════════════════════════
// Template selector
// ═══════════════════════════════════════════════════════════════
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
  if (!fn) return warmOrganic()
  return fn()
}

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

  const defaults: TemplateName[] = ['editorial_luxury', 'bold_modern', 'fresh_startup']
  return defaults[Math.floor(Math.random() * defaults.length)]
}
