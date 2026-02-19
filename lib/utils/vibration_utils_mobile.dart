import 'package:vibration/vibration.dart';

Future<bool> hasVibratorMobile() async {
  return await Vibration.hasVibrator() ?? false;
}

Future<void> vibrateMobile({int? duration, List<int>? pattern}) async {
  if (pattern != null) {
    await Vibration.vibrate(pattern: pattern);
  } else {
    await Vibration.vibrate(duration: duration ?? 100);
  }
}

