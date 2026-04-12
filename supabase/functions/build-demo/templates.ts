// templates.ts — HTML template library for build-demo Edge Function
// Each template returns a fully-formed HTML string with {{placeholder}} tokens
// that template-engine.ts will replace with real business content.

export function warmOrganic(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{business_name}}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,300;0,9..144,400;0,9..144,600;0,9..144,700;1,9..144,400;1,9..144,600&family=Josefin+Sans:wght@300;400;600;700&display=swap');

    /* ── Design tokens ───────────────────────────────────────────── */
    :root {
      --clr-primary:   {{clr-primary}};
      --clr-secondary: {{clr-secondary}};
      --clr-accent:    {{clr-accent}};
      --clr-bg:        {{clr-bg}};
      --clr-surface:   {{clr-surface}};
      --clr-text:      {{clr-text}};
      --clr-muted:     {{clr-muted}};

      --radius-sm:  8px;
      --radius-md:  14px;
      --radius-lg:  22px;
      --shadow-sm:  0 2px 8px rgba(0,0,0,.07);
      --shadow-md:  0 6px 24px rgba(0,0,0,.10);
      --shadow-lg:  0 16px 48px rgba(0,0,0,.14);
      --transition: .3s ease;
      --container:  1100px;
    }

    /* ── Reset & base ────────────────────────────────────────────── */
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    html { scroll-behavior: smooth; }

    body {
      font-family: 'Josefin Sans', sans-serif;
      background-color: var(--clr-bg);
      color: var(--clr-text);
      line-height: 1.65;
      -webkit-font-smoothing: antialiased;
    }

    img { display: block; max-width: 100%; }

    a { color: inherit; text-decoration: none; }

    /* ── Typography helpers ──────────────────────────────────────── */
    .serif { font-family: 'Fraunces', serif; }

    .label {
      font-family: 'Josefin Sans', sans-serif;
      font-size: .72rem;
      font-weight: 700;
      letter-spacing: .14em;
      text-transform: uppercase;
      color: var(--clr-accent);
    }

    /* ── Layout ──────────────────────────────────────────────────── */
    .container {
      width: 100%;
      max-width: var(--container);
      margin-inline: auto;
      padding-inline: 1.25rem;
    }

    /* ── Buttons ─────────────────────────────────────────────────── */
    .btn {
      display: inline-flex;
      align-items: center;
      gap: .5rem;
      font-family: 'Josefin Sans', sans-serif;
      font-weight: 700;
      font-size: .92rem;
      letter-spacing: .06em;
      text-transform: uppercase;
      padding: .875rem 2rem;
      border-radius: 50px;
      border: 2px solid transparent;
      cursor: pointer;
      transition: transform var(--transition), box-shadow var(--transition), background-color var(--transition);
      white-space: nowrap;
    }

    .btn-primary {
      background-color: var(--clr-accent);
      color: var(--clr-bg);
      border-color: var(--clr-accent);
      box-shadow: 0 4px 18px rgba(0,0,0,.18);
    }

    .btn-primary:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 28px rgba(0,0,0,.22);
      filter: brightness(1.07);
    }

    .btn-outline {
      background-color: transparent;
      color: var(--clr-bg);
      border-color: rgba(255,255,255,.55);
    }

    .btn-outline:hover {
      background-color: rgba(255,255,255,.12);
      border-color: rgba(255,255,255,.9);
      transform: translateY(-2px);
    }

    /* ══════════════════════════════════════════════════════════════
       1. HERO
    ══════════════════════════════════════════════════════════════ */
    .hero {
      position: relative;
      min-height: 100svh;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
      background-color: var(--clr-primary);
      text-align: center;
    }

    /* Hero background image — only rendered when an image is available */
    {{#has_hero_image}}
    .hero-bg {
      position: absolute;
      inset: 0;
      background-image: url('{{hero_image}}');
      background-size: cover;
      background-position: center;
      background-repeat: no-repeat;
      transform: scale(1.04);
      transition: transform 8s ease;
    }
    .hero:hover .hero-bg { transform: scale(1); }
    {{/has_hero_image}}

    /* Dark overlay for text legibility */
    .hero-overlay {
      position: absolute;
      inset: 0;
      background: linear-gradient(
        160deg,
        rgba(0,0,0,.62) 0%,
        rgba(0,0,0,.38) 55%,
        rgba(0,0,0,.58) 100%
      );
    }

    .hero-content {
      position: relative;
      z-index: 2;
      color: #fff;
      padding: 3rem 1.25rem 4rem;
      max-width: 820px;
    }

    .hero-eyebrow {
      display: inline-block;
      font-family: 'Josefin Sans', sans-serif;
      font-size: .75rem;
      font-weight: 700;
      letter-spacing: .18em;
      text-transform: uppercase;
      color: rgba(255,255,255,.7);
      margin-bottom: 1.25rem;
    }

    .hero-headline {
      font-family: 'Fraunces', serif;
      font-size: clamp(2.6rem, 7vw, 5.5rem);
      font-weight: 700;
      line-height: 1.08;
      letter-spacing: -.01em;
      margin-bottom: 1.1rem;
      color: #fff;
    }

    .hero-headline em {
      font-style: italic;
      font-weight: 400;
      color: var(--clr-accent);
    }

    .hero-sub {
      font-family: 'Josefin Sans', sans-serif;
      font-size: clamp(1rem, 2.5vw, 1.22rem);
      font-weight: 300;
      color: rgba(255,255,255,.85);
      max-width: 560px;
      margin-inline: auto;
      margin-bottom: 1.75rem;
    }

    .hero-rating {
      display: inline-flex;
      align-items: center;
      gap: .5rem;
      background: rgba(255,255,255,.12);
      backdrop-filter: blur(8px);
      border: 1px solid rgba(255,255,255,.22);
      border-radius: 50px;
      padding: .45rem 1.1rem;
      font-size: .88rem;
      font-weight: 600;
      color: #fff;
      margin-bottom: 2rem;
    }

    .hero-rating .stars { color: #f5c842; letter-spacing: .05em; }

    .hero-cta-wrap {
      display: flex;
      flex-wrap: wrap;
      gap: .875rem;
      justify-content: center;
    }

    /* ══════════════════════════════════════════════════════════════
       2. SERVICES
    ══════════════════════════════════════════════════════════════ */
    .services {
      background-color: var(--clr-surface);
      padding: 5rem 0;
    }

    .section-header {
      text-align: center;
      margin-bottom: 3rem;
    }

    .section-header .label { margin-bottom: .6rem; }

    .section-title {
      font-family: 'Fraunces', serif;
      font-size: clamp(1.75rem, 4vw, 2.8rem);
      font-weight: 600;
      line-height: 1.18;
      color: var(--clr-primary);
    }

    .section-subtitle {
      margin-top: .65rem;
      font-size: .98rem;
      color: var(--clr-muted);
      max-width: 520px;
      margin-inline: auto;
    }

    .services-grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 1.25rem;
    }

    .service-card {
      background: var(--clr-bg);
      border: 1.5px solid rgba(0,0,0,.07);
      border-radius: var(--radius-md);
      padding: 1.75rem 1.5rem;
      box-shadow: var(--shadow-sm);
      transition: transform var(--transition), box-shadow var(--transition), border-color var(--transition);
    }

    .service-card:hover {
      transform: translateY(-4px);
      box-shadow: var(--shadow-md);
      border-color: var(--clr-accent);
    }

    .service-icon {
      width: 44px;
      height: 44px;
      background: color-mix(in srgb, var(--clr-accent) 14%, transparent);
      border-radius: var(--radius-sm);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.35rem;
      margin-bottom: 1rem;
    }

    .service-name {
      font-family: 'Fraunces', serif;
      font-size: 1.18rem;
      font-weight: 600;
      color: var(--clr-primary);
      margin-bottom: .4rem;
    }

    .service-desc {
      font-size: .92rem;
      color: var(--clr-muted);
      line-height: 1.6;
    }

    .service-price {
      display: inline-block;
      margin-top: .75rem;
      font-weight: 700;
      font-size: .95rem;
      color: var(--clr-accent);
    }

    /* ══════════════════════════════════════════════════════════════
       3. ABOUT
    ══════════════════════════════════════════════════════════════ */
    .about {
      background-color: var(--clr-bg);
      padding: 5rem 0;
    }

    .about-inner {
      display: grid;
      grid-template-columns: 1fr;
      gap: 2.5rem;
      align-items: center;
    }

    .about-text .label { margin-bottom: .7rem; }

    .about-title {
      font-family: 'Fraunces', serif;
      font-size: clamp(1.6rem, 4vw, 2.6rem);
      font-weight: 600;
      line-height: 1.22;
      color: var(--clr-primary);
      margin-bottom: 1.1rem;
    }

    .about-body {
      font-size: 1rem;
      color: var(--clr-muted);
      line-height: 1.75;
    }

    .about-body p + p { margin-top: .9rem; }

    .about-accent-bar {
      width: 56px;
      height: 3px;
      background: var(--clr-accent);
      border-radius: 4px;
      margin-top: 1.5rem;
    }

    .about-visual {
      position: relative;
    }

    .about-img-wrap {
      border-radius: var(--radius-lg);
      overflow: hidden;
      box-shadow: var(--shadow-lg);
      aspect-ratio: 4 / 3;
      background: color-mix(in srgb, var(--clr-primary) 18%, var(--clr-surface));
    }

    .about-img-wrap img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      transition: transform .6s ease;
    }

    .about-img-wrap:hover img { transform: scale(1.04); }

    .about-badge {
      position: absolute;
      bottom: -1.25rem;
      right: -0.5rem;
      background: var(--clr-accent);
      color: var(--clr-bg);
      border-radius: var(--radius-md);
      padding: 1rem 1.4rem;
      text-align: center;
      box-shadow: var(--shadow-md);
      font-family: 'Fraunces', serif;
    }

    .about-badge .num {
      display: block;
      font-size: 2rem;
      font-weight: 700;
      line-height: 1;
    }

    .about-badge .dsc {
      font-size: .75rem;
      font-weight: 400;
      letter-spacing: .06em;
      text-transform: uppercase;
      opacity: .85;
    }

    /* ══════════════════════════════════════════════════════════════
       4. WHY / HOURS
    ══════════════════════════════════════════════════════════════ */
    .why-hours {
      background-color: var(--clr-surface);
      padding: 5rem 0;
    }

    /* generic prose fallback for why_or_hours */
    .why-hours-body {
      max-width: 720px;
      margin-inline: auto;
      font-size: .98rem;
      color: var(--clr-muted);
      line-height: 1.75;
    }

    /* hours table — template-engine may inject a styled <table> here */
    .hours-table {
      width: 100%;
      border-collapse: collapse;
      font-size: .93rem;
    }

    .hours-table tr { border-bottom: 1px solid rgba(0,0,0,.06); }
    .hours-table tr:last-child { border-bottom: none; }

    .hours-table td {
      padding: .65rem .5rem;
      color: var(--clr-text);
    }

    .hours-table td:first-child {
      font-weight: 600;
      color: var(--clr-primary);
      width: 42%;
    }

    /* why-us bullets */
    .why-list {
      display: grid;
      grid-template-columns: 1fr;
      gap: 1.5rem;
      max-width: 760px;
      margin-inline: auto;
    }

    .why-item {
      display: flex;
      gap: 1rem;
      align-items: flex-start;
    }

    .why-icon {
      flex-shrink: 0;
      width: 46px;
      height: 46px;
      background: color-mix(in srgb, var(--clr-primary) 10%, transparent);
      border-radius: var(--radius-sm);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.4rem;
    }

    .why-item-title {
      font-family: 'Fraunces', serif;
      font-size: 1.06rem;
      font-weight: 600;
      color: var(--clr-primary);
      margin-bottom: .25rem;
    }

    .why-item-desc {
      font-size: .9rem;
      color: var(--clr-muted);
      line-height: 1.55;
    }

    /* ══════════════════════════════════════════════════════════════
       5. CONTACT
    ══════════════════════════════════════════════════════════════ */
    .contact {
      background-color: var(--clr-primary);
      padding: 5rem 0;
      color: #fff;
      text-align: center;
    }

    .contact .section-title { color: #fff; }
    .contact .section-subtitle { color: rgba(255,255,255,.68); }

    .contact-cards {
      display: grid;
      grid-template-columns: 1fr;
      gap: 1rem;
      margin: 2.5rem 0;
      max-width: 640px;
      margin-inline: auto;
    }

    .contact-card {
      background: rgba(255,255,255,.1);
      backdrop-filter: blur(10px);
      border: 1px solid rgba(255,255,255,.18);
      border-radius: var(--radius-md);
      padding: 1.4rem 1.75rem;
      display: flex;
      align-items: center;
      gap: 1rem;
      text-align: left;
      transition: background var(--transition), transform var(--transition);
    }

    .contact-card:hover {
      background: rgba(255,255,255,.17);
      transform: translateY(-2px);
    }

    .contact-card-icon {
      flex-shrink: 0;
      font-size: 1.5rem;
      width: 42px;
      text-align: center;
    }

    .contact-card-label {
      font-size: .72rem;
      font-weight: 700;
      letter-spacing: .12em;
      text-transform: uppercase;
      color: rgba(255,255,255,.55);
      margin-bottom: .25rem;
    }

    .contact-card-value {
      font-size: .97rem;
      font-weight: 600;
      color: #fff;
      word-break: break-word;
    }

    .contact-card a { color: #fff; }
    .contact-card a:hover { text-decoration: underline; }

    .contact-cta { margin-top: 2.5rem; }

    /* ══════════════════════════════════════════════════════════════
       6. FOOTER
    ══════════════════════════════════════════════════════════════ */
    .footer {
      background-color: color-mix(in srgb, var(--clr-primary) 90%, #000);
      color: rgba(255,255,255,.55);
      padding: 2rem 1.25rem;
      text-align: center;
      font-size: .82rem;
      letter-spacing: .03em;
    }

    .footer strong {
      color: rgba(255,255,255,.85);
      font-family: 'Fraunces', serif;
      font-size: .95rem;
    }

    .footer-divider {
      display: inline-block;
      margin-inline: .5rem;
      opacity: .4;
    }

    /* ══════════════════════════════════════════════════════════════
       RESPONSIVE — tablet and up
    ══════════════════════════════════════════════════════════════ */
    @media (min-width: 768px) {
      .services-grid {
        grid-template-columns: repeat(2, 1fr);
        gap: 1.5rem;
      }

      .about-inner {
        grid-template-columns: 1fr 1fr;
        gap: 4rem;
      }

      .why-list {
        grid-template-columns: repeat(3, 1fr);
        gap: 2rem;
      }

      .contact-cards {
        grid-template-columns: 1fr 1fr;
      }

      .hero-content {
        padding: 4rem 2rem 5rem;
      }
    }

    @media (min-width: 1024px) {
      .services-grid {
        grid-template-columns: repeat(3, 1fr);
      }

      .hero-content { max-width: 900px; }
    }
  </style>
</head>
<body>

  <!-- ══════════════════════════════════════════════════════════════
       1. HERO
  ══════════════════════════════════════════════════════════════ -->
  <section class="hero">
    {{#has_hero_image}}
    <div class="hero-bg" aria-hidden="true"></div>
    {{/has_hero_image}}
    <div class="hero-overlay" aria-hidden="true"></div>

    <div class="hero-content">
      <span class="hero-eyebrow">{{business_name}}</span>

      <h1 class="hero-headline serif">{{headline}}</h1>

      <p class="hero-sub">{{subheadline}}</p>

      <div class="hero-rating" aria-label="Rating">
        <span class="stars">{{rating}}</span>
      </div>

      <div class="hero-cta-wrap">
        <a href="#contact" class="btn btn-primary">{{cta_text}}</a>
        <a href="#services" class="btn btn-outline">Our Menu</a>
      </div>
    </div>
  </section>

  <!-- ══════════════════════════════════════════════════════════════
       2. SERVICES
  ══════════════════════════════════════════════════════════════ -->
  <section class="services" id="services">
    <div class="container">
      <div class="section-header">
        <p class="label">What We Offer</p>
        <h2 class="section-title serif">Crafted with Passion</h2>
        <p class="section-subtitle">Every dish, every cup, every bite — made with the finest ingredients and decades of craft.</p>
      </div>

      <div class="services-grid">
        {{services}}
      </div>
    </div>
  </section>

  <!-- ══════════════════════════════════════════════════════════════
       3. ABOUT
  ══════════════════════════════════════════════════════════════ -->
  <section class="about" id="about">
    <div class="container">
      <div class="about-inner">
        <div class="about-text">
          <p class="label">Our Story</p>
          <h2 class="about-title serif">A Labor of Love,<br>Served Daily</h2>
          <div class="about-body">
            {{about}}
          </div>
          <div class="about-accent-bar"></div>
        </div>

        <div class="about-visual">
          <div class="about-img-wrap">
            <img
              src="https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80"
              alt="{{business_name}} — our space"
              loading="lazy"
              width="800"
              height="600"
            />
          </div>
          <div class="about-badge">
            <span class="num">★</span>
            <span class="dsc">Since Day&nbsp;One</span>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ══════════════════════════════════════════════════════════════
       4. WHY / HOURS
  ══════════════════════════════════════════════════════════════ -->
  <section class="why-hours" id="hours">
    <div class="container">
      <div class="section-header">
        <p class="label">Find Us</p>
        <h2 class="section-title serif">Hours &amp; Highlights</h2>
      </div>
      <div class="why-hours-body">
        {{why_or_hours}}
      </div>
    </div>
  </section>

  <!-- ══════════════════════════════════════════════════════════════
       5. CONTACT
  ══════════════════════════════════════════════════════════════ -->
  <section class="contact" id="contact">
    <div class="container">
      <p class="label" style="color:rgba(255,255,255,.55)">Get In Touch</p>
      <h2 class="section-title serif" style="color:#fff;margin-top:.5rem">Come Visit Us</h2>
      <p class="section-subtitle">We'd love to see you. Stop by, call ahead, or just show up hungry.</p>

      <div class="contact-cards">
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">📞</span>
          <div>
            <p class="contact-card-label">Phone</p>
            <p class="contact-card-value">
              {{business_phone}}
            </p>
          </div>
        </div>

        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">📍</span>
          <div>
            <p class="contact-card-label">Address</p>
            <p class="contact-card-value">{{business_address}}</p>
          </div>
        </div>

        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">🌐</span>
          <div>
            <p class="contact-card-label">Website</p>
            <p class="contact-card-value">
              {{business_website}}
            </p>
          </div>
        </div>
      </div>

      <div class="contact-cta">
        <a href="tel:{{business_phone_raw}}" class="btn btn-primary">{{cta_text}}</a>
      </div>
    </div>
  </section>

  <!-- ══════════════════════════════════════════════════════════════
       6. FOOTER
  ══════════════════════════════════════════════════════════════ -->
  <footer class="footer">
    <strong>{{business_name}}</strong>
    <span class="footer-divider">·</span>
    Powered by LeadForge
  </footer>

</body>
</html>`
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. SOFT GLASS — Salons, spas, clinics, wellness
// ─────────────────────────────────────────────────────────────────────────────
export function softGlass(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{business_name}}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600;0,9..40,700;1,9..40,400&display=swap');

    :root {
      --clr-primary:   {{clr-primary}};
      --clr-secondary: {{clr-secondary}};
      --clr-accent:    {{clr-accent}};
      --clr-bg:        {{clr-bg}};
      --clr-surface:   {{clr-surface}};
      --clr-text:      {{clr-text}};
      --clr-muted:     {{clr-muted}};

      --radius-sm:  12px;
      --radius-md:  20px;
      --radius-lg:  32px;
      --shadow-sm:  0 2px 12px rgba(0,0,0,.06);
      --shadow-md:  0 8px 32px rgba(0,0,0,.10);
      --shadow-lg:  0 20px 60px rgba(0,0,0,.13);
      --transition: .3s ease;
      --container:  1100px;
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html { scroll-behavior: smooth; }
    body {
      font-family: 'DM Sans', sans-serif;
      background-color: var(--clr-bg);
      color: var(--clr-text);
      line-height: 1.65;
      -webkit-font-smoothing: antialiased;
    }
    img { display: block; max-width: 100%; }
    a { color: inherit; text-decoration: none; }

    .container {
      width: 100%;
      max-width: var(--container);
      margin-inline: auto;
      padding-inline: 1.25rem;
    }

    /* ── Buttons ── */
    .btn {
      display: inline-flex;
      align-items: center;
      gap: .5rem;
      font-family: 'DM Sans', sans-serif;
      font-weight: 600;
      font-size: .95rem;
      padding: .875rem 2.25rem;
      border-radius: 50px;
      border: none;
      cursor: pointer;
      transition: transform var(--transition), box-shadow var(--transition), filter var(--transition);
      white-space: nowrap;
    }
    .btn-primary {
      background: linear-gradient(135deg, var(--clr-accent), var(--clr-secondary));
      color: #fff;
      box-shadow: 0 6px 24px rgba(0,0,0,.18);
    }
    .btn-primary:hover { transform: translateY(-2px); filter: brightness(1.07); box-shadow: 0 10px 32px rgba(0,0,0,.22); }
    .btn-outline {
      background: rgba(255,255,255,.2);
      color: #fff;
      border: 1.5px solid rgba(255,255,255,.5);
      backdrop-filter: blur(8px);
    }
    .btn-outline:hover { background: rgba(255,255,255,.32); transform: translateY(-2px); }

    /* ── Labels ── */
    .label {
      font-size: .72rem;
      font-weight: 700;
      letter-spacing: .16em;
      text-transform: uppercase;
      color: var(--clr-accent);
    }

    /* ══════════════════════════════════════════════════════════════
       1. HERO
    ══════════════════════════════════════════════════════════════ */
    .hero {
      min-height: 100svh;
      display: flex;
      align-items: center;
      justify-content: center;
      position: relative;
      overflow: hidden;
      background: linear-gradient(135deg, var(--clr-primary) 0%, var(--clr-secondary) 50%, var(--clr-accent) 100%);
      text-align: center;
      padding: 4rem 1.25rem;
    }

    {{#has_hero_image}}
    .hero::before {
      content: '';
      position: absolute;
      inset: 0;
      background-image: url('{{hero_image}}');
      background-size: cover;
      background-position: center;
      opacity: .18;
    }
    {{/has_hero_image}}

    .hero-glass {
      position: relative;
      z-index: 2;
      background: rgba(255,255,255,.18);
      backdrop-filter: blur(24px);
      -webkit-backdrop-filter: blur(24px);
      border: 1.5px solid rgba(255,255,255,.38);
      border-radius: var(--radius-lg);
      padding: 3.5rem 2.5rem;
      max-width: 680px;
      width: 100%;
      box-shadow: 0 24px 72px rgba(0,0,0,.15);
    }

    .hero-eyebrow {
      font-size: .75rem;
      font-weight: 700;
      letter-spacing: .2em;
      text-transform: uppercase;
      color: rgba(255,255,255,.75);
      margin-bottom: 1rem;
    }

    .hero-headline {
      font-size: clamp(2.2rem, 6vw, 4.2rem);
      font-weight: 700;
      line-height: 1.1;
      color: #fff;
      margin-bottom: 1rem;
    }

    .hero-sub {
      font-size: clamp(.97rem, 2.2vw, 1.15rem);
      font-weight: 400;
      color: rgba(255,255,255,.88);
      max-width: 480px;
      margin-inline: auto;
      margin-bottom: 1.75rem;
    }

    .hero-rating {
      display: inline-flex;
      align-items: center;
      gap: .5rem;
      background: rgba(255,255,255,.15);
      border: 1px solid rgba(255,255,255,.3);
      border-radius: 50px;
      padding: .4rem 1.1rem;
      font-size: .88rem;
      font-weight: 600;
      color: #fff;
      margin-bottom: 2rem;
    }
    .hero-rating .stars { color: #f5c842; }

    .hero-cta-wrap { display: flex; flex-wrap: wrap; gap: .875rem; justify-content: center; }

    /* ══════════════════════════════════════════════════════════════
       2. SERVICES
    ══════════════════════════════════════════════════════════════ */
    .services {
      padding: 5.5rem 0;
      background: var(--clr-surface);
    }

    .section-header { text-align: center; margin-bottom: 3rem; }
    .section-header .label { margin-bottom: .6rem; }

    .section-title {
      font-size: clamp(1.75rem, 4vw, 2.75rem);
      font-weight: 700;
      color: var(--clr-primary);
      line-height: 1.18;
    }

    .section-subtitle {
      margin-top: .65rem;
      font-size: .98rem;
      color: var(--clr-muted);
      max-width: 520px;
      margin-inline: auto;
    }

    .services-grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 1.25rem;
    }

    .service-card {
      background: var(--clr-bg);
      border: 1.5px solid rgba(0,0,0,.06);
      border-radius: var(--radius-md);
      padding: 2rem 1.75rem;
      box-shadow: var(--shadow-sm);
      transition: transform var(--transition), box-shadow var(--transition), border-color var(--transition);
      position: relative;
      overflow: hidden;
    }
    .service-card::before {
      content: '';
      position: absolute;
      top: 0; left: 0; right: 0;
      height: 4px;
      background: linear-gradient(90deg, var(--clr-accent), var(--clr-secondary));
      opacity: 0;
      transition: opacity var(--transition);
    }
    .service-card:hover { transform: translateY(-6px); box-shadow: var(--shadow-md); }
    .service-card:hover::before { opacity: 1; }

    .service-card h3 {
      font-size: 1.12rem;
      font-weight: 700;
      color: var(--clr-primary);
      margin-bottom: .5rem;
    }
    .service-card p {
      font-size: .92rem;
      color: var(--clr-muted);
      line-height: 1.6;
    }

    /* ══════════════════════════════════════════════════════════════
       3. ABOUT
    ══════════════════════════════════════════════════════════════ */
    .about {
      padding: 5.5rem 0;
      background: var(--clr-bg);
    }

    .about-inner {
      display: grid;
      grid-template-columns: 1fr;
      gap: 3rem;
      align-items: center;
    }

    .about-text .label { margin-bottom: .7rem; }

    .about-title {
      font-size: clamp(1.6rem, 4vw, 2.5rem);
      font-weight: 700;
      line-height: 1.22;
      color: var(--clr-primary);
      margin-bottom: 1.1rem;
    }

    .about-body {
      font-size: 1rem;
      color: var(--clr-muted);
      line-height: 1.78;
    }

    .about-accent-bar {
      width: 48px;
      height: 4px;
      background: linear-gradient(90deg, var(--clr-accent), var(--clr-secondary));
      border-radius: 4px;
      margin-top: 1.5rem;
    }

    .about-img-wrap {
      border-radius: var(--radius-lg);
      overflow: hidden;
      box-shadow: var(--shadow-lg);
      aspect-ratio: 4 / 3;
      background: color-mix(in srgb, var(--clr-accent) 12%, var(--clr-surface));
    }
    .about-img-wrap img { width: 100%; height: 100%; object-fit: cover; transition: transform .6s ease; }
    .about-img-wrap:hover img { transform: scale(1.04); }

    /* ══════════════════════════════════════════════════════════════
       4. WHY / HOURS
    ══════════════════════════════════════════════════════════════ */
    .why-hours {
      padding: 5.5rem 0;
      background: linear-gradient(135deg, color-mix(in srgb, var(--clr-accent) 8%, var(--clr-surface)) 0%, var(--clr-surface) 100%);
    }

    .why-hours-body {
      max-width: 720px;
      margin-inline: auto;
      font-size: .98rem;
      color: var(--clr-muted);
      line-height: 1.75;
    }

    .hours-table { width: 100%; border-collapse: collapse; font-size: .93rem; }
    .hours-table tr { border-bottom: 1px solid rgba(0,0,0,.06); }
    .hours-table tr:last-child { border-bottom: none; }
    .hours-table td { padding: .65rem .5rem; color: var(--clr-text); }
    .hours-table td:first-child { font-weight: 600; color: var(--clr-primary); width: 42%; }

    .why-list { display: grid; grid-template-columns: 1fr; gap: 1.5rem; max-width: 760px; margin-inline: auto; }
    .why-item { display: flex; gap: 1rem; align-items: flex-start; }
    .why-icon {
      flex-shrink: 0;
      width: 48px; height: 48px;
      background: linear-gradient(135deg, color-mix(in srgb, var(--clr-accent) 20%, transparent), color-mix(in srgb, var(--clr-secondary) 20%, transparent));
      border-radius: var(--radius-sm);
      display: flex; align-items: center; justify-content: center;
      font-size: 1.4rem;
    }
    .why-item-title { font-size: 1.05rem; font-weight: 700; color: var(--clr-primary); margin-bottom: .25rem; }
    .why-item-desc { font-size: .9rem; color: var(--clr-muted); line-height: 1.55; }

    /* ══════════════════════════════════════════════════════════════
       5. CONTACT
    ══════════════════════════════════════════════════════════════ */
    .contact {
      padding: 5.5rem 0;
      background: linear-gradient(135deg, var(--clr-primary) 0%, var(--clr-secondary) 100%);
      color: #fff;
      text-align: center;
    }
    .contact .section-title { color: #fff; }
    .contact .section-subtitle { color: rgba(255,255,255,.7); }

    .contact-cards {
      display: grid;
      grid-template-columns: 1fr;
      gap: 1rem;
      margin: 2.5rem 0;
      max-width: 640px;
      margin-inline: auto;
    }

    .contact-card {
      background: rgba(255,255,255,.14);
      backdrop-filter: blur(12px);
      border: 1px solid rgba(255,255,255,.25);
      border-radius: var(--radius-md);
      padding: 1.4rem 1.75rem;
      display: flex;
      align-items: center;
      gap: 1rem;
      text-align: left;
      transition: background var(--transition), transform var(--transition);
    }
    .contact-card:hover { background: rgba(255,255,255,.22); transform: translateY(-2px); }
    .contact-card-icon { flex-shrink: 0; font-size: 1.5rem; width: 42px; text-align: center; }
    .contact-card-label { font-size: .72rem; font-weight: 700; letter-spacing: .12em; text-transform: uppercase; color: rgba(255,255,255,.55); margin-bottom: .25rem; }
    .contact-card-value { font-size: .97rem; font-weight: 600; color: #fff; word-break: break-word; }
    .contact-card a { color: #fff; }
    .contact-card a:hover { text-decoration: underline; }

    .contact-cta { margin-top: 2.5rem; }

    /* ══════════════════════════════════════════════════════════════
       6. FOOTER
    ══════════════════════════════════════════════════════════════ */
    .footer {
      background: color-mix(in srgb, var(--clr-primary) 85%, #000);
      color: rgba(255,255,255,.5);
      padding: 2rem 1.25rem;
      text-align: center;
      font-size: .82rem;
      letter-spacing: .03em;
    }
    .footer strong { color: rgba(255,255,255,.85); font-size: .95rem; }
    .footer-divider { display: inline-block; margin-inline: .5rem; opacity: .4; }

    /* ── Responsive ── */
    @media (min-width: 768px) {
      .services-grid { grid-template-columns: repeat(2, 1fr); gap: 1.5rem; }
      .about-inner { grid-template-columns: 1fr 1fr; gap: 4rem; }
      .why-list { grid-template-columns: repeat(3, 1fr); gap: 2rem; }
      .contact-cards { grid-template-columns: 1fr 1fr; }
      .hero-glass { padding: 4rem 3.5rem; }
    }
    @media (min-width: 1024px) {
      .services-grid { grid-template-columns: repeat(3, 1fr); }
    }
  </style>
</head>
<body>

  <!-- 1. HERO -->
  <section class="hero">
    <div class="hero-glass">
      <p class="hero-eyebrow">{{business_name}}</p>
      <h1 class="hero-headline">{{headline}}</h1>
      <p class="hero-sub">{{subheadline}}</p>
      <div class="hero-rating" aria-label="Rating">
        <span class="stars">{{rating}}</span>
      </div>
      <div class="hero-cta-wrap">
        <a href="#contact" class="btn btn-primary">{{cta_text}}</a>
        <a href="#services" class="btn btn-outline">Our Services</a>
      </div>
    </div>
  </section>

  <!-- 2. SERVICES -->
  <section class="services" id="services">
    <div class="container">
      <div class="section-header">
        <p class="label">What We Offer</p>
        <h2 class="section-title">Our Treatments</h2>
        <p class="section-subtitle">Tailored experiences designed to restore, refresh, and renew.</p>
      </div>
      <div class="services-grid">
        {{services}}
      </div>
    </div>
  </section>

  <!-- 3. ABOUT -->
  <section class="about" id="about">
    <div class="container">
      <div class="about-inner">
        <div class="about-text">
          <p class="label">Our Story</p>
          <h2 class="about-title">A Space Built<br>for You</h2>
          <div class="about-body">{{about}}</div>
          <div class="about-accent-bar"></div>
        </div>
        <div>
          <div class="about-img-wrap">
            <img
              src="https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800&q=80"
              alt="{{business_name}} — our space"
              loading="lazy"
              width="800"
              height="600"
            />
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- 4. WHY / HOURS -->
  <section class="why-hours" id="hours">
    <div class="container">
      <div class="section-header">
        <p class="label">Visit Us</p>
        <h2 class="section-title">Hours &amp; Highlights</h2>
      </div>
      <div class="why-hours-body">
        {{why_or_hours}}
      </div>
    </div>
  </section>

  <!-- 5. CONTACT -->
  <section class="contact" id="contact">
    <div class="container">
      <p class="label" style="color:rgba(255,255,255,.55)">Get In Touch</p>
      <h2 class="section-title" style="color:#fff;margin-top:.5rem">Book Your Visit</h2>
      <p class="section-subtitle">Ready when you are. Reach out and we'll take care of the rest.</p>
      <div class="contact-cards">
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">📞</span>
          <div>
            <p class="contact-card-label">Phone</p>
            <p class="contact-card-value">{{business_phone}}</p>
          </div>
        </div>
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">📍</span>
          <div>
            <p class="contact-card-label">Address</p>
            <p class="contact-card-value">{{business_address}}</p>
          </div>
        </div>
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">🌐</span>
          <div>
            <p class="contact-card-label">Website</p>
            <p class="contact-card-value">{{business_website}}</p>
          </div>
        </div>
      </div>
      <div class="contact-cta">
        <a href="tel:{{business_phone_raw}}" class="btn btn-primary">{{cta_text}}</a>
      </div>
    </div>
  </section>

  <!-- 6. FOOTER -->
  <footer class="footer">
    <strong>{{business_name}}</strong>
    <span class="footer-divider">·</span>
    Powered by LeadForge
  </footer>

</body>
</html>`
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. EDITORIAL LUXURY — Law, finance, real estate, consulting
// ─────────────────────────────────────────────────────────────────────────────
export function editorialLuxury(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{business_name}}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,500;0,600;0,700;1,400;1,600&family=Inter:wght@300;400;500;600&display=swap');

    :root {
      --clr-primary:   {{clr-primary}};
      --clr-secondary: {{clr-secondary}};
      --clr-accent:    {{clr-accent}};
      --clr-bg:        {{clr-bg}};
      --clr-surface:   {{clr-surface}};
      --clr-text:      {{clr-text}};
      --clr-muted:     {{clr-muted}};

      --radius-sm:  4px;
      --radius-md:  8px;
      --radius-lg:  12px;
      --shadow-sm:  0 1px 4px rgba(0,0,0,.06);
      --shadow-md:  0 4px 20px rgba(0,0,0,.08);
      --shadow-lg:  0 12px 40px rgba(0,0,0,.10);
      --transition: .3s ease;
      --container:  1080px;
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html { scroll-behavior: smooth; }
    body {
      font-family: 'Inter', sans-serif;
      background-color: var(--clr-bg);
      color: var(--clr-text);
      line-height: 1.65;
      -webkit-font-smoothing: antialiased;
    }
    img { display: block; max-width: 100%; }
    a { color: inherit; text-decoration: none; }

    .container { width: 100%; max-width: var(--container); margin-inline: auto; padding-inline: 1.5rem; }

    /* ── Buttons ── */
    .btn {
      display: inline-flex;
      align-items: center;
      gap: .5rem;
      font-family: 'Inter', sans-serif;
      font-weight: 500;
      font-size: .85rem;
      letter-spacing: .1em;
      text-transform: uppercase;
      padding: .875rem 2.5rem;
      border-radius: var(--radius-sm);
      border: 1.5px solid transparent;
      cursor: pointer;
      transition: transform var(--transition), box-shadow var(--transition), background-color var(--transition);
      white-space: nowrap;
    }
    .btn-primary {
      background-color: var(--clr-primary);
      color: #fff;
      border-color: var(--clr-primary);
    }
    .btn-primary:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(0,0,0,.18); filter: brightness(1.06); }
    .btn-outline-light {
      background: transparent;
      color: #fff;
      border-color: rgba(255,255,255,.5);
    }
    .btn-outline-light:hover { background: rgba(255,255,255,.1); border-color: #fff; transform: translateY(-1px); }

    /* ── Editorial label ── */
    .overline {
      font-family: 'Inter', sans-serif;
      font-size: .68rem;
      font-weight: 600;
      letter-spacing: .22em;
      text-transform: uppercase;
      color: var(--clr-accent);
    }

    .divider {
      width: 100%;
      height: 1px;
      background: linear-gradient(90deg, transparent, var(--clr-accent), transparent);
      opacity: .35;
      margin: 1.5rem 0;
    }

    /* ══════════════════════════════════════════════════════════════
       1. HERO
    ══════════════════════════════════════════════════════════════ */
    .hero {
      min-height: 100svh;
      display: flex;
      align-items: center;
      justify-content: center;
      position: relative;
      overflow: hidden;
      background-color: var(--clr-primary);
      text-align: center;
      padding: 5rem 1.5rem;
    }

    {{#has_hero_image}}
    .hero::before {
      content: '';
      position: absolute;
      inset: 0;
      background-image: url('{{hero_image}}');
      background-size: cover;
      background-position: center;
      opacity: .12;
    }
    {{/has_hero_image}}

    .hero-content {
      position: relative;
      z-index: 2;
      max-width: 780px;
    }

    .hero-overline {
      font-size: .7rem;
      font-weight: 600;
      letter-spacing: .28em;
      text-transform: uppercase;
      color: rgba(255,255,255,.55);
      margin-bottom: 2rem;
    }

    .hero-rule {
      width: 40px;
      height: 1px;
      background: var(--clr-accent);
      margin: 0 auto 2rem;
    }

    .hero-headline {
      font-family: 'Playfair Display', serif;
      font-size: clamp(2.8rem, 6.5vw, 5.5rem);
      font-weight: 400;
      line-height: 1.1;
      letter-spacing: -.01em;
      color: #fff;
      margin-bottom: 1.5rem;
    }

    .hero-headline em { font-style: italic; color: var(--clr-accent); }

    .hero-sub {
      font-size: clamp(.95rem, 2vw, 1.1rem);
      font-weight: 300;
      color: rgba(255,255,255,.72);
      max-width: 540px;
      margin-inline: auto;
      margin-bottom: 1.5rem;
      letter-spacing: .01em;
    }

    .hero-rating {
      display: inline-flex;
      align-items: center;
      gap: .5rem;
      background: rgba(255,255,255,.08);
      border: 1px solid rgba(255,255,255,.18);
      border-radius: var(--radius-sm);
      padding: .4rem 1.2rem;
      font-size: .85rem;
      font-weight: 500;
      color: rgba(255,255,255,.8);
      margin-bottom: 2.5rem;
      letter-spacing: .05em;
    }
    .hero-rating .stars { color: #f5c842; }

    .hero-cta-wrap { display: flex; flex-wrap: wrap; gap: 1rem; justify-content: center; }

    /* ══════════════════════════════════════════════════════════════
       2. SERVICES
    ══════════════════════════════════════════════════════════════ */
    .services {
      padding: 6rem 0;
      background: var(--clr-bg);
    }

    .section-header { text-align: center; margin-bottom: 3.5rem; }
    .section-header .overline { margin-bottom: .75rem; }

    .section-title {
      font-family: 'Playfair Display', serif;
      font-size: clamp(1.8rem, 4vw, 3rem);
      font-weight: 400;
      color: var(--clr-primary);
      line-height: 1.2;
    }

    .section-subtitle {
      margin-top: .75rem;
      font-size: .95rem;
      font-weight: 300;
      color: var(--clr-muted);
      max-width: 500px;
      margin-inline: auto;
      letter-spacing: .01em;
    }

    .services-grid { display: grid; grid-template-columns: 1fr; gap: 1.5px; background: rgba(0,0,0,.08); }

    .service-card {
      background: var(--clr-bg);
      padding: 2.5rem 2rem;
      transition: background var(--transition);
      position: relative;
    }
    .service-card::after {
      content: '';
      position: absolute;
      bottom: 0; left: 2rem; right: 2rem;
      height: 1px;
      background: rgba(0,0,0,.06);
    }
    .service-card:hover { background: var(--clr-surface); }
    .service-card:hover .service-num { color: var(--clr-accent); }

    .service-num {
      display: block;
      font-size: .7rem;
      font-weight: 600;
      letter-spacing: .2em;
      text-transform: uppercase;
      color: var(--clr-muted);
      margin-bottom: .75rem;
      transition: color var(--transition);
    }

    .service-card h3 {
      font-family: 'Playfair Display', serif;
      font-size: 1.22rem;
      font-weight: 500;
      color: var(--clr-primary);
      margin-bottom: .6rem;
    }

    .service-card p {
      font-size: .92rem;
      font-weight: 300;
      color: var(--clr-muted);
      line-height: 1.65;
    }

    /* ══════════════════════════════════════════════════════════════
       3. ABOUT
    ══════════════════════════════════════════════════════════════ */
    .about {
      padding: 6rem 0;
      background: var(--clr-surface);
    }

    .about-inner { display: grid; grid-template-columns: 1fr; gap: 3.5rem; align-items: center; }
    .about-text .overline { margin-bottom: .75rem; }

    .about-title {
      font-family: 'Playfair Display', serif;
      font-size: clamp(1.7rem, 4vw, 2.8rem);
      font-weight: 400;
      line-height: 1.22;
      color: var(--clr-primary);
      margin-bottom: 1.25rem;
    }

    .about-body { font-size: .97rem; font-weight: 300; color: var(--clr-muted); line-height: 1.85; }
    .about-body p + p { margin-top: 1rem; }

    .about-rule {
      width: 36px;
      height: 1px;
      background: var(--clr-accent);
      margin-top: 2rem;
    }

    .about-img-wrap {
      border-radius: var(--radius-md);
      overflow: hidden;
      box-shadow: var(--shadow-lg);
      aspect-ratio: 3 / 4;
      background: color-mix(in srgb, var(--clr-primary) 12%, var(--clr-surface));
    }
    .about-img-wrap img { width: 100%; height: 100%; object-fit: cover; transition: transform .6s ease; }
    .about-img-wrap:hover img { transform: scale(1.03); }

    /* ══════════════════════════════════════════════════════════════
       4. WHY / HOURS
    ══════════════════════════════════════════════════════════════ */
    .why-hours { padding: 6rem 0; background: var(--clr-bg); }

    .why-hours-body { max-width: 720px; margin-inline: auto; font-size: .97rem; font-weight: 300; color: var(--clr-muted); line-height: 1.8; }

    .hours-table { width: 100%; border-collapse: collapse; font-size: .93rem; }
    .hours-table tr { border-bottom: 1px solid rgba(0,0,0,.06); }
    .hours-table tr:last-child { border-bottom: none; }
    .hours-table td { padding: .75rem .5rem; color: var(--clr-text); font-weight: 300; }
    .hours-table td:first-child { font-weight: 500; color: var(--clr-primary); width: 42%; letter-spacing: .02em; }

    .why-list { display: grid; grid-template-columns: 1fr; gap: 2rem; max-width: 760px; margin-inline: auto; }
    .why-item { display: flex; gap: 1.25rem; align-items: flex-start; }
    .why-icon {
      flex-shrink: 0; width: 44px; height: 44px;
      background: color-mix(in srgb, var(--clr-accent) 10%, transparent);
      border: 1px solid color-mix(in srgb, var(--clr-accent) 25%, transparent);
      border-radius: var(--radius-sm);
      display: flex; align-items: center; justify-content: center;
      font-size: 1.25rem;
    }
    .why-item-title { font-family: 'Playfair Display', serif; font-size: 1.05rem; font-weight: 500; color: var(--clr-primary); margin-bottom: .3rem; }
    .why-item-desc { font-size: .9rem; font-weight: 300; color: var(--clr-muted); line-height: 1.6; }

    /* ══════════════════════════════════════════════════════════════
       5. CONTACT
    ══════════════════════════════════════════════════════════════ */
    .contact { padding: 6rem 0; background: var(--clr-primary); color: #fff; text-align: center; }
    .contact .section-title { color: #fff; font-family: 'Playfair Display', serif; }
    .contact .section-subtitle { color: rgba(255,255,255,.6); }

    .contact-cards { display: grid; grid-template-columns: 1fr; gap: 1px; background: rgba(255,255,255,.12); margin: 3rem 0; max-width: 680px; margin-inline: auto; }
    .contact-card {
      background: color-mix(in srgb, var(--clr-primary) 80%, #000);
      padding: 1.75rem 2rem;
      display: flex; align-items: center; gap: 1.25rem; text-align: left;
      transition: background var(--transition);
    }
    .contact-card:hover { background: color-mix(in srgb, var(--clr-primary) 70%, #000); }
    .contact-card-icon { flex-shrink: 0; font-size: 1.35rem; width: 38px; text-align: center; opacity: .7; }
    .contact-card-label { font-size: .66rem; font-weight: 600; letter-spacing: .2em; text-transform: uppercase; color: rgba(255,255,255,.45); margin-bottom: .3rem; }
    .contact-card-value { font-size: .95rem; font-weight: 400; color: rgba(255,255,255,.9); word-break: break-word; }
    .contact-card a { color: rgba(255,255,255,.9); }
    .contact-card a:hover { color: #fff; text-decoration: underline; }

    .contact-cta { margin-top: 3rem; }

    /* ══════════════════════════════════════════════════════════════
       6. FOOTER
    ══════════════════════════════════════════════════════════════ */
    .footer {
      background: #000;
      color: rgba(255,255,255,.38);
      padding: 2rem 1.5rem;
      text-align: center;
      font-size: .8rem;
      letter-spacing: .06em;
      text-transform: uppercase;
    }
    .footer strong { color: rgba(255,255,255,.7); font-family: 'Playfair Display', serif; font-size: .88rem; letter-spacing: .05em; text-transform: none; }
    .footer-divider { display: inline-block; margin-inline: .75rem; opacity: .3; }

    /* ── Responsive ── */
    @media (min-width: 768px) {
      .services-grid { grid-template-columns: repeat(2, 1fr); }
      .about-inner { grid-template-columns: 1fr 1fr; gap: 5rem; }
      .why-list { grid-template-columns: repeat(3, 1fr); }
      .contact-cards { grid-template-columns: 1fr 1fr; }
    }
    @media (min-width: 1024px) {
      .services-grid { grid-template-columns: repeat(3, 1fr); }
    }
  </style>
</head>
<body>

  <!-- 1. HERO -->
  <section class="hero">
    <div class="hero-content">
      <p class="hero-overline">{{business_name}}</p>
      <div class="hero-rule"></div>
      <h1 class="hero-headline">{{headline}}</h1>
      <p class="hero-sub">{{subheadline}}</p>
      <div class="hero-rating" aria-label="Rating">
        <span class="stars">{{rating}}</span>
      </div>
      <div class="hero-cta-wrap">
        <a href="#contact" class="btn btn-primary">{{cta_text}}</a>
        <a href="#services" class="btn btn-outline-light">Our Practice</a>
      </div>
    </div>
  </section>

  <!-- 2. SERVICES -->
  <section class="services" id="services">
    <div class="container">
      <div class="section-header">
        <p class="overline">Practice Areas</p>
        <h2 class="section-title">What We Do</h2>
        <p class="section-subtitle">Comprehensive expertise, tailored to your unique situation.</p>
      </div>
      <div class="services-grid">
        {{services}}
      </div>
    </div>
  </section>

  <!-- 3. ABOUT -->
  <section class="about" id="about">
    <div class="container">
      <div class="about-inner">
        <div class="about-text">
          <p class="overline">Our Firm</p>
          <h2 class="about-title">Experience You<br>Can Rely On</h2>
          <div class="about-body">{{about}}</div>
          <div class="about-rule"></div>
        </div>
        <div>
          <div class="about-img-wrap">
            <img
              src="https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=80"
              alt="{{business_name}} — our office"
              loading="lazy"
              width="800"
              height="1067"
            />
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- 4. WHY / HOURS -->
  <section class="why-hours" id="hours">
    <div class="container">
      <div class="section-header">
        <p class="overline">Why Choose Us</p>
        <h2 class="section-title">Our Commitment</h2>
      </div>
      <div class="why-hours-body">{{why_or_hours}}</div>
    </div>
  </section>

  <!-- 5. CONTACT -->
  <section class="contact" id="contact">
    <div class="container">
      <p class="overline" style="color:rgba(255,255,255,.4)">Contact</p>
      <h2 class="section-title" style="margin-top:.75rem">Schedule a Consultation</h2>
      <p class="section-subtitle">Confidential. Professional. Discreet.</p>
      <div class="contact-cards">
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">📞</span>
          <div>
            <p class="contact-card-label">Phone</p>
            <p class="contact-card-value">{{business_phone}}</p>
          </div>
        </div>
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">📍</span>
          <div>
            <p class="contact-card-label">Address</p>
            <p class="contact-card-value">{{business_address}}</p>
          </div>
        </div>
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">🌐</span>
          <div>
            <p class="contact-card-label">Website</p>
            <p class="contact-card-value">{{business_website}}</p>
          </div>
        </div>
      </div>
      <div class="contact-cta">
        <a href="tel:{{business_phone_raw}}" class="btn btn-primary" style="background:#fff;color:var(--clr-primary)">{{cta_text}}</a>
      </div>
    </div>
  </section>

  <!-- 6. FOOTER -->
  <footer class="footer">
    <strong>{{business_name}}</strong>
    <span class="footer-divider">·</span>
    Powered by LeadForge
  </footer>

</body>
</html>`
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. BOLD MODERN — Auto, construction, trades
// ─────────────────────────────────────────────────────────────────────────────
export function boldModern(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{business_name}}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=Inter:wght@300;400;500&display=swap');

    :root {
      --clr-primary:   {{clr-primary}};
      --clr-secondary: {{clr-secondary}};
      --clr-accent:    {{clr-accent}};
      --clr-bg:        {{clr-bg}};
      --clr-surface:   {{clr-surface}};
      --clr-text:      {{clr-text}};
      --clr-muted:     {{clr-muted}};

      --radius-sm:  4px;
      --radius-md:  8px;
      --radius-lg:  14px;
      --shadow-sm:  0 2px 8px rgba(0,0,0,.12);
      --shadow-md:  0 6px 24px rgba(0,0,0,.18);
      --shadow-lg:  0 16px 48px rgba(0,0,0,.22);
      --transition: .3s ease;
      --container:  1100px;
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html { scroll-behavior: smooth; }
    body {
      font-family: 'Inter', sans-serif;
      background-color: var(--clr-bg);
      color: var(--clr-text);
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    img { display: block; max-width: 100%; }
    a { color: inherit; text-decoration: none; }

    .container { width: 100%; max-width: var(--container); margin-inline: auto; padding-inline: 1.25rem; }

    /* ── Buttons ── */
    .btn {
      display: inline-flex;
      align-items: center;
      gap: .5rem;
      font-family: 'Space Grotesk', sans-serif;
      font-weight: 700;
      font-size: .9rem;
      letter-spacing: .04em;
      text-transform: uppercase;
      padding: 1rem 2.5rem;
      border-radius: var(--radius-sm);
      border: 2px solid transparent;
      cursor: pointer;
      transition: transform var(--transition), box-shadow var(--transition), filter var(--transition);
      white-space: nowrap;
    }
    .btn-primary { background: var(--clr-accent); color: #fff; border-color: var(--clr-accent); box-shadow: var(--shadow-sm); }
    .btn-primary:hover { transform: translateY(-2px); box-shadow: var(--shadow-md); filter: brightness(1.08); }
    .btn-outline { background: transparent; color: #fff; border-color: rgba(255,255,255,.5); }
    .btn-outline:hover { background: rgba(255,255,255,.1); border-color: #fff; transform: translateY(-2px); }

    /* ── Label ── */
    .label {
      font-family: 'Space Grotesk', sans-serif;
      font-size: .72rem;
      font-weight: 700;
      letter-spacing: .16em;
      text-transform: uppercase;
      color: var(--clr-accent);
    }

    /* ══════════════════════════════════════════════════════════════
       1. HERO
    ══════════════════════════════════════════════════════════════ */
    .hero {
      min-height: 100svh;
      display: flex;
      align-items: center;
      position: relative;
      overflow: hidden;
      background-color: #0d0d0d;
      padding: 0;
    }

    .hero-accent-bar {
      position: absolute;
      top: 0; left: 0; right: 0;
      height: 6px;
      background: var(--clr-accent);
    }

    {{#has_hero_image}}
    .hero-bg {
      position: absolute;
      inset: 0;
      background-image: url('{{hero_image}}');
      background-size: cover;
      background-position: center;
      opacity: .14;
    }
    {{/has_hero_image}}

    .hero-content {
      position: relative;
      z-index: 2;
      padding: 6rem 1.25rem 5rem;
      max-width: 900px;
    }

    .hero-eyebrow {
      display: inline-block;
      background: var(--clr-accent);
      color: #fff;
      font-family: 'Space Grotesk', sans-serif;
      font-size: .72rem;
      font-weight: 700;
      letter-spacing: .18em;
      text-transform: uppercase;
      padding: .3rem .85rem;
      border-radius: var(--radius-sm);
      margin-bottom: 1.75rem;
    }

    .hero-headline {
      font-family: 'Space Grotesk', sans-serif;
      font-size: clamp(3rem, 8vw, 7rem);
      font-weight: 700;
      line-height: 1.0;
      letter-spacing: -.02em;
      color: #fff;
      margin-bottom: 1.25rem;
    }

    .hero-sub {
      font-size: clamp(.97rem, 2vw, 1.2rem);
      font-weight: 300;
      color: rgba(255,255,255,.65);
      max-width: 540px;
      margin-bottom: 2rem;
      line-height: 1.65;
    }

    .hero-rating {
      display: inline-flex;
      align-items: center;
      gap: .5rem;
      border: 1px solid rgba(255,255,255,.2);
      border-radius: var(--radius-sm);
      padding: .45rem 1.1rem;
      font-size: .88rem;
      font-weight: 600;
      color: rgba(255,255,255,.8);
      margin-bottom: 2.25rem;
    }
    .hero-rating .stars { color: #f5c842; }

    .hero-cta-wrap { display: flex; flex-wrap: wrap; gap: 1rem; }

    /* ══════════════════════════════════════════════════════════════
       2. SERVICES
    ══════════════════════════════════════════════════════════════ */
    .services { padding: 5.5rem 0; background: var(--clr-bg); }

    .section-header { margin-bottom: 3rem; }
    .section-header.center { text-align: center; }
    .section-header .label { margin-bottom: .6rem; }

    .section-title {
      font-family: 'Space Grotesk', sans-serif;
      font-size: clamp(1.8rem, 4.5vw, 3.2rem);
      font-weight: 700;
      color: var(--clr-primary);
      line-height: 1.12;
      letter-spacing: -.02em;
    }

    .section-subtitle {
      margin-top: .65rem;
      font-size: .97rem;
      color: var(--clr-muted);
      max-width: 520px;
    }
    .section-header.center .section-subtitle { margin-inline: auto; }

    .services-grid { display: grid; grid-template-columns: 1fr; gap: 1.5px; background: rgba(0,0,0,.1); }

    .service-card {
      background: var(--clr-surface);
      padding: 2rem 1.75rem;
      border-left: 4px solid transparent;
      transition: border-color var(--transition), background var(--transition);
    }
    .service-card:hover { border-left-color: var(--clr-accent); background: var(--clr-bg); }

    .service-card h3 {
      font-family: 'Space Grotesk', sans-serif;
      font-size: 1.18rem;
      font-weight: 700;
      color: var(--clr-primary);
      margin-bottom: .5rem;
      letter-spacing: -.01em;
    }
    .service-card p { font-size: .92rem; color: var(--clr-muted); line-height: 1.6; }

    /* ══════════════════════════════════════════════════════════════
       3. ABOUT
    ══════════════════════════════════════════════════════════════ */
    .about { padding: 5.5rem 0; background: var(--clr-surface); }

    .about-inner { display: grid; grid-template-columns: 1fr; gap: 3rem; align-items: center; }
    .about-text .label { margin-bottom: .6rem; }

    .about-title {
      font-family: 'Space Grotesk', sans-serif;
      font-size: clamp(1.6rem, 4vw, 2.8rem);
      font-weight: 700;
      line-height: 1.14;
      letter-spacing: -.02em;
      color: var(--clr-primary);
      margin-bottom: 1.25rem;
    }

    .about-body { font-size: 1rem; color: var(--clr-muted); line-height: 1.75; }
    .about-body p + p { margin-top: .9rem; }

    .about-accent-bar { width: 48px; height: 4px; background: var(--clr-accent); margin-top: 1.5rem; }

    .about-img-wrap {
      border-radius: var(--radius-md);
      overflow: hidden;
      box-shadow: var(--shadow-lg);
      aspect-ratio: 16 / 10;
      background: color-mix(in srgb, var(--clr-primary) 15%, var(--clr-surface));
    }
    .about-img-wrap img { width: 100%; height: 100%; object-fit: cover; transition: transform .6s ease; }
    .about-img-wrap:hover img { transform: scale(1.04); }

    /* ══════════════════════════════════════════════════════════════
       4. WHY / HOURS
    ══════════════════════════════════════════════════════════════ */
    .why-hours { padding: 5.5rem 0; background: var(--clr-bg); }

    .why-hours-body { max-width: 720px; margin-inline: auto; font-size: .97rem; color: var(--clr-muted); line-height: 1.75; }

    .hours-table { width: 100%; border-collapse: collapse; font-size: .93rem; }
    .hours-table tr { border-bottom: 1px solid rgba(0,0,0,.08); }
    .hours-table tr:last-child { border-bottom: none; }
    .hours-table td { padding: .7rem .5rem; color: var(--clr-text); }
    .hours-table td:first-child { font-family: 'Space Grotesk', sans-serif; font-weight: 600; color: var(--clr-primary); width: 42%; }

    .why-list { display: grid; grid-template-columns: 1fr; gap: 1.5rem; max-width: 760px; margin-inline: auto; }
    .why-item { display: flex; gap: 1rem; align-items: flex-start; }
    .why-icon {
      flex-shrink: 0; width: 48px; height: 48px;
      background: color-mix(in srgb, var(--clr-accent) 14%, transparent);
      border: 2px solid color-mix(in srgb, var(--clr-accent) 30%, transparent);
      border-radius: var(--radius-sm);
      display: flex; align-items: center; justify-content: center;
      font-size: 1.4rem;
    }
    .why-item-title { font-family: 'Space Grotesk', sans-serif; font-size: 1.06rem; font-weight: 700; color: var(--clr-primary); margin-bottom: .25rem; letter-spacing: -.01em; }
    .why-item-desc { font-size: .9rem; color: var(--clr-muted); line-height: 1.55; }

    /* ══════════════════════════════════════════════════════════════
       5. CONTACT
    ══════════════════════════════════════════════════════════════ */
    .contact { padding: 5.5rem 0; background: #0d0d0d; color: #fff; }
    .contact .section-title { color: #fff; }
    .contact .section-subtitle { color: rgba(255,255,255,.5); }

    .contact-cards { display: grid; grid-template-columns: 1fr; gap: 1.5px; background: rgba(255,255,255,.1); margin: 3rem 0; max-width: 680px; }
    .contact-card {
      background: #141414;
      padding: 1.5rem 1.75rem;
      display: flex; align-items: center; gap: 1rem; text-align: left;
      border-left: 3px solid transparent;
      transition: border-color var(--transition), background var(--transition);
    }
    .contact-card:hover { border-left-color: var(--clr-accent); background: #1a1a1a; }
    .contact-card-icon { flex-shrink: 0; font-size: 1.35rem; width: 38px; text-align: center; }
    .contact-card-label { font-family: 'Space Grotesk', sans-serif; font-size: .66rem; font-weight: 700; letter-spacing: .18em; text-transform: uppercase; color: rgba(255,255,255,.4); margin-bottom: .25rem; }
    .contact-card-value { font-size: .95rem; font-weight: 500; color: rgba(255,255,255,.9); word-break: break-word; }
    .contact-card a { color: rgba(255,255,255,.9); }
    .contact-card a:hover { color: var(--clr-accent); }

    .contact-cta { margin-top: 2.5rem; }

    /* ══════════════════════════════════════════════════════════════
       6. FOOTER
    ══════════════════════════════════════════════════════════════ */
    .footer {
      background: #000;
      color: rgba(255,255,255,.35);
      padding: 2rem 1.25rem;
      text-align: center;
      font-size: .82rem;
      letter-spacing: .05em;
      text-transform: uppercase;
      border-top: 3px solid var(--clr-accent);
    }
    .footer strong { color: rgba(255,255,255,.75); font-family: 'Space Grotesk', sans-serif; font-size: .88rem; }
    .footer-divider { display: inline-block; margin-inline: .75rem; opacity: .3; }

    /* ── Responsive ── */
    @media (min-width: 768px) {
      .services-grid { grid-template-columns: repeat(2, 1fr); }
      .about-inner { grid-template-columns: 1fr 1fr; gap: 4rem; }
      .why-list { grid-template-columns: repeat(3, 1fr); }
      .contact-cards { grid-template-columns: 1fr 1fr; }
      .hero-content { padding: 7rem 2rem 6rem; }
    }
    @media (min-width: 1024px) {
      .services-grid { grid-template-columns: repeat(3, 1fr); }
      .hero-content { max-width: var(--container); }
    }
  </style>
</head>
<body>

  <!-- 1. HERO -->
  <section class="hero">
    <div class="hero-accent-bar" aria-hidden="true"></div>
    {{#has_hero_image}}
    <div class="hero-bg" aria-hidden="true"></div>
    {{/has_hero_image}}
    <div class="container">
      <div class="hero-content">
        <span class="hero-eyebrow">{{business_name}}</span>
        <h1 class="hero-headline">{{headline}}</h1>
        <p class="hero-sub">{{subheadline}}</p>
        <div class="hero-rating" aria-label="Rating">
          <span class="stars">{{rating}}</span>
        </div>
        <div class="hero-cta-wrap">
          <a href="#contact" class="btn btn-primary">{{cta_text}}</a>
          <a href="#services" class="btn btn-outline">Our Services</a>
        </div>
      </div>
    </div>
  </section>

  <!-- 2. SERVICES -->
  <section class="services" id="services">
    <div class="container">
      <div class="section-header center">
        <p class="label">What We Do</p>
        <h2 class="section-title">Our Services</h2>
        <p class="section-subtitle">Built tough, done right — every time.</p>
      </div>
      <div class="services-grid">
        {{services}}
      </div>
    </div>
  </section>

  <!-- 3. ABOUT -->
  <section class="about" id="about">
    <div class="container">
      <div class="about-inner">
        <div class="about-text">
          <p class="label">About Us</p>
          <h2 class="about-title">We Get<br>the Job Done</h2>
          <div class="about-body">{{about}}</div>
          <div class="about-accent-bar"></div>
        </div>
        <div>
          <div class="about-img-wrap">
            <img
              src="https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800&q=80"
              alt="{{business_name}} — at work"
              loading="lazy"
              width="800"
              height="500"
            />
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- 4. WHY / HOURS -->
  <section class="why-hours" id="hours">
    <div class="container">
      <div class="section-header center">
        <p class="label">Why Choose Us</p>
        <h2 class="section-title">Hours &amp; Highlights</h2>
      </div>
      <div class="why-hours-body">{{why_or_hours}}</div>
    </div>
  </section>

  <!-- 5. CONTACT -->
  <section class="contact" id="contact">
    <div class="container">
      <p class="label" style="color:rgba(255,255,255,.4)">Get a Quote</p>
      <h2 class="section-title" style="color:#fff;margin-top:.5rem">Ready to Start?</h2>
      <p class="section-subtitle">Call us today — free estimates, fast response.</p>
      <div class="contact-cards">
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">📞</span>
          <div>
            <p class="contact-card-label">Phone</p>
            <p class="contact-card-value">{{business_phone}}</p>
          </div>
        </div>
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">📍</span>
          <div>
            <p class="contact-card-label">Address</p>
            <p class="contact-card-value">{{business_address}}</p>
          </div>
        </div>
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">🌐</span>
          <div>
            <p class="contact-card-label">Website</p>
            <p class="contact-card-value">{{business_website}}</p>
          </div>
        </div>
      </div>
      <div class="contact-cta">
        <a href="tel:{{business_phone_raw}}" class="btn btn-primary">{{cta_text}}</a>
      </div>
    </div>
  </section>

  <!-- 6. FOOTER -->
  <footer class="footer">
    <strong>{{business_name}}</strong>
    <span class="footer-divider">·</span>
    Powered by LeadForge
  </footer>

</body>
</html>`
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. FRESH STARTUP — Tech, agencies, marketing, creative
// ─────────────────────────────────────────────────────────────────────────────
export function freshStartup(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{business_name}}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap');

    :root {
      --clr-primary:   {{clr-primary}};
      --clr-secondary: {{clr-secondary}};
      --clr-accent:    {{clr-accent}};
      --clr-bg:        {{clr-bg}};
      --clr-surface:   {{clr-surface}};
      --clr-text:      {{clr-text}};
      --clr-muted:     {{clr-muted}};

      --radius-sm:  8px;
      --radius-md:  16px;
      --radius-lg:  24px;
      --radius-xl:  36px;
      --shadow-sm:  0 1px 6px rgba(0,0,0,.06);
      --shadow-md:  0 4px 20px rgba(0,0,0,.09);
      --shadow-lg:  0 12px 48px rgba(0,0,0,.12);
      --transition: .3s ease;
      --container:  1080px;
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html { scroll-behavior: smooth; }
    body {
      font-family: 'Outfit', sans-serif;
      background-color: var(--clr-bg);
      color: var(--clr-text);
      line-height: 1.65;
      -webkit-font-smoothing: antialiased;
    }
    img { display: block; max-width: 100%; }
    a { color: inherit; text-decoration: none; }

    .container { width: 100%; max-width: var(--container); margin-inline: auto; padding-inline: 1.25rem; }

    /* ── Gradient helpers ── */
    .grad-text {
      background: linear-gradient(135deg, var(--clr-accent), var(--clr-secondary));
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }

    /* ── Buttons ── */
    .btn {
      display: inline-flex;
      align-items: center;
      gap: .5rem;
      font-family: 'Outfit', sans-serif;
      font-weight: 600;
      font-size: .93rem;
      padding: .875rem 2rem;
      border-radius: 50px;
      border: none;
      cursor: pointer;
      transition: transform var(--transition), box-shadow var(--transition), filter var(--transition);
      white-space: nowrap;
    }
    .btn-primary {
      background: linear-gradient(135deg, var(--clr-accent), var(--clr-secondary));
      color: #fff;
      box-shadow: 0 4px 18px rgba(0,0,0,.18);
    }
    .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 28px rgba(0,0,0,.22); filter: brightness(1.06); }
    .btn-ghost {
      background: rgba(0,0,0,.05);
      color: var(--clr-text);
      border: 1.5px solid rgba(0,0,0,.1);
    }
    .btn-ghost:hover { background: rgba(0,0,0,.08); transform: translateY(-2px); }

    /* ── Labels ── */
    .label {
      display: inline-block;
      font-size: .72rem;
      font-weight: 700;
      letter-spacing: .14em;
      text-transform: uppercase;
      color: var(--clr-accent);
    }

    /* ── Pill badge ── */
    .pill {
      display: inline-flex;
      align-items: center;
      gap: .4rem;
      background: color-mix(in srgb, var(--clr-accent) 10%, transparent);
      border: 1.5px solid color-mix(in srgb, var(--clr-accent) 25%, transparent);
      color: var(--clr-accent);
      border-radius: 50px;
      padding: .3rem 1rem;
      font-size: .8rem;
      font-weight: 600;
    }

    /* ══════════════════════════════════════════════════════════════
       1. HERO
    ══════════════════════════════════════════════════════════════ */
    .hero {
      min-height: 100svh;
      display: flex;
      align-items: center;
      justify-content: center;
      position: relative;
      overflow: hidden;
      background: var(--clr-bg);
      text-align: center;
      padding: 5rem 1.25rem;
    }

    .hero::before {
      content: '';
      position: absolute;
      top: -30%;
      left: 50%;
      transform: translateX(-50%);
      width: 800px;
      height: 800px;
      background: radial-gradient(circle, color-mix(in srgb, var(--clr-accent) 12%, transparent) 0%, transparent 70%);
      pointer-events: none;
    }

    {{#has_hero_image}}
    .hero::after {
      content: '';
      position: absolute;
      inset: 0;
      background-image: url('{{hero_image}}');
      background-size: cover;
      background-position: center;
      opacity: .05;
      z-index: 0;
    }
    {{/has_hero_image}}

    .hero-content {
      position: relative;
      z-index: 2;
      max-width: 760px;
    }

    .hero-address-pill {
      margin-bottom: 1.5rem;
    }

    .hero-headline {
      font-size: clamp(2.5rem, 6.5vw, 5rem);
      font-weight: 800;
      line-height: 1.08;
      letter-spacing: -.03em;
      color: var(--clr-text);
      margin-bottom: 1.25rem;
    }

    .hero-sub {
      font-size: clamp(.97rem, 2.2vw, 1.18rem);
      font-weight: 400;
      color: var(--clr-muted);
      max-width: 520px;
      margin-inline: auto;
      margin-bottom: 1.75rem;
      line-height: 1.7;
    }

    .hero-rating {
      display: inline-flex;
      align-items: center;
      gap: .5rem;
      background: var(--clr-surface);
      border: 1.5px solid rgba(0,0,0,.07);
      border-radius: 50px;
      padding: .4rem 1.1rem;
      font-size: .88rem;
      font-weight: 600;
      color: var(--clr-text);
      margin-bottom: 2rem;
      box-shadow: var(--shadow-sm);
    }
    .hero-rating .stars { color: #f5c842; }

    .hero-cta-wrap { display: flex; flex-wrap: wrap; gap: .875rem; justify-content: center; }

    /* ══════════════════════════════════════════════════════════════
       2. SERVICES
    ══════════════════════════════════════════════════════════════ */
    .services { padding: 5.5rem 0; background: var(--clr-surface); }

    .section-header { text-align: center; margin-bottom: 3rem; }
    .section-header .label { margin-bottom: .6rem; }

    .section-title {
      font-size: clamp(1.75rem, 4vw, 2.8rem);
      font-weight: 700;
      color: var(--clr-text);
      line-height: 1.15;
      letter-spacing: -.02em;
    }

    .section-subtitle {
      margin-top: .65rem;
      font-size: .98rem;
      color: var(--clr-muted);
      max-width: 520px;
      margin-inline: auto;
    }

    .services-grid { display: grid; grid-template-columns: 1fr; gap: 1.25rem; }

    .service-card {
      background: var(--clr-bg);
      border: 1.5px solid rgba(0,0,0,.07);
      border-radius: var(--radius-lg);
      padding: 2rem 1.75rem;
      box-shadow: var(--shadow-sm);
      transition: transform var(--transition), box-shadow var(--transition), border-color var(--transition);
    }
    .service-card:hover { transform: translateY(-6px); box-shadow: var(--shadow-md); border-color: color-mix(in srgb, var(--clr-accent) 35%, transparent); }

    .service-card h3 {
      font-size: 1.12rem;
      font-weight: 700;
      color: var(--clr-text);
      margin-bottom: .5rem;
      letter-spacing: -.01em;
    }
    .service-card p { font-size: .92rem; color: var(--clr-muted); line-height: 1.65; }

    /* ══════════════════════════════════════════════════════════════
       3. ABOUT
    ══════════════════════════════════════════════════════════════ */
    .about { padding: 5.5rem 0; background: var(--clr-bg); }

    .about-inner { display: grid; grid-template-columns: 1fr; gap: 3rem; align-items: center; }
    .about-text .label { margin-bottom: .7rem; }

    .about-title {
      font-size: clamp(1.6rem, 4vw, 2.6rem);
      font-weight: 700;
      line-height: 1.18;
      letter-spacing: -.025em;
      color: var(--clr-text);
      margin-bottom: 1.1rem;
    }

    .about-body { font-size: .98rem; color: var(--clr-muted); line-height: 1.78; }
    .about-body p + p { margin-top: .9rem; }

    .about-accent-bar {
      width: 48px;
      height: 4px;
      background: linear-gradient(90deg, var(--clr-accent), var(--clr-secondary));
      border-radius: 50px;
      margin-top: 1.5rem;
    }

    .about-img-wrap {
      border-radius: var(--radius-xl);
      overflow: hidden;
      box-shadow: var(--shadow-lg);
      aspect-ratio: 4 / 3;
      background: color-mix(in srgb, var(--clr-accent) 8%, var(--clr-surface));
    }
    .about-img-wrap img { width: 100%; height: 100%; object-fit: cover; transition: transform .6s ease; }
    .about-img-wrap:hover img { transform: scale(1.04); }

    /* ══════════════════════════════════════════════════════════════
       4. WHY / HOURS
    ══════════════════════════════════════════════════════════════ */
    .why-hours { padding: 5.5rem 0; background: var(--clr-surface); }

    .why-hours-body { max-width: 720px; margin-inline: auto; font-size: .98rem; color: var(--clr-muted); line-height: 1.78; }

    .hours-table { width: 100%; border-collapse: collapse; font-size: .93rem; }
    .hours-table tr { border-bottom: 1px solid rgba(0,0,0,.06); }
    .hours-table tr:last-child { border-bottom: none; }
    .hours-table td { padding: .65rem .5rem; color: var(--clr-text); }
    .hours-table td:first-child { font-weight: 600; color: var(--clr-text); width: 42%; }

    .why-list { display: grid; grid-template-columns: 1fr; gap: 1.5rem; max-width: 760px; margin-inline: auto; }
    .why-item { display: flex; gap: 1rem; align-items: flex-start; }
    .why-icon {
      flex-shrink: 0; width: 48px; height: 48px;
      background: linear-gradient(135deg, color-mix(in srgb, var(--clr-accent) 15%, transparent), color-mix(in srgb, var(--clr-secondary) 15%, transparent));
      border-radius: var(--radius-md);
      display: flex; align-items: center; justify-content: center;
      font-size: 1.4rem;
    }
    .why-item-title { font-size: 1.05rem; font-weight: 700; color: var(--clr-text); margin-bottom: .25rem; letter-spacing: -.01em; }
    .why-item-desc { font-size: .9rem; color: var(--clr-muted); line-height: 1.58; }

    /* ══════════════════════════════════════════════════════════════
       5. CONTACT
    ══════════════════════════════════════════════════════════════ */
    .contact {
      padding: 5.5rem 0;
      background: linear-gradient(135deg, var(--clr-primary) 0%, color-mix(in srgb, var(--clr-secondary) 80%, #000) 100%);
      color: #fff;
      text-align: center;
    }
    .contact .section-title { color: #fff; }
    .contact .section-subtitle { color: rgba(255,255,255,.68); }

    .contact-cards { display: grid; grid-template-columns: 1fr; gap: 1rem; margin: 2.5rem 0; max-width: 640px; margin-inline: auto; }
    .contact-card {
      background: rgba(255,255,255,.12);
      backdrop-filter: blur(10px);
      border: 1.5px solid rgba(255,255,255,.2);
      border-radius: var(--radius-lg);
      padding: 1.4rem 1.75rem;
      display: flex; align-items: center; gap: 1rem; text-align: left;
      transition: background var(--transition), transform var(--transition);
    }
    .contact-card:hover { background: rgba(255,255,255,.2); transform: translateY(-2px); }
    .contact-card-icon { flex-shrink: 0; font-size: 1.5rem; width: 42px; text-align: center; }
    .contact-card-label { font-size: .7rem; font-weight: 700; letter-spacing: .14em; text-transform: uppercase; color: rgba(255,255,255,.5); margin-bottom: .25rem; }
    .contact-card-value { font-size: .95rem; font-weight: 600; color: #fff; word-break: break-word; }
    .contact-card a { color: #fff; }
    .contact-card a:hover { text-decoration: underline; }

    .contact-cta { margin-top: 2.5rem; }

    /* ══════════════════════════════════════════════════════════════
       6. FOOTER
    ══════════════════════════════════════════════════════════════ */
    .footer {
      background: var(--clr-bg);
      color: var(--clr-muted);
      padding: 2rem 1.25rem;
      text-align: center;
      font-size: .82rem;
      border-top: 1.5px solid rgba(0,0,0,.07);
    }
    .footer strong { color: var(--clr-text); font-size: .95rem; font-weight: 700; }
    .footer-divider { display: inline-block; margin-inline: .5rem; opacity: .4; }

    /* ── Responsive ── */
    @media (min-width: 768px) {
      .services-grid { grid-template-columns: repeat(2, 1fr); gap: 1.5rem; }
      .about-inner { grid-template-columns: 1fr 1fr; gap: 4.5rem; }
      .why-list { grid-template-columns: repeat(3, 1fr); gap: 2rem; }
      .contact-cards { grid-template-columns: 1fr 1fr; }
    }
    @media (min-width: 1024px) {
      .services-grid { grid-template-columns: repeat(3, 1fr); }
    }
  </style>
</head>
<body>

  <!-- 1. HERO -->
  <section class="hero">
    <div class="hero-content">
      <div class="hero-address-pill">
        <span class="pill">📍 {{business_address}}</span>
      </div>
      <h1 class="hero-headline">
        <span class="grad-text">{{headline}}</span>
      </h1>
      <p class="hero-sub">{{subheadline}}</p>
      <div class="hero-rating" aria-label="Rating">
        <span class="stars">{{rating}}</span>
      </div>
      <div class="hero-cta-wrap">
        <a href="#contact" class="btn btn-primary">{{cta_text}}</a>
        <a href="#services" class="btn btn-ghost">See Our Work</a>
      </div>
    </div>
  </section>

  <!-- 2. SERVICES -->
  <section class="services" id="services">
    <div class="container">
      <div class="section-header">
        <p class="label">What We Offer</p>
        <h2 class="section-title">Our Services</h2>
        <p class="section-subtitle">Everything you need to grow, all in one place.</p>
      </div>
      <div class="services-grid">
        {{services}}
      </div>
    </div>
  </section>

  <!-- 3. ABOUT -->
  <section class="about" id="about">
    <div class="container">
      <div class="about-inner">
        <div class="about-text">
          <p class="label">About Us</p>
          <h2 class="about-title">Built to<br>Move Fast</h2>
          <div class="about-body">{{about}}</div>
          <div class="about-accent-bar"></div>
        </div>
        <div>
          <div class="about-img-wrap">
            <img
              src="https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800&q=80"
              alt="{{business_name}} — our team"
              loading="lazy"
              width="800"
              height="600"
            />
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- 4. WHY / HOURS -->
  <section class="why-hours" id="hours">
    <div class="container">
      <div class="section-header">
        <p class="label">Why Us</p>
        <h2 class="section-title">Hours &amp; Highlights</h2>
      </div>
      <div class="why-hours-body">{{why_or_hours}}</div>
    </div>
  </section>

  <!-- 5. CONTACT -->
  <section class="contact" id="contact">
    <div class="container">
      <p class="label" style="color:rgba(255,255,255,.5)">Get In Touch</p>
      <h2 class="section-title" style="margin-top:.5rem">Let's Work Together</h2>
      <p class="section-subtitle">We'd love to hear about your project.</p>
      <div class="contact-cards">
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">📞</span>
          <div>
            <p class="contact-card-label">Phone</p>
            <p class="contact-card-value">{{business_phone}}</p>
          </div>
        </div>
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">📍</span>
          <div>
            <p class="contact-card-label">Address</p>
            <p class="contact-card-value">{{business_address}}</p>
          </div>
        </div>
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">🌐</span>
          <div>
            <p class="contact-card-label">Website</p>
            <p class="contact-card-value">{{business_website}}</p>
          </div>
        </div>
      </div>
      <div class="contact-cta">
        <a href="tel:{{business_phone_raw}}" class="btn btn-primary" style="background:#fff;color:var(--clr-primary)">{{cta_text}}</a>
      </div>
    </div>
  </section>

  <!-- 6. FOOTER -->
  <footer class="footer">
    <strong>{{business_name}}</strong>
    <span class="footer-divider">·</span>
    Powered by LeadForge
  </footer>

</body>
</html>`
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. DARK PREMIUM — Fine dining, hotels, lounges, boutique
// ─────────────────────────────────────────────────────────────────────────────
export function darkPremium(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{business_name}}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,500;0,600;1,300;1,400;1,600&family=Inter:wght@300;400;500&display=swap');

    :root {
      --clr-primary:   {{clr-primary}};
      --clr-secondary: {{clr-secondary}};
      --clr-accent:    {{clr-accent}};
      --clr-bg:        {{clr-bg}};
      --clr-surface:   {{clr-surface}};
      --clr-text:      {{clr-text}};
      --clr-muted:     {{clr-muted}};

      /* Dark premium overrides — ensures true dark look */
      --dp-bg:      #0a0a0a;
      --dp-surface: #111111;
      --dp-border:  rgba(180,145,65,.22);
      --dp-gold:    var(--clr-accent);

      --radius-sm:  3px;
      --radius-md:  6px;
      --radius-lg:  10px;
      --shadow-sm:  0 2px 12px rgba(0,0,0,.4);
      --shadow-md:  0 8px 32px rgba(0,0,0,.55);
      --shadow-lg:  0 20px 60px rgba(0,0,0,.65);
      --transition: .3s ease;
      --container:  1040px;
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html { scroll-behavior: smooth; }
    body {
      font-family: 'Inter', sans-serif;
      background-color: var(--dp-bg);
      color: rgba(255,255,255,.82);
      line-height: 1.65;
      -webkit-font-smoothing: antialiased;
    }
    img { display: block; max-width: 100%; }
    a { color: inherit; text-decoration: none; }

    .container { width: 100%; max-width: var(--container); margin-inline: auto; padding-inline: 1.5rem; }

    /* ── Buttons ── */
    .btn {
      display: inline-flex;
      align-items: center;
      gap: .5rem;
      font-family: 'Inter', sans-serif;
      font-weight: 500;
      font-size: .8rem;
      letter-spacing: .14em;
      text-transform: uppercase;
      padding: .875rem 2.5rem;
      border-radius: var(--radius-sm);
      border: 1px solid transparent;
      cursor: pointer;
      transition: transform var(--transition), box-shadow var(--transition), background-color var(--transition);
      white-space: nowrap;
    }
    .btn-primary {
      background: var(--dp-gold);
      color: #0a0a0a;
      border-color: var(--dp-gold);
      box-shadow: 0 4px 20px rgba(180,145,65,.3);
    }
    .btn-primary:hover { transform: translateY(-1px); box-shadow: 0 8px 30px rgba(180,145,65,.45); filter: brightness(1.08); }
    .btn-outline {
      background: transparent;
      color: rgba(255,255,255,.7);
      border-color: rgba(255,255,255,.22);
    }
    .btn-outline:hover { border-color: var(--dp-gold); color: var(--dp-gold); transform: translateY(-1px); }

    /* ── Labels ── */
    .overline {
      font-family: 'Inter', sans-serif;
      font-size: .65rem;
      font-weight: 500;
      letter-spacing: .28em;
      text-transform: uppercase;
      color: var(--dp-gold);
    }

    .gold-rule {
      width: 60px;
      height: 1px;
      background: var(--dp-gold);
      opacity: .6;
      margin: 1.5rem auto;
    }

    /* ══════════════════════════════════════════════════════════════
       1. HERO
    ══════════════════════════════════════════════════════════════ */
    .hero {
      min-height: 100svh;
      display: flex;
      align-items: center;
      justify-content: center;
      position: relative;
      overflow: hidden;
      background: var(--dp-bg);
      text-align: center;
      padding: 5rem 1.5rem;
    }

    .hero-glow {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -55%);
      width: 700px;
      height: 700px;
      background: radial-gradient(circle, rgba(180,145,65,.12) 0%, transparent 65%);
      pointer-events: none;
    }

    {{#has_hero_image}}
    .hero::before {
      content: '';
      position: absolute;
      inset: 0;
      background-image: url('{{hero_image}}');
      background-size: cover;
      background-position: center;
      opacity: .1;
    }
    {{/has_hero_image}}

    .hero-content {
      position: relative;
      z-index: 2;
      max-width: 720px;
    }

    .hero-eyebrow {
      font-size: .65rem;
      font-weight: 500;
      letter-spacing: .32em;
      text-transform: uppercase;
      color: rgba(255,255,255,.38);
      margin-bottom: 1.75rem;
    }

    .hero-headline {
      font-family: 'Cormorant Garamond', serif;
      font-size: clamp(3rem, 7vw, 6rem);
      font-weight: 300;
      line-height: 1.08;
      letter-spacing: .01em;
      color: #fff;
      margin-bottom: 1.5rem;
    }

    .hero-headline em { font-style: italic; color: var(--dp-gold); }

    .hero-sub {
      font-size: clamp(.92rem, 1.8vw, 1.05rem);
      font-weight: 300;
      color: rgba(255,255,255,.55);
      max-width: 480px;
      margin-inline: auto;
      margin-bottom: 1.5rem;
      letter-spacing: .02em;
      line-height: 1.75;
    }

    .hero-rating {
      display: inline-flex;
      align-items: center;
      gap: .6rem;
      border: 1px solid var(--dp-border);
      border-radius: var(--radius-sm);
      padding: .45rem 1.25rem;
      font-size: .82rem;
      font-weight: 400;
      color: rgba(255,255,255,.65);
      margin-bottom: 2.5rem;
      letter-spacing: .06em;
    }
    .hero-rating .stars { color: var(--dp-gold); }

    .hero-cta-wrap { display: flex; flex-wrap: wrap; gap: 1rem; justify-content: center; }

    /* ══════════════════════════════════════════════════════════════
       2. SERVICES
    ══════════════════════════════════════════════════════════════ */
    .services { padding: 6rem 0; background: var(--dp-surface); }

    .section-header { text-align: center; margin-bottom: 3.5rem; }
    .section-header .overline { margin-bottom: .5rem; }

    .section-title {
      font-family: 'Cormorant Garamond', serif;
      font-size: clamp(2rem, 4.5vw, 3.4rem);
      font-weight: 300;
      color: #fff;
      line-height: 1.2;
      letter-spacing: .02em;
    }

    .section-subtitle {
      margin-top: .75rem;
      font-size: .92rem;
      font-weight: 300;
      color: rgba(255,255,255,.4);
      max-width: 480px;
      margin-inline: auto;
      letter-spacing: .03em;
    }

    .services-grid { display: grid; grid-template-columns: 1fr; gap: 1px; background: var(--dp-border); }

    .service-card {
      background: var(--dp-surface);
      padding: 2.5rem 2rem;
      border-top: 1px solid var(--dp-border);
      transition: background var(--transition);
      position: relative;
    }
    .service-card::before {
      content: '';
      position: absolute;
      top: 0; left: 0;
      width: 0; height: 1px;
      background: var(--dp-gold);
      transition: width .4s ease;
    }
    .service-card:hover { background: color-mix(in srgb, var(--dp-surface) 80%, var(--dp-gold) 5%); }
    .service-card:hover::before { width: 100%; }

    .service-card h3 {
      font-family: 'Cormorant Garamond', serif;
      font-size: 1.35rem;
      font-weight: 400;
      color: rgba(255,255,255,.9);
      margin-bottom: .6rem;
      letter-spacing: .02em;
    }
    .service-card p { font-size: .9rem; font-weight: 300; color: rgba(255,255,255,.45); line-height: 1.65; letter-spacing: .01em; }

    /* ══════════════════════════════════════════════════════════════
       3. ABOUT
    ══════════════════════════════════════════════════════════════ */
    .about { padding: 6rem 0; background: var(--dp-bg); }

    .about-inner { display: grid; grid-template-columns: 1fr; gap: 3.5rem; align-items: center; }
    .about-text .overline { margin-bottom: .75rem; }

    .about-title {
      font-family: 'Cormorant Garamond', serif;
      font-size: clamp(1.8rem, 4.5vw, 3.2rem);
      font-weight: 300;
      line-height: 1.2;
      letter-spacing: .02em;
      color: #fff;
      margin-bottom: 1.25rem;
    }

    .about-body { font-size: .95rem; font-weight: 300; color: rgba(255,255,255,.5); line-height: 1.85; letter-spacing: .02em; }
    .about-body p + p { margin-top: 1rem; }

    .about-gold-rule {
      width: 36px;
      height: 1px;
      background: var(--dp-gold);
      opacity: .7;
      margin-top: 2rem;
    }

    .about-img-wrap {
      border-radius: var(--radius-md);
      overflow: hidden;
      box-shadow: var(--shadow-lg);
      aspect-ratio: 4 / 3;
      background: #1a1a1a;
    }
    .about-img-wrap img { width: 100%; height: 100%; object-fit: cover; opacity: .85; transition: opacity .4s ease, transform .6s ease; }
    .about-img-wrap:hover img { opacity: 1; transform: scale(1.03); }

    /* ══════════════════════════════════════════════════════════════
       4. WHY / HOURS
    ══════════════════════════════════════════════════════════════ */
    .why-hours { padding: 6rem 0; background: var(--dp-surface); }

    .why-hours-body { max-width: 700px; margin-inline: auto; font-size: .95rem; font-weight: 300; color: rgba(255,255,255,.5); line-height: 1.85; letter-spacing: .02em; }

    .hours-table { width: 100%; border-collapse: collapse; font-size: .9rem; }
    .hours-table tr { border-bottom: 1px solid rgba(255,255,255,.06); }
    .hours-table tr:last-child { border-bottom: none; }
    .hours-table td { padding: .75rem .5rem; color: rgba(255,255,255,.6); font-weight: 300; }
    .hours-table td:first-child { font-weight: 500; color: rgba(255,255,255,.85); width: 42%; letter-spacing: .04em; }

    .why-list { display: grid; grid-template-columns: 1fr; gap: 2rem; max-width: 760px; margin-inline: auto; }
    .why-item { display: flex; gap: 1.25rem; align-items: flex-start; }
    .why-icon {
      flex-shrink: 0; width: 44px; height: 44px;
      background: rgba(180,145,65,.1);
      border: 1px solid var(--dp-border);
      border-radius: var(--radius-sm);
      display: flex; align-items: center; justify-content: center;
      font-size: 1.2rem;
    }
    .why-item-title { font-family: 'Cormorant Garamond', serif; font-size: 1.12rem; font-weight: 400; color: rgba(255,255,255,.85); margin-bottom: .3rem; letter-spacing: .02em; }
    .why-item-desc { font-size: .88rem; font-weight: 300; color: rgba(255,255,255,.45); line-height: 1.6; letter-spacing: .01em; }

    /* ══════════════════════════════════════════════════════════════
       5. CONTACT
    ══════════════════════════════════════════════════════════════ */
    .contact { padding: 6rem 0; background: var(--dp-bg); color: #fff; text-align: center; }

    .contact-cards { display: grid; grid-template-columns: 1fr; gap: 1px; background: var(--dp-border); margin: 3rem 0; max-width: 680px; margin-inline: auto; }
    .contact-card {
      background: var(--dp-bg);
      padding: 1.75rem 2rem;
      display: flex; align-items: center; gap: 1.25rem; text-align: left;
      transition: background var(--transition);
    }
    .contact-card:hover { background: #111; }
    .contact-card-icon { flex-shrink: 0; font-size: 1.25rem; width: 36px; text-align: center; opacity: .55; }
    .contact-card-label { font-size: .62rem; font-weight: 500; letter-spacing: .24em; text-transform: uppercase; color: rgba(255,255,255,.3); margin-bottom: .3rem; }
    .contact-card-value { font-size: .93rem; font-weight: 300; color: rgba(255,255,255,.78); word-break: break-word; letter-spacing: .02em; }
    .contact-card a { color: rgba(255,255,255,.78); }
    .contact-card a:hover { color: var(--dp-gold); }

    .contact-cta { margin-top: 3rem; }

    /* ══════════════════════════════════════════════════════════════
       6. FOOTER
    ══════════════════════════════════════════════════════════════ */
    .footer {
      background: #050505;
      color: rgba(255,255,255,.25);
      padding: 2.5rem 1.5rem;
      text-align: center;
      font-size: .75rem;
      letter-spacing: .1em;
      text-transform: uppercase;
      border-top: 1px solid var(--dp-border);
    }
    .footer strong { color: rgba(255,255,255,.6); font-family: 'Cormorant Garamond', serif; font-size: .92rem; letter-spacing: .08em; text-transform: none; font-weight: 400; }
    .footer-divider { display: inline-block; margin-inline: .75rem; opacity: .25; }

    /* ── Responsive ── */
    @media (min-width: 768px) {
      .services-grid { grid-template-columns: repeat(2, 1fr); }
      .about-inner { grid-template-columns: 1fr 1fr; gap: 5rem; }
      .why-list { grid-template-columns: repeat(3, 1fr); }
      .contact-cards { grid-template-columns: 1fr 1fr; }
    }
    @media (min-width: 1024px) {
      .services-grid { grid-template-columns: repeat(3, 1fr); }
    }
  </style>
</head>
<body>

  <!-- 1. HERO -->
  <section class="hero">
    <div class="hero-glow" aria-hidden="true"></div>
    <div class="hero-content">
      <p class="hero-eyebrow">{{business_name}}</p>
      <div class="gold-rule"></div>
      <h1 class="hero-headline">{{headline}}</h1>
      <p class="hero-sub">{{subheadline}}</p>
      <div class="hero-rating" aria-label="Rating">
        <span class="stars">{{rating}}</span>
      </div>
      <div class="hero-cta-wrap">
        <a href="#contact" class="btn btn-primary">{{cta_text}}</a>
        <a href="#services" class="btn btn-outline">Explore</a>
      </div>
    </div>
  </section>

  <!-- 2. SERVICES -->
  <section class="services" id="services">
    <div class="container">
      <div class="section-header">
        <p class="overline">The Experience</p>
        <div class="gold-rule" style="width:30px;margin:.75rem auto 1rem"></div>
        <h2 class="section-title">What We Offer</h2>
        <p class="section-subtitle">Curated with intention. Delivered with precision.</p>
      </div>
      <div class="services-grid">
        {{services}}
      </div>
    </div>
  </section>

  <!-- 3. ABOUT -->
  <section class="about" id="about">
    <div class="container">
      <div class="about-inner">
        <div class="about-text">
          <p class="overline">Our Story</p>
          <h2 class="about-title">A Legacy of<br><em>Excellence</em></h2>
          <div class="about-body">{{about}}</div>
          <div class="about-gold-rule"></div>
        </div>
        <div>
          <div class="about-img-wrap">
            <img
              src="https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80"
              alt="{{business_name}} — ambiance"
              loading="lazy"
              width="800"
              height="600"
            />
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- 4. WHY / HOURS -->
  <section class="why-hours" id="hours">
    <div class="container">
      <div class="section-header">
        <p class="overline">Reservations</p>
        <div class="gold-rule" style="width:30px;margin:.75rem auto 1rem"></div>
        <h2 class="section-title">Hours &amp; Details</h2>
      </div>
      <div class="why-hours-body">{{why_or_hours}}</div>
    </div>
  </section>

  <!-- 5. CONTACT -->
  <section class="contact" id="contact">
    <div class="container">
      <p class="overline" style="color:rgba(255,255,255,.28)">Contact</p>
      <div class="gold-rule" style="width:30px;margin:.75rem auto 1rem"></div>
      <h2 class="section-title" style="font-family:'Cormorant Garamond',serif;font-size:clamp(2rem,4.5vw,3.2rem);font-weight:300;letter-spacing:.02em">Make a Reservation</h2>
      <p class="section-subtitle">We look forward to welcoming you.</p>
      <div class="contact-cards">
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">📞</span>
          <div>
            <p class="contact-card-label">Phone</p>
            <p class="contact-card-value">{{business_phone}}</p>
          </div>
        </div>
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">📍</span>
          <div>
            <p class="contact-card-label">Address</p>
            <p class="contact-card-value">{{business_address}}</p>
          </div>
        </div>
        <div class="contact-card">
          <span class="contact-card-icon" aria-hidden="true">🌐</span>
          <div>
            <p class="contact-card-label">Website</p>
            <p class="contact-card-value">{{business_website}}</p>
          </div>
        </div>
      </div>
      <div class="contact-cta">
        <a href="tel:{{business_phone_raw}}" class="btn btn-primary">{{cta_text}}</a>
      </div>
    </div>
  </section>

  <!-- 6. FOOTER -->
  <footer class="footer">
    <strong>{{business_name}}</strong>
    <span class="footer-divider">·</span>
    Powered by LeadForge
  </footer>

</body>
</html>`
}

// ─────────────────────────────────────────────────────────────────────────────
// SELECTOR
// ─────────────────────────────────────────────────────────────────────────────

export type TemplateName =
  | 'warm_organic'
  | 'soft_glass'
  | 'editorial_luxury'
  | 'bold_modern'
  | 'fresh_startup'
  | 'dark_premium'

const templateMap: Record<TemplateName, () => string> = {
  warm_organic:      warmOrganic,
  soft_glass:        softGlass,
  editorial_luxury:  editorialLuxury,
  bold_modern:       boldModern,
  fresh_startup:     freshStartup,
  dark_premium:      darkPremium,
}

export function getTemplate(name: TemplateName): string {
  const fn = templateMap[name]
  if (!fn) return warmOrganic()
  return fn()
}

export function pickTemplateName(
  business: { categories?: string[]; name?: string },
): TemplateName {
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
