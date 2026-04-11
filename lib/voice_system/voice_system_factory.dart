import 'dart:async';

import '../services/voice_assistant_service.dart';
import 'application/language_manager.dart';
import 'application/voice_command_orchestrator.dart';
import 'data/repositories/caching_voice_intent_repository.dart';
import 'data/repositories/chained_voice_intent_repository.dart';
import 'data/repositories/composite_text_to_speech_repository.dart';
import 'data/repositories/device_speech_repository_impl.dart';
import 'data/repositories/flutter_tts_repository_adapter.dart';
import 'data/repositories/google_cloud_speech_repository_impl.dart';
import 'data/repositories/google_cloud_tts_repository_impl.dart';
import 'data/repositories/heuristic_voice_intent_repository.dart';
import 'data/repositories/hybrid_speech_repository_impl.dart';
import 'data/repositories/openai_voice_intent_repository.dart';
import 'voice_system_config.dart';

/// Wires repositories for production-style injection (Provider, tests, flavors).
class VoiceSystemFactory {
  VoiceSystemFactory._();

  static VoiceCommandOrchestrator createOrchestrator({
    required VoiceSystemConfig config,
    required LanguageManager languageManager,
    required VoiceAssistantService voiceAssistant,
  }) {
    final googleStt = GoogleCloudSpeechRepositoryImpl(config: config);
    final deviceStt = DeviceSpeechRepositoryImpl(languageManager: languageManager);
    final hybrid = HybridSpeechRepositoryImpl(cloud: googleStt, device: deviceStt);

    final openAiRepo = OpenAiVoiceIntentRepository(config: config);
    final heuristic = HeuristicVoiceIntentRepository();
    final chained = ChainedVoiceIntentRepository(
      config: config,
      openAi: openAiRepo,
      heuristic: heuristic,
    );
    final intentRepo = CachingVoiceIntentRepository(
      delegate: chained,
      config: config,
    );

    final googleTts = GoogleCloudTtsRepositoryImpl(config: config);
    final flutterTts = FlutterTtsVoiceRepository(voiceAssistant);
    final compositeTts = CompositeTextToSpeechRepository(
      config: config,
      cloud: googleTts,
      fallback: flutterTts,
    );

    return VoiceCommandOrchestrator(
      config: config,
      languageManager: languageManager,
      speechToText: hybrid,
      intentRepository: intentRepo,
      textToSpeech: compositeTts,
      disposeResources: () {
        googleStt.dispose();
        openAiRepo.dispose();
        unawaited(googleTts.dispose());
      },
    );
  }
}
