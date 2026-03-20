import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'supabase_service.dart';

class RevenueCatService {
  /// Check if user has Pro entitlement
  static Future<bool> isPro() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey('pro');
    } catch (e) {
      dev.log('RevenueCat isPro check failed: $e', name: 'RevenueCat');
      return false;
    }
  }

  /// Get available offerings
  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      dev.log('RevenueCat getOfferings failed: $e', name: 'RevenueCat');
      return null;
    }
  }

  /// Purchase a package
  static Future<({bool success, String? error})> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);

      if (result.customerInfo.entitlements.active.containsKey('pro')) {
        await _updateSubscriptionTier('pro');
        return (success: true, error: null);
      }

      return (success: false, error: 'Purchase completed but Pro entitlement not found');
    } on PlatformException catch (e) {
      if (e.code == 'PURCHASE_CANCELLED') {
        return (success: false, error: null); // User cancelled, not an error
      }
      dev.log('RevenueCat purchase failed: $e', name: 'RevenueCat');
      return (success: false, error: 'Purchase failed: ${e.message}');
    } catch (e) {
      dev.log('RevenueCat purchase failed: $e', name: 'RevenueCat');
      return (success: false, error: 'Purchase failed: $e');
    }
  }

  /// Restore purchases
  static Future<({bool isPro, String? error})> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();

      final isPro = customerInfo.entitlements.active.containsKey('pro');
      await _updateSubscriptionTier(isPro ? 'pro' : 'free');

      return (isPro: isPro, error: null);
    } catch (e) {
      dev.log('RevenueCat restore failed: $e', name: 'RevenueCat');
      return (isPro: false, error: 'Restore failed: $e');
    }
  }

  /// Update subscription tier in Supabase
  static Future<void> _updateSubscriptionTier(String tier) async {
    final userId = SupabaseService.userId;
    if (userId == null) return;

    try {
      await SupabaseService.client
          .from('profiles')
          .update({'subscription_tier': tier})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Failed to update subscription tier in Supabase: $e');
      rethrow;
    }
  }

  /// Get customer info
  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      dev.log('RevenueCat getCustomerInfo failed: $e', name: 'RevenueCat');
      return null;
    }
  }
}
