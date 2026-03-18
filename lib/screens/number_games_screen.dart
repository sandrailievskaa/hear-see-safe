import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';

/// Аудио-визуелни игри со броеви за деца со оштетен вид:
/// 1) Препознавање на број – цел екран, висок контраст, TTS го изговара, внес преку тастатура/паднастатура, поени.
/// 2) Операции – TTS ја чита целата задача (на пр. 3+2=?), ученикот внесува одговор.
/// 3) Броење предмети – приказ на облици/предмети, внес на избројаната количина (за остаток на вид).
class NumberGamesScreen extends StatefulWidget {
  const NumberGamesScreen({super.key});

  @override
  State<NumberGamesScreen> createState() => _NumberGamesScreenState();
}

class _NumberGamesScreenState extends State<NumberGamesScreen> {
  late VoiceAssistantService _voiceAssistant;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  String _currentGame = 'recognize';
  int _score = 0;
  int _totalAsked = 0;

  // Recognize mode: number to guess
  int _displayNumber = 0;

  // Operations: a op b = ?
  int _opA = 0, _opB = 0;
  bool _isAddition = true;
  int get _correctOpAnswer => _isAddition ? _opA + _opB : _opA - _opB;

  // Count objects: how many shapes
  int _shapeCount = 0;
  String _shapeType = 'circle'; // circle, square, star

  @override
  void initState() {
    super.initState();
    _voiceAssistant =
        Provider.of<VoiceAssistantService>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickNewQuestion();
      _announceModeAndQuestion();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  String get _langCode => context.locale.languageCode;

  void _pickNewQuestion() {
    setState(() {
      _inputController.clear();
      if (_currentGame == 'recognize') {
        _displayNumber = 1 + (_totalAsked % 10);
      } else if (_currentGame == 'operations') {
        _opA = 1 + (_totalAsked % 9);
        _opB = 1 + ((_totalAsked * 3) % 5);
        _isAddition = _totalAsked % 2 == 0;
        if (!_isAddition && _opA < _opB) {
          final t = _opA;
          _opA = _opB;
          _opB = t;
        }
      } else {
        _shapeCount = 1 + (_totalAsked % 8);
        final types = ['circle', 'square', 'star'];
        _shapeType = types[_totalAsked % 3];
      }
    });
  }

  Future<void> _announceModeAndQuestion() async {
    if (_currentGame == 'recognize') {
      await _voiceAssistant.speakWithLanguage(
        'number_games.number'.tr(args: [_displayNumber.toString()]),
        _langCode,
        vibrate: false,
      );
      await Future.delayed(const Duration(milliseconds: 500));
      await _voiceAssistant.speakWithLanguage(
        'number_games.what_number'.tr(),
        _langCode,
        vibrate: false,
      );
    } else if (_currentGame == 'operations') {
      final text = _isAddition
          ? 'number_games.equals'.tr(args: [_opA.toString(), _opB.toString()])
          : 'number_games.equals_subtract'.tr(args: [_opA.toString(), _opB.toString()]);
      await _voiceAssistant.speakWithLanguage(text, _langCode, vibrate: false);
      await Future.delayed(const Duration(milliseconds: 300));
      await _voiceAssistant.speakWithLanguage(
        'number_games.enter_number'.tr(),
        _langCode,
        vibrate: false,
      );
    } else {
      await _voiceAssistant.speakWithLanguage(
        'number_games.how_many_shapes'.tr(),
        _langCode,
        vibrate: false,
      );
      // За слепи деца: гласовно најавување колку облици има, за да можат да внесат број.
      final shapeLabel = 'number_games.shapes_$_shapeType'.tr();
      await Future.delayed(const Duration(milliseconds: 600));
      await _voiceAssistant.speakWithLanguage(
        'number_games.objects_announce'.tr(args: [_shapeCount.toString(), shapeLabel]),
        _langCode,
        vibrate: false,
      );
    }
  }

  int? _getCorrectAnswer() {
    if (_currentGame == 'recognize') return _displayNumber;
    if (_currentGame == 'operations') return _correctOpAnswer;
    return _shapeCount;
  }

  Future<void> _submitAnswer() async {
    final raw = _inputController.text.trim();
    if (raw.isEmpty) return;
    final parsed = int.tryParse(raw);
    if (parsed == null) return;

    final correct = _getCorrectAnswer()!;
    final isCorrect = parsed == correct;

    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: isCorrect ? 200 : 100);
    }

    if (isCorrect) {
      setState(() {
        _score++;
        _totalAsked++;
      });
      await _voiceAssistant.speakWithLanguage(
        'number_games.correct'.tr(),
        _langCode,
        vibrate: false,
      );
      final scoreMsg = 'number_games.score_announce'.tr(args: [_score.toString()]);
      await _voiceAssistant.speakWithLanguage(scoreMsg, _langCode, vibrate: false);
      _pickNewQuestion();
      if (mounted) _announceModeAndQuestion();
    } else {
      await _voiceAssistant.speakWithLanguage(
        'number_games.incorrect'.tr(),
        _langCode,
        vibrate: false,
      );
      setState(() => _inputController.clear());
    }
  }

  void _appendDigit(String digit) {
    final now = _inputController.text;
    if (now.length >= 3) return;
    setState(() => _inputController.text = now + digit);
  }

  void _clearInput() {
    setState(() => _inputController.clear());
  }

  void _switchGame(String game) {
    setState(() {
      _currentGame = game;
      _score = 0;
      _totalAsked = 0;
      _inputController.clear();
    });
    _pickNewQuestion();
    _announceModeAndQuestion();
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
          'number_games.title'.tr().isNotEmpty
              ? 'number_games.title'.tr()
              : 'features.number_games'.tr(),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: _gameChip(context, 'recognize', 'number_games.counting'.tr(), contrastColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _gameChip(context, 'operations', 'number_games.addition'.tr(), contrastColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _gameChip(context, 'count_objects', 'number_games.objects'.tr(), contrastColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'number_games.score'.tr(args: [_score.toString()]),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: contrastColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildMainContent(context, backgroundColor, contrastColor),
            ),
            _buildNumberPad(context, contrastColor),
            _buildInputRow(context, contrastColor),
          ],
        ),
      ),
    );
  }

  Widget _gameChip(BuildContext context, String game, String label, Color contrastColor) {
    final isActive = _currentGame == game;
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: isActive ? const Color(0xFF2196F3) : Colors.grey.shade600,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _switchGame(game),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, Color backgroundColor, Color contrastColor) {
    if (_currentGame == 'recognize') {
      return _buildRecognizeView(contrastColor);
    }
    if (_currentGame == 'operations') {
      return _buildOperationsView(contrastColor);
    }
    return _buildCountObjectsView(backgroundColor, contrastColor);
  }

  Widget _buildRecognizeView(Color contrastColor) {
    final size = MediaQuery.of(context).size;
    final numberSize = (size.height * 0.28).clamp(100.0, 220.0);
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: contrastColor, width: 4),
        ),
        child: Center(
          child: Text(
            _displayNumber.toString(),
            style: TextStyle(
              fontSize: numberSize,
              fontWeight: FontWeight.bold,
              color: contrastColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperationsView(Color contrastColor) {
    final opText = _isAddition ? '$_opA + $_opB = ?' : '$_opA − $_opB = ?';
    final size = MediaQuery.of(context).size;
    final textSize = (size.height * 0.12).clamp(48.0, 120.0);
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: contrastColor, width: 4),
        ),
        child: Center(
          child: Text(
            opText,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.bold,
              color: contrastColor,
            ),
          ),
        ),
      ),
    );
  }

  static Color get backgroundColor => const Color(0xFFFFFFFF);

  Widget _buildCountObjectsView(Color bgColor, Color contrastColor) {
    const double shapeSize = 56;
    final count = _shapeCount.clamp(1, 12);
    final perRow = count <= 4 ? count : (count <= 6 ? 3 : 4);
    final rows = <Widget>[];
    int placed = 0;
    while (placed < count) {
      final rowChildren = <Widget>[];
      for (int i = 0; i < perRow && placed < count; i++, placed++) {
        rowChildren.add(_buildShape(shapeSize, contrastColor));
        if (i < perRow - 1 && placed < count) rowChildren.add(const SizedBox(width: 16));
      }
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: rowChildren,
      ));
      if (placed < count) rows.add(const SizedBox(height: 16));
    }
    final shapeLabel = 'number_games.shapes_$_shapeType'.tr();
    final announceLabel = 'number_games.objects_announce'.tr(args: [_shapeCount.toString(), shapeLabel]);
    return Semantics(
      label: announceLabel,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: contrastColor, width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: rows,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShape(double size, Color color) {
    Widget child;
    if (_shapeType == 'square') {
      child = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          border: Border.all(color: color, width: 4),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    } else if (_shapeType == 'star') {
      child = CustomPaint(
        size: Size(size, size),
        painter: _StarPainter(color: color),
      );
    } else {
      child = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 4),
        ),
      );
    }
    return Semantics(
      label: 'number_games.shapes_$_shapeType'.tr(),
      child: child,
    );
  }

  Widget _buildNumberPad(BuildContext context, Color contrastColor) {
    const digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: digits.map((d) => _digitButton(d, contrastColor)).toList(),
      ),
    );
  }

  Widget _digitButton(String digit, Color contrastColor) {
    return Semantics(
      label: digit,
      button: true,
      child: SizedBox(
        width: 64,
        height: 56,
        child: ElevatedButton(
          onPressed: () => _appendDigit(digit),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          child: Text(digit),
        ),
      ),
    );
  }

  Widget _buildInputRow(BuildContext context, Color contrastColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Semantics(
              label: 'number_games.enter_number'.tr(),
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 3,
                onSubmitted: (_) => _submitAnswer(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: contrastColor,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: contrastColor, width: 3),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label: 'number_games.clear'.tr(),
            button: true,
            child: SizedBox(
              width: 100,
              height: 56,
              child: ElevatedButton(
                onPressed: _clearInput,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  foregroundColor: Colors.white,
                ),
                child: Text('number_games.clear'.tr()),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label: 'number_games.submit'.tr(),
            button: true,
            child: SizedBox(
              width: 100,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text('number_games.submit'.tr()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;

  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width * 0.45;
    final inner = size.width * 0.2;
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = (i * 36 - 90) * math.pi / 180;
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color.withOpacity(0.3));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}