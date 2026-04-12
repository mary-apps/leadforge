// template-engine.ts — merges HTML templates with AI-generated content and business data

export interface AiContent {
  headline: string
  subheadline: string
  services: string[]
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
  reviews_count: number | null
  categories: string[] | null
  opening_hours: Record<string, string> | null
  audit_score: number | null
  audit_diagnosis: string | null
}

// ---------------------------------------------------------------------------
// HTML escaping — applied to all user-supplied strings
// ---------------------------------------------------------------------------

function escapeHtml(str: string | null | undefined): string {
  if (!str) return ''
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
}

// ---------------------------------------------------------------------------
// Service cards
// ---------------------------------------------------------------------------

function buildServiceCards(services: string[]): string {
  if (!services || services.length === 0) return ''
  return services
    .map((service) => {
      const safe = escapeHtml(service)
      return `<div class="service-card"><span class="service-name">${safe}</span></div>`
    })
    .join('\n')
}

// ---------------------------------------------------------------------------
// Why-us bullets OR opening hours grid
// ---------------------------------------------------------------------------

function buildWhyOrHours(business: BusinessData, whyUs: string[]): string {
  if (business.opening_hours && Object.keys(business.opening_hours).length > 0) {
    const rows = Object.entries(business.opening_hours)
      .map(([day, hours]) => {
        return `<div class="hours-row"><span class="hours-day">${escapeHtml(day)}</span><span class="hours-time">${escapeHtml(hours)}</span></div>`
      })
      .join('\n')
    return `<div class="hours-grid">${rows}</div>`
  }

  if (!whyUs || whyUs.length === 0) return ''
  const bullets = whyUs
    .map((item) => `<li class="why-item">${escapeHtml(item)}</li>`)
    .join('\n')
  return `<ul class="why-list">${bullets}</ul>`
}

// ---------------------------------------------------------------------------
// Star rating HTML
// ---------------------------------------------------------------------------

function buildRatingHtml(rating: number | null): string {
  if (!rating || rating < 3.5) return ''
  const fullStars = Math.floor(rating)
  const halfStar = rating - fullStars >= 0.5
  const emptyStars = 5 - fullStars - (halfStar ? 1 : 0)

  const stars =
    '★'.repeat(fullStars) +
    (halfStar ? '½' : '') +
    '☆'.repeat(emptyStars)

  return `<div class="rating"><span class="stars" aria-label="${rating} out of 5 stars">${stars}</span><span class="rating-value">${rating}</span></div>`
}

// ---------------------------------------------------------------------------
// Conditional block processing: {{#has_hero_image}}...{{/has_hero_image}}
// ---------------------------------------------------------------------------

function processConditionals(html: string, hasHeroImage: boolean): string {
  const openTag = '{{#has_hero_image}}'
  const closeTag = '{{/has_hero_image}}'
  const pattern = new RegExp(
    escapeRegex(openTag) + '([\\s\\S]*?)' + escapeRegex(closeTag),
    'g'
  )
  if (hasHeroImage) {
    // Keep the inner content, remove the tags
    return html.replace(pattern, '$1')
  } else {
    // Remove the entire block
    return html.replace(pattern, '')
  }
}

function escapeRegex(str: string): string {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

// ---------------------------------------------------------------------------
// Main render function
// ---------------------------------------------------------------------------

export function renderTemplate(
  templateHtml: string,
  content: AiContent,
  business: BusinessData,
  images: { hero?: string; section?: string }
): string {
  const hasHeroImage = Boolean(images.hero)

  // 1. Handle conditional blocks first
  let html = processConditionals(templateHtml, hasHeroImage)

  // 2. CSS custom property palette tokens
  const paletteMap: Record<string, string> = {
    '{{clr-primary}}': content.palette.primary,
    '{{clr-secondary}}': content.palette.secondary,
    '{{clr-accent}}': content.palette.accent,
    '{{clr-bg}}': content.palette.bg,
    '{{clr-surface}}': content.palette.surface,
    '{{clr-text}}': content.palette.text,
    '{{clr-muted}}': content.palette.muted,
  }
  for (const [token, value] of Object.entries(paletteMap)) {
    html = replaceAll(html, token, escapeHtml(value))
  }

  // 3. AI copy tokens (HTML-escaped)
  html = replaceAll(html, '{{headline}}', escapeHtml(content.headline))
  html = replaceAll(html, '{{subheadline}}', escapeHtml(content.subheadline))
  html = replaceAll(html, '{{about}}', escapeHtml(content.about))
  html = replaceAll(html, '{{cta_text}}', escapeHtml(content.cta_text))

  // 4. Structured HTML blocks (pre-built, not escaped again)
  html = replaceAll(html, '{{services}}', buildServiceCards(content.services))
  html = replaceAll(html, '{{why_or_hours}}', buildWhyOrHours(business, content.why_us))
  html = replaceAll(html, '{{rating}}', buildRatingHtml(business.rating))

  // 5. Business data tokens
  html = replaceAll(html, '{{business_name}}', escapeHtml(business.name))
  html = replaceAll(html, '{{business_address}}', escapeHtml(business.address))

  const rawPhone = escapeHtml(business.phone)
  const phoneLink = business.phone
    ? `<a href="tel:${escapeHtml(business.phone)}">${escapeHtml(business.phone)}</a>`
    : ''
  html = replaceAll(html, '{{business_phone}}', phoneLink)
  html = replaceAll(html, '{{business_phone_raw}}', rawPhone)
  html = replaceAll(html, '{{business_website}}', escapeHtml(business.website))

  // 6. Image tokens
  html = replaceAll(html, '{{hero_image}}', images.hero ?? '')
  html = replaceAll(html, '{{section_image}}', images.section ?? '')

  return html
}

// Simple global string replacement (no regex needed for literal tokens)
function replaceAll(source: string, token: string, value: string): string {
  // Split on the literal token and rejoin with value — handles all occurrences
  return source.split(token).join(value)
}

// ---------------------------------------------------------------------------
// Fallback content generator
// ---------------------------------------------------------------------------

export function fallbackContent(business: BusinessData, language: string): AiContent {
  const isSpanish = language.toLowerCase().startsWith('es') || language.toLowerCase() === 'spanish'

  const name = business.name || (isSpanish ? 'Nuestro Negocio' : 'Our Business')
  const categories = business.categories && business.categories.length > 0
    ? business.categories
    : isSpanish ? ['Servicios Profesionales'] : ['Professional Services']

  // Build service list from categories (capitalize each)
  const services = categories.slice(0, 6).map((cat) =>
    cat.charAt(0).toUpperCase() + cat.slice(1)
  )

  const headline = name
  const subheadline = isSpanish
    ? `Calidad y confianza en cada servicio`
    : `Quality and trust in every service`

  const about = isSpanish
    ? `En ${escapeHtml(name)} nos dedicamos a brindar servicios de la más alta calidad. Con años de experiencia, nuestro equipo está comprometido con la satisfacción de cada cliente.`
    : `At ${name} we are dedicated to providing the highest quality services. With years of experience, our team is committed to the satisfaction of every client.`

  const why_us = isSpanish
    ? [
        '✓ Atención personalizada y profesional',
        '✓ Precios competitivos y transparentes',
        '✓ Experiencia y resultados comprobados',
      ]
    : [
        '✓ Personalized and professional attention',
        '✓ Competitive and transparent pricing',
        '✓ Proven experience and results',
      ]

  const cta_text = isSpanish ? 'Contáctanos Ahora' : 'Contact Us Now'

  // Neutral professional palette as fallback
  const palette: AiContent['palette'] = {
    primary: '#1565C0',
    secondary: '#0277BD',
    accent: '#FF6F00',
    bg: '#FFFFFF',
    surface: '#F5F7FA',
    text: '#1A1A2E',
    muted: '#6B7280',
  }

  return {
    headline,
    subheadline,
    services,
    about,
    why_us,
    cta_text,
    palette,
  }
}
