import 'dart:convert';

import 'package:http/http.dart' as http;

/// OpenAI Chat Completions → structured JSON [VoiceIntent].
class OpenAiIntentClient {
  OpenAiIntentClient({
    required this.apiKey,
    required this.model,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _http;

  static const _url = 'https://api.openai.com/v1/chat/completions';

  Future<String?> completeJson({
    required String systemPrompt,
    required String userContent,
  }) async {
    final res = await _http.post(
      Uri.parse(_url),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'temperature': 0.1,
        'response_format': {'type': 'json_object'},
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userContent},
        ],
      }),
    );

    if (res.statusCode != 200) return null;
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final choices = map['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) return null;
    final msg = (choices.first as Map<String, dynamic>)['message']
        as Map<String, dynamic>?;
    return msg?['content'] as String?;
  }

  void close() {
    _http.close();
  }
}
