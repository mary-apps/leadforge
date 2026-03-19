import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client singleton
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  static User? get currentUser => client.auth.currentUser;
  
  static String? get userId => currentUser?.id;
  
  static bool get isLoggedIn => currentUser != null;
  
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  /// Sign in with email and password
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// Sign up with email and password
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }
  
  /// Sign in with Apple
  static Future<bool> signInWithApple() async {
    return await client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.leadforge.app://login-callback',
    );
  }
  
  /// Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  /// Get auth token for API calls (refreshes if expired)
  static Future<String?> getAuthToken() async {
    var session = client.auth.currentSession;
    if (session == null) return null;

    // Check if token is expired or about to expire (within 30s)
    final expiresAt = session.expiresAt;
    if (expiresAt != null) {
      final expiresDate = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
      if (DateTime.now().isAfter(expiresDate.subtract(const Duration(seconds: 30)))) {
        try {
          final response = await client.auth.refreshSession();
          session = response.session;
        } catch (_) {
          // If refresh fails, return current token and let the server reject it
          return session?.accessToken;
        }
      }
    }
    return session?.accessToken;
  }
}
