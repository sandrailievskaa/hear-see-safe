import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hear_and_see_safe/providers/accessibility_provider.dart';
import 'package:hear_and_see_safe/providers/app_state_provider.dart';
import 'package:hear_and_see_safe/services/voice_assistant_service.dart';
import 'package:hear_and_see_safe/utils/vibration_utils.dart';

class AccessibilityUtils {
  static double getTextScale(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context, listen: false);
    return accessibilityProvider.textScale;
  }

  static Color getContrastColor(BuildContext context, {Color? lightColor, Color? darkColor}) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context, listen: false);
    final isHighContrast = accessibilityProvider.highContrastMode;

    if (isHighContrast) {
      return darkColor ?? const Color(0xFF000000);
    }
    return lightColor ?? const Color(0xFF212121);
  }

  static Color getBackgroundColor(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context, listen: false);
    final isHighContrast = accessibilityProvider.highContrastMode;

    if (isHighContrast) {
      return const Color(0xFFFFFFFF);
    }
    return const Color(0xFFF5F5F5);
  }

  static double getButtonSize(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context, listen: false);
    return accessibilityProvider.buttonSize;
  }

  static Future<void> provideFeedback({
    required BuildContext context,
    bool vibrate = true,
    String? audioFeedback,
    VoiceAssistantService? voiceAssistant,
  }) async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    if (vibrate && appState.vibrationEnabled) {
      if (await VibrationUtils.hasVibrator()) {
        await VibrationUtils.vibrate(duration: 100);
      }
    }

    if (audioFeedback != null && voiceAssistant != null && appState.isVoiceAssistantEnabled) {
      await voiceAssistant.speak(audioFeedback, vibrate: false);
    }
  }

  static Widget buildAccessibleButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double? height,
  }) {
    final buttonSize = getButtonSize(context);
    final contrastColor = getContrastColor(context, darkColor: textColor);
    final bgColor = backgroundColor ?? const Color(0xFF2196F3);

    return SizedBox(
      width: width != null ? width * buttonSize : 200 * buttonSize,
      height: height != null ? height * buttonSize : 60 * buttonSize,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: contrastColor,
          textStyle: TextStyle(
            fontSize: 20 * buttonSize,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: contrastColor,
              width: 2,
            ),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size:  buttonSize),
              const SizedBox(width: 8),
            ],
            Text(text),
          ],
        ),
      ),
    );
  }
}

