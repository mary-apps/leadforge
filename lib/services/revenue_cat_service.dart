import 'package:purchases_flutter/purchases_flutter.dart';

import 'supabase_service.dart';

class RevenueCatService {
  /// Check if user has Pro entitlement
  static Future<bool> isPro() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey('pro');
    } catch (e) {
      return false;
    }
  }
  
  /// Get available offerings
  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      return null;
    }
  }
  
  /// Purchase a package
  static Future<bool> purchasePackage(Package package) async {
    try {
      final purchaserInfo = await Purchases.purchasePackage(package);
      
      if (purchaserInfo.entitlements.active.containsKey('pro')) {
        // Update Supabase profile
        await _updateSubscriptionTier('pro');
        return true;
      }
      
      return false;
    } catch (e) {
      // User cancelled or error
      return false;
    }
  }
  
  /// Restore purchases
  static Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      
      final isPro = customerInfo.entitlements.active.containsKey('pro');
      await _updateSubscriptionTier(isPro ? 'pro' : 'free');
      
      return isPro;
    } catch (e) {
      return false;
    }
  }
  
  /// Update subscription tier in Supabase
  static Future<void> _updateSubscriptionTier(String tier) async {
    final userId = SupabaseService.userId;
    if (userId == null) return;
    
    await SupabaseService.client
        .from('profiles')
        .update({'subscription_tier': tier})
        .eq('id', userId);
  }
  
  /// Get customer info
  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      return null;
    }
  }
}
