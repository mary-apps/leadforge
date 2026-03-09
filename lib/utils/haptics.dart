import 'package:flutter/services.dart';

/// Haptic feedback utilities
class Haptics {
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }
  
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }
  
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }
  
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }
}
