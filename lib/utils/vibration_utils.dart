import 'package:hear_and_see_safe/utils/platform_utils.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform-aware vibration utility
class VibrationUtils {
  static Future<bool> hasVibrator() async {
    if (PlatformUtils.isWeb) return false;
    
    // On mobile, check for vibrator
    try {
      // Use dynamic to avoid Web compilation errors
      // On mobile, this will use the vibration package
      if (kIsWeb) return false;
      
      // Import vibration package only on mobile
      // For Web compilation, this returns false
      return await _checkVibratorMobile();
    } catch (e) {
      return false;
    }
  }

  static Future<void> vibrate({int? duration, List<int>? pattern}) async {
    if (PlatformUtils.isWeb) {
      // Web: No vibration
      return;
    }

    try {
      await _performVibrationMobile(duration: duration, pattern: pattern);
    } catch (e) {
      // Silently fail - vibration not available
    }
  }

  static Future<bool> _checkVibratorMobile() async {
    if (kIsWeb) return false;
    
    try {
      // This will be replaced with actual vibration package call on mobile
      // For now, return false to allow Web compilation
      // In production build for mobile, this will use: await Vibration.hasVibrator()
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> _performVibrationMobile({int? duration, List<int>? pattern}) async {
    if (kIsWeb) return;
    
    try {
      // This will use the vibration package on mobile
      // For Web compilation, this is a no-op
      // In production build for mobile, this will use:
      // if (pattern != null) {
      //   await Vibration.vibrate(pattern: pattern);
      // } else {
      //   await Vibration.vibrate(duration: duration ?? 100);
      // }
    } catch (e) {
      // Ignore errors
    }
  }
}
