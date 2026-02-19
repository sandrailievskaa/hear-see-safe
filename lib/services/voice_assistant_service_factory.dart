import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';

/// Factory to create the appropriate VoiceAssistantService implementation
VoiceAssistantService createVoiceAssistantService() {
  if (kIsWeb) {
    return VoiceAssistantService();
  } else {
    // On mobile, return service that will try to use flutter_tts
    return VoiceAssistantService();
  }
}

