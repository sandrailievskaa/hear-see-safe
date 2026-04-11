import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';
import 'package:hear_and_see_safe/widgets/game_screen_chrome.dart';
import 'package:audioplayers/audioplayers.dart';

/// Ритмичка игра: слушаш N удари, потоа тапаш N пати во ритам. Учи ритам и броење.
class RhythmTapScreen extends StatefulWidget {
  const RhythmTapScreen({super.key});

  @override
  State<RhythmTapScreen> createState() => _RhythmTapScreenState();
}

class _RhythmTapScreenState extends State<RhythmTapScreen> {
  late VoiceAssistantService _voiceAssistant;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _level = 1;
  int _beatsToPlay = 3;
  int _userTaps = 0;
  bool _listenPhase = true;
  bool _tapPhase = false;
  static const int _maxLevel = 6;
  static const int _beatMs = 550;

  @override
  void initState() {
    super.initState();
    _voiceAssistant = Provider.of<VoiceAssistantService>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRound());
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String get _langCode => context.locale.languageCode;

  Future<void> _playBeat() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/sun.mp3'));
    } catch (_) {}
    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: 50);
    }
  }

  Future<void> _startRound() async {
    setState(() {
      _beatsToPlay = 2 + _level;
      _userTaps = 0;
      _listenPhase = true;
      _tapPhase = false;
    });

    await _voiceAssistant.speakWithLanguage(
      'rhythm.listen'.tr(args: [_beatsToPlay.toString()]),
      _langCode,
      vibrate: false,
    );
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    for (int i = 0; i < _beatsToPlay && mounted; i++) {
      await _playBeat();
      await Future.delayed(const Duration(milliseconds: _beatMs));
    }

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 400));

    setState(() {
      _listenPhase = false;
      _tapPhase = true;
    });

    await _voiceAssistant.speakWithLanguage(
      'rhythm.your_turn'.tr(args: [_beatsToPlay.toString()]),
      _langCode,
      vibrate: false,
    );
  }

  Future<void> _onTap() async {
    if (!_tapPhase) return;

    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: 60);
    }
    await _playBeat();

    setState(() => _userTaps++);
    await _voiceAssistant.speakWithLanguage(
      'rhythm.tap_count'.tr(args: [_userTaps.toString(), _beatsToPlay.toString()]),
      _langCode,
      vibrate: false,
    );

    if (_userTaps >= _beatsToPlay) {
      setState(() => _tapPhase = false);

      if (await VibrationUtils.hasVibrator()) {
        await VibrationUtils.vibrate(duration: 200);
      }
      await _voiceAssistant.speakWithLanguage(
        'rhythm.great'.tr(),
        _langCode,
        vibrate: false,
      );

      if (_level >= _maxLevel) {
        await Future.delayed(const Duration(milliseconds: 800));
        await _voiceAssistant.speakWithLanguage(
          'rhythm.win'.tr(),
          _langCode,
          vibrate: false,
        );
        setState(() => _level = 1);
        await Future.delayed(const Duration(milliseconds: 2500));
        if (!mounted) return;
        _startRound();
        return;
      }

      setState(() => _level++);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      _startRound();
    }
  }

  @override
  Widget build(BuildContext context) {
    final contrastColor = AccessibilityUtils.getContrastColor(context);
    final hc = AccessibilityUtils.isHighContrast(context);

    return GameScreenChrome(
      accent: const Color(0xFFE11D48),
      title: 'features.rhythm_tap'.tr(),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _listenPhase
                    ? 'rhythm.listen'.tr(args: [_beatsToPlay.toString()])
                    : 'rhythm.tap_count'.tr(args: [_userTaps.toString(), _beatsToPlay.toString()]),
                textAlign: TextAlign.center,
                style: GameTypography.heading(context, contrastColor, 20),
              ),
            ),
            Expanded(
              child: Semantics(
                label: 'rhythm.tap_area'.tr(),
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _onTap,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: _tapPhase && !hc
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFFFB7185).withValues(alpha: 0.42),
                                  const Color(0xFFF472B6).withValues(alpha: 0.22),
                                ],
                              )
                            : null,
                        color: !_tapPhase || hc
                            ? (hc ? const Color(0xFF333333) : Colors.grey.withValues(alpha: 0.2))
                            : null,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: contrastColor,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _tapPhase ? 'rhythm.tap_here'.tr() : 'rhythm.wait'.tr(),
                          style: GameTypography.heading(context, contrastColor, 28),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
