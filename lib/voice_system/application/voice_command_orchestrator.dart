import '../domain/entities/supported_voice_language.dart';
import '../domain/entities/voice_intent.dart';
import '../domain/repositories/speech_to_text_repository.dart';
import '../domain/repositories/text_to_speech_repository.dart';
import '../domain/repositories/voice_intent_repository.dart';
import '../voice_system_config.dart';
import 'language_manager.dart';
import 'voice_ui_strings.dart';

/// Coordinates STT → intent (cache + LLM) → optional confirmation → TTS feedback.
class VoiceCommandOrchestrator {
  VoiceCommandOrchestrator({
    required VoiceSystemConfig config,
    required LanguageManager languageManager,
    required SpeechToTextRepository speechToText,
    required VoiceIntentRepository intentRepository,
    required TextToSpeechRepository textToSpeech,
    required void Function() disposeResources,
  })  : _config = config,
        _languageManager = languageManager,
        _speechToText = speechToText,
        _intentRepository = intentRepository,
        _textToSpeech = textToSpeech,
        _disposeResources = disposeResources;

  final VoiceSystemConfig _config;
  final LanguageManager _languageManager;
  final SpeechToTextRepository _speechToText;
  final VoiceIntentRepository _intentRepository;
  final TextToSpeechRepository _textToSpeech;
  final void Function() _disposeResources;

  SupportedVoiceLanguage _feedbackLang(String uiLanguageCode) {
    return _languageManager.lastDetectedLanguage ??
        SupportedVoiceLanguage.fromUiLanguageCode(uiLanguageCode);
  }

  /// Full microphone session: prompt → listen → parse → optional confirm.
  Future<VoiceIntent?> runCommand(VoiceUiStrings strings, String uiLanguageCode) async {
    final lang = _feedbackLang(uiLanguageCode);
    await _speakOut(strings.commandHint, lang);

    await Future<void>.delayed(const Duration(milliseconds: 400));

    final heard = await _speechToText.listenOnce(
      timeout: _config.commandListenTimeout,
    );

    if (heard == null || heard.isEmpty) {
      await _speakOut(strings.notRecognized, lang);
      return null;
    }

    _languageManager.applyDetectionHint(heard);

    final intent = await _intentRepository.resolveIntent(
      transcript: heard.transcript,
      uiLanguageHint: SupportedVoiceLanguage.fromUiLanguageCode(uiLanguageCode),
    );

    _languageManager.applyIntentLanguage(intent.detectedLanguage);

    if (intent.requiresConfirmation) {
      final confirmLang = intent.detectedLanguage ?? lang;
      await _speakOut(strings.confirmWifiDisable, confirmLang);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final answer = await _speechToText.listenOnce(
        timeout: const Duration(seconds: 5),
      );
      if (!_isAffirmative(answer?.transcript)) {
        await _speakOut(strings.sessionCancelled, confirmLang);
        return null;
      }
    }

    return intent;
  }

  Future<void> _speakOut(String text, SupportedVoiceLanguage lang) async {
    await _textToSpeech.speak(
      text,
      language: lang,
      speakingRate: _config.ttsSpeakingRate,
    );
  }

  bool _isAffirmative(String? transcript) {
    if (transcript == null || transcript.trim().isEmpty) return false;
    final s = transcript.toLowerCase().trim();
    const affirm = [
      'yes',
      'yeah',
      'yep',
      'ok',
      'okay',
      'sure',
      'да',
      'дa',
      'потврдувам',
      'потврди',
      'се разбира',
      'po',
      'po,',
      'sigurisht',
      'mirë',
      'e po',
      'confirm',
    ];
    for (final a in affirm) {
      if (s.contains(a)) return true;
    }
    return false;
  }

  void dispose() => _disposeResources();
}
