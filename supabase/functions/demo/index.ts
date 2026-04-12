// Demo Serving Edge Function - Serve generated demo HTML pages
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
    // Env var checks
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    if (!supabaseUrl || !supabaseKey || !serviceRoleKey) {
      return new Response(JSON.stringify({ error: 'Server misconfigured' }), {
        status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // Extract slug from URL path: /functions/v1/demo/{slug}
    const url = new URL(req.url)
    const pathParts = url.pathname.split('/')
    const slug = pathParts[pathParts.length - 1]

    if (!slug) {
      return new Response('<h1>Not found</h1>', {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'text/html' },
      })
    }

    // Service role client — demos are public-facing, need to bypass RLS
    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey)

    // Find demo by slug
    const { data: demo, error } = await supabaseAdmin
      .from('demos')
      .select('storage_path, views')
      .eq('public_slug', slug)
      .single()

    if (error || !demo) {
      console.error('[demo] Not found:', slug, error?.message)
      return new Response('<h1>Demo not found</h1><p>This demo link may have expired.</p>', {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'text/html' },
      })
    }

    // Increment view count (fire and forget)
    supabaseAdmin
      .from('demos')
      .update({
        views: (demo.views || 0) + 1,
        last_viewed_at: new Date().toISOString(),
      })
      .eq('public_slug', slug)
      .then(({ error }) => { if (error) console.error('[demo] view increment failed:', error.message) })

    // Fetch HTML from storage
    const { data: fileData, error: downloadError } = await supabaseAdmin.storage
      .from('demos')
      .download(demo.storage_path)

    if (downloadError || !fileData) {
      return new Response('<h1>Demo unavailable</h1><p>Could not load demo content.</p>', {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'text/html' },
      })
    }

    const html = await fileData.text()

    return new Response(html, {
      headers: {
        ...corsHeaders,
        'Content-Type': 'text/html; charset=utf-8',
        'Cache-Control': 'public, max-age=3600',
      },
    })
  } catch (error) {
    return new Response('<h1>Error</h1><p>An unexpected error occurred.</p>', {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'text/html' },
    })
  }
})
