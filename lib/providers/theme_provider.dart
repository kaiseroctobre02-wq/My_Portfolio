import 'package:flutter/foundation.dart';

/// Global app state that manages the Light / Dark theme.
///
/// Any widget can read [isDarkMode] or call [toggleTheme].
/// When [toggleTheme] runs, `notifyListeners()` tells every
/// subscribed widget to rebuild immediately.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}