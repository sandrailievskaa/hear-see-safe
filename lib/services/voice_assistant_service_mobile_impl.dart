// This file provides the actual mobile implementation
// It uses conditional imports to avoid Web compilation errors
// On mobile, this will be used via reflection or direct instantiation

import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import - only works on mobile
import 'package:flutter_tts/flutter_tts.dart' if (dart.library.html) 'package:hear_and_see_safe/services/voice_assistant_service_stub.dart';
import 'package:vibration/vibration.dart' if (dart.library.html) 'package:hear_and_see_safe/utils/vibration_utils_stub.dart';
import 'package:hear_and_see_safe/utils/platform_utils.dart';

/// Mobile implementation that actually uses flutter_tts
class VoiceAssistantServiceMobileImpl {
  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _voiceAssistantEnabled = true;
  bool _vibrationEnabled = true;

  bool get isSpeaking => _isSpeaking;

  void setVoiceAssistantEnabled(bool enabled) => _voiceAssistantEnabled = enabled;
  void setVibrationEnabled(bool enabled) => _vibrationEnabled = enabled;

  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) return;

    try {
      _flutterTts = FlutterTts();
      await _flutterTts!.setLanguage("en-US");
      await _flutterTts!.setSpeechRate(0.5);
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);

      _flutterTts!.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts!.setErrorHandler((msg) {
        _isSpeaking = false;
      });

      _isInitialized = true;
    } catch (e) {
      // Handle error gracefully
      _isInitialized = true; // Mark as initialized even if TTS fails
    }
  }

  Future<void> speak(String text, {bool vibrate = true}) async {
    if (!_isInitialized) await initialize();
    if (!_voiceAssistantEnabled) return;

    _isSpeaking = true;

    if (_flutterTts != null && !kIsWeb) {
      try {
        await _flutterTts!.speak(text);
        if (vibrate && _vibrationEnabled && PlatformUtils.isMobile) {
          final hasVibrator = await Vibration.hasVibrator();
          if (hasVibrator ?? false) {
            await Vibration.vibrate(duration: 100);
          }
        }
        return;
      } catch (e) {
        // Fall through to fallback
      }
    }

    // Fallback
    print('🔊 TTS: $text');
    await Future.delayed(Duration(milliseconds: (text.length * 30).clamp(100, 2000)));
    _isSpeaking = false;
  }

  Future<void> speakWithLanguage(String text, String languageCode, {bool vibrate = true}) async {
    if (!_isInitialized) await initialize();

    if (_flutterTts != null && !kIsWeb) {
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
        await _flutterTts!.setLanguage(ttsLanguage);
      } catch (e) {
        await _flutterTts!.setLanguage("en-US");
      }
    }

    await speak(text, vibrate: vibrate);
  }

  Future<void> stop() async {
    if (_flutterTts != null) {
      try {
        await _flutterTts!.stop();
      } catch (e) {}
    }
    _isSpeaking = false;
  }

  Future<void> pause() async {
    if (_flutterTts != null) {
      try {
        await _flutterTts!.pause();
      } catch (e) {}
    }
  }

  void dispose() {
    if (_flutterTts != null) {
      try {
        _flutterTts!.stop();
      } catch (e) {}
    }
    _isSpeaking = false;
  }
}
