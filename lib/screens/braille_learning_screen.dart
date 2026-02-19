import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';

class BrailleLearningScreen extends StatefulWidget {
  const BrailleLearningScreen({super.key});

  @override
  State<BrailleLearningScreen> createState() => _BrailleLearningScreenState();
}

class _BrailleLearningScreenState extends State<BrailleLearningScreen> {
  late VoiceAssistantService _voiceAssistant;
  String _currentLetter = 'A';
  List<bool> _selectedDots = List.filled(6, false);
  Map<String, List<bool>> _braillePatterns = {};

  @override
  void initState() {
    super.initState();
    _voiceAssistant =
        Provider.of<VoiceAssistantService>(context, listen: false);
    _initializeBraillePatterns();
    _loadLetter(_currentLetter);
  }

  void _initializeBraillePatterns() {
    _braillePatterns = {
      'A': [true, false, false, false, false, false],
      'B': [true, true, false, false, false, false],
      'C': [true, false, false, true, false, false],
      'D': [true, false, false, true, true, false],
      'E': [true, false, false, false, true, false],
      'F': [true, true, false, true, false, false],
      'G': [true, true, false, true, true, false],
      'H': [true, true, false, false, true, false],
      'I': [false, true, false, true, false, false],
      'J': [false, true, false, true, true, false],
      'K': [true, false, false, false, false, true],
      'L': [true, true, false, false, false, true],
      'M': [true, false, false, true, false, true],
      'N': [true, false, false, true, true, true],
      'O': [true, false, false, false, true, true],
      'P': [true, true, false, true, false, true],
      'Q': [true, true, false, true, true, true],
      'R': [true, true, false, false, true, true],
      'S': [false, true, false, true, false, true],
      'T': [false, true, false, true, true, true],
      'U': [true, false, false, false, false, true],
      'V': [true, true, false, false, false, true],
      'W': [false, true, false, true, true, false],
      'X': [true, false, false, true, false, true],
      'Y': [true, false, false, true, true, true],
      'Z': [true, false, false, false, true, true],
    };
  }

  Future<void> _loadLetter(String letter) async {
    setState(() {
      _currentLetter = letter;
      _selectedDots = List.filled(6, false);
    });

    await _voiceAssistant
        .speak('braille.learn_letter'.tr(args: [letter]));
  }

  Future<void> _toggleDot(int index) async {
    setState(() {
      _selectedDots[index] = !_selectedDots[index];
    });

    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: 100);
    }

    AccessibilityUtils.provideFeedback(context: context);
    _checkPattern();
  }

  Future<void> _checkPattern() async {
    final correctPattern = _braillePatterns[_currentLetter] ?? [];
    bool isCorrect = true;

    for (int i = 0; i < 6; i++) {
      if (_selectedDots[i] != correctPattern[i]) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect && _selectedDots.any((dot) => dot)) {
      if (await VibrationUtils.hasVibrator()) {
        await VibrationUtils.vibrate(duration: 300);
      }

      await _voiceAssistant
          .speak('braille.correct'.tr(args: [_currentLetter]));

      await Future.delayed(const Duration(seconds: 2));
      _nextLetter();
    }
  }

  void _nextLetter() {
    final currentIndex =
        _currentLetter.codeUnitAt(0) - 'A'.codeUnitAt(0);
    final nextIndex = (currentIndex + 1) % 26;
    final nextLetter =
    String.fromCharCode('A'.codeUnitAt(0) + nextIndex);
    _loadLetter(nextLetter);
  }

  void _previousLetter() {
    final currentIndex =
        _currentLetter.codeUnitAt(0) - 'A'.codeUnitAt(0);
    final prevIndex = (currentIndex - 1 + 26) % 26;
    final prevLetter =
    String.fromCharCode('A'.codeUnitAt(0) + prevIndex);
    _loadLetter(prevLetter);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
    AccessibilityUtils.getBackgroundColor(context);
    final contrastColor =
    AccessibilityUtils.getContrastColor(context);
    final correctPattern =
        _braillePatterns[_currentLetter] ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'features.braille_learning'.tr(),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: SafeArea(
        child: Column(
          children: [

            SizedBox(
              height: 90,
              child: Center(
                child: Text(
                  _currentLetter,
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: contrastColor,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 10),
                child: GridView.builder(
                  physics:
                  const NeverScrollableScrollPhysics(),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 25,
                    crossAxisSpacing: 25,
                    childAspectRatio: 1,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    final isSelected =
                    _selectedDots[index];
                    final shouldBeSelected =
                    correctPattern[index];

                    Color dotColor;
                    if (isSelected && shouldBeSelected) {
                      dotColor = Colors.green;
                    } else if (isSelected &&
                        !shouldBeSelected) {
                      dotColor = Colors.red;
                    } else {
                      dotColor =
                          Colors.grey.withOpacity(0.2);
                    }

                    return GestureDetector(
                      onTap: () =>
                          _toggleDot(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: contrastColor,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            /// ARROW BUTTONS (Guaranteed visible)
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 25, horizontal: 40),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 70,
                      child: ElevatedButton(
                        onPressed: _previousLetter,
                        child: const Icon(
                          Icons.arrow_back,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: SizedBox(
                      height: 70,
                      child: ElevatedButton(
                        onPressed: _nextLetter,
                        child: const Icon(
                          Icons.arrow_forward,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
