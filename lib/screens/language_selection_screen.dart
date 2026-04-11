import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';
import '../providers/app_state_provider.dart';
import '../providers/accessibility_provider.dart';
import '../services/voice_assistant_service.dart';
import '../voice_system/application/language_manager.dart';
import '../utils/accessibility_utils.dart';
import '../theme/app_style.dart';
import '../widgets/ambient_background.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final voiceAssistant = Provider.of<VoiceAssistantService>(context, listen: false);
    final hc = Provider.of<AccessibilityProvider>(context).highContrastMode;

    if (hc) {
      return Scaffold(
        backgroundColor: AccessibilityUtils.getBackgroundColor(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'app.title'.tr(),
                  style: GoogleFonts.lexend(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AccessibilityUtils.getContrastColor(context),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'language.welcome'.tr(),
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    color: AccessibilityUtils.getContrastColor(context),
                  ),
                ),
                const SizedBox(height: 28),
                _voiceAssistantCard(context, voiceAssistant, highContrast: true),
                const SizedBox(height: 24),
                _languageRow(
                  context: context,
                  code: 'MK',
                  name: 'Македонски',
                  locale: const Locale('mk', 'MK'),
                  langCode: 'mk',
                  accent: const Color(0xFFFFC400),
                  voiceAssistant: voiceAssistant,
                  highContrast: true,
                ),
                const SizedBox(height: 16),
                _languageRow(
                  context: context,
                  code: 'EN',
                  name: 'English',
                  locale: const Locale('en', 'US'),
                  langCode: 'en',
                  accent: const Color(0xFF4A90E2),
                  voiceAssistant: voiceAssistant,
                  highContrast: true,
                ),
                const SizedBox(height: 16),
                _languageRow(
                  context: context,
                  code: 'SQ',
                  name: 'Shqip',
                  locale: const Locale('sq', 'AL'),
                  langCode: 'sq',
                  accent: const Color(0xFFFF1E2D),
                  voiceAssistant: voiceAssistant,
                  highContrast: true,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppStyle.welcomeBackground),
          ),
          const Positioned.fill(
            child: AmbientBackground(variant: AmbientVariant.welcome),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth > 480 ? 480.0 : constraints.maxWidth;
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            'app.title'.tr(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lexend(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.15,
                              letterSpacing: -0.8,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'language.welcome'.tr(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '👂  ·  👁️  ·  🙌',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _voiceAssistantCard(context, voiceAssistant, highContrast: false),
                          const SizedBox(height: 28),
                          Text(
                            'language.choose'.tr(),
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _languageRow(
                            context: context,
                            code: 'MK',
                            name: 'Македонски',
                            locale: const Locale('mk', 'MK'),
                            langCode: 'mk',
                            accent: const Color(0xFFFFB800),
                            voiceAssistant: voiceAssistant,
                            highContrast: false,
                          ),
                          const SizedBox(height: 14),
                          _languageRow(
                            context: context,
                            code: 'EN',
                            name: 'English',
                            locale: const Locale('en', 'US'),
                            langCode: 'en',
                            accent: const Color(0xFF38BDF8),
                            voiceAssistant: voiceAssistant,
                            highContrast: false,
                          ),
                          const SizedBox(height: 14),
                          _languageRow(
                            context: context,
                            code: 'SQ',
                            name: 'Shqip',
                            locale: const Locale('sq', 'AL'),
                            langCode: 'sq',
                            accent: const Color(0xFFFB7185),
                            voiceAssistant: voiceAssistant,
                            highContrast: false,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _voiceAssistantCard(
    BuildContext context,
    VoiceAssistantService voiceAssistant, {
    required bool highContrast,
  }) {
    if (highContrast) {
      return Semantics(
        container: true,
        label: '${'language.voice_title'.tr()}. ${'language.voice_ready'.tr()}',
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AccessibilityUtils.getCardBackgroundColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AccessibilityUtils.getAccentColor(context), width: 2),
          ),
          child: Row(
            children: [
              Icon(Icons.mic_rounded, color: AccessibilityUtils.getAccentColor(context), size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'language.voice_title'.tr(),
                      style: GoogleFonts.lexend(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AccessibilityUtils.getContrastColor(context),
                      ),
                    ),
                    Text(
                      'language.voice_ready'.tr(),
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        color: AccessibilityUtils.getContrastColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  await AccessibilityUtils.provideFeedback(
                    context: context,
                    audioFeedback: 'language.voice_assistant_ready'.tr(),
                    voiceAssistant: voiceAssistant,
                  );
                },
                icon: Icon(Icons.volume_up_rounded, color: AccessibilityUtils.getAccentColor(context)),
                tooltip: 'language.voice_title'.tr(),
              ),
            ],
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: '${'language.voice_title'.tr()}. ${'language.voice_ready'.tr()}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'language.voice_title'.tr(),
                    style: GoogleFonts.lexend(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppStyle.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'language.voice_ready'.tr(),
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppStyle.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: const Color(0xFF0F766E),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await AccessibilityUtils.provideFeedback(
                    context: context,
                    audioFeedback: 'language.voice_assistant_ready'.tr(),
                    voiceAssistant: voiceAssistant,
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(Icons.volume_up_rounded, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageRow({
    required BuildContext context,
    required String code,
    required String name,
    required Locale locale,
    required String langCode,
    required Color accent,
    required VoiceAssistantService voiceAssistant,
    required bool highContrast,
  }) {
    Future<void> select() async {
      await context.setLocale(locale);
      Provider.of<AppStateProvider>(context, listen: false).setLanguage(langCode);
      Provider.of<LanguageManager>(context, listen: false).setUserUiLanguageCode(langCode);

      await AccessibilityUtils.provideFeedback(
        context: context,
        audioFeedback: "${'settings.language'.tr()}: $name",
        voiceAssistant: voiceAssistant,
      );

      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }

    Future<void> preview() async {
      await AccessibilityUtils.provideFeedback(
        context: context,
        audioFeedback: name,
        voiceAssistant: voiceAssistant,
      );
    }

    if (highContrast) {
      return Semantics(
        button: true,
        label: '$name. ${'language.choose'.tr()}',
        child: Row(
          children: [
            Expanded(
              child: Material(
                color: AccessibilityUtils.getCardBackgroundColor(context),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: select,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AccessibilityUtils.getAccentColor(context), width: 2),
                    ),
                    child: Row(
                      children: [
                        Text(
                          code,
                          style: GoogleFonts.lexend(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AccessibilityUtils.getAccentColor(context),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.lexend(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AccessibilityUtils.getContrastColor(context),
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_rounded, color: AccessibilityUtils.getContrastColor(context)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: AccessibilityUtils.getPrimaryButtonBackground(context),
                foregroundColor: AccessibilityUtils.getPrimaryButtonForeground(context),
              ),
              onPressed: preview,
              icon: const Icon(Icons.volume_up_rounded),
            ),
          ],
        ),
      );
    }

    return Semantics(
      button: true,
      label: '$name. ${'language.choose'.tr()}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Material(
              color: Colors.white,
              elevation: 6,
              shadowColor: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: select,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border(
                      left: BorderSide(color: accent, width: 5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          code,
                          style: GoogleFonts.lexend(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppStyle.textPrimary,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded, color: accent, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.white,
            elevation: 4,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: preview,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: accent.withValues(alpha: 0.4), width: 2),
                ),
                child: Icon(Icons.volume_up_rounded, color: accent, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
