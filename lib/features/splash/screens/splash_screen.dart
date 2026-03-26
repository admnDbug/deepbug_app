// Archivo: lib/features/splash/screens/splash_screen.dart

import 'package:flutter/material.dart';
import '../../auth/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  Future<void> _initAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _startAnimation = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Detectamos si el celular está en modo oscuro
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // 2. El Scaffold ya hereda el color de fondo correcto de app_theme.dart
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutQuart,
              width: _startAnimation ? 160.0 : 0.0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _startAnimation ? 1.0 : 0.0,
                child: Text(
                  'Deep Bug',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    // 3. El color del texto se adapta (negro en día, blanco en noche)
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 4. Cambiamos el Icon por tu Image.asset dinámica
            Image.asset(
              isDark ? 'assets/images/Deepbug_dark.png' : 'assets/images/Deepbug_light1.png',
              height: 50, // Mismo tamaño que tenía tu ícono
              width: 50,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}