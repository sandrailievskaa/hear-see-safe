/// Runtime configuration for cloud voice services.
///
/// **Production:** do not ship API keys in the client binary. Prefer a small
/// backend (Cloud Run / Functions) that holds Google + OpenAI keys and exposes
/// streaming STT over WebSocket. This config supports `--dart-define` for
/// development and internal builds only.
class VoiceSystemConfig {
  const VoiceSystemConfig({
    this.googleApiKey = '',
    this.openAiApiKey = '',
    this.openAiModel = 'gpt-4o-mini',
    this.sttMinConfidenceFallback = 0.62,
    this.ttsSpeakingRate = 0.82,
    this.intentCacheTtl = const Duration(minutes: 10),
    this.intentCacheMaxEntries = 64,
    this.commandListenTimeout = const Duration(seconds: 8),
    this.targetMaxResponseLatency = const Duration(milliseconds: 1500),
  });

  /// From `flutter run --dart-define=GOOGLE_API_KEY=... --dart-define=OPENAI_API_KEY=...`
  factory VoiceSystemConfig.fromEnvironment() {
    return const VoiceSystemConfig(
      googleApiKey: String.fromEnvironment('GOOGLE_API_KEY', defaultValue: ''),
      openAiApiKey: String.fromEnvironment('OPENAI_API_KEY', defaultValue: ''),
      openAiModel: String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4o-mini'),
    );
  }

  final String googleApiKey;
  final String openAiApiKey;
  final String openAiModel;

  /// If Google STT returns confidence below this (when present), retry with English.
  final double sttMinConfidenceFallback;

  /// Google TTS speaking rate (1.0 = normal; lower = slower, accessibility-friendly).
  final double ttsSpeakingRate;

  final Duration intentCacheTtl;
  final int intentCacheMaxEntries;
  final Duration commandListenTimeout;
  final Duration targetMaxResponseLatency;

  bool get hasGoogleKey => googleApiKey.isNotEmpty;
  bool get hasOpenAiKey => openAiApiKey.isNotEmpty;
}
