import '../../domain/entities/supported_voice_language.dart';
import '../../domain/repositories/text_to_speech_repository.dart';
import '../../../services/voice_assistant_service.dart';

/// Bridges [VoiceAssistantService] (flutter_tts) into [TextToSpeechRepository].
class FlutterTtsVoiceRepository implements TextToSpeechRepository {
  FlutterTtsVoiceRepository(this._voiceAssistant);

  final VoiceAssistantService _voiceAssistant;

  @override
  Future<void> speak(
    String text, {
    SupportedVoiceLanguage? language,
    double? speakingRate,
  }) async {
    if (text.isEmpty) return;
    final code = language?.languageCode ?? 'mk';
    await _voiceAssistant.speakWithLanguage(text, code, vibrate: false);
  }

  @override
  Future<void> stop() => _voiceAssistant.stop();
}
