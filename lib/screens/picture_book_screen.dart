import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';
import 'package:audioplayers/audioplayers.dart';

/// Мултимедијална сликовница за слабовиди (модул „Учи и Слушај“).
/// - Големи едноставни слики (емоџи); при допир: звук + вибрација.
/// - Листање: лизгање лево/десно или 2 тапа (следна) / 3 тапа (претходна).
/// - Целосна аудио-нарација за слепи; по секој звук се чита образовен факт.
/// - Едукативен карактер за деца и младинци до ~15 год. (природа, безбедност, здравје, комуникација).

class PictureBookScreen extends StatefulWidget {
  const PictureBookScreen({super.key});

  @override
  State<PictureBookScreen> createState() => _PictureBookScreenState();
}

class _PictureBookScreenState extends State<PictureBookScreen> {
  late VoiceAssistantService _voiceAssistant;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _currentIndex = 0;
  bool _isHelpDialogOpen = false;

  /// Tap counter for double/triple tap navigation (2 taps = next, 3 taps = prev)
  int _tapCount = 0;
  Timer? _tapTimer;
  static const _tapTimeout = Duration(milliseconds: 400);

  /// When sound finishes, this completer is completed so we can speak the learning fact.
  Completer<void>? _soundCompleteCompleter;
  StreamSubscription? _playerCompleteSub;

  final List<PictureBookItem> _items = [
    PictureBookItem(
      nameKey: 'picture_book.cat',
      descriptionKey: 'picture_book.cat_desc',
      learnKey: 'picture_book.cat_learn',
      learn2Key: 'picture_book.cat_learn2',
      emoji: '🐱',
      soundAsset: 'assets/sounds/meow.mp3',
    ),
    PictureBookItem(
      nameKey: 'picture_book.dog',
      descriptionKey: 'picture_book.dog_desc',
      learnKey: 'picture_book.dog_learn',
      emoji: '🐶',
      soundAsset: 'assets/sounds/bark.mp3',
    ),
    PictureBookItem(
      nameKey: 'picture_book.car',
      descriptionKey: 'picture_book.car_desc',
      learnKey: 'picture_book.car_learn',
      emoji: '🚗',
      soundAsset: 'assets/sounds/car.mp3',
    ),
    PictureBookItem(
      nameKey: 'picture_book.rain',
      descriptionKey: 'picture_book.rain_desc',
      learnKey: 'picture_book.rain_learn',
      emoji: '🌧️',
      soundAsset: 'assets/sounds/rain.mp3',
    ),
    PictureBookItem(
      nameKey: 'picture_book.sun',
      descriptionKey: 'picture_book.sun_desc',
      learnKey: 'picture_book.sun_learn',
      emoji: '☀️',
      soundAsset: 'assets/sounds/sun.mp3',
    ),
    PictureBookItem(
      nameKey: 'picture_book.tree',
      descriptionKey: 'picture_book.tree_desc',
      learnKey: 'picture_book.tree_learn',
      emoji: '🌳',
      soundAsset: 'assets/sounds/wind.mp3',
    ),
    PictureBookItem(
      nameKey: 'picture_book.bicycle',
      descriptionKey: 'picture_book.bicycle_desc',
      learnKey: 'picture_book.bicycle_learn',
      emoji: '🚲',
      soundAsset: 'assets/sounds/car.mp3',
    ),
    PictureBookItem(
      nameKey: 'picture_book.water',
      descriptionKey: 'picture_book.water_desc',
      learnKey: 'picture_book.water_learn',
      learn2Key: 'picture_book.water_learn2',
      emoji: '💧',
      soundAsset: 'assets/sounds/rain.mp3',
    ),
    PictureBookItem(
      nameKey: 'picture_book.book',
      descriptionKey: 'picture_book.book_desc',
      learnKey: 'picture_book.book_learn',
      emoji: '📖',
      soundAsset: 'assets/sounds/wind.mp3',
    ),
    PictureBookItem(
      nameKey: 'picture_book.fire',
      descriptionKey: 'picture_book.fire_desc',
      learnKey: 'picture_book.fire_learn',
      learn2Key: 'picture_book.fire_learn2',
      emoji: '🔥',
      soundAsset: 'assets/sounds/rain.mp3',
    ),
    PictureBookItem(
      nameKey: 'picture_book.phone',
      descriptionKey: 'picture_book.phone_desc',
      learnKey: 'picture_book.phone_learn',
      learn2Key: 'picture_book.phone_learn2',
      emoji: '📱',
      soundAsset: 'assets/sounds/rain.mp3',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _voiceAssistant =
        Provider.of<VoiceAssistantService>(context, listen: false);

    _playerCompleteSub = _audioPlayer.onPlayerComplete.listen((_) {
      if (_soundCompleteCompleter != null && !_soundCompleteCompleter!.isCompleted) {
        _soundCompleteCompleter!.complete();
      }
      _soundCompleteCompleter = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final intro = 'picture_book.intro'.tr();
      if (intro.isNotEmpty) {
        await _voiceAssistant.speakWithLanguage(intro, _langCode);
      }
      await _announceCurrentItem();
    });
  }

  String get _langCode => context.locale.languageCode;

  Future<void> _announceCurrentItem() async {
    final item = _items[_currentIndex];
    final name = item.nameKey.tr();
    final description = item.descriptionKey.tr();
    final learn = item.learnKey.tr();
    final pageInfo = '${_currentIndex + 1} ${'picture_book.of'.tr()} ${_items.length}. ';
    await _voiceAssistant.speakWithLanguage(
      '$pageInfo $name. $description. $learn',
      _langCode,
    );
  }

  /// Long press: repeat full page + optional extra fact (for blind users to hear again).
  Future<void> _repeatCurrentPage() async {
    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: 100);
    }
    final item = _items[_currentIndex];
    final name = item.nameKey.tr();
    final description = item.descriptionKey.tr();
    final learn = item.learnKey.tr();
    final pageInfo = '${_currentIndex + 1} ${'picture_book.of'.tr()} ${_items.length}. ';
    await _voiceAssistant.speakWithLanguage(
      '$pageInfo $name. $description. $learn',
      _langCode,
      vibrate: false,
    );
    if (item.learn2Key != null) {
      final remember = 'picture_book.remember'.tr();
      final learn2 = item.learn2Key!.tr();
      if (remember.isNotEmpty && learn2.isNotEmpty) {
        await _voiceAssistant.speakWithLanguage(
          '$remember $learn2',
          _langCode,
          vibrate: false,
        );
      }
    }
  }

  Future<void> _speakIntro() async {
    final intro = 'picture_book.intro'.tr();
    final helpTitle = 'picture_book.help'.tr().isNotEmpty ? 'picture_book.help'.tr() : 'Help';

    // Ensure the tap always has visible feedback (even if voice output isn't available).
    if (mounted && !_isHelpDialogOpen) {
      _isHelpDialogOpen = true;
      if (intro.isNotEmpty) {
        // Start speaking, but don't block the UI with it.
        unawaited(_voiceAssistant.speakWithLanguage(intro, _langCode, vibrate: false));
      }

      try {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) {
            final content = intro.isNotEmpty ? intro : helpTitle;
            return AlertDialog(
              title: Text(
                helpTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Text(
                  content,
                  textAlign: TextAlign.center,
                ),
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('OK'),
                  ),
                ),
              ],
            );
          },
        );
      } finally {
        if (mounted) _isHelpDialogOpen = false;
      }
    } else {
      // If dialog is already open, just try speaking again.
      if (intro.isNotEmpty) {
        try {
          await _voiceAssistant.speakWithLanguage(intro, _langCode, vibrate: false);
        } catch (_) {}
      }
    }
  }

  Future<void> _handleTap() async {
    final item = _items[_currentIndex];
    final name = item.nameKey.tr();
    final learn = item.learnKey.tr();

    if (await VibrationUtils.hasVibrator()) {
      await VibrationUtils.vibrate(duration: 200);
    }

    await _voiceAssistant.speakWithLanguage(name, _langCode, vibrate: false);
    await _playSoundEffect(item.soundAsset);
    if (!mounted) return;
    final learnPrompt = 'picture_book.learn_prompt'.tr();
    final learnText = learnPrompt.isNotEmpty ? '$learnPrompt $learn' : learn;
    await _voiceAssistant.speakWithLanguage(learnText, _langCode, vibrate: false);
  }

  void _handleMultiTap() {
    _tapCount++;
    _tapTimer?.cancel();
    _tapTimer = Timer(_tapTimeout, () {
      if (_tapCount == 1) {
        _handleTap();
      } else if (_tapCount == 2) {
        _next();
      } else if (_tapCount >= 3) {
        _prev();
      }
      _tapCount = 0;
    });
  }

  /// Returns a Future that completes when the sound finishes playing.
  /// Used so we can speak the learning fact after the sound (for blind users).
  Future<void> _playSoundEffect(String assetPath) async {
    _soundCompleteCompleter = Completer<void>();
    try {
      final relative = assetPath.startsWith('assets/')
          ? assetPath.substring('assets/'.length)
          : assetPath;
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(relative));
      await _soundCompleteCompleter!.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          if (_soundCompleteCompleter != null && !_soundCompleteCompleter!.isCompleted) {
            _soundCompleteCompleter!.complete();
          }
        },
      );
    } catch (_) {
      if (_soundCompleteCompleter != null && !_soundCompleteCompleter!.isCompleted) {
        _soundCompleteCompleter!.complete();
      }
    } finally {
      _soundCompleteCompleter = null;
    }
  }

  Future<void> _navigateToItem(int index, {bool isNext = true}) async {
    if (index < 0 || index >= _items.length) return;
    final prevIndex = _currentIndex;
    final wrappedFromLast = isNext && prevIndex == _items.length - 1 && index == 0;

    setState(() => _currentIndex = index);
    AccessibilityUtils.provideFeedback(context: context);

    if (wrappedFromLast) {
      final endOfBook = 'picture_book.end_of_book'.tr();
      if (endOfBook.isNotEmpty) {
        await _voiceAssistant.speakWithLanguage(endOfBook, _langCode, vibrate: false);
      }
      if (!mounted) return;
    } else {
      final navLabel = isNext ? 'picture_book.next'.tr() : 'picture_book.previous'.tr();
      if (navLabel.isNotEmpty) {
        await _voiceAssistant.speakWithLanguage(navLabel, _langCode, vibrate: false);
      }
      if (!mounted) return;
    }

    if (index == 0) {
      final firstPage = 'picture_book.first_page'.tr();
      if (firstPage.isNotEmpty) {
        await _voiceAssistant.speakWithLanguage(firstPage, _langCode, vibrate: false);
      }
      if (!mounted) return;
    } else if (index == _items.length - 1) {
      final lastPage = 'picture_book.last_page'.tr();
      if (lastPage.isNotEmpty) {
        await _voiceAssistant.speakWithLanguage(lastPage, _langCode, vibrate: false);
      }
      if (!mounted) return;
    }

    await _announceCurrentItem();
  }

  void _next() => _navigateToItem((_currentIndex + 1) % _items.length, isNext: true);
  void _prev() =>
      _navigateToItem((_currentIndex - 1 + _items.length) % _items.length, isNext: false);

  @override
  void dispose() {
    _tapTimer?.cancel();
    _playerCompleteSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AccessibilityUtils.getBackgroundColor(context);
    final contrastColor = AccessibilityUtils.getContrastColor(context);
    final item = _items[_currentIndex];
    final name = item.nameKey.tr();
    final description = item.descriptionKey.tr();
    final learn = item.learnKey.tr();
    final hintNav = 'picture_book.hint_nav'.tr();
    final hintTap = 'picture_book.hint_tap'.tr();
    final longPressHint = 'picture_book.long_press_hint'.tr();
    final helpLabel = 'picture_book.help'.tr();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'picture_book.title'.tr().isNotEmpty
              ? 'picture_book.title'.tr()
              : 'features.picture_book'.tr(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        backgroundColor: AccessibilityUtils.getAppBarBackgroundColor(context),
        actions: [
          Semantics(
            label: helpLabel.isNotEmpty ? helpLabel : 'Help',
            button: true,
            child: IconButton(
              icon: Icon(Icons.help_outline, color: AccessibilityUtils.getPrimaryButtonForeground(context)),
              onPressed: _speakIntro,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _handleMultiTap,
                onLongPress: _repeatCurrentPage,
                onHorizontalDragEnd: (details) {
                  const threshold = 30.0;
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! < -threshold) {
                      _next();
                    } else if (details.primaryVelocity! > threshold) {
                      _prev();
                    }
                  }
                },
                child: Semantics(
                  label: '$name. $description. $learn. $hintTap $longPressHint $hintNav',
                  hint: hintTap,
                  button: true,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AccessibilityUtils.getPrimaryButtonForeground(context),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: contrastColor, width: 3),
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
                              (h * 0.28).clamp(120.0, 220.0);
                          final titleSize =
                              (w * 0.09).clamp(24.0, 36.0);
                          final descSize =
                              (w * 0.048).clamp(16.0, 20.0);
                          final learnSize =
                              (w * 0.042).clamp(14.0, 18.0);
                          final hintSize =
                              (w * 0.032).clamp(12.0, 16.0);

                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Semantics(
                                  label: name,
                                  child: Text(
                                    item.emoji,
                                    style: TextStyle(fontSize: emojiSize),
                                  ),
                                ),
                                const SizedBox(height: 16),
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
                                    color: contrastColor.withOpacity(0.85),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  learn,
                                  style: TextStyle(
                                    fontSize: learnSize,
                                    color: contrastColor.withOpacity(0.75),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                if (hintNav.isNotEmpty)
                                  Text(
                                    hintNav,
                                    style: TextStyle(
                                      fontSize: hintSize,
                                      color: contrastColor.withOpacity(0.75),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'picture_book.previous'.tr().isNotEmpty
                          ? 'picture_book.previous'.tr()
                          : '←',
                      button: true,
                      child: AccessibilityUtils.buildAccessibleButton(
                        context: context,
                        text: '←',
                        onPressed: _prev,
                        height: 64,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    child: Semantics(
                      label: 'picture_book.next'.tr().isNotEmpty
                          ? 'picture_book.next'.tr()
                          : '→',
                      button: true,
                      child: AccessibilityUtils.buildAccessibleButton(
                        context: context,
                        text: '→',
                        onPressed: _next,
                        height: 64,
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

class PictureBookItem {
  final String nameKey;
  final String descriptionKey;
  final String learnKey;
  final String? learn2Key;
  final String emoji;
  final String soundAsset;

  PictureBookItem({
    required this.nameKey,
    required this.descriptionKey,
    required this.learnKey,
    this.learn2Key,
    required this.emoji,
    required this.soundAsset,
  });
}
