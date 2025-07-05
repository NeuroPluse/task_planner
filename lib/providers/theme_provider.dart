import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.system
        ? ThemeMode.light
        : _themeMode == ThemeMode.light
            ? ThemeMode.system
            : ThemeMode.system;
    notifyListeners();
  }
}