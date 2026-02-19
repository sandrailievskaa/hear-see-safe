import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class PlatformUtils {
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !kIsWeb;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  
  /// Check if a feature is supported on current platform
  static bool isFeatureSupported(PlatformFeature feature) {
    switch (feature) {
      case PlatformFeature.camera:
        return isMobile;
      case PlatformFeature.vibration:
        return isMobile;
      case PlatformFeature.speechToText:
        return isMobile;
      case PlatformFeature.textToSpeech:
        return true; // TTS works on Web via Web Speech API
      case PlatformFeature.fileSystem:
        return isMobile;
    }
  }
}

enum PlatformFeature {
  camera,
  vibration,
  speechToText,
  textToSpeech,
  fileSystem,
}

