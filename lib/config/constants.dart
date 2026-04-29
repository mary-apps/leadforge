import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App-wide constants and configuration
class AppConstants {
  // Supabase Config
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    assert(url != null && url.isNotEmpty, 'SUPABASE_URL not set in .env');
    return url ?? '';
  }

  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    assert(key != null && key.isNotEmpty, 'SUPABASE_ANON_KEY not set in .env');
    return key ?? '';
  }

  // RevenueCat Config
  static String get revenueCatApiKey {
    final key = dotenv.env['REVENUECAT_API_KEY'];
    assert(key != null && key.isNotEmpty, 'REVENUECAT_API_KEY not set in .env');
    return key ?? '';
  }

  // Free Tier Limits
  static const freeSearchesPerMonth = 10;
  static const freeAuditsPerMonth = 10;
  static const freeReportsPerMonth = 3;

  // Subscription Tiers
  static const tierFree = 'free';
  static const tierPro = 'pro';

  // API Endpoints (Edge Functions)
  static String get scoutEndpoint => '$supabaseUrl/functions/v1/scout';
  static String get auditEndpoint => '$supabaseUrl/functions/v1/audit';
  static String get outreachEndpoint => '$supabaseUrl/functions/v1/outreach';

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
    'Cafes',
    'Retail Stores',
  ];

}
