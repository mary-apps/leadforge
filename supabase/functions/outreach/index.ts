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

    // 2. Pro-only check
    const { data: profile } = await supabase
      .from('profiles')
      .select('subscription_tier, display_name, business_name')
      .eq('id', user.id)
      .single()

    if (profile.subscription_tier !== 'pro') {
      return new Response(JSON.stringify({ error: 'Outreach requires Pro subscription' }), {
        status: 402, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 3. Get request data and business
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

    // 4. Generate message via OpenAI
    const openaiKey = Deno.env.get('OPENAI_API_KEY')
    const channelGuide = channelInstructions[channel] || channelInstructions.other

    const prompt = `You are a sales outreach expert helping a web agency reach out to local businesses.

Agency: ${profile.business_name || 'Our Agency'}
Agent name: ${profile.display_name || 'Sales Representative'}

Target business: ${business.name}
Address: ${business.address || 'Unknown'}
Industry: ${(business.categories || []).join(', ') || 'Local Business'}
Current website: ${business.website || 'None'}
Rating: ${business.rating || 'N/A'}/5 (${business.reviews_count || 0} reviews)
${business.audit_score != null ? `Audit score: ${business.audit_score}/100 - ${business.audit_diagnosis || ''}` : ''}
${demo_url ? `Demo website we built for them: ${demo_url}` : ''}

Channel: ${channel}
Tone: ${tone}
Language: ${language === 'es' ? 'Spanish' : 'English'}

${channelGuide}

Write the outreach message now. Output ONLY the message text, nothing else.`

    const aiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4.1-mini',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.7,
      }),
    })

    const aiData = await aiResponse.json()
    if (!aiData.choices?.[0]?.message?.content) {
      return new Response(JSON.stringify({ error: 'AI did not return a valid response' }), {
        status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    const messageContent = aiData.choices[0].message.content.trim()

    // 5. Save message to database
    const { data: message, error: insertError } = await supabase
      .from('messages')
      .insert({
        business_id,
        user_id: user.id,
        channel,
        tone,
        language: language || 'en',
        content: messageContent,
      })
      .select()
      .single()

    if (insertError) {
      throw new Error(`Message insert failed: ${insertError.message}`)
    }

    // 6. Update business status if early in pipeline
    if (['found', 'audited', 'demo_created'].includes(business.status)) {
      await supabase
        .from('businesses')
        .update({ status: 'contacted', updated_at: new Date().toISOString() })
        .eq('id', business_id)
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
