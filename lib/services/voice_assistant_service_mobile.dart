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

  static const List<String> _mkLocales = ['mk-MK', 'mk_MK', 'mk'];
  static const List<String> _sqLocales = ['sq-AL', 'sq_AL', 'sq'];

  Future<bool> _trySetLanguage(String languageCode) async {
    List<String> localesToTry;
    switch (languageCode) {
      case 'mk':
        localesToTry = _mkLocales;
        break;
      case 'sq':
        localesToTry = _sqLocales;
        break;
      default:
        localesToTry = ['en-US', 'en_US', 'en'];
        break;
    }
    try {
      final available = await _flutterTts.getLanguages;
      if (available != null && available.isNotEmpty) {
        final langPrefix = languageCode == 'mk' ? 'mk' : (languageCode == 'sq' ? 'sq' : 'en');
        for (final a in available) {
          if (a.toString().toLowerCase().startsWith(langPrefix)) {
            try {
              await _flutterTts.setLanguage(a.toString());
              return true;
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
    for (final loc in localesToTry) {
      try {
        await _flutterTts.setLanguage(loc);
        return true;
      } catch (_) {}
    }
    return false;
  }

  Future<void> speakWithLanguage(String text, String languageCode, {bool vibrate = true}) async {
    if (!_isInitialized) await initialize();

    final ok = await _trySetLanguage(languageCode);
    if (!ok) {
      try {
        await _flutterTts.setLanguage("en-US");
      } catch (_) {}
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

