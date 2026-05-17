// Archivo: lib/features/splash/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/screens/login_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';

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
    _iniciarAnimacionYVerificarSesion();
  }

  Future<void> _iniciarAnimacionYVerificarSesion() async {
    // 1. Esperamos a que Flutter garantice que el primer fotograma ya es visible en la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Le damos un micro-respiro de 100ms por si el celular está desvaneciendo la pantalla nativa
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _startAnimation = true;
        });
      }
    });

    // 2. Damos un retraso visual (1.5s) para que termine la animación
    await Future.delayed(const Duration(milliseconds: 1500));

    // 3. Buscamos el token en la bóveda del teléfono
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (!mounted) return;

    // 4. Tomamos la decisión de a dónde enviarlo
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos si el celular está en modo oscuro
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // El texto que sale de detrás
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutQuart,
              width: _startAnimation ? 160.0 : 0.0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: _startAnimation ? 1.0 : 0.0,
                child: Text(
                  'Deep Bug',
                  maxLines: 1,
                  overflow: TextOverflow.clip, // Evita errores de overflow mientras se anima
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Tu logo (Se queda quieto, el texto sale hacia la izquierda)
            Image.asset(
              isDark ? 'assets/images/Deepbug_dark.png' : 'assets/images/Deepbug_light1.png',
              height: 50,
              width: 50,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}