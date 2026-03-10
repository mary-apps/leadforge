// Audit Edge Function - AI Business Web Presence Analysis
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
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

    // 2. Check usage limits
    const { data: profile } = await supabase
      .from('profiles')
      .select('subscription_tier, audits_this_month')
      .eq('id', user.id)
      .single()

    if (profile.subscription_tier === 'free' && profile.audits_this_month >= 3) {
      return new Response(JSON.stringify({ error: 'Free tier audit limit reached' }), {
        status: 402, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 3. Get business
    const { business_id } = await req.json()
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

    // 4. AI Audit via OpenAI
    const openaiKey = Deno.env.get('OPENAI_API_KEY')
    const prompt = `You are a digital marketing expert. Analyze this local business and score their web presence from 0-100.

Business: ${business.name}
Address: ${business.address || 'Unknown'}
Website: ${business.website || 'None'}
Rating: ${business.rating || 'N/A'} (${business.reviews_count} reviews)
Phone: ${business.phone || 'None'}
Categories: ${JSON.stringify(business.categories)}

Score these factors (each 0-20 points):
1. website_quality - Do they have a website? Is the URL professional?
2. online_reviews - Rating and review count quality
3. contact_info - Phone, address completeness
4. social_presence - Based on categories, likely social media presence
5. local_seo - Business listing completeness (photos, hours, categories)

Return ONLY valid JSON in this exact format:
{
  "score": <total 0-100>,
  "breakdown": {
    "website_quality": { "label": "Website Quality", "impact": <0-20>, "passed": <true/false> },
    "online_reviews": { "label": "Online Reviews", "impact": <0-20>, "passed": <true/false> },
    "contact_info": { "label": "Contact Info", "impact": <0-20>, "passed": <true/false> },
    "social_presence": { "label": "Social Presence", "impact": <0-20>, "passed": <true/false> },
    "local_seo": { "label": "Local SEO", "impact": <0-20>, "passed": <true/false> }
  },
  "diagnosis": "<2-3 sentence summary of main weaknesses and opportunity for a web agency to help>"
}`

    const aiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4.1-mini',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.3,
        response_format: { type: 'json_object' },
      }),
    })

    const aiData = await aiResponse.json()
    const auditResult = JSON.parse(aiData.choices[0].message.content)

    // 5. Save to database
    await supabase
      .from('businesses')
      .update({
        audit_score: auditResult.score,
        audit_breakdown: auditResult.breakdown,
        audit_diagnosis: auditResult.diagnosis,
        audited_at: new Date().toISOString(),
        status: 'audited',
        web_presence: auditResult.score >= 60 ? 'decent' : auditResult.score >= 30 ? 'poor' : 'none',
      })
      .eq('id', business_id)

    // 6. Increment usage
    await supabase
      .from('profiles')
      .update({ audits_this_month: profile.audits_this_month + 1 })
      .eq('id', user.id)

    // 7. Return result
    return new Response(JSON.stringify(auditResult), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})
