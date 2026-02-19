import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';
import 'package:audioplayers/audioplayers.dart';

class VoicePongScreen extends StatefulWidget {
  const VoicePongScreen({super.key});

  @override
  State<VoicePongScreen> createState() => _VoicePongScreenState();
}

class _VoicePongScreenState extends State<VoicePongScreen> {
  late VoiceAssistantService _voiceAssistant;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _gameTimer;
  double _ballX = 0.5;
  double _ballY = 0.5;
  double _ballSpeedX = 0.02;
  double _ballSpeedY = 0.02;
  double _paddleY = 0.5;
  int _score = 0;
  int _misses = 0;
  bool _isPlaying = false;
  String _lastDirection = '';

  @override
  void initState() {
    super.initState();
    _voiceAssistant = Provider.of<VoiceAssistantService>(context, listen: false);
    _announceInstructions();
  }

  Future<void> _announceInstructions() async {
    await _voiceAssistant.speak('pong.instructions'.tr());
  }

  void _startGame() {
    if (_isPlaying) return;

    setState(() {
      _isPlaying = true;
      _score = 0;
      _misses = 0;
      _ballX = 0.5;
      _ballY = 0.5;
      _paddleY = 0.5;
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _updateGame();
    });

    _voiceAssistant.speak('pong.start'.tr());
  }

  void _stopGame() {
    _gameTimer?.cancel();
    setState(() {
      _isPlaying = false;
    });
    _voiceAssistant.speak('pong.game_over'.tr(args: [_score.toString()]));
  }

  void _updateGame() {
    if (!_isPlaying) return;

    setState(() {
      _ballX += _ballSpeedX;
      _ballY += _ballSpeedY;

      // Bounce off walls
      if (_ballY <= 0 || _ballY >= 1) {
        _ballSpeedY = -_ballSpeedY;
      }

      // Check collision with paddle
      if (_ballX <= 0.1 && (_ballY - _paddleY).abs() < 0.15) {
        _ballSpeedX = -_ballSpeedX;
        _score++;
        VibrationUtils.hasVibrator().then((hasVibrator) {
          if (hasVibrator) {
            VibrationUtils.vibrate(duration: 100);
          }
        });
        _voiceAssistant.speak('pong.hit'.tr());
      }

      // Ball missed
      if (_ballX < 0) {
        _misses++;
        _ballX = 0.5;
        _ballY = 0.5;
        _ballSpeedX = 0.02;
        _ballSpeedY = 0.02;
        VibrationUtils.hasVibrator().then((hasVibrator) {
          if (hasVibrator) {
            VibrationUtils.vibrate(duration: 200, pattern: [0, 100, 50, 100]);
          }
        });
        _voiceAssistant.speak('pong.miss'.tr());
      }

      // Game over condition
      if (_misses >= 3) {
        _stopGame();
      }

      _announceBallPosition();
    });
  }

  Future<void> _announceBallPosition() async {
    String direction = '';
    if (_ballX < 0.3) {
      direction = 'pong.left'.tr();
    } else if (_ballX > 0.7) {
      direction = 'pong.right'.tr();
    } else {
      direction = 'pong.center'.tr();
    }

    if (direction != _lastDirection) {
      _lastDirection = direction;
      if (DateTime.now().millisecond % 500 < 50) {
        await _voiceAssistant.speak(direction);
      }
    }
  }

  void _movePaddleUp() {
    if (_isPlaying) {
      setState(() {
        _paddleY = (_paddleY - 0.1).clamp(0.0, 1.0);
      });
    }
  }

  void _movePaddleDown() {
    if (_isPlaying) {
      setState(() {
        _paddleY = (_paddleY + 0.1).clamp(0.0, 1.0);
      });
    }
  }

  void _tapToHit() {
    if (_isPlaying && _ballX <= 0.15) {
      setState(() {
        _ballSpeedX = -_ballSpeedX;
        _score++;
      });
      VibrationUtils.hasVibrator().then((hasVibrator) {
        if (hasVibrator) {
          VibrationUtils.vibrate(duration: 100);
        }
      });
      _voiceAssistant.speak('pong.hit'.tr());
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('features.voice_pong'.tr()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Score and Misses
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: Text(
                      'pong.score'.tr(args: [_score.toString()]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'pong.misses'.tr(args: [_misses.toString()]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Game Area
            Expanded(
              child: GestureDetector(
                onTap: _tapToHit,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Paddle
                      Positioned(
                        left: 20,
                        top: MediaQuery.of(context).size.height * 0.4 * _paddleY,
                        child: Container(
                          width: 20,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      // Ball
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.4 * _ballX,
                        top: MediaQuery.of(context).size.height * 0.4 * _ballY,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Controls
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 80,
                        child: ElevatedButton(
                          onPressed: _movePaddleUp,
                          child: const Text('↑'),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        height: 80,
                        child: ElevatedButton(
                          onPressed: _movePaddleDown,
                          child: const Text('↓'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Start/Stop Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: _isPlaying ? _stopGame : _startGame,
                      icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                      label: Flexible(
                        child: Text(
                          _isPlaying ? 'pong.stop'.tr() : 'pong.start'.tr(),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
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
