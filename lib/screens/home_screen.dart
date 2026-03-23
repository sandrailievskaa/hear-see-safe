import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/services/speech_command_service.dart';
import 'package:hear_and_see_safe/providers/app_state_provider.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/screens/braille_learning_screen.dart';
import 'package:hear_and_see_safe/screens/picture_book_screen.dart';
import 'package:hear_and_see_safe/screens/number_games_screen.dart';
import 'package:hear_and_see_safe/screens/camera_recognition_screen.dart';
import 'package:hear_and_see_safe/screens/spatial_orientation_screen.dart';
import 'package:hear_and_see_safe/screens/sound_identification_screen.dart';
import 'package:hear_and_see_safe/screens/cyber_safety_screen.dart';
import 'package:hear_and_see_safe/screens/sound_memory_screen.dart';
import 'package:hear_and_see_safe/screens/voice_pong_screen.dart';
import 'package:hear_and_see_safe/screens/melody_memory_screen.dart';
import 'package:hear_and_see_safe/screens/rhythm_tap_screen.dart';
import 'package:hear_and_see_safe/screens/story_choices_screen.dart';
import 'package:hear_and_see_safe/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VoiceAssistantService _voiceAssistant;
  late SpeechCommandService _speechCommand;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _voiceAssistant = Provider.of<VoiceAssistantService>(context, listen: false);
    _speechCommand = Provider.of<SpeechCommandService>(context, listen: false);
    _voiceAssistant.initialize();
    _updateVoiceAssistantSettings();
    _announceHomeScreen();
  }

  /// Мапира препознат говор на екран (многујазично).
  void _handleVoiceCommand(String? text) {
    if (text == null || text.isEmpty) return;
    final t = text.toLowerCase().trim();

    // Клучни зборови по модул (en, mk, sq)
    if (_match(t, ['braille', 'брај', 'braj', 'brajova', 'azbuka', 'родители', 'prindër'])) {
      _navigateToScreen(const BrailleLearningScreen(), 'features.braille'.tr());
      return;
    }
    if (_match(t, ['picture', 'book', 'learn', 'listen', 'учи', 'слушај', 'сликовница', 'mëso', 'dëgjo'])) {
      _navigateToScreen(const PictureBookScreen(), 'features.picture_book'.tr());
      return;
    }
    if (_match(t, ['number', 'broevi', 'броеви', 'numra', 'calculate'])) {
      _navigateToScreen(const NumberGamesScreen(), 'features.number_games'.tr());
      return;
    }
    if (_match(t, ['camera', 'камера', 'recognize', 'распознавање', 'kamerë'])) {
      _navigateToScreen(const CameraRecognitionScreen(), 'features.camera_recognition'.tr());
      return;
    }
    if (_match(t, ['spatial', 'orientation', 'просторна', 'ориентација', 'hapësirë'])) {
      _navigateToScreen(const SpatialOrientationScreen(), 'features.spatial_orientation'.tr());
      return;
    }
    if (_match(t, ['sound', 'identification', 'звук', 'идентификација', 'tingull'])) {
      _navigateToScreen(const SoundIdentificationScreen(), 'features.sound_identification'.tr());
      return;
    }
    if (_match(t, ['cyber', 'safety', 'кибер', 'безбедност', 'siguria'])) {
      _navigateToScreen(const CyberSafetyScreen(), 'features.cyber_safety'.tr());
      return;
    }
    if (_match(t, ['sound memory', 'меморија звуци', 'memory', 'kujtesë'])) {
      _navigateToScreen(const SoundMemoryScreen(), 'features.sound_memory'.tr());
      return;
    }
    if (_match(t, ['pong', 'понг', 'voice pong'])) {
      _navigateToScreen(const VoicePongScreen(), 'features.voice_pong'.tr());
      return;
    }
    if (_match(t, ['melody', 'мелодија', 'simon'])) {
      _navigateToScreen(const MelodyMemoryScreen(), 'features.melody_memory'.tr());
      return;
    }
    if (_match(t, ['rhythm', 'ритми', 'tap', 'ритам'])) {
      _navigateToScreen(const RhythmTapScreen(), 'features.rhythm_tap'.tr());
      return;
    }
    if (_match(t, ['story', 'приказна', 'choice', 'histori'])) {
      _navigateToScreen(const StoryChoicesScreen(), 'features.story_choices'.tr());
      return;
    }
    if (_match(t, ['settings', 'поставки', 'postavki', 'cilësimet'])) {
      _navigateToScreen(const SettingsScreen(), 'settings.opening'.tr());
      return;
    }

    _voiceAssistant.speakWithLanguage('voice.not_recognized'.tr(), context.locale.languageCode, vibrate: false);
  }

  bool _match(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k.toLowerCase()));
  }

  Future<void> _startVoiceCommand() async {
    if (_isListening) return;
    setState(() => _isListening = true);
    final langCode = context.locale.languageCode;
    await _voiceAssistant.speakWithLanguage('voice.speak_command'.tr(), langCode, vibrate: false);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final result = await _speechCommand.listen(locale: langCode);
    if (!mounted) return;
    setState(() => _isListening = false);
    _handleVoiceCommand(result);
  }

  void _updateVoiceAssistantSettings() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    _voiceAssistant.setVoiceAssistantEnabled(appState.isVoiceAssistantEnabled);
    _voiceAssistant.setVibrationEnabled(appState.vibrationEnabled);
  }

  Future<void> _announceHomeScreen() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final langCode = context.locale.languageCode;
    await _voiceAssistant.speakWithLanguage('home.welcome'.tr(), langCode, vibrate: false);
  }

  void _navigateToScreen(Widget screen, String announcement) {
    AccessibilityUtils.provideFeedback(
      context: context,
      audioFeedback: announcement,
      voiceAssistant: _voiceAssistant,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AccessibilityUtils.getBackgroundColor(context);
    final contrastColor = AccessibilityUtils.getContrastColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'app.title'.tr(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        backgroundColor: AccessibilityUtils.getAppBarBackgroundColor(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 32),
            onPressed: () {
              _navigateToScreen(
                const SettingsScreen(),
                'settings.opening'.tr(),
              );
            },
            tooltip: 'settings.title'.tr(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isListening ? null : _startVoiceCommand,
        icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
        label: Text(_isListening ? 'voice.listening'.tr() : 'voice.tap_to_speak'.tr()),
        backgroundColor: _isListening ? AccessibilityUtils.getDisabledColor(context) : AccessibilityUtils.getAppBarBackgroundColor(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFeatureCard(
                context,
                icon: Icons.grid_view,
                title: 'features.braille'.tr(),
                description: 'features.braille_desc'.tr(),
                color: const Color(0xFF1565C0),
                onTap: () => _navigateToScreen(
                  const BrailleLearningScreen(),
                  'features.braille'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.book,
                title: 'features.picture_book'.tr(),
                description: 'features.picture_book_desc'.tr(),
                color: Colors.blue,
                onTap: () => _navigateToScreen(
                  const PictureBookScreen(),
                  'features.picture_book'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.calculate,
                title: 'features.number_games'.tr(),
                description: 'features.number_games_desc'.tr(),
                color: Colors.green,
                onTap: () => _navigateToScreen(
                  const NumberGamesScreen(),
                  'features.number_games'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.camera_alt,
                title: 'features.camera_recognition'.tr(),
                description: 'features.camera_recognition_desc'.tr(),
                color: Colors.orange,
                onTap: () => _navigateToScreen(
                  const CameraRecognitionScreen(),
                  'features.camera_recognition'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.explore,
                title: 'features.spatial_orientation'.tr(),
                description: 'features.spatial_orientation_desc'.tr(),
                color: Colors.purple,
                onTap: () => _navigateToScreen(
                  const SpatialOrientationScreen(),
                  'features.spatial_orientation'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.hearing,
                title: 'features.sound_identification'.tr(),
                description: 'features.sound_identification_desc'.tr(),
                color: Colors.teal,
                onTap: () => _navigateToScreen(
                  const SoundIdentificationScreen(),
                  'features.sound_identification'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.security,
                title: 'features.cyber_safety'.tr(),
                description: 'features.cyber_safety_desc'.tr(),
                color: Colors.red,
                onTap: () => _navigateToScreen(
                  const CyberSafetyScreen(),
                  'features.cyber_safety'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.memory,
                title: 'features.sound_memory'.tr(),
                description: 'features.sound_memory_desc'.tr(),
                color: Colors.pink,
                onTap: () => _navigateToScreen(
                  const SoundMemoryScreen(),
                  'features.sound_memory'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.sports_esports,
                title: 'features.voice_pong'.tr(),
                description: 'features.voice_pong_desc'.tr(),
                color: Colors.amber,
                onTap: () => _navigateToScreen(
                  const VoicePongScreen(),
                  'features.voice_pong'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.music_note,
                title: 'features.melody_memory'.tr(),
                description: 'features.melody_memory_desc'.tr(),
                color: const Color(0xFF9C27B0),
                onTap: () => _navigateToScreen(
                  const MelodyMemoryScreen(),
                  'features.melody_memory'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.graphic_eq,
                title: 'features.rhythm_tap'.tr(),
                description: 'features.rhythm_tap_desc'.tr(),
                color: const Color(0xFFE91E63),
                onTap: () => _navigateToScreen(
                  const RhythmTapScreen(),
                  'features.rhythm_tap'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.menu_book,
                title: 'features.story_choices'.tr(),
                description: 'features.story_choices_desc'.tr(),
                color: const Color(0xFF009688),
                onTap: () => _navigateToScreen(
                  const StoryChoicesScreen(),
                  'features.story_choices'.tr(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final buttonSize = AccessibilityUtils.getButtonSize(context);
    final contrastColor = AccessibilityUtils.getContrastColor(context);

    final hint = 'features.tap_to_open'.tr().isNotEmpty ? 'features.tap_to_open'.tr() : 'Tap to open';
    return Semantics(
      label: '$title. $description. $hint',
      button: true,
        child: Card(
        elevation: AccessibilityUtils.isHighContrast(context) ? 0 : 8,
        color: AccessibilityUtils.getCardBackgroundColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: AccessibilityUtils.getCardBorder(context, fallbackColor: contrastColor),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 40 * buttonSize,
                  color: AccessibilityUtils.getPrimaryButtonForeground(context),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 22 * buttonSize,
                    fontWeight: FontWeight.bold,
                    color: contrastColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: contrastColor,
                size: 24 * buttonSize,
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

