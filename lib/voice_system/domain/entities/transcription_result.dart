import 'supported_voice_language.dart';

/// Single utterance from STT (device or cloud).
class TranscriptionResult {
  const TranscriptionResult({
    required this.transcript,
    this.confidence,
    this.detectedLanguage,
    this.isFinal = true,
    this.source = TranscriptionSource.device,
  });

  final String transcript;
  final double? confidence;
  final SupportedVoiceLanguage? detectedLanguage;
  final bool isFinal;
  final TranscriptionSource source;

  bool get isEmpty => transcript.trim().isEmpty;
}

enum TranscriptionSource { device, googleCloud, hybrid }
