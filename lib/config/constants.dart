/// App-wide constants and configuration
class AppConstants {
  // Supabase Config
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );
  
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  // RevenueCat Config
  static const revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: 'YOUR_REVENUECAT_KEY',
  );
  
  // Free Tier Limits
  static const freeSearchesPerMonth = 5;
  static const freeAuditsPerMonth = 3;
  static const freeDemosPerMonth = 1;
  
  // Subscription Tiers
  static const tierFree = 'free';
  static const tierPro = 'pro';
  
  // API Endpoints (Edge Functions)
  static String get scoutEndpoint => '$supabaseUrl/functions/v1/scout';
  static String get auditEndpoint => '$supabaseUrl/functions/v1/audit';
  static String get buildDemoEndpoint => '$supabaseUrl/functions/v1/build-demo';
  static String get outreachEndpoint => '$supabaseUrl/functions/v1/outreach';
  static String demoUrl(String slug) => '$supabaseUrl/functions/v1/demo/$slug';
  
  // Animation Durations
  static const quickAnimation = Duration(milliseconds: 200);
  static const standardAnimation = Duration(milliseconds: 300);
  static const slowAnimation = Duration(milliseconds: 400);
  
  // Suggested Niches
  static const suggestedNiches = [
    'Dentists',
    'Restaurants',
    'Plumbers',
    'Lawyers',
    'Hair Salons',
    'Gyms',
    'Cafés',
    'Retail Stores',
  ];
  
  // Demo Templates
  static const templateRestaurant = 'restaurant';
  static const templateProfessional = 'professional';
  static const templateHealthBeauty = 'health_beauty';
}
