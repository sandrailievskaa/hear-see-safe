import 'dart:convert';

import 'package:http/http.dart' as http;

/// REST client for Google Cloud Speech-to-Text `speech:recognize` (synchronous).
///
/// **Streaming:** `speech:longrunningrecognize` or gRPC `StreamingRecognize` is
/// recommended behind a backend proxy; this client is optimized for short
/// commands and low integration cost on mobile.
class GoogleSpeechRestClient {
  GoogleSpeechRestClient({
    required this.apiKey,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String apiKey;
  final http.Client _http;

  static const _endpoint = 'https://speech.googleapis.com/v1/speech:recognize';

  Future<GoogleRecognizeResult?> recognize({
    required List<int> audioBytes,
    required String encoding,
    required int sampleRateHertz,
    required String languageCode,
    List<String> alternativeLanguageCodes = const [],
  }) async {
    final url = Uri.parse('$_endpoint?key=$apiKey');
    final body = <String, dynamic>{
      'config': <String, dynamic>{
        'encoding': encoding,
        'sampleRateHertz': sampleRateHertz,
        'languageCode': languageCode,
        'enableAutomaticPunctuation': true,
        if (alternativeLanguageCodes.isNotEmpty)
          'alternativeLanguageCodes': alternativeLanguageCodes,
        'model': 'latest_short',
      },
      'audio': <String, dynamic>{
        'content': base64Encode(audioBytes),
      },
    };

    final res = await _http.post(
      url,
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      return null;
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final results = map['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return null;

    final top = results.first as Map<String, dynamic>;
    final alternatives = top['alternatives'] as List<dynamic>?;
    if (alternatives == null || alternatives.isEmpty) return null;

    final first = alternatives.first as Map<String, dynamic>;
    final transcript = (first['transcript'] as String?)?.trim() ?? '';
    if (transcript.isEmpty) return null;

    final confidence = (first['confidence'] as num?)?.toDouble();
    final detectedTag = top['languageCode'] as String?;

    return GoogleRecognizeResult(
      transcript: transcript,
      confidence: confidence,
      detectedBcp47: detectedTag,
    );
  }

  void close() {
    _http.close();
  }
}

class GoogleRecognizeResult {
  const GoogleRecognizeResult({
    required this.transcript,
    this.confidence,
    this.detectedBcp47,
  });

  final String transcript;
  final double? confidence;
  final String? detectedBcp47;
}
