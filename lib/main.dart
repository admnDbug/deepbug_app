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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Usamos el tema limpio que extrajimos a la carpeta "core"
      theme: AppTheme.lightTheme, 
      // Arrancamos con la pantalla de carga que extrajimos a la carpeta "splash"
      home: const SplashScreen(), 
    );
  }
}