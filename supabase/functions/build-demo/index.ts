// Build Demo Edge Function - Generate unique AI-powered demo websites for prospects
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

function detectLanguage(business: any): { language: string; langCode: string } {
  const text = `${business.name || ''} ${business.address || ''} ${(business.categories || []).join(' ')}`.toLowerCase()

  if (/méxico|mexico|guadalajara|monterrey|cdmx|ciudad de|colonia|calle |avenida |paseo |blvd\.|c\.p\.|jalisco|puebla|oaxaca|cancún|mérida|querétaro|león|tijuana|hermosillo|chile|santiago|valparaíso|viña|concepción|colombia|bogotá|medellín|argentina|buenos aires|córdoba|perú|lima|ecuador|quito|venezuela|caracas|uruguay|montevideo|bolivia|la paz|paraguay|asunción|panamá|costa rica|san josé|guatemala|honduras|el salvador|nicaragua|dominicana|santo domingo|taquería|tacos |pozole|carnitas|birria|tortas |antojitos|mariscos|panadería|carnicería|estética|peluquería|empanadas|ceviche|arepa/i.test(text)) {
    return { language: 'Spanish', langCode: 'es' }
  }
  if (/brasil|brazil|são paulo|rio de janeiro|belo horizonte|rua |bairro |padaria|churrascaria/i.test(text)) {
    return { language: 'Portuguese', langCode: 'pt' }
  }
  if (/france|paris|lyon|marseille|rue |boulevard |boulangerie|pâtisserie/i.test(text)) {
    return { language: 'French', langCode: 'fr' }
  }
  return { language: 'English', langCode: 'en' }
}

function buildFallbackHTML(business: any, langCode: string): string {
  return `<!DOCTYPE html>
<html lang="${langCode}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${business.name}</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; color: #333; line-height: 1.6; }
    .hero { background: linear-gradient(135deg, #1565C0, #0277BD); color: white; padding: 80px 20px; text-align: center; }
    .hero h1 { font-size: 2.5rem; margin-bottom: 12px; font-weight: 800; }
    .hero p { font-size: 1.1rem; opacity: 0.9; }
    .section { padding: 56px 20px; max-width: 820px; margin: 0 auto; }
    .section h2 { font-size: 1.7rem; margin-bottom: 20px; color: #1565C0; }
    .contact-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; }
    .contact-card { background: #f8f9fa; border-radius: 12px; padding: 24px; text-align: center; }
    .contact-card h3 { color: #1565C0; margin-bottom: 8px; }
    .footer { background: #1a1a2e; color: white; padding: 32px 20px; text-align: center; }
    .footer p { opacity: 0.6; font-size: 0.82rem; }
  </style>
</head>
<body>
  <div class="hero">
    <h1>${business.name}</h1>
    <p>${business.address || ''}</p>
    ${business.rating ? `<p style="margin-top:12px">⭐ ${business.rating}/5 (${business.reviews_count} reviews)</p>` : ''}
  </div>
  <div class="section">
    <h2>Contact</h2>
    <div class="contact-grid">
      ${business.phone ? `<div class="contact-card"><h3>📞</h3><p><a href="tel:${business.phone}">${business.phone}</a></p></div>` : ''}
      ${business.address ? `<div class="contact-card"><h3>📍</h3><p>${business.address}</p></div>` : ''}
      ${business.website ? `<div class="contact-card"><h3>🌐</h3><p>${business.website}</p></div>` : ''}
    </div>
  </div>
  <div class="footer"><p>Powered by LeadForge</p></div>
</body>
</html>`
}

async function scrapeBusinessWebsite(url: string): Promise<string | null> {
  if (!url) return null
  try {
    const cleanUrl = url.startsWith('http') ? url : `https://${url}`
    const response = await fetch(cleanUrl, {
      headers: { 'User-Agent': 'Mozilla/5.0 (compatible; LeadForge/1.0)' },
      redirect: 'follow',
    })
    if (!response.ok) return null
    const html = await response.text()

    // Extract useful content: meta tags, headings, text, links
    const titleMatch = html.match(/<title[^>]*>(.*?)<\/title>/is)
    const metaDescMatch = html.match(/<meta[^>]*name=["']description["'][^>]*content=["'](.*?)["']/is)
    const ogImageMatch = html.match(/<meta[^>]*property=["']og:image["'][^>]*content=["'](.*?)["']/is)
    const h1Matches = [...html.matchAll(/<h1[^>]*>(.*?)<\/h1>/gis)].map(m => m[1].replace(/<[^>]+>/g, '').trim()).filter(Boolean)
    const h2Matches = [...html.matchAll(/<h2[^>]*>(.*?)<\/h2>/gis)].map(m => m[1].replace(/<[^>]+>/g, '').trim()).filter(Boolean)

    // Extract visible text from body
    const bodyMatch = html.match(/<body[^>]*>([\s\S]*?)<\/body>/is)
    let bodyText = ''
    if (bodyMatch) {
      bodyText = bodyMatch[1]
        .replace(/<script[\s\S]*?<\/script>/gi, '')
        .replace(/<style[\s\S]*?<\/style>/gi, '')
        .replace(/<nav[\s\S]*?<\/nav>/gi, '')
        .replace(/<footer[\s\S]*?<\/footer>/gi, '')
        .replace(/<[^>]+>/g, ' ')
        .replace(/\s+/g, ' ')
        .trim()
        .slice(0, 2000)
    }

    // Extract menu items or services if present
    const listItems = [...html.matchAll(/<li[^>]*>(.*?)<\/li>/gis)]
      .map(m => m[1].replace(/<[^>]+>/g, '').trim())
      .filter(t => t.length > 3 && t.length < 100)
      .slice(0, 20)

    // Extract color scheme from CSS
    const colorMatches = [...html.matchAll(/(?:background-color|color|background)\s*:\s*(#[0-9a-fA-F]{3,8}|rgb[a]?\([^)]+\))/gi)]
      .map(m => m[1])
      .slice(0, 10)

    const result = []
    if (titleMatch?.[1]) result.push(`Page title: ${titleMatch[1].trim()}`)
    if (metaDescMatch?.[1]) result.push(`Meta description: ${metaDescMatch[1].trim()}`)
    if (ogImageMatch?.[1]) result.push(`OG image: ${ogImageMatch[1].trim()}`)
    if (h1Matches.length > 0) result.push(`Main headings: ${h1Matches.slice(0, 3).join(', ')}`)
    if (h2Matches.length > 0) result.push(`Section headings: ${h2Matches.slice(0, 6).join(', ')}`)
    if (listItems.length > 0) result.push(`Menu/service items: ${listItems.slice(0, 15).join(', ')}`)
    if (colorMatches.length > 0) result.push(`Brand colors found: ${[...new Set(colorMatches)].slice(0, 5).join(', ')}`)
    if (bodyText) result.push(`Page content excerpt: ${bodyText.slice(0, 1000)}`)

    return result.length > 0 ? result.join('\n') : null
  } catch (e) {
    console.log('[build-demo] Website scrape failed:', e.message)
    return null
  }
}

async function generateUniqueHTML(business: any, customNotes: string | null): Promise<string> {
  const openaiKey = Deno.env.get('OPENAI_API_KEY')
  const { language, langCode } = detectLanguage(business)

  if (!openaiKey) {
    return buildFallbackHTML(business, langCode)
  }

  // Scrape existing website for real content
  console.log('[build-demo] Scraping website:', business.website)
  const scrapedContent = await scrapeBusinessWebsite(business.website)
  console.log('[build-demo] Scraped content length:', scrapedContent?.length || 0)

  const categories = business.categories ? JSON.stringify(business.categories) : 'Unknown'
  const hours = business.opening_hours ? JSON.stringify(business.opening_hours) : null
  const auditInfo = business.audit_score != null
    ? `Score: ${business.audit_score}/100. Diagnosis: ${business.audit_diagnosis || 'N/A'}.`
    : null

  // Pick a random design style for variety
  const designStyles = [
    {
      name: 'Editorial Luxury',
      description: 'Serif headings (Playfair Display), ultra-generous whitespace, muted earth-tone palette, full-bleed hero with overlay text, editorial magazine feel. Thin borders, letter-spacing on small caps labels. Sections separated by subtle horizontal rules.',
      fonts: '@import url("https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=Inter:wght@300;400;500&display=swap");',
      heroStyle: 'min-height:90vh with centered text, large serif title (clamp(2.5rem,6vw,5rem)), subtle gradient overlay on solid color background',
    },
    {
      name: 'Bold Modern',
      description: 'Geometric sans-serif (Space Grotesk), high contrast black/white with ONE vibrant accent color, oversized typography, asymmetric layouts. Cards with thick borders instead of shadows. Brutalist-inspired but polished.',
      fonts: '@import url("https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;600;700&family=Inter:wght@300;400;500&display=swap");',
      heroStyle: 'full-width solid dark background, enormous white text (clamp(3rem,8vw,6rem)), accent color on one word, minimal padding',
    },
    {
      name: 'Soft Glassmorphism',
      description: 'Rounded sans (DM Sans), soft pastel gradients, frosted glass cards (backdrop-filter:blur + white/10% bg), gentle shadows, pill-shaped buttons. Dreamy, premium SaaS feel. Lots of border-radius (20px+).',
      fonts: '@import url("https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&display=swap");',
      heroStyle: 'gradient background (two soft colors), floating glass card in center with business info, large rounded elements',
    },
    {
      name: 'Dark Premium',
      description: 'Dark background (#0a0a0a), light text, gold/amber accent. Elegant serif (Cormorant Garamond) for headings, clean sans for body. Subtle glow effects, thin gold borders. Nightclub/fine-dining/luxury feel.',
      fonts: '@import url("https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;600;700&family=Inter:wght@300;400&display=swap");',
      heroStyle: 'full dark background, large serif text with slight text-shadow glow, accent color sparingly, elegant spacing',
    },
    {
      name: 'Fresh Startup',
      description: 'Clean geometric sans (Outfit), bright white background, vibrant gradient accent (purple-to-pink or blue-to-teal), rounded cards with subtle shadows, emoji as visual elements, playful but professional. Stripe/Linear inspired.',
      fonts: '@import url("https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap");',
      heroStyle: 'white or very light bg, large bold text with gradient color on key words (background-clip:text), clean and airy',
    },
    {
      name: 'Warm Organic',
      description: 'Warm serif (Lora) + clean sans (Nunito), cream/warm-white backgrounds, terracotta/sage/olive accent colors, organic rounded shapes, hand-crafted feel. Cards with warm shadows. Perfect for food, wellness, artisan businesses.',
      fonts: '@import url("https://fonts.googleapis.com/css2?family=Lora:wght@400;600;700&family=Nunito:wght@300;400;600&display=swap");',
      heroStyle: 'warm gradient or solid warm color, rounded container for hero text, cozy and inviting feel',
    },
  ]

  const style = designStyles[Math.floor(Math.random() * designStyles.length)]

  const prompt = `Build a STUNNING demo website. Language: ALL visible text in ${language}.

DESIGN STYLE: "${style.name}"
${style.description}
Fonts: ${style.fonts}
Hero approach: ${style.heroStyle}

BUSINESS DATA:
- Name: ${business.name}
- Address: ${business.address || 'N/A'}
- Phone: ${business.phone || 'N/A'}
- Website: ${business.website || 'None'}
- Rating: ${business.rating ? `${business.rating}/5 (${business.reviews_count || 0} reviews)` : 'No ratings'}
- Categories: ${categories}
${hours ? `- Hours: ${hours}` : ''}
${auditInfo ? `- Audit: ${auditInfo}` : ''}
${scrapedContent ? `
REAL CONTENT FROM THEIR WEBSITE:
${scrapedContent}

CRITICAL: Use their real services, menu items, prices, descriptions, and brand voice from above. This makes the demo authentic and compelling.` : ''}
${customNotes ? `\nCLIENT NOTES: ${customNotes}` : ''}

TECHNICAL REQUIREMENTS:
- <!DOCTYPE html> with <html lang="${langCode}">
- ${style.fonts} at the top of <style>
- ALL CSS inline in <style> tag. Zero external CSS. Zero JavaScript.
- CSS custom properties: --clr-primary, --clr-secondary, --clr-accent, --clr-bg, --clr-surface, --clr-text, --clr-muted
- Mobile-first responsive: base styles for mobile, @media (min-width:768px) for tablet, @media (min-width:1024px) for desktop
- Smooth CSS transitions on all interactive elements (0.3s ease)
- Phone number as clickable <a href="tel:...">

PAGE STRUCTURE:
1. HERO (full viewport height or near it):
   ${style.heroStyle}
   - Business name: massive, striking typography
   - Tagline: ONE powerful sentence in ${language} that captures what makes THIS business special. Be creative, not generic.
   ${business.rating && business.rating >= 4 ? '- Show star rating prominently with visual stars (★)' : ''}

2. SERVICES/MENU (the money section):
   ${scrapedContent ? '- Use REAL items from the scraped content above' : '- Create 4-6 realistic, specific items for this business type and location'}
   - Beautiful card grid or list layout
   - Each item: name + short compelling description
   - If prices are available, show them elegantly

3. ABOUT/STORY (build trust):
   - 2-3 sentences about what makes this business unique
   - Mention their location, experience, specialties
   - ${business.rating && business.rating >= 4 ? `Feature their ${business.rating} star rating as social proof` : 'Focus on their expertise'}

4. ${hours ? 'HOURS: Clean, scannable grid layout with days and times' : 'WHY CHOOSE US: 3 compelling bullet points with icons (use unicode symbols)'}

5. CONTACT/CTA:
   - Strong call-to-action button (${business.phone ? '"Call Now" linking to tel:' : '"Visit Us"'})
   - Address, phone (clickable), any other contact info
   - Clean, prominent layout

6. FOOTER: Minimal. Business name + "Powered by LeadForge"

CSS TECHNIQUES TO USE:
- clamp() for fluid typography: headings clamp(2rem, 5vw, 4rem)
- Smooth box-shadows: multiple layered shadows for depth
- border-radius: 12-24px on cards, pill shape on buttons
- Subtle hover transforms: translateY(-2px) + shadow increase on cards
- Gradient backgrounds or borders where they enhance the design
- Good vertical rhythm: consistent spacing using rem units
- max-width container (1100px) centered with margin:auto

WHAT MAKES THIS WORTH PAYING FOR:
- It should look like a $2000+ custom website, not a free template
- Every section should feel intentional and polished
- Typography hierarchy must be clear: huge hero > medium headings > readable body
- Whitespace is a feature, not wasted space
- The CTA should be impossible to miss
- Mobile version should look just as good as desktop

Max 14000 characters. Return ONLY the HTML document.`

  let aiData: any
  try {
    const aiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4.1-mini',
        messages: [
          { role: 'system', content: `You are an award-winning web designer known for creating visually stunning, conversion-optimized single-page websites. Your designs are featured on Awwwards and Dribbble. You output ONLY valid HTML documents — never markdown, never code fences, never explanations. Every word of visible text must be in ${language}. You adapt your design precisely to the style direction given.` },
          { role: 'user', content: prompt },
        ],
        temperature: 0.75,
        max_tokens: 10000,
      }),
    })

    if (!aiResponse.ok) {
      console.error(`OpenAI API error: ${aiResponse.status}`)
      return buildFallbackHTML(business, langCode)
    }

    aiData = await aiResponse.json()
  } catch (e) {
    console.error('OpenAI call failed:', e)
    return buildFallbackHTML(business, langCode)
  }

  let html = aiData.choices?.[0]?.message?.content || ''

  // Clean up: remove markdown fences if AI added them
  html = html.replace(/^```html?\s*\n?/i, '').replace(/\n?```\s*$/i, '').trim()

  // Validate it's actual HTML
  if (!html.includes('<!DOCTYPE') && !html.includes('<html')) {
    return buildFallbackHTML(business, langCode)
  }

  return html
}

// Detect template from business categories for backward compatibility
function detectTemplate(categories: string[] | null): string {
  if (!categories || categories.length === 0) return 'professional'
  const joined = categories.join(' ').toLowerCase()
  if (/restaurant|cafe|bar|food|pizza|sushi|bakery|coffee|diner|grill|bistro|taco|burger|brew/i.test(joined)) return 'restaurant'
  if (/salon|spa|beauty|hair|nail|skin|massage|wellness|yoga|fitness|gym|clinic|dental|medical|health|therapy/i.test(joined)) return 'health_beauty'
  return 'professional'
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Auth
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Missing Authorization header' }), {
        status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    // User client — respects RLS for table operations
    const supabase = createClient(supabaseUrl, supabaseKey, {
      global: { headers: { Authorization: authHeader } }
    })

    // Admin client — for storage operations (bypasses RLS)
    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey)

    console.log('[build-demo] Step 1: Authenticating...')
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      console.error('[build-demo] Auth failed:', authError?.message)
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    console.log('[build-demo] Step 1: OK, user:', user.id)

    // 2. Check limits
    console.log('[build-demo] Step 2: Checking limits...')
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('subscription_tier, demos_this_month')
      .eq('id', user.id)
      .single()

    if (profileError || !profile) {
      console.error('[build-demo] Profile error:', profileError?.message)
      return new Response(JSON.stringify({ error: `Profile error: ${profileError?.message || 'not found'}` }), {
        status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    console.log('[build-demo] Step 2: OK, tier:', profile.subscription_tier, 'demos:', profile.demos_this_month)

    if (profile.subscription_tier === 'free' && profile.demos_this_month >= 1) {
      return new Response(JSON.stringify({ error: 'Free tier demo limit reached' }), {
        status: 402, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 3. Get business and request data
    console.log('[build-demo] Step 3: Fetching business...')
    const { business_id, custom_notes } = await req.json()
    const { data: business, error: bizError } = await supabase
      .from('businesses')
      .select('*')
      .eq('id', business_id)
      .eq('user_id', user.id)
      .single()

    if (bizError || !business) {
      console.error('[build-demo] Business error:', bizError?.message)
      return new Response(JSON.stringify({ error: `Business error: ${bizError?.message || 'not found'}` }), {
        status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    console.log('[build-demo] Step 3: OK, business:', business.name)

    // 4. Generate unique AI-powered HTML (includes website scraping)
    console.log('[build-demo] Step 4: Generating HTML...')
    const html = await generateUniqueHTML(business, custom_notes || null)
    console.log('[build-demo] Step 4: OK, html length:', html.length)

    const slug = generateSlug()
    const storagePath = `demos/${user.id}/${slug}.html`
    const template = detectTemplate(business.categories)

    // 5. Upload to Storage (using admin client to bypass storage RLS)
    console.log('[build-demo] Step 5: Uploading to storage, path:', storagePath)
    const { error: uploadError } = await supabaseAdmin.storage
      .from('demos')
      .upload(storagePath, new Blob([html], { type: 'text/html' }), {
        contentType: 'text/html',
        upsert: true,
      })

    if (uploadError) {
      console.error('[build-demo] Storage upload failed:', uploadError.message)
      throw new Error(`Storage upload failed: ${uploadError.message}`)
    }
    console.log('[build-demo] Step 5: OK')

    // 6. Create demo record
    console.log('[build-demo] Step 6: Inserting demo record...')
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
          categories: business.categories,
          audit_score: business.audit_score,
          audit_diagnosis: business.audit_diagnosis,
        },
      })
      .select()
      .single()

    if (insertError) {
      console.error('[build-demo] Insert failed:', insertError.message)
      throw new Error(`Demo insert failed: ${insertError.message}`)
    }
    console.log('[build-demo] Step 6: OK, demo id:', demo.id)

    // 7. Update business status
    console.log('[build-demo] Step 7: Updating business status...')
    await supabase
      .from('businesses')
      .update({ status: 'demo_created', updated_at: new Date().toISOString() })
      .eq('id', business_id)

    // 8. Increment usage
    await supabase
      .from('profiles')
      .update({ demos_this_month: profile.demos_this_month + 1 })
      .eq('id', user.id)

    console.log('[build-demo] DONE - success')
    return new Response(JSON.stringify({ demo }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('[build-demo] FATAL:', error.message)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})
