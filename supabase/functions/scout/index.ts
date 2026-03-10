// Scout Edge Function - Business Discovery
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Auth check
    const authHeader = req.headers.get('Authorization')!
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    )
    
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    
    // 2. Check usage limits
    const { data: profile } = await supabase
      .from('profiles')
      .select('subscription_tier, searches_this_month, month_reset_at')
      .eq('id', user.id)
      .single()
    
    if (profile.subscription_tier === 'free' && profile.searches_this_month >= 5) {
      return new Response(JSON.stringify({ error: 'Free tier limit reached' }), {
        status: 402,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    
    // 3. Parse request
    const { query } = await req.json()
    
    // 4. Google Places Text Search
    const placesUrl = `https://maps.googleapis.com/maps/api/place/textsearch/json?query=${encodeURIComponent(query)}&key=${Deno.env.get('GOOGLE_PLACES_API_KEY')}`
    const placesRes = await fetch(placesUrl)
    const placesData = await placesRes.json()
    
    if (placesData.status !== 'OK') {
      return new Response(JSON.stringify({ error: `Google Places API error: ${placesData.status}` }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    
    // 5. Fetch details for each (parallel, limit 20)
    const detailsPromises = placesData.results.slice(0, 20).map(async (place: any) => {
      const detailsUrl = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${place.place_id}&fields=website,formatted_phone_number,opening_hours,photos&key=${Deno.env.get('GOOGLE_PLACES_API_KEY')}`
      const detailsRes = await fetch(detailsUrl)
      const detailsData = await detailsRes.json()
      
      return {
        ...place,
        details: detailsData.result
      }
    })
    
    const enrichedPlaces = await Promise.all(detailsPromises)
    
    // 6. Format businesses
    const businesses = enrichedPlaces.map(place => ({
      place_id: place.place_id,
      name: place.name,
      address: place.formatted_address,
      latitude: place.geometry.location.lat,
      longitude: place.geometry.location.lng,
      rating: place.rating || null,
      reviews_count: place.user_ratings_total || 0,
      phone: place.details?.formatted_phone_number || null,
      website: place.details?.website || null,
      photos: (place.photos || []).map((p: any) => p.photo_reference),
      categories: place.types || [],
      opening_hours: place.details?.opening_hours || null,
      web_presence: !place.details?.website ? 'none' : 'poor',
      user_id: user.id,
    }))
    
    // 7. Insert businesses (skip duplicates by place_id per user)
    const businessesForInsert = businesses.map(b => ({
      ...b,
      created_at: new Date().toISOString(),
    }))

    await supabase
      .from('businesses')
      .upsert(businessesForInsert, {
        onConflict: 'user_id,place_id',
        ignoreDuplicates: true
      })
    
    // 9. Increment usage
    await supabase
      .from('profiles')
      .update({ searches_this_month: profile.searches_this_month + 1 })
      .eq('id', user.id)
    
    // 10. Sort results
    const sorted = businesses.sort((a, b) => {
      if (a.web_presence === 'none' && b.web_presence !== 'none') return -1
      if (a.web_presence !== 'none' && b.web_presence === 'none') return 1
      return (a.rating || 0) - (b.rating || 0)
    })
    
    return new Response(JSON.stringify({ businesses: sorted }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
    
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})
