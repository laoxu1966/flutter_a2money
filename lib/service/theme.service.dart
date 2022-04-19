import 'package:flutter/material.dart';

import 'pref.service.dart';

class ThemeService with ChangeNotifier {
  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  ThemeService() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _themeMode = ThemeMode.system;

    if (Pref.containsKey('dark')) {
      bool dark = Pref.getBool('dark')!;
      if (dark) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;        
      }
    }

    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    Pref.setBool('dark', _themeMode == ThemeMode.dark);

    notifyListeners();
  }
}
