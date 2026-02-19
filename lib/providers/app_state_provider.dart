import 'package:flutter/material.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';

class AppStateProvider extends ChangeNotifier {
  String _currentLanguage = 'en';
  bool _isVoiceAssistantEnabled = true;
  double _volume = 1.0;
  bool _vibrationEnabled = true;
  VoiceAssistantService? _voiceAssistant;

  String get currentLanguage => _currentLanguage;
  bool get isVoiceAssistantEnabled => _isVoiceAssistantEnabled;
  double get volume => _volume;
  bool get vibrationEnabled => _vibrationEnabled;

  void setVoiceAssistant(VoiceAssistantService? voiceAssistant) {
    _voiceAssistant = voiceAssistant;
    _updateVoiceAssistantSettings();
  }

  void _updateVoiceAssistantSettings() {
    if (_voiceAssistant != null) {
      _voiceAssistant!.setVoiceAssistantEnabled(_isVoiceAssistantEnabled);
      _voiceAssistant!.setVibrationEnabled(_vibrationEnabled);
    }
  }

  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    notifyListeners();
  }

  void toggleVoiceAssistant() {
    _isVoiceAssistantEnabled = !_isVoiceAssistantEnabled;
    _updateVoiceAssistantSettings();
    notifyListeners();
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  void toggleVibration() {
    _vibrationEnabled = !_vibrationEnabled;
    _updateVoiceAssistantSettings();
    notifyListeners();
  }
}
