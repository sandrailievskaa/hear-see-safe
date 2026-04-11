import 'dart:convert';

import 'supported_voice_language.dart';

/// Normalized command from the LLM (multilingual → one schema).
class VoiceIntent {
  const VoiceIntent({
    required this.action,
    this.params = const {},
    this.detectedLanguage,
    this.confidence,
    this.requiresConfirmation = false,
    this.rawModelJson,
  });

  final String action;
  final Map<String, dynamic> params;
  final SupportedVoiceLanguage? detectedLanguage;
  final double? confidence;
  final bool requiresConfirmation;
  final String? rawModelJson;

  Map<String, dynamic> toJson() => {
        'action': action,
        'params': params,
        'detected_language': detectedLanguage?.bcp47,
        'confidence': confidence,
        'requires_confirmation': requiresConfirmation,
      };

  factory VoiceIntent.fromJson(Map<String, dynamic> json) {
    final lang = SupportedVoiceLanguage.tryParseBcp47(
      json['detected_language'] as String?,
    );
    final params = Map<String, dynamic>.from(json['params'] as Map? ?? {});
    const reserved = {
      'action',
      'params',
      'detected_language',
      'confidence',
      'requires_confirmation',
    };
    for (final e in json.entries) {
      if (reserved.contains(e.key)) continue;
      params.putIfAbsent(e.key, () => e.value);
    }
    return VoiceIntent(
      action: (json['action'] as String?)?.trim() ?? 'unknown',
      params: params,
      detectedLanguage: lang,
      confidence: (json['confidence'] as num?)?.toDouble(),
      requiresConfirmation: json['requires_confirmation'] == true,
    );
  }

  static VoiceIntent? tryParse(String content) {
    try {
      final map = jsonDecode(content) as Map<String, dynamic>;
      return VoiceIntent.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
