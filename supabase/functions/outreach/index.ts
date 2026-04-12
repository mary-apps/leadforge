// Outreach Edge Function - AI-powered sales message generation
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const channelInstructions: Record<string, string> = {
  email: 'Write a professional email with subject line, greeting, body, and sign-off. Keep it under 200 words.',
  whatsapp: 'Write a concise WhatsApp message. Friendly but professional. Keep it under 100 words. No subject line needed.',
  instagram: 'Write a short Instagram DM. Casual and friendly. Keep it under 80 words. Use 1-2 relevant emojis.',
  phone: 'Write a phone call script with an opener, key talking points, and a closing. Keep it natural and conversational.',
  other: 'Write a brief professional outreach message. Keep it under 150 words.',
}

const validTones = ['professional', 'friendly', 'casual', 'formal']
const validLanguages = ['en', 'es', 'pt', 'fr']

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Env var checks
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')
    if (!supabaseUrl || !supabaseKey) {
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
    const supabase = createClient(
      supabaseUrl,
      supabaseKey,
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 3. Pro-only check + rate limiting
    const { data: profile } = await supabase
      .from('profiles')
      .select('subscription_tier, display_name, business_name, outreach_this_month')
      .eq('id', user.id)
      .maybeSingle()

    const tier = profile?.subscription_tier ?? 'free'
    const outreachThisMonth = profile?.outreach_this_month ?? 0

    if (tier !== 'pro') {
      return new Response(JSON.stringify({ error: 'Outreach requires Pro subscription' }), {
        status: 402, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    if (outreachThisMonth >= 50) {
      return new Response(JSON.stringify({ error: 'Monthly outreach limit reached' }), {
        status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 4. Get request data and business
    const { business_id, channel, tone, language, demo_url } = await req.json()

    if (!business_id || typeof business_id !== 'string') {
      return new Response(JSON.stringify({ error: 'business_id is required' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    if (!channel || !['email', 'whatsapp', 'instagram', 'phone', 'other'].includes(channel)) {
      return new Response(JSON.stringify({ error: 'Invalid channel' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    if (tone && !validTones.includes(tone)) {
      return new Response(JSON.stringify({ error: 'Invalid tone' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    if (language && !validLanguages.includes(language)) {
      return new Response(JSON.stringify({ error: 'Invalid language' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    if (demo_url && (typeof demo_url !== 'string' || demo_url.length > 500)) {
      return new Response(JSON.stringify({ error: 'Invalid demo_url' }), {
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

    // 5. Generate message via OpenAI (with timeout)
    const openaiKey = Deno.env.get('OPENAI_API_KEY')
    const channelGuide = channelInstructions[channel] || channelInstructions.other

    const prompt = `You are a sales outreach expert helping a web agency reach out to local businesses.

Agency: ${profile?.business_name || 'Our Agency'}
Agent name: ${profile?.display_name || 'Sales Representative'}

Target business: ${business.name}
Address: ${business.address || 'Unknown'}
Industry: ${(business.categories || []).join(', ') || 'Local Business'}
Current website: ${business.website || 'None'}
Rating: ${business.rating || 'N/A'}/5 (${business.reviews_count || 0} reviews)
${business.audit_score != null ? `Audit score: ${business.audit_score}/100 - ${business.audit_diagnosis || ''}` : ''}
${demo_url ? `Demo website we built for them: ${demo_url}` : ''}

Channel: ${channel}
Tone: ${tone || 'professional'}
Language: ${language === 'es' ? 'Spanish' : language === 'pt' ? 'Portuguese' : language === 'fr' ? 'French' : 'English'}

${channelGuide}

Write the outreach message now. Output ONLY the message text, nothing else.`

    const aiController = new AbortController()
    const aiTimeout = setTimeout(() => aiController.abort(), 30000)
    let aiData: any
    try {
      const aiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${openaiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'gpt-4o-mini',
          messages: [{ role: 'user', content: prompt }],
          temperature: 0.7,
        }),
        signal: aiController.signal,
      })
      clearTimeout(aiTimeout)

      aiData = await aiResponse.json()
    } catch (e) {
      clearTimeout(aiTimeout)
      return new Response(JSON.stringify({ error: 'AI request timed out or failed' }), {
        status: 504, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    if (!aiData.choices?.[0]?.message?.content) {
      return new Response(JSON.stringify({ error: 'AI did not return a valid response' }), {
        status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    const messageContent = aiData.choices[0].message.content.trim()

    // 6. Save message to database
    const { data: message, error: insertError } = await supabase
      .from('messages')
      .insert({
        business_id,
        user_id: user.id,
        channel,
        tone: tone || 'professional',
        language: language || 'en',
        content: messageContent,
      })
      .select()
      .single()

    if (insertError) {
      throw new Error(`Message insert failed: ${insertError.message}`)
    }

    // 7. Update business status if early in pipeline
    if (['found', 'audited', 'demo_created'].includes(business.status)) {
      await supabase
        .from('businesses')
        .update({ status: 'contacted', updated_at: new Date().toISOString() })
        .eq('id', business_id)
    }

    // 8. Increment outreach usage
    try {
      await supabase.rpc('increment_counter', {
        p_user_id: user.id,
        p_column: 'outreach_this_month',
      })
    } catch {
      try {
        await supabase
          .from('profiles')
          .update({ outreach_this_month: outreachThisMonth + 1 })
          .eq('id', user.id)
      } catch (e) {
        console.warn('[outreach] Could not increment usage counter:', e)
      }
    }

    return new Response(JSON.stringify({ message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('[outreach] Error:', error.message)
    return new Response(JSON.stringify({ error: 'Something went wrong. Please try again.' }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})
