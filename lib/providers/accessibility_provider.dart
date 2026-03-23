import 'package:flutter/material.dart';

class AccessibilityProvider extends ChangeNotifier {
  bool _highContrastMode = false;
  // Default: "normal" sizes. Users can enable Large Text mode in Settings.
  bool _largeTextMode = false;
  double _textScale = 1.0;
  double _buttonSize = 1.0;

  bool get highContrastMode => _highContrastMode;
  bool get largeTextMode => _largeTextMode;
  double get textScale => _textScale;
  double get buttonSize => _buttonSize;

  void toggleHighContrast() {
    _highContrastMode = !_highContrastMode;
    notifyListeners();
  }

  void toggleLargeText() {
    _largeTextMode = !_largeTextMode;
    _textScale = _largeTextMode ? 1.2 : 1.0;
    _buttonSize = _largeTextMode ? 1.1 : 1.0;
    notifyListeners();
  }

  void setTextScale(double scale) {
    _textScale = scale.clamp(0.9, 1.6);
    notifyListeners();
  }

  void setButtonSize(double size) {
    _buttonSize = size.clamp(1.0, 1.3);
    notifyListeners();
  }
}

