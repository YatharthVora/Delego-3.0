import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system; // follow OS by default

  ThemeMode get mode => _mode;

  // Preferred for Flutter/dart idiom
  void setThemeMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  // Old name for backward compatibility in your project (optional)
  void setMode(ThemeMode mode) => setThemeMode(mode);

  // Optional helpers
  void useSystem() => setThemeMode(ThemeMode.system);
  void useLight() => setThemeMode(ThemeMode.light);
  void useDark() => setThemeMode(ThemeMode.dark);
}
