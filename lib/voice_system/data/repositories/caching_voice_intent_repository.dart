import '../cache/intent_cache.dart';
import '../../domain/entities/supported_voice_language.dart';
import '../../domain/entities/voice_intent.dart';
import '../../domain/repositories/voice_intent_repository.dart';
import '../../voice_system_config.dart';

/// LRU cache in front of a delegate [VoiceIntentRepository].
class CachingVoiceIntentRepository implements VoiceIntentRepository {
  CachingVoiceIntentRepository({
    required VoiceIntentRepository delegate,
    required VoiceSystemConfig config,
    IntentCache? cache,
  })  : _delegate = delegate,
        _cache = cache ?? IntentCache(config);

  final VoiceIntentRepository _delegate;
  final IntentCache _cache;

  @override
  Future<VoiceIntent> resolveIntent({
    required String transcript,
    SupportedVoiceLanguage? uiLanguageHint,
  }) async {
    final hit = _cache.get(transcript);
    if (hit != null) return hit;

    final intent = await _delegate.resolveIntent(
      transcript: transcript,
      uiLanguageHint: uiLanguageHint,
    );
    if (intent.action != 'unknown') {
      _cache.put(transcript, intent);
    }
    return intent;
  }

  void clearCache() => _cache.clear();
}
