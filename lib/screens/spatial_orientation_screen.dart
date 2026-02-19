import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';

class SpatialOrientationScreen extends StatefulWidget {
  const SpatialOrientationScreen({super.key});

  @override
  State<SpatialOrientationScreen> createState() => _SpatialOrientationScreenState();
}

class _SpatialOrientationScreenState extends State<SpatialOrientationScreen> {
  late VoiceAssistantService _voiceAssistant;
  List<String> _instructions = [];
  int _currentStep = 0;
  int _stepsCompleted = 0;

  int _score = 0; // Додаено Score

  @override
  void initState() {
    super.initState();
    _voiceAssistant = Provider.of<VoiceAssistantService>(context, listen: false);
    _generateInstructions();
  }

  void _generateInstructions() {
    _instructions = [
      'spatial.walk_forward_5'.tr(),
      'spatial.turn_left'.tr(),
      'spatial.walk_forward_3'.tr(),
      'spatial.turn_right'.tr(),
      'spatial.walk_forward_2'.tr(),
      'spatial.stop'.tr(),
    ];
    _currentStep = 0;
    _stepsCompleted = 0;
    _score = 0; // Reset score на почеток
    _announceCurrentInstruction();
  }

  Future<void> _announceCurrentInstruction() async {
    if (_currentStep < _instructions.length) {
      await _voiceAssistant.speak(
        'spatial.instruction'.tr(args: [
          (_currentStep + 1).toString(),
          _instructions[_currentStep],
        ]),
      );
    }
  }

  Future<void> _completeStep() async {
    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: 200);
    }

    await _voiceAssistant.speak('spatial.step_completed'.tr());

    setState(() {
      _stepsCompleted++;
      _currentStep++;
      _score++; // Зголемување на Score при Заврши чекор
    });

    if (_currentStep < _instructions.length) {
      await Future.delayed(const Duration(milliseconds: 500));
      await _announceCurrentInstruction();
    } else {
      await _voiceAssistant.speak('spatial.all_completed'.tr());
    }
  }

  Future<void> _repeatInstruction() async {
    await _announceCurrentInstruction();
    AccessibilityUtils.provideFeedback(context: context);

    setState(() {
      if (_score > 0) {
        _score--; // Намалување на Score при Повтори
      }
    });
  }

  Widget _buildButton({required String text, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AccessibilityUtils.getBackgroundColor(context);
    final contrastColor = AccessibilityUtils.getContrastColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'features.spatial_orientation'.tr(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: contrastColor,
                          width: 4,
                        ),
                      ),
                      child: Icon(
                        Icons.navigation,
                        size: 100,
                        color: contrastColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (_currentStep < _instructions.length)
                      Text(
                        _instructions[_currentStep],
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: contrastColor,
                        ),
                        textAlign: TextAlign.center,
                      )
                    else
                      Text(
                        'spatial.all_completed'.tr(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 20),
                    // ================= Score долу ===================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Score: ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: contrastColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _score.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    // ================================================
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      text: 'spatial.repeat'.tr(),
                      icon: Icons.replay,
                      onPressed: _repeatInstruction,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _currentStep < _instructions.length
                        ? _buildButton(
                      text: 'spatial.complete'.tr(),
                      icon: Icons.check,
                      onPressed: _completeStep,
                    )
                        : _buildButton(
                      text: 'spatial.restart'.tr(),
                      icon: Icons.refresh,
                      onPressed: () {
                        _generateInstructions();
                        AccessibilityUtils.provideFeedback(context: context);
                      },
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
