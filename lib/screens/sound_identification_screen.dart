import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';
import 'package:audioplayers/audioplayers.dart';

/// Идентификација на звук за деца: се пушта вистински звук (животно, возило, природа),
/// детето избира од големи копчиња што го слушнало. Целосна аудио повратна информација.
class SoundIdentificationScreen extends StatefulWidget {
  const SoundIdentificationScreen({super.key});

  @override
  State<SoundIdentificationScreen> createState() =>
      _SoundIdentificationScreenState();
}

class _SoundIdentificationScreenState extends State<SoundIdentificationScreen> {
  late VoiceAssistantService _voiceAssistant;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _score = 0;
  int _totalQuestions = 0;
  String? _currentSoundId;
  bool _waitingForAnswer = false;

  static const List<MapEntry<String, String>> _sounds = [
    MapEntry('cat', 'assets/sounds/meow.mp3'),
    MapEntry('dog', 'assets/sounds/bark.mp3'),
    MapEntry('car', 'assets/sounds/car.mp3'),
    MapEntry('rain', 'assets/sounds/rain.mp3'),
    MapEntry('sun', 'assets/sounds/sun.mp3'),
    MapEntry('wind', 'assets/sounds/wind.mp3'),
  ];

  static String _nameKey(String id) => 'sound.name_$id';

  @override
  void initState() {
    super.initState();
    _voiceAssistant =
        Provider.of<VoiceAssistantService>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _nextQuestion());
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String get _langCode => context.locale.languageCode;

  Future<void> _playAsset(String path) async {
    try {
      final relative = path.startsWith('assets/')
          ? path.substring('assets/'.length)
          : path;
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(relative));
    } catch (_) {}
  }

  Future<void> _nextQuestion() async {
    if (_sounds.isEmpty) return;
    final index = _totalQuestions % _sounds.length;
    final entry = _sounds[index];
    setState(() {
      _currentSoundId = entry.key;
      _waitingForAnswer = true;
    });
    await _voiceAssistant.speakWithLanguage(
      'sound.listen'.tr(),
      _langCode,
      vibrate: false,
    );
    await Future.delayed(const Duration(milliseconds: 600));
    await _voiceAssistant.speakWithLanguage(
      'sound.playing_sound'.tr(),
      _langCode,
      vibrate: false,
    );
    await Future.delayed(const Duration(milliseconds: 400));
    await _playAsset(entry.value);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    await _voiceAssistant.speakWithLanguage(
      'sound.what_is_this'.tr(),
      _langCode,
      vibrate: false,
    );
  }

  Future<void> _onChoose(String chosenId) async {
    if (!_waitingForAnswer || _currentSoundId == null) return;

    final isCorrect = chosenId == _currentSoundId;

    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: isCorrect ? 200 : 100);
    }

    if (isCorrect) {
      setState(() {
        _score++;
        _totalQuestions++;
        _waitingForAnswer = false;
      });
      await _voiceAssistant.speakWithLanguage(
        'sound.correct'.tr(),
        _langCode,
        vibrate: false,
      );
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) _nextQuestion();
    } else {
      final correctName = _nameKey(_currentSoundId!).tr();
      await _voiceAssistant.speakWithLanguage(
        'sound.incorrect'.tr(args: [correctName]),
        _langCode,
        vibrate: false,
      );
    }
  }

  Future<void> _replaySound() async {
    if (_currentSoundId == null || !_waitingForAnswer) return;
    final entry = _sounds.firstWhere(
      (e) => e.key == _currentSoundId,
      orElse: () => _sounds.first,
    );
    await _playAsset(entry.value);
    AccessibilityUtils.provideFeedback(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AccessibilityUtils.getBackgroundColor(context);
    final contrastColor = AccessibilityUtils.getContrastColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'features.sound_identification'.tr(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                shape: BoxShape.circle,
                border: Border.all(color: contrastColor, width: 4),
              ),
              child: const Icon(
                Icons.hearing,
                size: 70,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'sound.choose'.tr(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: contrastColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _sounds
                      .map((e) => _choiceButton(
                            context,
                            e.key,
                            contrastColor,
                          ))
                      .toList(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _waitingForAnswer ? _replaySound : null,
                  icon: const Icon(Icons.replay, size: 32),
                  color: const Color(0xFF2196F3),
                  tooltip: 'sound.replay'.tr(),
                ),
                const SizedBox(width: 24),
                Text(
                  'sound.score'.tr(args: [
                    _score.toString(),
                    _totalQuestions.toString(),
                  ]),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: contrastColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _choiceButton(
    BuildContext context,
    String soundId,
    Color contrastColor,
  ) {
    final label = _nameKey(soundId).tr();
    return Semantics(
      label: label,
      button: true,
      child: SizedBox(
        width: 140,
        height: 56,
        child: ElevatedButton(
          onPressed: _waitingForAnswer ? () => _onChoose(soundId) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
