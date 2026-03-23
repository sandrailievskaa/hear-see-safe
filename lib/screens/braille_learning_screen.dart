import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';

/// Модул за родители: учење на брајова азбука за поддршка на слепи деца.
/// Едноставен приказ на букви и броеви со брајова нотација.
class BrailleLearningScreen extends StatefulWidget {
  const BrailleLearningScreen({super.key});

  @override
  State<BrailleLearningScreen> createState() => _BrailleLearningScreenState();
}

class _BrailleLearningScreenState extends State<BrailleLearningScreen> {
  late VoiceAssistantService _voiceAssistant;

  /// Braille dot positions: 1 4
  ///                       2 5
  ///                       3 6
  static const Map<String, List<int>> _brailleLetters = {
    'A': [1], 'B': [1, 2], 'C': [1, 4], 'D': [1, 4, 5], 'E': [1, 5],
    'F': [1, 2, 4], 'G': [1, 2, 4, 5], 'H': [1, 2, 5], 'I': [2, 4], 'J': [2, 4, 5],
    'K': [1, 3], 'L': [1, 2, 3], 'M': [1, 3, 4], 'N': [1, 3, 4, 5], 'O': [1, 3, 5],
    'P': [1, 2, 3, 4], 'Q': [1, 2, 3, 4, 5], 'R': [1, 2, 3, 5], 'S': [2, 3, 4], 'T': [2, 3, 4, 5],
    'U': [1, 3, 6], 'V': [1, 2, 3, 6], 'W': [2, 4, 5, 6], 'X': [1, 3, 4, 6], 'Y': [1, 3, 4, 5, 6], 'Z': [1, 3, 5, 6],
  };

  static const Map<String, List<int>> _brailleNumbers = {
    '0': [2, 4, 5],  // same as J
    '1': [1], '2': [1, 2], '3': [1, 4], '4': [1, 4, 5], '5': [1, 5],
    '6': [1, 2, 4], '7': [1, 2, 4, 5], '8': [1, 2, 5], '9': [2, 4],
  };

  String get _langCode => context.locale.languageCode;

  @override
  void initState() {
    super.initState();
    _voiceAssistant = Provider.of<VoiceAssistantService>(context, listen: false);
    _voiceAssistant.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) => _announceIntro());
  }

  Future<void> _announceIntro() async {
    if (!mounted) return;
    await _voiceAssistant.speakWithLanguage(
      'braille.intro'.tr(),
      _langCode,
      vibrate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = AccessibilityUtils.getBackgroundColor(context);
    final contrast = AccessibilityUtils.getContrastColor(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          'braille.title'.tr(),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: contrast),
        ),
        backgroundColor: AccessibilityUtils.getAppBarBackgroundColor(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'braille.for_parents'.tr(),
                style: TextStyle(fontSize: 18, color: contrast),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'braille.letters'.tr(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: contrast),
              ),
              const SizedBox(height: 12),
              _buildBrailleGrid(_brailleLetters, contrast),
              const SizedBox(height: 24),
              Text(
                'braille.numbers'.tr(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: contrast),
              ),
              const SizedBox(height: 12),
              _buildBrailleGrid(_brailleNumbers, contrast),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrailleGrid(Map<String, List<int>> items, Color contrast) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: items.entries.map((e) => _BrailleCell(
        character: e.key,
        dots: e.value,
        contrastColor: contrast,
        onTap: () => _speakCharacter(e.key),
      )).toList(),
    );
  }

  void _speakCharacter(String char) {
    final isDigit = char.length == 1 && int.tryParse(char) != null;
    final key = isDigit ? 'braille.num_$char' : 'braille.letter_$char';
    final text = key.tr();
    _voiceAssistant.speakWithLanguage(text, _langCode, vibrate: false);
    AccessibilityUtils.provideFeedback(context: context);
  }
}

class _BrailleCell extends StatelessWidget {
  final String character;
  final List<int> dots;
  final Color contrastColor;
  final VoidCallback onTap;

  const _BrailleCell({
    required this.character,
    required this.dots,
    required this.contrastColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = AccessibilityUtils.getButtonSize(context);

    return Semantics(
      label: 'braille.cell'.tr(args: [character]),
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 72 * buttonSize,
            padding: EdgeInsets.all(12 * buttonSize),
            decoration: BoxDecoration(
              border: Border.all(color: contrastColor, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  character,
                  style: TextStyle(
                    fontSize: 28 * buttonSize,
                    fontWeight: FontWeight.bold,
                    color: contrastColor,
                  ),
                ),
                const SizedBox(height: 8),
                _BrailleDots(dots: dots, contrastColor: contrastColor, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Braille cell: dots 1,2,3 left column; 4,5,6 right column
class _BrailleDots extends StatelessWidget {
  final List<int> dots;
  final Color contrastColor;
  final double size;

  const _BrailleDots({required this.dots, required this.contrastColor, this.size = 24});

  bool _isRaised(int dot) => dots.contains(dot);

  @override
  Widget build(BuildContext context) {
    final dotSize = size * 0.32;
    final gap = size * 0.12;
    const layout = [
      [1, 4],
      [2, 5],
      [3, 6],
    ];

    return SizedBox(
      width: size,
      height: size * 1.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var r = 0; r < 3; r++) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(raised: _isRaised(layout[r][0]), color: contrastColor, size: dotSize),
                SizedBox(width: gap),
                _Dot(raised: _isRaised(layout[r][1]), color: contrastColor, size: dotSize),
              ],
            ),
            if (r < 2) SizedBox(height: gap),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool raised;
  final Color color;
  final double size;

  const _Dot({required this.raised, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: raised ? color : color.withValues(alpha: 0.2),
        border: Border.all(color: color, width: raised ? 1.5 : 1),
      ),
    );
  }
}
