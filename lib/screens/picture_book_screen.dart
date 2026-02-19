import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';
import 'package:audioplayers/audioplayers.dart';

class PictureBookScreen extends StatefulWidget {
  const PictureBookScreen({super.key});

  @override
  State<PictureBookScreen> createState() => _PictureBookScreenState();
}

class _PictureBookScreenState extends State<PictureBookScreen> {
  late VoiceAssistantService _voiceAssistant;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _currentIndex = 0;

  final List<PictureBookItem> _items = [
    PictureBookItem(
      nameKey: 'picture_book.cat',
      descriptionKey: 'picture_book.cat_desc',
      emoji: '🐱',
      soundAsset: 'assets/sounds/meow.mp3',
    ),
    PictureBookItem(
      nameKey: 'picture_book.dog',
      descriptionKey: 'picture_book.dog_desc',
      emoji: '🐶',
      soundAsset: 'assets/sounds/bark.mp3',
    ),
    PictureBookItem(
      nameKey: 'picture_book.car',
      descriptionKey: 'picture_book.car_desc',
      emoji: '🚗',
      soundAsset: 'assets/sounds/car.mp3',
    ),
    PictureBookItem(
      nameKey: 'picture_book.rain',
      descriptionKey: 'picture_book.rain_desc',
      emoji: '🌧️',
      soundAsset: 'assets/sounds/rain.mp3',
    ),
    PictureBookItem(
      nameKey: 'picture_book.sun',
      descriptionKey: 'picture_book.sun_desc',
      emoji: '☀️',
      soundAsset: 'assets/sounds/sun.mp3',
    ),
    PictureBookItem(
      nameKey: 'picture_book.tree',
      descriptionKey: 'picture_book.tree_desc',
      emoji: '🌳',
      soundAsset: 'assets/sounds/wind.mp3',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _voiceAssistant =
        Provider.of<VoiceAssistantService>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceCurrentItem();
    });
  }

  String get _langCode => context.locale.languageCode;

  Future<void> _announceCurrentItem() async {
    final item = _items[_currentIndex];
    final name = item.nameKey.tr();
    final description = item.descriptionKey.tr();

    await _voiceAssistant
        .speakWithLanguage('$name. $description', _langCode);
  }

  Future<void> _handleTap() async {
    final item = _items[_currentIndex];
    final name = item.nameKey.tr();

    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: 150);
    }

    await _voiceAssistant
        .speakWithLanguage(name, _langCode, vibrate: false);

    await _playSoundEffect(item.soundAsset);
  }

  Future<void> _playSoundEffect(String assetPath) async {
    try {
      final relative = assetPath.startsWith('assets/')
          ? assetPath.substring('assets/'.length)
          : assetPath;

      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(relative));
    } catch (_) {}
  }

  void _navigateToItem(int index) {
    if (index < 0 || index >= _items.length) return;

    setState(() {
      _currentIndex = index;
    });

    _announceCurrentItem();
    AccessibilityUtils.provideFeedback(context: context);
  }

  void _next() => _navigateToItem((_currentIndex + 1) % _items.length);
  void _prev() =>
      _navigateToItem((_currentIndex - 1 + _items.length) % _items.length);

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
    AccessibilityUtils.getBackgroundColor(context);
    final contrastColor =
    AccessibilityUtils.getContrastColor(context);

    final item = _items[_currentIndex];
    final name = item.nameKey.tr();
    final description = item.descriptionKey.tr();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'features.picture_book'.tr(),
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
            Expanded(
              child: GestureDetector(
                onTap: _handleTap,
                onDoubleTap: _next,
                onLongPress: _prev,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border:
                    Border.all(color: contrastColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: contrastColor.withOpacity(0.25),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final h = constraints.maxHeight;
                        final w = constraints.maxWidth;

                        final emojiSize =
                        (h * 0.26).clamp(80.0, 150.0);
                        final titleSize =
                        (w * 0.085).clamp(22.0, 32.0);
                        final descSize =
                        (w * 0.045).clamp(14.0, 18.0);

                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Text(item.emoji,
                                  style: TextStyle(
                                      fontSize: emojiSize)),
                              const SizedBox(height: 14),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.bold,
                                  color: contrastColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: descSize,
                                  color: contrastColor
                                      .withOpacity(0.75),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            /// 🔥 FIXED NAVIGATION BAR (NO OVERFLOW)
            Padding(
              padding:
              const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: AccessibilityUtils
                        .buildAccessibleButton(
                      context: context,
                      text: '←',
                      onPressed: _prev,
                      height: 64,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12),
                    child: FittedBox(
                      child: Text(
                        '${_currentIndex + 1} / ${_items.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: contrastColor,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: AccessibilityUtils
                        .buildAccessibleButton(
                      context: context,
                      text: '→',
                      onPressed: _next,
                      height: 64,
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

class PictureBookItem {
  final String nameKey;
  final String descriptionKey;
  final String emoji;
  final String soundAsset;

  PictureBookItem({
    required this.nameKey,
    required this.descriptionKey,
    required this.emoji,
    required this.soundAsset,
  });
}
