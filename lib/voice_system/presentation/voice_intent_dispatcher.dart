import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../screens/braille_learning_screen.dart';
import '../../screens/camera_recognition_screen.dart';
import '../../screens/cyber_safety_screen.dart';
import '../../screens/melody_memory_screen.dart';
import '../../screens/number_games_screen.dart';
import '../../screens/picture_book_screen.dart';
import '../../screens/rhythm_tap_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/sound_identification_screen.dart';
import '../../screens/sound_memory_screen.dart';
import '../../screens/spatial_orientation_screen.dart';
import '../../screens/story_choices_screen.dart';
import '../../screens/voice_pong_screen.dart';
import '../../services/voice_assistant_service.dart';
import '../../utils/accessibility_utils.dart';
import '../domain/entities/voice_intent.dart';

/// Maps normalized intents to navigation + spoken feedback (screen-reader friendly).
Future<void> dispatchVoiceIntent({
  required BuildContext context,
  required VoiceIntent intent,
  required VoiceAssistantService voiceAssistant,
  required String systemWifiUnavailableMessage,
}) async {
  void go(Widget screen, String announcement) {
    AccessibilityUtils.provideFeedback(
      context: context,
      audioFeedback: announcement,
      voiceAssistant: voiceAssistant,
    );
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  switch (intent.action) {
    case 'system_wifi':
      await AccessibilityUtils.provideFeedback(
        context: context,
        audioFeedback: systemWifiUnavailableMessage,
        voiceAssistant: voiceAssistant,
      );
      return;

    case 'open_settings':
      go(const SettingsScreen(), 'settings.opening'.tr());
      return;

    case 'navigate_braille':
      go(const BrailleLearningScreen(), 'features.braille'.tr());
      return;
    case 'navigate_picture_book':
      go(const PictureBookScreen(), 'features.picture_book'.tr());
      return;
    case 'navigate_number_games':
      go(const NumberGamesScreen(), 'features.number_games'.tr());
      return;
    case 'navigate_camera_recognition':
      go(const CameraRecognitionScreen(), 'features.camera_recognition'.tr());
      return;
    case 'navigate_spatial_orientation':
      go(const SpatialOrientationScreen(), 'features.spatial_orientation'.tr());
      return;
    case 'navigate_sound_identification':
      go(const SoundIdentificationScreen(), 'features.sound_identification'.tr());
      return;
    case 'navigate_cyber_safety':
      go(const CyberSafetyScreen(), 'features.cyber_safety'.tr());
      return;
    case 'navigate_sound_memory':
      go(const SoundMemoryScreen(), 'features.sound_memory'.tr());
      return;
    case 'navigate_voice_pong':
      go(const VoicePongScreen(), 'features.voice_pong'.tr());
      return;
    case 'navigate_melody_memory':
      go(const MelodyMemoryScreen(), 'features.melody_memory'.tr());
      return;
    case 'navigate_rhythm_tap':
      go(const RhythmTapScreen(), 'features.rhythm_tap'.tr());
      return;
    case 'navigate_story_choices':
      go(const StoryChoicesScreen(), 'features.story_choices'.tr());
      return;

    case 'unknown':
    default:
      await AccessibilityUtils.provideFeedback(
        context: context,
        audioFeedback: 'voice.not_recognized'.tr(),
        voiceAssistant: voiceAssistant,
      );
      return;
  }
}
