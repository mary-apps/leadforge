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

function buildFallbackHTML(business: any): string {
  return `<!DOCTYPE html>
<html lang="en">
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
    <h2>Contact Us</h2>
    <div class="contact-grid">
      ${business.phone ? `<div class="contact-card"><h3>📞 Phone</h3><p>${business.phone}</p></div>` : ''}
      ${business.address ? `<div class="contact-card"><h3>📍 Address</h3><p>${business.address}</p></div>` : ''}
      ${business.website ? `<div class="contact-card"><h3>🌐 Website</h3><p>${business.website}</p></div>` : ''}
    </div>
  </div>
  <div class="footer"><p>Demo website — Powered by LeadForge</p></div>
</body>
</html>`
}

async function generateUniqueHTML(business: any, customNotes: string | null): Promise<string> {
  const openaiKey = Deno.env.get('OPENAI_API_KEY')
  if (!openaiKey) {
    return buildFallbackHTML(business)
  }

  const categories = business.categories ? JSON.stringify(business.categories) : 'Unknown'
  const hours = business.opening_hours ? JSON.stringify(business.opening_hours) : null
  const auditInfo = business.audit_score != null
    ? `Web presence score: ${business.audit_score}/100.\nDiagnosis: ${business.audit_diagnosis || 'N/A'}.\nBreakdown: ${JSON.stringify(business.audit_breakdown || {})}`
    : null

  const prompt = `You are an elite web designer and copywriter. Generate a COMPLETE, UNIQUE, production-quality HTML page for this local business. Every website you create must be different — unique layout, unique color palette, unique sections, unique tone.

BUSINESS IDENTITY:
- Name: ${business.name}
- Address: ${business.address || 'Unknown'}
- Phone: ${business.phone || 'None'}
- Website: ${business.website || 'None'}
- Rating: ${business.rating || 'N/A'}/5 (${business.reviews_count || 0} reviews)
- Categories: ${categories}
${hours ? `- Opening Hours: ${hours}` : ''}
${auditInfo ? `\nWEB PRESENCE ANALYSIS:\n${auditInfo}` : ''}
${customNotes ? `\nSPECIAL INSTRUCTIONS:\n${customNotes}` : ''}

REQUIREMENTS:
1. Return a COMPLETE <!DOCTYPE html> document with inline CSS (no external dependencies)
2. Choose a color palette that matches this SPECIFIC business type and vibe — a sushi bar gets different colors than a law firm or a nail salon
3. Choose sections that make sense for THIS business:
   - A restaurant might get: hero, menu highlights, ambiance, reviews, hours, reservation CTA
   - A lawyer might get: hero, practice areas, credentials, testimonials, consultation CTA
   - A salon might get: hero, services with pricing hints, gallery feel, booking CTA
   - Be creative — don't use the same sections for every business
4. All copy must be specific to this business — mention their actual categories, location, and strengths
5. If they have a good rating (4+), feature it prominently with stars
6. If they have opening hours, show them in a clean format
7. Phone numbers must be clickable (tel: links)
8. Must be fully responsive (mobile-first, use @media queries)
9. Use modern CSS: gradients, subtle shadows, smooth transitions on hover
10. Include a compelling hero section with a tagline written specifically for this business
11. End with a clear call-to-action (call, visit, book — whatever fits)
12. Footer must include: "Powered by LeadForge"
13. Keep total HTML under 8000 characters — be concise but polished
14. NO placeholder text, NO lorem ipsum, NO generic "trusted local business" filler
15. NO JavaScript — pure HTML + CSS only
16. Use web-safe fonts only (system font stack)

Return ONLY the complete HTML document. No markdown, no explanation, no code fences.`

  const aiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${openaiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-4.1-mini',
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.9,
      max_tokens: 4096,
    }),
  })

  const aiData = await aiResponse.json()
  let html = aiData.choices?.[0]?.message?.content || ''

  // Clean up: remove markdown fences if AI added them
  html = html.replace(/^```html?\s*\n?/i, '').replace(/\n?```\s*$/i, '').trim()

  // Validate it's actual HTML
  if (!html.includes('<!DOCTYPE') && !html.includes('<html')) {
    return buildFallbackHTML(business)
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
    const { business_id, custom_notes } = await req.json()
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

    // 4. Generate unique AI-powered HTML
    const html = await generateUniqueHTML(business, custom_notes || null)
    const slug = generateSlug()
    const storagePath = `demos/${user.id}/${slug}.html`
    const template = detectTemplate(business.categories)

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
          categories: business.categories,
          audit_score: business.audit_score,
          audit_diagnosis: business.audit_diagnosis,
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
