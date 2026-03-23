import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';

/// Просторна ориентација како игра за слепи: апликацијата ја чита целата инструкција
/// (на пр. „на равна површина прошетајте 5 чекори напред, свртете лево...“).
/// Корисникот извршува чекори со стрелки на тастатурата или копчиња на екранот
/// и добива глас и вибрација дали е правилно или не.
class SpatialOrientationScreen extends StatefulWidget {
  const SpatialOrientationScreen({super.key});

  @override
  State<SpatialOrientationScreen> createState() =>
      _SpatialOrientationScreenState();
}

class _SpatialOrientationScreenState extends State<SpatialOrientationScreen> {
  late VoiceAssistantService _voiceAssistant;

  static const List<String> _expectedSequence = [
    'forward', 'forward', 'forward', 'forward', 'forward',
    'turn_left',
    'forward', 'forward', 'forward',
    'turn_right',
    'forward', 'forward',
    'stop',
  ];

  int _currentIndex = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _voiceAssistant =
        Provider.of<VoiceAssistantService>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakFullInstruction();
    });
    _attachKeyListener();
  }

  void _attachKeyListener() {
    HardwareKeyboard.instance.addHandler(_keyHandler);
  }

  bool _keyHandler(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) {
      _onAction('forward');
      return true;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      _onAction('turn_left');
      return true;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _onAction('turn_right');
      return true;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _onAction('stop');
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyHandler);
    super.dispose();
  }

  String get _langCode => context.locale.languageCode;

  Future<void> _speakFullInstruction() async {
    final msg = 'spatial.full_instruction'.tr();
    if (msg.isNotEmpty) {
      await _voiceAssistant.speakWithLanguage(msg, _langCode, vibrate: false);
    }
    await Future.delayed(const Duration(milliseconds: 300));
    final hint = 'spatial.use_arrows_hint'.tr();
    if (hint.isNotEmpty) {
      await _voiceAssistant.speakWithLanguage(hint, _langCode, vibrate: false);
    }
  }

  Future<void> _onAction(String action) async {
    if (_finished) return;

    final expected = _expectedSequence[_currentIndex];
    final isCorrect = action == expected;

    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: isCorrect ? 200 : 100);
    }

    if (isCorrect) {
      _currentIndex++;
      await _voiceAssistant.speakWithLanguage(
        'spatial.correct'.tr(),
        _langCode,
        vibrate: false,
      );
      if (_currentIndex >= _expectedSequence.length) {
        _finished = true;
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 600));
        await _voiceAssistant.speakWithLanguage(
          'spatial.all_completed'.tr(),
          _langCode,
          vibrate: false,
        );
      } else {
        setState(() {});
      }
    } else {
      await _voiceAssistant.speakWithLanguage(
        'spatial.incorrect'.tr(),
        _langCode,
        vibrate: false,
      );
      setState(() {});
    }
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _finished = false;
    });
    _speakFullInstruction();
    AccessibilityUtils.provideFeedback(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AccessibilityUtils.getBackgroundColor(context);
    final contrastColor = AccessibilityUtils.getContrastColor(context);

    return Focus(
      autofocus: true,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            'spatial.title'.tr().isNotEmpty
                ? 'spatial.title'.tr()
                : 'features.spatial_orientation'.tr(),
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
                padding: const EdgeInsets.all(16),
                child: Text(
                  'spatial.progress'.tr(args: [
                    (_currentIndex).toString(),
                    _expectedSequence.length.toString(),
                  ]),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: contrastColor,
                  ),
                ),
              ),
              if (_finished)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'spatial.all_completed'.tr(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AccessibilityUtils.isHighContrast(context) ? const Color(0xFF4CAF50) : Colors.green.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Icon(
                      Icons.explore,
                      size: 120,
                      color: AccessibilityUtils.getSecondaryTextColor(context),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _arrowButton(
                      context,
                      icon: Icons.arrow_upward,
                      action: 'forward',
                      label: 'spatial.button_forward'.tr(),
                      contrastColor: contrastColor,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _arrowButton(
                    context,
                    icon: Icons.arrow_back,
                    action: 'turn_left',
                    label: 'spatial.button_left'.tr(),
                    contrastColor: contrastColor,
                  ),
                  const SizedBox(width: 24),
                  SizedBox(width: 72, height: 56),
                  const SizedBox(width: 24),
                  _arrowButton(
                    context,
                    icon: Icons.arrow_forward,
                    action: 'turn_right',
                    label: 'spatial.button_right'.tr(),
                    contrastColor: contrastColor,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _arrowButton(
                  context,
                  icon: Icons.stop,
                  action: 'stop',
                  label: 'spatial.button_stop'.tr(),
                  contrastColor: contrastColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _speakFullInstruction,
                        icon: const Icon(Icons.replay),
                        label: Text('spatial.repeat'.tr()),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AccessibilityUtils.getDisabledColor(context),
                          foregroundColor: AccessibilityUtils.getPrimaryButtonForeground(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _restart,
                        icon: const Icon(Icons.refresh),
                        label: Text('spatial.restart'.tr()),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AccessibilityUtils.getPrimaryButtonBackground(context),
                          foregroundColor: AccessibilityUtils.getPrimaryButtonForeground(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _arrowButton(
    BuildContext context, {
    required IconData icon,
    required String action,
    required String label,
    required Color contrastColor,
  }) {
    return Semantics(
      label: label,
      button: true,
      child: SizedBox(
        width: 72,
        height: 56,
        child: ElevatedButton(
          onPressed: _finished ? null : () => _onAction(action),
          style: ElevatedButton.styleFrom(
            backgroundColor: AccessibilityUtils.getPrimaryButtonBackground(context),
            foregroundColor: AccessibilityUtils.getPrimaryButtonForeground(context),
            padding: EdgeInsets.zero,
          ),
          child: Icon(icon, size: 32),
        ),
      ),
    );
  }
}
