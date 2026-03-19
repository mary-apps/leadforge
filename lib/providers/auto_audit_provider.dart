import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'auto_audit_enabled';

final autoAuditProvider = StateNotifierProvider<AutoAuditNotifier, bool>((ref) {
  return AutoAuditNotifier();
});

class AutoAuditNotifier extends StateNotifier<bool> {
  AutoAuditNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? true;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }
}
