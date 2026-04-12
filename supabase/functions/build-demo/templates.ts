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
