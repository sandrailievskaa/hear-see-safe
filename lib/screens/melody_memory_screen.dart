import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';
import 'package:audioplayers/audioplayers.dart';

/// Меморија на мелодија (Simon Says со звуци): слушаш низа од звуци, потоа повторуваш со тап.
/// Целосно аудио, идеално за слепи деца.
class MelodyMemoryScreen extends StatefulWidget {
  const MelodyMemoryScreen({super.key});

  @override
  State<MelodyMemoryScreen> createState() => _MelodyMemoryScreenState();
}

class _MelodyMemoryScreenState extends State<MelodyMemoryScreen> {
  late VoiceAssistantService _voiceAssistant;
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const List<String> _soundIds = ['cat', 'dog', 'car', 'rain'];
  static const Map<String, String> _soundAssets = {
    'cat': 'assets/sounds/meow.mp3',
    'dog': 'assets/sounds/bark.mp3',
    'car': 'assets/sounds/car.mp3',
    'rain': 'assets/sounds/rain.mp3',
  };

  List<int> _sequence = [];
  int _userStep = 0;
  bool _playingSequence = false;
  bool _inputEnabled = false;
  int _level = 1;
  static const int _maxLevel = 8;

  @override
  void initState() {
    super.initState();
    _voiceAssistant = Provider.of<VoiceAssistantService>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGame());
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String get _langCode => context.locale.languageCode;

  void _startGame() {
    _level = 1;
    _nextLevel();
  }

  Future<void> _nextLevel() async {
    setState(() {
      _sequence.add(Random().nextInt(4));
      _userStep = 0;
      _playingSequence = true;
      _inputEnabled = false;
    });
    await _voiceAssistant.speakWithLanguage(
      'melody.level'.tr(args: [_level.toString()]),
      _langCode,
      vibrate: false,
    );
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await _playSequence();
    if (!mounted) return;
    setState(() {
      _playingSequence = false;
      _inputEnabled = true;
    });
    await _voiceAssistant.speakWithLanguage(
      'melody.your_turn'.tr(),
      _langCode,
      vibrate: false,
    );
  }

  Future<void> _playSequence() async {
    for (int i = 0; i < _sequence.length && mounted; i++) {
      await _playSoundByIndex(_sequence[i]);
      await Future.delayed(const Duration(milliseconds: 450));
    }
  }

  Future<void> _playSoundByIndex(int index) async {
    final id = _soundIds[index];
    final path = _soundAssets[id];
    if (path == null) return;
    try {
      final relative = path.startsWith('assets/') ? path.substring(7) : path;
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(relative));
    } catch (_) {}
  }

  Future<void> _onButtonTap(int index) async {
    if (!_inputEnabled || _playingSequence) return;

    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: 60);
    }
    await _playSoundByIndex(index);

    if (index != _sequence[_userStep]) {
      setState(() => _inputEnabled = false);
      await _voiceAssistant.speakWithLanguage(
        'melody.wrong'.tr(),
        _langCode,
        vibrate: false,
      );
      if (await VibrationUtils.hasVibrator()) {
        await VibrationUtils.vibrate(duration: 200);
      }
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() {
        _userStep = 0;
        _inputEnabled = true;
      });
      await _playSequence();
      if (!mounted) return;
      await _voiceAssistant.speakWithLanguage(
        'melody.your_turn'.tr(),
        _langCode,
        vibrate: false,
      );
      return;
    }

    setState(() => _userStep++);

    if (_userStep >= _sequence.length) {
      setState(() => _inputEnabled = false);
      if (await VibrationUtils.hasVibrator()) {
        await VibrationUtils.vibrate(duration: 250);
      }
      await _voiceAssistant.speakWithLanguage(
        'melody.correct'.tr(),
        _langCode,
        vibrate: false,
      );

      if (_level >= _maxLevel) {
        await Future.delayed(const Duration(milliseconds: 600));
        await _voiceAssistant.speakWithLanguage(
          'melody.win'.tr(),
          _langCode,
          vibrate: false,
        );
        setState(() {
          _level = 1;
          _sequence = [];
        });
        await Future.delayed(const Duration(milliseconds: 2500));
        if (!mounted) return;
        _startGame();
        return;
      }

      setState(() => _level++);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      _nextLevel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AccessibilityUtils.getBackgroundColor(context);
    final contrastColor = AccessibilityUtils.getContrastColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'features.melody_memory'.tr(),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: contrastColor),
        ),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'melody.level'.tr(args: [_level.toString()]),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: contrastColor),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.1,
                  children: List.generate(4, (index) {
                    final colors = [
                      Colors.blue,
                      Colors.orange,
                      Colors.green,
                      Colors.teal,
                    ];
                    final labels = [
                      'melody.sound1'.tr(),
                      'melody.sound2'.tr(),
                      'melody.sound3'.tr(),
                      'melody.sound4'.tr(),
                    ];
                    return Semantics(
                      label: '${labels[index]}. ${'melody.tap_to_repeat'.tr()}',
                      button: true,
                      child: Material(
                        color: colors[index].withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _onButtonTap(index),
                          child: Center(
                            child: Text(
                              labels[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
