
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'home_screen.dart';
import '../providers/app_state_provider.dart';
import '../services/voice_assistant_service.dart';
import '../utils/accessibility_utils.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final voiceAssistant = Provider.of<VoiceAssistantService>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE4E8CF),
              Color(0xFFF6E8A8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth > 520 ? 520.0 : constraints.maxWidth;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        _voiceAssistantCard(context, voiceAssistant),
                        const SizedBox(height: 36),

                        _languageRow(
                          context: context,
                          code: "MK",
                          name: "Македонски",
                          locale: const Locale('mk', 'MK'),
                          langCode: 'mk',
                          color: const Color(0xFFFFC400),
                          voiceAssistant: voiceAssistant,
                        ),
                        const SizedBox(height: 22),
                        _languageRow(
                          context: context,
                          code: "GB",
                          name: "English",
                          locale: const Locale('en', 'US'),
                          langCode: 'en',
                          color: const Color(0xFF4A90E2),
                          voiceAssistant: voiceAssistant,
                        ),
                        const SizedBox(height: 22),
                        _languageRow(
                          context: context,
                          code: "AL",
                          name: "Shqip",
                          locale: const Locale('sq', 'AL'),
                          langCode: 'sq',
                          color: const Color(0xFFFF1E2D),
                          voiceAssistant: voiceAssistant,
                        ),

                        const Spacer(),
                        const Text("👂   👁️   🙌", style: TextStyle(fontSize: 30)),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _voiceAssistantCard(BuildContext context, VoiceAssistantService voiceAssistant) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFB46BFF), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF8E74FF),
            child: Icon(Icons.mic, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Voice Assistant", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Ready to help"),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              await AccessibilityUtils.provideFeedback(
                context: context,
                audioFeedback: "Voice assistant is ready.",
                voiceAssistant: voiceAssistant,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2F78FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.volume_up, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageRow({
    required BuildContext context,
    required String code,
    required String name,
    required Locale locale,
    required String langCode,
    required Color color,
    required VoiceAssistantService voiceAssistant,
  }) {
    Future<void> select() async {
      context.setLocale(locale);
      Provider.of<AppStateProvider>(context, listen: false).setLanguage(langCode);

      await AccessibilityUtils.provideFeedback(
        context: context,
        audioFeedback: "${'settings.language'.tr()}: $name",
        voiceAssistant: voiceAssistant,
      );

      // Оди на постоечкиот HomeScreen (листата со модули)
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

    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: select,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(code,
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(name, style: const TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: preview,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.volume_up, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
