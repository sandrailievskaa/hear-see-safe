import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/theme/app_style.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';
import 'package:hear_and_see_safe/widgets/game_screen_chrome.dart';

/// Гласовен Понг: верзија на пинг-понг со звук. Топката се „слуша“ како се движи
/// преку вибрации и глас — играчот допира на екранот во вистински момент за удар.
class VoicePongScreen extends StatefulWidget {
  const VoicePongScreen({super.key});

  @override
  State<VoicePongScreen> createState() => _VoicePongScreenState();
}

class _VoicePongScreenState extends State<VoicePongScreen> {
  late VoiceAssistantService _voiceAssistant;

  Timer? _gameTimer;
  double _ballX = 0.5;
  double _ballY = 0.5;
  double _ballSpeedX = -0.018;
  double _ballSpeedY = 0.012;
  int _score = 0;
  int _misses = 0;
  bool _isPlaying = false;
  static const int _maxMisses = 3;

  int _lastTickMs = 0;
  bool _announcedComing = false;

  @override
  void initState() {
    super.initState();
    _voiceAssistant =
        Provider.of<VoiceAssistantService>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _announceInstructions());
  }

  String get _langCode => context.locale.languageCode;

  Future<void> _announceInstructions() async {
    await _voiceAssistant.speakWithLanguage(
      'pong.instructions'.tr(),
      _langCode,
      vibrate: false,
    );
  }

  void _startGame() {
    if (_isPlaying) return;
    setState(() {
      _isPlaying = true;
      _score = 0;
      _misses = 0;
      _ballX = 0.5;
      _ballY = 0.5;
      _ballSpeedX = -0.018;
      _ballSpeedY = 0.012;
      _announcedComing = false;
      _lastTickMs = DateTime.now().millisecondsSinceEpoch;
    });
    _gameTimer = Timer.periodic(const Duration(milliseconds: 40), (_) => _updateGame());
    _voiceAssistant.speakWithLanguage('pong.start'.tr(), _langCode, vibrate: false);
  }

  void _stopGame() {
    _gameTimer?.cancel();
    _gameTimer = null;
    setState(() => _isPlaying = false);
    _voiceAssistant.speakWithLanguage(
      'pong.game_over'.tr(args: [_score.toString(), _misses.toString()]),
      _langCode,
      vibrate: false,
    );
  }

  void _updateGame() {
    if (!_isPlaying || !mounted) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    bool didMiss = false;
    int newMisses = _misses;

    setState(() {
      _ballX += _ballSpeedX;
      _ballY += _ballSpeedY;

      if (_ballY <= 0 || _ballY >= 1) {
        _ballSpeedY = -_ballSpeedY;
      }

      if (_ballX >= 1) {
        _ballSpeedX = -_ballSpeedX.abs();
      }

      if (_ballX < 0) {
        didMiss = true;
        _misses++;
        newMisses = _misses;
        _ballX = 0.5;
        _ballY = 0.5;
        _ballSpeedX = -0.018 - (_score * 0.002).clamp(0.0, 0.015);
        _ballSpeedY = 0.012;
        _announcedComing = false;
      }

      bool inApproach = _ballSpeedX < 0 && _ballX < 0.45;
      bool inHitZone = _ballSpeedX < 0 && _ballX < 0.22;

      if (inHitZone && !_announcedComing) {
        _announcedComing = true;
        _voiceAssistant.speakWithLanguage('pong.coming'.tr(), _langCode, vibrate: false);
      }

      if (inApproach) {
        final interval = inHitZone ? 70 : 130;
        if (now - _lastTickMs >= interval) {
          _lastTickMs = now;
          VibrationUtils.hasVibrator().then((ok) {
            if (ok) VibrationUtils.vibrate(duration: 25);
          });
        }
      } else if (_ballX > 0.5) {
        _announcedComing = false;
      }
    });

    if (didMiss) {
      VibrationUtils.hasVibrator().then((ok) {
        if (ok) VibrationUtils.vibrate(duration: 150);
      });
      _voiceAssistant.speakWithLanguage('pong.miss'.tr(), _langCode, vibrate: false);
      if (newMisses >= _maxMisses) {
        _stopGame();
      }
    }
  }

  void _onTap() {
    if (!_isPlaying) return;

    final inHitZone = _ballX < 0.25 && _ballSpeedX < 0;
    if (inHitZone) {
      setState(() {
        _ballSpeedX = (_ballSpeedX.abs() + 0.0015).clamp(0.018, 0.045);
        _ballSpeedX = -_ballSpeedX;
        _score++;
      });
      VibrationUtils.hasVibrator().then((ok) {
        if (ok) VibrationUtils.vibrate(duration: 100);
      });
      _voiceAssistant.speakWithLanguage('pong.hit'.tr(), _langCode, vibrate: false);
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contrastColor = AccessibilityUtils.getContrastColor(context);
    final hc = AccessibilityUtils.isHighContrast(context);

    return GameScreenChrome(
      accent: const Color(0xFFD97706),
      title: 'pong.title'.tr().isNotEmpty
          ? 'pong.title'.tr()
          : 'features.voice_pong'.tr(),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'pong.score'.tr(args: [_score.toString()]),
                    style: GameTypography.heading(context, contrastColor, 20),
                  ),
                  Text(
                    'pong.misses'.tr(args: [_misses.toString()]),
                    style: GameTypography.heading(
                      context,
                      _misses >= 2 ? const Color(0xFFFF4444) : contrastColor,
                      20,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Semantics(
                label: 'pong.instructions'.tr(),
                button: true,
                child: GestureDetector(
                  onTap: _onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: hc ? const Color(0xFF1A1A1A) : Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: contrastColor, width: 4),
                      boxShadow: hc ? const <BoxShadow>[] : AppStyle.cardShadow(false),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 16,
                          top: MediaQuery.of(context).size.height * 0.35 * _ballY.clamp(0.05, 0.95),
                          child: Container(
                            width: 16,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AccessibilityUtils.getAccentColor(context),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.35 * _ballX.clamp(0.0, 1.0) + 12,
                          top: MediaQuery.of(context).size.height * 0.35 * _ballY.clamp(0.0, 1.0) + 40,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AccessibilityUtils.getContrastColor(context),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: _isPlaying ? 'pong.stop'.tr() : 'pong.start'.tr(),
                      button: true,
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isPlaying ? _stopGame : _startGame,
                          icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                          label: Text(
                            _isPlaying ? 'pong.stop'.tr() : 'pong.start'.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isPlaying ? const Color(0xFFE53935) : const Color(0xFF4CAF50),
                            foregroundColor: AccessibilityUtils.getPrimaryButtonForeground(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Semantics(
                      label: 'pong.restart'.tr(),
                      button: true,
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_isPlaying) _stopGame();
                            _startGame();
                            AccessibilityUtils.provideFeedback(context: context);
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text('pong.restart'.tr()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AccessibilityUtils.getPrimaryButtonBackground(context),
                            foregroundColor: AccessibilityUtils.getPrimaryButtonForeground(context),
                            textStyle: const TextStyle(
                              fontSize: 16,
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
          ],
        ),
      ),
    );
  }
}
