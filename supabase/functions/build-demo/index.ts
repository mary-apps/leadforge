// Build Demo Edge Function - Generate demo websites for prospects
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
