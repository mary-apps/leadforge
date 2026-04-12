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
    // 1. Env var checks
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')
    const googlePlacesKey = Deno.env.get('GOOGLE_PLACES_API_KEY')
    if (!supabaseUrl || !supabaseKey) {
      return new Response(JSON.stringify({ error: 'Server misconfigured' }), {
        status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    if (!googlePlacesKey) {
      return new Response(JSON.stringify({ error: 'Server misconfigured' }), {
        status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 2. Auth check
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
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 3. Check usage limits
    const { data: profile } = await supabase
      .from('profiles')
      .select('subscription_tier, searches_this_month, month_reset_at')
      .eq('id', user.id)
      .maybeSingle()

    const tier = profile?.subscription_tier ?? 'free'
    const searchesThisMonth = profile?.searches_this_month ?? 0

    if (tier === 'free' && searchesThisMonth >= 5) {
      return new Response(JSON.stringify({ error: 'Free tier limit reached' }), {
        status: 402,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 4. Parse request — supports legacy `query` and new territory/nearby params
    const body = await req.json()
    const {
      query,
      niche,
      location,
      latitude,
      longitude,
      radius = 2000,
      type,
      territory_id,
      page_token,
    } = body

    // Derive the search term: accept either `query` (legacy) or `niche` + optional `location`
    const searchQuery = query || (niche && location ? `${niche} ${location}` : niche) || null

    // Nearby Search requires lat/lng; Text Search requires a query string
    const useNearby = typeof latitude === 'number' && typeof longitude === 'number'

    if (!useNearby && (!searchQuery || typeof searchQuery !== 'string' || searchQuery.trim().length === 0)) {
      return new Response(JSON.stringify({ error: 'Query is required (or provide latitude and longitude for nearby search)' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 5. Build Google Places URL — Nearby Search or Text Search
    let placesUrl: string
    if (page_token) {
      // Pagination: Google requires ONLY the token + key when using page_token
      placesUrl = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=${encodeURIComponent(page_token)}&key=${googlePlacesKey}`
    } else if (useNearby) {
      const keyword = niche || query || ''
      placesUrl = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latitude},${longitude}&radius=${radius}&keyword=${encodeURIComponent(keyword)}${type ? `&type=${encodeURIComponent(type)}` : ''}&key=${googlePlacesKey}`
    } else {
      placesUrl = `https://maps.googleapis.com/maps/api/place/textsearch/json?query=${encodeURIComponent(searchQuery!.trim())}&key=${googlePlacesKey}`
    }

    const placesController = new AbortController()
    const placesTimeout = setTimeout(() => placesController.abort(), 15000)
    let placesData: any
    try {
      const placesRes = await fetch(placesUrl, { signal: placesController.signal })
      clearTimeout(placesTimeout)
      placesData = await placesRes.json()
    } catch (e) {
      clearTimeout(placesTimeout)
      return new Response(JSON.stringify({ error: 'Google Places request timed out or failed' }), {
        status: 504, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    if (placesData.status !== 'OK' && placesData.status !== 'ZERO_RESULTS') {
      return new Response(JSON.stringify({ error: `Google Places API error: ${placesData.status}` }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 6. Fetch details for each (parallel, limit 20 per page, with timeout)
    const detailsPromises = (placesData.results || []).slice(0, 20).map(async (place: any) => {
      const detailsUrl = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${place.place_id}&fields=website,formatted_phone_number,opening_hours,photos&key=${googlePlacesKey}`

      const detailController = new AbortController()
      const detailTimeout = setTimeout(() => detailController.abort(), 15000)
      try {
        const detailsRes = await fetch(detailsUrl, { signal: detailController.signal })
        clearTimeout(detailTimeout)
        const detailsData = await detailsRes.json()
        return {
          ...place,
          details: detailsData.result
        }
      } catch (e) {
        clearTimeout(detailTimeout)
        return {
          ...place,
          details: null
        }
      }
    })

    const enrichedPlaces = await Promise.all(detailsPromises)

    // 7. Format businesses
    const businesses = enrichedPlaces.map(place => ({
      place_id: place.place_id,
      name: place.name,
      address: place.formatted_address || place.vicinity || null,
      latitude: place.geometry?.location?.lat ?? null,
      longitude: place.geometry?.location?.lng ?? null,
      rating: place.rating || null,
      reviews_count: place.user_ratings_total || 0,
      phone: place.details?.formatted_phone_number || null,
      website: place.details?.website || null,
      photos: (place.photos || []).map((p: any) => p.photo_reference),
      categories: place.types || [],
      opening_hours: place.details?.opening_hours || null,
      web_presence: !place.details?.website ? 'none' : 'poor',
      user_id: user.id,
      ...(territory_id ? { territory_id } : {}),
    }))

    // 8. Insert businesses (skip duplicates by place_id per user)
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

    // 9. Fetch inserted businesses from DB (with generated IDs)
    const placeIds = businesses.map(b => b.place_id)
    const { data: dbBusinesses } = await supabase
      .from('businesses')
      .select('*')
      .eq('user_id', user.id)
      .in('place_id', placeIds)

    const savedBusinesses = dbBusinesses || []

    // 10. Update territory stats if territory_id was provided
    if (territory_id) {
      const { count } = await supabase
        .from('businesses')
        .select('id', { count: 'exact', head: true })
        .eq('territory_id', territory_id)
        .eq('user_id', user.id)

      await supabase
        .from('territories')
        .update({
          business_count: count || 0,
          last_scanned_at: new Date().toISOString()
        })
        .eq('id', territory_id)
    }

    // 11. Increment usage (atomic via rpc or fallback)
    try {
      await supabase.rpc('increment_counter', {
        p_user_id: user.id,
        p_column: 'searches_this_month',
      })
    } catch {
      try {
        await supabase
          .from('profiles')
          .update({ searches_this_month: searchesThisMonth + 1 })
          .eq('id', user.id)
      } catch (e) {
        console.warn('[scout] Could not increment usage counter:', e)
      }
    }

    // 12. Sort results — no website first, then by rating
    const sorted = savedBusinesses.sort((a: any, b: any) => {
      if (a.web_presence === 'none' && b.web_presence !== 'none') return -1
      if (a.web_presence !== 'none' && b.web_presence === 'none') return 1
      return (a.rating || 0) - (b.rating || 0)
    })

    return new Response(JSON.stringify({
      businesses: sorted,
      next_page_token: placesData.next_page_token || null,
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('[scout] Error:', error.message)
    return new Response(JSON.stringify({ error: 'Something went wrong. Please try again.' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})
