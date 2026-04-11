import '../entities/supported_voice_language.dart';

abstract class TextToSpeechRepository {
  Future<void> speak(
    String text, {
    SupportedVoiceLanguage? language,
    double? speakingRate,
  });

  Future<void> stop();
}
