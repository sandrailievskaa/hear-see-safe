import '../entities/supported_voice_language.dart';
import '../entities/voice_intent.dart';

abstract class VoiceIntentRepository {
  /// Map free text in any supported language to [VoiceIntent].
  Future<VoiceIntent> resolveIntent({
    required String transcript,
    SupportedVoiceLanguage? uiLanguageHint,
  });
}
