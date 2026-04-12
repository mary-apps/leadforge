import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

/// Auth state
class AuthState {
  final User? user;
  final bool isLoading;
  final bool needsOnboarding;
  
  AuthState({
    this.user,
    this.isLoading = false,
    this.needsOnboarding = false,
  });
  
  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? needsOnboarding,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      needsOnboarding: needsOnboarding ?? this.needsOnboarding,
    );
  }
}

/// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  StreamSubscription? _authSubscription;

  AuthNotifier() : super(AuthState(isLoading: true)) {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _authSubscription = SupabaseService.authStateChanges.listen((data) {
      final event = data.event;
      final user = data.session?.user;

      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.initialSession) {
        state = state.copyWith(user: user, isLoading: false);
        if (user != null) _checkOnboarding();
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        // Keep user in sync without re-checking onboarding
        if (user != null) {
          state = state.copyWith(user: user);
        }
      } else if (event == AuthChangeEvent.signedOut) {
        state = AuthState(user: null, isLoading: false, needsOnboarding: false);
      }
    });
    
    // Check current session and validate it's still refreshable
    final currentUser = SupabaseService.currentUser;
    if (currentUser != null) {
      _validateSession(currentUser);
    } else {
      state = state.copyWith(user: null, isLoading: false);
    }
  }

  Future<void> _validateSession(User cachedUser) async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) {
      state = AuthState(user: null, isLoading: false);
      return;
    }

    final expiresAt = session.expiresAt;
    final isExpired = expiresAt != null &&
        DateTime.now().isAfter(
          DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000),
        );

    if (isExpired) {
      try {
        await SupabaseService.client.auth.refreshSession();
        // Refresh succeeded — stream listener will update state
      } catch (e) {
        debugPrint('Session validation failed, signing out: $e');
        await signOut();
        return;
      }
    }

    state = state.copyWith(user: cachedUser, isLoading: false);
    _checkOnboarding();
  }
  
  Future<void> _checkOnboarding() async {
    // Check if user has completed profile setup
    final userId = SupabaseService.userId;
    if (userId == null) return;
    
    final response = await SupabaseService.client
        .from('profiles')
        .select('display_name, business_name')
        .eq('id', userId)
        .maybeSingle();
    
    if (response == null) {
      state = state.copyWith(needsOnboarding: true);
      return;
    }
    
    final profile = response;
    final needsOnboarding = profile['display_name'] == null || 
                            profile['business_name'] == null;
    
    state = state.copyWith(needsOnboarding: needsOnboarding);
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await SupabaseService.signInWithEmail(email: email, password: password);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
  
  Future<void> signUpWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await SupabaseService.signUpWithEmail(email: email, password: password);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
  
  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true);
    try {
      await SupabaseService.signInWithApple();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    await SupabaseService.signOut();
    // Ensure state is cleared even if the stream event is delayed
    state = AuthState(user: null, isLoading: false, needsOnboarding: false);
  }

  Future<void> resetPassword(String email) async {
    await SupabaseService.client.auth.resetPasswordForEmail(email);
  }
  
  Future<void> completeOnboarding({
    required String displayName,
    required String businessName,
  }) async {
    final userId = SupabaseService.userId;
    if (userId == null) return;
    
    await SupabaseService.client
        .from('profiles')
        .update({
          'display_name': displayName,
          'business_name': businessName,
        })
        .eq('id', userId);
    
    state = state.copyWith(needsOnboarding: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
