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
  static Future<AuthResponse> signInWithApple() async {
    return await client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.leadforge.app://login-callback',
    );
  }
  
  /// Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  /// Get auth token for API calls
  static Future<String?> getAuthToken() async {
    final session = client.auth.currentSession;
    return session?.accessToken;
  }
}
