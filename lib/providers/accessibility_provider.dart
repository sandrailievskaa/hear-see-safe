import 'package:flutter/material.dart';

class AccessibilityProvider extends ChangeNotifier {
  bool _highContrastMode = true;
  bool _largeTextMode = true;
  double _textScale = 1.5;
  double _buttonSize = 1.2;

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
    _textScale = _largeTextMode ? 1.5 : 1.0;
    notifyListeners();
  }

  void setTextScale(double scale) {
    _textScale = scale.clamp(1.0, 2.0);
    notifyListeners();
  }

  void setButtonSize(double size) {
    _buttonSize = size.clamp(1.0, 1.5);
    notifyListeners();
  }
}

