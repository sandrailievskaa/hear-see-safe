import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/utils/platform_utils.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundIdentificationScreen extends StatefulWidget {
  const SoundIdentificationScreen({super.key});

  @override
  State<SoundIdentificationScreen> createState() =>
      _SoundIdentificationScreenState();
}

class _SoundIdentificationScreenState
    extends State<SoundIdentificationScreen> {
  late VoiceAssistantService _voiceAssistant;
  dynamic _speech;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final bool _isListening = false;
  String _currentSound = '';
  String _userAnswer = '';
  int _score = 0;
  int _totalQuestions = 0;

  final Map<String, String> _sounds = {
    'animal.cat': 'meow',
    'animal.dog': 'bark',
    'animal.bird': 'chirp',
    'vehicle.car': 'car',
    'vehicle.train': 'train',
    'nature.rain': 'rain',
    'nature.thunder': 'thunder',
    'nature.wind': 'wind',
  };

  @override
  void initState() {
    super.initState();
    _voiceAssistant =
        Provider.of<VoiceAssistantService>(context, listen: false);
    _initializeSpeech();
    _generateQuestion();
  }

  Future<void> _initializeSpeech() async {
    if (PlatformUtils.isWeb) {
      await _voiceAssistant.speak(
          'sound.speech_not_available'.tr());
      return;
    }
  }

  void _generateQuestion() {
    final keys = _sounds.keys.toList();
    _currentSound =
    keys[_totalQuestions % keys.length];
    _userAnswer = '';
    _playSound();
  }

  Future<void> _playSound() async {
    await _voiceAssistant.speak('sound.listen'.tr());
    await Future.delayed(
        const Duration(milliseconds: 500));
    await _voiceAssistant
        .speak('sound.playing_sound'.tr());
    await Future.delayed(
        const Duration(seconds: 2));
    await _voiceAssistant
        .speak('sound.what_is_this'.tr());
  }

  Future<void> _startListening() async {
    _showTextInputDialog();
  }

  void _showTextInputDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('sound.enter_answer'.tr()),
        content: TextField(
          onChanged: (value) =>
          _userAnswer = value,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkAnswer();
            },
            child: Text('sound.submit'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAnswer() async {
    if (_userAnswer.isEmpty) return;

    final correctAnswer =
        _currentSound.split('.').last;

    final isCorrect =
    _userAnswer.toLowerCase().contains(
        correctAnswer.toLowerCase());

    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(
          duration: isCorrect ? 200 : 100);
    }

    if (isCorrect) {
      setState(() => _score++);
      await _voiceAssistant
          .speak('sound.correct'.tr());
    } else {
      await _voiceAssistant.speak(
          'sound.incorrect'
              .tr(args: [correctAnswer]));
    }

    await Future.delayed(
        const Duration(seconds: 2));

    setState(() => _totalQuestions++);
    _generateQuestion();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
    AccessibilityUtils.getBackgroundColor(
        context);
    final contrastColor =
    AccessibilityUtils.getContrastColor(
        context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'features.sound_identification'.tr(),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        backgroundColor:
        const Color(0xFF2196F3),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFF2196F3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: contrastColor,
                          width: 4,
                        ),
                      ),
                      child: const Icon(
                        Icons.hearing,
                        size: 90,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'sound.ready'.tr(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight:
                        FontWeight.bold,
                        color: contrastColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// ✅ FIXED BUTTONS (TEXT SIMPLY SMALLER)
            Padding(
              padding:
              const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed:
                        _startListening,
                        icon: const Icon(
                            Icons.mic,
                            size: 18),
                        label: Text(
                          'sound.start'
                              .tr(),
                          style: const TextStyle(
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed:
                        _playSound,
                        icon: const Icon(
                            Icons.replay,
                            size: 18),
                        label: Text(
                          'sound.replay'
                              .tr(),
                          style: const TextStyle(
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.all(12),
              child: Text(
                'sound.score'.tr(args: [
                  _score.toString(),
                  _totalQuestions
                      .toString()
                ]),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                  color: contrastColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
