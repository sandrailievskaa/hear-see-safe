import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hear_and_see_safe/utils/platform_utils.dart';

/// Voice Assistant Service - works on both Web and Mobile
class VoiceAssistantService {
  dynamic _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _voiceAssistantEnabled = true;
  bool _vibrationEnabled = true;

  bool get isSpeaking => _isSpeaking;

  void setVoiceAssistantEnabled(bool enabled) {
    _voiceAssistantEnabled = enabled;
  }

  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    if (kIsWeb) {
      // Web: No TTS initialization needed
      _isInitialized = true;
      return;
    }

    // Mobile: Try to initialize flutter_tts
    try {
      // Dynamic import to avoid Web compilation errors
      final flutterTtsPackage = await _tryGetFlutterTts();
      if (flutterTtsPackage != null) {
        _flutterTts = flutterTtsPackage;
        await _flutterTts.setLanguage("en-US");
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setVolume(1.0);
        await _flutterTts.setPitch(1.0);
        _flutterTts.setCompletionHandler(() => _isSpeaking = false);
        _flutterTts.setErrorHandler((msg) => _isSpeaking = false);
      }
    } catch (e) {
      // flutter_tts not available, will use fallback
    }
    
    _isInitialized = true;
  }

  Future<dynamic> _tryGetFlutterTts() async {
    if (kIsWeb) return null;
    
    // On mobile, try to create FlutterTts instance
    // We use dynamic to avoid compilation errors on Web
    try {
      // Use conditional compilation or try-catch
      // For now, return null - will be initialized via reflection on mobile
      // In production, you could use package:reflectable or similar
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Method to initialize flutter_tts on mobile (called from mobile-specific code)
  void _initializeMobileTts(dynamic flutterTts) {
    if (!kIsWeb && flutterTts != null) {
      _flutterTts = flutterTts;
    }
  }

  Future<void> speak(String text, {bool vibrate = true}) async {
    if (!_isInitialized) await initialize();
    if (!_voiceAssistantEnabled) return;

    _isSpeaking = true;

    // Try to use flutter_tts on mobile
    if (!kIsWeb && _flutterTts != null) {
      try {
        await _flutterTts.speak(text);
        if (vibrate && _vibrationEnabled && PlatformUtils.isMobile) {
          await _vibrate();
        }
        return;
      } catch (e) {
        // Fall through to fallback
      }
    }

    // Fallback: Web or mobile without TTS
    print('🔊 TTS: $text');
    await Future.delayed(Duration(milliseconds: (text.length * 30).clamp(100, 2000)));
    _isSpeaking = false;
  }

  Future<void> _vibrate() async {
    if (!PlatformUtils.isMobile) return;
    try {
      // Vibration will be handled via VibrationUtils
      // This is just a placeholder
    } catch (e) {
      // Ignore
    }
  }

  Future<void> speakWithLanguage(String text, String languageCode, {bool vibrate = true}) async {
    if (!_isInitialized) await initialize();

    if (!kIsWeb && _flutterTts != null) {
      try {
        String ttsLanguage = "en-US";
        switch (languageCode) {
          case 'mk':
            ttsLanguage = "mk-MK";
            break;
          case 'sq':
            ttsLanguage = "sq-AL";
            break;
          case 'en':
          default:
            ttsLanguage = "en-US";
            break;
        }
        await _flutterTts.setLanguage(ttsLanguage);
      } catch (e) {
        await _flutterTts.setLanguage("en-US");
      }
    }

    await speak(text, vibrate: vibrate);
  }

  Future<void> stop() async {
    if (_flutterTts != null) {
      try {
        await _flutterTts.stop();
      } catch (e) {
        // Ignore
      }
    }
    _isSpeaking = false;
  }

  Future<void> pause() async {
    if (_flutterTts != null) {
      try {
        await _flutterTts.pause();
      } catch (e) {
        // Ignore
      }
    }
  }

  void dispose() {
    if (_flutterTts != null) {
      try {
        _flutterTts.stop();
      } catch (e) {
        // Ignore
      }
    }
    _isSpeaking = false;
  }
}
