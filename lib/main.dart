// Archivo: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart'; 
import 'features/protocolo5/providers/protocolo5_provider.dart';

import 'features/splash/screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Protocolo5Provider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), 
      ],
      child: const DeepBugApp(),
    ),
  );
}

class DeepBugApp extends StatelessWidget {
  const DeepBugApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Deep Bug',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      
      themeMode: themeProvider.themeMode, 

      home: const SplashScreen(),
    );
  }
}