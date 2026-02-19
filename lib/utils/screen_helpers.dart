import 'package:hear_and_see_safe/utils/platform_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';

/// Helper functions for screens to handle platform differences
class ScreenHelpers {
  /// Provide haptic/vibration feedback - works on both platforms
  static Future<void> provideHapticFeedback() async {
    if (PlatformUtils.isMobile) {
      await VibrationUtils.vibrate(duration: 100);
    } else {
      // Web: Visual feedback only (could add CSS animations)
    }
  }

  /// Check if camera is available
  static bool isCameraAvailable() {
    return PlatformUtils.isMobile;
  }

  /// Check if speech recognition is available
  static bool isSpeechRecognitionAvailable() {
    return PlatformUtils.isMobile;
  }
}

