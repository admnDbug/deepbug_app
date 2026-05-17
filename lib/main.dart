// Archivo: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Archivos de configuración (Datos y Tema)
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart'; // <-- 1. Importamos el nuevo Provider del tema
import 'features/protocolo5/providers/protocolo5_provider.dart';

// La única pantalla que el main necesita conocer es la primera (Splash)
import 'features/splash/screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Protocolo5Provider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // <-- 2. Lo registramos en la app
      ],
      child: const DeepBugApp(),
    ),
  );
}

class DeepBugApp extends StatelessWidget {
  const DeepBugApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Escuchamos activamente las decisiones del usuario sobre el tema
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Deep Bug',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      
      // Simplemente pasamos el objeto del provider
      themeMode: themeProvider.themeMode, 

      home: const SplashScreen(),
    );
  }
}