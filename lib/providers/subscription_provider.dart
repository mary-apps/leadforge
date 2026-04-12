import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/revenue_cat_service.dart';
import 'profile_provider.dart';

/// Subscription state — autoDisposed, refetched on demand
final isProProvider = FutureProvider.autoDispose<bool>((ref) async {
  return await RevenueCatService.isPro();
});

/// Offerings — autoDisposed, refetched when paywall opens
final offeringsProvider = FutureProvider.autoDispose<Offerings?>((ref) async {
  return await RevenueCatService.getOfferings();
});

/// Customer info — autoDisposed, refetched on demand
final customerInfoProvider = FutureProvider.autoDispose<CustomerInfo?>((ref) async {
  return await RevenueCatService.getCustomerInfo();
});

/// Subscription notifier — handles purchases and propagates changes
class SubscriptionNotifier extends StateNotifier<AsyncValue<bool>> {
  final Ref _ref;

  SubscriptionNotifier(this._ref) : super(const AsyncValue.loading()) {
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

  Future<({bool success, String? error})> purchase(Package package) async {
    final result = await RevenueCatService.purchasePackage(package);

    if (result.success) {
      await _load();
      // Invalidate dependent providers so they refetch with new tier
      _ref.invalidate(isProProvider);
      _ref.invalidate(profileProvider);
    }

    return result;
  }

  Future<({bool isPro, String? error})> restore() async {
    final result = await RevenueCatService.restorePurchases();
    await _load();
    // Invalidate dependent providers
    _ref.invalidate(isProProvider);
    _ref.invalidate(profileProvider);
    return result;
  }

  Future<void> reload() => _load();
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, AsyncValue<bool>>((ref) {
  return SubscriptionNotifier(ref);
});
