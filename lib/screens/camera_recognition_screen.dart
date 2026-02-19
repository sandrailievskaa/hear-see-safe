import 'package:flutter/material.dart';
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

class _CameraRecognitionScreenState
    extends State<CameraRecognitionScreen> {

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String _recognitionMode = 'currency';

  late VoiceAssistantService _voiceAssistant;

  @override
  void initState() {
    super.initState();
    _voiceAssistant =
        Provider.of<VoiceAssistantService>(context, listen: false);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.request();

      if (!status.isGranted) {
        await _voiceAssistant.speak("Camera permission denied");
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

        setState(() {
          _isInitialized = true;
        });

        await _voiceAssistant.speak('camera.ready'.tr());
      }
    } catch (e) {
      await _voiceAssistant.speak('camera.error'.tr());
    }
  }

  Future<void> _captureAndRecognize() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      await _voiceAssistant.speak('camera.analyzing'.tr());

      if (await VibrationUtils.hasVibrator()) {
        await VibrationUtils.vibrate(duration: 300);
      }

      final image = await _cameraController!.takePicture();

      // MOMENTALNO: симулација
      await Future.delayed(const Duration(seconds: 1));

      String result;
      if (_recognitionMode == 'currency') {
        result = "Detected 100 Denars";
      } else if (_recognitionMode == 'color') {
        result = "Detected Blue Color";
      } else {
        result = "Detected Object";
      }

      await _voiceAssistant.speak(result);
      AccessibilityUtils.provideFeedback(context: context);

    } catch (e) {
      await _voiceAssistant.speak('camera.error'.tr());
    }

    setState(() => _isProcessing = false);
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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'features.camera_recognition'.tr(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // MODE BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _modeButton('currency', 'Currency'),
              _modeButton('color', 'Color'),
              _modeButton('object', 'Object'),
            ],
          ),

          const SizedBox(height: 16),

          // CAMERA VIEW
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: contrastColor, width: 4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _isInitialized
                    ? _buildCameraPreview()
                    : const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // CAPTURE BUTTON
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton.icon(
              onPressed: _captureAndRecognize,
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                "Capture",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: const Color(0xFF2196F3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(String mode, String label) {
    final isActive = _recognitionMode == mode;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _recognitionMode = mode;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
        isActive ? const Color(0xFF2196F3) : Colors.grey,
      ),
      child: Text(label),
    );
  }
}
