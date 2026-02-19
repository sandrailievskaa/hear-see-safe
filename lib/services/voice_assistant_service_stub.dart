/// Stub implementation for Web
class VoiceAssistantService {
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
    _isInitialized = true;
  }

  Future<void> speak(String text, {bool vibrate = true}) async {
    if (!_isInitialized) {
      await initialize();
    }
    if (!_voiceAssistantEnabled) return;
    _isSpeaking = true;
    // Web: Use browser console or visual feedback
    print('TTS (Web): $text');
    await Future.delayed(Duration(milliseconds: text.length * 50));
    _isSpeaking = false;
  }

  Future<void> speakWithLanguage(String text, String languageCode, {bool vibrate = true}) async {
    await speak(text, vibrate: vibrate);
  }

  Future<void> stop() async {
    _isSpeaking = false;
  }

  Future<void> pause() async {
    _isSpeaking = false;
  }

  void dispose() {
    _isSpeaking = false;
  }
}

