// Archivo: lib/features/auth/screens/registro_screen.dart

import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../../onboarding/screens/onboarding_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  bool _ocultarPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Permite hacer scroll si el teclado tapa la pantalla
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Botón de regresar en la esquina
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context), // Regresa al Login
                ),
              ),
              Icon(
                Icons.person_add_alt_1_outlined,
                size: 80,
                // Usamos el color principal del tema de forma dinámica
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Crear Cuenta',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Únete a Deep Bug para realizar biomonitoreos',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- FORMULARIO ---
              TextField(
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _ocultarPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _ocultarPassword = !_ocultarPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- BOTONES ---
              ElevatedButton(
                onPressed: () {
                  // AQUI OCURRE LA MAGIA
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen(),
                    ),
                    (Route<dynamic> route) => false, // Esto borra las pantallas anteriores
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  // Eliminamos el color fijo, el Theme se encarga de pintarlo
                ),
                child: const Text(
                  'Registrarme',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // Enlace para volver al login si ya tiene cuenta
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya tienes una cuenta?'),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Inicia Sesión',
                      style: TextStyle(
                        // Color dinámico para que resalte en cualquier tema
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}