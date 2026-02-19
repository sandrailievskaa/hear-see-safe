import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundMemoryScreen extends StatefulWidget {
  const SoundMemoryScreen({super.key});

  @override
  State<SoundMemoryScreen> createState() => _SoundMemoryScreenState();
}

class _SoundMemoryScreenState extends State<SoundMemoryScreen> {
  late VoiceAssistantService _voiceAssistant;
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> _soundPairs = [];
  List<bool> _revealed = [];
  int? _firstSelected;
  int _matches = 0;
  int _moves = 0;

  final List<String> _sounds = [
    'sound_memory.car',
    'sound_memory.cat',
    'sound_memory.dog',
    'sound_memory.bird',
    'sound_memory.rain',
    'sound_memory.thunder',
  ];

  @override
  void initState() {
    super.initState();
    _voiceAssistant = Provider.of<VoiceAssistantService>(context, listen: false);
    _initializeGame();
  }

  void _initializeGame() {
    _soundPairs = [..._sounds, ..._sounds];
    _soundPairs.shuffle();
    _revealed = List.filled(_soundPairs.length, false);
    _firstSelected = null;
    _matches = 0;
    _moves = 0;
    _announceGameStart();
  }

  Future<void> _announceGameStart() async {
    await _voiceAssistant.speak('sound_memory.start'.tr());
    await Future.delayed(const Duration(milliseconds: 500));
    await _voiceAssistant.speak('sound_memory.instructions'.tr());
  }

  Future<void> _playSound(String soundKey) async {
    await _voiceAssistant.speak('sound_memory.playing'.tr(args: [soundKey]));
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _selectCard(int index) async {
    if (_revealed[index] || _matches == _soundPairs.length ~/ 2) return;

    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: 100);
    }

    setState(() {
      _revealed[index] = true;
    });

    await _playSound(_soundPairs[index]);

    if (_firstSelected == null) {
      setState(() {
        _firstSelected = index;
      });
    } else {
      setState(() {
        _moves++;
      });

      if (_soundPairs[_firstSelected!] == _soundPairs[index]) {
        setState(() {
          _matches++;
        });

        if (await VibrationUtils.hasVibrator()) {
          await VibrationUtils.vibrate(duration: 300);
        }

        await _voiceAssistant.speak('sound_memory.match'.tr());
        setState(() {
          _firstSelected = null;
        });

        if (_matches == _soundPairs.length ~/ 2) {
          await Future.delayed(const Duration(milliseconds: 500));
          await _voiceAssistant.speak('sound_memory.win'.tr(args: [_moves.toString()]));
        }
      } else {
        await _voiceAssistant.speak('sound_memory.no_match'.tr());
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _revealed[_firstSelected!] = false;
          _revealed[index] = false;
          _firstSelected = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AccessibilityUtils.getBackgroundColor(context);
    final contrastColor = AccessibilityUtils.getContrastColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'features.sound_memory'.tr(),
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
          child: Column(
            children: [
              // Matches / Moves
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Text(
                        'sound_memory.matches'.tr(args: [_matches.toString()]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'sound_memory.moves'.tr(args: [_moves.toString()]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // Grid of cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _soundPairs.length,
                  itemBuilder: (context, index) {
                    final isRevealed = _revealed[index];
                    final isMatched = _matches == _soundPairs.length ~/ 2 ||
                        (isRevealed && _soundPairs[index] == _soundPairs[_firstSelected ?? -1]);

                    return GestureDetector(
                      onTap: () => _selectCard(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isRevealed || isMatched
                              ? const Color(0xFF2196F3)
                              : const Color(0xFF757575),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: contrastColor,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: isRevealed || isMatched
                              ? const Icon(
                            Icons.volume_up,
                            size: 40,
                            color: Colors.white,
                          )
                              : const Icon(
                            Icons.help_outline,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Restart button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SafeArea(
                  top: false,
                  child: AccessibilityUtils.buildAccessibleButton(
                    context: context,
                    text: 'Restart',
                    icon: Icons.refresh,
                    onPressed: () {
                      _initializeGame();
                      AccessibilityUtils.provideFeedback(context: context);
                    },
                    width: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
