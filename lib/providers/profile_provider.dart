import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile.dart';
import '../services/supabase_service.dart';

/// Profile provider
final profileProvider = FutureProvider<Profile?>((ref) async {
  final userId = SupabaseService.userId;
  if (userId == null) return null;
  
  final response = await SupabaseService.client
      .from('profiles')
      .select()
      .eq('id', userId)
      .maybeSingle();
  
  if (response == null) return null;
  
  return Profile.fromJson(response);
});

/// Profile notifier for updates
class ProfileNotifier extends StateNotifier<AsyncValue<Profile?>> {
  ProfileNotifier() : super(const AsyncValue.loading()) {
    _load();
  }
  
  Future<void> _load() async {
    state = const AsyncValue.loading();
    
    try {
      final userId = SupabaseService.userId;
      if (userId == null) {
        state = const AsyncValue.data(null);
        return;
      }
      
      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) {
        state = const AsyncValue.data(null);
        return;
      }
      
      final profile = Profile.fromJson(response);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> updatePreferredLanguage(String language) async {
    final userId = SupabaseService.userId;
    if (userId == null) return;
    
    await SupabaseService.client
        .from('profiles')
        .update({'preferred_language': language})
        .eq('id', userId);
    
    await _load();
  }
  
  Future<void> reload() => _load();
}

final profileNotifierProvider = 
    StateNotifierProvider<ProfileNotifier, AsyncValue<Profile?>>((ref) {
  return ProfileNotifier();
});
