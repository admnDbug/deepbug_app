import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Archivos de configuración (Datos y Tema)
import 'core/theme/app_theme.dart';
import 'features/protocolo5/providers/protocolo5_provider.dart';

// La única pantalla que el main necesita conocer es la primera (Splash)
import 'features/splash/screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Protocolo5Provider()),
      ],
      child: const DeepBugApp(),
    ),
  );
}

class DeepBugApp extends StatelessWidget {
  const DeepBugApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos el color institucional Teal
    const Color colorInstitucional = Color(0xFF009688);

    return MaterialApp(
      title: 'Deep Bug',
      debugShowCheckedModeBanner: false,
      
      // 1. TEMA CLARO (Traído de app_theme.dart)
      theme: AppTheme.lightTheme,

      // 2. TEMA OSCURO (Traído de app_theme.dart)
      darkTheme: AppTheme.darkTheme,

      // 3. SELECCIÓN DE TEMA (Seguir al Sistema)
      themeMode: ThemeMode.system, // Cambia automáticamente según el celular

      home: const SplashScreen(), // O tu LoginScreen
    );
  }
}