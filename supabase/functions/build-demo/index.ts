// Build Demo Edge Function - Generate demo websites using the template system
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { getTemplate, pickTemplateName } from './templates.ts'
import { renderTemplate, fallbackContent, type AiContent, type BusinessData } from './template-engine.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

function generateSlug(): string {
  return Array.from(
    { length: 8 },
    () => 'abcdefghijklmnopqrstuvwxyz0123456789'[Math.floor(Math.random() * 36)]
  ).join('')
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

async function fetchUnsplashImages(business: any): Promise<string[]> {
  const unsplashKey = Deno.env.get('UNSPLASH_ACCESS_KEY')
  if (!unsplashKey) return []

  // Build a search query from business category/name
  const cats = (business.categories || []).slice(0, 2).join(' ')
  const query = cats || business.name || 'business'

  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), 10000)
  try {
    const response = await fetch(
      `https://api.unsplash.com/search/photos?query=${encodeURIComponent(query)}&per_page=3&orientation=landscape`,
      {
        headers: { Authorization: `Client-ID ${unsplashKey}` },
        signal: controller.signal,
      }
    )
    clearTimeout(timeout)
    if (!response.ok) return []
    const data = await response.json()
    return (data.results || []).map((img: any) => img.urls?.regular).filter(Boolean)
  } catch (e) {
    clearTimeout(timeout)
    console.log('[build-demo] Unsplash fetch failed:', e.message)
    return []
  }
}

async function generateAiContent(
  business: any,
  scrapedContent: string | null,
  customNotes: string | null,
  language: string
): Promise<AiContent | null> {
  const openaiKey = Deno.env.get('OPENAI_API_KEY')
  if (!openaiKey) return null

  const categories = business.categories ? business.categories.join(', ') : 'Unknown'
  const ratingInfo = business.rating
    ? `${business.rating}/5 (${business.reviews_count || 0} reviews)`
    : 'No ratings'

  const prompt = `You are a copywriter creating website content for a local business. Return a JSON object with the following fields.

BUSINESS:
- Name: ${business.name}
- Address: ${business.address || 'N/A'}
- Phone: ${business.phone || 'N/A'}
- Rating: ${ratingInfo}
- Categories: ${categories}
${scrapedContent ? `\nREAL CONTENT FROM THEIR WEBSITE:\n${scrapedContent}\n` : ''}
${customNotes ? `\nCLIENT NOTES: ${customNotes}` : ''}

LANGUAGE: Write ALL text in ${language}.

Return a JSON object with exactly these fields:
{
  "headline": "Short punchy business tagline (max 8 words)",
  "subheadline": "One compelling sentence about what makes this business special (max 20 words)",
  "services": [
    {"name": "Service Name", "desc": "Short compelling description (8-15 words)"},
    {"name": "Service Name 2", "desc": "Short compelling description (8-15 words)"}
  ],
  "about": "2-3 sentence paragraph about the business, its specialties, and location. Make it warm and authentic.",
  "why_us": ["Compelling reason 1 with a unicode symbol prefix", "Compelling reason 2 with a unicode symbol prefix", "Compelling reason 3 with a unicode symbol prefix"],
  "cta_text": "Call-to-action button text (max 4 words)",
  "palette": {
    "primary": "#hexcolor",
    "secondary": "#hexcolor",
    "accent": "#hexcolor",
    "bg": "#hexcolor",
    "surface": "#hexcolor",
    "text": "#hexcolor",
    "muted": "#hexcolor"
  }
}

For the palette, choose colors that fit the business type and feel premium. Use real hex color codes.
For services, include 4-6 items with name and a compelling description. Use real items from the scraped content if available, otherwise create realistic specific items for this business type.`

  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), 30000)
  try {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o',
        messages: [
          {
            role: 'system',
            content: 'You are a professional copywriter. Return only valid JSON matching the requested schema. No markdown fences, no extra text.',
          },
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
      console.error('[build-demo] OpenAI API error:', response.status)
      return null
    }

    const data = await response.json()
    const raw = data.choices?.[0]?.message?.content || ''
    const parsed = JSON.parse(raw) as AiContent
    return parsed
  } catch (e) {
    clearTimeout(timeout)
    console.error('[build-demo] generateAiContent failed:', e.message)
    return null
  }
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

    // Env var checks
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    if (!supabaseUrl || !supabaseKey || !serviceRoleKey) {
      return new Response(JSON.stringify({ error: 'Server misconfigured' }), {
        status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // User client — respects RLS for table operations
    const supabase = createClient(supabaseUrl, supabaseKey, {
      global: { headers: { Authorization: authHeader } }
    })

    // Admin client — for storage operations (bypasses RLS)
    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey)

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      console.error('[build-demo] Auth failed:', authError?.message)
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 2. Parse request body first (needed for parallel fetches below)
    const { business_id, custom_notes } = await req.json()

    if (!business_id || typeof business_id !== 'string') {
      return new Response(JSON.stringify({ error: 'business_id is required' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    if (custom_notes && typeof custom_notes === 'string' && custom_notes.length > 500) {
      return new Response(JSON.stringify({ error: 'custom_notes too long (max 500 characters)' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 3. Parallel: check limits + fetch business
    const [profileResult, businessResult] = await Promise.all([
      supabase.from('profiles').select('subscription_tier, demos_this_month').eq('id', user.id).single(),
      supabase.from('businesses').select('*').eq('id', business_id).eq('user_id', user.id).single(),
    ])

    const { data: profile, error: profileError } = profileResult
    if (profileError || !profile) {
      console.error('[build-demo] Profile error:', profileError?.message)
      return new Response(JSON.stringify({ error: `Profile error: ${profileError?.message || 'not found'}` }), {
        status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    if (profile.subscription_tier === 'free' && profile.demos_this_month >= 1) {
      return new Response(JSON.stringify({ error: 'Free tier demo limit reached' }), {
        status: 402, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    const { data: business, error: bizError } = businessResult
    if (bizError || !business) {
      console.error('[build-demo] Business error:', bizError?.message)
      return new Response(JSON.stringify({ error: `Business error: ${bizError?.message || 'not found'}` }), {
        status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 4. Pick template + detect language
    const templateName = pickTemplateName(business)
    const { language, langCode } = detectLanguage(business)
    console.log('[build-demo] template:', templateName, '| language:', language)

    // 5. Parallel: scrape website + fetch images
    const [scrapedContent, unsplashImages] = await Promise.all([
      scrapeBusinessWebsite(business.website),
      fetchUnsplashImages(business),
    ])

    // 6. Generate AI content (JSON payload, not full HTML)
    const businessData: BusinessData = {
      name: business.name,
      address: business.address,
      phone: business.phone,
      website: business.website,
      rating: business.rating,
      reviews_count: business.reviews_count,
      categories: business.categories,
      opening_hours: business.opening_hours,
      audit_score: business.audit_score,
      audit_diagnosis: business.audit_diagnosis,
    }

    let aiContent: AiContent
    const rawAiContent = await generateAiContent(business, scrapedContent, custom_notes || null, language)
    if (rawAiContent) {
      aiContent = rawAiContent
    } else {
      aiContent = fallbackContent(businessData, langCode)
    }

    // 7. Get template HTML and render
    const templateHtml = getTemplate(templateName)
    const images = {
      hero: unsplashImages[0],
      section: unsplashImages[1],
    }
    const html = renderTemplate(templateHtml, aiContent, businessData, images)

    const slug = generateSlug()
    const storagePath = `demos/${user.id}/${slug}.html`

    // 8. Upload to Storage (using admin client to bypass storage RLS)
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

    // 9. Create demo record
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

    if (insertError) {
      console.error('[build-demo] Insert failed:', insertError.message)
      throw new Error(`Demo insert failed: ${insertError.message}`)
    }

    // 10. Update business status
    await supabase
      .from('businesses')
      .update({ status: 'demo_created', updated_at: new Date().toISOString() })
      .eq('id', business_id)

    // 11. Increment usage (atomic via rpc or fallback)
    try {
      await supabase.rpc('increment_counter', {
        p_user_id: user.id,
        p_column: 'demos_this_month',
      })
    } catch {
      await supabase
        .from('profiles')
        .update({ demos_this_month: profile.demos_this_month + 1 })
        .eq('id', user.id)
    }

    console.log('[build-demo] success, html length:', html.length)
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
