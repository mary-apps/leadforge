import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks per-business audit progress. Keyed by businessId.
/// - null = not started
/// - AsyncLoading = in progress
/// - AsyncData = completed
/// - AsyncError = failed
final auditStateProvider =
    StateProvider.family<AsyncValue<void>?, String>((ref, businessId) => null);
