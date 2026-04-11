import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';
import 'package:hear_and_see_safe/widgets/game_screen_chrome.dart';

/// Приказна – твој избор: слушаш кратка приказна, избираш што ќе се случи понатаму, слушаш исходот.
/// Образовно за фантазија и одлучување.
class StoryChoicesScreen extends StatefulWidget {
  const StoryChoicesScreen({super.key});

  @override
  State<StoryChoicesScreen> createState() => _StoryChoicesScreenState();
}

class _StoryChoicesScreenState extends State<StoryChoicesScreen> {
  late VoiceAssistantService _voiceAssistant;

  int _currentStory = 0;
  bool _showingOutcome = false;
  static const int _storyCount = 3;

  @override
  void initState() {
    super.initState();
    _voiceAssistant = Provider.of<VoiceAssistantService>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _announceAndReadStory());
  }

  String get _langCode => context.locale.languageCode;

  String _storyKey(int i) => 'story.s${i + 1}_text';
  String _opt1Key(int i) => 'story.s${i + 1}_o1';
  String _opt2Key(int i) => 'story.s${i + 1}_o2';
  String _out1Key(int i) => 'story.s${i + 1}_out1';
  String _out2Key(int i) => 'story.s${i + 1}_out2';

  Future<void> _announceAndReadStory() async {
    await _voiceAssistant.speakWithLanguage(
      'story.intro'.tr(),
      _langCode,
      vibrate: false,
    );
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await _readStory();
  }

  Future<void> _readStory() async {
    setState(() => _showingOutcome = false);

    final textKey = _storyKey(_currentStory);
    await _voiceAssistant.speakWithLanguage(textKey.tr(), _langCode, vibrate: false);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    await _voiceAssistant.speakWithLanguage(
      'story.what_next'.tr(),
      _langCode,
      vibrate: false,
    );
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    await _voiceAssistant.speakWithLanguage(
      'story.option'.tr(args: ['1', _opt1Key(_currentStory).tr()]),
      _langCode,
      vibrate: false,
    );
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    await _voiceAssistant.speakWithLanguage(
      'story.option'.tr(args: ['2', _opt2Key(_currentStory).tr()]),
      _langCode,
      vibrate: false,
    );
  }

  Future<void> _choose(int option) async {
    if (_showingOutcome) return;

    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: 80);
    }

    setState(() => _showingOutcome = true);

    final outcomeKey = option == 1 ? _out1Key(_currentStory) : _out2Key(_currentStory);
    await _voiceAssistant.speakWithLanguage(outcomeKey.tr(), _langCode, vibrate: false);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    await _voiceAssistant.speakWithLanguage(
      'story.the_end'.tr(),
      _langCode,
      vibrate: false,
    );
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    if (_currentStory + 1 < _storyCount) {
      setState(() {
        _currentStory++;
        _showingOutcome = false;
      });
      await _voiceAssistant.speakWithLanguage(
        'story.next_story'.tr(),
        _langCode,
        vibrate: false,
      );
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      _readStory();
    } else {
      await _voiceAssistant.speakWithLanguage(
        'story.all_done'.tr(),
        _langCode,
        vibrate: false,
      );
      setState(() {
        _currentStory = 0;
        _showingOutcome = false;
      });
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      _readStory();
    }
  }

  void _restart() {
    setState(() {
      _currentStory = 0;
      _showingOutcome = false;
    });
    _announceAndReadStory();
  }

  @override
  Widget build(BuildContext context) {
    final contrastColor = AccessibilityUtils.getContrastColor(context);

    return GameScreenChrome(
      accent: const Color(0xFF0F766E),
      title: 'features.story_choices'.tr(),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'story.what_next'.tr(),
                textAlign: TextAlign.center,
                style: GameTypography.heading(context, contrastColor, 20),
              ),
            ),
            if (!_showingOutcome) ...[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Semantics(
                        label: '${'story.option'.tr(args: ['1', _opt1Key(_currentStory).tr()])}. ${'features.tap_to_open'.tr()}',
                        button: true,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.touch_app, size: 32),
                            label: Text(
                              _opt1Key(_currentStory).tr(),
                              style: const TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () => _choose(1),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: AccessibilityUtils.getPrimaryButtonBackground(context),
                              foregroundColor: AccessibilityUtils.getPrimaryButtonForeground(context),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Semantics(
                        label: '${'story.option'.tr(args: ['2', _opt2Key(_currentStory).tr()])}. ${'features.tap_to_open'.tr()}',
                        button: true,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.touch_app, size: 32),
                            label: Text(
                              _opt2Key(_currentStory).tr(),
                              style: const TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () => _choose(2),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: AccessibilityUtils.getPrimaryButtonBackground(context),
                              foregroundColor: AccessibilityUtils.getPrimaryButtonForeground(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'story.the_end'.tr(),
                        style: GameTypography.heading(context, contrastColor, 24),
                      ),
                      const SizedBox(height: 32),
                      Semantics(
                        label: 'story.play_again'.tr(),
                        button: true,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.replay),
                          label: Text('story.play_again'.tr()),
                          onPressed: _restart,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            backgroundColor: AccessibilityUtils.getPrimaryButtonBackground(context),
                            foregroundColor: AccessibilityUtils.getPrimaryButtonForeground(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
