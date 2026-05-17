// Archivo: lib/core/theme/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Por defecto, seguimos al sistema
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _cargarPreferencia();
  }

  // Cambiar el modo y guardarlo
  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    // Guardamos como String: 'system', 'light' o 'dark'
    await prefs.setString('themeMode', mode.toString().split('.').last);
  }

  void _cargarPreferencia() async {
    final prefs = await SharedPreferences.getInstance();
    final String? modeString = prefs.getString('themeMode');
    
    if (modeString != null) {
      if (modeString == 'light') _themeMode = ThemeMode.light;
      if (modeString == 'dark') _themeMode = ThemeMode.dark;
      if (modeString == 'system') _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }
}