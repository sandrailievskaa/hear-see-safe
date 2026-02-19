import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/providers/app_state_provider.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/screens/picture_book_screen.dart';
import 'package:hear_and_see_safe/screens/number_games_screen.dart';
import 'package:hear_and_see_safe/screens/camera_recognition_screen.dart';
import 'package:hear_and_see_safe/screens/spatial_orientation_screen.dart';
import 'package:hear_and_see_safe/screens/sound_identification_screen.dart';
import 'package:hear_and_see_safe/screens/braille_learning_screen.dart';
import 'package:hear_and_see_safe/screens/cyber_safety_screen.dart';
import 'package:hear_and_see_safe/screens/sound_memory_screen.dart';
import 'package:hear_and_see_safe/screens/voice_pong_screen.dart';
import 'package:hear_and_see_safe/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VoiceAssistantService _voiceAssistant;

  @override
  void initState() {
    super.initState();
    _voiceAssistant = Provider.of<VoiceAssistantService>(context, listen: false);
    _voiceAssistant.initialize();
    _updateVoiceAssistantSettings();
    _announceHomeScreen();
  }

  void _updateVoiceAssistantSettings() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    _voiceAssistant.setVoiceAssistantEnabled(appState.isVoiceAssistantEnabled);
    _voiceAssistant.setVibrationEnabled(appState.vibrationEnabled);
  }

  Future<void> _announceHomeScreen() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _voiceAssistant.speak('home.welcome'.tr());
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
        backgroundColor: const Color(0xFF2196F3),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                icon: Icons.touch_app,
                title: 'features.braille_learning'.tr(),
                description: 'features.braille_learning_desc'.tr(),
                color: Colors.indigo,
                onTap: () => _navigateToScreen(
                  const BrailleLearningScreen(),
                  'features.braille_learning'.tr(),
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

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: contrastColor,
          width: 3,
        ),
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
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 22 * buttonSize,
                        fontWeight: FontWeight.bold,
                        color: contrastColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16 * buttonSize,
                        color: contrastColor.withOpacity(0.7),
                      ),
                    ),
                  ],
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
    );
  }
}

