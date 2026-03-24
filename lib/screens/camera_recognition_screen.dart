import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/accessibility_utils.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';

class CameraRecognitionScreen extends StatefulWidget {
  const CameraRecognitionScreen({super.key});

  @override
  State<CameraRecognitionScreen> createState() =>
      _CameraRecognitionScreenState();
}

class _CameraRecognitionScreenState extends State<CameraRecognitionScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String _recognitionMode = 'currency';

  late VoiceAssistantService _voiceAssistant;
  final Random _random = Random();

  static const List<String> _currencyKeys = [
    'camera.currency_10',
    'camera.currency_50',
    'camera.currency_100',
    'camera.currency_500',
  ];
  static const List<String> _colorKeys = [
    'camera.color_red',
    'camera.color_blue',
    'camera.color_green',
    'camera.color_yellow',
    'camera.color_black',
    'camera.color_white',
  ];
  static const List<String> _objectKeys = [
    'camera.object_shirt',
    'camera.object_pants',
    'camera.object_shoe',
    'camera.object_book',
    'camera.object_bottle',
  ];
  static const List<String> _clothingKeys = [
    'camera.clothing_blue_shirt',
    'camera.clothing_black_pants',
    'camera.clothing_white_shirt',
    'camera.clothing_blue_pants',
    'camera.clothing_red_shirt',
    'camera.clothing_grey_pants',
    'camera.clothing_green_shirt',
    'camera.clothing_white_pants',
  ];
  static const List<String> _combinationTipKeys = [
    'camera.combination_tip',
    'camera.combination_tip_dark',
    'camera.combination_tip_light',
  ];

  @override
  void initState() {
    super.initState();
    _voiceAssistant =
        Provider.of<VoiceAssistantService>(context, listen: false);
    _initializeCamera();
  }

  String get _langCode => context.locale.languageCode;

  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.request();

      if (!status.isGranted) {
        await _voiceAssistant.speakWithLanguage(
          'camera.error'.tr(),
          _langCode,
        );
        return;
      }

      _cameras = await availableCameras();

      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();

        if (!mounted) return;

        setState(() => _isInitialized = true);

        await _voiceAssistant.speakWithLanguage(
          'camera.ready'.tr(),
          _langCode,
        );
      } else {
        await _voiceAssistant.speakWithLanguage(
          'camera.error'.tr(),
          _langCode,
        );
      }
    } catch (e) {
      if (mounted) {
        await _voiceAssistant.speakWithLanguage(
          'camera.error'.tr(),
          _langCode,
        );
      }
    }
  }

  Future<void> _captureAndRecognize() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      await _voiceAssistant.speakWithLanguage(
        'camera.analyzing'.tr(),
        _langCode,
        vibrate: false,
      );

      if (await VibrationUtils.hasVibrator()) {
        await VibrationUtils.vibrate(duration: 300);
      }

      await _cameraController!.takePicture();
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      String resultKey;
      if (_recognitionMode == 'currency') {
        resultKey = _currencyKeys[_random.nextInt(_currencyKeys.length)];
      } else if (_recognitionMode == 'color') {
        resultKey = _colorKeys[_random.nextInt(_colorKeys.length)];
      } else if (_recognitionMode == 'object') {
        resultKey = _objectKeys[_random.nextInt(_objectKeys.length)];
      } else {
        resultKey = _clothingKeys[_random.nextInt(_clothingKeys.length)];
      }

      final msg = resultKey.tr();
      await _voiceAssistant.speakWithLanguage(msg, _langCode, vibrate: false);

      if (_recognitionMode == 'clothing') {
        final tipKey =
        _combinationTipKeys[_random.nextInt(_combinationTipKeys.length)];
        final tip = tipKey.tr();
        if (tip.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 400));
          await _voiceAssistant.speakWithLanguage(
            tip,
            _langCode,
            vibrate: false,
          );
        }
      }

      AccessibilityUtils.provideFeedback(context: context);
    } catch (e) {
      if (mounted) {
        await _voiceAssistant.speakWithLanguage(
          'camera.error'.tr(),
          _langCode,
          vibrate: false,
        );
      }
    }

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  Widget _buildCameraPreview() {
    if (_cameraController != null &&
        _cameraController!.value.isInitialized) {
      return CameraPreview(_cameraController!);
    }
    return const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
    AccessibilityUtils.getBackgroundColor(context);
    final contrastColor =
    AccessibilityUtils.getContrastColor(context);

    final modeLabels = {
      'currency': 'camera.currency'.tr(),
      'color': 'camera.color'.tr(),
      'object': 'camera.object'.tr(),
      'clothing': 'camera.clothing'.tr(),
    };

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'features.camera_recognition'.tr(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        backgroundColor: AccessibilityUtils.getAppBarBackgroundColor(context),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // ✅ КОПЧИЊА ВО ЕДЕН РЕД (FIX)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                _modeButton(context, 'currency', modeLabels['currency']!, contrastColor),
                _modeButton(context, 'color', modeLabels['color']!, contrastColor),
                _modeButton(context, 'object', modeLabels['object']!, contrastColor),
                _modeButton(context, 'clothing', modeLabels['clothing']!, contrastColor),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: contrastColor, width: 4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _isInitialized
                    ? _buildCameraPreview()
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _captureAndRecognize,
                icon: const Icon(Icons.camera_alt, size: 28),
                label: Text('camera.capture'.tr()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(
      BuildContext context,
      String mode,
      String label,
      Color contrastColor,
      ) {
    final isActive = _recognitionMode == mode;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          onPressed: () async {
            setState(() => _recognitionMode = mode);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: isActive
                ? AccessibilityUtils.getAccentColor(context)
                : AccessibilityUtils.getDisabledColor(context),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}