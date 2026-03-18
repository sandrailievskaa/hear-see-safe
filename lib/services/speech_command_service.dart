import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// Распознавање на говор за гласовни команди (како Siri).
/// Работи на Chrome (Web Speech API) и на мобилен.
class SpeechCommandService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    return _initialized;
  }

  bool get isListening => _speech.isListening;

  /// Слуша до [timeout] и враћа препознат текст или null.
  Future<String?> listen({String? locale, Duration timeout = const Duration(seconds: 6)}) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return null;
    }
    final completer = Completer<String?>();
    String? lastFinal;

    await _speech.listen(
      onResult: (SpeechRecognitionResult r) {
        if (r.finalResult && r.recognizedWords.trim().isNotEmpty) {
          lastFinal = r.recognizedWords.trim();
          if (!completer.isCompleted) completer.complete(lastFinal);
        }
      },
      listenFor: timeout,
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: _localeToId(locale),
      listenMode: ListenMode.confirmation,
    );

    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        if (_speech.isListening) _speech.stop();
        completer.complete(lastFinal);
      }
    });

    return completer.future;
  }

  String _localeToId(String? langCode) {
    switch (langCode ?? 'en') {
      case 'mk':
        return 'mk_MK';
      case 'sq':
        return 'sq_AL';
      case 'en':
      default:
        return 'en_US';
    }
  }

  Future<void> stop() async {
    if (_speech.isListening) await _speech.stop();
  }
}
