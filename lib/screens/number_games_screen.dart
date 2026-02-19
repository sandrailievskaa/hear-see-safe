import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';

class NumberGamesScreen extends StatefulWidget {
  const NumberGamesScreen({super.key});

  @override
  State<NumberGamesScreen> createState() => _NumberGamesScreenState();
}

class _NumberGamesScreenState extends State<NumberGamesScreen> {
  late VoiceAssistantService _voiceAssistant;

  String _currentGame = 'counting';
  int _currentNumber = 1;

  int? _selectedAnswer;
  bool _isCorrect = false;

  int _score = 0;
  int _totalQuestions = 0;

  String? _currentQuestion;
  int? _correctAnswer;
  List<int> _options = [];

  @override
  void initState() {
    super.initState();
    _voiceAssistant =
        Provider.of<VoiceAssistantService>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateQuestion();
    });
  }

  void _generateQuestion() {
    setState(() {
      _selectedAnswer = null;
      _isCorrect = false;
    });

    if (_currentGame == 'counting') {
      _currentNumber = 1 + (_totalQuestions % 10);
      _currentQuestion = null;
      _correctAnswer = _currentNumber;
      _options = [];
      _announceNumber();
      return;
    }

    if (_currentGame == 'counting_objects') {
      _currentNumber = 1 + (_totalQuestions % 5);
      _currentQuestion = null;
      _correctAnswer = _currentNumber;
      _options = [];
      _announceNumber();
      return;
    }

    if (_currentGame == 'addition') {
      final a = 1 + (_totalQuestions % 5);
      final b = 1 + ((_totalQuestions * 2) % 5);

      _currentQuestion = '$a + $b';
      _correctAnswer = a + b;

      _options = [
        _correctAnswer!,
        _correctAnswer! + 1,
        _correctAnswer! - 1,
        _correctAnswer! + 2,
      ].where((x) => x >= 0).toSet().toList();

      _options.shuffle();

      _announceQuestion();
      return;
    }
  }

  Future<void> _announceNumber() async {
    await _voiceAssistant.speak(
      'number_games.number'.tr(args: [_currentNumber.toString()]),
    );
  }

  Future<void> _announceQuestion() async {
    if (_currentQuestion == null) return;

    await _voiceAssistant.speak(
      'number_games.question'.tr(args: [_currentQuestion!]),
    );
    await Future.delayed(const Duration(milliseconds: 400));
    await _voiceAssistant.speak('number_games.choose_answer'.tr());
  }

  Future<void> _selectAnswer(int answer) async {
    final int correctValue =
    _currentGame == 'addition' ? _correctAnswer! : _currentNumber;

    final bool isNowCorrect = answer == correctValue;

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = isNowCorrect;

      // Зголемување или намалување на score
      if (isNowCorrect) {
        _score++;
      } else {
        if (_score > 0) {
          _score--;
        }
      }
    });

    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: isNowCorrect ? 180 : 90);
    }

    if (isNowCorrect) {
      await _voiceAssistant.speak('number_games.correct'.tr());

      await Future.delayed(const Duration(milliseconds: 900));

      setState(() {
        _totalQuestions++;
        _selectedAnswer = null;
        _isCorrect = false;
      });

      _generateQuestion();
    } else {
      await _voiceAssistant.speak('number_games.incorrect'.tr());

      // кратко време да се врати бојата во сино и да може повторно да кликнеш
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() {
        _selectedAnswer = null;
        _isCorrect = false;
      });
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
          'features.number_games'.tr(),
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildGameButton(
                      context, 'counting', 'number_games.counting'.tr()),
                  _buildGameButton(
                      context, 'addition', 'number_games.addition'.tr()),
                  _buildGameButton(context, 'counting_objects',
                      'number_games.objects'.tr()),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(child: _buildGameContent(context)),
              ),
            ),
            // ===================== Score долу =====================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Score: ',
                    style: TextStyle(
                      fontSize: 18,
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
            ),
            // =======================================================
          ],
        ),
      ),
    );
  }

  Widget _buildGameButton(
      BuildContext context, String game, String label) {
    final isActive = _currentGame == game;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _currentGame = game;
          _score = 0;
          _totalQuestions = 0;
          _selectedAnswer = null;
          _isCorrect = false;
        });
        _generateQuestion();
        AccessibilityUtils.provideFeedback(context: context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFF2196F3) : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Text(label),
    );
  }

  Widget _buildGameContent(BuildContext context) {
    final contrastColor = AccessibilityUtils.getContrastColor(context);
    final buttonSize = AccessibilityUtils.getButtonSize(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final w = constraints.maxWidth;

        final bigNumberSize = (h * 0.32).clamp(90.0, 180.0);
        final questionSize = (w * 0.18).clamp(44.0, 96.0);

        if (_currentGame == 'counting' || _currentGame == 'counting_objects') {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentNumber.toString(),
                style: TextStyle(
                  fontSize: bigNumberSize,
                  fontWeight: FontWeight.bold,
                  color: contrastColor,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNumberButton(context, _currentNumber - 1),
                  const SizedBox(width: 14),
                  _buildNumberButton(context, _currentNumber),
                  const SizedBox(width: 14),
                  _buildNumberButton(context, _currentNumber + 1),
                ],
              ),
            ],
          );
        }

        if (_currentGame == 'addition') {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentQuestion ?? '',
                style: TextStyle(
                  fontSize: questionSize,
                  fontWeight: FontWeight.bold,
                  color: contrastColor,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children:
                _options.map((answer) => _buildAnswerButton(context, answer)).toList(),
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildNumberButton(BuildContext context, int number) {
    final contrastColor = AccessibilityUtils.getContrastColor(context);
    final buttonSize = AccessibilityUtils.getButtonSize(context);

    final double box = (86 * buttonSize).clamp(58.0, 92.0);
    final double text = (36 * buttonSize).clamp(20.0, 42.0);

    Color bgColor = const Color(0xFF2196F3);

    if (_selectedAnswer == number) {
      bgColor = _isCorrect ? const Color(0xFF4CAF50) : Colors.red;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(number),
      child: Container(
        width: box,
        height: box,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: contrastColor, width: 3),
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
              fontSize: text,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(BuildContext context, int answer) {
    final contrastColor = AccessibilityUtils.getContrastColor(context);
    final buttonSize = AccessibilityUtils.getButtonSize(context);

    final double box = (98 * buttonSize).clamp(64.0, 110.0);
    final double text = (36 * buttonSize).clamp(22.0, 44.0);

    Color bgColor = const Color(0xFF2196F3);

    if (_selectedAnswer == answer) {
      bgColor = _isCorrect ? const Color(0xFF4CAF50) : Colors.red;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(answer),
      child: Container(
        width: box,
        height: box,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: contrastColor, width: 3),
        ),
        child: Center(
          child: Text(
            answer.toString(),
            style: TextStyle(
              fontSize: text,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
