import 'package:flutter_tts/flutter_tts.dart';

/// Гласовен асистент – TTS низ целата апликација (Chrome, Android, iOS).
/// Користи flutter_tts (на веб = SpeechSynthesis, на мобилен = системски TTS).
class VoiceAssistantService {
  FlutterTts? _flutterTts;
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

    try {
      _flutterTts = FlutterTts();

      await _flutterTts!.setLanguage("en-US");
      await _flutterTts!.setSpeechRate(0.45);
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
      _isInitialized = true;
    }
  }

  Future<void> speak(String text, {bool vibrate = true}) async {
    if (!_isInitialized) await initialize();
    if (!_voiceAssistantEnabled || text.isEmpty) return;

    _isSpeaking = true;

    if (_flutterTts != null) {
      try {
        await _flutterTts!.speak(text);
        return;
      } catch (e) {
        _isSpeaking = false;
      }
    }

    _isSpeaking = false;
  }

  /// Македонски и албански: пробува повеќе формати бидејќи уреди/прелистувачи користат различни.
  static const List<String> _mkLocales = ['mk-MK', 'mk_MK', 'mk'];
  static const List<String> _sqLocales = ['sq-AL', 'sq_AL', 'sq'];

  Future<bool> _trySetLanguage(String languageCode) async {
    if (_flutterTts == null) return false;

    List<String> localesToTry;
    switch (languageCode) {
      case 'mk':
        localesToTry = _mkLocales;
        break;
      case 'sq':
        localesToTry = _sqLocales;
        break;
      case 'en':
      default:
        localesToTry = ['en-US', 'en_US', 'en'];
        break;
    }

    // На Android: ако getLanguages работи, најди match за mk/sq
    try {
      final available = await _flutterTts!.getLanguages;
      if (available != null && available.isNotEmpty) {
        final langPrefix = languageCode == 'mk' ? 'mk' : (languageCode == 'sq' ? 'sq' : 'en');
        for (final a in available) {
          final s = a.toString().toLowerCase();
          if (s.startsWith(langPrefix)) {
            try {
              await _flutterTts!.setLanguage(a.toString());
              return true;
            } catch (_) {}
          }
        }
      }
    } catch (_) {}

    // Fallback: пробувај по ред
    for (final loc in localesToTry) {
      try {
        await _flutterTts!.setLanguage(loc);
        return true;
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  Future<void> speakWithLanguage(String text, String languageCode, {bool vibrate = true}) async {
    if (!_isInitialized) await initialize();
    if (!_voiceAssistantEnabled || text.isEmpty) return;

    if (_flutterTts != null) {
      final ok = await _trySetLanguage(languageCode);
      if (!ok) {
        try {
          await _flutterTts!.setLanguage("en-US");
        } catch (_) {}
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
