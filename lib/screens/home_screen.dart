import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/providers/app_state_provider.dart';
import 'package:hear_and_see_safe/voice_system/application/language_manager.dart';
import 'package:hear_and_see_safe/voice_system/application/voice_command_orchestrator.dart';
import 'package:hear_and_see_safe/voice_system/application/voice_ui_strings.dart';
import 'package:hear_and_see_safe/voice_system/presentation/voice_intent_dispatcher.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/theme/app_style.dart';
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

class _HomeFeature {
  const _HomeFeature({
    required this.icon,
    required this.titleKey,
    required this.descKey,
    required this.accent,
    required this.screen,
  });

  final IconData icon;
  final String titleKey;
  final String descKey;
  final Color accent;
  final Widget screen;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VoiceAssistantService _voiceAssistant;
  bool _isListening = false;

  static final List<_HomeFeature> _features = [
    _HomeFeature(
      icon: Icons.grid_view_rounded,
      titleKey: 'features.braille',
      descKey: 'features.braille_desc',
      accent: Color(0xFF1D4ED8),
      screen: const BrailleLearningScreen(),
    ),
    _HomeFeature(
      icon: Icons.auto_stories_rounded,
      titleKey: 'features.picture_book',
      descKey: 'features.picture_book_desc',
      accent: Color(0xFF2563EB),
      screen: const PictureBookScreen(),
    ),
    _HomeFeature(
      icon: Icons.calculate_rounded,
      titleKey: 'features.number_games',
      descKey: 'features.number_games_desc',
      accent: Color(0xFF059669),
      screen: const NumberGamesScreen(),
    ),
    _HomeFeature(
      icon: Icons.photo_camera_rounded,
      titleKey: 'features.camera_recognition',
      descKey: 'features.camera_recognition_desc',
      accent: Color(0xFFD97706),
      screen: const CameraRecognitionScreen(),
    ),
    _HomeFeature(
      icon: Icons.explore_rounded,
      titleKey: 'features.spatial_orientation',
      descKey: 'features.spatial_orientation_desc',
      accent: Color(0xFF7C3AED),
      screen: const SpatialOrientationScreen(),
    ),
    _HomeFeature(
      icon: Icons.hearing_rounded,
      titleKey: 'features.sound_identification',
      descKey: 'features.sound_identification_desc',
      accent: Color(0xFF0D9488),
      screen: const SoundIdentificationScreen(),
    ),
    _HomeFeature(
      icon: Icons.shield_rounded,
      titleKey: 'features.cyber_safety',
      descKey: 'features.cyber_safety_desc',
      accent: Color(0xFFDC2626),
      screen: const CyberSafetyScreen(),
    ),
    _HomeFeature(
      icon: Icons.psychology_rounded,
      titleKey: 'features.sound_memory',
      descKey: 'features.sound_memory_desc',
      accent: Color(0xFFDB2777),
      screen: const SoundMemoryScreen(),
    ),
    _HomeFeature(
      icon: Icons.sports_esports_rounded,
      titleKey: 'features.voice_pong',
      descKey: 'features.voice_pong_desc',
      accent: Color(0xFFCA8A04),
      screen: const VoicePongScreen(),
    ),
    _HomeFeature(
      icon: Icons.piano_rounded,
      titleKey: 'features.melody_memory',
      descKey: 'features.melody_memory_desc',
      accent: Color(0xFF9333EA),
      screen: const MelodyMemoryScreen(),
    ),
    _HomeFeature(
      icon: Icons.graphic_eq_rounded,
      titleKey: 'features.rhythm_tap',
      descKey: 'features.rhythm_tap_desc',
      accent: Color(0xFFE11D48),
      screen: const RhythmTapScreen(),
    ),
    _HomeFeature(
      icon: Icons.menu_book_rounded,
      titleKey: 'features.story_choices',
      descKey: 'features.story_choices_desc',
      accent: Color(0xFF0F766E),
      screen: const StoryChoicesScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _voiceAssistant = Provider.of<VoiceAssistantService>(context, listen: false);
    _voiceAssistant.initialize();
    _updateVoiceAssistantSettings();
    _announceHomeScreen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = context.locale.languageCode;
    final lm = Provider.of<LanguageManager>(context, listen: false);
    if (lm.userUiLanguageCode != code) {
      lm.setUserUiLanguageCode(code);
    }
  }

  Future<void> _startVoiceCommand() async {
    if (_isListening) return;
    setState(() => _isListening = true);
    final langCode = context.locale.languageCode;
    final orchestrator = Provider.of<VoiceCommandOrchestrator>(context, listen: false);
    final strings = VoiceUiStrings(
      commandHint: 'voice.speak_command'.tr(),
      notRecognized: 'voice.not_recognized'.tr(),
      confirmWifiDisable: 'voice.confirm_wifi_disable'.tr(),
      sessionCancelled: 'voice.session_cancelled'.tr(),
      systemWifiUnavailable: 'voice.system_wifi_unavailable'.tr(),
    );

    final intent = await orchestrator.runCommand(strings, langCode);
    if (!mounted) return;
    setState(() => _isListening = false);
    if (intent == null) return;

    await dispatchVoiceIntent(
      context: context,
      intent: intent,
      voiceAssistant: _voiceAssistant,
      systemWifiUnavailableMessage: strings.systemWifiUnavailable,
    );
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
    final hc = AccessibilityUtils.isHighContrast(context);
    final backgroundColor = AccessibilityUtils.getBackgroundColor(context);
    final contrastColor = AccessibilityUtils.getContrastColor(context);
    final secondaryColor = AccessibilityUtils.getSecondaryTextColor(context);
    final buttonSize = AccessibilityUtils.getButtonSize(context);
    final fabBg = _isListening
        ? AccessibilityUtils.getDisabledColor(context)
        : (hc ? AccessibilityUtils.getPrimaryButtonBackground(context) : const Color(0xFF115E59));
    final fabFg = AccessibilityUtils.getPrimaryButtonForeground(context);

    return Scaffold(
      backgroundColor: hc ? backgroundColor : Colors.transparent,
      extendBody: false,
      appBar: AppBar(
        centerTitle: false,
        elevation: hc ? 0 : 0,
        scrolledUnderElevation: 0,
        backgroundColor: hc ? AccessibilityUtils.getAppBarBackgroundColor(context) : Colors.transparent,
        flexibleSpace: hc
            ? null
            : Container(
                decoration: const BoxDecoration(gradient: AppStyle.appBarGradient),
              ),
        title: Text(
          'app.title'.tr(),
          style: GoogleFonts.lexend(
            fontSize: 22 * buttonSize,
            fontWeight: FontWeight.w700,
            color: hc ? contrastColor : Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded, size: 28 * buttonSize),
            color: hc ? contrastColor : Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: hc ? null : Colors.white.withValues(alpha: 0.18),
            ),
            onPressed: () {
              _navigateToScreen(
                const SettingsScreen(),
                'settings.opening'.tr(),
              );
            },
            tooltip: 'settings.title'.tr(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: Material(
        elevation: hc ? 0 : 8,
        shadowColor: const Color(0xFF115E59).withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _isListening ? null : _startVoiceCommand,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: _isListening || hc
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF115E59), Color(0xFF0D9488)],
                    ),
              color: (_isListening || hc) ? fabBg : null,
              border: hc
                  ? Border.all(color: contrastColor, width: 2)
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 22 * buttonSize,
                vertical: 16 * buttonSize,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: fabFg,
                    size: 26 * buttonSize,
                  ),
                  SizedBox(width: 10 * buttonSize),
                  Text(
                    _isListening ? 'voice.listening'.tr() : 'voice.tap_to_speak'.tr(),
                    style: GoogleFonts.lexend(
                      fontSize: 16 * buttonSize,
                      fontWeight: FontWeight.w700,
                      color: fabFg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: hc
            ? BoxDecoration(color: backgroundColor)
            : const BoxDecoration(gradient: AppStyle.homeBodyGradient),
        child: SafeArea(
          top: false,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 100),
            itemCount: _features.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'home.welcome'.tr(),
                        style: GoogleFonts.lexend(
                          fontSize: 15 * buttonSize,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }
              final f = _features[index - 1];
              final title = f.titleKey.tr();
              final desc = f.descKey.tr();
              final hint = 'features.tap_to_open'.tr();
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildFeatureCard(
                  context,
                  icon: f.icon,
                  title: title,
                  description: desc,
                  accent: f.accent,
                  buttonSize: buttonSize,
                  contrastColor: contrastColor,
                  secondaryColor: secondaryColor,
                  highContrast: hc,
                  semanticLabel: '$title. $desc. $hint',
                  onTap: () => _navigateToScreen(f.screen, title),
                ),
              );
            },
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
    required Color accent,
    required double buttonSize,
    required Color contrastColor,
    required Color secondaryColor,
    required bool highContrast,
    required String semanticLabel,
    required VoidCallback onTap,
  }) {
    final cardBg = AccessibilityUtils.getCardBackgroundColor(context);
    final borderSide = AccessibilityUtils.getCardBorder(context, fallbackColor: contrastColor);
    final borderColor = highContrast ? borderSide.color : const Color(0xFFE2E8F0);
    final borderW = highContrast ? borderSide.width : 1.0;

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: borderColor,
                width: borderW,
              ),
              boxShadow: AppStyle.cardShadow(highContrast),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(18 * buttonSize),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(14 * buttonSize),
                            decoration: BoxDecoration(
                              color: highContrast
                                  ? AccessibilityUtils.getPrimaryButtonBackground(context)
                                  : accent.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              icon,
                              size: 32 * buttonSize,
                              color: highContrast
                                  ? AccessibilityUtils.getPrimaryButtonForeground(context)
                                  : accent,
                            ),
                          ),
                          SizedBox(width: 16 * buttonSize),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: GoogleFonts.lexend(
                                    fontSize: 18 * buttonSize,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    color: contrastColor,
                                  ),
                                ),
                                SizedBox(height: 6 * buttonSize),
                                Text(
                                  description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lexend(
                                    fontSize: 14 * buttonSize,
                                    fontWeight: FontWeight.w500,
                                    height: 1.35,
                                    color: secondaryColor.withValues(
                                      alpha: highContrast ? 1.0 : 0.92,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: accent,
                            size: 18 * buttonSize,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
