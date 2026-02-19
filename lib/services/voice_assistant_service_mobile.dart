import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:hear_and_see_safe/utils/platform_utils.dart';

/// Mobile implementation using flutter_tts
class VoiceAssistantService {
  final FlutterTts _flutterTts = FlutterTts();
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

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
    });

    _isInitialized = true;
  }

  Future<void> speak(String text, {bool vibrate = true}) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_voiceAssistantEnabled) return;

    _isSpeaking = true;
    await _flutterTts.speak(text);

    if (vibrate && _vibrationEnabled && PlatformUtils.isMobile) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator ?? false) {
        await Vibration.vibrate(duration: 100);
      }
    }
  }

  Future<void> speakWithLanguage(String text, String languageCode, {bool vibrate = true}) async {
    if (!_isInitialized) {
      await initialize();
    }

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

    try {
      await _flutterTts.setLanguage(ttsLanguage);
    } catch (e) {
      await _flutterTts.setLanguage("en-US");
    }

    await speak(text, vibrate: vibrate);
  }

  Future<void> stop() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
    }
  }

  Future<void> pause() async {
    if (_isSpeaking) {
      await _flutterTts.pause();
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}

