import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';
import 'package:audioplayers/audioplayers.dart';

/// Аудио меморија за деца: наместо картички се слушаат звуци.
/// Детето допира картичка → слуша звук; допира друга → слуша звук.
/// Ако се ист звук — пар! Целосна гласовна повратна информација.
class SoundMemoryScreen extends StatefulWidget {
  const SoundMemoryScreen({super.key});

  @override
  State<SoundMemoryScreen> createState() => _SoundMemoryScreenState();
}

class _SoundMemoryScreenState extends State<SoundMemoryScreen> {
  late VoiceAssistantService _voiceAssistant;
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const List<String> _soundIds = [
    'cat',
    'dog',
    'car',
    'rain',
    'sun',
    'wind',
  ];

  static const Map<String, String> _soundAssets = {
    'cat': 'assets/sounds/meow.mp3',
    'dog': 'assets/sounds/bark.mp3',
    'car': 'assets/sounds/car.mp3',
    'rain': 'assets/sounds/rain.mp3',
    'sun': 'assets/sounds/sun.mp3',
    'wind': 'assets/sounds/wind.mp3',
  };

  List<String> _cards = [];
  List<bool> _revealed = [];
  List<bool> _matched = [];
  int? _firstIndex;
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    _voiceAssistant =
        Provider.of<VoiceAssistantService>(context, listen: false);
    _initGame();
    WidgetsBinding.instance.addPostFrameCallback((_) => _announceStart());
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String get _langCode => context.locale.languageCode;

  void _initGame() {
    _cards = [..._soundIds, ..._soundIds]..shuffle();
    _revealed = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
    _firstIndex = null;
    _moves = 0;
    setState(() {});
  }

  Future<void> _announceStart() async {
    await _voiceAssistant.speakWithLanguage(
      'sound_memory.start'.tr(),
      _langCode,
      vibrate: false,
    );
    await Future.delayed(const Duration(milliseconds: 500));
    await _voiceAssistant.speakWithLanguage(
      'sound_memory.instructions'.tr(),
      _langCode,
      vibrate: false,
    );
  }

  Future<void> _playSoundForCard(int index) async {
    final id = _cards[index];
    final path = _soundAssets[id];
    if (path == null) return;
    try {
      final relative = path.startsWith('assets/')
          ? path.substring('assets/'.length)
          : path;
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(relative));
    } catch (_) {}
  }

  Future<void> _onCardTap(int index) async {
    if (_revealed[index] || _matched[index]) return;
    if (_matched.where((x) => x).length == _cards.length ~/ 2) return;

    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: 80);
    }

    setState(() => _revealed[index] = true);
    await _playSoundForCard(index);

    if (_firstIndex == null) {
      setState(() => _firstIndex = index);
      return;
    }

    setState(() => _moves++);
    final firstId = _cards[_firstIndex!];
    final secondId = _cards[index];

    if (firstId == secondId) {
      setState(() {
        _matched[_firstIndex!] = true;
        _matched[index] = true;
        _firstIndex = null;
      });
      if (await VibrationUtils.hasVibrator()) {
        await VibrationUtils.vibrate(duration: 250);
      }
      await _voiceAssistant.speakWithLanguage(
        'sound_memory.match'.tr(),
        _langCode,
        vibrate: false,
      );
      final matchedCount = _matched.where((x) => x).length;
      if (matchedCount == _cards.length) {
        await Future.delayed(const Duration(milliseconds: 600));
        await _voiceAssistant.speakWithLanguage(
          'sound_memory.win'.tr(args: [_moves.toString()]),
          _langCode,
          vibrate: false,
        );
      }
    } else {
      await _voiceAssistant.speakWithLanguage(
        'sound_memory.no_match'.tr(),
        _langCode,
        vibrate: false,
      );
      await Future.delayed(const Duration(milliseconds: 1800));
      if (!mounted) return;
      setState(() {
        _revealed[_firstIndex!] = false;
        _revealed[index] = false;
        _firstIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AccessibilityUtils.getBackgroundColor(context);
    final contrastColor = AccessibilityUtils.getContrastColor(context);

    final matchedCount = _matched.where((x) => x).length;
    final totalPairs = _cards.length ~/ 2;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'features.sound_memory'.tr(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        backgroundColor: AccessibilityUtils.getAppBarBackgroundColor(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'sound_memory.matches'.tr(args: [matchedCount.toString()]),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: contrastColor,
                    ),
                  ),
                  Text(
                    'sound_memory.moves'.tr(args: [_moves.toString()]),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: contrastColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final isRevealed = _revealed[index];
                    final isMatched = _matched[index];
                    return Semantics(
                      label: 'sound_memory.tap_to_hear'.tr(args: [(index + 1).toString()]),
                      button: true,
                      child: GestureDetector(
                        onTap: () => _onCardTap(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isMatched
                                ? (AccessibilityUtils.isHighContrast(context) ? const Color(0xFF4CAF50) : Colors.green.shade600)
                                : isRevealed
                                    ? AccessibilityUtils.getPrimaryButtonBackground(context)
                                    : AccessibilityUtils.getDisabledColor(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: contrastColor,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: isRevealed || isMatched
                                ? Icon(
                                    Icons.volume_up,
                                    size: 44,
                                    color: AccessibilityUtils.getPrimaryButtonForeground(context),
                                  )
                                : Icon(
                                    Icons.help_outline,
                                    size: 44,
                                    color: AccessibilityUtils.getPrimaryButtonForeground(context),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Semantics(
                label: 'sound_memory.restart'.tr(),
                button: true,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _initGame();
                      _announceStart();
                      AccessibilityUtils.provideFeedback(context: context);
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text('sound_memory.restart'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AccessibilityUtils.getPrimaryButtonBackground(context),
                    foregroundColor: AccessibilityUtils.getPrimaryButtonForeground(context),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
