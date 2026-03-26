// Archivo: lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color colorInstitucional = Color(0xFF009688);

  // --- TEMA CLARO ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colorInstitucional,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA), 
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      // CORRECCIÓN: Usamos CardThemeData
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300), 
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorInstitucional,
          foregroundColor: Colors.white, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // --- TEMA OSCURO ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colorInstitucional,
        brightness: Brightness.dark, 
      ),
      appBarTheme: const AppBarTheme(
        elevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      // CORRECCIÓN: Usamos CardThemeData
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade800), 
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorInstitucional, 
          foregroundColor: Colors.white, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}