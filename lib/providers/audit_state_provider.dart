import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks per-business audit progress. Keyed by businessId.
/// AutoDisposed — ephemeral per-screen state.
/// - null = not started
/// - AsyncLoading = in progress
/// - AsyncData = completed
/// - AsyncError = failed
final auditStateProvider =
    StateProvider.autoDispose.family<AsyncValue<void>?, String>((ref, businessId) => null);
