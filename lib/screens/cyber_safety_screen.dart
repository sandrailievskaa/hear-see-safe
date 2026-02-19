import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';

class CyberSafetyScreen extends StatefulWidget {
  const CyberSafetyScreen({super.key});

  @override
  State<CyberSafetyScreen> createState() => _CyberSafetyScreenState();
}

class _CyberSafetyScreenState extends State<CyberSafetyScreen> {
  late VoiceAssistantService _voiceAssistant;
  int _currentQuestion = 0;
  int? _selectedAnswer;
  int _score = 0;

  final List<CyberSafetyQuestion> _questions = [
    CyberSafetyQuestion(
      question: 'cyber.question1'.tr(),
      options: [
        'cyber.option1a'.tr(),
        'cyber.option1b'.tr(),
        'cyber.option1c'.tr(),
      ],
      correctAnswer: 0,
      explanation: 'cyber.explanation1'.tr(),
    ),
    CyberSafetyQuestion(
      question: 'cyber.question2'.tr(),
      options: [
        'cyber.option2a'.tr(),
        'cyber.option2b'.tr(),
        'cyber.option2c'.tr(),
      ],
      correctAnswer: 1,
      explanation: 'cyber.explanation2'.tr(),
    ),
    CyberSafetyQuestion(
      question: 'cyber.question3'.tr(),
      options: [
        'cyber.option3a'.tr(),
        'cyber.option3b'.tr(),
        'cyber.option3c'.tr(),
      ],
      correctAnswer: 0,
      explanation: 'cyber.explanation3'.tr(),
    ),
    CyberSafetyQuestion(
      question: 'cyber.question4'.tr(),
      options: [
        'cyber.option4a'.tr(),
        'cyber.option4b'.tr(),
        'cyber.option4c'.tr(),
      ],
      correctAnswer: 1,
      explanation: 'cyber.explanation4'.tr(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _voiceAssistant = Provider.of<VoiceAssistantService>(context, listen: false);
    _announceQuestion();
  }

  Future<void> _announceQuestion() async {
    if (_currentQuestion < _questions.length) {
      final q = _questions[_currentQuestion];
      await _voiceAssistant.speak(q.question);
      await Future.delayed(const Duration(milliseconds: 500));
      for (int i = 0; i < q.options.length; i++) {
        await _voiceAssistant.speak('${i + 1}. ${q.options[i]}');
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  Future<void> _selectAnswer(int answerIndex) async {
    if (_selectedAnswer != null) return;

    setState(() {
      _selectedAnswer = answerIndex;
    });

    final q = _questions[_currentQuestion];
    final isCorrect = answerIndex == q.correctAnswer;

    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: isCorrect ? 200 : 100);
    }

    if (isCorrect) {
      setState(() {
        _score++;
      });
      await _voiceAssistant.speak('cyber.correct'.tr());
    } else {
      await _voiceAssistant.speak('cyber.incorrect'.tr());
    }

    await Future.delayed(const Duration(milliseconds: 500));
    await _voiceAssistant.speak(q.explanation);
    await Future.delayed(const Duration(seconds: 3));

    _nextQuestion();
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
      });
      _announceQuestion();
    } else {
      _showResults();
    }
  }

  Future<void> _showResults() async {
    await _voiceAssistant.speak('cyber.results'.tr(args: [
      _score.toString(),
      _questions.length.toString(),
    ]));
  }

  void _restart() {
    setState(() {
      _currentQuestion = 0;
      _selectedAnswer = null;
      _score = 0;
    });
    _announceQuestion();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Colors.white;
    const contrastColor = Colors.black;

    if (_currentQuestion >= _questions.length) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            'features.cyber_safety'.tr(),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          backgroundColor: const Color(0xFF2196F3),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'cyber.results_title'.tr(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'cyber.score'.tr(args: [
                    _score.toString(),
                    _questions.length.toString(),
                  ]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 70, // зголемена висина за wrap текст
                  child: ElevatedButton.icon(
                    onPressed: _restart,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'cyber.restart'.tr(),
                      textAlign: TextAlign.center,
                      softWrap: true, // текстот може да продолжи во втор ред
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = _questions[_currentQuestion];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'features.cyber_safety'.tr(),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'cyber.progress'.tr(args: [
                  (_currentQuestion + 1).toString(),
                  _questions.length.toString(),
                ]),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      question.question,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ...question.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = _selectedAnswer == index;
                      final isCorrect = index == question.correctAnswer;
                      Color? buttonColor;

                      if (_selectedAnswer != null) {
                        if (isCorrect) {
                          buttonColor = const Color(0xFF4CAF50);
                        } else if (isSelected && !isCorrect) {
                          buttonColor = Colors.red;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 70, // зголемена висина за wrap текст
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                            ),
                            onPressed: () => _selectAnswer(index),
                            child: Text(
                              option,
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CyberSafetyQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  CyberSafetyQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}
