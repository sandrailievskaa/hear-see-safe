import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../domain/entities/supported_voice_language.dart';

/// REST client for Google Cloud Text-to-Speech `text:synthesize`.
class GoogleTtsRestClient {
  GoogleTtsRestClient({
    required this.apiKey,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String apiKey;
  final http.Client _http;

  static const _endpoint = 'https://texttospeech.googleapis.com/v1/text:synthesize';

  /// Returns MP3 bytes. Tries primary voice; on failure retries [fallbackVoices].
  Future<Uint8List?> synthesizeToMp3({
    required String text,
    required SupportedVoiceLanguage language,
    required double speakingRate,
    List<Map<String, String>> fallbackVoices = const [],
  }) async {
    final candidates = <Map<String, String>>[
      _voiceSpec(language),
      ...fallbackVoices,
    ];

    for (final voice in candidates) {
      final audio = await _trySynthesize(
        text: text,
        languageCode: voice['languageCode']!,
        voiceName: voice['name']!,
        speakingRate: speakingRate,
      );
      if (audio != null) return audio;
    }
    return null;
  }

  Map<String, String> _voiceSpec(SupportedVoiceLanguage language) {
    switch (language) {
      case SupportedVoiceLanguage.macedonian:
        return {'languageCode': 'mk-MK', 'name': 'mk-MK-Standard-A'};
      case SupportedVoiceLanguage.english:
        return {'languageCode': 'en-US', 'name': 'en-US-Neural2-F'};
      case SupportedVoiceLanguage.albanian:
        return {'languageCode': 'sq-AL', 'name': 'sq-AL-Standard-A'};
    }
  }

  /// Slavic fallback if Macedonian neural/standard voice is unavailable for the project.
  static List<Map<String, String>> macedonianFallbackVoices() => [
        {'languageCode': 'bg-BG', 'name': 'bg-BG-Standard-A'},
        {'languageCode': 'sr-RS', 'name': 'sr-RS-Standard-A'},
      ];

  Future<Uint8List?> _trySynthesize({
    required String text,
    required String languageCode,
    required String voiceName,
    required double speakingRate,
  }) async {
    final url = Uri.parse('$_endpoint?key=$apiKey');
    final body = {
      'input': {'text': text},
      'voice': {
        'languageCode': languageCode,
        'name': voiceName,
      },
      'audioConfig': {
        'audioEncoding': 'MP3',
        'speakingRate': speakingRate,
        'pitch': 0.0,
        'effectsProfileId': ['headphone-class-device'],
      },
    };

    final res = await _http.post(
      url,
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) return null;
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final b64 = map['audioContent'] as String?;
    if (b64 == null) return null;
    return base64Decode(b64);
  }

  void close() {
    _http.close();
  }
}
