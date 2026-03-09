import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/revenue_cat_service.dart';

/// Subscription state provider
final isProProvider = FutureProvider<bool>((ref) async {
  return await RevenueCatService.isPro();
});

/// Offerings provider
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  return await RevenueCatService.getOfferings();
});

/// Customer info provider
final customerInfoProvider = FutureProvider<CustomerInfo?>((ref) async {
  return await RevenueCatService.getCustomerInfo();
});

/// Subscription notifier
class SubscriptionNotifier extends StateNotifier<AsyncValue<bool>> {
  SubscriptionNotifier() : super(const AsyncValue.loading()) {
    _load();
  }
  
  Future<void> _load() async {
    state = const AsyncValue.loading();
    
    try {
      final isPro = await RevenueCatService.isPro();
      state = AsyncValue.data(isPro);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<bool> purchase(Package package) async {
    final success = await RevenueCatService.purchasePackage(package);
    
    if (success) {
      await _load();
    }
    
    return success;
  }
  
  Future<bool> restore() async {
    final isPro = await RevenueCatService.restorePurchases();
    await _load();
    return isPro;
  }
  
  Future<void> reload() => _load();
}

final subscriptionProvider = 
    StateNotifierProvider<SubscriptionNotifier, AsyncValue<bool>>((ref) {
  return SubscriptionNotifier();
});
