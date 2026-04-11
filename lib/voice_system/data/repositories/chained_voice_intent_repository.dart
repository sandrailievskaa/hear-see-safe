import '../../domain/entities/supported_voice_language.dart';
import '../../domain/entities/voice_intent.dart';
import '../../domain/repositories/voice_intent_repository.dart';
import '../../voice_system_config.dart';
import 'heuristic_voice_intent_repository.dart';
import 'openai_voice_intent_repository.dart';

/// OpenAI first when configured; otherwise (or on `unknown`) heuristic keywords.
class ChainedVoiceIntentRepository implements VoiceIntentRepository {
  ChainedVoiceIntentRepository({
    required VoiceSystemConfig config,
    required OpenAiVoiceIntentRepository openAi,
    required HeuristicVoiceIntentRepository heuristic,
  })  : _config = config,
        _openAi = openAi,
        _heuristic = heuristic;

  final VoiceSystemConfig _config;
  final OpenAiVoiceIntentRepository _openAi;
  final HeuristicVoiceIntentRepository _heuristic;

  @override
  Future<VoiceIntent> resolveIntent({
    required String transcript,
    SupportedVoiceLanguage? uiLanguageHint,
  }) async {
    if (_config.hasOpenAiKey) {
      final ai = await _openAi.resolveIntent(
        transcript: transcript,
        uiLanguageHint: uiLanguageHint,
      );
      if (ai.action != 'unknown') return ai;
    }
    return _heuristic.resolve(transcript);
  }
}
