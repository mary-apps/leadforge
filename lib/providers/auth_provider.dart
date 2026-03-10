import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../models/profile.dart';

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
      if (event == AuthChangeEvent.signedIn) {
        state = state.copyWith(user: data.session?.user, isLoading: false);
        _checkOnboarding();
      } else if (event == AuthChangeEvent.signedOut) {
        state = state.copyWith(user: null, isLoading: false);
      }
    });
    
    // Check current session
    final currentUser = SupabaseService.currentUser;
    state = state.copyWith(user: currentUser, isLoading: false);
    
    if (currentUser != null) {
      _checkOnboarding();
    }
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
