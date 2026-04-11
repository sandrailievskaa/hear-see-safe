import '../../domain/entities/supported_voice_language.dart';
import '../../domain/repositories/text_to_speech_repository.dart';
import '../../voice_system_config.dart';

/// Tries Google Cloud TTS when a key is configured; otherwise [fallback].
class CompositeTextToSpeechRepository implements TextToSpeechRepository {
  CompositeTextToSpeechRepository({
    required VoiceSystemConfig config,
    required TextToSpeechRepository cloud,
    required TextToSpeechRepository fallback,
  })  : _config = config,
        _cloud = cloud,
        _fallback = fallback;

  final VoiceSystemConfig _config;
  final TextToSpeechRepository _cloud;
  final TextToSpeechRepository _fallback;

  @override
  Future<void> speak(
    String text, {
    SupportedVoiceLanguage? language,
    double? speakingRate,
  }) async {
    if (_config.hasGoogleKey) {
      try {
        await _cloud.speak(
          text,
          language: language,
          speakingRate: speakingRate,
        );
        return;
      } catch (_) {
        // fall through
      }
    }
    await _fallback.speak(
      text,
      language: language,
      speakingRate: speakingRate,
    );
  }

  @override
  Future<void> stop() async {
    await _cloud.stop();
    await _fallback.stop();
  }
}
