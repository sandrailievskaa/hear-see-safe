import 'package:just_audio/just_audio.dart';

import '../../domain/entities/supported_voice_language.dart';
import '../../domain/repositories/text_to_speech_repository.dart';
import '../../voice_system_config.dart';
import '../google_cloud/google_tts_rest_client.dart';

/// Google Cloud Text-to-Speech (MP3 → playback). Works on **mobile and web** (data URI).
class GoogleCloudTtsRepositoryImpl implements TextToSpeechRepository {
  GoogleCloudTtsRepositoryImpl({
    required VoiceSystemConfig config,
    GoogleTtsRestClient? client,
    AudioPlayer? player,
  })  : _config = config,
        _client = client ?? GoogleTtsRestClient(apiKey: config.googleApiKey),
        _player = player ?? AudioPlayer();

  final VoiceSystemConfig _config;
  final GoogleTtsRestClient _client;
  final AudioPlayer _player;

  @override
  Future<void> speak(
    String text, {
    SupportedVoiceLanguage? language,
    double? speakingRate,
  }) async {
    if (!_config.hasGoogleKey || text.isEmpty) return;

    final lang = language ?? SupportedVoiceLanguage.macedonian;
    final bytes = await _client.synthesizeToMp3(
      text: text,
      language: lang,
      speakingRate: speakingRate ?? _config.ttsSpeakingRate,
      fallbackVoices: lang == SupportedVoiceLanguage.macedonian
          ? GoogleTtsRestClient.macedonianFallbackVoices()
          : const [],
    );
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Google TTS synthesis returned no audio');
    }

    await _player.stop();
    await _player.setAudioSource(
      AudioSource.uri(
        Uri.dataFromBytes(bytes, mimeType: 'audio/mpeg'),
      ),
    );
    await _player.play();
    await _player.processingStateStream.firstWhere(
      (s) => s == ProcessingState.completed,
    );
  }

  @override
  Future<void> stop() => _player.stop();

  Future<void> dispose() async {
    await _player.dispose();
    _client.close();
  }
}
