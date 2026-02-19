import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/providers/app_state_provider.dart';
import 'package:hear_and_see_safe/providers/accessibility_provider.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late VoiceAssistantService _voiceAssistant;

  @override
  void initState() {
    super.initState();
    _voiceAssistant = Provider.of<VoiceAssistantService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AccessibilityUtils.getBackgroundColor(context);
    final contrastColor = AccessibilityUtils.getContrastColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'settings.title'.tr(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle(context, 'settings.language'.tr()),
              _buildLanguageSelector(context),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'settings.accessibility'.tr()),
              _buildAccessibilitySettings(context),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'settings.audio'.tr()),
              _buildAudioSettings(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final contrastColor = AccessibilityUtils.getContrastColor(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: contrastColor,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        return Card(
          elevation: 4,
          child: Column(
            children: [
              _buildLanguageOption(context, 'English', 'en', appState.currentLanguage),
              _buildLanguageOption(context, 'Македонски', 'mk', appState.currentLanguage),
              _buildLanguageOption(context, 'Shqip', 'sq', appState.currentLanguage),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, String code, String current) {
    final isSelected = current == code;
    final contrastColor = AccessibilityUtils.getContrastColor(context);

    return ListTile(
      title: Text(
        name,
        style: TextStyle(
          fontSize: 20,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: contrastColor,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF2196F3), size: 28)
          : null,
      onTap: () async {
        context.setLocale(Locale(code));
        Provider.of<AppStateProvider>(context, listen: false).setLanguage(code);
        await AccessibilityUtils.provideFeedback(
          context: context,
          audioFeedback: 'settings.language_changed'.tr(),
          voiceAssistant: _voiceAssistant,
        );
      },
    );
  }

  Widget _buildAccessibilitySettings(BuildContext context) {
    return Consumer<AccessibilityProvider>(
      builder: (context, accessibility, _) {
        return Card(
          elevation: 4,
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  'settings.high_contrast'.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    color: AccessibilityUtils.getContrastColor(context),
                  ),
                ),
                value: accessibility.highContrastMode,
                onChanged: (value) {
                  accessibility.toggleHighContrast();
                  AccessibilityUtils.provideFeedback(context: context);
                },
              ),
              SwitchListTile(
                title: Text(
                  'settings.large_text'.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    color: AccessibilityUtils.getContrastColor(context),
                  ),
                ),
                value: accessibility.largeTextMode,
                onChanged: (value) {
                  accessibility.toggleLargeText();
                  AccessibilityUtils.provideFeedback(context: context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAudioSettings(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        return Card(
          elevation: 4,
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  'settings.voice_assistant'.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    color: AccessibilityUtils.getContrastColor(context),
                  ),
                ),
                value: appState.isVoiceAssistantEnabled,
                onChanged: (value) {
                  appState.toggleVoiceAssistant();
                  AccessibilityUtils.provideFeedback(context: context);
                },
              ),
              SwitchListTile(
                title: Text(
                  'settings.vibration'.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    color: AccessibilityUtils.getContrastColor(context),
                  ),
                ),
                value: appState.vibrationEnabled,
                onChanged: (value) {
                  appState.toggleVibration();
                  AccessibilityUtils.provideFeedback(context: context);
                },
              ),
              ListTile(
                title: Text(
                  'settings.volume'.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    color: AccessibilityUtils.getContrastColor(context),
                  ),
                ),
                subtitle: Slider(
                  value: appState.volume,
                  onChanged: (value) {
                    appState.setVolume(value);
                    AccessibilityUtils.provideFeedback(context: context);
                  },
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

